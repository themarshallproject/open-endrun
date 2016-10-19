# Store an encrypted version of the .p12 private key Google provides in the repo.
# Decrypt the key when needed. Decryption keys are stored in environment variables.
# (We're deployed on Heroku, so each web dyno cycles every day or so, thus the decrypted key is flushed that often too.)

require 'google/api_client'

class GoogleAnalytics

	# Based on https://raw.githubusercontent.com/google/google-api-ruby-client-samples/1480725b07e7048bc5dc7048606a016c5a8378a7/service_account/analytics.rb
	# NOTE: You need to add the email address generated to the GA acct: http://stackoverflow.com/a/20961008

	def decrypted_private_key_path
		File.join(Rails.root, "keys", "google_analytics.p12")
	end

	def message_encryptor
		ActiveSupport::MessageEncryptor.new(
			ActiveSupport::KeyGenerator.new(ENV['GOOGLE_ANALYTICS_P12_PASSWORD']).generate_key(ENV['GOOGLE_ANALYTICS_P12_SALT'])
		)
	end

	def decrypt_key
		decrypted_private_key = message_encryptor.decrypt_and_verify(
			File.read(File.join(Rails.root, "keys", "google_analytics.encrypted"))
		)  
		File.open(decrypted_private_key_path(), "wb") do |f|
			f.write(decrypted_private_key)			
		end
		puts "GoogleAnalytics wrote decrypted private key to .p12 file."
	end

	def initialize
		unless File.exists?(decrypted_private_key_path())			
			decrypt_key()
		end
	end

	def build_client

		cached_api_file = File.join(Rails.root, "tmp", "analytics-v3.cache")
		
		client = Google::APIClient.new(
			:application_name => 'EndRun Analytics',
			:application_version => '1.0.0'
		)

		# Load our credentials for the service account
		private_key = Google::APIClient::KeyUtils.load_from_pkcs12(decrypted_private_key_path(), 'notasecret')
		client.authorization = Signet::OAuth2::Client.new(
			:token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
			:audience => 'https://accounts.google.com/o/oauth2/token',
			:scope => 'https://www.googleapis.com/auth/analytics.readonly',
			:issuer => ENV['GOOGLE_ANALYTICS_EMAIL'],
			:signing_key => private_key
		)

		# Request a token for our service account
		client.authorization.fetch_access_token!

		# puts "GoogleAnalytics: #{client.inspect}"

		analytics = nil
		# Load cached discovered API, if it exists. This prevents retrieving the
		# discovery document on every run, saving a round-trip to the discovery service.
		if File.exists?(cached_api_file)
			puts "GoogleAnalytics analytics-v3.cache exists, loading from file...."
			File.open(cached_api_file) do |file|
				analytics = Marshal.load(file)
			end
		else
			analytics = client.discovered_api('analytics', 'v3')
			puts "GoogleAnalytics fetching analytics-v3.cache, not found locally"
			File.open(cached_api_file, 'w') do |file|
				Marshal.dump(analytics, file)
			end
		end

		@client = client
		@analytics = analytics
	end

	def query(parameters)
		if @client.nil? or @analytics.nil?
			build_client()
		end

		JSON.parse(@client.execute(
			api_method: @analytics.data.ga.get, 
			parameters: parameters
		).body)
	end

end