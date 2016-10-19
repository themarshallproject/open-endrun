class IndexTag
	include Sidekiq::Worker
	sidekiq_options :retry => false

	def perform(tag_id)
		puts "IndexTag id=#{tag_id}"
		ES.index_tag(tag_id)
	end

end
