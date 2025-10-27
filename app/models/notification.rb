class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: 'User', optional: true
  belongs_to :entity, polymorphic: true, optional: true

  validates :notification_type, presence: true
  validates :notification_type, inclusion: {
    in: %w[follow like comment review message route_featured venue_approved]
  }
  # スコープ
  scope :unread, -> { where(is_read: false) }
  scope :recent, -> { order(created_at: :desc) }

  # メソッド
  def mark_as_read!
    update(is_read: true)

  end
end
