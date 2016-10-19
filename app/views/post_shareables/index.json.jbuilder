json.array!(@post_sharables) do |post_sharable|
  json.extract! post_sharable, :id, :post_id, :slug, :photo_id, :facebook_headline, :facebook_description, :twitter_headline
  json.url post_sharable_url(post_sharable, format: :json)
end
