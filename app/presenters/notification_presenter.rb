class NotificationPresenter
  include Rails.application.routes.url_helpers

  def initialize(notification)
    @n = notification
    @actor_name = @n.actor&.username || '誰か'
  end

  def icon
    case @n.notification_type
    when 'like', 'route_liked' then '❤️'
    when 'comment', 'route_commented' then '💬'
    when 'follow' then '👤'
    when 'bookmark' then '🔖'
    when 'review', 'route_reviewed' then '⭐'
    when 'new_message' then '✉️'
    when 'new_post' then '📍'
    when 'mention' then '🔔'
    else '🔔'
    end
  end

  def message
    actor_name = @n.actor&.username || '誰か'
    target_name = get_target_name

    case @n.notification_type
    when 'new_message'
      "#{actor_name}さんからメッセージが届きました"

    when 'like', 'route_liked'
      if target_name
        "#{actor_name}さんがルート「#{target_name}」にいいねしました"
      else
        "#{actor_name}さんがあなたの投稿にいいねしました"
      end

    when 'comment', 'route_commented'
      if target_name
        "#{actor_name}さんがルート「#{target_name}」にコメントしました"
      else
        "#{actor_name}さんがコメントしました"
      end

    when 'follow'
      "#{actor_name}さんがあなたをフォローしました"

    when 'review', 'route_reviewed'
      if target_name
        "#{actor_name}さんがルート「#{target_name}」にレビューを投稿しました"
      else
        "#{actor_name}さんがレビューを投稿しました"
      end

    when 'new_post'
      if target_name
        "#{actor_name}さんが新しいルート「#{target_name}」を投稿しました"
      else
        "#{actor_name}さんが新しいルートを投稿しました"
      end

    when 'bookmark'
      if target_name
        "#{actor_name}さんがルート「#{target_name}」を保存しました"
      else
        "#{actor_name}さんがあなたのルートを保存しました"
      end

    when 'mention'
      "#{actor_name}さんがあなたをメンションしました"

    else
      "#{actor_name}さんから通知があります"
    end
  end

  def target_url
    return Rails.application.routes.url_helpers.root_path if @n.notifiable.nil?

    helpers = Rails.application.routes.url_helpers

    case notifiable_type
    when 'Route'
      helpers.route_path(notifiable)

    when 'Venue'
      helpers.venue_path(notifiable)

    when 'DmMessage'
      room_id = notifiable.respond_to?(:dm_room_id) ? notifiable.dm_room_id : nil
      room_id ? helpers.dm_room_path(room_id) : helpers.dm_rooms_path

    when 'Comment'
      target = notifiable.commentable
      if target.is_a?(Route)
        helpers.route_path(target, anchor: "comment-#{notifiable.id}")
      elsif target.is_a?(Venue)
        helpers.venue_path(target, anchor: "comment-#{notifiable.id}")
      else
        helpers.root_path
      end

    when 'Review'
      if notifiable.reviewable
        helpers.route_path(notifiable.reviewable, anchor: "review-#{notifiable.id}")
      else
        helpers.root_path
      end

    when 'Like'
      target = notifiable.likeable
      target.is_a?(Route) ? helpers.route_path(target) : helpers.root_path

    when 'User'
      helpers.user_path(notifiable)

    else
      helpers.root_path
    end
  rescue StandardError => e
    Rails.logger.error "❌ Notification URL error: #{e.message}"
    helpers.root_path
  end

  private

  def get_target_name
    case notifiable
    when Route, Venue
      notifiable.name
    when Comment
      notifiable.commentable&.name
    when Review
      notifiable.reviewable&.name
    when Like
      notifiable.likeable&.name
    when DmMessage
      notifiable.dm_room&.other_user(user)&.username
    else
      nil
    end
  rescue StandardError
    nil
  end
end