json.array!(@partners) do |partner|
  json.extract! partner, :id, :name
  json.url partner_url(partner, format: :json)
end
