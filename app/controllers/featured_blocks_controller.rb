class FeaturedBlocksController < ApplicationController
  before_action :verify_current_user_present
  before_action :set_featured_block, only: [:show, :edit, :update, :destroy, :preview, :activate, :dupe]

  # GET /featured_blocks
  # GET /featured_blocks.json
  def index
    @page = (params[:page] || 0).to_i
    @page_size = 15
    @total_pages = (1.0*FeaturedBlock.count/@page_size).ceil

    @featured_blocks = FeaturedBlock.order('updated_at DESC').offset(@page*@page_size).first(@page_size)
  end

  # GET /featured_blocks/1
  # GET /featured_blocks/1.json
  def show
  end

  def activate
    if @featured_block.activate!(current_user)
      redirect_to featured_blocks_path
    else
      render text: "Failed to activate!", status: 422
    end
  end

  def dupe
    @dupe = @featured_block.dupe
    redirect_to edit_featured_block_path(@dupe)
  end

  # GET /featured_blocks/new
  def new
    @featured_block = FeaturedBlock.new
  end

  # GET /featured_blocks/1/edit
  def edit
    @all_posts = Post.order('revised_at DESC').all
  end

  def activation_events
    render json: FeaturedBlockActivateEvent.order('created_at DESC').all
  end

  def preview
    render layout: 'public'
  end

  # POST /featured_blocks
  # POST /featured_blocks.json
  def create
    @featured_block = FeaturedBlock.new(featured_block_params)

    respond_to do |format|
      if @featured_block.save
        format.html { redirect_to edit_featured_block_path(@featured_block), notice: 'Featured block was successfully created.' }
        format.json { render :show, status: :created, location: @featured_block }
      else
        format.html { render :new }
        format.json { render json: @featured_block.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /featured_blocks/1
  # PATCH/PUT /featured_blocks/1.json
  def update
    respond_to do |format|
      @featured_block.template  = params[:featured_block][:template]
      @featured_block.slots     = params[:featured_block][:slots]     # hash -> serialize
      @featured_block.published = params[:featured_block][:published]

      if @featured_block.all_posts_published? == false
        logger.info 'warning, unpublished posts included, marking this as unpublished!'
        @featured_block.published = false
      end

      if @featured_block.save
        format.html { redirect_to edit_featured_block_path(@featured_block), notice: 'Featured block was successfully updated.' }
        format.json { render :show, status: :ok, location: @featured_block }
      else
        format.html { render :edit }
        format.json { render json: @featured_block.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /featured_blocks/1
  # DELETE /featured_blocks/1.json
  def destroy
    @featured_block.destroy
    respond_to do |format|
      format.html { redirect_to featured_blocks_url, notice: 'Featured block was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_featured_block
      @featured_block = FeaturedBlock.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def featured_block_params
      params.require(:featured_block).permit(:template, {slots: []}, :published)
    end
end
