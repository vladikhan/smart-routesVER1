# app/controllers/notifications_controller.rb
class NotificationsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @notifications = current_user.notifications.order(created_at: :desc)
  end
  
  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.update(is_read: true)
    render json: { success: true }
  end
  
  def mark_all_as_read
    current_user.notifications.update_all(is_read: true)
    render json: { success: true }
  end
  
  def unread_count
    count = current_user.notifications.where(is_read: false).count
    render json: { count: count }
  end
end