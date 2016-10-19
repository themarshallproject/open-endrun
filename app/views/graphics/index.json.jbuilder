json.array!(@graphics) do |graphic|
  json.extract! graphic, :id, :slug, :html, :head
  json.url graphic_url(graphic, format: :json)
end
