class CollectionSlice

  attr_reader :tag
  attr_reader :slice
  attr_reader :models
  attr_reader :page

  def valid_slice?(name)
    [:facebook_count, :date].include? name.to_sym
  end

  def initialize(tag_id: nil, models: [], slice: nil, page: 0)
    @page = page
    @original_models = models
    @slice = slice.to_sym
    @models = @original_models.map{|s| model_class(s) }.compact.uniq
    @tag = Tag.find(tag_id)

    @limit = 25

    unless valid_slice?(slice)
      raise "Invalid slice: #{slice}"
    end
  end

  def redis
    $redis
  end

  def total_pages(_total_count)
    (1.0 * _total_count / @limit).ceil
  end

  def key_for(item)
    # expects AR record instance
    "#{item.class.to_s.downcase}:#{item.id}"
  rescue
    nil
  end

  def has_zero_links?
    Tagging.where(tag_id: self.tag.id, taggable_type: 'Link').empty?
  end

  def slice_key
    models = @models.map(&:to_s).map(&:downcase).join(",")
    ["v1", "tag=#{tag.id}", "models=#{models}", "slice=#{slice}"].join("|")
  end

  def slow_fetch_database_items
    # must be called in background worker
    models.flat_map do |model|
      puts "fetch for tag=#{tag} model=#{model}"
      Tagging.where(tag: tag).where(taggable_type: model).includes(:taggable).map(&:taggable)
    end
  end

  def request_rebuild
    lock_time = 5.minutes

    cache_key = "collections_build_lock:v2:#{slice_key}"

    cache_read = Rails.cache.read(cache_key)
    if cache_read.present?
      return "locked|#{cache_read}"
    else
      Rails.cache.write(cache_key, Time.now.utc.to_i, expires_in: lock_time)
      CollectionSliceWorker.perform_async(tag.id, @original_models, slice)
      return 'building'
    end
  end

  def generate
    start_time = Time.now.utc.to_f

    redis.with do |conn|
      conn.del(slice_key)
    end

    slow_fetch_database_items().each do |item|
      key = key_for(item)
      score = self.send(slice, item)
      if score.present?
        redis.with do |conn|
          conn.zadd(slice_key, score, key)
        end
      end
    end

    elasped_time = Time.now.utc.to_f - start_time
    puts "CollectionSlice#generate tag_id=#{tag.id} time=#{elasped_time}"
  end

  def generate_memcached
    start_time = Time.now.utc.to_f

    result = slow_fetch_database_items().map{ |item|
      key = key_for(item)
      score = self.send(slice, item)
      [key, score]
    }.select{ |_, score|
      score.present?
    }.sort_by{ |_, score|
      score # sort order is ASC
    }
    json = JSON.generate(result)
    Rails.cache.write(slice_key, json, expires_in: 60.minutes)

    elasped_time = (1000*(Time.now.utc.to_f - start_time)).to_i
    puts "writing time=#{elasped_time}ms slice_key=#{slice_key}"

    return result
  end

  def total_count
    # redis.with do |conn|
    #   conn.zcard(slice_key)
    # end
    json = Rails.cache.read(slice_key)
    if json.present?
      all_records = JSON.parse(json)
    else
      all_records = []
    end
    return all_records.count
  end

  def redis_records
    offset = @page * @limit

    all_records = redis.with{ |conn|
      conn.zrangebyscore(slice_key, '-inf', '+inf', with_scores: true)
    }.reverse

    records = all_records.slice(offset, @limit).to_a # force array, even if slice returns nil

    puts "redis_records tag='#{@tag.name}', page=#{@page}, limit=#{@limit}, offset=#{offset}, results=#{records.to_json}"

    records
  end

  def memcached_records
    offset = @page * @limit

    json = Rails.cache.read(slice_key)
    if json.present?
      all_records = JSON.parse(json)
      all_records.reverse!
    else
      all_records = []
    end
    subset_records = all_records.slice(offset, @limit).to_a

    puts "memcached_records tag='#{@tag.name}', page=#{@page}, limit=#{@limit}, offset=#{offset}, results=#{subset_records.to_json}"
    return subset_records
  end

  def model_class(name)
    # whitelist of allowed string => model lookup
    {
      "post"    => ::Post,
      "link"    => ::Link,
    }[name]
  end

  ## builder helpers

  def build_query(model, ids)
    base_query = model_class(model).where(id: ids).published

    if model == "post"
      return base_query
    elsif model == "link"
      return base_query
    end
  end

  def result
    results = memcached_records.map{ |key, score|
      model, id = key.split(":")
      {
        _id: id.to_i,
        model: model,
        score: score,
      }
    }

    database_records = results.inject({}){ |obj, item|
      obj[item[:model]] ||= []
      obj[item[:model]] << item[:_id]
      obj
    }.flat_map{ |model, ids|
      build_query(model, ids) # ActiveRecord query
    }

    results.map{ |result|

      record = database_records.select{ |candidate|
        candidate.id == result[:_id] and candidate.class.to_s.downcase == result[:model]
      }.first

      CollectionItemPresenter.new(record).render.with_indifferent_access
    }.select{ |result|
      result['id'].present?
    }
  end

  def date item
    return item.created_at.utc.to_i if item.is_a?(Link)
    return item.revised_at.utc.to_i if item.is_a?(Post)
    return nil
  end

  def facebook_count item
    item.try(:facebook_count)
  end

  def top_fb item
    if item.is_a?(Link) and item.facebook_count > 5000
      item.facebook_count
    end
  end

end
