namespace :collections do

  task build_homepage: :environment do
    CollectionSummary.generate_popular_counts
    Tag.json_collection_index_all
  end

  task build_slices: :environment do
    Tag.all.shuffle.each do |tag|
      ['facebook_count', 'date'].each do |slice|
        CollectionSlice.new(tag_id: tag.id, models: ['link'], slice: slice).generate_memcached
      end
    end
  end

end
