class Follower < ApplicationRecord
  belongs_to :follower_user, class_name: 'User', foreign_key: 'follower_id'
  belongs_to :following_user, class_name: 'User', foreign_key: 'following_id'

  after_create_commit :increment_counters
  after_create_commit
  after_destroy_commit :decrement_counters
  after_destroy_commit :remove_follow_notifications

  validates :follower_id, presence: true
  validates :following_id, presence: true
  validates :follower_id, uniqueness: { scope: :following_id }
  validate :cannot_follow_self

  def self.notify_new_follower(follower, followed)
    return if follower.id == followed.id

    create_notification(
      user: followed,
      actor: follower,
      notification_type: :follow,
      notifiable: Relationship.find_by(follower: follower, following: followed) # Передаем объект связи
    )
  end

  private

  def cannot_follow_self
    errors.add(:follower_id, '自分自身をフォローすることはできません') if follower_id == following_id
  end

  def increment_counters
    User.increment_counter(:following_count, follower_id)
    User.increment_counter(:followers_count, following_id)
  end

  def decrement_counters
    User.decrement_counter(:following_count, follower_id)
    User.decrement_counter(:followers_count, following_id)
  end

  def remove_follow_notifications
    NotificationService.remove_notification(self)
  end
end
