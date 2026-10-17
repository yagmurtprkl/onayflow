require "test_helper"

class ApprovalDocumentTest < ActiveSupport::TestCase
  setup do
    @employee = users(:employee)
    @manager = users(:manager)
  end

  test "new document starts as draft" do
    document = build_document

    assert document.save
    assert_predicate document, :draft?
  end

  test "employee submits draft and receives a 48 hour deadline" do
    document = create_document
    submission_time = Time.zone.local(2026, 10, 17, 9, 30)

    travel_to submission_time do
      document.submit!(actor: @employee)
    end

    assert_predicate document, :pending?
    assert_equal submission_time, document.submitted_at
    assert_equal submission_time + 48.hours, document.due_at
  end

  test "assigned manager approves pending document" do
    document = create_document
    document.submit!(actor: @employee)

    document.approve!(actor: @manager)

    assert_predicate document, :approved?
    assert_not_nil document.decided_at
  end

  test "assigned manager rejects pending document with a reason" do
    document = create_document
    document.submit!(actor: @employee)

    document.reject!(actor: @manager, reason: "Bütçe bilgisi eksik.")

    assert_predicate document, :rejected?
    assert_equal "Bütçe bilgisi eksik.", document.rejection_reason
    assert_not_nil document.decided_at
  end

  test "rejection requires a reason" do
    document = create_document
    document.submit!(actor: @employee)

    error = assert_raises(ApprovalDocument::InvalidTransitionError) do
      document.reject!(actor: @manager, reason: " ")
    end

    assert_equal "Ret gerekçesi zorunludur.", error.message
    assert_predicate document.reload, :pending?
  end

  test "approved document cannot be approved again" do
    document = create_document
    document.submit!(actor: @employee)
    document.approve!(actor: @manager)

    assert_raises(ApprovalDocument::InvalidTransitionError) do
      document.approve!(actor: @manager)
    end
  end

  test "pending document is not overdue before 48 hours" do
    document = create_document
    submission_time = Time.zone.local(2026, 10, 17, 9, 30)

    travel_to(submission_time) { document.submit!(actor: @employee) }
    travel_to(submission_time + 47.hours + 59.minutes) do
      assert_not_predicate document, :overdue?
    end
  end

  test "pending document is overdue after 48 hours" do
    document = create_document
    submission_time = Time.zone.local(2026, 10, 17, 9, 30)

    travel_to(submission_time) { document.submit!(actor: @employee) }
    travel_to(submission_time + 48.hours + 1.second) do
      assert_predicate document, :overdue?
    end
  end

  test "approved document is not overdue after its deadline" do
    document = create_document
    submission_time = Time.zone.local(2026, 10, 17, 9, 30)

    travel_to(submission_time) { document.submit!(actor: @employee) }
    travel_to(submission_time + 1.hour) { document.approve!(actor: @manager) }
    travel_to(submission_time + 49.hours) do
      assert_not_predicate document, :overdue?
    end
  end

  test "pending documents are classified as overdue urgent and normal" do
    current_time = Time.zone.local(2026, 10, 17, 12)

    travel_to current_time do
      overdue = create_pending_document(title: "Gecikmiş", due_at: 1.minute.ago)
      urgent = create_pending_document(title: "Acil", due_at: 2.hours.from_now)
      normal = create_pending_document(title: "Normal", due_at: 7.hours.from_now)

      assert_equal :overdue, overdue.next_action_priority
      assert_equal :urgent, urgent.next_action_priority
      assert_equal :normal, normal.next_action_priority
    end
  end

  test "exactly six hours remaining is urgent" do
    current_time = Time.zone.local(2026, 10, 17, 12)

    travel_to current_time do
      document = create_pending_document(title: "Altı saat sınırı", due_at: 6.hours.from_now)

      assert_equal :urgent, document.next_action_priority
    end
  end

  test "approval windows use absolute instants when runtime time zone is UTC" do
    document = create_document
    submission_time = Time.utc(2026, 10, 17, 6, 30)

    Time.use_zone("UTC") do
      travel_to(submission_time) { document.submit!(actor: @employee) }

      assert_equal submission_time, document.submitted_at
      assert_equal submission_time + 48.hours, document.due_at

      travel_to(submission_time + 41.hours + 59.minutes + 59.seconds) do
        assert_equal :normal, document.next_action_priority
      end

      travel_to(submission_time + 42.hours) do
        assert_equal :urgent, document.next_action_priority
      end

      travel_to(submission_time + 48.hours + 1.second) do
        assert_equal :overdue, document.next_action_priority
      end
    end
  end

  test "priority queue orders groups and deadlines" do
    current_time = Time.zone.local(2026, 10, 17, 12)

    travel_to current_time do
      overdue_first = create_pending_document(title: "Gecikmiş 1", due_at: 3.hours.ago)
      overdue_second = create_pending_document(title: "Gecikmiş 2", due_at: 1.hour.ago)
      urgent_first = create_pending_document(title: "Acil 1", due_at: 1.hour.from_now)
      urgent_second = create_pending_document(title: "Acil 2", due_at: 5.hours.from_now)
      normal_first = create_pending_document(title: "Normal 1", due_at: 7.hours.from_now)
      normal_second = create_pending_document(title: "Normal 2", due_at: 12.hours.from_now)

      expected_order = [
        overdue_first,
        overdue_second,
        urgent_first,
        urgent_second,
        normal_first,
        normal_second
      ]

      prioritized_documents = ApprovalDocument.prioritized_for(@manager, at: current_time)
      created_document_ids = expected_order.map(&:id)
      created_documents_in_queue = prioritized_documents.select do |document|
        created_document_ids.include?(document.id)
      end

      assert_equal expected_order, created_documents_in_queue
    end
  end

  test "approved and rejected documents are excluded from priority queue" do
    current_time = Time.zone.local(2026, 10, 17, 12)

    travel_to current_time do
      pending = create_pending_document(title: "Karar bekliyor", due_at: 2.hours.from_now)
      approved = create_pending_document(title: "Onaylandı", due_at: 3.hours.from_now)
      rejected = create_pending_document(title: "Reddedildi", due_at: 4.hours.from_now)
      approved.approve!(actor: @manager)
      rejected.reject!(actor: @manager, reason: "Gerekli bilgi eksik.")

      prioritized_documents = ApprovalDocument.prioritized_for(@manager, at: current_time)

      assert_includes prioritized_documents, pending
      assert_not_includes prioritized_documents, approved
      assert_not_includes prioritized_documents, rejected
    end
  end

  test "another manager's documents are excluded from priority queue" do
    current_time = Time.zone.local(2026, 10, 17, 12)

    travel_to current_time do
      assigned = create_pending_document(title: "Atanmış belge", due_at: 2.hours.from_now)
      other_manager_document = create_pending_document(
        title: "Başka yöneticiye atanmış",
        due_at: 1.hour.from_now,
        approver: users(:other_manager)
      )

      prioritized_documents = ApprovalDocument.prioritized_for(@manager, at: current_time)

      assert_includes prioritized_documents, assigned
      assert_not_includes prioritized_documents, other_manager_document
      assert prioritized_documents.all? { |document| document.approver == @manager }
    end
  end

  private

  def build_document
    ApprovalDocument.new(
      title: "Yeni talep",
      content: "Onaylanacak belge içeriği",
      requester: @employee,
      approver: @manager
    )
  end

  def create_document
    build_document.tap(&:save!)
  end

  def create_pending_document(title:, due_at:, approver: @manager)
    ApprovalDocument.create!(
      title: title,
      content: "Öncelik testi belge içeriği",
      requester: @employee,
      approver: approver,
      status: :pending,
      submitted_at: due_at - ApprovalDocument::APPROVAL_WINDOW,
      due_at: due_at
    )
  end
end
