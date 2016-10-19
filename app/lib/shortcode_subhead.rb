class ShortcodeSubhead
  def self.regex
  	/(\[subhead\])([\s\S]*?)(\[\/subhead\])/
  end
  def self.parse(full_text)
    full_text.gsub(self.regex) do |capture|
      inner_html = $2
      ["\n<span class=\"shortcode-subhead\">", inner_html, "</span>\n"].join("")
    end
  end
end
