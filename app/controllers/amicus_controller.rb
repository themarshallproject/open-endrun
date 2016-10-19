class AmicusController < ApplicationController
  before_action :verify_current_user_present

  def index  	
  	@posts = Post.order('revised_at DESC').all
  end

  def edit
  	# PostLockSweeper.new.perform

  	@post = Post.find(params[:id])

  	# @post_lock = PostLock.acquire(user: current_user, post: @post)
  end

  def update
  	@post = Post.find(params[:post][:id])


  	# post = Post.find(params[:post][:id])
  	# allowed_attributes = params[:post].except(:id, :status, :updated_at, :created_at)
  	# post.serialized_draft = allowed_attributes
  	# post.save

  	# redirect_to amicus_diff_path(post)
  end

  def sync
  	@post = Post.find(params[:post][:id])

  	attributes_to_update = params[:post].select{ |column_name, value|
		  Post.column_names.include?(column_name)
	  }
	@post.serialized_draft.merge!(attributes_to_update)
	@post.save
  end

  def preview_draft
  	@post = Post.find(params[:post_id]).mock_draft
	render layout: 'public'
  end

  def yaml_live
  	render plain: Post.find(params[:post_id]).live_yaml
  end

  def yaml_draft
  	render plain: Post.find(params[:post_id]).draft_yaml
  end

  def live_to_draft
	post = Post.find(params[:post_id])
	post.serialized_draft = post.attributes
	post.save
	redirect_to amicus_index_path
  end

  def diff
  	post = Post.find(params[:post_id])
  	render text: [
  		"<style>",
  		Diffy::CSS,
  		"</style>",
  		Diffy::Diff.new(post.draft_yaml, post.live_yaml).to_s(:html_simple)
  	].join("\n")
  end

  def api_post
    post = Post.find params[:id]
    render json: post.serialize.to_json
  end

end