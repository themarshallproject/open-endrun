class SyncWeeklyNewsletterMailchimpCampaign
	include Sidekiq::Worker
	sidekiq_options :retry => false
	
	def perform(weekly_newsletter_id, html, text)
		ActiveRecord::Base.connection_pool.with_connection do
			mailchimp = Mailchimp::API.new(ENV['MAILCHIMP_API_KEY'])
			weekly_newsletter = WeeklyNewsletter.find(weekly_newsletter_id)

			# http://apidocs.mailchimp.com/api/2.0/campaigns/update.php
			puts mailchimp.campaigns.update(
				weekly_newsletter.mailchimp_id, 
				'options', 
				{
					subject: weekly_newsletter.email_subject
				}
			)

			update_result = mailchimp.campaigns.update(
				weekly_newsletter.mailchimp_id, 
				'content', 
				{
					html: html,
					text: text
				}
			)

			weekly_newsletter.archive_url = update_result['data']['archive_url']
			weekly_newsletter.save

			Slack.perform_async('SLACK_DEV_LOGS_URL', {
				channel: "#email",
				username: "Closing Argument",
				text: "Updated Mailchimp campaign for '#{weekly_newsletter.email_subject}' (id=#{weekly_newsletter_id}) <#{weekly_newsletter.archive_url}>",
				icon_emoji: ":ferris_wheel:"
			})
		end
	end

end