class DmRoom < ApplicationRecord
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'
  has_many :dm_messages, dependent: :destroy

  has_one :last_message, -> { order(created_at: :desc) }, class_name: 'DmMessage'

  validates :sender_id, :receiver_id, presence: true
  validate :sender_and_receiver_are_different

  scope :for_user, lambda { |user|
    where('sender_id = ? OR receiver_id = ?', user.id, user.id)
  }
  scope :recent, lambda {
    order(Arel.sql('COALESCE(last_message_at, updated_at) DESC'))
  }

  def other_user(current_user)
    current_user.id == sender_id ? receiver : sender
  end

  def unread_count_for(user)
    (user.id == sender_id ? unread_count_sender || 0 : unread_count_receiver || 0).to_i
  end

  def any_unread_for?(user)
    unread_count_for(user) > 0
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
    column = (user.id == sender_id) ? :unread_count_sender : :unread_count_receiver
    update_columns(column => 0) 
  end

  def self.for_user_with_preloads(user)
    for_user(user).includes(:sender, :receiver).recent
  end

  private

  def sender_and_receiver_are_different
    errors.add(:base, 'You cannot chat with yourself') if sender_id == receiver_id
  end
end
