class ESIndexAllPostsWorker
	include Sidekiq::Worker
	sidekiq_options :retry => false

	def perform
		puts "ESIndexAllPostsWorker rebuilding index"
		puts ES.index_all_published_posts
	end # perform
	
end