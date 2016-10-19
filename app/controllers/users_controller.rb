class UsersController < ApplicationController

	before_action :verify_current_user_present

	def index
		@users = User.all.sort_by{|user|
			user.name.split(' ').last rescue 'Z'
		}
	end

	def edit
		@user = User.find(params[:id])
	end

	# PATCH/PUT /posts/1
	# PATCH/PUT /posts/1.json
	def update
		@user = User.find(params[:id])
		respond_to do |format|
			if @user.update(user_params)
				format.html { redirect_to users_path, notice: 'User was successfully updated.' }
				format.json { render :show, status: :ok, location: users_path }
			else
				format.html { render :edit }
				format.json { render json: @user.errors, status: :unprocessable_entity }
			end
		end
	end

	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params)
		if @user.save
			redirect_to root_url, notice: "Thank you for signing up!"
		else
			render "new"
		end
	end
	
	def forgot_password
		# TODO
	end

	def email_login_token
		
	end

	private
		def user_params
			params.require(:user).permit(:slug, :name, :title, :public_key, :email, :phone, :twitter, :bio, :password, :password_confirmation)
		end
end