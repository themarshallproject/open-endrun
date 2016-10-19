class FacebookCountWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(link_id)
    ActiveRecord::Base.connection_pool.with_connection do
      link = Link.find_by(id: link_id)
      if link.nil?
        return false
      end

      url = link.url
      escaped_url = URI.escape(url, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
      data = JSON.parse(HTTParty.get("https://api.facebook.com/restserver.php?method=links.getStats&format=json&urls=#{escaped_url}").body)

      current_share_count = data[0]['share_count'].to_i rescue 0

      previous_share_count = link.facebook_count

      if (current_share_count > 0) and (current_share_count != previous_share_count)
        puts "FacebookCountWorker updating id=#{link.id}, time=#{Time.now.utc.to_i}, previous=#{previous_share_count}, current=#{current_share_count}"

        link.facebook_count = current_share_count
        link.save
      else
        puts "FacebookCountWorker failed for id=#{link.id}"
      end

    end
  end
end
