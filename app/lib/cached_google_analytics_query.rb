class CachedGoogleAnalyticsQuery

	def key(slug)
		['cached_analytics_query', 'v1', slug.parameterize].join(":")
	end
	
	def run(slug, _query)
		run_time = Time.now.utc.to_i

		query = _query.merge({'ids' => ENV['GOOGLE_ANALYTICS_ID']})
		result = GoogleAnalytics.new.query(query)

		data = {
			time: run_time,
			result: result
		}.to_json

		Rails.cache.write(key(slug), data, expires_in: 12.hours)

		return result
	end

	def get(slug)
		text = Rails.cache.read(key(slug))
		obj = begin
			JSON.parse(text)
		rescue 
			puts "Error parsing key=#{key(slug)} text=#{text}"
			{}
		end

		return obj
	end

end