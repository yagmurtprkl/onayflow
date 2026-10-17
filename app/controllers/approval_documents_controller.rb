class ApprovalDocumentsController < ApplicationController
  before_action :require_authentication
  before_action :require_employee, only: %i[new create edit update submit]
  before_action :require_manager, only: %i[pending approve reject]
  before_action :set_approval_document, only: %i[show edit update submit approve reject]
  before_action :ensure_editable, only: %i[edit update]

  rescue_from ApprovalDocument::AuthorizationError, with: :render_forbidden

  def index
    if current_user.manager?
      redirect_to pending_approval_documents_path
      return
    end

    documents = current_user.requested_documents.includes(:approver)
    @approval_documents = documents.order(created_at: :desc)
    @document_counts = {
      total: documents.count,
      pending: documents.pending.count,
      approved: documents.approved.count,
      rejected: documents.rejected.count
    }
  end

  def pending
    @dashboard_time = Time.current
    assigned_documents = current_user.assigned_documents.includes(:requester)
    @next_actions = ApprovalDocument.prioritized_for(current_user, at: @dashboard_time)
    @approval_documents = assigned_documents.order(created_at: :desc)
    @document_counts = {
      pending: @next_actions.size,
      overdue: @next_actions.count { |document| document.next_action_priority(at: @dashboard_time) == :overdue },
      urgent: @next_actions.count { |document| document.next_action_priority(at: @dashboard_time) == :urgent }
    }
  end

  def show
  end

  def new
    @approval_document = current_user.requested_documents.new
    load_managers
  end

  def create
    @approval_document = current_user.requested_documents.new(approval_document_params)

    if @approval_document.save
      redirect_to @approval_document, notice: "Belge taslak olarak oluşturuldu."
    else
      load_managers
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_managers
  end

  def update
    if @approval_document.update(approval_document_params)
      redirect_to @approval_document, notice: "Taslak belge güncellendi."
    else
      load_managers
      render :edit, status: :unprocessable_entity
    end
  end

  def submit
    @approval_document.submit!(actor: current_user)
    redirect_to @approval_document, notice: "Belge onaya gönderildi."
  rescue ApprovalDocument::InvalidTransitionError => error
    redirect_to @approval_document, alert: error.message
  end

  def approve
    @approval_document.approve!(actor: current_user)
    redirect_to @approval_document, notice: "Belge onaylandı."
  rescue ApprovalDocument::InvalidTransitionError => error
    redirect_to @approval_document, alert: error.message
  end

  def reject
    @approval_document.reject!(actor: current_user, reason: params[:rejection_reason])
    redirect_to @approval_document, notice: "Belge reddedildi."
  rescue ApprovalDocument::InvalidTransitionError => error
    flash.now[:alert] = error.message
    render :show, status: :unprocessable_entity
  end

  private

  def set_approval_document
    @approval_document = visible_documents.find(params[:id])
  end

  def visible_documents
    if current_user.employee?
      current_user.requested_documents
    else
      current_user.assigned_documents
    end
  end

  def ensure_editable
    return if @approval_document.editable_by?(current_user)

    redirect_to @approval_document, alert: "Yalnızca taslak belgeler düzenlenebilir."
  end

  def approval_document_params
    params.require(:approval_document).permit(:title, :content, :approver_id)
  end

  def load_managers
    @managers = User.manager.order(:name)
  end

  def render_forbidden
    head :forbidden
  end
end
