class PlaceOwner < ApplicationRecord
  belongs_to :user
  belongs_to :venue

  enum role: { owner: 'owner', manager: 'manager', staff: 'staff' }, _prefix: :role
  enum status: { pending: 'pending', approved: 'approved', rejected: 'rejected' }, _prefix: :status


  validates :user_id, uniqueness: { scope: :venue_id, message: "すでに申請済みです" }
  validates :role, inclusion: { in: %w[owner manager staff] }
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

end
