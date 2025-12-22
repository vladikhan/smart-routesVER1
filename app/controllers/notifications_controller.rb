# encoding: UTF-8
class NotificationsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:unread_count, :mark_as_read, :mark_all_as_read]

  def index
    @notifications = current_user.notifications
                                  .includes(:actor)
                                  .order(created_at: :desc)
                                  .page(params[:page])
                                  .per(20)
  end

  def unread_count
    @unread_count = current_user.notifications.unread.count
    render json: { unread_count: @unread_count }
  end

  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    
    if notification.update(is_read: true)
      redirect_url = notification_target_path(notification)
      
      respond_to do |format|
        format.html { redirect_to redirect_url }
        format.json { render json: { success: true, redirect_url: redirect_url } }
      end
    else
      respond_to do |format|
        format.html { redirect_back(fallback_location: notifications_path, alert: 'エラーが発生しました') }
        format.json { render json: { success: false, error: 'Failed to update' }, status: :unprocessable_entity }
      end
    end
  end

  def mark_all_as_read
    updated_count = current_user.notifications.where(is_read: false).update_all(is_read: true)
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path, notice: 'すべて既読にしました') }
      format.json { render json: { success: true, message: 'すべて既読にしました', updated_count: updated_count } }
    end
  end

  private

  def notification_target_path(notification)
    notifiable = notification.notifiable
    return root_path unless notifiable

    case notifiable
    when Route then route_path(notifiable)
    when Venue then venue_path(notifiable)
    when User then user_path(notifiable)
    else root_path
    end
  rescue
    root_path
  end
end