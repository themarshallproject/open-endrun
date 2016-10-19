module ShortcodeTweet

	def self.parse(full_text, post_id)
		regex = /\[tweet(.*?)\]/
		output = full_text.gsub(regex) do |capture|
			url = $1.strip
			output = %Q{<div class="tweet-embed">
				<blockquote class="twitter-tweet" lang="en"><a href="#{url}"></a></blockquote>
				<script type="text/javascript" async src="//platform.twitter.com/widgets.js"></script>
			</div>}
			puts "ShortcodeTweet: rewriting #{url} -- #{capture} => #{output}"
			output
		end
	end
end