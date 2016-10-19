class PostShareableMaybe
	def self.override(shareable, post, col)
		if shareable.present? and shareable.respond_to?(col) and shareable.send(col).present?
			shareable.send(col)
		else
			post.send(col)
		end
	end
end