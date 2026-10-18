require "test_helper"

class ApprovalWorkflowTest < ActionDispatch::IntegrationTest
  test "login page and employee document pages render" do
    get login_path
    assert_response :success
    assert_select "form"
    assert_select "input[type='email'][autofocus]", count: 0

    log_in_as(users(:employee))
    follow_redirect!
    assert_response :success
    assert_select "h1", "Belgelerim"
    assert_select ".timezone-pill", "Türkiye saati (UTC+03:00)"

    get new_approval_document_path
    assert_response :success
    assert_select "form.document-form"
    assert_select ".nav-item.active", text: /Yeni belge/

    get edit_approval_document_path(approval_documents(:employee_draft))
    assert_response :success
    assert_select "form.document-form"
    assert_select ".nav-item.active", text: /Belgelerim/

    get approval_document_path(approval_documents(:employee_draft))
    assert_response :success
    assert_select "h1", approval_documents(:employee_draft).title
  end

  test "employee creates a document that starts as draft" do
    employee = users(:employee)
    log_in_as(employee)

    assert_difference("ApprovalDocument.count", 1) do
      post approval_documents_path, params: {
        approval_document: {
          title: "Yeni satın alma talebi",
          content: "Kurumsal lisans satın alma talebi",
          approver_id: users(:manager).id
        }
      }
    end

    document = ApprovalDocument.order(:created_at).last
    assert_redirected_to approval_document_path(document)
    assert_equal employee, document.requester
    assert_predicate document, :draft?
  end

  test "authenticated user can log out" do
    log_in_as(users(:employee))

    delete logout_path

    assert_redirected_to login_path
    get approval_documents_path
    assert_redirected_to login_path
  end

  test "employee submits own draft from controller" do
    document = approval_documents(:employee_draft)
    log_in_as(users(:employee))

    post submit_approval_document_path(document)

    assert_redirected_to approval_document_path(document)
    assert_predicate document.reload, :pending?
    assert_not_nil document.submitted_at
    assert_equal document.submitted_at + 48.hours, document.due_at
  end

  test "employee cannot access another employee document" do
    log_in_as(users(:employee))

    get approval_document_path(approval_documents(:other_employee_draft))

    assert_response :not_found
  end

  test "employee cannot perform manager approval action" do
    document = approval_documents(:employee_pending)
    log_in_as(users(:employee))

    post approve_approval_document_path(document)

    assert_response :forbidden
    assert_predicate document.reload, :pending?
  end

  test "assigned manager can approve pending document" do
    document = approval_documents(:employee_pending)
    log_in_as(users(:manager))

    post approve_approval_document_path(document)

    assert_redirected_to approval_document_path(document)
    assert_predicate document.reload, :approved?
  end

  test "assigned manager can view queue and reject with a reason" do
    document = approval_documents(:employee_pending)
    log_in_as(users(:manager))
    follow_redirect!

    assert_response :success
    assert_select "h1", "Onay Paneli"
    assert_select "title", "Onay Paneli | OnayFlow"

    get approval_document_path(document)
    assert_response :success
    assert_select "form[action=?]", approve_approval_document_path(document)
    assert_select "form[action=?]", reject_approval_document_path(document)

    post reject_approval_document_path(document), params: { rejection_reason: "Eksik bilgi var." }

    assert_redirected_to approval_document_path(document)
    assert_predicate document.reload, :rejected?
    assert_equal "Eksik bilgi var.", document.rejection_reason
  end

  test "manager rejection endpoint requires a reason" do
    document = approval_documents(:employee_pending)
    log_in_as(users(:manager))

    post reject_approval_document_path(document), params: { rejection_reason: "" }

    assert_response :unprocessable_entity
    assert_predicate document.reload, :pending?
  end

  test "unassigned manager cannot view or decide document" do
    document = approval_documents(:employee_pending)
    log_in_as(users(:other_manager))

    get approval_document_path(document)
    assert_response :not_found

    post approve_approval_document_path(document)
    assert_response :not_found
    assert_predicate document.reload, :pending?
  end

  test "manager dashboard shows priorities only for assigned documents" do
    current_time = Time.zone.local(2026, 10, 17, 12)

    travel_to current_time do
      overdue = create_pending_document(
        title: "Gecikmiş yönetici belgesi",
        approver: users(:manager),
        due_at: 30.minutes.ago
      )
      urgent = create_pending_document(
        title: "Acil yönetici belgesi",
        approver: users(:manager),
        due_at: 6.hours.from_now
      )
      normal = create_pending_document(
        title: "Normal yönetici belgesi",
        approver: users(:manager),
        due_at: 7.hours.from_now
      )
      create_pending_document(
        title: "Görünmemesi gereken belge",
        approver: users(:other_manager),
        due_at: 1.hour.from_now
      )

      log_in_as(users(:manager))
      follow_redirect!

      assert_response :success
      assert_select ".priority-panel .eyebrow", "Sıradaki işlem"
      assert_select ".priority-overdue", text: "Gecikmiş", minimum: 1
      assert_select ".priority-urgent", text: "Acil", minimum: 1
      assert_select ".priority-normal", text: "Normal", minimum: 1
      assert_select "body", text: /Gecikmiş yönetici belgesi/
      assert_select "body", text: /Acil yönetici belgesi/
      assert_select "body", text: /Normal yönetici belgesi/
      assert_select "body", text: /Görünmemesi gereken belge/, count: 0

      priority_links = css_select(".priority-table tbody .document-link")
      assert_equal [ overdue.title, urgent.title, normal.title ], priority_links.first(3).map(&:text)
      assert_equal [
        approval_document_path(overdue),
        approval_document_path(urgent),
        approval_document_path(normal)
      ], priority_links.first(3).map { |link| link["href"] }

      time_labels = css_select(".priority-table tbody .time-remaining").first(3).map(&:text)
      assert_equal "30 dk gecikti", time_labels.fetch(0)
      assert_equal "6 sa kaldı", time_labels.fetch(1)
      assert_equal "7 sa kaldı", time_labels.fetch(2)
    end
  end

  private

  def create_pending_document(title:, approver:, due_at:)
    ApprovalDocument.create!(
      title: title,
      content: "Yönetici paneli testi",
      requester: users(:employee),
      approver: approver,
      status: :pending,
      submitted_at: due_at - ApprovalDocument::APPROVAL_WINDOW,
      due_at: due_at
    )
  end
end
