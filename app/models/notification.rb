class Notification < ApplicationRecord
  # === Ассоциации ===
  belongs_to :user
  belongs_to :actor, class_name: 'User', optional: true
  belongs_to :notifiable, polymorphic: true # Объект (DmMessage, Route, и т.д.)

  # === Валидации ===
  validates :notification_type, presence: true
  validates :user_id, presence: true
  validates :notifiable_type, presence: true
  validates :notifiable_id, presence: true

  # === Enum  ===
  enum notification_type: {
    follow: 'follow',
    like: 'like',
    comment: 'comment',
    review: 'review',
    new_message: 'new_message',
    new_post: 'new_post',
    bookmark: 'bookmark',
    route_liked: 'route_liked',
    route_commented: 'route_commented'
  }

  # === Scopes ===
  scope :unread, -> { where(is_read: false) }
  scope :read_list, -> { where(is_read: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user_id: user.id) }
  scope :message_notifications, -> { where(notification_type: :new_message) }

  # === Методы иконки и текста ===
  def icon
    case notification_type
    when 'like', 'route_liked' then '❤️'
    when 'comment', 'route_commented' then '💬'
    when 'follow' then '👤'
    when 'bookmark' then '💾'
    when 'review' then '⭐'
    when 'new_message' then '✉️'
    else '🔔'
    end
  end

  def message
    notification_text
  end

  def notification_text
    case notification_type.to_sym
    when :new_message
      "#{actor&.username || '誰か'}さんからメッセージが届きました"
    when :route_liked, :like
      "#{actor&.username || '誰か'}さんがあなたのルートにいいねしました"
    when :route_commented, :comment
      "#{actor&.username || '誰か'}さんがあなたのルートにコメントしました"
    when :follow
      "#{actor&.username || '誰か'}さんがあなたをフォローしました"
    when :review
      "#{actor&.username || '誰か'}さんがあなたの場所をレビューしました"
    when :new_post
      "#{actor&.username || '誰か'}さんが新しいルートを投稿しました"
    else
      "#{actor&.username || '誰か'}さんから通知があります"
    end
  end

  def target_url
    return Rails.application.routes.url_helpers.root_path if notifiable.nil?

    helpers = Rails.application.routes.url_helpers

    case notifiable_type
    when 'Route'
      Rails.application.routes.url_helpers.route_path(notifiable)
    when 'Venue'
      Rails.application.routes.url_helpers.venue_path(notifiable)
    when 'DmMessage'
      room_id = notifiable.respond_to?(:dm_room_id) ? notifiable.dm_room_id : nil
      room_id ? Rails.application.routes.url_helpers.dm_room_path(room_id) : '#'
    when 'Comment'
      target = notifiable.commentable
      target.is_a?(Route) ? Rails.application.routes.url_helpers.route_path(target) : Rails.application.routes.url_helpers.venue_path(target)
    when 'User'
      Rails.application.routes.url_helpers.user_path(notifiable)
    when 'Follower'
      actor ? helpers.user_path(actor) : helpers.root_path
    when 'Review'
      if notifiable&.reviewable
        helpers.route_path(notifiable.reviewable, anchor: "review-#{notifiable.id}")
      else
        helpers.root_path
      end
    end
  rescue StandardError => e
    Rails.logger.error "❌ Notification URL error: #{e.message}"
    '#'
  end

  def mark_as_read!
    return if is_read?

    update!(is_read: true, read_at: Time.current)
  end

  def mark_as_unread!
    update!(is_read: false, read_at: nil)
  end

  def self.mark_all_as_read_for(user)
    unread.for_user(user).update_all(is_read: true, read_at: Time.current)
  end

  def self.unread_cont_for(user)
    unread.for_user(user).count
  end
end
