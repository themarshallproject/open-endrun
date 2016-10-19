json.array!(@featured_blocks) do |featured_block|
  json.extract! featured_block, :id, :template, :slots, :published
  json.url featured_block_url(featured_block, format: :json)
end
