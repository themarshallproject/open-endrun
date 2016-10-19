class MinuteCronWorker
	include Sidekiq::Worker
	sidekiq_options :retry => false

	def perform
		ScanNewPublishedPosts.perform_async
		PostLockSweeper.perform_async
	end

end
