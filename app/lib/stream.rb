class Stream

  def initialize(settings={})
    defaults = {
      author: nil,
      tag: nil,
      infinity: true,
      end_date: Time.now.strftime('%Y%m%d'),
      except_posts: [],
      min_time: nil,
      show_newsletters: false
    }

    @settings = defaults.merge(settings)
    @author = @settings[:author]
    @tag    = @settings[:tag]

    @settings[:except_posts].map!(&:to_i) # they're strings in the featured block serialization
  end

  def except_posts
    @settings[:except_posts]
  end

  def max_time
    end_date = @settings[:end_date] || Time.now.strftime('%Y%m%d') # can be overwritten with nil by route, so fallback again?
    Time.strptime(end_date, '%Y%m%d').end_of_day.to_time + 1.minute
  end

  def min_time
    return @settings[:min_time] if @settings[:min_time].present?

    Post.where('revised_at < ?', max_time() - 1.day)
      .order('revised_at DESC')
      .offset(10)
      .first
      .revised_at
      .beginning_of_day.to_time - 1.minute

  rescue
    10.years.ago
  end

  def infinite?
    @settings[:infinity] == true
  end

  def self.key(item)
    [item.class.model_name.singular, item.id].join(':')
  end

  def items
    return tag()    if @tag.present?
    return author() if @author.present?
    return main()
  end

  def tag
    $stdout.puts("count#stream.tag=1")
    items = Tagging.where(tag: @tag).map{ |tagging|
      tagging.taggable
    }.select{ |item|
      item.published? rescue false # TODO probably a better way to do this
    }.sort_by{ |item|
      -1 * item.stream_sort_key.to_i # .stream_sort_key must be implemented by any stream-able model
    }

    items.select{ |item|
      item.is_a?(Post) # disable this to flow Links in too
    }
  end

  def author
    $stdout.puts("count#stream.author=1")
    post_ids = UserPostAssignment.where(user: @author).pluck(:post_id)

    Post.published.where(id: post_ids).sort_by{ |item|
      -1 * item.stream_sort_key.to_i
    }
  end

  def main(options={})
    $stdout.puts("count#stream.main=1")
    puts "stream#main for end_date:#{@settings[:end_date]} querying: #{min_time} -> #{max_time}"

    models = [ Post, Letter, FreeformStreamPromo ]

    if @settings[:show_newsletters] == true
      models << Newsletter
    end

    models.flat_map{ |model|
      model.stream(min_time, max_time) # models must implement .stream()
    }.sort_by{ |item|
      -1 * item.stream_sort_key.to_i # models must implement .stream()
    }.reject{ |item|
      # except_posts, initially, is post_ids that are in the featured block
      item.is_a?(Post) and @settings[:except_posts].include?(item.id)
    }.select{ |item|
      item.in_stream?
    }
  end

end
