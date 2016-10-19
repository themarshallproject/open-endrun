class CreatePostVersion
	
	include Sidekiq::Worker
	sidekiq_options retry: 0

	def perform(post_id)
		ActiveRecord::Base.connection_pool.with_connection do
			post = Post.find(post_id)		
			# TODO
		end
	end
end