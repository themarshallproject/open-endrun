class ShortcodeSidebar
	# include Rails.application.routes.url_helpers
	def self.parse(full_text)
		regex = /(\[sidebar(.*?)\])([\s\S]*?)(\[\/sidebar\])/
		full_text.gsub(regex) do |capture|
  			# attrs = $1.split(' ').inject({}){|obj, item|
  			# 	k, v = item.split('=')
  			# 	obj[k.to_sym] = v
  			# 	obj
  			# }
  			inner_html = $3
        	["\n<aside class='sidebar'>", inner_html, "</aside>\n"].join("\n")
  		end
	end

end
