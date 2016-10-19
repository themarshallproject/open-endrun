module ShortcodeAssets
  def self.parse(html)
        html
    	# html.gsub(/\[(photo|video) (.+?)\]/) do |capture|
    	# 	# TODO: use the capture groups
    	# 	model, *args = capture.gsub('[', '').gsub(']', '').strip.squeeze(' ').split(' ') # ugz
    	# 	args = args.inject({model: model}){|obj, item|
    	# 		k, v = item.split('=')
    	# 		obj[k.to_sym] = v
    	# 		obj
    	# 	}
    	# 	begin
    	# 		model.singularize.classify.constantize
    	# 			 .find(args[:id].to_i)
    	# 			 .render_partial(args)
    	# 	rescue
     #            puts $!
    	# 		"<!-- #{$!} -->"
    	# 	end
    	# end
    end
end