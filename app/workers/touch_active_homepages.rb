class TouchActiveHomepages
	include Sidekiq::Worker
	sidekiq_options :retry => false

	def perform(post_id)
		ActiveRecord::Base.connection_pool.with_connection do
			FeaturedBlock.published.each do |featured_block|
				puts "TouchActiveHomepages: #{featured_block}, testing #{post_id}"
				featured_block.touch_if_contains_post(post_id)
			end
		end # AR::Base
	end # perform
	
end