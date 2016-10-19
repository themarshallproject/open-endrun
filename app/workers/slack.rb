class Slack
	include Sidekiq::Worker

	# Slack.perform_async('SLACK_GATOR', {
	# 	text: 'a new thing! and a <http://google.com> link'
	# })
	# where ENV['SLACK_GATOR'] is the https endpoint
	def perform(env_var, payload, options={force: false})	
		if ENV[env_var].blank?
			puts "No ENV var for Slack present"
			return
		end

		if ENV['RACK_ENV'] == 'production' or options[:force] == true
			HTTParty.post(ENV[env_var], body: payload.to_json)
		else
			puts "Would sent to Slack: #{payload.to_json}"
		end
	end

end