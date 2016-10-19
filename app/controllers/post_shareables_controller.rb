class PostShareablesController < ApplicationController
  before_action :set_post_shareable, only: [:show, :edit, :update, :destroy]

  # GET /post_shareables
  # GET /post_shareables.json
  def index
    if params[:post_id].present?
      @post_shareables = PostShareable.where(post: Post.find(params[:post_id])).all
    else
      @post_shareables = PostShareable.all
    end
  end

  # GET /post_shareables/1
  # GET /post_shareables/1.json
  def show
  end

  # GET /post_shareables/new
  def new
    @post_shareable = PostShareable.new(post_id: params[:post_id])
  end

  # GET /post_shareables/1/edit
  def edit
  end

  # POST /post_shareables
  # POST /post_shareables.json
  def create
    @post_shareable = PostShareable.new(post_shareable_params)

    respond_to do |format|
      if @post_shareable.save
        format.html {           
            redirect_to edit_post_path @post_shareable.post, notice: 'Post shareable was successfully created.'           
        }
        format.json { render :show, status: :created, location: @post_shareable }
      else
        format.html { render :new }
        format.json { render json: @post_shareable.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /post_shareables/1
  # PATCH/PUT /post_shareables/1.json
  def update
    respond_to do |format|
      if @post_shareable.update(post_shareable_params)
        format.html { redirect_to @post_shareable, notice: 'Post shareable was successfully updated.' }
        format.json { render :show, status: :ok, location: @post_shareable }
      else
        format.html { render :edit }
        format.json { render json: @post_shareable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /post_shareables/1
  # DELETE /post_shareables/1.json
  def destroy
    @post_shareable.destroy
    respond_to do |format|
      format.html { redirect_to post_shareables_url, notice: 'Post sharable was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post_shareable
      @post_shareable = PostShareable.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_shareable_params
      params.require(:post_shareable).permit(:post_id, :slug, :photo_id, :facebook_headline, :facebook_description, :twitter_headline)
    end
end
