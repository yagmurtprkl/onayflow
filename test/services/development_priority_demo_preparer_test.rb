require "test_helper"

class DevelopmentPriorityDemoPreparerTest < ActiveSupport::TestCase
  setup do
    @employee = User.create!(
      name: "Demo Çalışan",
      email: DevelopmentPriorityDemoPreparer::EMPLOYEE_EMAIL,
      role: :employee,
      password: "TestPassword123!"
    )
    @manager = User.create!(
      name: "Demo Yönetici",
      email: DevelopmentPriorityDemoPreparer::MANAGER_EMAIL,
      role: :manager,
      password: "TestPassword123!"
    )
    @reference_time = Time.zone.local(2026, 10, 17, 12)
  end

  test "refuses test and production environments without changing data" do
    %w[test production].each do |environment_name|
      environment = ActiveSupport::StringInquirer.new(environment_name)

      assert_no_difference("ApprovalDocument.count") do
        assert_raises(DevelopmentPriorityDemoPreparer::EnvironmentError) do
          DevelopmentPriorityDemoPreparer.new(environment: environment).call!
        end
      end
    end
  end

  test "creates three idempotent pending documents through normal submission" do
    preparer = development_preparer

    assert_difference("ApprovalDocument.count", 3) do
      @documents = preparer.call!
    end
    assert_no_difference("ApprovalDocument.count") { preparer.call! }

    assert_equal DevelopmentPriorityDemoPreparer::DOCUMENT_DEFINITIONS.pluck(:title), @documents.pluck(:title)
    assert @documents.all?(&:pending?)
    assert @documents.all? { |document| document.requester == @employee && document.approver == @manager }
    assert @documents.all? { |document| document.due_at == document.submitted_at + 48.hours }
    assert_equal 3, @documents.pluck(:demo_key).compact.uniq.size
  end

  test "sets normal urgent and overdue deadlines and priority order" do
    travel_to @reference_time do
      documents = development_preparer.call!
      documents_by_title = documents.index_by(&:title)

      normal = documents_by_title.fetch("Ekipman Satın Alma Talebi")
      urgent = documents_by_title.fetch("Acil Bütçe Onayı")
      overdue = documents_by_title.fetch("Sunucu Bakım Talebi")

      assert_equal @reference_time + 48.hours, normal.due_at
      assert_equal @reference_time + 3.hours, urgent.due_at
      assert_equal @reference_time - 2.hours, overdue.due_at
      assert_equal :normal, normal.next_action_priority
      assert_equal :urgent, urgent.next_action_priority
      assert_equal :overdue, overdue.next_action_priority

      assert_equal [ overdue, urgent, normal ], ApprovalDocument.prioritized_for(@manager, at: @reference_time)
    end
  end

  test "does not modify a user document with the same title" do
    user_document = ApprovalDocument.create!(
      title: "Acil Bütçe Onayı",
      content: "Kullanıcının kendi belge içeriği",
      requester: @employee,
      approver: @manager
    )
    original_attributes = user_document.attributes

    development_preparer.call!

    assert_equal original_attributes, user_document.reload.attributes
    assert_nil user_document.demo_key
  end

  test "refuses to reset a decided demo document" do
    documents = development_preparer.call!
    normal = documents.find { |document| document.demo_key == "priority-demo-normal-v1" }
    normal.approve!(actor: @manager)
    decided_attributes = normal.attributes

    assert_raises(DevelopmentPriorityDemoPreparer::DocumentStateError) do
      development_preparer.call!
    end

    assert_equal decided_attributes, normal.reload.attributes
  end

  private

  def development_preparer
    DevelopmentPriorityDemoPreparer.new(
      environment: ActiveSupport::StringInquirer.new("development"),
      reference_time: @reference_time
    )
  end
end
