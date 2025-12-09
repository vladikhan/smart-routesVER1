class Notification < ApplicationRecord
  belongs_to :user  # recipient
  belongs_to :actor, class_name: 'User'

  validates :notification_type, presence: true, inclusion: { 
    in: %w[follow like comment review route_shared] 
  }

  scope :unread, -> { where(is_read: false) }
  scope :read, -> { where(is_read: true) }
  scope :recent, -> { order(created_at: :desc) }

  # Broadcast to user after creation
  after_create_commit :broadcast_notification

  def mark_as_read!
    update(is_read: true) unless is_read?
  end

  def unread?
    !is_read?
  end

  def notifiable
    return nil unless entity_type && entity_id
    entity_type.constantize.find_by(id: entity_id)
  end

  def message
    case notification_type
    when 'route_shared'
      "#{actor.username}さんがルートをシェアしました"
    when 'like'
      "#{actor.username}さんがあなたの#{entity_type_japanese}にいいねしました"
    when 'comment'
      "#{actor.username}さんがコメントしました"
    when 'review'
      "#{actor.username}さんがレビューを投稿しました"
    when 'follow'
      "#{actor.username}さんがフォローしました"
    else
      "新しい通知があります"
    end
  end

  def icon
    case notification_type
    when 'route_shared' then '📤'
    when 'like' then '❤️'
    when 'comment' then '💬'
    when 'review' then '⭐'
    when 'follow' then '👤'
    else '🔔'
    end
  end

  private

  def entity_type_japanese
    case entity_type
    when 'Route' then 'ルート'
    when 'Venue' then '場所'
    when 'Review' then 'レビュー'
    else 'コンテンツ'
    end
  end

  def broadcast_notification
    # Broadcast to the user's notification channel
    NotificationChannel.broadcast_to(
      user,
      {
        notification: {
          id: id,
          message: message,
          icon: icon,
          created_at: created_at,
          is_read: is_read
        },
        unread_count: user.notifications.unread.count
      }
    )
  end
end
