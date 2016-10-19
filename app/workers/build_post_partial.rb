class BuildPostPartial
	
	include Sidekiq::Worker
	sidekiq_options retry: 0

	def perform(post_id)
		ActiveRecord::Base.connection_pool.with_connection do
			post = Post.find(post_id)		

			html = OfflineTemplate.new
				.set_instance_vars(post: post)
				.render_to_string("public/posts/single_post_partial")

			puts "BuildPostPartial for #{post_id}: #{html.length} characters"
		end
	end
end