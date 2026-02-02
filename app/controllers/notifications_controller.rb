class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications
                                 .includes(:actor, :notifiable)
                                 .recent

    @notifications = case params[:filter]
                     when 'messages'     then @notifications.message_notifications
                     when 'interactions' then @notifications.interaction_notifications
                     when 'follows'      then @notifications.follow_notifications
                     else @notifications 
                     end

    @notifications = @notifications.page(params[:page]).per(20)

    @unread_count = @notifications.where(is_read: false).count
  end

  # Этот метод должен быть один!
  def unread_count
    render json: { 
      count: current_user.notifications.where(is_read: false).count, 
      authenticated: true 
    }
  end

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!

    redirect_url = @notification.target_url

    respond_to do |format|
      format.html { redirect_to redirect_url }
      format.json { render json: { success: true, redirect_url: redirect_url } }
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to notifications_path, alert: '通知が見つかりません'
  end

  def mark_all_as_read
    Notification.mark_all_as_read_for(current_user)
    redirect_back(fallback_location: notifications_path, notice: 'すべて既読にしました')
  end
end