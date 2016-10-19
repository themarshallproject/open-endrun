class RatingsController < ApplicationController
    before_action :verify_current_user_present
    
	def create_or_update
		resource = record_from_params(params)
		rating = Rating.where(resource: resouce, user: current_user).first_or_initialize
		rating.rating = params[:rating].to_i
		rating.touch
		if rating.save
			render text: "OK"
		else
			render text: "FAIL", status: 500
		end
	end

	private

		def record_from_params(params)
			params[:model_type].singularize.classify.constantize.find(params[:model_id].to_i)   
		end		

end