class LintPostWorker
	include Sidekiq::Worker

	def perform(post_id)	
		
		post = Post.find(post_id)
		cache_key = post.lint_cache_key

		html = post.rendered_content()
		doc = Nokogiri::HTML.fragment(html)

		links = doc.css('a')
		
		check_http_codes = links.map do |link|
			url = link['href']

			result = begin
				request = HTTParty.get(url, timeout: 3)
				{ 
				 	passed: (request.code == 200),
					status_code: request.code,
					body_size: request.body.length,
					content_type: request.content_type
				}
			rescue
				{
					passed: false,
					error: $!.inspect
				}
			end

			result.merge({ url: url })
		end

		result = {
			cache_key: cache_key,
			generated_at: "#{Time.now.utc.iso8601}",
			check_http_codes: check_http_codes			
		}

		Rails.cache.write(
			cache_key, 
			result.to_json, 
			expires: 1.day
		)

		Slack.perform_async('SLACK_DEV_LOGS_URL', {
			channel: "#dev_logs",
			username: "LintPostWorker",
			text: JSON.pretty_generate(result),
			icon_emoji: ":fire:"
		})				
	end
end