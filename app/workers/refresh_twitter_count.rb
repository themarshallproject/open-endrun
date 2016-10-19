class RefreshTwitterCount
	include Sidekiq::Worker
	def perform
		puts "Twitter deprecated this API."
	end
end