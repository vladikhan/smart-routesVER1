class DmRoom < ApplicationRecord
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'
  has_many :dm_messages, dependent: :destroy

  validates :sender_id, uniqueness: { scope: :receiver_id }
  validate :sender_and_receiver_are_different

  # Твой оригинальный метод с сортировкой ID
  def self.between(user1_id, user2_id)
    u1, u2 = [user1_id.to_i, user2_id.to_i].sort
    where(sender_id: u1, receiver_id: u2).first_or_create!
  end

  def self.find_or_create_between(user1, user2)
    between(user1.id, user2.id)
  end

  def other_user(current_user)
    current_user.id == sender_id ? receiver : sender
  end

  def last_message
    dm_messages.order(created_at: :desc).first
  end

  def unread_count_for(user)
    (user.id == sender_id ? unread_count_sender : unread_count_receiver).to_i
  end

  def any_unread_for?(user)
    unread_count_for(user) > 0
  end

  def participant?(user)
    sender_id == user.id || receiver_id == user.id
  end

  def reset_unread_for(user)
    if user.id == sender_id
      update_columns(unread_count_sender: 0)
    elsif user.id == receiver_id
      update_columns(unread_count_receiver: 0)
    end
  end

  def increment_unread_for(sender)
    if sender.id == sender_id
      increment!(:unread_count_receiver)
    else
      increment!(:unread_count_sender)
    end
  end

  private

  def sender_and_receiver_are_different
    errors.add(:base, 'You cannot chat with yourself') if sender_id == receiver_id
  end
end
