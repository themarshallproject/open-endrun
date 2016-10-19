class DebugEmailWorker
	include Sidekiq::Worker
	
	def perform(data)
		if ENV['POSTMARK_API_KEY'].blank?
			puts "DebugEmailWorker run without POSTMARK_API_KEY, skipping send"
			return
		end
		client = Postmark::ApiClient.new(ENV['POSTMARK_API_KEY'], secure: true, http_open_timeout: 5)
		client.deliver(data.symbolize_keys)
	end
end