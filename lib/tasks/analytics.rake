namespace :analytics do
	task send_daily_email: :environment do 
		puts DailyAnalyticsEmail.new.send_email!
	end

	task generate_posts_csv: :environment do 
		puts AnalyticsPosts.new.persist_csv
	end

	task generate_posts_days_csv: :environment do 
		puts AnalyticsPostsPerDay.new.persist_csv
	end
	
	task generate_links_csv: :environment do 
		puts AnalyticsLinks.new.persist_csv
	end
	
end
