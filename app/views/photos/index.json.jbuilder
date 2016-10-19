json.array!(@photos) do |photo|
  json.extract! photo, :id, :original_url, :caption, :byline
  json.url photo_url(photo, format: :json)
end
