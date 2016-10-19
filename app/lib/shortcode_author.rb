class ShortcodeAuthor
	include Rails.application.routes.url_helpers
	def call(text)
		regex = /\[author (.+?)\]/
		text ||= "The Marshall Project"
		text.gsub(regex) do |capture|
			user = User.where(slug: $1).first rescue nil
			if user.present?
				%Q{<span><a href="#{author_path(user.slug)}">#{user.name}</a></span>}
			else
				# changes ivar-vong to Ivar Vong
				name = $1.gsub('-', ' ').titleize # dirty hack TODO
				"<span>#{name}</span>".html_safe
			end
		end
	end
end