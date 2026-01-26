class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true

  validates :user_id, uniqueness: { scope: %i[likeable_type likeable_id], message: 'すでにいいねしています' }

  after_create_commit :create_like_notification
  after_destroy_commit :remove_like_notification

  counter_culture :likeable, column_name: 'likes_count'

  scope :recent, -> { order(created_at: :desc) }

  private

  def create_like_notification
    return if likeable.user_id == user_id

    NotificationService.notify_route_liked(self)
  end

  def remove_like_notification
    NotificationService.remove_notification(self)
  end
end
