class StatusController < ApplicationController

  protect_from_forgery except: []

  def index
    redis()
    postgres()
    cache()
    elasticsearch()

    render text: "OK"
  end

  private

    def redis
      cache_key = "status_controller_redis_v1"
      test_val = SecureRandom.hex
      @result = nil
      $redis.with do |conn|
        conn.set(cache_key, test_val)
        @result = conn.get(cache_key)
      end

      if test_val != @result
        raise "StatusController#redis -- failed get/set test"
      end
    end

    def postgres
      result = ActiveRecord::Base.connection.execute("SELECT 1;").result_status.to_s
      if result != "2"
        raise "StatusController#postgres -- SELECT 1 –– expected='2', got=#{result}"
      end
    end

    def cache
      cache_key = "status_controller_cache_v1"
      test_val = SecureRandom.hex

      Rails.cache.write(cache_key, test_val)
      read_val = Rails.cache.read(cache_key)

      if test_val != read_val
        raise "StatusController#redis -- failed get/set test -- expected=#{test_val}, got=#{read_val}"
      end
    end

    def elasticsearch
      url = ENV[ENV['ELASTICSEARCH_VAR']]
      client = Elasticsearch::Client.new(url: url)
      status = client.info['status']
      if status != 200
        raise "StatusController#elasticsearch -- failed health check –– expected=200, got=#{status}"
      end
    end

end
