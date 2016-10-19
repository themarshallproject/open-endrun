class ExternalLink

	def initialize(url: '', signed_url: '', position: nil)
		@url = 	url
		@signed_url = signed_url
		@position = position
	end

	def key
		"key"
	end

	def blob
		JSON.generate({
			url: @url
		})
	end

	def hmac
		OpenSSL::HMAC.hexdigest(
			OpenSSL::Digest.new('sha1'),
			key(), 
			blob()
		)
	end	

	def signed_path
		{
			url: @url,
			hmac: hmac(),
			position: @position
		}.to_query
	end

	def verify_signed_path
		params = CGI.parse(@signed_url)
		candidate_hmac = params.slice("hmac")['hmac'].first
		{
			params: params.map{|k, v| [k, v.first] },
			candidate_hmac: candidate_hmac
		}
	end

end