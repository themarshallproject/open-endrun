class EmailSignupController < ApplicationController
	before_action :verify_current_user_present, except: []

	def index
		@emails_added = []

		@email_signups = EmailSignup.order('created_at DESC').all.select do |record|
			if !@emails_added.include?(record.email) and record.email.include?('@')
				@emails_added << record.email
				true
			else
				false
			end
		end

		respond_to do |format|
	      format.html
	      format.csv { send_data @products.to_csv }
	      format.xls
	    end
	end
	
end