class GenerateTagSlugsIfNil
	include Sidekiq::Worker

	def perform
		ActiveRecord::Base.connection_pool.with_connection do
			puts Tag.generate_slugs_for_nils()
			puts Tag.generate_slugs_for_emptys()
		end
	end

end
