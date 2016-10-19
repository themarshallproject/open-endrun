class CollectionSliceWorker
	include Sidekiq::Worker
	sidekiq_options :retry => false

	def perform(tag_id, models, slice)
		slice = CollectionSlice.new(tag_id: tag_id, models: models, slice: slice)
    slice.generate_memcached
    slice.generate
	end

end
