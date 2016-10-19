class ShortcodeAnnotation

  # uses '.post-anno-2' SCSS

  def self.extract_attrs(str)
    str.split(' ').inject({}) do |obj, item|
      k, v = item.split('=')
      obj[k.to_sym] = v
      obj
    end
  end

  def self.selector_regex
    /\[anno-selector(.*?)\]([\s\S]*?)\[\/anno-selector\]/m
  end
  def self.body_regex
    /\[anno-body(.*?)\]([\s\S]*?)\[\/anno-body\]/m
  end

	def self.parse(full_text)
		selector_regex = /\[anno-selector(.*?)\]([\s\S]*?)\[\/anno-selector\]/m
    body_regex     =     /\[anno-body(.*?)\]([\s\S]*?)\[\/anno-body\]/m

    full_text.gsub!(selector_regex) do |capture|
        attrs = self.extract_attrs($1)
        inner_html = $2
        [ "<span class='post-annotation-2-selector' data-index=\"#{attrs[:i]}\">", 
            inner_html, 
            "<sup>", 
              attrs[:i],
            "</sup>", 
          "</span>"].join("")    
    end

		full_text.gsub!(body_regex) do |capture|
  			attrs = self.extract_attrs($1)
  			inner_html = $2
        [ "\n<aside class='post-annotation-2-body' data-index=\"#{attrs[:i]}\">", 
            "<div class='body-inner'>",
              "<div class='header'>",
                "<span class='title'></span>",
                "<sup>", attrs[:i], "</sup>",
              "</div>",
              "<div class='content'>",
                inner_html, 
              "</div>",
            "</div>",
          "</aside>\n"].join("\n")		
  	end 

    full_text

	end

end