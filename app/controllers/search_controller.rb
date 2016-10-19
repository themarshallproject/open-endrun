class SearchController < ApplicationController
  before_action :verify_current_user_present
  def search
  	@posts = Post.where("title @@ :q or content @@ :q", q: params[:q])
  	@links = Link.where("title @@ :q or    html @@ :q", q: params[:q])
  end
end
