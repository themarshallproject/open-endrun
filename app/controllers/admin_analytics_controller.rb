
class AdminAnalyticsController < ApplicationController
	before_action :verify_current_user_present

	# https://developers.google.com/analytics/devguides/reporting/core/dimsmets

	def daily_email
		dae = DailyAnalyticsEmail.new
		render html: dae.render_to_string()
	end

	def today
		@response = GoogleAnalytics.new.query({
			'ids' => ENV['GOOGLE_ANALYTICS_ID'],
			'start-date' => DateTime.now.strftime("%Y-%m-%d"),
			'end-date'   => DateTime.now.strftime("%Y-%m-%d"),
			'dimensions' => "ga:pagePath",
			'metrics' => "ga:pageviews",
			'sort' => '-ga:pageviews',
			'max-results' => '500'
		})
	end

	def json_weekly
		@response = GoogleAnalytics.new.query({
			'ids' => ENV['GOOGLE_ANALYTICS_ID'],
			'start-date' => (DateTime.now - 1.days).strftime("%Y-%m-%d"),
			'end-date'   => (DateTime.now - 1.days).strftime("%Y-%m-%d"),
			'dimensions' => "ga:date,ga:pagePath,ga:fullReferrer",
			'metrics' => "ga:pageviews",
			# 'filters'  => 'ga:pageviews > 10',
			'sort' => '-ga:pageviews',
			'max-results' => '5000'
		})
		result = @response['rows'].map do |(date, path, referrer, pageviews)|

			post_id = begin
				Post.find_by(slug:
					Rails.application.routes.recognize_path(path)[:slug]
				).try(:id)
			rescue
				nil
			end

			{
				date: Date.parse(date, "%Y%m%d"),
				path: path,
				referrer: referrer,
				pageviews: pageviews.to_i,
				post_id: post_id
			}
		end

		render json: result
	end

	def engaged_time
		@response = GoogleAnalytics.new.query({
			'ids' => ENV['GOOGLE_ANALYTICS_ID'],
			'start-date' => "2010-01-01",
			'end-date'   => DateTime.now.strftime("%Y-%m-%d"),
			'dimensions' => "ga:eventAction",
			'metrics' => "ga:totalEvents",
			'filters' => ['ga:eventCategory==v1_engaged_time', 'ga:pagePath=='+params[:path]].join(";"),
			'max-results' => '500'
		})

		@timeseries = @response['rows'].map do |(seconds, counts)|
			[seconds.to_i, counts.to_i]
		end.sort_by do |(seconds, _)|
			seconds
		end
	end

	def edu
		google_client = GoogleAnalytics.new

		days = (params[:days] || 1).to_i

		startDate = (DateTime.now - days.days).strftime("%Y-%m-%d")
		endDate = DateTime.now.strftime("%Y-%m-%d")

		# https://developers.google.com/analytics/devguides/reporting/core/v3/reference
		# https://developers.google.com/analytics/devguides/reporting/core/dimsmets#cats=page_tracking

		response = google_client.query({
			'ids' => ENV['GOOGLE_ANALYTICS_ID'],
			'start-date' => startDate,
			'end-date' => endDate,
			'dimensions' => "ga:pagePath,ga:fullReferrer",
			'filters' => [
				'ga:pagePath=~^\/201\d\/\d\d\/\d\d\/\w+',
				'ga:fullReferrer=~.*\.(gov|edu).*'
			].join(';'),
			'metrics' => "ga:pageviews",
			'max-results' => '50000'
		})
		render json: response
	end

	def edu_total
		google_client = GoogleAnalytics.new


		startDate = (DateTime.now - 365.days).strftime("%Y-%m-%d")
		endDate = DateTime.now.strftime("%Y-%m-%d")

		# https://developers.google.com/analytics/devguides/reporting/core/v3/reference
		# https://developers.google.com/analytics/devguides/reporting/core/dimsmets#cats=page_tracking

		response = google_client.query({
			'ids' => ENV['GOOGLE_ANALYTICS_ID'],
			'start-date' => startDate,
			'end-date' => endDate,
			'dimensions' => "ga:source",
			'filters' => [
				'ga:fullReferrer=~.*\.edu.*'
			].join(';'),
			'metrics' => "ga:pageviews",
			'max-results' => '50000'
		})
		render text: JSON.pretty_generate(response)
	end

	def referers
		render json: GoogleAnalytics.new.query({
			'ids' => ENV['GOOGLE_ANALYTICS_ID'],
			'start-date' => (DateTime.now - 12.months).strftime("%Y-%m-%d"),
			'end-date'   => DateTime.now.strftime("%Y-%m-%d"),
			'dimensions' => "ga:source,ga:month", #{}"ga:fullReferrer",
			'metrics'	 => "ga:pageviews",
			'sort'       => "ga:month,-ga:pageviews",
			'max-results' => '5000'
		})
	end

	def event_ref
		@response = GoogleAnalytics.new.query({
			'ids' => ENV['GOOGLE_ANALYTICS_ID'],
			'start-date' => (DateTime.now - 1.month).strftime("%Y-%m-%d"),
			'end-date'   => DateTime.now.strftime("%Y-%m-%d"),
			'dimensions' => "ga:date,ga:pageview,ga:fullReferrer",
			'metrics'	 => "ga:pageview",
			'sort'       => "ga:date",
			'max-results' => '1000'
		})
		render json: @response
	end

	def yesterday
		@pageviews = GoogleAnalytics.new.query({
			'ids' => ENV['GOOGLE_ANALYTICS_ID'],
			'start-date' => (DateTime.now - 1.day).strftime("%Y-%m-%d"),
			'end-date'   => (DateTime.now - 1.day).strftime("%Y-%m-%d"),
			'dimensions' => "ga:pagePath",
			'metrics' => "ga:pageviews",
			'sort' => '-ga:pageviews',
			'max-results' => '25'
		})

		@source = GoogleAnalytics.new.query({
			'ids' => ENV['GOOGLE_ANALYTICS_ID'],
			'start-date' => (DateTime.now - 1.day).strftime("%Y-%m-%d"),
			'end-date'   => (DateTime.now - 1.day).strftime("%Y-%m-%d"),
			'dimensions' => "ga:source",
			'metrics' => "ga:pageviews",
			'sort' => '-ga:pageviews',
			'max-results' => '25'
		})
	end

	def ga_test
		google_client = GoogleAnalytics.new

		startDate = "2014-08-03"
		endDate = DateTime.now.strftime("%Y-%m-%d")

		# https://developers.google.com/analytics/devguides/reporting/core/v3/reference
		# https://developers.google.com/analytics/devguides/reporting/core/dimsmets#cats=page_tracking

		response = google_client.query({
			'ids' => ENV['GOOGLE_ANALYTICS_ID'],
			'start-date' => startDate,
			'end-date' => endDate,
			'dimensions' => "ga:pagePath,ga:date",
			'filters' => 'ga:pagePath=~^\/201\d\/\d\d\/\d\d\/\w+', #;ga:pageviews>=10',
			'metrics' => "ga:pageviews",
			'max-results' => '50000'
		})

		rows = response['rows']

		paths = rows.map{|row|
			row[0] # path
		}.map{|path|
		 	path = path.split("?").first
		 	path = path.split(".").first
		 	if path.scan(/^\/201\d\/\d\d\/\d\d\S+(\/)$/).count == 1
		 		path = path[0..-2]
		 	end
		 	path
		}.uniq

		dates = rows.map{|row|
			row[1] # date
		}.map{|date|
		 	date
		}.uniq.map(&:to_i).sort

		data = []
		str_dates = dates.map{|date| date = date.to_s; "#{date[0..3]}-#{date[4..5]}-#{date[6..7]}"} # yyyymmdd -> yyyy-mm-dd
		data << (["Path"] + str_dates).flatten.join("\t")

		paths.each do |path|
			row = [path]

			have_seen_non_null = false

			dates.each do |date|
				pageviews = rows.select{|row|
					row[0].include?(path) and row[1].to_s == date.to_s
				}.map{|row|
					row[2].to_i # pageviews
				}.reduce(:+)

				if pageviews.to_i > 0
					have_seen_non_null = true
				end

				if have_seen_non_null == true
					pageviews ||= 0
				end

				row << pageviews
			end

			data << row.join("\t")
		end

		render plain: data.join("\n")
	end

	def partners_nojs
		# url = "#{ENV['LOVESTORY_ELASTICSEARCH_READONLY_URL']}/pixels/external_nojs/_search"
		# query = {
		#   size: 0,
		#   aggregations: {
		#     group_by_slug: {
		#       terms: {
		#         field: "slug"
		#       }
		#     }
		#   }
		# }
		# @response = HTTParty.post(url, body: query.to_json)
	end

	def lovestory_total
		@response = HTTParty.post(
			"#{ENV['LOVESTORY_ELASTICSEARCH_READONLY_URL']}/pixel-external/_search",
			body: File.open(
				File.join(Rails.root, 'lovestory-queries', 'table-slug.raw.json')
			).read
		)
	end

	def mailchimp_merge
		@yes_endrun = []
		@no_endrun = []
		emails = EmailSignup.all
		known_emails = emails.map(&:email)

		f_yes_endrun = File.open(File.join(Rails.root, 'tmp', 'mailchimp-yes-endrun.tsv'), 'w')
		f_no_endrun  = File.open(File.join(Rails.root, 'tmp',  'mailchimp-no-endrun.tsv'), 'w')
		CSV.foreach(File.join(Rails.root, 'tmp', 'mailchimp.csv'), headers: true) do |row|
			if known_emails.include?(row['Email Address'])
				puts "y"
				f_yes_endrun.puts([
					row.to_hash.values,
					emails.select{|e| e.email == row['Email Address']}.first.attributes.values
				].join("\t"))
			else
				puts "n"
				f_no_endrun.puts row.to_hash.values.join("\t")
			end
		end
		render plain: "done"
	end

	def gator_domains
		render content_type: 'text/tsv', plain: Link.where('created_at > ?', Date.parse("2015-01-01"))
			.order('created_at ASC')
			.pluck(:url).map{|url|
				URI.parse(url).host rescue nil }
			.compact
			.map{|u|
				u.gsub(/^www\./, "")
			}.group_by{|d|
				d
			}.map{|k, v|
				[k, v.count]
			}.sort_by{|k, v|
				-v
			}.map{|k, v| [k, v]
				.join("\t")
			}.join("\n")
	end

	def mailchimp_webhooks
		rows = MailchimpWebhook.order('created_at DESC').map{|webhook|
			[
				webhook.created_at.to_time.iso8601,
				webhook.event_type,
				webhook.email,
			].join("\t")
		}.join("\n")
		header = ["time", "type", "email"].join("\t")

		render plain: header + "\n" + rows
	end

end
