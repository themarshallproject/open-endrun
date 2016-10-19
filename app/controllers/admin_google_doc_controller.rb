require 'google/api_client'

class AdminGoogleDocController < ApplicationController

	before_action :verify_current_user_present

	def api_client
		client = Google::APIClient.new(application_name: "EndRun", application_version: "0.1.0")
		client.authorization.client_id     = ENV["GOOGLE_API_CLIENT_ID"]
		client.authorization.client_secret = ENV["GOOGLE_API_CLIENT_SECRET"]
		client.authorization.redirect_uri  = ENV["GOOGLE_API_REDIRECT_URI"]
		client.authorization.scope         = 'https://www.googleapis.com/auth/drive'
		return client
	end

	def redirect_to_login
		cookies.delete(:google_oauth_token)
		redirect_to api_client.authorization.authorization_uri.to_s
	end

	def extract_id_from_url
		url = params[:url]
		id = /\/d\/(.+)\//.match(url)[1]
		redirect_to admin_parse_doc_path(id)
	end

	def extract_id_from_url_v2
		url = params[:url]
		id = /\/d\/(.+)\//.match(url)[1]
		redirect_to admin_parse_doc_v2_path(id)
	end

	def oauth_callback
		response = JSON.parse(HTTParty.post("https://accounts.google.com/o/oauth2/token", body: {
			code: params[:code],
			client_id: ENV["GOOGLE_API_CLIENT_ID"],
			client_secret: ENV["GOOGLE_API_CLIENT_SECRET"],
			redirect_uri: ENV["GOOGLE_API_REDIRECT_URI"],
			grant_type: 'authorization_code'
		}).body)

		cookies.signed[:google_oauth_token] = {
			httponly: true,
			expires: 30.minutes.from_now,
			value: CookieVault.encrypt(JSON.generate(response.merge(generated_at: Time.now.utc.to_i)))
		}

		if session[:return_to_doc].present?
			redirect_to(session.delete(:return_to_doc))
		else
			redirect_to admin_all_google_docs_path
		end
	rescue
		render plain: $!.inspect, status: 500
	end

	def unset_token
		cookies.delete(:google_oauth_token)
		redirect_to admin_path
	end

	def all_spreadsheets
		unless cookies.signed[:google_oauth_token].present?
			logger.info "all_google_docs redirecting to oauth"
			cookies.delete(:google_oauth_token)
			redirect_to api_client.authorization.authorization_uri.to_s and return false
		end

		access_token = JSON.parse(CookieVault.decrypt(cookies.signed[:google_oauth_token]))['access_token']
		@response = JSON.parse HTTParty.get("https://www.googleapis.com/drive/v2/files",
			query: {
				#
			}, headers: {
				"Authorization" => "Bearer #{access_token}"
			}
		).body

		@files = @response['items'].select{|file|
			file['mimeType'].include?('spreadsheet')
		}

	end

	def all_google_docs

		unless cookies.signed[:google_oauth_token].present?
			logger.info "all_google_docs redirecting to oauth"
			cookies.delete(:google_oauth_token)
			redirect_to api_client.authorization.authorization_uri.to_s and return false
		end

		access_token = get_access_token(cookies)
		@response = JSON.parse(HTTParty.get(
			"https://www.googleapis.com/drive/v2/files",
			headers: {"Authorization" => "Bearer #{access_token}"}
		).body)

		@files = @response['items'].select{|file|
			file['mimeType'] == 'application/vnd.google-apps.document'
		}
	rescue
		cookies.delete(:google_oauth_token)
		redirect_to api_client.authorization.authorization_uri.to_s
	end

	def get_access_token(cookies)
		JSON.parse(CookieVault.decrypt(cookies.signed[:google_oauth_token]))['access_token'] rescue nil
	end

	def parse_doc
		access_token = get_access_token(cookies)

		if access_token.nil?
			session[:return_to_doc] = request.path
			cookies.delete(:google_oauth_token)
			redirect_to api_client.authorization.authorization_uri.to_s and return false
		end

		@html = MarkdownGoogleDoc.download(access_token: access_token, id: params[:id])
		@doc  = MarkdownGoogleDoc.parse(@html)
	end

	def parse_doc_v2
		access_token = get_access_token(cookies)

		if access_token.nil?
			session[:return_to_doc] = request.path
			cookies.delete(:google_oauth_token)
			redirect_to api_client.authorization.authorization_uri.to_s and return false
		end

		@html = MarkdownGoogleDoc.download(access_token: access_token, id: params[:id])

		converter = GoogledocMarkdown::Converter.new(html: @html)
		render plain: converter.to_markdown

	end

	def get_file_by_id(id)
		access_token = get_access_token(cookies)
		JSON.parse(HTTParty.get(
			"https://www.googleapis.com/drive/v2/files/#{id}",
			headers: { "Authorization" => "Bearer #{access_token}"}
		).body)
	end

	def get_download_for_file(gdoc_response, mimeType)
		access_token = get_access_token(cookies)
		HTTParty.get(gdoc_response['exportLinks'][mimeType],
			headers: { "Authorization" => "Bearer #{access_token}"}
		).body
	end

	def parse_spreadsheet
		access_token = JSON.parse(CookieVault.decrypt(cookies.signed[:google_oauth_token]))['access_token'] rescue nil

		if access_token.nil?
			session[:return_to_doc] = request.path
			cookies.delete(:google_oauth_token)
			redirect_to api_client.authorization.authorization_uri.to_s and return false
		end

		file = get_file_by_id(params[:id])
		csv = get_download_for_file(file, 'text/csv').force_encoding('UTF-8')

		data = []
		CSV.parse(csv, headers: true) do |row|
			data << row.to_hash.map do |key, value|
				%Q{
					<b>#{key}</b><br>
					#{value}<br>
					<br>
				}
			end.join("\n")
		end

		@html = data.join("<br><hr><br>")
	end

end
