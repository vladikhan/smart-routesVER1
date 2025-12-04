# encoding: UTF-8
class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications
                                    .includes(:actor)
                                    .recent
                                    .page(params[:page])
                                    .per(20)
  end

  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!

    redirect_to notification_path(notification)
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(is_read: true)
    redirect_back(fallback_location: notifications_path, notice: 'すべて既読にしました')
  end

  private

  def notification_path(notification)
    notifiable = notification.notifiable
    return root_path unless notifiable

    case notifiable 
    when Route
      route_path(notifiable)
    when Venue
      venue_path(notifiable)
    when Review
      route_path(notifiable.reviewable) if notifiable.reviewable.is_a?(Route)
    when User
      user_path(notifiable)
    else
      root_path
    end
  end
end