class CollectionSummary

  def self.cache_key
    ["collection_summary", "popular_counts", "v1"].join(":")
  end

  def self.generate_popular_counts
    tags = Tag.collection_index_recent
    links = Link.where('created_at > ?', 1.week.ago).all
    link_ids = links.map(&:id)

    result = tags.inject(Hash.new){ |obj, tag|

      taggings = Tagging.where(tag: tag)

      count = taggings.select{ |tagging|
        link_ids.include?(tagging.taggable_id)
      }.count

      obj[tag.id] = count
      obj
    }

    Rails.cache.write(self.cache_key, JSON.generate(result))
    return result
  end

  def self.popular_counts
    JSON.parse(Rails.cache.read(self.cache_key))
  rescue
    {}
  end

  def self.popular(limit: 36)
    start_time = Time.now.utc.to_f


    time_delta = 1.week

    link_ids = Link.where('created_at > ?', time_delta.ago).pluck(:id)

    exclude_tag_ids = Tag.where(tag_type: ['content_type', 'category']).pluck(:id)

    summary = Tagging.where(taggable_id: link_ids, taggable_type: 'Link')
      .select("tag_id, count(*) AS item_count")
      .group("tag_id")
      .order("item_count desc")
      .limit(limit+10)
      .map{ |item|
        [item[:tag_id], item[:item_count]]
      }.select{ |item|
        tag_id, _ = item
        exclude_tag_ids.include?(tag_id) == false
      }.first(limit)

    tag_ids = summary.map{ |tag_id, _|
      tag_id
    }
    tags = Tag.where(id: tag_ids)

    puts "CollectionSummary.popular time=#{Time.now.utc.to_f-start_time}"
    return [summary, tags]
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

end
