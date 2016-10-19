class SitemapController < ApplicationController

	layout nil

	def index
		headers['Content-Type'] = 'application/xml'
		@inject_public_cache_control = true

		last_post = Post.published.order('revised_at DESC').first
		if stale?(etag: last_post, last_modified: last_post.revised_at.utc)
			@posts = Post.published.order('revised_at DESC').all		
		end
	end

end