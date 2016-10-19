class CreateWeeklyNewsletterMailchimpCampaign
	include Sidekiq::Worker

	def create_campaign
		mailchimp = Mailchimp::API.new(ENV['MAILCHIMP_API_KEY'])

		campaign = mailchimp.campaigns.create('regular', {
			list_id: ENV['MAILCHIMP_LIST_ID'],
			subject: WeeklyNewsletter.default_subject_line,
			from_email: 'info@themarshallproject.org',
			from_name: 'The Marshall Project',
			to_name: '',
			auto_footer: false,
		}, {
			html: "(no content)"
		})
		puts "Created Weekly Mailchimp campaign: #{campaign.inspect}"
		return campaign
	end

	def perform(newsletter_id)
		ActiveRecord::Base.connection_pool.with_connection do
			newsletter = WeeklyNewsletter.find(newsletter_id)

			if newsletter.mailchimp_id.present?
				puts "Newsletter id=#{newsletter_id} already has a Mailchimp campaign, skipping creation."
			else
				campaign = create_campaign()
				newsletter.mailchimp_id     = campaign['id']
				newsletter.mailchimp_web_id = campaign['web_id']
				newsletter.save
				puts "Created Mailchimp WEEKLY campaign for newsletter: #{newsletter.inspect}"
				Slack.perform_async('SLACK_DEV_LOGS_URL', {
					channel: "#dev_logs",
					username: "WeeklyNewsletterBot",
					text: "Created Mailchimp campaign for newsletter id=#{newsletter_id}",
					icon_emoji: ":ferris_wheel:"
				})
			end
		end
	end

end