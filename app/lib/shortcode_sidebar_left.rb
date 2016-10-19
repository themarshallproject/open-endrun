module ShortcodeSidebarLeft

	def self.parse(full_text, post_id)
		regex = /\[sidebar-left(.*?)\]((.*?)\[\/sidebar-left\])/
		full_text.gsub(regex) do |capture|
  			attrs = $1.split(' ').inject({}){|obj, item|
  				k, v = item.split('=')
  				obj[k.to_sym] = v
  				obj
  			}
  			inner_html = $3

        ["<div class='sidebar-shim'><div class='sidebar-inner'>",
          inner_html,
          "</div></div>\n\n"].join("\n")  			
  		end   
	end

end