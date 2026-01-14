class Follower < ApplicationRecord
  belongs_to :follower_user, class_name: 'User', foreign_key: 'follower_id'
  belongs_to :following_user, class_name: 'User', foreign_key: 'following_id'

  after_create_commit :increment_counters
  after_create_commit :create_follow_notification
  after_destroy_commit :decrement_counters
  after_destroy_commit :remove_follow_notifications

  private

  def increment_counters
    User.increment_counter(:following_count, follower_id)
    User.increment_counter(:followers_count, following_id)
  end

  def decrement_counters
    User.decrement_counter(:following_count, follower_id)
    User.decrement_counter(:followers_count, following_id)
  end

  def create_follow_notification
    NotificationService.create_notification(
      user: following_user,
      actor: follower_user,
      notification_type: :follow,
      notifiable: self
    )
  end

  def remove_follow_notifications
    Notification.where(
      notifiable_id: id,
      notifiable_type: 'Follower',
      notification_type: 'follow'
    ).destroy_all
  end
end
