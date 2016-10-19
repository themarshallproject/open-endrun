class YahooPostsController < ApplicationController
  before_action :set_yahoo_post, only: [:show, :edit, :update, :destroy]
  before_action :verify_current_user_present

  def send_webhook
    result = HTTParty.post(ENV['YAHOO_RSS_PUBSUB_URL'], body: {
      "hub.url"  => "https://www.themarshallproject.org/rss/yahoo.rss",
      "hub.mode" => "publish"
    })

    render text: JSON.pretty_generate({
      code: result.code,
      body: result.body,
    })
  end

  # GET /yahoo_posts
  # GET /yahoo_posts.json
  def index
    @yahoo_posts = YahooPost.all.order('created_at DESC')
  end

  # GET /yahoo_posts/1
  # GET /yahoo_posts/1.json
  def show
  end

  # GET /yahoo_posts/new
  def new
    @yahoo_post = YahooPost.new
  end

  # GET /yahoo_posts/1/edit
  def edit
  end

  # POST /yahoo_posts
  # POST /yahoo_posts.json
  def create
    @yahoo_post = YahooPost.new(yahoo_post_params)

    respond_to do |format|
      if @yahoo_post.save
        format.html { redirect_to yahoo_posts_url, notice: 'Yahoo post was successfully created.' }
        format.json { render :show, status: :created, location: @yahoo_post }
      else
        format.html { render :new }
        format.json { render json: @yahoo_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /yahoo_posts/1
  # PATCH/PUT /yahoo_posts/1.json
  def update
    respond_to do |format|
      if @yahoo_post.update(yahoo_post_params)
        format.html { redirect_to yahoo_posts_url, notice: 'Yahoo post was successfully updated.' }
        format.json { render :show, status: :ok, location: @yahoo_post }
      else
        format.html { render :edit }
        format.json { render json: @yahoo_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /yahoo_posts/1
  # DELETE /yahoo_posts/1.json
  def destroy
    @yahoo_post.destroy
    respond_to do |format|
      format.html { redirect_to yahoo_posts_url, notice: 'Yahoo post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_yahoo_post
      @yahoo_post = YahooPost.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def yahoo_post_params
      params.require(:yahoo_post).permit(:post_id, :title, :published, :lead_photo, :summary)
    end
end
