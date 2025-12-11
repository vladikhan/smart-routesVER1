class NotificationsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:mark_as_read, :mark_all_as_read, :unread_count]

  def index
    @notifications = current_user.notifications
                                  .includes(:actor)
                                  .order(created_at: :desc)
                                  .page(params[:page])
                                  .per(20)
  end

  def unread_count
    count = current_user.notifications.unread.count
    render json: { count: count, success: true }
  end

  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!
    
    respond_to do |format|
      format.html { redirect_to notification.target_url }
      format.json { 
        render json: { 
          success: true, 
          redirect_url: notification.target_url,
          unread_count: current_user.unread_notifications_count
        } 
      }
    end
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(is_read: true, read_at: Time.current)
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path, notice: 'すべて既読にしました') }
      format.json { render json: { success: true, message: 'すべて既読にしました', unread_count: 0 } }
    end
  end
end