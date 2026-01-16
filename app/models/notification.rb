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
    route_commented: 'route_commented',
    route_reviewed: 'route_reviewed',
    mention: 'mention'
  }

  # === Scopes ===
  scope :unread, -> { where(is_read: false) }
  scope :read_list, -> { where(is_read: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user_id: user.id) }
  scope :message_notifications, -> { where(notification_type: :new_message) }

  # === Методы иконки и текста ===
  def icon
    case notification_type.to_sym
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
    actor_name = actor&.username || '誰か'

    case notification_type.to_sym
    when :new_message
      "#{actor_name}さんからメッセージが届きました"
    when :route_liked, :like
      target_name = get_notifiable_name
      target_name ? "#{actor_name}さんがルート「#{target_name}」にいいねしました" : "#{actor_name}さんがあなたの投稿にいいねしました"
    when :route_commented, :comment
      target_name = get_notifiable_name
      target_name ? "#{actor_name}さんがルート「#{target_name}」にコメントしました" : "#{actor_name}さんがあなたの投稿にコメントしました"
    when :follow
      "#{actor_name}さんがあなたをフォローしました"
    when :review, :route_reviewed
      target_name = get_notifiable_name
      target_name ? "#{actor_name}さんがルート「#{target_name}」にレビューを投稿しました" : "#{actor_name}さんがレビューを投稿しました"
    when :new_post
      "#{actor_name}さんが新しいルート「#{notifiable.name}」を投稿しました" if notifiable.is_a?(Route)
    when :bookmark
      "#{actor_name}さんがあなたのルートを保存しました"
    else
      "#{actor_name}さんから通知があります"
    end
  end

  def target_url
    return Rails.application.routes.url_helpers.root_path if notifiable.nil?

    helpers = Rails.application.routes.url_helpers

    case notifiable_type
    when 'Route'
      helpers.route_path(notifiable)
    when 'Venue'
      helpers.venue_path(notifiable)
    when 'DmMessage'
      room_id = notifiable.respond_to?(:dm_room_id) ? notifiable.dm_room_id : nil
      room_id ? helpers.dm_room_path(room_id) : '#'
    when 'Comment'
      target = notifiable.commentable
      target.is_a?(Route) ? helpers.route_path(target) : helpers.venue_path(target)
    when 'User'
      helpers.user_path(notifiable)
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

  def self.unread_count_for(user)
    unread.for_user(user).count
  end

  private

  def get_notifiable_name
    if notifiable.respond_to?(:name)
      notifiable.name
    elsif notifiable.respond_to?(:likeable) && notifiable.likeable.respond_to?(:name)
      notifiable.likeable.name
    elsif notifiable.respond_to?(:commentable) && notifiable.commentable.respond_to?(:name)
      notifiable.commentable.name
    elsif notifiable.respond_to?(:reviewable) && notifiable.reviewable.respond_to?(:name)
      notifiable.reviewable.name
    elsif notifiable.respond_to?(:route) && notifiable.route.respond_to?(:name)
      notifiable.route.name
    end
  end
end
