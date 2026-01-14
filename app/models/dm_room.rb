class DmRoom < ApplicationRecord
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'
  has_many :dm_messages, dependent: :destroy

  validates :sender_id, presence: true
  validates :receiver_id, presence: true
  validate :sender_and_receiver_are_different
  validate :prevent_duplicate_room, on: :create

  scope :for_user, lambda { |user|
    where('sender_id = ? OR receiver_id = ?', user.id, user.id)
  }
  scope :recent, lambda {
    order(Arel.sql('COALESCE(last_message_at, updated_at) DESC'))
  }
  scope :with_unread_for, lambda { |user|
    where('(sender_id = ? AND unread_count_sender > 0) OR (receiver_id = ? AND unread_count_receiver > 0)',
          user.id, user.id)
  }

  def self.between(user1_id, user2_id)
    u1, u2 = [user1_id.to_i, user2_id.to_i].sort
    where(sender_id: u1, receiver_id: u2).first_or_create!
  end

  def self.find_or_create_between(user1, user2)
    between(user1.id, user2.id)
    room = where(
      '(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)', user1.id, user2.id, user2.id, user1.id
    ).first

    room ||= create!(sender_id: user1.id, receiver_id: user2.id)
    room
  end

  def other_user(current_user)
    current_user.id == sender_id ? receiver : sender
  end

  def last_message
    dm_messages.order(created_at: :desc).first
  end

  def unread_count_for(user)
    (user.id == sender_id ? unread_count_sender || 0 : unread_count_receiver || 0).to_i
  end

  def any_unread_for?(user)
    unread_count_for(user) > 0
  end

  def participant?(user)
    sender_id == user.id || receiver_id == user.id
  end

  def increment_unread_for(sender)
    if sender.id == sender_id
      increment!(:unread_count_receiver)
    else
      increment!(:unread_count_sender)
    end
  end

  def mark_all_as_read_for(user)
    unread_messages = dm_messages
                      .where(is_read: false)
                      .where.not(user_id: user.id)

    unread_messages.find_each do |message|
      message.mark_as_read!
    end

    reset_unread_for(user)

    Rails.logger.info "ユーザー #{user.id} のルーム #{id} において、#{unread_messages.count} 件のメッセージを既読としてマークしました"
  end

  def reset_unread_for(user)
    if user.id == sender_id
      update_columns(unread_count_sender: 0)
    elsif user.id == receiver_id
      update_columns(unread_count_receiver: 0)
    end
  end

  def self.for_user_with_preloads(user)
    for_user(user)
      .includes(:sender, :receiver, dm_messages: [:user])
      .recent
  end

  private

  def sender_and_receiver_are_different
    errors.add(:base, 'You cannot chat with yourself') if sender_id == receiver_id
  end

  def prevent_duplicate_room
    existing = DmRoom.where(
      '(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)',
      sender_id, receiver_id, receiver_id, sender_id
    ).exists?

    return unless existing

    errors.add(:base, 'このユーザーとのチャットルームは既に存在します')
  end
end
