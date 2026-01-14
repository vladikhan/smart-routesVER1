class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true, counter_cache: true

  validates :user_id, uniqueness: { scope: %i[likeable_type likeable_id], message: 'すでにいいねしています' }

  after_create_commit :create_like_notification
  after_destroy_commit :remove_like_notification

  counter_culture :likeable, column_name: 'likes_count'

  private

  def create_like_notification
    return unless likeable.is_a?(Route)

    NotificationService.notify_route_liked(self)
  end

  def remove_like_notification
    NotificationService.remove_notification(self)
  end

  def increment_likes_count
    likeable.increment!(:likes_count) if likeable.respond_to?(:likes_count)
  end

  def decrement_likes_count
    likeable.decrement!(:likes_count) if likeable.respond_to?(:likes_count)
  end
end
