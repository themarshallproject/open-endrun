if $redis.present?
  puts "config/initializers/redis.rb: $redis already exists"
else
  $redis = ConnectionPool.new(size: 5, timeout: 5) { 
    Redis.new(url: ENV[ENV['REDIS_PROVIDER']])
  }
end
