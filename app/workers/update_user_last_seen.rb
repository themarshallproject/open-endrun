class UpdateUserLastSeen
	include Sidekiq::Worker
	sidekiq_options :retry => false

	def perform(user_id, timestamp)
		ActiveRecord::Base.connection_pool.with_connection do
			puts "bumping user_session for #{user_id}"
			user = User.find(user_id)
			user.last_seen = Time.at(timestamp)
			user.save
			UserSession.event_for(user.id)
		end # AR::Base
	end # perform
	
end