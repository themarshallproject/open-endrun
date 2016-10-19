module ShortcodeGraphic
  def self.regex
    /\[graphic(.*?)\]/m
  end
	def self.parse(full_text, post_id)
		full_text.gsub(self.regex) do |capture|
        args = ShortcodeArgumentParser.new($1).parse
        graphic = Graphic.find_by(id: args[:id])
  			
        PostEmbed.mark_embedded(post_id: post_id, embed: graphic)

        if graphic.present?
          graphic.html
        else
          "<!-- graphic inject failed :: id=#{args[:id]} -->"
        end
    end
	end

end