class S3FileUploader

	def initialize(options = {})
		@bucket = options[:bucket]		
		@access_key = options[:access_key]
		@secret_key = options[:secret_key]
	end

	def signature(options = {})
		Base64.encode64(
			OpenSSL::HMAC.digest(
				OpenSSL::Digest::Digest.new('sha1'),
				@secret_key,
				policy({ secret_access_key: @secret_key })
			)
		).gsub(/\n/, '')
	end

	def policy(options = {})
		obj = {
			expiration: '2020-01-01T01:00:00.000Z', #TODO: make this a fixed window. for when we have auth on this.
			conditions: [
				{ bucket: @bucket },
				{ acl: "public-read" },
				["starts-with", "$key", "uploads/"],
				["content-length-range", 1024, 21474836480]
			]
		}
		obj = obj.to_json
		Base64.encode64(obj).gsub(/\n|\r/, '')
	end

end