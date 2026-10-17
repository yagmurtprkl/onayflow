# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_10_17_173000) do
  create_table "approval_documents", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.integer "requester_id", null: false
    t.integer "approver_id", null: false
    t.string "status", default: "draft", null: false
    t.datetime "submitted_at"
    t.datetime "decided_at"
    t.datetime "due_at"
    t.text "rejection_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "demo_key"
    t.index ["approver_id", "status"], name: "index_approval_documents_on_approver_id_and_status"
    t.index ["approver_id"], name: "index_approval_documents_on_approver_id"
    t.index ["demo_key"], name: "index_approval_documents_on_demo_key", unique: true
    t.index ["requester_id", "created_at"], name: "index_approval_documents_on_requester_id_and_created_at"
    t.index ["requester_id"], name: "index_approval_documents_on_requester_id"
    t.check_constraint "status != 'rejected' OR (rejection_reason IS NOT NULL AND LENGTH(TRIM(rejection_reason)) > 0)", name: "approval_documents_rejection_reason_check"
    t.check_constraint "status IN ('draft', 'pending', 'approved', 'rejected')", name: "approval_documents_status_check"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "employee", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.check_constraint "role IN ('employee', 'manager')", name: "users_role_check"
  end

  add_foreign_key "approval_documents", "users", column: "approver_id"
  add_foreign_key "approval_documents", "users", column: "requester_id"
end
