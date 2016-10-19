class ProjectReposController < ApplicationController
  before_action :verify_current_user_present

  def index
  	@repos = ProjectRepo.new.all
  	render json: {
  		repos: @repos['values'].map do |repo|
  			{
  				name: repo['name']
  			}
  		end
  	}

  end

  def show
  	@repo = ProjectRepo.new(slug: params[:slug])
  	render json: @repo
  end

end
