class CookieVault
	def self.crypt
		key = ActiveSupport::KeyGenerator.new(ENV['COOKIE_VAULT_PASSWORD']).generate_key(ENV['COOKIE_VAULT_SALT'])
		ActiveSupport::MessageEncryptor.new(key)
	end

	def self.encrypt(text)	
		self.crypt.encrypt_and_sign(text)
	end

	def self.decrypt(text)
		self.crypt.decrypt_and_verify(text)  
	end
end