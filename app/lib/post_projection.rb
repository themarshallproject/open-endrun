class PostProjection
	
	attr_reader :post
	def initialize(post)
		@post = post
		self
	end

	def to_array
		post_renderer = PostRenderer.new(post)
		html = post_renderer.render_markdown()
		doc = Nokogiri::HTML(post.content)

		doc.css('body > *').map do |el|
			el.to_html
		end		
	end

end