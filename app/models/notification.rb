class Notification < ApplicationRecord
  belongs_to :user  # recipient
  belongs_to :actor, class_name: 'User'

  validates :notification_type, presence: true, inclusion: { 
    in: %w[follow like comment review route_shared] 
  }

  scope :unread, -> { where(is_read: false) }
  scope :read, -> { where(is_read: true) }
  scope :recent, -> { order(created_at: :desc) }

  after_create_commit :broadcast_notification

  def mark_as_read!
    return if is_read?
    update(is_read: true, read_at: Time.current)
  end

  def unread?
    !is_read?
  end

  def notifiable
    return nil unless entity_type && entity_id
    entity_type.constantize.find_by(id: entity_id)
  end

  def target_url
    case notification_type
    when 'route_shared', 'like'
      notifiable ? "/routes/#{notifiable.id}" : '/'
    when 'comment', 'review'
      notifiable ? "/routes/#{notifiable.id}#reviews" : '/'
    when 'follow'
      actor ? "/users/#{actor.id}" : '/'
    else
      '/'
    end
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
      "#{actor.username}さんがあなたをフォローしました"
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
    NotificationChannel.broadcast_to(
      user,
      {
        notification: {
          id: id,
          message: message,
          icon: icon,
          target_url: target_url,
          created_at: created_at.iso8601,
          is_read: is_read,
          actor: {
            id: actor.id,
            username: actor.username,
            avatar_url: actor.avatar.present? ? actor.avatar.thumb.url : nil
          }
        },
        unread_count: user.unread_notifications_count
      }
    )
  end
end