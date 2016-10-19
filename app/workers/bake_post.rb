class BakePost
	
	include Sidekiq::Worker
	sidekiq_options retry: 0

	def perform(post_id)
		ActiveRecord::Base.connection_pool.with_connection do
			puts "BakePost for id=#{post_id}"
			post = Post.find(post_id)		

			html = OfflineTemplate.new
				.set_instance_vars(post: post)
				.render_to_string('posts/show', layout: 'public')

			url = S3SyncUpload.new.perform({
				access_key:    ENV['S3_BAKE_KEY'],
				access_secret: ENV['S3_BAKE_SECRET'],
				bucket:        ENV['S3_BAKE_BUCKET'],
				key: "posts/#{post.slug}",
				contents: html
			})
			puts "BakePost id=#{post_id} -> #{url}"

			$redis.with do |conn|
				conn.set("bakepost/v1/post/#{post.id}", html)
			end
		end

		Slack.perform_async('SLACK_DEV_LOGS_URL', {
			channel: "#dev_logs",
			username: "Baker",
			text: "Baked post id=#{post_id} -> <#{url}>",
			icon_emoji: ":fire:"
		})
	end
end