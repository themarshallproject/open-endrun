class AssetFile < ActiveRecord::Base
	
	validates :source, length: { minimum: 3 }
	validates :slug,   length: { minimum: 3 }

	before_save do
		self.source = source.parameterize
		self.slug = slug.parameterize
	end

	def public_url
		[ENV['S3_ASSET_UPLOADS_CDN'], self.s3_key].join('')
	end

	def inline_upload content
		@content = content
		@content_type = "application/json"

		upload!
	end

	private

		def generate_key
			[
				"asset_file",
				"v1",
				self.id,
				self.source,
				self.slug,
			].join("/")
		end

		def s3_client
			AWS::S3.new(
				use_ssl:           true,
				access_key_id:     ENV['S3_ASSET_UPLOADS_KEY'],
				secret_access_key: ENV['S3_ASSET_UPLOADS_SECRET'],
			).buckets[ ENV['S3_ASSET_UPLOADS_BUCKET'] ]
		end

		def upload!
			key = generate_key()

			cache_seconds = 1.minute
			obj = s3_client.objects[key]
			obj.write(
				@content,
				acl: 'public-read',
				cache_control: "public, max-age=#{cache_seconds.to_i}",
				expires: (Time.now + cache_seconds).httpdate,
				content_type: @content_type
			)
			self.s3_url = obj.public_url.to_s
			self.s3_key = key
			self.save
		end

end