class WeeklyNewslettersController < ApplicationController
  before_action :verify_current_user_present
  before_action :set_weekly_newsletter, only: [:show, :edit, :update, :destroy, :build, :build_text]

  def build
      html = render_to_string('build', layout: false) # this is the "main" layout
      render inline: WeeklyNewsletter.inject_styles(html).gsub('%7C','|') 
  end

  def build_text
      render 'build_text', layout: false
  end

  # GET /weekly_newsletters
  # GET /weekly_newsletters.json
  def index
    @weekly_newsletters = WeeklyNewsletter.order('created_at DESC').all
  end

  # GET /weekly_newsletters/1
  # GET /weekly_newsletters/1.json
  def show
  end

  # GET /weekly_newsletters/new
  def new
    @weekly_newsletter = WeeklyNewsletter.new
    @weekly_newsletter.quote_graf = [
      "<blockquote>“#quote#”</blockquote>",
      "*— #attribution#*",
      "<span>[Join the discussion](#link#)</span>"
    ].join("\n\n")

  end

  # GET /weekly_newsletters/1/edit
  def edit
  end

  # POST /weekly_newsletters
  # POST /weekly_newsletters.json
  def create
    @weekly_newsletter = WeeklyNewsletter.new(weekly_newsletter_params)

    respond_to do |format|
      if @weekly_newsletter.save
        format.html { redirect_to edit_weekly_newsletter_path(@weekly_newsletter), notice: 'Weekly newsletter was successfully created.' }
        format.json { render :show, status: :created, location: @weekly_newsletter }
      else
        format.html { render :new }
        format.json { render json: @weekly_newsletter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /weekly_newsletters/1
  # PATCH/PUT /weekly_newsletters/1.json
  def update
    respond_to do |format|
      if @weekly_newsletter.update(weekly_newsletter_params)
        @weekly_newsletter.sync_to_mailchimp
        
        format.html { redirect_to edit_weekly_newsletter_path(@weekly_newsletter), notice: 'Saved.' }
        format.json { render :show, status: :ok, location: @weekly_newsletter }
      else
        format.html { render :edit }
        format.json { render json: @weekly_newsletter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /weekly_newsletters/1
  # DELETE /weekly_newsletters/1.json
  def destroy
    @weekly_newsletter.destroy
    respond_to do |format|
      format.html { redirect_to weekly_newsletters_url, notice: 'Weekly newsletter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_weekly_newsletter
      id = params[:id] || params[:weekly_newsletter_id]
      @weekly_newsletter = WeeklyNewsletter.find(id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def weekly_newsletter_params
      params.require(:weekly_newsletter).permit(:name, :email_subject, :mailchimp_id, :mailchimp_web_id, :byline, :published_at, :public, :archive_url, :opening_graf, :quote_graf, :tmp_stories, :other_stories)
    end
end
