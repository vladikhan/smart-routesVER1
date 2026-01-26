class DmMessage < ApplicationRecord
  belongs_to :dm_room, touch: true
  belongs_to :user

  has_one_attached :image

  validates :message, presence: true, length: { maximum: 5000 }, unless: -> { image.attached? }
  validate :must_have_content

  # コールバック
  after_create_commit :update_room_timestamp
  after_create_commit :increment_unread_for
  after_create_commit :broadcast_message
  after_create_commit :create_notification

  scope :unread, -> { where(is_read: false) }
  scope :unread_by, ->(user) { where(is_read: false).where.not(user_id: user.id) }
  scope :recent, -> { order(created_at: :desc) }

  def mark_as_read!
    update!(is_read: true, read_at: Time.current)
    update_columns(is_read: true, read_at: Time.current)
    update_notifications_status
  end

  def receiver
    dm_room.other_user(user)
  end

  def sender
    user
  end

  private

  def must_have_content
    return unless message.blank? && !image.attached?

    errors.add(:base, 'メッセージまたは画像を添付してください。')
  end

  def update_room_timestamp
    dm_room.update(last_message_at: created_at)
  end

  def increment_unread_for
    if dm_room.sender_id == user_id
      dm_room.increment!(:unread_count_receiver)
    else
      dm_room.increment!(:unread_count_sender)
    end
  end

  def broadcast_message
    return unless defined?(ActionCable)

    ActionCable.server.broadcast(
      "dm_room_#{dm_room.id}",
      {
        user_id: user.id,
        html: ApplicationController.render(
          partial: 'dm_messages/message',
          locals: { message: self, user: user }
        )
      }
    )
  end

  def create_notification
    target_user = receiver
    return unless target_user

    notification = Notification.create!(
      user: target_user,
      actor: user,
      notifiable: self,
      notification_type: 'new_message',
      is_read: false
    )

    Rails.logger.info "Notification created: ID=#{notification.id}"
  rescue StandardError => e
    Rails.logger.error "Ошибка создания уведомления: #{e.message}"
  end

  def update_notifications_status
    # Ищем уведомление через полиморфную связь
    notification = Notification.find_by(
      notifiable: self,
      notification_type: 'new_message'
    )

    return unless notification && !notification.is_read?

    # Исправил read: true на is_read: true согласно структуре твоей базы
    notification.update(is_read: true, read_at: Time.current)
  end
end
