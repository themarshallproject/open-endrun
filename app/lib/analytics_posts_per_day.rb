class AnalyticsPostsPerDay

		def column_names
			[
				:date,
				:pageviews,
				:title,				
				:published_date,				
				:path,
				:id,
				:date_delta
			]
		end

		def posts
			# Post.published.order('published_at DESC').offset(100).first(3)
			Post.published.order('published_at DESC').all
		end

		def generate_values(post, row)
			# THESE MUST MATCH POSITIONALLY for column_names
			[
				row[:date],
				row[:pageviews],
				title(post),
				published_date(post),
				path(post),
				id(post),
				row[:date_delta],
			]	
		end

		def csv
			"# Generated #{DateTime.now.to_s}\n" +
			CSV.generate do |csv|
				csv << column_names
				posts.each do |post|
					puts "[GENERATING] '#{post.title}'"
					pageviews(post).each do |row|
						csv << generate_values(post, row)
					end					
				end
			end
		end

		def s3_key
			"endrun-post-analytics-rollup-v1/posts-days.csv" # hardcoded, fun
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
				post.title
			end

			def pageviews(post)
				query = { 		
					'ids' => ENV['GOOGLE_ANALYTICS_ID'],
					'start-date'  => '2014-05-01', # far enough before any post we've published, so we get everything
					'end-date'    => DateTime.now.strftime("%Y-%m-%d"),
					'dimensions'  => "ga:date",			
					'metrics'     => "ga:pageviews",			
					'filters'     => "ga:pagePath=~^#{post.path}",
					'max-results' => '5000',
				}				
				result = GoogleAnalytics.new.query(query)
				rows = result['rows']
				rows.map{ |(date, pageviews)|
					parsed_date = DateTime.parse(date, "%Y%m%d")
					{
						date: parsed_date.strftime("%Y-%m-%d"),
						pageviews: pageviews,
						date_delta: (parsed_date.to_date - post.published_at.to_date).to_i
					}
				}.select{ |obj|
					obj[:date_delta] >= 0
				}
			end

end