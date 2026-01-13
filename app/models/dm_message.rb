class DmMessage < ApplicationRecord
  belongs_to :dm_room, touch: true
  belongs_to :user

  has_one_attached :image

  validates :message, presence: true, length: { maximum: 5000 }, unless: -> { image.attached? }

  # コールバック
  after_create_commit :update_room_timestamp
  after_create_commit :increment_unread_for
  # after_create_commit :broadcast_message
  # after_create_commit :create_notification

  scope :unread, -> { where(is_read: false) }
  scope :unread_by, ->(user) { where(is_read: false).where.not(user_id: user.id) }

  def mark_as_read
    update_columns(is_read: true, read_at: Time.current)
  end

  private

  def update_room_timestamp
    dm_room.update(last_message_at: created_at)
  end

  def increment_unread_for
    receiver = dm_room.sender_id == user_id ? dm_room.receiver : dm_room.sender

    if dm_room.sender_id == user_id
      dm_room.increment!(:unread_count_receiver)
    else
      dm_room.increment!(:unread_count_sender)
    end
  end

  # def broadcast_message
  # ActionCable.server.broadcast(
  #  "dm_room_#{dm_room.id}",
  # {
  #  user_id: user.id,
  # html: ApplicationController.render(
  #  partial: 'dm_messages/message',
  # locals: { message: self, current_user: nil }
  #      )
  #   }
  # )
  # end

  def create_notification
    receiver = dm_room.other_user(user)
    return unless receiver

    Notification.create!(
      user_id: receiver.id,
      actor_id: user.id,
      notifiable: self,
      notification_type: 'new_message'
    )
  end
end
