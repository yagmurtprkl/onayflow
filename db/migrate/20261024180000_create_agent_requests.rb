class CreateAgentRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :agent_requests do |t|
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :approver, null: false, foreign_key: { to_table: :users }
      t.references :approval_document, foreign_key: true, index: { unique: true }
      t.string :state, null: false, default: "collecting"
      t.json :messages, null: false, default: []
      t.json :assessment, null: false, default: {}
      t.string :llm_model
      t.timestamps
    end
    add_check_constraint :agent_requests, "state IN ('collecting', 'submitted', 'handoff')", name: "agent_requests_state_check"
  end
end
