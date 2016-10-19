class LinkDownloadWorker
	include Sidekiq::Worker
	sidekiq_options :retry => 2

	def perform(link_id)
		ActiveRecord::Base.connection_pool.with_connection do
			puts "LinkDownloadWorker link_id=#{link_id} now..."
			link = Link.find_by(id: link_id)
			if link.nil?
				return false
			end

			url = link.url
			html_contents = HTTParty.get(url).body			
			
			html_url = S3SyncUpload.new.perform({
				access_key: ENV['S3_GATOR_ACCESS_KEY'],
				access_secret: ENV['S3_GATOR_ACCESS_SECRET'],
				bucket: ENV['S3_GATOR_BUCKET'],
				key: "#{ENV['RACK_ENV']}/links/#{link.id}/html",
				contents: html_contents
			})
			link.html_url = html_url
			link.html = ""
			link.save

			link.update_og_image # calls UploadLinkImage async
			$stdout.puts("count#worker.link-downloader-worker=1")
		end
	end
end