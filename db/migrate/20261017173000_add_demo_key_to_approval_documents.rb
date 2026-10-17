class AddDemoKeyToApprovalDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :approval_documents, :demo_key, :string
    add_index :approval_documents, :demo_key, unique: true
  end
end
