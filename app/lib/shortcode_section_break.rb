class ShortcodeSectionBreak
  def self.regex
    /\[section-break\](.*?)\[\/section-break\]/m
  end
  def self.parse(full_text, post_id)
    full_text.gsub(self.regex) do |capture|
        "<div class='shortcode-section-break'>#{$1}</div>"
    end
  end
end
