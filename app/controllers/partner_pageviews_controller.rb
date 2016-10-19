class PartnerPageviewsController < ApplicationController
  before_action :verify_current_user_present
  before_action :set_partner_pageview, only: [:show, :edit, :update, :destroy]

  # GET /partner_pageviews
  # GET /partner_pageviews.json
  def index
    @partner_pageviews = PartnerPageview.order('created_at DESC').all
  end

  # GET /partner_pageviews/1
  # GET /partner_pageviews/1.json
  def show
  end

  # GET /partner_pageviews/new
  def new
    @partner_pageview = PartnerPageview.new
    if params[:post_id].present?
      @partner_pageview.post = Post.find_by(id: params[:post_id])
    end
  end

  # GET /partner_pageviews/1/edit
  def edit
  end

  # POST /partner_pageviews
  # POST /partner_pageviews.json
  def create
    @partner_pageview = PartnerPageview.new(partner_pageview_params)

    respond_to do |format|
      if @partner_pageview.save
        format.html { redirect_to @partner_pageview, notice: 'Partner pageview was successfully created.' }
        format.json { render :show, status: :created, location: @partner_pageview }
      else
        format.html { render :new }
        format.json { render json: @partner_pageview.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /partner_pageviews/1
  # PATCH/PUT /partner_pageviews/1.json
  def update
    respond_to do |format|
      if @partner_pageview.update(partner_pageview_params)
        format.html { redirect_to @partner_pageview, notice: 'Partner pageview was successfully updated.' }
        format.json { render :show, status: :ok, location: @partner_pageview }
      else
        format.html { render :edit }
        format.json { render json: @partner_pageview.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /partner_pageviews/1
  # DELETE /partner_pageviews/1.json
  def destroy
    @partner_pageview.destroy
    respond_to do |format|
      format.html { redirect_to partner_pageviews_url, notice: 'Partner pageview was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_partner_pageview
      @partner_pageview = PartnerPageview.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def partner_pageview_params
      params.require(:partner_pageview).permit(:post_id, :partner_id, :url, :pageviews)
    end
end
