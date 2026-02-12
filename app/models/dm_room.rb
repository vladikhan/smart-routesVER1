class DmRoom < ApplicationRecord
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'
  has_many :dm_messages, dependent: :destroy

  has_many :dm_room_members, dependent: :destroy

  has_one :last_message, -> { order(created_at: :desc) }, class_name: 'DmMessage'

  validates :sender_id, :receiver_id, presence: true
  validate :sender_and_receiver_are_different

  scope :for_user, lambda { |user|
    where('sender_id = ? OR receiver_id = ?', user.id, user.id)
  }
  scope :recent, lambda {
    order(Arel.sql('COALESCE(last_message_at, updated_at) DESC'))
  }

  def self.find_or_create_between(user_a_id, user_b_id)
  room = where(sender_id: user_a_id, receiver_id: user_b_id)
         .or(where(sender_id: user_b_id, receiver_id: user_a_id))
         .first

  # Используем create! чтобы увидеть ошибку, если валидация не прошла
  room ||= create!(sender_id: user_a_id, receiver_id: user_b_id)
  
  room
end

  def other_user(user_to_compare)
    user_to_compare.id == sender_id ? receiver : sender
  end

  def increment_unread_for(user)
    return unless user
    column = (user.id == sender.id) ? :unread_count_sender : :unread_count_receiver

    self.increment!(column)
  end

  def unread_count_for(user)
    (user.id == sender_id ? unread_count_sender || 0 : unread_count_receiver || 0).to_i
  end

  def any_unread_for?(user)
    unread_count_for(user) > 0
  end

  def mark_all_as_read_for(user)
    # 1. Помечаем сообщения прочитанными (только чужие)
    # Используем update_all для скорости
    dm_messages.where.not(user_id: user.id)
              .where(is_read: false)
              .update_all(is_read: true, read_at: Time.current, updated_at: Time.current)

    # 2. Сбрасываем счетчик. 
    # ВАЖНО: используй update_columns, чтобы это сразу улетело в SQL 
    # и не вызывало лишних коллбэков, которые могут всё испортить.
    if sender_id == user.id
      update_columns(unread_count_sender: 0)
    else
      update_columns(unread_count_receiver: 0)
    end
  end

  def reset_unread_for(user)
    column = (user.id == sender_id) ? :unread_count_sender : :unread_count_receiver
    update_columns(column => 0) 
  end

  def self.for_user_with_preloads(user)
    for_user(user).includes(:sender, :receiver).recent
  end

  def participant?(user)
    return false if user.nil?
    sender.id == user.id ||receiver_id == user.id
  end

  private

  def sender_and_receiver_are_different
    errors.add(:base, 'You cannot chat with yourself') if sender_id == receiver_id
  end
end
