class NotifyPublishedPostWorker
	include Sidekiq::Worker

	def perform(post_id)	
		ActiveRecord::Base.connection_pool.with_connection do
			post = Post.find(post_id)
			DebugEmailWorker.perform_async({
				from: 'ivong@themarshallproject.org',
				to: 'ivong+postpub@themarshallproject.org',
				subject: "[#{ENV['RACK_ENV']}] Post Published!",
				text_body: JSON.pretty_generate(post.attributes)
			})
		end
	end
end