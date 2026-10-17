class ApprovalDocument < ApplicationRecord
  APPROVAL_WINDOW = 48.hours
  URGENT_WINDOW = 6.hours
  REVIEW_PRIORITY_ORDER = { overdue: 0, urgent: 1, normal: 2 }.freeze
  ALLOWED_TRANSITIONS = {
    "draft" => %w[pending],
    "pending" => %w[approved rejected]
  }.freeze

  class InvalidTransitionError < StandardError; end
  class AuthorizationError < StandardError; end

  belongs_to :requester, class_name: "User", inverse_of: :requested_documents
  belongs_to :approver, class_name: "User", inverse_of: :assigned_documents

  enum :status,
       { draft: "draft", pending: "pending", approved: "approved", rejected: "rejected" },
       default: :draft,
       validate: true

  scope :pending_review, -> { pending.order(due_at: :asc, created_at: :asc) }

  def self.prioritized_for(approver, at: Time.current)
    pending
      .where(approver: approver)
      .includes(:requester)
      .to_a
      .sort_by do |document|
        [ REVIEW_PRIORITY_ORDER.fetch(document.next_action_priority(at: at)), document.due_at ]
      end
  end

  validates :title, presence: true, length: { maximum: 200 }
  validates :content, presence: true
  validates :demo_key, uniqueness: true, allow_nil: true
  validates :rejection_reason, presence: true, if: :rejected?
  validate :requester_must_be_employee
  validate :approver_must_be_manager
  validate :status_transition_must_be_allowed, on: :update
  validate :document_fields_change_only_while_draft, on: :update
  validate :timestamps_must_match_status

  def submit!(actor:)
    with_lock do
      authorize_requester!(actor)
      ensure_transition_to!("pending")

      submitted_time = Time.current
      update!(
        status: :pending,
        submitted_at: submitted_time,
        due_at: submitted_time + APPROVAL_WINDOW,
        decided_at: nil,
        rejection_reason: nil
      )
    end
  end

  def approve!(actor:)
    with_lock do
      authorize_approver!(actor)
      ensure_transition_to!("approved")
      update!(status: :approved, decided_at: Time.current, rejection_reason: nil)
    end
  end

  def reject!(actor:, reason:)
    with_lock do
      authorize_approver!(actor)
      ensure_transition_to!("rejected")

      normalized_reason = reason.to_s.strip
      if normalized_reason.blank?
        raise InvalidTransitionError, "Ret gerekçesi zorunludur."
      end

      update!(
        status: :rejected,
        decided_at: Time.current,
        rejection_reason: normalized_reason
      )
    end
  end

  def next_action_priority(at: Time.current)
    return unless pending? && due_at.present?
    return :overdue if due_at < at
    return :urgent if due_at <= at + URGENT_WINDOW

    :normal
  end

  def seconds_until_due(at: Time.current)
    return unless pending? && due_at.present?

    due_at - at
  end

  def overdue?(at: Time.current)
    next_action_priority(at: at) == :overdue
  end

  def editable_by?(user)
    draft? && requester == user && user&.employee?
  end

  private

  def authorize_requester!(actor)
    return if actor&.employee? && requester == actor

    raise AuthorizationError, "Bu belge üzerinde çalışan işlemi yapma yetkiniz yok."
  end

  def authorize_approver!(actor)
    return if actor&.manager? && approver == actor

    raise AuthorizationError, "Bu belge için karar verme yetkiniz yok."
  end

  def ensure_transition_to!(target_status)
    return if ALLOWED_TRANSITIONS.fetch(status, []).include?(target_status)

    raise InvalidTransitionError, "#{status} durumundan #{target_status} durumuna geçilemez."
  end

  def requester_must_be_employee
    errors.add(:requester, "çalışan rolünde olmalıdır") if requester && !requester.employee?
  end

  def approver_must_be_manager
    errors.add(:approver, "yönetici rolünde olmalıdır") if approver && !approver.manager?
  end

  def status_transition_must_be_allowed
    return unless will_save_change_to_status?

    previous_status, next_status = status_change_to_be_saved
    return if ALLOWED_TRANSITIONS.fetch(previous_status, []).include?(next_status)

    errors.add(:status, "geçişi geçersizdir")
  end

  def document_fields_change_only_while_draft
    return unless will_save_change_to_title? || will_save_change_to_content? || will_save_change_to_approver_id?
    return if status == "draft" && status_was == "draft"

    errors.add(:base, "Yalnızca taslak belgeler düzenlenebilir.")
  end

  def timestamps_must_match_status
    if draft?
      errors.add(:submitted_at, "taslak belgede bulunamaz") if submitted_at.present?
      errors.add(:due_at, "taslak belgede bulunamaz") if due_at.present?
      errors.add(:decided_at, "taslak belgede bulunamaz") if decided_at.present?
    else
      errors.add(:submitted_at, "zorunludur") if submitted_at.blank?
      errors.add(:due_at, "zorunludur") if due_at.blank?
    end

    if approved? || rejected?
      errors.add(:decided_at, "zorunludur") if decided_at.blank?
    elsif decided_at.present?
      errors.add(:decided_at, "yalnızca karardan sonra bulunabilir")
    end
  end
end
