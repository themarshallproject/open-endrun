class PublicSearchQuery < ActiveRecord::Base

	# after_create do
	# 	Slack.perform_async('SLACK_DEV_LOGS_URL', {
	# 		channel: "#endrun",
	# 		username: "SearchQuery",
	# 		text: "'#{self.query}' (referer: #{self.referer})",
	# 		icon_emoji: ":doughnut:"
	# 	})
	# end

	def user_first_seen
		Time.at(self.token.split('|p|').first.to_i)
	end
end
