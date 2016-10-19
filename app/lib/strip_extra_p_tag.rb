module StripExtraPTag

	def self.parse(full_text)
		doc = Nokogiri::HTML.fragment full_text
		doc.css('p').each do |el|
			# if the contents of the p tag starts with [ and ends with ], unwrap it.
			# this needs to happen before shortcodes are expanded, of course.
			if el.text =~ /^\[(.*?)\]$/
				next_el = el.add_next_sibling( el.children.to_html )
				el.remove
			end
		end
		doc.to_html
	end

end
