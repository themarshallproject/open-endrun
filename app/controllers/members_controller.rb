class MembersController < ApplicationController

  before_action :verify_current_user_present, except: [:auth_with_token] 
  before_action :set_member, only: [:show, :edit, :update, :destroy]

  def auth_with_token
    token = params[:token]
    member = Member.where(token: token).first
    if member.present? and member.active?
      Slack.perform_async('SLACK_DEV_LOGS_URL', {
        channel: "#dev_logs",
        username: "Member Login Successful",
        text: "Member #{member.email} is now on the site.",
        icon_emoji: ":fire:"
      })
      cookies.signed[:m_id] = {value: member.id, expires: 7.days.from_now}
      redirect_to root_path
    else
      render plain: "Invalid token. If you think you've gotten this in error, please email us."
    end
  end

  # GET /members
  # GET /members.json
  def index
    @members = Member.all
  end

  # GET /members/1
  # GET /members/1.json
  def show
  end

  # GET /members/new
  def new
    @member = Member.new
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members
  # POST /members.json
  def create
    @member = Member.new(member_params)

    respond_to do |format|
      if @member.save
        format.html { redirect_to @member, notice: 'Member was successfully created.' }
        format.json { render :show, status: :created, location: @member }
      else
        format.html { render :new }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update
    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to @member, notice: 'Member was successfully updated.' }
        format.json { render :show, status: :ok, location: @member }
      else
        format.html { render :edit }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    @member.destroy
    respond_to do |format|
      format.html { redirect_to members_url, notice: 'Member was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def member_params
      params.require(:member).permit(:name, :email, :token, :last_seen_at, :last_ip, :active)
    end
end
