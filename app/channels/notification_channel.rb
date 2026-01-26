class NotificationChannel < ApplicationCable::Channel
  def subscribed
    # Stream notifications for the current user
    stream_from "notification_#{current_user.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
