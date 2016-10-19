class FacebookRecentPostSharesV1Worker
	include Sidekiq::Worker

	def perform
		post_urls = Post.published.where('published_at > ?', 1.week.ago).map do |post| 
			post.canonical_url
		end
		
		response = HTTParty.post(ENV['THRILLER_MOST_FACEBOOK_ENDPOINT'], body: {
			token: ENV['THRILLER_TOKEN'],
			post_urls: post_urls
		})
		
		parsed_response = JSON.parse(response.body) # make sure we get a valid JSON object
		puts "FacebookRecentPostSharesV1Worker: parsed response: #{parsed_response}"

		if response.present? and response.code == 200
			# :response is a serialized column, pass an object, not a string:
			ExternalServiceResponse.create(action: 'topshelf_v1_social', response: parsed_response)
		else
			raise "FacebookRecentPostSharesV1Worker result was nil or an error: #{response.inspect}"
		end

	end

end