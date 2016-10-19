json.array!(@posts) do |post|
  json.extract! post, :id, :content, :format_id, :publish_at, :status
  json.url post_url(post, format: :json)
end
