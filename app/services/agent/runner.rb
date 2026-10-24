module Agent
  class Runner
    class InvalidMessage < StandardError; end
    class Closed < StandardError; end
    FIELDS = %w[title purpose amount currency needed_on].freeze

    def initialize(client: LlmClient.new)
      @client = client
    end

    def call(request, message:)
      text = message.to_s.strip
      raise InvalidMessage if text.blank? || text.length > 4000

      request.with_lock do
        return request if request.submitted?
        raise Closed if request.handoff?
        raise InvalidMessage if request.messages.size >= 40

        request.append_message("user", text)
        begin
          result = validate_result!(@client.call(request.messages))
          request.llm_model = @client.model
          request.assessment = result
          request.append_message("assistant", result.fetch("reply"))
          case result.fetch("action")
          when "ready" then submit!(request, result)
          when "handoff" then request.state = "handoff"
          end
        rescue LlmClient::Unavailable
          request.state = "handoff"
          request.assessment = { "action" => "handoff", "reason" => "service_unavailable" }
          request.append_message("assistant", "LLM hizmetine ulaşılamadı veya geçerli yanıt alınamadı. Talebiniz seçtiğiniz yöneticiye devredildi; henüz onay belgesi oluşturulmadı.")
        end
        request.save!
      end
      request
    end

    private

    def validate_result!(result)
      raise LlmClient::Unavailable unless result.is_a?(Hash)
      raise LlmClient::Unavailable unless %w[needs_info ready handoff].include?(result["action"])
      raise LlmClient::Unavailable unless result["reply"].is_a?(String) && result["reply"].strip.present? && result["reply"].length <= 4000

      if result["action"] == "ready"
        valid = FIELDS.all? { |field| result[field].present? }
        valid &&= result["title"].is_a?(String) && result["title"].length <= 200
        valid &&= %w[purpose currency needed_on rationale].all? { |field| result[field].is_a?(String) && result[field].length <= 4000 }
        valid &&= result["missing_fields"] == [] && %w[normal urgent].include?(result["urgency"])
        valid &&= result["amount"].is_a?(Numeric) && result["amount"].positive? && result["amount"].finite?
        begin
          valid &&= Date.iso8601(result["needed_on"]) >= Date.current
        rescue Date::Error, TypeError
          valid = false
        end
        raise LlmClient::Unavailable unless valid
      end
      result.slice("action", "reply", "title", "purpose", "amount", "currency", "needed_on", "urgency", "rationale", "missing_fields")
    end

    def submit!(request, result)
      content = [ result.fetch("purpose"),
                  "Tutar: #{result.fetch('amount')} #{result.fetch('currency')}",
                  "İhtiyaç tarihi: #{result.fetch('needed_on')}",
                  "Agent değerlendirmesi: #{result.fetch('urgency')} — #{result.fetch('rationale')}",
                  "Bu değerlendirme yöneticinin kararı değildir. Onay süresi gönderimden itibaren 48 saattir." ].join("\n\n")
      document = ApprovalDocument.create!(requester: request.requester, approver: request.approver,
                                          title: result.fetch("title"), content: content)
      document.submit!(actor: request.requester)
      request.approval_document = document
      request.state = "submitted"
    end
  end
end
