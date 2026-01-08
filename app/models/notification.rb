class Notification < ApplicationRecord
  belongs_to :actor, class_name: 'User'
  belongs_to :notifiable, polymorphic: true
  belongs_to :user

  validates :notification_type, presence: true
  validates :notifiable_type, presence: true
  validates :notifiable_id, presence: true

  enum notification_type: {
    follow: 0,
    like: 1,
    comment: 2,
    review: 3,
    new_message: 4,
    new_post: 5,
    bookmark: 6
  }

  scope :unread, -> { where(is_read: false) }
  scope :recent, -> { order(created_at: :desc) }

  def icon
    case notification_type
    when 'like'
      '❤️'
    when 'comment'
      '💬'
    when 'follow'
      '👤'
    when 'bookmark'
      '💾'
    when 'review'
      '⭐'
    else
      '🔔'
    end
  end

  def message
    I18n.t("notifications.messages.#{notification_type}",
           actor: actor.username,
           type: entity_type_japanese)
  rescue I18n::MissingTranslationData
    "#{actor.username}さんから通知があります"
  end

  def entity_type_japanese
    case entity_type
    when 'Route'
      'ルート'
    when 'Venue'
      '場所'
    when 'Review'
      'レビュー'
    when 'Comment'
      'コメント'
    else
      entity_type
    end
  end

  def target_url
    return Rails.application.routes.url_helpers.root_path if notifiable.nil?

    case notifiable_type
    when 'Route'
      Rails.application.routes.url_helpers.route_path(notifiable)
    when 'Venue'
      Rails.application.routes.url_helpers.venue_path(notifiable)
    when 'DmMessage'
      # Используем ID напрямую, чтобы не грузить весь объект комнаты из базы
      if notifiable.respond_to?(:dm_room_id)
        Rails.application.routes.url_helpers.dm_room_path(notifiable.dm_room_id)
      else
        '/'
      end
    when 'Comment'
      target = notifiable.commentable
      target.is_a?(Route) ? Rails.application.routes.url_helpers.route_path(target) : Rails.application.routes.url_helpers.venue_path(target)
    when 'User'
      Rails.application.routes.url_helpers.user_path(notifiable)
    else
      Rails.application.routes.url_helpers.root_path
    end
  rescue StandardError => e
    Rails.logger.error "Notification target_url error: #{e.message}"
    '/'
  end

  def mark_as_read!
    update(is_read: true, read_at: Time.current)
  end
end
