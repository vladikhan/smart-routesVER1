class DmMessage < ApplicationRecord
  belongs_to :dm_room, touch: true
  belongs_to :user

  has_one_attached :image

  validates :message, presence: true, length: { maximum: 5000 }, unless: -> { image.attached? }

  # コールバック
  after_create_commit :update_room_timestamp
  after_create_commit :increment_unread_count
  after_create_commit :broadcast_message
  after_create_commit :create_notification

  scope :unread, -> { where(is_read: false) }

  def mark_as_read
    update_columns(is_read: true, read_at: Time.current)
  end

  private

  def update_room_timestamp
    dm_room.update(last_message_at: created_at)
  end

  def increment_unread_for(user)
    if user.id == sender_id
      increment!(:unread_count_sender)
    else
      increment!(:unread_count_receiver)
    end
  end

  def broadcast_message
    ActionCable.server.broadcast(
      "dm_room_#{dm_room.id}",
      {
        user_id: user.id,
        html: ApplicationController.render(
          partial: 'dm_messages/message',
          locals: { message: self, current_user: nil }
        )
      }
    )
  end

  def create_notification
    receiver = dm_room.other_user(user)
    return unless receiver

    Notification.create!(
      user_id: receiver.id,
      actor_id: user.id,
      entity_type: 'DmMessage',
      entity_id: id,
      notification_type: 'new_message'
    )
  end
end
