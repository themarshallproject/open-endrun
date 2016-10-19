class Post < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include Rails.application.routes.url_helpers

  has_many :post_thread_assignments
  has_many :post_threads, through: :post_thread_assignments

  has_many :letters

  belongs_to :featured_photo, class_name: 'Photo'

  validates :title,   length: { minimum: 3 }
  validates :content, length: { minimum: 0 }

  validates :post_format,   length: { minimum: 2 }
  validates :stream_promo,  length: { minimum: 0 }

  validate :has_rubric_if_published # custom validator for category ('rubric') presence if published

  scope :published, -> { where(status: 'published').where('published_at < ?', Time.now) }
  scope :queued,    -> { where(status: 'published').where('published_at > ?', Time.now) }
  scope :drafts,    -> { where(status: 'draft') }

  scope :redirects, -> (id) { where("redirects -> ? LIKE 't'", id) }
  scope :by_year, -> (year) { where("extract(year from published_at) = ?", year) }

  scope :stream, -> (min_time, max_time) {
    published.order('revised_at DESC')
             .where('revised_at > ?', min_time)
             .where('revised_at < ?', max_time)
  }

  has_many :taggings, as: :taggable, dependent: :destroy

  has_many :post_shareables

  before_save do
    self.slug = self.title.parameterize if slug.blank?
    self.slug = self.slug.parameterize # make sure we have a legit slug!
  end

  after_initialize :set_default_values
  def set_default_values
    self.published_at ||= Time.now
    self.revised_at   ||= Time.now
    self.status       ||= 'draft'
    self.post_format  ||= 'base'
    self.stream_promo ||= 'base'

    self.in_stream = true if self.in_stream.nil? # can't use the ||= because this is a boolean and false will always turn into true with ||=
  end

  before_save :bump_revised_at_if_published_at_newer
  before_save :update_redirects

  after_save {
    TouchActiveHomepages.perform_async(self.id)
    FacebookLinterWorker.perform_async(self.id)
  }

  after_save :attach_freeform_byline_users
  after_save :attach_freeform_produced_by_users

  # after_save { SnapshotPost.perform_async(self.id) }

  def has_rubric_if_published
    if status == 'published' and rubric.nil?
      errors.add(:rubric, "must be present if publishing")
    end
  end

  def bump_revised_at_if_published_at_newer # before_save
    if revised_at < published_at
      logger.info "revised_at is BEFORE published_at -- setting it to equal published_at"
      self.revised_at = published_at
    end
  end

  def update_redirects # before_save
    if self.redirects.respond_to?(:merge)
      self.redirects = self.redirects.merge("#{title.parameterize}" => "t")
    else
      logger.info "redirects didnt respond to :merge -- resetting hash"
      self.redirects = {"#{title.parameterize}" => "t"}
    end
  end

  def to_param
    "#{id}-#{slug}"
  end

  def path
    if PostDelegatePath.lookup_path(self).present?
      return PostDelegatePath.lookup_path(self)
    end

    date = published_at.strftime('%Y/%m/%d')
    return "/#{date}/#{slug}"
  end

  def stream_sort_key
    revised_at
  end

  def stream_promo_key
    # the partial that is rendered into the stream
    "stream/posts/#{self.stream_promo}"
  end

  # def inline_html_count
  #   Nokogiri::HTML.fragment(self.content).css('div,sup,span,img').count
  # end

  # def inline_html_css
  #   Nokogiri::HTML.fragment(self.content).css('div,sup,span,img').map{|el|
  #     "<#{el.name} class=\"#{el['class']}\">"
  #   }
  # end

  def in_stream?
    self.in_stream == true
  end

  def is_fullbleed_promo?
    ['photo_essay', 'feature'].include?(self.stream_promo)
  end

  def is_stream_expandable?
    if PostDelegatePath.lookup_path(self).present?
      return false
    end

    if self.post_format == 'freeform'
      return false
    end

    return true
  end

  def states
    {
      'draft'     => 'Draft', # let's keep this first so it's the default
      'published' => 'Published',
    }
  end
  def human_status
    self.states[self.status]
  end

  def published?
    Post.published.exists?(self.id)
  end

  def queued?
    Post.queued.exists?(self.id)
  end

  def rendered_content
    PostRenderer.new(self).render
  end

  def lead_photo
    Photo.find(self.lead_photo_id) rescue nil
  end

  def tags
    tag_ids = Tagging.where(taggable: self).pluck(:tag_id)
    Tag.where(id: tag_ids)
  end

  def footer_tags
    tag_ids = Tagging.where(taggable: self).pluck(:tag_id)
    Tag.where(id: tag_ids).select{ |tag|
      tag.published? and tag.name.present? and tag.slug.present? and (tag.tag_type != 'category')
    }
  end

  def create_version
    PostVersion.create!(
      post_id: self.id,
      content: self.serializable_hash(
        only: [:content, :published_at, :status, :revised_at, :title, :slug, :post_format,
             :deck, :email_content, :byline_freeform, :stream_promo, :revised_at],
        methods: [:byline, :rubric, :letters_count, :format]
      )
    )
  end

  def attach_freeform_byline_users
    (read_attribute(:byline_freeform) || '').gsub(/\[author (.+?)\]/) do |capture|
      user = User.where(slug: $1).first rescue nil
      if user.present?
        UserPostAssignment.where(source: 'byline', user: user, post: self).first_or_create
      end
    end
  end

  def attach_freeform_produced_by_users
    (read_attribute(:produced_by) || '').gsub(/\[author (.+?)\]/) do |capture|
      user = User.where(slug: $1).first rescue nil
      if user.present?
        UserPostAssignment.where(source: 'produced_by', user: user, post: self).first_or_create
      end
    end
  end

  def byline
    # TODO: one of the lovely spots where the model returns HTML.
    if self.byline_freeform.present?
      # returns the HTML
      ShortcodeAuthor.new.call(self.byline_freeform)
    else
      # no freeform, so build it from the combo. returns HTML
      templated_authors = self.authors.map{ |author|
        if author.present? and author.slug.present? and author.name.present?
          # TODO: refactor
          %Q{<span><a href=\"#{author_path(author.slug)}\">#{author.name}</a></span>}
        else
          "<!-- error templating author #{author.id}, check name and slug -->"
        end
      }

      last_author = templated_authors.pop()

      result = if templated_authors.present?
        templated_authors.join(", ") + " and "
      end
      result ||= ''
      result += last_author
      result = "By " + result

    end
  rescue
    "<span style='display:none'>error in byline</span>"
  end

  def available_authors
    User.all.select{ |user|
      user.name.present? and user.slug.present?
    }
  end

  def authors
    assignments = UserPostAssignment.where(source: 'byline', post: self).order('position DESC')
    user_ids = assignments.pluck(:user_id)
    User.find(user_ids).sort_by{|author|
      author.name.split(' ').last.downcase # alphabetical, last name
    }
  rescue
    []
  end

  def authors=(user_ids)
    user_ids ||= []
    current_assignments = user_ids.select{|user_id| user_id.present? }.map do |user_id|
      user = User.find(user_id) rescue nil
      if user.present?
        UserPostAssignment.where(post: self, user: user, source: 'byline').first_or_create
      end
    end

    # current_assignment_ids = current_assignments.map(&:id) rescue []
    # UserPostAssignment.where(post: self, source: 'byline')
    #   .where('id not in (?)', current_assignment_ids).each do |deleted_assignment|
    #     logger.info "destroying: #{deleted_assignment}: #{deleted_assignment.destroy}"
    #   end
  end

  def remove_other_rubric_taggings(category_tag_id_to_save)
    # delete current rubric taggings on this post
    # todo: safe enough, efficent enough?
    all_rubric_tag_ids = Tag.where(tag_type: 'category').pluck(:id).select{|tag_id|
      tag_id != category_tag_id_to_save
    }
    Tagging.where(taggable: self).where('tag_id in (?)', all_rubric_tag_ids).each do |old_rubric_tagging|
      old_rubric_tagging.destroy
    end
  end

  def rubric=(tag_id)
    if tag_id.present?
      tag = Tag.find(tag_id)
      rubric_tagging = Tagging.where(taggable: self, tag: tag).first_or_create
      logger.info "adding #{tag.inspect} -- #{rubric_tagging.inspect}"

      self.remove_other_rubric_taggings(tag.id) # delete existing rubric taggings, except for the new one. move to background?
    else
      logger.info "no rubric saved with post!"
    end
  end

  def rubric
    all_rubric_tag_ids = Tag.where(tag_type: 'category').pluck(:id) # potential optimization, cache this
    tagging = Tagging.where(taggable: self).where(tag_id: all_rubric_tag_ids).order('updated_at DESC').first

    if tagging.present?
      return tagging.tag
    else
      return nil
    end
  end

  def use_freeform_header?
    post_format == 'base_freeform_header'
  rescue
    false
  end

  def available_rubrics
    Tag.where(tag_type: 'category').all.map{|tag|
      [tag.id, tag.name]
    }
  end

  def in_zero_threads?
    self.post_threads.count == 0
  end

  def default_email_content
    [self.title, "[The Marshall Project](#{self.canonical_url})"].join(" ")
  end

  def posts_in_thread
    ([self] + other_posts_in_thread())
      .sort_by{ |post|
        -1 * post.published_at.utc.to_i
      }
  end

  def other_posts_in_thread
    (self.post_threads.first.try(:posts) || []) # TODO FIXME un-ugz
      .select{ |other_post|
        other_post.id != self.id
      }
  end

  def letters_count
    letters.visible.count # TODO cache this
  end

  def featured_letter
    letters.visible.first
  end

  def human_published_at
    published_at.to_s(:full_date)
  end

  def post_formats
    Hashie::Mash.new(YAML.load_file(File.join(Rails.root, 'config', 'post_formats.yml')))
  end

  def stream_promo_options
    Hashie::Mash.new(YAML.load_file(File.join(Rails.root, 'config', 'post_stream_promos.yml')))
  end

  def format
    post_formats[self.post_format]
  end

  def word_count
    Nokogiri::HTML.fragment(self.content).text.split.count
  end

  def estimated_reading_time
    # retval is int seconds
    # 275 WPM is what medium uses
    (60 * word_count / 275.0).floor
  end

  def letters_to_the_editor_enabled?
    true
  end

  def canonical_url(share: nil)
    # TODO, remove 'share', but check `grep -r canonical_url **/*.rb`
    "https://www.themarshallproject.org#{self.path}"
  end

  def escaped_canonical_url
    URI.escape(canonical_url, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end

  def social_query_params(options={})
    { utm_medium: 'social', utm_campaign: 'share-tools'}
      .merge(options).select{ |k, v|
        v != nil
      }.map{ |k, v|
        "#{k}=#{v}"
      }.join("&")
  end

  def stream_promo_photo_url
    if featured_photo.present?
      featured_photo.url_for(size: '740x')
    end
  end

  def stream_dateslug
    self.revised_at.strftime('%Y%m%d')
  end

  def google_analytics_config
    {
      dimension1: rubric.try(:name),
      dimension2: authors.map{ |author| author.name}.join(", "),
      dimension3: self.id,
      title: self.title,
      path: self.path
    }
  end

  def locked?
    if PostLock.where(post: self).empty?
      false
    else
      true
    end
  end

  def locked_at_time
    PostLock.where(post: self).first.try(:updated_at) # used in cache key
  end

  def draft
    self.serialized_draft # JSON blob
  end

  def locked_by
    if PostLock.where(post: self).empty?
      nil
    else
      PostLock.where(post: self).first.user # TODO: sometimes this fails? https://heroku.honeybadger.io/projects/38954/faults/9937681#notice-trace
    end
  end

  def rendered_scss
    scss = [
      "/* auto generated */",
      ".post-#{self.id} {",
        (self.custom_scss rescue ""),
      "}"
    ].join("\n")
    Sass::Engine.new(scss, {syntax: :scss}).render
  rescue
    "/* Error rendering custom SCSS for post */"
  end

  def changes_pending?
    Digest::SHA256.digest(live_yaml) != Digest::SHA256.digest(draft_yaml)
  end

  def live_yaml
    attributes = self.attributes.except('id', 'serialized_draft', 'created_at', 'updated_at', 'redirects')
    Post.new(attributes).to_yaml
  end

  def draft_yaml
    attributes = self.serialized_draft.except('id', 'serialized_draft', 'created_at', 'updated_at', 'redirects')
    Post.new(attributes).to_yaml
  rescue
    nil.to_s
  end

  def mock_draft
    attributes = self.serialized_draft.except('id', 'serialized_draft', 'created_at', 'updated_at', 'redirects')
    Post.new(attributes)
  end

  def featured_block_path(options={})
    config = options[:config]
    slot   = options[:slot]
    if config.present? and slot.present?
      content = "#{slot}-#{config}"
    else
      content = nil
    end
    path + "?ref=hp-#{content}" + PostsHelper.social_hash_id
  end

  def tracked_featured_block_path(options={})
    TrackClick.encode_as_url(
      url: self.featured_block_path(options),
      source: 'featuredblock'
    )
  end

  def author_ids
    self.authors.map(&:id) rescue []
  end
  # def author_ids=(author_ids)
  #   self.authors = author_ids # TODO SHIM!!!!
  # end
  def rubric_id
    self.rubric.id rescue nil
  end

  def tag_ids
    self.tags.map(&:id) rescue []
  end

  def dupe
    PostVersion.create(
      post_id: self.id,
      content: self.export
    )
  end

  def metadata_provider
    PostMetadataProvider.new(post: self)
  end

  def serialize
    [
      :id,
      :created_at,
      :published_at,
      :revised_at,
      :updated_at,
      :title,
      :facebook_headline,
      :twitter_headline,
      :display_headline,
      :author_ids, # PostMock intercepts this setter
      :rubric_id,  # PostMock intercepts this setter
      :tag_ids,    # PostMock intercepts this setter
      :status,
      :stream_promo,
      :slug,
      :redirects,
      :post_format,
      :deck,
      :produced_by,
      :byline_freeform,
      :published_at,
      :revised_at,
      :featured_photo_id,
      :lead_photo_id,
      :inject_html,
      :custom_scss,
      :content,
    ].inject({}) do |obj, item|
      obj[item] = self.send(item)
      obj
    end
  end

  # def surrogate_key
  #   "post post/#{@post.id}" # Fastly
  # end

  def self.topshelf_quickreads
    Post.published.order('revised_at DESC').all.select{ |post|
      post.word_count < 800
    }
  end

  def self.most_recent
    self.published.order('published_at DESC').first
  end

  def self.last_update
    self.all.order('updated_at DESC').first
  end

  def parse_all_links
    Nokogiri::HTML( rendered_content() ).css('a')
  end

  # "Linting" the post, check links, etc
  def lint_cache_key
    html = self.rendered_content()
    content_hash = Digest::SHA256.hexdigest(html)
    "post:#{self.id}:#{content_hash}"
  end
  def lint_response
    response = Rails.cache.read(self.lint_cache_key)
    if response.nil?
      LintPostWorker.perform_async(self.id)
    end
    response
  end

end
