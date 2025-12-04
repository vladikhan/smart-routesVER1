class NotificationService
  def self.notify_route_liked(route, actor)
    return if route.user_id == actor.id

    Notification.create!(
      user: route.user,
      actor: actor,
      notification_type: 'like',
      entity_type: 'Route',
      entity_id: route.id,
      is_read: false
    )
  end

  def self.notify_route_shared(route, actor, recipient)
    return if recipient.id == actor.id

    Notification.create!(
      user: recipient,
      actor: actor,
      notification_type: 'route_shared',
      entity_type: 'Route',
      entity_id: route.id,
      is_read: false
    )
  end

  def self.notify_new_follower(follower, followed)
    Notification.create!(
      user: followed,
      actor: follower,
      notification_type: 'follow',
      entity_type: 'User',
      entity_id: follower.id,
      is_read: false
    )
  end

  def self.notify_comment_added(comment, actor, route)
    return if route.user_id == actor.id
    
    Notification.create!(
      user: route.user,
      actor: actor,
      notification_type: 'comment',
      entity_type: 'Route',
      entity_id: route.id,
      is_read: false
    )
  end

  def self.notify_review_added(review, actor)
    recipient = case review.reviewable_type
                when 'Route' then review.reviewable.user
                when 'Venue' then nil
              end
    return  unless recipient && recipient.id != actor.id

    Notification.create!(
      user: recipient,
      actor: actor,
      notification_type: 'review',
      entity_type: review.reviewable_type,
      entity_id: review.reviewable_id,
      is_read: false
    )
  end
end