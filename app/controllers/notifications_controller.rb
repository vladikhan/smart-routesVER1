# encoding: UTF-8
class NotificationsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:unread_count]

  def index
    @notifications = current_user.notifications
                                  .includes(:actor)
                                  .order(created_at: :desc)
                                  .page(params[:page])
                                  .per(20)
  end

  def unread_count
    count = current_user.notifications.where(is_read: false).count
    
    respond_to do |format|
      format.json { render json: { count: count, success: true } }
    end
  end

  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.update(is_read: true)
    
    redirect_to notification_target_path(notification)
  end

  def mark_all_as_read
    current_user.notifications.where(is_read: false).update_all(is_read: true)
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path, notice: 'すべて既読にしました') }
      format.js   { head :ok }
      format.json { render json: { success: true, message: 'すべて既読にしました' } }
    end
  end

  private

  def notification_target_path(notification)
    notifiable = notification.notifiable
    return root_path unless notifiable

    case notifiable
    when Route then route_path(notifiable)
    when Venue then venue_path(notifiable)
    when Review
      notifiable.reviewable.is_a?(Route) ? route_path(notifiable.reviewable) : root_path
    when User then user_path(notifiable)
    else root_path
    end
  rescue ActiveRecord::RecordNotFound
    root_path
  end
end