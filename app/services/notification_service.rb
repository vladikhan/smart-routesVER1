class NotificationService
  # Route shared notification
  def self.notify_route_shared(route, actor, recipient)
    return if recipient.id == actor.id
    
    create_notification(
      user: recipient,
      actor: actor,
      notification_type: 'route_shared',
      entity_type: 'Route',
      entity_id: route.id
    )
  end

  # Route liked notification
  def self.notify_route_liked(route, actor)
    return if route.user_id == actor.id
    
    create_notification(
      user: route.user,
      actor: actor,
      notification_type: 'like',
      entity_type: 'Route',
      entity_id: route.id
    )
  end

  # New follower notification
  def self.notify_new_follower(follower, followed)
    return if follower.id == followed.id
    
    create_notification(
      user: followed,
      actor: follower,
      notification_type: 'follow',
      entity_type: 'User',
      entity_id: follower.id
    )
  end

  # Comment added notification
  def self.notify_comment_added(comment, route)
    return if route.user_id == comment.user_id
    
    create_notification(
      user: route.user,
      actor: comment.user,
      notification_type: 'comment',
      entity_type: 'Route',
      entity_id: route.id
    )
  end

  # Review added notification
  def self.notify_review_added(review)
    case review.reviewable_type
    when 'Route'
      route = review.reviewable
      return if route.user_id == review.user_id
      
      create_notification(
        user: route.user,
        actor: review.user,
        notification_type: 'review',
        entity_type: 'Route',
        entity_id: route.id
      )
    when 'Venue'
      # If venues have owners, notify them
      # For now, skip
    end
  end

  private

  def self.create_notification(user:, actor:, notification_type:, entity_type:, entity_id:)
    # Don't create duplicate notifications
    existing = Notification.find_by(
      user: user,
      actor: actor,
      notification_type: notification_type,
      entity_type: entity_type,
      entity_id: entity_id,
      created_at: 1.hour.ago..Time.current
    )
    
    return if existing
    
    Notification.create!(
      user: user,
      actor: actor,
      notification_type: notification_type,
      entity_type: entity_type,
      entity_id: entity_id,
      is_read: false
    )
  end
end