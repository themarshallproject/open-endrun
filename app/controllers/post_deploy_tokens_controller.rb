class PostDeployTokensController < ApplicationController
  before_action :verify_current_user_present, except: [:api_v1_update]
  skip_before_filter :verify_authenticity_token, only: [:api_v1_update]
  before_action :set_post_deploy_token, only: [:show, :edit, :update, :destroy]

  def api_v1_update
    error, message = PostDeployToken.update_post(params)
    render json: {
      error: error,
      message: message
    }
  end

  # GET /post_deploy_tokens
  # GET /post_deploy_tokens.json
  def index
    @post_deploy_tokens = PostDeployToken.all
  end

  # GET /post_deploy_tokens/1
  # GET /post_deploy_tokens/1.json
  def show
  end

  # GET /post_deploy_tokens/new
  def new
    @post_deploy_token = PostDeployToken.new
  end

  # GET /post_deploy_tokens/1/edit
  def edit
  end

  # POST /post_deploy_tokens
  # POST /post_deploy_tokens.json
  def create
    @post_deploy_token = PostDeployToken.new(post_deploy_token_params)

    respond_to do |format|
      if @post_deploy_token.save
        format.html { redirect_to @post_deploy_token, notice: 'Post deploy token was successfully created.' }
        format.json { render :show, status: :created, location: @post_deploy_token }
      else
        format.html { render :new }
        format.json { render json: @post_deploy_token.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /post_deploy_tokens/1
  # PATCH/PUT /post_deploy_tokens/1.json
  def update
    respond_to do |format|
      if @post_deploy_token.update(post_deploy_token_params)
        format.html { redirect_to @post_deploy_token, notice: 'Post deploy token was successfully updated.' }
        format.json { render :show, status: :ok, location: @post_deploy_token }
      else
        format.html { render :edit }
        format.json { render json: @post_deploy_token.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /post_deploy_tokens/1
  # DELETE /post_deploy_tokens/1.json
  def destroy
    @post_deploy_token.destroy
    respond_to do |format|
      format.html { redirect_to post_deploy_tokens_url, notice: 'Post deploy token was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post_deploy_token
      @post_deploy_token = PostDeployToken.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_deploy_token_params
      params.require(:post_deploy_token).permit(:post_id, :label, :token, :active)
    end
end
