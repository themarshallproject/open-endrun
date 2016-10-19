class RebuildAllTagsJSON
	include Sidekiq::Worker
	sidekiq_options :retry => false

	def perform
		puts "RebuildAllTagsJSON"
		ActiveRecord::Base.connection_pool.with_connection do
			Tag.get_all()
		end
	end

end
