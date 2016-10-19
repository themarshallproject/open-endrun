namespace :sidekiq do
	task report: :environment do
		sidekiq_stats = Sidekiq::Stats.new
	    payload = JSON.pretty_generate({
	      sidekiq: {
	        processed:       sidekiq_stats.processed,
	        failed:          sidekiq_stats.failed,
	        # busy:            sidekiq_stats.workers_size,
	        # processes:       sidekiq_stats.processes_size,
	        enqueued:        sidekiq_stats.enqueued,
	        scheduled:       sidekiq_stats.scheduled_size,
	        retries:         sidekiq_stats.retry_size,
	        dead:            sidekiq_stats.dead_size,
	        # default_latency: sidekiq_stats.default_queue_latency
	      }
	    })

	    puts payload

	    if (sidekiq_stats.enqueued > 0)
		    puts HTTParty.post(ENV['SLACK_DEV_LOGS_URL'], body: {
				channel: "#dev_logs",
				username: "Sidekiq Stats",
				text: "#{payload}",
				icon_emoji: ":fire:"
			}.to_json)
		   
		   	puts DebugEmailWorker.new.perform({
		   		from: 'ivong@themarshallproject.org',
				to: 'ivong+sidekiq@themarshallproject.org',
				subject: "[#{ENV['RACK_ENV']}] EndRun/Sidekiq Queue Status",
				text_body: payload
		   	})
	    end

	end
end
