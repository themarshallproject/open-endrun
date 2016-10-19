class EmailSignupWorker
	include Sidekiq::Worker

	def perform(email_signup_id)
		ActiveRecord::Base.connection_pool.with_connection do
			email_signup = EmailSignup.find(email_signup_id)

			unless email_signup.email.to_s.include?('@')
				puts "Skipping EmailSignupWorker for #{email_signup.inspect}"
				return false
			end

			result = email_signup.add_to_mailchimp()

			puts "EmailSignupWorker: mailchimp.lists.subscribe '#{email_signup}' => #{result.inspect}"
			Slack.perform_async('SLACK_DEV_LOGS_URL', {
					channel: "#dev_logs",
					username: "EmailSignupWorker",
					text: "SUCCESS: #{email_signup.inspect} -- #{result.inspect}",
					icon_emoji: ":triangular_flag_on_post:"
			})
		end # with_connection
	end

end
