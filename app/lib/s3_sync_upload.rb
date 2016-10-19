class S3SyncUpload
	def perform(options={})
		# kword args: access_key, access_secret, bucket, key, contents
		# returns public url
		# puts options.inspect
		
		url = AWS::S3.new(
			access_key_id: options[:access_key], 
			secret_access_key: options[:access_secret]
		)
		.buckets[options[:bucket]]
		.objects[options[:key]]
		.write(
		 	options[:contents], 
		 	acl: options[:acl] || :public_read
		).public_url.to_s

		# puts "S3Uploaded: #{url}"

		return url

	end
end