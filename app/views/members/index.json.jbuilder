json.array!(@members) do |member|
  json.extract! member, :id, :name, :email, :token, :last_seen_at, :last_ip, :active
  json.url member_url(member, format: :json)
end
