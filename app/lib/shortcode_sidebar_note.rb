class ShortcodeSidebarNote
  def self.regex
    /\[sidebar-note\](.*?)\[\/sidebar-note\]/
  end
  def self.parse(full_text, post_id)
    full_text.gsub(self.regex) do |capture|
      [ '<div class="shortcode-sidebar-note-shim">',
        '<div class="shortcode-sidebar-note-inner">',
        $1,
        '</div>',
        '</div>',
      ].join('')
    end
  end
end
