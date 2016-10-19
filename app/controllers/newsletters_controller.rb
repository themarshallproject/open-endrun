class NewslettersController < ApplicationController
  before_action :verify_current_user_present
  before_action :set_newsletter, only: [:show, :build, :build_text, :sort, :update_assignments, :sync_newsletter_to_mailchimp, :edit, :update, :destroy, :raw_html]


  def update_assignments
    results = (params['assignments'] || []).map do |item|
      assignment = NewsletterAssignment.where(newsletter_id: @newsletter.id, id: item['tagging_assignment_id']).first
      assignment.bucket   = item['slug']
      assignment.position = item['position']
      assignment.save
    end

    @newsletter.email_subject = params['config']['email_subject']
    @newsletter.blurb         = params['config']['blurb']
    results << @newsletter.save

    render text: results.join("|"), status: results.all? ? 200 : 402
  end

  def updated_homepage_positions
  end

  def update_email_contents
    results = (params['email_updates'] || []).map do |item|
      taggable = taggable_from(model: item[:model], id: item[:id])
      taggable.email_content = item[:email_content]
      taggable.save
    end

    render text: results.join("|"), status: results.all? ? 200 : 402
  end

  # GET /newsletters
  # GET /newsletters.json
  def index
    @newsletters = Newsletter.order('created_at DESC').all
  end

  def sort
    num_days = (params[:days] || 3).to_i
    @potential_items = (
      Post.where('published_at > ?', num_days.days.ago).order('created_at DESC') +
      Link.where('created_at > ?', num_days.days.ago).order('created_at DESC')
    ).sort_by{ |item|
      -1 * (item.try(:published_at) || item.created_at).to_i # todo, need consistent sort key here
    }

    @newsletter_items = @newsletter.items # makes it 150 times faster, probably worth keeping

    @building_current_assignments_ms = Benchmark.ms do
      @current_assignments = @potential_items.inject({}) do |obj, potential_item|

        is_currently_assigned = @newsletter_items.any? do |existing_item|
          [ existing_item.taggable.model_name == potential_item.class.name.downcase,
            existing_item.taggable.id         == potential_item.id
          ].all?
        end

        obj[potential_item.id] = is_currently_assigned
        obj

      end
    end

  end

  def attach_to_taggable
    newsletter = Newsletter.find(params[:newsletter_id])
    model = params[:model_name].singularize.classify.constantize
    taggable = model.find(params[:model_id].to_i)
    taggable.email_content = taggable.default_email_content
    taggable.save

    if newsletter.attach_to(taggable).save
      render partial: 'newsletters/sorter_potential_item', locals: { newsletter: newsletter, item: taggable, is_already_present: true }, layout: false
    else
      render partial: 'newsletters/sorter_potential_item', locals: { newsletter: newsletter, item: taggable, is_already_present: false }, layout: false, status: 503
    end
  end

  def remove_from_taggable
    newsletter = Newsletter.find(params[:newsletter_id])
    model = params[:model_name].singularize.classify.constantize
    taggable = model.find(params[:model_id].to_i)
    NewsletterAssignment.where(taggable: taggable, newsletter: newsletter).destroy_all

    render partial: 'newsletters/sorter_potential_item', locals: { newsletter: newsletter, item: taggable, is_already_present: false }, layout: false
  end

  # GET /newsletters/1
  # GET /newsletters/1.json
  def show
    @newsletter_items = @newsletter.items

    build_doc = Nokogiri.HTML(render_to_string('build', layout: false))
    @problem_links = []
    build_doc.css('a').each do |link|
      next if link['href'] == "*|UPDATE_PROFILE|*"
      next if link['href'] == "*|FORWARD|*"

      unless link['href'].include?('http')
        @problem_links << link['href']
      end
    end
  end

  def build
      render 'build', layout: false # this is the "main" layout
  end

  def raw_html
    render plain: render_to_string('build', layout: false)
  end

  def build_text
      render 'build_text', layout: false
  end

  def sync_newsletter_to_mailchimp
    html = render_to_string('build', layout: false).gsub('%7C','|')
    text = render_to_string('build_text', layout: false).gsub('%7C','|')
    SyncMailchimpCampaign.perform_async(@newsletter.id, html, text)
    redirect_to @newsletter, notice: 'Syncing campaign to Mailchimp...'
  end

  # GET /newsletters/new
  def new
    @newsletter = Newsletter.new
  end

  # GET /newsletters/1/edit
  def edit
  end

  # POST /newsletters
  # POST /newsletters.json
  def create
    @newsletter = Newsletter.new(newsletter_params)

    respond_to do |format|
      if @newsletter.save
        format.html { redirect_to @newsletter, notice: 'Newsletter was successfully created.' }
        format.json { render :show, status: :created, location: @newsletter }
      else
        format.html { render :new }
        format.json { render json: @newsletter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /newsletters/1
  # PATCH/PUT /newsletters/1.json
  def update
    respond_to do |format|
      if @newsletter.update(newsletter_params)
        format.html { redirect_to @newsletter, notice: 'Newsletter was successfully updated.' }
        format.json { render :show, status: :ok, location: @newsletter }
      else
        format.html { render :edit }
        format.json { render json: @newsletter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /newsletters/1
  # DELETE /newsletters/1.json
  def destroy
    @newsletter.destroy
    respond_to do |format|
      format.html { redirect_to newsletters_url, notice: 'Newsletter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_newsletter
      @newsletter = Newsletter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def newsletter_params
      params.require(:newsletter).permit(:name, :byline, :public, :published_at, :email_subject, :blurb, :template)
    end

    def taggable_from(args={})
      model = args[:model].singularize.classify.constantize
      taggable = model.find(args[:id].to_i)
      taggable
    end
end
