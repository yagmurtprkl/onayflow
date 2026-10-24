require "test_helper"

class AgentLlmClientTest < ActiveSupport::TestCase
  test "missing key raises a controlled unavailable error without network" do
    assert_raises(Agent::LlmClient::Unavailable) { Agent::LlmClient.new(key: nil).call([]) }
  end

  test "provider JSON response is decoded and request uses JSON mode" do
    response = Net::HTTPOK.new("1.1", "200", "OK")
    response.define_singleton_method(:body) do
      { choices: [ { message: { content: { action: "needs_info", reply: "Tutar?" }.to_json } } ] }.to_json
    end
    captured = nil
    transport = ->(request) { captured = request; response }
    result = Agent::LlmClient.new(key: "test-key", transport: transport).call([ { "role" => "user", "content" => "Monitör" } ])
    assert_equal "needs_info", result.fetch("action")
    body = JSON.parse(captured.body)
    assert_equal "json_object", body.fetch("response_format").fetch("type")
    assert_includes body.fetch("messages").last.fetch("content"), "Monitör"
    assert_equal "Bearer test-key", captured["Authorization"]
  end

  test "provider errors and invalid JSON become controlled failures" do
    [ Net::HTTPTooManyRequests.new("1.1", "429", "Rate limited"), Net::HTTPOK.new("1.1", "200", "OK") ].each do |response|
      response.define_singleton_method(:body) { "invalid JSON" }
      transport = ->(_request) { response }
      assert_raises(Agent::LlmClient::Unavailable) do
        Agent::LlmClient.new(key: "test-key", transport: transport).call([])
      end
    end
  end
  test "network failures become controlled failures" do
    [ SocketError.new("DNS failed"), Net::ReadTimeout.new ].each do |error|
      transport = ->(_request) { raise error }
      assert_raises(Agent::LlmClient::Unavailable) do
        Agent::LlmClient.new(key: "test-key", transport: transport).call([])
      end
    end
  end
end
