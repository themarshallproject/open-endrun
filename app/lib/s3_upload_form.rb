class S3UploadForm

	def initialize(bucket: nil, access_key: nil, secret_key: nil, prefix: nil)
		raise "Must have bucket, access_key and secret_key" unless [bucket, access_key, secret_key].all?
		@bucket = bucket
		@access_key = access_key
		@secret_key = secret_key
		@prefix = prefix
		self
	end

	def prefix(key_prefix)
		@key_prefix = key_prefix

		self
	end

	def expiration
		Time.now.utc + 10.minutes
	end

	def human_policy
		#raise "No key" if prefix.nil?

		{
			expiration: expiration().iso8601,
			conditions: [
				{ bucket: @bucket },
				{ acl: "public-read" },
				["starts-with", "$key", @prefix],
				["content-length-range", 1, 21474836480]
			]
		}
  	end

  	def policy
  		Base64.encode64(human_policy.to_json).gsub(/\n|\r/, '')
  	end

	def signature
		Base64.encode64(
			OpenSSL::HMAC.digest(
				OpenSSL::Digest::Digest.new('sha1'),
				@secret_key,
				policy({ secret_access_key: @secret_key })
			)
		).gsub(/\n/, '')
	end

end