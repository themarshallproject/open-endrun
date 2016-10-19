class UserFeaturesController < ApplicationController
	before_action :verify_current_user_present
	def all
		@flags = FeatureFlag.all_per_user_flags
	end

	def enable
		flag_name, _ = FeatureFlag.all_per_user_flags.select{|flag, _| flag == params[:slug]}.first
		cookies.permanent["_uff_#{flag_name}"] = 't'
		redirect_to root_path
	end

	def disable
		flag_name, _ = FeatureFlag.all_per_user_flags.select{|flag, _| flag == params[:slug]}.first
		cookies.permanent["_uff_#{flag_name}"] = 'f'
		redirect_to root_path
	end
end
