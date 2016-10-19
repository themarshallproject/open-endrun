class RedisHeartbeatWorker
  include Sidekiq::Worker

  def perform
    info = $redis.info
    # Librato.group 'redis' do |g|
    #   g.measure 'memory.usage', info['used_memory'].to_i
    #   g.measure 'connected_clients.count', info['connected_clients'].to_i
    # end
  end
end