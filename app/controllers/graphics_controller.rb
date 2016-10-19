class GraphicsController < ApplicationController
  before_action :verify_current_user_present, except: [:api_v1_update]
  skip_before_action :verify_authenticity_token, only: [:api_v1_update]
  before_action :set_graphic, only: [:show, :edit, :update, :destroy, :rotate_deploy_token]

  def api_v1_update
    graphic = Graphic.find_by(deploy_token: params[:token])
    if graphic.nil?
      render json: { error: "Graphic Not Found" }, status: 404 and return false
    end

    graphic.html = params[:html]
    if graphic.save
      render json: { id: graphic.id }
    else
      render json: { error: "Error saving" }
    end
  end

  def rotate_deploy_token
    @graphic.rotate_deploy_token
    redirect_to graphics_path
  end

  # GET /graphics
  # GET /graphics.json
  def index
    @graphics = Graphic.order('created_at DESC').all
    @post_embeds = PostEmbed.graphics
  end

  # GET /graphics/1
  # GET /graphics/1.json
  def show
  end

  # GET /graphics/new
  def new
    @graphic = Graphic.new
  end

  # GET /graphics/1/edit
  def edit
  end

  # POST /graphics
  # POST /graphics.json
  def create
    @graphic = Graphic.new(graphic_params)

    respond_to do |format|
      if @graphic.save
        format.html { redirect_to edit_graphic_path(@graphic), notice: 'Graphic was successfully created.' }
        format.json { render :show, status: :created, location: @graphic }
      else
        format.html { render :new }
        format.json { render json: @graphic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /graphics/1
  # PATCH/PUT /graphics/1.json
  def update
    respond_to do |format|
      if @graphic.update(graphic_params)
        format.html { redirect_to edit_graphic_path(@graphic), notice: 'Graphic was successfully updated.' }
        format.json { render :show, status: :ok, location: @graphic }
      else
        format.html { render :edit }
        format.json { render json: @graphic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /graphics/1
  # DELETE /graphics/1.json
  def destroy
    @graphic.destroy
    respond_to do |format|
      format.html { redirect_to graphics_url, notice: 'Graphic was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_graphic
      @graphic = Graphic.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def graphic_params
      params.require(:graphic).permit(:slug, :html)
    end
end
