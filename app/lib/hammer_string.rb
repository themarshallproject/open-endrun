class HammerString
	def self.coerce(dirty)
		dirty.to_s.force_encoding("UTF-8").encode("UTF-8", invalid: :replace, replace: "")
  end
end
