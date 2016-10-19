class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :related_posts, through: :taggings, source: :taggable, source_type: 'Post'
  has_many :related_links, through: :taggings, source: :taggable, source_type: 'Link'
  validates_uniqueness_of :name, case_sensitive: false

  validates :tag_type,   length: { minimum: 2 }
  validates :name, length: { minimum: 2 }

  scope :published, -> { where(public: true) }

  after_create do
    notify_change("Created tag: #{self.name}")
    RebuildAllTagsJSON.perform_async()
    IndexTag.perform_async(self.id)
  end

  before_create do
    self.public = true
    self.slug = name.parameterize
  end

  before_update do
    self.slug = name.parameterize
  end

  after_update do
    GenerateTagSlugsIfNil.perform_async()
    RebuildAllTagsJSON.perform_async()
    IndexTag.perform_async(self.id)
  end

  def to_param
    "#{id}-#{name.parameterize}" rescue "#{id}"
  end

  def related
    Tagging.where(tag_id: self.id)
  end

  def featured_photo
    Photo.find_by(id: self.featured_photo_id)
  end

  def published_related_posts
    self.related_posts.order('revised_at DESC').select(&:published?)
  end

  def links_since(time)
    Tagging.where(taggable: self).count
  end

  def related_tags
    taggings = Tagging.where(tag_id: self.id).order('created_at DESC').first(30)
    items = taggings.map(&:taggable)

    tag_ids = items.compact.flat_map{ |item|
      item.taggings.map(&:tag_id)
    }.reject{|tag_id|
      tag_id == self.id
    }.inject(Hash.new(0)) {|obj, item|
      obj[item] += 1
      obj
    }.sort_by{ |k, v|
      -v
    }

    tags = Tag.where(id: tag_ids.first(7).map{|k, v| k }).reject{|tag|
      tag.tag_type == 'content_type'
    }.first(6)

    return tags
  end

  def self.collection_index_popular(limit: 40)

    link_ids = Link.where('created_at > ?', 1.week.ago).pluck(:id)

    tag_rollup = Tagging.where(taggable_id: link_ids, taggable_type: 'Link')
      .select("tag_id, count(*) AS item_count")
      .group("tag_id")
      .order("item_count desc")
      .map{|item|
        [item[:tag_id], item[:item_count]]
      }

    tag_ids = tag_rollup.map{ |tag_id, _itemcount|
      tag_id
    }.uniq.sort

    tags = Tag.without_types(['content_type', 'category'])
      .where(id: tag_ids)
      .first(limit)

    rollup = tag_rollup


    tags
  end

  def self.json_collection_index_all
    Rails.cache.fetch('tag/v1/json_collection_index_all', expires_in: 10.minutes, race_condition_ttl: 2.minutes) {
      puts "Tag.json_collection_index_all GENERATING"
      Tag.without_types(['content_type', 'category']).all.map{ |tag|
        unless tag.name.downcase.include?('xx')
          {
            id: tag.id,
            slug: tag.to_param,
            name: tag.name,
          }
        end
      }.compact.to_json
    }
  end

  def self.json_collection_index_popular
    Rails.cache.fetch('tag/v1/json_collection_index_popular', expires_in: 1.minute, race_condition_ttl: 10.seconds) {
      self.collection_index_popular(limit: 500).map{ |tag|
        {
          id: tag.id,
          slug: tag.to_param,
          name: tag.name,
        }
      }.to_json
    }
  end

  def total_share_count
    Rails.cache.fetch("tag/v1/total_share_count/#{self.id}", expires_in: 5.minutes, race_condition_ttl: 30.seconds) {
      self.related_links.pluck(:facebook_count).map(&:to_i).reduce(:+)
    }.to_i
  end

  def self.collection_index_recent
    tag_ids = Tagging
      .where(taggable_type: Link)
      .order('created_at DESC')
      .limit(100)
      .map(&:tag_id)
    Tag.without_types(['content_type', 'category']).where(id: tag_ids).order('updated_at DESC').first(40)
  end

  def similar_tags(limit: 10)
    link_ids = Tagging.where(tag: self, taggable_type: 'Link').pluck(:taggable_id)
    top_tags = Tagging.top_tags_from_taggables(type: 'Link', ids: link_ids, limit: limit)
    tag_ids = top_tags.map{|_| _[:tag_id] }
    Tag.without_types(['content_type', 'category']).where(id: tag_ids).where("id != ?", self.id)
  end

  def published?
    self.public == true
  end

  def attach_to(record, user=nil)
    Tagging.where(
      taggable: record,
      tag_id:   self.id
    ).first_or_initialize do |tagging|
      puts "Creating tagging #{tagging} for user #{user}."
      if user.present?
        tagging.user = user
      else
        puts "No user passed to Tag's attach_to... deprecated."
      end
    end
  end

  def remove_from(record, user=nil)
    puts "Tag .remove_from for record=#{record} by user=#{user}"
    Tagging.where(
      taggable: record,
      tag_id:   self.id
    ).destroy_all
  end

  def links
    Tagging.where(tag_id: self.id).where(taggable_type: 'Link').order('created_at DESC').includes(:taggable)
  end

  def posts
    Tagging.where(tag_id: self.id).where(taggable_type: 'Post').order('created_at DESC').includes(:taggable)
  end

  def type
    tag_types[self.tag_type]
  end

  def tag_types
    Hashie::Mash.new(YAML.load_file(File.join(Rails.root, 'config', 'tag_types.yml')))
  end

  def self.generate_slugs_for_nils
    where(slug: nil).each do |item|
      item.slug = item.name.parameterize
      item.save
    end
  end

  def self.generate_slugs_for_emptys
    where(slug: '').each do |item|
      item.slug = item.name.parameterize
      item.save
    end
  end

  def self.get_all
    start_time = Time.now.utc.to_f
    cache_key = Tag.unscoped.order('updated_at DESC').first.updated_at
    result = Rails.cache.fetch("tags:get_all:#{cache_key}") {
      tags = Tag.where.not(tag_type: 'category')
      tags.map do |tag|
        {
          id: tag.id,
          name: tag.name,
          tag_type: tag.tag_type,
          tag_type_name: tag.type.name
        }
      end
    }
    puts "measure#tag_get_all=#{1000*(Time.now.utc.to_f-start_time)}ms"
    return result
  end

  def is_location?
    tag_type == 'location'
  end

  def self.without_types(types_array)
      self.where("id NOT IN (?)", Tag.where(tag_type: types_array).pluck(:id))
  end

  def update_facebook_counts
    links = self.related_links
    links.each{ |link|
      FacebookCountWorker.perform_async(link.id)
    }

    {
      tag_id: self.id,
      count: links.count,
      status: 'running'
    }
  end

  def rebuild_collection_slices
    CollectionSliceWorker.perform_async(self.id, ['link'], 'date')
    CollectionSliceWorker.perform_async(self.id, ['link'], 'facebook_count')
  end

  private

    def notify_change(text)
      Slack.perform_async('SLACK_DEV_LOGS_URL', {
        channel: "#tag_activity",
        username: "Dr. RattleCan",
        text: text,
        icon_emoji: ":doughnut:"
      })
    end

end
