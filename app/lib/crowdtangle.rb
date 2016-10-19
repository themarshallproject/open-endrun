class Crowdtangle

	def base_uri
		"https://apps.crowdtangle.com/api/posts"
	end

	def app_name
		ENV['CROWDTANGLE_APP_NAME']		
	end

	def app_token
		ENV['CROWDTANGLE_APP_TOKEN']		
	end
	
	def query(type: 'total_engagement', timeframe: '1day', format: 'json', lists: '32976')
		JSON.parse(HTTParty.get(base_uri, query: {
			dashboard: app_name,
			token: app_token,
			type: type,
			timeframe: timeframe,
			lists: lists,
			format: format
		}).body)
	end

end