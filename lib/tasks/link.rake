namespace :link do
  task update_facebook_count: :environment do
  	Link.where('created_at > ?', 7.days.ago).each do |link|
  		puts "queueing #{link.url} for FacebookCountWorker"
  		link.update_facebook_count
  	end
  end

  task export_facebook_count: :environment do
    puts ["id", "domain", "facebook_share_count", "url"].join(",")
    Link.order('id DESC').all.each do |link|
      host = URI.parse(link.url).host.gsub(/^www\./, '') rescue nil
      count = link.facebook_count.to_i
      if host.present? and count > 0
        puts [link.id, host, count, link.url].join(",")
      end
    end
  end

end
