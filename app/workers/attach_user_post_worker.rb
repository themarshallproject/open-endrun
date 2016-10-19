class AttachUserToPostWorker
	include Sidekiq::Worker

	def perform(args={})
		ActiveRecord::Base.connection_pool.with_connection do		
			UserPostAssignment.first_or_create!(
				source: args['source'],
				user: User.find(args['user_id']),
				post: Post.find(args['post_id'])
			)
		end
	end
end
