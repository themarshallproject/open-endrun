class WeedwackerController < ApplicationController
	before_action :verify_current_user_present

	def index
		@ga_today = CachedGoogleAnalyticsQuery.new.get('topline:v1:summary:today')
		@ga_yesterday = CachedGoogleAnalyticsQuery.new.get('topline:v1:summary:yesterday')
		@ga_alltime = CachedGoogleAnalyticsQuery.new.get('topline:v1:summary:alltime')		
	end

	def post
		post_id = params[:post_id].to_i
		result = CachedGoogleAnalyticsQuery.new.get("topline:v1:post:#{post_id}")	
		if result.nil?
			AnalyticsPostSummaryV1.perform_async(post_id)
		end
		render json: result
	end



end