json.array!(@partner_pageviews) do |partner_pageview|
  json.extract! partner_pageview, :id, :post_id, :partner_id, :url, :pageviews
  json.url partner_pageview_url(partner_pageview, format: :json)
end
