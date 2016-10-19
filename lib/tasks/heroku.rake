namespace :heroku do

	desc "Restart Web/Sidekiq Dynos via Heroku API"

	task restart_sidekiq: :environment do
		puts "Running Heroku.restart_sidekiq_dynos..."
		# TODO: check queue depth before doing this?
		Heroku.restart_sidekiq_dynos
	end

	task restart_web: :environment do
		puts "Running Heroku.restart_web_dynos..."
		Heroku.restart_web_dynos
	end

	task restart_random_web: :environment do
		Heroku.restart_random_web_dyno
	end

end
