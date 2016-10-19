json.array!(@post_threads) do |post_thread|
  json.extract! post_thread, :id, :name
  json.url post_thread_url(post_thread, format: :json)
end
