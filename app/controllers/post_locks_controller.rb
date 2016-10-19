class PostLocksController < ApplicationController
  before_action :verify_current_user_present
  before_action :set_post_lock, only: [:show, :edit, :update, :destroy]

  # GET /post_locks
  # GET /post_locks.json
  def index
    PostLockSweeper.perform_async
    @post_locks = PostLock.order('created_at DESC').all
  end

  # GET /post_locks/1
  # GET /post_locks/1.json
  def show
  end

  # GET /post_locks/new
  def new
    @post_lock = PostLock.new
  end

  # GET /post_locks/1/edit
  def edit
  end

  def actives_widget
    @post_locks = PostLock.includes(:post, :user).all.sort_by do |post_lock|
      (-1 * post_lock.post.updated_at.to_i) rescue 0
    end
    
    if @post_locks.empty?
      render text: ""
    else
      render json: {
        t: Time.now.utc.to_f,
        html: render_to_string(layout: false)
      }
    end
  end

  # POST /post_locks
  # POST /post_locks.json
  def create
    @post_lock = PostLock.new(post_lock_params)

    respond_to do |format|
      if @post_lock.save
        format.html { redirect_to @post_lock, notice: 'Post lock was successfully created.' }
        format.json { render :show, status: :created, location: @post_lock }
      else
        format.html { render :new }
        format.json { render json: @post_lock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /post_locks/1
  # PATCH/PUT /post_locks/1.json
  def update
    respond_to do |format|
      if @post_lock.update(post_lock_params)
        format.html { redirect_to @post_lock, notice: 'Post lock was successfully updated.' }
        format.json { render :show, status: :ok, location: @post_lock }
      else
        format.html { render :edit }
        format.json { render json: @post_lock.errors, status: :unprocessable_entity }
      end
    end
  end

  def touch
    @post_lock = PostLock.find(params[:id]) rescue nil
    if @post_lock.present?
      render plain: @post_lock.touch
    else
      logger.info "PostLock#touch could not find PostLock w/ id=#{params[:id]} by #{current_user.email}"
      render plain: "Invalid PostLock ID", status: 404
    end
  end

  # DELETE /post_locks/1
  # DELETE /post_locks/1.json
  def destroy    
    @post_lock.destroy
    respond_to do |format|
      format.html { redirect_to post_locks_url, notice: 'Post lock was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post_lock
      @post_lock = PostLock.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_lock_params
      params.require(:post_lock).permit(:post_id, :user_id, :acquired_at)
    end
end
