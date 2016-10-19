Dotenv.load if Rails.env.development?
	
class ProjectRepo

	include HTTParty

	def all
		self.class.get("#{base_url}/repositories/#{organization}?sort=utc_last_updated", basic_auth: auth)
	end

	def initialize(slug: nil)
		@slug = slug
		if @slug.present?
			@repo = self.class.get("#{base_url}/repositories/#{organization}/#{slug}", basic_auth: auth)
		end
	end


	def branches(slug)
		self.class.get("#{base_url}/repositories/#{organization}/#{@slug}/branches", basic_auth: auth)
	end

	private

		def base_url
			"https://api.bitbucket.org/2.0"
		end

		def organization
			ENV['BITBUCKET_ORGANIZATION']
		end

		def auth
			{ 
				username: ENV['BITBUCKET_USERNAME'], 
			 	password: ENV['BITBUCKET_PASSWORD']
			}
		end

end