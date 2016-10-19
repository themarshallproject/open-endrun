class AnalyticsLinks

		def column_names
			# implement these methods
			[
				:link_id, 
				:link_url,
				:link_tags,
				:mailchimp_campaign_web_id
			]
		end

		def links
			Link.order('created_at DESC').all
		end

		def lookup_values(link, *column_names)
			column_names.map do |col|
				self.send(col, link)
			end
		end

		def csv
			"# Generated #{DateTime.now.to_s}\n" +
			CSV.generate do |csv|
				csv << column_names
				links.each do |link|
					puts "[GENERATING] '#{link.url}'"
					values = lookup_values(link, *column_names)
					puts "Writing: #{values.to_json}"
					csv << values
				end
			end
		end

		def s3_key
			"endrun-links-v1/links.csv"
		end

		def persist_csv
			contents = csv()
			S3SyncUpload.new.perform(
				access_key: ENV['S3_UPLOAD_ACCESS_KEY'],
				access_secret: ENV['S3_UPLOAD_SECRET_KEY'],			
				bucket: ENV['S3_UPLOAD_BUCKET'],
				key: s3_key(),
				contents: contents,
				acl: 'private'
			)
		end

		def cached_csv
			AWS::S3.new(access_key_id: ENV['S3_UPLOAD_ACCESS_KEY'], secret_access_key: ENV['S3_UPLOAD_SECRET_KEY'])
				.buckets[ENV['S3_UPLOAD_BUCKET']]
				.objects[s3_key()]
				.read
		end

		private

			def link_id(link)
				link.id
			end

			def link_url(link)
				link.url
			end

			def link_tags(link)
				tags = link.taggings.map(&:tag)
				tags.map(&:name).map(&:strip).join("|")
			end

			def mailchimp_campaign_web_id(link)
				link.newsletters_appeared_in.map(&:mailchimp_web_id).join("|")
			end

end