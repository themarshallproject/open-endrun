class MarkdownGoogleDoc

# https://developers.google.com/drive/web/manage-downloads
# Documents	HTML	text/html
# Plain text	text/plain
# Rich text	application/rtf
# Open Office doc	application/vnd.oasis.opendocument.text
# PDF	application/pdf
# MS Word document	application/vnd.openxmlformats-officedocument.wordprocessingml.document


	def self.download(options={access_token: nil, id: nil})
		raise "must have id and access_token" unless options[:access_token].present? and options[:id].present?

		response = JSON.parse HTTParty.get("https://www.googleapis.com/drive/v2/files/#{options[:id]}", headers: {
			"Authorization" => "Bearer #{options[:access_token]}"
		}).body

		html = HTTParty.get(response['exportLinks']['text/html'], headers: {
			"Authorization" => "Bearer #{options[:access_token]}"
		}).body

		# doc = HTTParty.get(response['exportLinks']['application/vnd.openxmlformats-officedocument.wordprocessingml.document'], headers: {
		# 	"Authorization" => "Bearer #{options[:access_token]}"
		# }).body

		return html
	end

	def self.highlight(markdown)
		markdown.gsub(/(\[(.*?)\]\((.*?)\))/) do |match|
			"<span class='admin-gdoc-markdown-highlight'>" + $1 + "</span>"
		end
		# .gsub(/\*\*(.*?)\*\*/) do |match|
		# 	"<span class='admin-gdoc-markdown-highlight'>" + $1 + "</span>"
		# end
	end

	def self.parse(html)
		doc = Nokogiri::HTML.fragment(html)

		bold_class   = html.scan(/\.(c\d){font-weight:bold}/).first.first rescue nil  # looks for classes in the form .cX, where X is a number
		italic_class = html.scan(/\.(c\d){font-style:italic}/).first.first rescue nil
		puts "bold_class: #{bold_class}"
		puts "italic_class: #{italic_class}"

		doc.css('style, title, meta, br').each do |el|
			el.remove
		end

		doc.css('a, ul, li').each do |el|
			el.attributes['class'].remove rescue nil
		end

		doc.css('ol, ul, p').each do |el|
			el.add_next_sibling(el.children.to_html+"\n")
			el.remove
		end

		if bold_class.present?
			doc.css(".#{bold_class}").each do |el|
				el.content = "**#{el.content}**"
			end
		end
		if italic_class.present?
			doc.css(".#{italic_class}").each do |el|
				el.content = "*#{el.content}*"
			end
		end

		doc.css('span').each do |el|
			el.add_next_sibling(el.children.to_html)
			el.remove
		end

		doc.css('li').each do |el|
			el.add_next_sibling("\n - " + el.children.to_html)
			el.remove
		end

		doc.css('a').each do |el|
			href = self.parse_googled_href(el['href'])
			link_text = el.text.strip

			if link_text.squeeze(' ').length > 1
				el.add_next_sibling("[#{link_text}](#{href})")
			else
				el.add_next_sibling(link_text)
			end

			# next_el = next_el.to_html.squeeze(' ')
			el.remove
		end

		return doc
	end

	def self.parse_googled_href(input)
		if input.include?('www.google.com/url?q=')
			query = URI.parse(input).query
			params = CGI::parse(query)
			return params['q'].first
		else
			return input
		end
	rescue
		"UNKNOWN_LINK"
	end

end