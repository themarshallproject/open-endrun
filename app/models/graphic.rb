class Graphic < ActiveRecord::Base
	
	after_create :rotate_deploy_token

	def rotate_deploy_token
		self.deploy_token = SecureRandom.hex
		self.save!
	end

	def to_param
		"#{id}-#{slug.parameterize}"
	end

end