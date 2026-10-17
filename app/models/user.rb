class User < ApplicationRecord
  has_secure_password

  enum :role, { employee: "employee", manager: "manager" }, default: :employee, validate: true

  has_many :requested_documents,
           class_name: "ApprovalDocument",
           foreign_key: :requester_id,
           inverse_of: :requester,
           dependent: :restrict_with_exception
  has_many :assigned_documents,
           class_name: "ApprovalDocument",
           foreign_key: :approver_id,
           inverse_of: :approver,
           dependent: :restrict_with_exception

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true, length: { maximum: 100 }
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP },
            length: { maximum: 255 }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
end
