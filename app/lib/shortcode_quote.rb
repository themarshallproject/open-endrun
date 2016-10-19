module ShortcodeQuote
  def self.parse(html)
        regex = /\[quote(.*?)\](.*?)\[\/quote\]/m
    	html = html.gsub(regex) do |capture|    		
            array_args = $1.squeeze(' ').split(' ')
    		args = array_args.inject({}) { |obj, item|
    			k, v = item.split('=')
    			obj[k.to_sym] = v
    			obj
    		}
            
            if args.keys.include?(:type)
                contents = $2
                output = ["<div class=\"post-quote-sidebar-shim\"><div class=\"post-quote-#{args[:type]}\">", contents, "</div></div>"].join("\n")
            else
                output = "<span class='shortcode-quote-error' style='display:none;'>#{array_args} is invalid</span>"
            end   

            output  
    	end
    end

end