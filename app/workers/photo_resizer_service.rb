class PhotoResizerService

	### NOT IN USE

	# include Sidekiq::Worker
	# sidekiq_options :queue => :photo

	# include HTTParty
	# default_timeout 8

	# def perform(options={crop: nil})

	# 	if options['photo_id'].nil? or options['photo_original_url'].nil? or options['size'].nil?
	# 		raise "ENDRUN: Check your arguments. photo_original_url, photo_id and size are required."
	# 	end

	# 	# this is an HTTPS call to a Heroku app running imagemagick. 
	# 	# https://bitbucket.org/themarshallproject/ruby-imagemagick-resizer
	# 	# that app does the download -> resize -> upload. 
	# 	# the keys are set as ENV vars
	# 	# another ENV var on that app contains comma-seperated api keys. 
	# 	# one of those keys should be in ENV['PHOTO_RESIZER_API_KEY'] in endrun!
	# 	response = self.class.get(ENV['PHOTO_RESIZER_ENDPOINT'], query: { # HTTParty
	# 		api_key:            ENV['PHOTO_RESIZER_API_KEY'],
	# 		size:               options['size'],
	# 		resize_key:         options['resize_key'],
	# 		photo_original_url: options['photo_original_url']
	# 	})

	# 	if response.code != 200
	# 		Slack.perform_async('SLACK_DEV_LOGS_URL', {
	# 			channel: "#dev_logs",
	# 			username: "PhotoResizerService ERROR",
	# 			text: "ERROR id=#{options['photo_id']} size=#{options['size']} message=#{response.body}",
	# 			icon_emoji: ":fire:"
	# 		})
	# 		$stdout.puts("count#worker.error-photo-resizer-worker=1")

	# 		raise "ERROR:PhotoResizerService: #{options['photo_id']} message=#{response.body}" # sidekiq will then retry
	# 	end

	# 	$stdout.puts("PhotoResizerService id=#{options['photo_id']} response=#{response.body}")
	# 	new_size = JSON.parse(response.body)

	# 	ActiveRecord::Base.connection_pool.with_connection do  
	# 		$stdout.puts Photo.find(
	# 			options['photo_id']
	# 		).add_new_size(
	# 			resize_key: options['resize_key'], 
	# 			public_url: new_size['public_url']
	# 		)
	# 	end

	# 	Slack.perform_async('SLACK_DEV_LOGS_URL', {
	# 		channel: "#dev_logs",
	# 		username: "PhotoResizerService",
	# 		text: "id=#{options['photo_id']} size=#{options['size']} <#{new_size['public_url']}> in #{new_size['elapsed_time']}sec",
	# 		icon_emoji: ":fire:"
	# 	})

	# 	$stdout.puts("count#worker.photo-resizer-worker=1")
	# end
	
end