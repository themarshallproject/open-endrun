class DocumentsController < ApplicationController
  before_action :verify_current_user_present
  before_action :set_document, only: [:show, :edit, :update, :destroy, :update_published_url, :async_update_published_url]
  before_action :verify_current_user_present, except: []
  
  # GET /documents
  # GET /documents.json
  def index
    @documents = Document.order('updated_at DESC').all
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
  end

  # GET /documents/new
  def new
    @document = Document.new
  end

  # GET /documents/1/edit
  def edit
  end

  def async_update_published_url
    @document.async_update_published_url
    redirect_to documents_path, notice: 'Syncing URL in the background... refresh this page to confirm.'
  end

  def update_published_url
    @document.update_published_url
    redirect_to documents_path
  end

  def ingest
    Document.where(dc_id: params[:id]).first_or_create
    redirect_to public_document_url(params[:id])
  end

  def potential
    @potential_documents = Document.potential_documents
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = Document.new(document_params)

    respond_to do |format|
      if @document.save
        format.html { redirect_to @document, notice: 'Document was successfully created.' }
        format.json { render :show, status: :created, location: @document }
      else
        format.html { render :new }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update
    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to @document, notice: 'Document was successfully updated.' }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.destroy
    respond_to do |format|
      format.html { redirect_to documents_url, notice: 'Document was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:document).permit(:dc_id, :title, :deck, :published, :body, :dc_data, :dc_published_url)
    end
end
