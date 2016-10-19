json.array!(@freeform_stream_promos) do |freeform_stream_promo|
  json.extract! freeform_stream_promo, :id, :slug, :html, :revised_at, :deploy_token
  json.url freeform_stream_promo_url(freeform_stream_promo, format: :json)
end
