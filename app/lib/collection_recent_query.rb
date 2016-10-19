class CollectionRecentQuery

  def limit
    80
  end

  def taggings
    # limit+20 because we'll filter out the non-content_type/etc tags later
    @tagging_data ||= begin
      Tagging.order('created_at DESC').select(:created_at, :tag_id).limit(limit()+20).all.map do |tagging|
        {
          created_at: tagging.created_at,
          tag_id: tagging.tag_id
        }
      end
    end
  end

  def tag_ids
    ids = taggings.map{ |tagging|
      tagging[:tag_id]
    }

    ids.uniq
  end

  def tags
    @tags ||= begin
      Tag.without_types(['content_type', 'category']).where(id: tag_ids).all
    end
  end

  def find_intermediate(tag_id)
    tags.select do |tag|
      tag.id == tag_id
    end.first
  end

  def perform
    taggings.map{ |tagging|
      {
        created_at: tagging[:created_at],
        tag: find_intermediate(tagging[:tag_id])
      }
    }.select{ |obj|
      # if we dropped a tag because it's content_type/etc, remove from result set
      obj[:tag].present?
    }.first(limit())
  end

end
