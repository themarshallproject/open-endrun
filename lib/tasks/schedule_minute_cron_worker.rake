namespace :schedule_minute_cron_worker do
	task default: :environment do		
		(0..9).step(2).each do |scheduled_minutes|	
			time = scheduled_minutes.minutes		
			id = MinuteCronWorker.perform_in(time)
			puts "schedule_minute_cron_worker time=#{time} id=#{id}"
		end		
	end
end