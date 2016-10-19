class ESIndexAllLinksWorker
	include Sidekiq::Worker
	sidekiq_options :retry => false

	def perform
		puts "ESIndexAllLinksWorker rebuilding index"
		puts ES.index_all_links
	end # perform
	
end