class DmMessage < ApplicationRecord
  belongs_to :dm_room, touch: true
  belongs_to :user

  has_one_attached :image

  validates :message, presence: true, length: { maximum: 5000 }, unless: -> { image.attached? }
  validate :must_have_content

  scope :unread, -> { where(is_read: false) }
  scope :unread_by, ->(user) { where(is_read: false).where.not(user_id: user.id) }
  scope :recent, -> { order(created_at: :desc) }

  def mark_as_read!
    update_columns(is_read: true, read_at: Time.current)
    update_notifications_status
  end

  private

  def must_have_content
    return unless message.blank? && !image.attached?

    errors.add(:base, 'メッセージまたは画像を添付してください。')
  end

  def update_notifications_status
    # Ищем уведомление через полиморфную связь
    notification = Notification.find_by(
      notifiable: self,
      notification_type: 'new_message'
    )
    notification&.update(is_read: true, read_at: Time.current) if notification && !notification.is_read?
  end
end
