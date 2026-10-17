class DevelopmentPriorityDemoPreparer
  class EnvironmentError < StandardError; end
  class AccountError < StandardError; end
  class DocumentStateError < StandardError; end

  EMPLOYEE_EMAIL = "employee@onayflow.test"
  MANAGER_EMAIL = "manager@onayflow.test"

  DOCUMENT_DEFINITIONS = [
    {
      demo_key: "priority-demo-normal-v1",
      title: "Ekipman Satın Alma Talebi",
      content: "Yeni ekip ekipmanlarının satın alınması için yönetici onayı talep edilmektedir.",
      due_offset: 48.hours
    },
    {
      demo_key: "priority-demo-urgent-v1",
      title: "Acil Bütçe Onayı",
      content: "Zaman kritik bütçe düzenlemesi için yönetici kararı gerekmektedir.",
      due_offset: 3.hours
    },
    {
      demo_key: "priority-demo-overdue-v1",
      title: "Sunucu Bakım Talebi",
      content: "Planlanan sunucu bakımı için gecikmiş yönetici kararı beklenmektedir.",
      due_offset: -2.hours
    }
  ].freeze

  def initialize(environment: Rails.env, reference_time: Time.current)
    @environment = environment
    @reference_time = reference_time
  end

  def call!
    ensure_development_environment!
    employee, manager = demo_accounts

    ApprovalDocument.transaction do
      DOCUMENT_DEFINITIONS.map do |definition|
        prepare_document!(definition, employee: employee, manager: manager)
      end
    end
  end

  private

  attr_reader :environment, :reference_time

  def ensure_development_environment!
    return if environment.development?

    raise EnvironmentError, "Priority demo data can only be prepared in development."
  end

  def demo_accounts
    employee = User.find_by(email: EMPLOYEE_EMAIL)
    manager = User.find_by(email: MANAGER_EMAIL)

    unless employee&.employee? && manager&.manager?
      raise AccountError, "Development demo accounts are missing or have invalid roles. Run db:seed first."
    end

    [ employee, manager ]
  end

  def prepare_document!(definition, employee:, manager:)
    document = ApprovalDocument.find_by(demo_key: definition.fetch(:demo_key))

    if document
      validate_owned_pending_document!(document, employee: employee, manager: manager)
    else
      document = employee.requested_documents.create!(
        title: definition.fetch(:title),
        content: definition.fetch(:content),
        approver: manager,
        demo_key: definition.fetch(:demo_key)
      )
      document.submit!(actor: employee)
    end

    apply_demo_deadline!(document, due_offset: definition.fetch(:due_offset))
  end

  def validate_owned_pending_document!(document, employee:, manager:)
    return if document.pending? && document.requester == employee && document.approver == manager

    raise DocumentStateError,
          "Demo document #{document.demo_key.inspect} is not an assigned pending document; no data was changed."
  end

  def apply_demo_deadline!(document, due_offset:)
    due_at = reference_time + due_offset

    # These timestamps intentionally model an elapsed 48-hour approval window.
    # Only records carrying this task's unique demo_key can reach this method.
    document.update_columns(
      submitted_at: due_at - ApprovalDocument::APPROVAL_WINDOW,
      due_at: due_at,
      updated_at: reference_time
    )
    document.reload
  end
end
