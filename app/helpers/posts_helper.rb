module PostsHelper

	def self.social_hash_id
		chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
		hash = (1..9).map{ 
			chars[SecureRandom.random_number(chars.length)]
		}.join('')
		"#." + hash
	end
end
