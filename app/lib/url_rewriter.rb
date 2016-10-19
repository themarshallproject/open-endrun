class URLRewriter
	attr_reader :url, :allowed_host

	def initialize(url: nil, allowed_host: "www.themarshallproject.org")
		@allowed_host = allowed_host
		@url = url
		self
	end

	def parseable?
		URI.parse(url).host.present?
	rescue
		false
	end

	def rewrite(params: nil, optional_hash: nil)
		if !parseable?
			return url
		end

		parsed_uri = URI.parse(url)
		if parsed_uri.host != allowed_host
			return @url
		end

		if parsed_uri.fragment.blank?
			parsed_uri.fragment = optional_hash
		end

		parsed_uri.query = URI.encode_www_form(params)
		return parsed_uri.to_s
	end
end