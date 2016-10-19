class PostLockSweeper
	include Sidekiq::Worker
	sidekiq_options :retry => false

	def perform
		logger.info "PostLockSweeper perform starting..."
		ActiveRecord::Base.connection_pool.with_connection do

			PostLock.cleanup_stale_locks

		end # AR::Base
	end # perform
	
end