json.array!(@yahoo_posts) do |yahoo_post|
  json.extract! yahoo_post, :id, :post_id, :title, :published
  json.url yahoo_post_url(yahoo_post, format: :json)
end
