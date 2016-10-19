module ShortcodePhoto
  def self.markdown(content)
    content ||= ""
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(content).html_safe
  end
  def self.regex
    /\[photo (.+?)\]/
  end
  def self.parse(html, post_id)
    	html = html.gsub(self.regex) do |capture|    		
            array_args = $1.squeeze(' ').split(' ')
    		args = array_args.inject({}) { |obj, item|
    			k, v = item.split('=')
    			obj[k.to_sym] = v
    			obj
    		}
            
            if args.keys.include?(:type) and args.keys.include?(:id)

                extra_classes = []
                if args.keys.include?(:remove_margin_top)
                    extra_classes << 'remove-margin-top'
                end
                if args.keys.include?(:remove_margin_bottom)
                    extra_classes << 'remove-margin-bottom'
                end

                shim_extra_classes = extra_classes.map{|c| "photo-shim-#{c}" }.join(" ")
                main_extra_classes = extra_classes.map{|c| "photo-#{c}" }.join(" ")

                photo = Photo.find(args[:id]) rescue nil
                # PostEmbed.mark_embedded(post_id: post_id, embed: photo)

                if photo.present?
                    src = photo.url_for(size: '1140x')
                    %Q{                
                    <div class="photo photo-#{args[:type]}-shim #{shim_extra_classes}" data-photo-config='#{args.to_json}'>
                    <div class="photo photo-#{args[:type]} #{main_extra_classes}" data-photo-id="#{args[:id]}">
                        <img data-src="#{src}" onload='window.recordImageLoad(this);'>
                        <div class="meta">
                        <span class="caption">#{self.markdown(photo.caption)}</span>
                        <span class="byline">#{photo.byline}</span>
                        </div>
                    </div>
                    </div>
                    }
                else
                    "<span class='shortcode-photo-error' style='display:none;'>error finding photo for #{array_args}</span>"
                end
            else
                "<span class='shortcode-photo-error' style='display:none;'>#{array_args} is invalid</span>"
            end            
    	end
    end
    def self.render_template
        "temp #{args.to_json}"
    end
end