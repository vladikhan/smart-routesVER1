# app/controllers/notifications_controller.rb
class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications
                                 .includes(:actor, :notifiable)
                                 .recent

    @unread_count = current_user.notifications.where(is_read: false).count

    # Фильтрация
    case params[:filter]
    when 'messages'
      @notifications = @notifications.message_notifications
    when 'interactions'
      @notifications = @notifications.interaction_notifications
    when 'follows'
      @notifications = @notifications.follow_notifications
    end

    @notifications = @notifications.page(params[:page]).per(20)
    def unread_count
      puts "Checking notifications for User: #{current_user.id}"

      # Проверяем вообще все уведомления этого юзера
      all_count = current_user.notifications.count
      unread_count = current_user.notifications.where(is_read: false).count

      puts "DEBUG: All: #{all_count}, Unread: #{unread_count}"

      render json: { count: unread_count, authenticated: true }
    end
  end

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!

    redirect_url = @notification.target_url

    respond_to do |format|
      format.html { redirect_to redirect_url }
      format.json do
        render json: {
          success: true,
          redirect_url: redirect_url,
          unread_count: current_user.notifications.unread.count
        }
      end
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to notifications_path, alert: '通知が見つかりません'
  end

  def mark_all_as_read
    Notification.mark_all_as_read_for(current_user)

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path, notice: 'すべて既読にしました') }
      format.json { render json: { success: true, unread_count: 0 } }
    end
  end

  def unread_count
    render json: {
      count: current_user.notifications.unread.count,
      authenticated: true
    }
  end
end
