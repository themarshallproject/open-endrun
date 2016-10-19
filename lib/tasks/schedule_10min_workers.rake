namespace :schedule_10min_workers do
	task default: :environment do
		CachedGoogleAnalyticsQuery.new.run('topline:v1:summary:today', {
			'start-date'  => DateTime.now.strftime("%Y-%m-%d"),
			'end-date'    => DateTime.now.strftime("%Y-%m-%d"),
			'dimensions'  => "ga:pagePath",			
			'metrics'     => "ga:pageviews",			
			'sort'        => '-ga:pageviews',
			'max-results' => '2000'
		})

		CachedGoogleAnalyticsQuery.new.run('topline:v1:summary:yesterday', {
			'start-date'  => (DateTime.now - 1.days).strftime("%Y-%m-%d"),
			'end-date'    => (DateTime.now - 1.days).strftime("%Y-%m-%d"),
			'dimensions'  => "ga:pagePath",			
			'metrics'     => "ga:pageviews",			
			'sort'        => '-ga:pageviews',
			'max-results' => '2000'
		})

		CachedGoogleAnalyticsQuery.new.run('topline:v1:summary:alltime', {
			'start-date'  => '2014-01-01',
			'end-date'    => (DateTime.now).strftime("%Y-%m-%d"),
			'dimensions'  => "ga:pagePath",	
			'metrics'     => "ga:pageviews",			
			'sort'        => '-ga:pageviews',
			'max-results' => '2000'
		})
	end
end