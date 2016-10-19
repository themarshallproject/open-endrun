class User < ActiveRecord::Base
	has_secure_password  
	validates_uniqueness_of :email

	has_many :taggings

	has_many :user_post_assignments
	has_many :posts, through: :user_post_assignments

	def attributes
		{name: nil, email: nil, slug: nil}
	end

	def reset_login_token!
		self.login_token = SecureRandom.urlsafe_base64
		self.login_token_expires = 10.minutes.from_now		
		save!
	end

	def email_slug
		self.email.split("@").first
	end

	def login_with_token?(candidate_token)
		# check if we have a non-null token, it matches, and it's valid by expiring time
		if (self.login_token.length > 5) and (candidate_token == self.login_token) and (self.login_token_expires - Time.now  > 0)
			self.login_token = nil
			self.login_token_expires = nil
			save!
			return true
		else
			return false
		end
	end

	def reset_bookmarklet_token!
		self.bookmarklet_token = SecureRandom.urlsafe_base64		
	end

	def active?
		true 
	end
	
end
