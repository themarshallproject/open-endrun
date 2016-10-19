class LinksController < ApplicationController
  before_action :set_link, only: [:show, :edit, :update, :destroy]
  before_action :verify_current_user_present, only: [:index, :show, :bookmarklet_link, :approve, :reject, :update, :destroy]

  before_filter      :allow_iframe_requests,     only: [:edit_link_in_iframe, :iframe_update]
  skip_before_filter :verify_authenticity_token, only: [:bookmarklet_app]

  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end
  
  # GET /links
  # GET /links.json
  def index    
    @number_per_page = 30 # also used to compute cache for link index...
    Skylight.instrument title: "LinksController#index @links query" do
      @links = Link.order('created_at DESC').first(@number_per_page)
    end
    #@active_newsletters = Newsletter.all # todo: active only!
  end

  def partials_before
    time = Time.at(params['created_at'].to_i)
    @links = Link.order('created_at DESC').where('created_at < ?', time).first(15)
    render layout: false
  end

  # GET /links/1
  # GET /links/1.json
  def show
  end

  # GET /links/new
  def new
    @link = Link.new
  end

  def bookmarklet_app
    render js: render_to_string('bookmarklet_app.js.erb', layout: false)
  end

  def bookmarklet_link
    if current_user.nil?
      redirect_to '/login'
    end
  end

  def edit_link_in_iframe
    if current_user.nil?
      render text: "<h2>You have to log into EndRun first.</h2>" and return false
    end
    @disable_nav = true
    @link = Link.where(url: params[:url]).first_or_initialize
    @link.title   ||= params[:title]
    @link.domain  ||= params[:domain]
    puts "edit_link_in_iframe link: #{@link.inspect}"
    render 'edit_link_in_iframe'
  end

  def approve
    link = Link.find(params[:id])
    link.approved = true
    link.save
    render partial: 'links/link', locals: { link: link }, layout: false
  end

  def reject
    link = Link.find(params[:id])
    link.approved = false
    link.save
    render partial: 'links/link', locals: { link: link }, layout: false
  end

  # GET /links/1/edit
  def edit
  end

  # POST /links
  # POST /links.json
  def create
    @link = Link.new(link_params)
    @link.creator  ||= current_user
    @link.domain ||= 'UNKNOWN'

    respond_to do |format|
      if @link.save
        format.html { redirect_to @link, notice: 'Link was successfully created.' }  
        format.json { render :show, status: :created, location: @link }
      else
        format.html { render :new }
        format.json { render json: @link.errors, status: :unprocessable_entity }  
      end
    end
  end

  def iframe_update
   
    if current_user.nil?
      render text: 'Not logged in.', status: 403
    end

    link = Link.where(url: params[:url]).first_or_initialize do |link|
      puts "first_or_initialize block for #{link.inspect}"
    end
    link.title    = params[:title]
    link.domain   = params[:domain]
    link.creator  ||= current_user
    link.content  = params[:content]
    link.approved = params[:approved]
    link.approved = true if link.approved.nil?

    logger.info "iframe_update about to save with #{link.inspect}"

    if link.save
      #logger.info "save worked"
      render text: 'OK'
    else
      #logger.info "save failed"
      render text: 'ERROR!', status: 500
    end
  end

  def download_html_v1
    link = Link.find(params[:link_id])
    link.download
    render text: "Download started."
  end

  # PATCH/PUT /links/1
  # PATCH/PUT /links/1.json
  def update
    respond_to do |format|
      if @link.update(link_params)
          format.html { redirect_to @link, notice: 'Link was successfully updated.' }
          format.json { render :show, status: :ok, location: @link }
      else
          format.html { render :edit } 
          format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /links/1
  # DELETE /links/1.json
  def destroy
    @link.destroy
    respond_to do |format|
      format.html { redirect_to links_url, notice: 'Link was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_link
      @link = Link.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def link_params
      params.require(:link).permit(:url, :title, :creator_id, :domain, :content)
    end
end
