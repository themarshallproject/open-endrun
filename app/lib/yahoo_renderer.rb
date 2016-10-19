class YahooRenderer

	def initialize(post)		
		@post = post		
	end

	def render()	
		# non_closing_shortcodes_regex = /\[[^\/](.+?)\]/

		html = render_markdown(@post.content)

		html = StripExtraPTag.parse(html)

		html.gsub!(ShortcodeDivider.regex) do |capture|
			# dividers can be approximated by a string
			"* * *"
		end

		html.gsub!(ShortcodeAnnotation.selector_regex) do |capture|
			# pass thru the selector body text
			"#{$2}"
		end

		html.gsub!(ShortcodeAnnotation.body_regex) do |capture|
			# drop out the actual annotation
			""
		end

		html.gsub!(ShortcodeGraphic.regex) do |capture|
			# strip graphics
			"<!-- graphic -->"
		end

		html.gsub!(ShortcodePhoto.regex) do |capture|
			# strip photos placed by shortcode
			"<!-- photo -->"
		end

		html.gsub!(ShortcodeSubhead.regex) do |capture|
			["<p><strong>", $2, "</strong></p>"].join("")
		end

		tagged_url = @post.canonical_url + "?utm_campaign=partners&utm_source=yahoo&utm_medium=referral"



		result = [
			"<p><em>This article was originally published by <a href=\"#{tagged_url}\">The Marshall Project</a>.</em></p>",
			html
		].join("\n")

		return result.html_safe
	end

	def render_markdown(content)
		options = {
			autolink: false,
			no_intra_emphasis: true,
			fenced_code_blocks: true,
			lax_html_blocks: true,
			strikethrough: true,
			superscript: true,
			disable_indented_code_blocks: true
		}
		
		markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, options)
		markdown.render(content).html_safe
	end

end