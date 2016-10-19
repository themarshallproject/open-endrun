class TopshelfProvider

	def self.facebook_service_response
		ExternalServiceResponse.where(action: 'topshelf_v1_social').order('created_at DESC').first
	end

	def self.facebook
		# TODO: fix this:
		return []

		# record = self.facebook_service_response
		# items = record.response.sort_by do |item|
		# 	-1*item['facebook_count']
		# end
		# posts = Post.published.where('published_at > ?', 2.weeks.ago)

		# sorted_posts = items.map do |item|
		# 	posts.select do |post|
		# 		item['url'].include?(post.path)
		# 	end.first
		# end

		# sorted_posts.compact
	rescue
		puts "ERROR: TopshelfProvider.facebook error=#{$!.inspect}"
		[]
	end
end