require "test_helper"

class AgentRequestsTest < ActionDispatch::IntegrationTest
  setup do
    @agent_request_record = AgentRequest.create!(requester: users(:employee), approver: users(:manager),
                                    state: "handoff", messages: [ { "role" => "user", "content" => "İnsanla görüşmek istiyorum" } ])
  end

  test "authentication and ownership boundaries apply" do
    get agent_request_path(@agent_request_record)
    assert_redirected_to login_path
    log_in_as users(:other_employee)
    get agent_request_path(@agent_request_record)
    assert_response :not_found
    post message_agent_request_path(@agent_request_record), params: { message: "Devam" }
    assert_response :not_found
  end

  test "only assigned manager may resume a handoff" do
    log_in_as users(:other_manager)
    post resume_agent_request_path(@agent_request_record), params: { note: "Bütçeyi belirtin" }
    assert_response :not_found
    delete logout_path
    log_in_as users(:manager)
    get agent_request_path(@agent_request_record)
    assert_response :success
    post resume_agent_request_path(@agent_request_record), params: { note: "Bütçeyi belirtin" }
    assert_redirected_to agent_request_path(@agent_request_record)
    assert @agent_request_record.reload.collecting?
    assert_equal "human", @agent_request_record.messages.last.fetch("role")
  end

  test "employee cannot act as manager and manager cannot create employee requests" do
    log_in_as users(:employee)
    post resume_agent_request_path(@agent_request_record), params: { note: "Kendim devraldım" }
    assert_response :forbidden
    delete logout_path
    log_in_as users(:manager)
    get new_agent_request_path
    assert_response :forbidden
    post agent_requests_path, params: { approver_id: users(:manager).id, message: "Talep" }
    assert_response :forbidden
  end

  test "request pages escape untrusted messages" do
    @agent_request_record.update!(messages: [ { "role" => "user", "content" => "<script>alert(1)</script>" } ])
    log_in_as users(:employee)
    get agent_request_path(@agent_request_record)
    assert_response :success
    assert_select ".agent-message script", count: 0
    get agent_requests_path
    assert_response :success
    get new_agent_request_path
    assert_response :success
  end
  test "creation without a provider key persists a visible human handoff" do
    previous_key = ENV.delete("GROQ_API_KEY")
    log_in_as users(:employee)
    assert_difference "AgentRequest.count", 1 do
      assert_no_difference "ApprovalDocument.count" do
        post agent_requests_path, params: { approver_id: users(:manager).id, message: "Monitör lazım" }
      end
    end
    created = AgentRequest.order(:id).last
    assert_redirected_to agent_request_path(created)
    assert created.handoff?
    follow_redirect!
    assert_response :success
    assert_select "h2", text: "İnsan incelemesine devredildi"
  ensure
    previous_key.nil? ? ENV.delete("GROQ_API_KEY") : ENV["GROQ_API_KEY"] = previous_key
  end

  test "blank requests and non-manager recipients do not create conversations" do
    log_in_as users(:employee)
    assert_no_difference "AgentRequest.count" do
      post agent_requests_path, params: { approver_id: users(:manager).id, message: " " }
      assert_redirected_to new_agent_request_path
      post agent_requests_path, params: { approver_id: users(:other_employee).id, message: "Monitör" }
      assert_response :not_found
    end
  end
end
