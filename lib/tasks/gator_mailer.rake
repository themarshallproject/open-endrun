namespace :gator_mailer do
	task send_daily_email: :environment do 
		GatorMailer.daily_email.deliver_now
	end
end