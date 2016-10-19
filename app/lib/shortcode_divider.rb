class ShortcodeDivider
	def self.regex
		/\[divider\]([\s\S]*?)\[\/divider\]/m
	end
	def self.parse(full_text)		
	    full_text.gsub!(self.regex) do |capture|
	        inner_html = $1
			['<div class="divider">',
			   '<div class="line"></div>',
			   '<div class="timestamp">',
			     inner_html,
			   '</div>',
			 '</div>'].join("\n") 
	    end
		full_text
	end
end