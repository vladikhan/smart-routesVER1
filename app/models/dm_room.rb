class DmRoom < ApplicationRecord
  # --- Associations ---
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'
  
  has_many :dm_messages, dependent: :destroy
  has_many :dm_room_members, dependent: :destroy # Убедись, что эта таблица тебе нужна при наличии sender/receiver

  has_one :last_message, -> { order(created_at: :desc) }, class_name: 'DmMessage'

  # --- Validations ---
  validates :sender_id, :receiver_id, presence: true
  validate :sender_and_receiver_are_different

  # --- Scopes ---
  scope :for_user, ->(user) { where('sender_id = ? OR receiver_id = ?', user.id, user.id) }
  
  # Используем Arel.sql для безопасности и COALESCE для правильной сортировки
  scope :recent, -> { order(Arel.sql('COALESCE(last_message_at, updated_at) DESC')) }

  # --- Class Methods ---
  def self.find_or_create_between(user_a_id, user_b_id)
    room = where(sender_id: user_a_id, receiver_id: user_b_id)
             .or(where(sender_id: user_b_id, receiver_id: user_a_id))
             .first

    room ||= create(sender_id: user_a_id, receiver_id: user_b_id)
    room
  end

  def self.for_user_with_preloads(user)
    for_user(user).includes(:sender, :receiver, :last_message).recent
  end

  # --- Instance Methods ---
  def other_user(user_to_compare)
    user_to_compare.id == sender_id ? receiver : sender
  end

  def participant?(user)
    return false if user.nil?
    sender_id == user.id || receiver_id == user.id
  end

  # --- Unread Messages Logic ---
  def unread_count_for(user)
    count = (user.id == sender_id ? unread_count_sender : unread_count_receiver)
    count.to_i
  end

  def any_unread_for?(user)
    unread_count_for(user) > 0
  end

  def increment_unread_for(user)
    return unless user
    # Если сообщение получил user, значит счетчик растет у него
    column = (user.id == sender_id) ? :unread_count_sender : :unread_count_receiver
    increment!(column)
  end

  def mark_all_as_read_for(user)
    # 1. Помечаем чужие сообщения как прочитанные
    dm_messages.where.not(user_id: user.id)
               .where(is_read: false)
               .update_all(is_read: true, read_at: Time.current, updated_at: Time.current)

    # 2. Сбрасываем счетчик конкретного пользователя
    reset_unread_for(user)
  end

  def reset_unread_for(user)
    column = (user.id == sender_id) ? :unread_count_sender : :unread_count_receiver
    update_columns(column => 0) 
  end

  private

  def sender_and_receiver_are_different
    errors.add(:base, 'You cannot chat with yourself') if sender_id == receiver_id
  end
end