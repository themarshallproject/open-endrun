module ShortcodeBatman

	def self.parse(full_text, post_id)
		regex = /\[batman(.*?)\]((.*?)\[\/batman\])/
		full_text.gsub(regex) do |capture|
  			attrs = $1.split(' ').inject({}){|obj, item|
  				k, v = item.split('=')
  				obj[k.to_sym] = v
  				obj
  			}
  			inner_html = $3

        #["</div><div class='batman'>",
        #  inner_html,
        #  "</div><div class=\"wrapper-1140\">\n\n"].join("\n")

        "<!-- batman disabled, sorry -->"  			
  		end   
	end

end