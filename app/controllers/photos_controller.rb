class PhotosController < ApplicationController
  before_action :verify_current_user_present
  before_action :set_photo, only: [:show, :edit, :update, :destroy]

  # GET /photos
  # GET /photos.json
  def index
    @page = (params[:page] || 0).to_i
    @show_agg = params[:show_agg] || [nil, false]
    @page_size = 25
    @total_pages = (Photo.where(via_gator: @show_agg).count/@page_size).to_i
    @photos = Photo.where(via_gator: @show_agg).order('updated_at DESC').offset(@page*@page_size).first(@page_size)
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
  end

  # GET /photos/new
  def new
    @photo = Photo.new
  end

  # GET /photos/1/edit
  def edit
  end

  # POST /photos
  # POST /photos.json
  def create
    @photo = Photo.new(photo_params)

    respond_to do |format|
      if @photo.save
        format.html { redirect_to @photo, notice: 'Photo was successfully created.' }
        format.json { render :show, status: :created, location: @photo }
      else
        format.html { render :new }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  def v1_picker
    @photos = Photo.order('updated_at DESC').first(30)
  end

  def signature(options = {})
    Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest::Digest.new('sha1'),
        @s3_secret_key,
        policy({ secret_access_key: @s3_secret_key })
      )
    ).gsub(/\n/, '')
  end

  def policy(options = {})
    obj = {
      expiration: '2030-01-01T01:00:00.000Z', #TODO: make this a fixed window. for when we have auth on this.
      conditions: [
        { bucket: @s3_bucket },
        { acl: "public-read" },
        ["starts-with", "$key", @s3_key],
        ["content-length-range", 1, 21474836480]
      ]
    }
    obj = obj.to_json
    Base64.encode64(obj).gsub(/\n|\r/, '')
  end

  def upload_form
    @s3_key        = "#{Time.now.strftime('%Y%m%d')}/"
    @s3_bucket     = ENV['S3_UPLOAD_BUCKET']
    @s3_access_key = ENV['S3_UPLOAD_ACCESS_KEY']
    @s3_secret_key = ENV['S3_UPLOAD_SECRET_KEY']
    @policy        = policy()
    @signature     = signature()
  end

  def upload_complete
    url = params[:url]
    photo = Photo.where(original_url: url).first_or_create
    render text: photo.id
  end

  # PATCH/PUT /photos/1
  # PATCH/PUT /photos/1.json
  def update
    respond_to do |format|
      if @photo.update(photo_params)
        format.html { redirect_to @photo, notice: 'Photo was successfully updated.' }
        format.json { render :show, status: :ok, location: @photo }
      else
        format.html { render :edit }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo.destroy
    respond_to do |format|
      format.html { redirect_to photos_url, notice: 'Photo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def photo_params
      params.require(:photo).permit(:original_url, :caption, :byline)
    end
end
