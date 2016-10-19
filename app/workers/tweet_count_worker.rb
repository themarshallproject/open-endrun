class TweetCountWorker
	include Sidekiq::Worker
	sidekiq_options :retry => false

	def perform(link_id)
		puts "Twitter deprecated this API."
		# ActiveRecord::Base.connection_pool.with_connection do  
		# 	link = Link.find(link_id)
		# 	url = link.url
		# 	escaped_url = URI.escape(url, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
		# 	data = JSON.parse(HTTParty.get("http://cdn.api.twitter.com/1/urls/count.json?url=#{escaped_url}").body)
		# 	link.tweet_count = data['count']
		# 	link.save
		# 	$stdout.puts("count#worker.tweet-count-worker=1")
		# end
	end
end