class PostsController < ApplicationController
  before_action :verify_current_user_present
  before_action :set_post, only: [:edit, :update, :destroy]

  def updated_at
    render json: Post.find_by(id: params[:id]).try(:updated_at).try(:to_i)
  end

  def content_hash
    post = Post.find_by(id: params[:id])
    if post.nil?
      render json: nil and return
    end

    sample = [:title, :deck, :content, :inject_html, :custom_scss].map do |key|
      post.send(key).to_s
    end.join('')
    digest = Digest::SHA256.hexdigest("v1" + sample)

    render json: {sha256: digest}
  end

  def date_slugged
    @post = Post.by_year(params[:year]).slugged(params[:id])
    render 'show'
  end

  # GET /posts
  # GET /posts.json
  def index
    redirect_to '/admin/posts'
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    post = Post.find_by(id: params[:id])
    redirect_to admin_preview_post_path(post)
  end

  def destroy_user_post_assignment
    assignment = UserPostAssignment.find(params[:id])
    if assignment.destroy
      render plain: "ok"
    else
      render plain: "fail", status: 422
    end
  end

  def preview

    if params.keys.include?('edit')
      redirect_to edit_post_path(params[:id]) and return false
    end

    if params.keys.include?('epic')
      redirect_to edit_post_path(params[:id])+'?advanced' and return false
    end

    @post = Post.find_by(id: params[:id]) # will be nil instead of an exception if it's not found

    if @post.nil?
      # if we got a weird param, 404 it
      render text: "Not Found", status: 404
      return false
    end

    if @post.published?
      # if the post is published, redirect to the live version
      redirect_to @post.path
      return false
    end

    # render
    @stream = Stream.new
    render layout: 'public'
  end

  def preview_promo
    @post = Post.find(params[:id])
    render layout: 'public'
  end

  def as_json
    @post = Post.find(params[:id])
    content = @post.content
    render json: content
  end

  # GET /posts/new
  def new
    @post = Post.new
    if params[:seed_v1_google_doc_id].present?
      access_token = JSON.parse(CookieVault.decrypt(cookies.signed[:google_oauth_token]))['access_token']
      html = MarkdownGoogleDoc.download(id: params[:seed_v1_google_doc_id], access_token: access_token)
      @post.content = MarkdownGoogleDoc.parse(html)
    end
  end

  # GET /posts/1/edit
  def edit
    PostLockSweeper.new.perform # sync!
    @post_lock = PostLock.acquire(user: current_user, post: @post)
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)
    save_result = @post.save

    # TODO: this should get cleaned up:
    if save_result == true
      @post.rubric  = post_params[:rubric]
      @post.authors = post_params[:authors]
      @post.save
    end

    respond_to do |format|
      if save_result
        format.html { redirect_to edit_post_path(@post), notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    @post_lock = PostLock.acquire(user: current_user, post: @post)

    respond_to do |format|
      if @post.update(post_params)
        format.html do
          if params[:post][:return_to_path].present?
            redirect_to params[:post][:return_to_path]
          else
            redirect_to edit_post_path, notice: 'Post was successfully updated.'
          end
        end
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end

    # PostLock.release_all(post: @post)
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :display_headline, :facebook_headline, :facebook_description, :twitter_headline, :inject_html, :featured_photo_id, :freeform_post_header, :lead_photo_id, :slug, :content, :byline_freeform, :deck, :rubric, :email_content, :post_format, :published_at, :revised_at, :status, :produced_by, :custom_scss, :stream_promo, :in_stream, :authors => [])
    end
end
