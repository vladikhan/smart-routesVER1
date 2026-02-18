class DmMessage < ApplicationRecord
  belongs_to :dm_room, touch: true
  belongs_to :user

  after_create :update_room_stats

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

  def update_room_stats
    dm_room.update_columns(last_message_at: Time.current)

    receiver = (user_id == dm_room.sender_id) ? :unread_count_receiver : :unread_count_sender
    dm_room.increment!(receiver)
  end
end
