class ScanNewPublishedPosts
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform
    start_time = Time.now.utc.to_f
    ActiveRecord::Base.connection_pool.with_connection do
      ActiveRecord::Base.transaction do

        post_ids = Post.published.pluck(:id) - PostPublishedEvent.pluck(:post_id)

        post_ids.each do |post_id|
          puts "PostPublishedEvent: Checking id=#{post_id}"

          PostPublishedEvent.where(
            post_id: post_id
          ).first_or_create! { |event|
            puts "PostPublishedEvent: CREATE for id=#{post_id}"
            event.perform!
          }

        end
      end
    end
    puts "ScanNewPublishedPosts finished in #{Time.now.utc.to_f - start_time}"

  end
end
