class ShortcodeQaquestion
	def self.parse(full_text)
		regex = /\[qa\-question\]([\s\S]*?)\[\/qa\-question\]/m
	    full_text.gsub!(regex) do |capture|
	        inner_html = $1
			['<div class="askedanswered-shim">',
				'<span class="askedanswered-question">',
				'<svg width="11px" height="11px" version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 223.2 223.2" enable-background="new 0 0 223.2 223.2" xml:space="preserve"><g><g><polygon fill="#1A1A1A" points="3.6,3.6 3.6,219.6 34.5,219.6 34.5,34.5 		"/><polygon fill="#1A1A1A" points="65.3,65.3 65.3,219.6 96.2,219.6 96.2,96.2 		"/><polygon fill="#1A1A1A" points="188.7,34.5 188.7,219.6 219.6,219.6 219.6,3.6 		"/><polygon fill="#1A1A1A" points="127,96.2 127,219.6 157.9,219.6 157.9,65.3 		"/></g></g></svg>',
				 inner_html,
				'</span>',
			'</div>'].join("\n")
	    end
		full_text
	end
end