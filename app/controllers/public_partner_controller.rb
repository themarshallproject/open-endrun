class PublicPartnerController < ApplicationController

	def check_pixel
		@start_time = Time.now.utc.to_f

		if request.post?
			@url = params[:url]
			puts "check_pixel for url:#{@url}"
		end

		if @url.present?
			@html = HTTParty.get(@url, timeout: 1.0) rescue "Invalid URL."
			@doc = Nokogiri::HTML(@html)
		end

		render layout: 'partner'
	end

	def outcome_tracker		
	end

end
