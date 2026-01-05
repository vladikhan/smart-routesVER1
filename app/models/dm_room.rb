class DmRoom < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  has_many :dm_messages, dependent: :destroy

  validates :sender_id, uniqueness: { scope: :receiver_id }
  validate :sender_and_receiver_are_different

  def self.between(user1_id, user2_id)
    where(
      '(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)',
      user1_id, user2_id, user2_id, user1_id
    ).first_or_create(sender_id: user1_id, receiver_id: user2_id)
  end

  # Get another chatuser for current user
  def other_user(current_user)
    current_user.id == sender_id ? receiver : sender
  end

  # Get last message
  def last_message
    dm_messages.order(created_at: :desc).first
  end
end
