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

    case @n.notifiable_type
    when 'Route'
      helpers.route_path(@n.notifiable)

    when 'Venue'
      helpers.venue_path(@n.notifiable)

    when 'DmMessage'
      room_id = @n.notifiable.respond_to?(:dm_room_id) ? @n.notifiable.dm_room_id : nil
      room_id ? helpers.dm_room_path(room_id) : helpers.dm_rooms_path

    when 'Comment'
      target = @n.notifiable.commentable
      if target.is_a?(Route)
        helpers.route_path(target, anchor: "comment-#{@n.notifiable.id}")
      elsif target.is_a?(Venue)
        helpers.venue_path(target, anchor: "comment-#{@n.notifiable.id}")
      else
        helpers.root_path
      end

    when 'Review'
      if @n.notifiable.reviewable
        helpers.route_path(@n.notifiable.reviewable, anchor: "review-#{@n.notifiable.id}")
      else
        helpers.root_path
      end

    when 'Like'
      target = @n.notifiable.likeable
      target.is_a?(Route) ? helpers.route_path(target) : helpers.root_path

    when 'User'
      helpers.user_path(@n.notifiable)

    else
      helpers.root_path
    end
  rescue StandardError => e
    Rails.logger.error "❌ Notification URL error: #{e.message}"
    helpers.root_path
  end

  private

  private

  def get_target_name
    case @n.notifiable
    when Route, Venue
      @n.notifiable.name
    when Comment
      @n.notifiable.commentable&.name
    when Review
      @n.notifiable.reviewable&.name
    when Like
      @n.notifiable.likeable&.name
    when DmMessage
      @n.notifiable.dm_room&.other_user(@n.user)&.username
    else
      nil
    end
  rescue StandardError => e
    Rails.logger.error "❌ get_target_name error: #{e.message}"
    nil
  end
end