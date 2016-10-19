class PullLogsForEmailSignup
	include Sidekiq::Worker
	sidekiq_options :retry => false

	def perform(email_signup_id)
		ActiveRecord::Base.connection_pool.with_connection do
			email_signup = EmailSignup.find(email_signup_id)
			puts HTTParty.get("https://papertrailapp.com/api/v1/events/search.json", headers: {
				"X-Papertrail-Token" => ENV['PAPERTRAIL_TOKEN']
			}, query: {
				q: "ivarvong.com"
			});
		end # AR::Base
	end # perform
	
end