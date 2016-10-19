class AssetFilesController < ApplicationController
  before_action :verify_current_user_present
  before_action :set_asset_file, only: [:show, :edit, :update, :destroy]

  # GET /asset_files
  # GET /asset_files.json
  def index
    @asset_files = AssetFile.all
  end

  # GET /asset_files/1
  # GET /asset_files/1.json
  def show
  end

  # GET /asset_files/new
  def new
    @asset_file = AssetFile.new
  end

  # GET /asset_files/1/edit
  def edit
  end

  # POST /asset_files
  # POST /asset_files.json
  def create
    @asset_file = AssetFile.new(asset_file_params)

    respond_to do |format|
      if @asset_file.save
        format.html { redirect_to @asset_file, notice: 'Asset file was successfully created.' }
        format.json { render :show, status: :created, location: @asset_file }
      else
        format.html { render :new }
        format.json { render json: @asset_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /asset_files/1
  # PATCH/PUT /asset_files/1.json
  def update
    respond_to do |format|
      if @asset_file.update(asset_file_params)
        format.html { redirect_to @asset_file, notice: 'Asset file was successfully updated.' }
        format.json { render :show, status: :ok, location: @asset_file }
      else
        format.html { render :edit }
        format.json { render json: @asset_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /asset_files/1
  # DELETE /asset_files/1.json
  def destroy
    @asset_file.destroy
    respond_to do |format|
      format.html { redirect_to asset_files_url, notice: 'Asset file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_asset_file
      @asset_file = AssetFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def asset_file_params
      params.require(:asset_file).permit(:asset_id, :s3_bucket, :s3_key)
    end
end
