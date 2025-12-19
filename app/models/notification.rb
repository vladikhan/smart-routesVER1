# encoding: utf-8
class Notification < ApplicationRecord
  belongs_to :user  # recipient
  belongs_to :actor, class_name: 'User'

  def target_url
    case entity_type
    when 'Route'
      "/routes/#{entity_id}"
    when 'Venue'
      "/venues/#{entity_id}"
    when 'Review'
      review = Review.find_by(id: entity_id)
      if review&.reviewable_type == 'Route'
        "/routes/#{review.reviewable_id}"
      elsif review&.reviewable_type == 'Venue'
        "/venues/#{review.reviewable_id}"
      else
        "/"
      end
    else 
      "/"
    end
  end

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
  
  # Alias for compatibility
  def mark_as_read
    mark_as_read!
  end

  def unread?
    !is_read?
  end

  def notifiable
    return nil unless entity_type && entity_id
    entity_type.constantize.find_by(id: entity_id)
  end

  def message
    I18.t("notifications.messages.#{notification_type}",
          actor: actor.username,
          type: enrity_type_japanese)
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
    I18n.t("notifications.entity_types.#{entity_type}", default: "コンテンツ")
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
  rescue => e
    Rails.logger.error "Failed to broadcast notification: #{e.message}"
  end
end