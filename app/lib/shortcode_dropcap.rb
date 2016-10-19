module ShortcodeDropcap
  def self.regex
    /\[dropcap(.*?)\](.*?)\[\/dropcap\]/m
  end
  def self.parse(html)        
    	  html = html.gsub(self.regex) do |capture|    		
            array_args = $1.squeeze(' ').split(' ')
    		args = array_args.inject({}) { |obj, item|
    			k, v = item.split('=')
    			obj[k.to_sym] = v
    			obj
    		}
            
            type = args.keys.include?(:type) ? args[:type] : 'sans-serif'

            ["<span class=\"dropcap-shim\"></span>",
             "<span class=\"#{type}-dropcap\">", 
             $2, 
             "</span>"
            ].join("") + "\n\n"           
    	end
    end

end