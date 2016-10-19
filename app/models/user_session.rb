class UserSession < ActiveRecord::Base
	belongs_to :user
	after_create :notify_new_session

	def length 
		self.updated_at - self.created_at
	end

	def self.active_sessions
		self.where('updated_at > ?', 10.minutes.ago)
	end

	def self.event_for(user_id)
		user = User.find(user_id)
		session = self.where(user: user).where('updated_at > ?', 10.minutes.ago).first
		if session.nil?
			session = UserSession.new(user: user, events: 0)			
		end

		session.events += 1
		session.save		
	end

	def started_at
		self.created_at
	end

	def ended_at
		self.updated_at
	end

	def notify_new_session
		logger.info "NEW_SESSION for #{self.user.email}"
	end

	def self.summary(num_hours)
		self.where('created_at > ?', num_hours.hours.ago).includes(:user).inject({}) do |obj, session| 
			obj[session.user.email] ||= []
			obj[session.user.email] << {
				started_at: session.started_at.utc.to_i,
				ended_at: session.ended_at.utc.to_i,
				events: session.events,
				length: "#{(session.length/1.minute).round(1)} minutes"
			}
			obj
		end.map do |user_email, data|
			{
				user: user_email,
				sessions: data
			}
		end
	end

end