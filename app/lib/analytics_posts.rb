class AnalyticsPosts

		def column_names
			# implement these methods
			[
				:id, 
				:path,
				:title,
				:published_date,
				:total_pageviews,
				:facebook_share_count,
				:email_signups,
				:word_count,
				:total_partner_pageviews,
				:author,
				:rubric,
				:tags,
			]
		end

		def posts
			Post.published.order('published_at DESC').all
		end

		def lookup_values(post, *column_names)
			column_names.map do |col|
				self.send(col, post)
			end
		end

		def csv
			"# Generated #{DateTime.now.to_s}\n" +
			CSV.generate do |csv|
				csv << column_names
				posts.each do |post|
					puts "[GENERATING] '#{post.title}'"
					csv << lookup_values(post, *column_names)
				end
			end
		end

		def s3_key
			"endrun-post-analytics-rollup-v1/posts.csv" # hardcoded, fun
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

			def id(post)
				post.id
			end
			
			def path(post)
				post.path
			end

			def published_date(post)
				post.published_at.strftime("%Y-%m-%d")
			end

			def title(post)
				post.title.strip
			end

			def word_count(post)
				post.word_count
			end

			def total_pageviews(post)
				query = { 		
					'ids' => ENV['GOOGLE_ANALYTICS_ID'],
					'start-date'  => '2014-01-01',
					'end-date'    => DateTime.now.strftime("%Y-%m-%d"),
					'dimensions'  => "ga:pagePath",			
					'metrics'     => "ga:pageviews",			
					'sort'        => '-ga:pageviews',
					'filters'     => "ga:pagePath=~^#{post.path}",
					'max-results' => '1000',
				}				
				result = GoogleAnalytics.new.query(query)
				result['totalsForAllResults']['ga:pageviews']				
			end

			def total_partner_pageviews(post)
				PartnerPageview.where(post: post).order('updated_at DESC').first.try(:pageviews)
			end

			def facebook_share_count(post)
				escaped_url = URI.escape(post.canonical_url, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
				data = JSON.parse(HTTParty.get("https://api.facebook.com/restserver.php?method=links.getStats&format=json&urls=#{escaped_url}").body)				
				data[0]['share_count']
			end

			def email_signups(post)
				nil
			end

			def author(post)
				Nokogiri::HTML.fragment(post.byline).inner_text.strip.gsub(/^By /, '')
			end

			def rubric(post)
				post.rubric.try(:name).strip
			end

			def tags(post)
				post.tags.map{|tag| tag.name.to_s.strip }.join("|")
			end

end