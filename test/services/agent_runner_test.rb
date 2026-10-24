require "test_helper"

class AgentRunnerTest < ActiveSupport::TestCase
  class FakeClient
    attr_reader :calls
    def initialize(*results)
      @results = results
      @calls = 0
    end

    def model = "test-model"

    def call(_messages)
      @calls += 1
      result = @results.shift
      raise result if result.is_a?(Exception)
      result
    end
  end

  setup do
    @request = AgentRequest.create!(requester: users(:employee), approver: users(:manager))
  end

  def ready
    { "action" => "ready", "reply" => "Talebinizi hazırladım.", "title" => "İki monitör",
      "purpose" => "Tasarım ekibinin çalışması", "amount" => 20000, "currency" => "TRY",
      "needed_on" => (Date.current + 7).iso8601, "urgency" => "normal",
      "rationale" => "Önümüzdeki hafta gerekli; bugün için aciliyet yok.", "missing_fields" => [] }
  end

  test "asks for missing information and submits exactly one document once complete" do
    client = FakeClient.new({ "action" => "needs_info", "reply" => "Tutar ve ihtiyaç tarihi nedir?" }, ready)
    runner = Agent::Runner.new(client: client)
    assert_no_difference "ApprovalDocument.count" do
      runner.call(@request, message: "İki monitör lazım")
    end
    assert @request.reload.collecting?
    travel_to Time.current.change(usec: 0) do
      assert_difference "ApprovalDocument.count", 1 do
        runner.call(@request, message: "20000 TL, gelecek hafta")
      end
      assert_equal 48.hours, @request.approval_document.due_at - Time.current
    end
    assert @request.reload.submitted?
    assert @request.approval_document.pending?
    assert_equal users(:manager), @request.approval_document.approver
    assert_no_difference "ApprovalDocument.count" do
      runner.call(@request, message: "20000 TL, gelecek hafta")
    end
    assert_equal 2, client.calls
  end

  test "explicit human handoff does not submit a document" do
    runner = Agent::Runner.new(client: FakeClient.new({ "action" => "handoff", "reply" => "Yöneticiye danışalım." }))
    assert_no_difference "ApprovalDocument.count" do
      runner.call(@request, message: "Bütçeyi bilmiyorum; insanla görüşmek istiyorum")
    end
    assert @request.reload.handoff?
    assert_raises(Agent::Runner::Closed) { runner.call(@request, message: "Devam") }
  end

  test "unavailable service hands off and preserves original message" do
    Agent::Runner.new(client: FakeClient.new(Agent::LlmClient::Unavailable.new)).call(@request, message: "Monitör lazım")
    assert @request.reload.handoff?
    assert_nil @request.approval_document
    assert_equal "Monitör lazım", @request.messages.first.fetch("content")
    assert_nil @request.llm_model
  end

  test "malformed or incomplete ready response cannot create a document" do
    [ ready.merge("amount" => -1), ready.merge("needed_on" => "invalid"),
      ready.merge("missing_fields" => [ "purpose" ]), ready.merge("purpose" => ""),
      ready.merge("title" => "a" * 201), { "action" => "approve", "reply" => "Onaylandı" } ].each do |result|
      request = AgentRequest.create!(requester: users(:employee), approver: users(:manager))
      assert_no_difference "ApprovalDocument.count" do
        Agent::Runner.new(client: FakeClient.new(result)).call(request, message: "Talep")
      end
      assert request.reload.handoff?
    end
  end

  test "blank and oversized messages never call provider" do
    client = FakeClient.new
    [ " ", "x" * 4001 ].each do |text|
      assert_raises(Agent::Runner::InvalidMessage) { Agent::Runner.new(client: client).call(@request, message: text) }
    end
    assert_equal 0, client.calls
  end

  test "a document decision is visible through request association" do
    Agent::Runner.new(client: FakeClient.new(ready)).call(@request, message: "Talep")
    @request.approval_document.approve!(actor: users(:manager))
    assert @request.reload.approval_document.approved?
  end
end
