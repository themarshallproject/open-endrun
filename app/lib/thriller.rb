class Thriller
	include HTTParty
  	base_uri ENV['THRILLER_HOST']

	def token
		ENV['THRILLER_TOKEN']
	end
	
	def social_snapshot(urls)
		self.class.post(
			"/api/v1/report/social/snapshot",
			{   
				body: {
					token: token(),
					urls: urls
				}
			}
		)		
	end

end