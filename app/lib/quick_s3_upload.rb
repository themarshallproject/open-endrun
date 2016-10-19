class QuickS3Upload
	
	attr_reader :name

	def initialize(contents: nil, content_type: nil, name: nil)
		@contents = contents
		@content_type = content_type
		@name = name

		if @contents.nil? or @content_type.nil? or @name.nil?
			raise "Please supply contents, content_type, name"
		end

		@name = @name.gsub(/[^\.a-zA-Z0-9]/, '-').squeeze('-')

		self
	end

	def s3_client
		AWS::S3.new(
			use_ssl:           true,
        	access_key_id:     ENV['S3_ASSET_UPLOADS_KEY'],
        	secret_access_key: ENV['S3_ASSET_UPLOADS_SECRET']
		).buckets[ ENV['S3_ASSET_UPLOADS_BUCKET'] ]
	end

	def cache_seconds
		1.minutes
	end

	def sha2_contents
		Digest::SHA256.hexdigest(@contents)
	end

	def key
		[sha2_contents(), name].join('/')
	end

	def upload
		s3_obj = s3_client.objects[key]
		s3_obj.write(
			@contents,
			acl: 'public-read',
			cache_control: "public, max-age=#{cache_seconds.to_i}",
			expires: (Time.now + cache_seconds).httpdate,
			content_type: @content_type
		)
		@s3_public_url = s3_obj.public_url.to_s

		notify()

		self
	end

	def notify
		Slack.perform_async('SLACK_DEV_LOGS_URL', {
	  		channel: "#endrun",
	  		username: "Asset Upload",
	  		text: "Uploaded <#{cdn_url}|#{name}> to S3 via EndRun",
	  		icon_emoji: ":package:"
	  	})
	end

	def cdn_url
		[ENV['S3_ASSET_UPLOADS_CDN'], key()].join('')
	end

end