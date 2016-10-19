class FreeformStreamPromosController < ApplicationController
  before_action :set_freeform_stream_promo, only: [:show, :edit, :update, :destroy, :preview]

  # GET /freeform_stream_promos
  # GET /freeform_stream_promos.json
  def index
    @freeform_stream_promos = FreeformStreamPromo.all
  end

  # GET /freeform_stream_promos/1
  # GET /freeform_stream_promos/1.json
  def show
  end

  # GET /freeform_stream_promos/new
  def new
    @freeform_stream_promo = FreeformStreamPromo.new
  end

  # GET /freeform_stream_promos/1/edit
  def edit
  end

  def preview
    render layout: 'public'
  end

  # POST /freeform_stream_promos
  # POST /freeform_stream_promos.json
  def create
    @freeform_stream_promo = FreeformStreamPromo.new(freeform_stream_promo_params)

    respond_to do |format|
      if @freeform_stream_promo.save
        format.html { redirect_to @freeform_stream_promo, notice: 'Freeform stream promo was successfully created.' }
        format.json { render :show, status: :created, location: @freeform_stream_promo }
      else
        format.html { render :new }
        format.json { render json: @freeform_stream_promo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /freeform_stream_promos/1
  # PATCH/PUT /freeform_stream_promos/1.json
  def update
    respond_to do |format|
      if @freeform_stream_promo.update(freeform_stream_promo_params)
        format.html { redirect_to @freeform_stream_promo, notice: 'Freeform stream promo was successfully updated.' }
        format.json { render :show, status: :ok, location: @freeform_stream_promo }
      else
        format.html { render :edit }
        format.json { render json: @freeform_stream_promo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /freeform_stream_promos/1
  # DELETE /freeform_stream_promos/1.json
  def destroy
    @freeform_stream_promo.destroy
    respond_to do |format|
      format.html { redirect_to freeform_stream_promos_url, notice: 'Freeform stream promo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_freeform_stream_promo
      @freeform_stream_promo = FreeformStreamPromo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def freeform_stream_promo_params
      params.require(:freeform_stream_promo).permit(:slug, :html, :revised_at, :published, :deploy_token)
    end
end
