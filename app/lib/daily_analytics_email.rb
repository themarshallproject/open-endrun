class DailyAnalyticsEmail
	def initialize(days_ago: 1)
		@days_ago = days_ago
		@date = (DateTime.now - @days_ago.days)
		@date_string = @date.strftime("%Y-%m-%d")
	end

	def top_stories
		@top_stories ||= begin
			pageviews_result = GoogleAnalytics.new.query({ 
				'ids' => ENV['GOOGLE_ANALYTICS_ID'], 
				'start-date' => @date_string,
				'end-date'   => @date_string,
				'dimensions' => "ga:pagePath",			
				'metrics' => "ga:pageviews",
				'sort' => '-ga:pageviews',
				'max-results' => '10'
			})

			pageviews_result['rows'].select do |(path, _)|
				path.include?('/201') or path.include?('next-to-die')
			end.map do |(path, pvs)|
				_, year, month, day, slug = path.split('/')
				{
					path: path,
					pvs: pvs.to_i,
					slug: slug,
					post: Post.where(slug: slug).first
				}
			end
		end
	end

	def top_stories_paths
		top_stories.map{|story| story[:path] }
	end
		
	def top_stories_ga_filter
		f = top_stories_paths.map do |path|
			"ga:pagePath==#{path}"
		end.join(",")
		puts f

		f
	end

	def crowdtangle
		@crowdtangle ||= Crowdtangle.new.query
	end

	
	def top_stories_all_pvs
		@top_stories_all_pvs ||= GoogleAnalytics.new.query({ 
			'ids' => ENV['GOOGLE_ANALYTICS_ID'], 
			'start-date' => '2014-01-01',
			'end-date'   => @date.strftime("%Y-%m-%d"),
			'dimensions' => "ga:pagePath",			
			'metrics' => "ga:pageviews",
			'filters' => top_stories_ga_filter(),
			'max-results' => '20'
		})['rows']
	end

	def daily_total_pageviews
		GoogleAnalytics.new.query({ 
			'ids' => ENV['GOOGLE_ANALYTICS_ID'], 
			'start-date' => @date_string,
			'end-date'   => @date_string,
			'dimensions' => "",			
			'metrics' => "ga:pageviews",
			'sort' => '-ga:pageviews',
			'max-results' => '2'
		})['rows'].first.first.to_i
	end

	def source
		@source ||= begin
			@source_result = GoogleAnalytics.new.query({ 
				'ids' => ENV['GOOGLE_ANALYTICS_ID'], 
				'start-date' => @date_string,
				'end-date'   => @date_string,
				'dimensions' => "ga:source", 
				'metrics' => "ga:pageviews", # add email conversion rate metric to table	
				'sort' => '-ga:pageviews',
				'max-results' => '25'
			})

			@source_result['rows'].inject({}) do |obj, (source, pvs)|
				key = 'facebook.com' if source.include?('facebook')
				
				if ["t.co", "twitter", "twitterfeed", "tweetlist", "twitterrific.com", "topsy.com", "mobile.twitter.com", "twittergadget.com", "tweetedtimes.com", "tweetdeck.twitter.com", "hootsuite.com"].include?(source)
					key = 'twitter'
				end

				key ||= source

				obj[key] ||= { rows: [] }
				obj[key][:rows] << {
					source: source,
					pvs: pvs.to_i
				}
				obj
			end.inject({}){|obj, (source, data)|
				obj[source] = data
				obj[source][:total_pvs] = data[:rows].map{|r| r[:pvs] }.reduce(:+)
				obj
			}.sort_by{|k, v|
				-1*v[:total_pvs]
			}
		end
	end

	def this_month_total
		@this_month_total ||= begin
			GoogleAnalytics.new.query({ 
				'ids' => ENV['GOOGLE_ANALYTICS_ID'], 
				'start-date' => @date.beginning_of_month().strftime("%Y-%m-%d"),
				'end-date'   => @date_string,
				'dimensions' => "",			
				'metrics' => "ga:pageviews",
				'sort' => '-ga:pageviews',
				'max-results' => '5'
			})['rows'].first.first.to_i
		end
	end

	def last_month_total
		@last_month_total ||= begin
			GoogleAnalytics.new.query({ 
				'ids' => ENV['GOOGLE_ANALYTICS_ID'], 
				'start-date' => (@date - 1.month).beginning_of_month().strftime("%Y-%m-%d"),
				'end-date'   => (@date - 1.month).end_of_month().strftime("%Y-%m-%d"),
				'dimensions' => "",			
				'metrics' => "ga:pageviews",
				'sort' => '-ga:pageviews',
				'max-results' => '5'
			})['rows'].first.first.to_i
		end
	end

	def render_to_string
		OfflineTemplate.new			
			.set_instance_vars(
				days_ago: @days_ago,
				date: @date,
				date_string: @date_string,
				top_stories: top_stories,
				last_month_total: last_month_total,
				this_month_total: this_month_total,
				source: source,
				daily_total_pageviews: daily_total_pageviews,
				crowdtangle: crowdtangle,		
				top_stories_all_pvs: top_stories_all_pvs		
			)
			.render_to_string('admin_analytics/daily_email', layout: false)
	end

	def send_email!
		doc = Nokogiri::HTML.fragment( self.render_to_string() )

		attachments = doc.css('img.inline').map do |img|
			cid = "cid:"+SecureRandom.hex
			data = {
				"Name" => 'chart.png',
				"Content" => img.attr('data-encoded'), # this is a base64 encoded version of the png stashed on a data attr
				"ContentType" => 'image/png',
				"ContentID" => cid
			}
			img.attributes['data-encoded'].remove
			img['src'] = cid
			data
		end
		puts attachments
		puts doc.to_html

		DebugEmailWorker.new.perform({
			from: 'ivong@themarshallproject.org',
			to: (ENV["DAILY_ANALYTICS_EMAIL"] || "").split(","),
			subject: "Analytics #{@date_string}",
			text_body: "Please view the HTML version of this email",
			attachments: attachments,
			html_body: doc.to_html
		})
	end

		

	
end