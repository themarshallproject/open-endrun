class EmbedController < ApplicationController
	after_action :allow_iframe

	def v1_email
		render layout: false
	end

	private

		def allow_iframe
			# https://stackoverflow.com/questions/18445782/how-to-override-x-frame-options-for-a-controller-or-action-in-rails-4
			response.headers.except!('X-Frame-Options')
		end
end