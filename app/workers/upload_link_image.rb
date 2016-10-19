class UploadLinkImage
	include Sidekiq::Worker
	sidekiq_options :retry => false
	
	def perform(link_id)
		ActiveRecord::Base.connection_pool.with_connection do  

			puts "UploadLinkImage for id=#{link_id}"
			link = Link.find(link_id)
			image_url = link.og_image_url
			
			if image_url.present?				
				url = S3SyncUpload.new.perform({
					access_key: ENV['S3_GATOR_ACCESS_KEY'],
					access_secret: ENV['S3_GATOR_ACCESS_SECRET'],
					bucket: ENV['S3_GATOR_BUCKET'],
					key: "#{ENV['RACK_ENV']}/links/#{link.id}/fb_image/original",
					contents: HTTParty.get(image_url).parsed_response
				})
				link.fb_image_url = url
				link.save
			else
				puts "UploadLinkImage: no image_url for link id=#{link_id}, SKIPPING UPLOAD"
				$stdout.puts("count#worker.upload-link-image-no-url=1")
			end
			
		end
	end
end