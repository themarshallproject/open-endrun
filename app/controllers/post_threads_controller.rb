class PostThreadsController < ApplicationController
  before_action :verify_current_user_present
  before_action :set_post_thread, only: [:show, :edit, :update, :destroy]

  # GET /post_threads
  # GET /post_threads.json
  def index
    @post_threads = PostThread.all
  end

  # GET /post_threads/1
  # GET /post_threads/1.jsonf
  def show
  end

  # GET /post_threads/new
  def new
    @post_thread = PostThread.new
  end

  # GET /post_threads/1/edit
  def edit
  end

  def create_with_posts
    posts = params[:posts].map{|post_id| Post.find(post_id) }

    if posts.all?{|post| post.post_threads.empty? }
      # every post has no post_threads. so, make a thread, add posts to the thread
      post_thread = PostThread.create!
      posts.each do |post|
        post.post_threads << post_thread
        post.touch
      end
      redirect_to posts.first
    else
      render text: "not everything is empty... choose wisely"
    end

  end
  
  def attach_to_thread
    post = Post.find(params[:post_id])
    post_thread = PostThread.find(params[:thread_id])
    if post.post_threads.empty?
      post.post_threads << post_thread
      redirect_to edit_post_path(post)
    else
      redirect_to post, flash: 'Post is already in a thread.'
    end        
  end

  def remove_from_thread
    post = Post.find(params[:post_id])
    thread = PostThread.find(params[:thread_id])
    post.post_threads.delete(thread)
    redirect_to edit_post_path(post)
  end

  # POST /post_threads
  # POST /post_threads.json
  def create
    @post_thread = PostThread.new(post_thread_params)

    respond_to do |format|
      if @post_thread.save
        format.html { redirect_to @post_thread, notice: 'Post thread was successfully created.' }
        format.json { render :show, status: :created, location: @post_thread }
      else
        format.html { render :new }
        format.json { render json: @post_thread.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /post_threads/1
  # PATCH/PUT /post_threads/1.json
  def update
    respond_to do |format|
      if @post_thread.update(post_thread_params)
        format.html { redirect_to @post_thread, notice: 'Post thread was successfully updated.' }
        format.json { render :show, status: :ok, location: @post_thread }
      else
        format.html { render :edit }
        format.json { render json: @post_thread.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /post_threads/1
  # DELETE /post_threads/1.json
  def destroy
    @post_thread.destroy
    respond_to do |format|
      format.html { redirect_to post_threads_url, notice: 'Post thread was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post_thread
      @post_thread = PostThread.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_thread_params
      params.require(:post_thread).permit(:name)
    end
end
