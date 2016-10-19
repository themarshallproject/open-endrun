json.array!(@links) do |link|
  json.extract! link, :id, :url, :title, :creator_id, :content
  json.url link_url(link, format: :json)
end
