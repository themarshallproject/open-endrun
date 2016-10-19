json.array!(@documents) do |document|
  json.extract! document, :id, :dc_id, :published, :body, :dc_data, :dc_published_url
  json.url document_url(document, format: :json)
end
