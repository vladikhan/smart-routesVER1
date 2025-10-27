class PlaceOwner < ApplicationRecord
  belongs_to :user
  belongs_to :venue

  validates :user_id, uniqueness: { scope: :venue_id, message: "すでに申請済みです" }
  validates :role, inclusion: { in: %w[owner manager staff] }
  validates :status, inclusion: { in: %w[pending approved rejected] }
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> {contact_email.present? }

  # スコープ
  scope :pending, -> { where(status: 'pending') }
  scope :approved, -> { where(status: 'approved') }

  # コールバック
  after_update :update_venue_claimed_status, if: :saved_change_to_status?

  private

  def update_venue_claimed_status
    if approved?
      venue.update(is_claimed: true, claimed_at: Time.current)
    end
  end

  def approved?
    status == 'approved'
  end
end
