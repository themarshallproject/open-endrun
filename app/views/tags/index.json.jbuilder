json.array!(@tags) do |tag|
  json.extract! tag, :id, :name, :slug
  json.url tag_url(tag, format: :json)
end
