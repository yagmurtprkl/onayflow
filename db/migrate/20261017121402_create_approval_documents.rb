class CreateApprovalDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :approval_documents do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :approver, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "draft"
      t.datetime :submitted_at
      t.datetime :decided_at
      t.datetime :due_at
      t.text :rejection_reason

      t.timestamps
    end

    add_index :approval_documents, %i[requester_id created_at]
    add_index :approval_documents, %i[approver_id status]
    add_check_constraint :approval_documents,
                         "status IN ('draft', 'pending', 'approved', 'rejected')",
                         name: "approval_documents_status_check"
    add_check_constraint :approval_documents,
                         "status != 'rejected' OR (rejection_reason IS NOT NULL AND LENGTH(TRIM(rejection_reason)) > 0)",
                         name: "approval_documents_rejection_reason_check"
  end
end
