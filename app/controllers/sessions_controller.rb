class SessionsController < ApplicationController

	layout 'login'

	def new
		# pass
	end

	def new_with_token
		# pass
	end
	
	def create
		user = User.find_by_email(params[:email])
		if user && user.authenticate(params[:password])
			cookies.signed[:user_id] = {value: user.id, expires: 7.days.from_now}
			puts "USER LOGIN SUCCESS: #{user.email}"
			redirect_to posts_url, notice: "Logged in!"
			#Pushover.new.send_message("#{user.email} logged in.")
		else
			puts "USER LOGIN FAILURE: #{user.email}"
			redirect_to login_url
			#Pushover.new.send_message("#{params[:email]} FAILED login.")
		end
	end

	def destroy 
		cookies.signed[:user_id] = nil
		redirect_to root_path
	end

	def create_token
		email = params[:email].downcase.strip
		if email =~ /\A[a-z]+@themarshallproject.org\z/			
			user = User.where(email: email).first


			(ENV['BANNED_TMP_MEMBER_EMAILS'] || '').split(',').each do |banned_email|
				if email.include?(banned_email)
					Slack.perform_async('SLACK_DEV_LOGS_URL', {
						channel: "#dev_logs",
						username: "EndRun Login",
						text: "Rejected #{email}, this user is banned.",
						icon_emoji: ":fire:"
					})
					raise "Rejecting banned user #{email}"
				end
			end
			
		
			logger.info "user:#{user.inspect}"
			if user.nil?
				logger.info "Creating user with auto generated password..."
				password = SecureRandom.urlsafe_base64
				user = User.new(email: email, password: password, password_confirmation: password)
				user.save
			end

			user.reset_login_token!
			user.save
			UserMailer.login_token(request.protocol+request.host_with_port, user).deliver

			Slack.perform_async('SLACK_DEV_LOGS_URL', {
				channel: "#dev_logs",
				username: "EndRun Login",
				text: "Login email sent for #{user.email}",
				icon_emoji: ":ferris_wheel:"
			})			
			
		else
			flash.alert = "This email is not eligible at this time."
			redirect_to login_with_token_path
			Slack.perform_async('SLACK_DEV_LOGS_URL', {
				channel: "#dev_logs",
				username: "EndRun Login",
				text: "Rejected login with_token request for: #{email}",
				icon_emoji: ":fire:"
			})
		end
	end

	def process_login_token
		token = params[:token]
		user = User.where(login_token: token).first
		if user && user.login_with_token?(token)			
			cookies.signed[:user_id] = {value: user.id, expires: 7.days.from_now}
			redirect_to admin_url, notice: "Logged in!"

			Slack.perform_async('SLACK_DEV_LOGS_URL', {
				channel: "#dev_logs",
				username: "EndRun Login",
				text: "#{user.email} logged in successfully.",
				icon_emoji: ":ferris_wheel:"
			})
			
		else
			flash.alert = "Invalid or expired link."
			redirect_to login_with_token_url
		end
	end

end
