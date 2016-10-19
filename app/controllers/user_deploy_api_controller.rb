class UserDeployApiController < ApplicationController

  skip_before_action :verify_authenticity_token

  before_filter do
  	raise "No API Key." if params[:api_key].nil?
  		
  	@user = User.where(deploy_api_key: api_key).first
  	if @user.present?
  		logger.info "allowing API request for user #{@user.inspect}"
  	else
  		logger.info "invalid user, #{params.inspect}"
  		raise "Invalid API token."
  	end

  end

  def index
  	render json: Post.all.to_json
  end

  def create
  	render json: Post.create(status: 'draft')
  end

  def update
  	post = Post.find(params[:id])
  	post.content = params[:content]
  	post.status = 'draft'
  	render json: {
  		saved: post.save,
  		post: post
  	}
  end

end
