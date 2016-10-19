class SyncMailchimpCampaign
	include Sidekiq::Worker
	sidekiq_options :retry => false
	
	def perform(newsletter_id, html, text)
		ActiveRecord::Base.connection_pool.with_connection do
			mailchimp = Mailchimp::API.new(ENV['MAILCHIMP_API_KEY'])
			newsletter = Newsletter.find(newsletter_id)

			if newsletter.email_subject == Newsletter.default_subject_line
				raise "Default email subject line, rejecting sync request" 
			end

			# http://apidocs.mailchimp.com/api/2.0/campaigns/update.php
			puts mailchimp.campaigns.update(
				newsletter.mailchimp_id, 
				'options', 
				{
					subject: newsletter.email_subject
				}
			)

			update_result = mailchimp.campaigns.update(
				newsletter.mailchimp_id, 
				'content', 
				{
					html: html,
					text: text
				}
			)

			newsletter.archive_url = update_result['data']['archive_url']
			newsletter.save

			Slack.perform_async('SLACK_DEV_LOGS_URL', {
				channel: "#dev_logs",
				username: "NewsletterBot",
				text: "Updated Mailchimp campaign for '#{newsletter.email_subject}' (id=#{newsletter_id}) <#{newsletter.archive_url}> <#{newsletter.mailchimp_web_url}>",
				icon_emoji: ":ferris_wheel:"
			})
		end
	end

end