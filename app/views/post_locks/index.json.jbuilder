json.array!(@post_locks) do |post_lock|
  json.extract! post_lock, :id, :post_id, :user_id, :acquired_at
  json.url post_lock_url(post_lock, format: :json)
end
