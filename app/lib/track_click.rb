class TrackClick
	include Rails.application.routes.url_helpers

	def self.encode(payload={})		
		JWT.encode(payload, ENV['LINK_DECODE_HMAC_SECRET_V1'], 'HS256')
	end

	def self.decode(token)
		payload, _details = (JWT.decode(token, ENV['LINK_DECODE_HMAC_SECRET_V1']) rescue [nil, nil])
		payload
	end

	def self.encode_as_url(payload)
		token = self.encode(payload)
		Rails.application.routes.url_helpers.api_v2_decode_path(token: token)
	end

end