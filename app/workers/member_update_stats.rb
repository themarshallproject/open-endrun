class MemberUpdateStats
	include Sidekiq::Worker
	sidekiq_options :retry => false
	def perform(member_id, options={})
		ActiveRecord::Base.connection_pool.with_connection do  
			member = Member.find(member_id)
			member.update_stats(options)
		end
	end
end