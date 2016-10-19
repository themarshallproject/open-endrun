module ShortcodeTag

	def self.parse(full_text, post_id)
    start_time = Time.now.utc.to_f
    
		regex = /\[tag(.*?)\]((.*?)\[\/tag\])/
		output = full_text.gsub(regex) do |capture|
  			data = $1.split(' ').inject({}){|obj, item|
  				k, v = item.split('=')
  				obj[k.to_sym] = v
  				obj
  			}
  			link_text = $3

        # TODO: turn this back on. right now it's a pretty big penalty and is done in the response cycle, which is BAD

        # tag = Tag.find(data[:id])
        # puts "Shortcode in #{post_id}: #{link_text} -- #{data.inspect}"  

        # begin 
        #   self.add_tag_to_post(post_id: post_id, tag_id: data[:id], content: link_text)
        #   "<span data-tag-id='#{tag.id}' data-tag-name='#{tag.name}'><a href='/tags/#{tag.to_param}'>#{link_text}</a></span>"
        # rescue
        #   puts $!
        #   "<span data-tag-id='null' data-tag-not-found='true'>#{link_text}</span>"
        # end
  			
        link_text

  		end 

      ms = ((Time.now.utc.to_f-start_time)*1000).to_i
      $stdout.puts("measure#app.shortcode_tag=#{ms}ms")

      output
	end

  def self.add_tag_to_post(options={content: nil})
    post = Post.find(options[:post_id])
    tag  =  Tag.find(options[:tag_id])
    puts "Checking tagging for Tag:#{tag.inspect}, Post:#{post.inspect}"
    tagging = Tagging.where(taggable: post, tag: tag).first_or_create do |t|
      t.content = options[:content]
      puts "Created Tagging! #{t.inspect}"
    end
  end

end