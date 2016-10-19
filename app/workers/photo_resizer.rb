class PhotoResizer
	include Sidekiq::Worker
	sidekiq_options :retry => 1, :queue => :photo

	def perform(options={})

		start_time = Time.now.utc.to_f

		if options['photo_id'].nil? or options['photo_original_url'].nil? or options['size'].nil?
			raise "Check your arguments. photo_id and size are required."
		end

		### download and resize

		image = MiniMagick::Image.open(options['photo_original_url'])
		image.auto_orient
		image.resize(options['size'])

		image.strip
		image.quality(85) # TODO: test this

		temp_file_path = Rails.root.join('tmp', "resized_#{SecureRandom.hex(20)}")
		image.write(temp_file_path)

		puts "PhotoResizer: writing to tempfile:#{temp_file_path}"


		### upload

		s3 = AWS::S3.new(
			use_ssl:           true,
        	access_key_id:     ENV['S3_PHOTO_ACCESS_KEY'],
        	secret_access_key: ENV['S3_PHOTO_SECRET_KEY']
		).buckets[ ENV['S3_PHOTO_BUCKET'] ]
		s3_obj = s3.objects[options['resize_key']]
		
		cache_length = 5.minutes
		s3_obj.write(
			file: temp_file_path,
			acl: 'public-read',
			cache_control: "public, max-age=#{cache_length.to_i}",
			expires: (Time.now + cache_length).httpdate
		)
		public_url = s3_obj.public_url.to_s


		### update database with new s3 key

		ActiveRecord::Base.connection_pool.with_connection do
			Photo.find(
				options['photo_id']
			).add_new_size(
				resize_key: options['resize_key'], 
				public_url: public_url
			)
		end

		cut_time = Time.now.utc.to_f - start_time
		puts "PhotoResizer: #{options.to_json} in #{cut_time}sec => #{public_url}"

		$stdout.puts("count#worker.photo-resizer-worker=1")

		### cleanup

		File.delete(temp_file_path) # remove the resized, local image
		image.destroy!              # clean up the minimagick tempfile


		### notify

		if cut_time > 2 # seconds
			Slack.perform_async('SLACK_DEV_LOGS_URL', {
				channel: "#dev_logs",
				username: "PhotoResizer",
				text: "id=#{options['photo_id']} size=#{options['size']} <#{public_url}> in #{cut_time}sec",
				icon_emoji: ":fire:"
			})
		end

	end
	
end