class NotificationService
  # --- Сообщения (DM) ---
  def self.notify_new_message(dm_message)
    # Используем метод комнаты, чтобы найти получателя
    receiver = dm_message.dm_room.other_user(dm_message.user)
    return unless receiver

    create_notification(
      user: receiver,
      actor: dm_message.user,
      notification_type: :new_message,
      notifiable: dm_message
    )
    Rails.logger.info "✅ Notification: new_message for user #{receiver.id}"
  rescue StandardError => e
    Rails.logger.error "❌ Failed notify_new_message: #{e.message}"
  end

  # --- Лайки ---
  def self.notify_route_liked(like)
    route = like.likeable
    actor = like.user

    return if route.user_id == actor.id

    create_notification(
      user: route.user,
      actor: actor,
      notification_type: :like,
      notifiable: route
    )
  end

  # --- Подписки ---
  def self.notify_new_follower(follower, followed)
    return if follower.id == followed.id

    create_notification(
      user: followed,
      actor: follower,
      notification_type: :follow,
      notifiable: follower # Юзер, который подписался
    )
  end

  # --- Комментарии ---
  def self.notify_comment_added(comment)
    target = comment.commentable
    recipient = target.respond_to?(:user) ? target.user : nil

    return if recipient.nil? || recipient.id == comment.user_id

    create_notification(
      user: recipient,
      actor: comment.user,
      notification_type: :comment,
      notifiable: comment
    )
  end

  # --- Отзывы ---
  def self.notify_review_added(review)
    return unless review.reviewable.is_a?(Route)

    recipient = review.reviewable.respond_to?(:user) ? review.reviewable.user : nil

    return if recipient.nil? || review.user_id == recipient.id

    create_notification(
      user: recipient,
      actor: review.user,
      notification_type: :review,
      notifiable: review
    )
  end

  # --- Массовые уведомления (например, новый пост всем подписчикам) ---
  def self.notify_new_route_from_following(route)
    followers = route.user.followers
    return if followers.empty?

    notifications = followers.map do |follower|
      {
        user_id: follower.id,
        actor_id: route.user_id,
        notifiable_type: 'Route',
        notifiable_id: route.id,
        notification_type: Notification.notification_types[:new_post],
        is_read: false,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    Notification.insert_all(notifications)
    Rails.logger.info "✅ Bulk notifications for route #{route.id}"
  end

  def self.create_notification(params)
    user = params[:user]
    actor = params[:actor]
    notification_type = params[:notification_type]
    notifiable = params[:notifiable]

    return if Notification.exists?(
      user: user,
      actor: actor,
      notification_type: notification_type,
      notifiable: notifiable,
      created_at: 1.hour.ago..Time.current
    )

    notification = Notification.create!(params)

    ActionCable.server.broadcast("notifications_#{user.id}", {
                                   unread_count: user.unread_notifications_count,
                                   notification: {
                                     id: notification.id,
                                     message: notification.message,
                                     icon: notification.icon,
                                     url: notification.target_url,
                                     time: 'たった今'
                                   }
                                 })
  end

  def self.remove_notification(notifiable)
    notification = Notification.find_by(
      notifiable: notifiable
    )
    notification&.destroy
  end
end
