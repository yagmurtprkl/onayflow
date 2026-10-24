class AgentRequestsController < ApplicationController
  before_action :require_authentication
  before_action :require_employee, only: %i[new create message]
  before_action :require_manager, only: :resume
  before_action :set_request, only: %i[show message resume]

  def index
    @agent_requests = visible_requests.includes(:requester, :approver, :approval_document).order(updated_at: :desc)
  end

  def new
    @managers = User.manager.order(:name)
  end

  def create
    manager = User.manager.find(params[:approver_id])
    text = params[:message].to_s.strip
    if text.blank? || text.length > 4000
      redirect_to new_agent_request_path, alert: "Talep 1–4000 karakter olmalıdır."
      return
    end
    request = AgentRequest.create!(requester: current_user, approver: manager)
    Agent::Runner.new.call(request, message: text)
    redirect_to request
  end

  def show
  end

  def message
    Agent::Runner.new.call(@agent_request, message: params[:message])
    redirect_to @agent_request
  rescue Agent::Runner::InvalidMessage
    redirect_to @agent_request, alert: "Mesaj 1–4000 karakter olmalı; konuşma en fazla 40 mesaj içerebilir."
  rescue Agent::Runner::Closed
    redirect_to @agent_request, alert: "Talep insan incelemesinde. Yöneticinin yanıtını bekleyin."
  end

  def resume
    note = params[:note].to_s.strip
    if note.blank? || note.length > 4000
      redirect_to @agent_request, alert: "Açıklama 1–4000 karakter olmalıdır."
      return
    end
    @agent_request.with_lock do
      if @agent_request.handoff?
        @agent_request.append_message("human", note)
        @agent_request.state = "collecting"
        @agent_request.save!
      end
    end
    redirect_to @agent_request, notice: "Açıklamanız çalışana iletildi; çalışan agent ile devam edebilir."
  end

  private

  def visible_requests
    current_user.employee? ? AgentRequest.where(requester: current_user) : AgentRequest.where(approver: current_user)
  end

  def set_request
    @agent_request = visible_requests.find(params[:id])
  end
end
