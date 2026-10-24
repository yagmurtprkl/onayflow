class AgentRequest < ApplicationRecord
  belongs_to :requester, class_name: "User"
  belongs_to :approver, class_name: "User"
  belongs_to :approval_document, optional: true

  enum :state, { collecting: "collecting", submitted: "submitted", handoff: "handoff" }, validate: true
  validate :roles_must_match

  def append_message(role, content)
    self.messages = messages + [ { "role" => role, "content" => content } ]
  end

  private

  def roles_must_match
    errors.add(:requester, "çalışan olmalıdır") unless requester&.employee?
    errors.add(:approver, "yönetici olmalıdır") unless approver&.manager?
  end
end
