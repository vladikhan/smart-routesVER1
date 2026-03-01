class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true
  belongs_to :actor, class_name: 'User', optional: true

  validates :notification_type, :user_id, presence: true

  enum notification_type: {
    follow: 'follow', 
    follow_request: 'follow_request',
    like: 'like', 
    comment: 'comment', 
    review: 'review',
    new_message: 'new_message', 
    new_post: 'new_post', 
    bookmark: 'bookmark',
    route_liked: 'route_liked', 
    route_commented: 'route_commented',
    route_reviewed: 'route_reviewed', 
    mention: 'mention'
  }, _prefix: :type

  scope :unread, -> { where(is_read: false) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user_id: user.id) }
  scope :message_notifications, -> { where(notification_type: 'new_message') }
  scope :interaction_notifications, -> { where(notification_type: ['like', 'comment', 'route_liked', 'route_commented']) }
  scope :follow_notifications, -> { where(notification_type: 'follow') }

  def mark_as_read!
    update!(is_read: true, read_at: Time.current)
  end

  def target_url
  helpers = Rails.application.routes.url_helpers
  
  case notification_type
  when 'new_message'
    # Используем &. (safe navigation), чтобы не упасть, если notifiable пропал
    room_id = notifiable&.dm_room_id
    room_id ? helpers.dm_room_path(room_id) : helpers.dm_rooms_path
  when 'follow'
    helpers.user_path(actor_id)
  when 'like', 'new_route'
    # Если маршрут удалили, отправляем на главную
    notifiable.present? ? helpers.route_path(notifiable_id) : helpers.routes_path
  else
    helpers.root_path
  end
rescue => e
  Rails.logger.error "Notification target_url error: #{e.message}"
  "/"
end

  def self.mark_all_as_read_for(user)
  user.notifications.where(is_read: false).update_all(is_read: true, read_at: Time.current)
end

  def icon
    case notification_type
    when 'like' then '❤️'
    when 'new_message' then '💬'
    when 'follow' then '👤'
    else '🔔'
    end
  end
end