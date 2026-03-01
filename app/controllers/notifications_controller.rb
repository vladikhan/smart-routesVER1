class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    # 1. Сначала фильтруем (Scope logic)
    base_notifications = current_user.notifications.includes(:actor, :notifiable).recent

    @notifications = case params[:filter]
                     when 'messages'     then base_notifications.message_notifications
                     when 'interactions' then base_notifications.interaction_notifications
                     when 'follows'      then base_notifications.follow_notifications
                     else base_notifications 
                     end

    # 2. Берем только последние 50. Пагинация больше не нужна, если мы чистим базу.
    @notifications = @notifications.limit(50)

    # 3. Считаем непрочитанные ДО того, как пометим их прочитанными
    @unread_count = @notifications.select { |n| !n.is_read }.size

    # 4. Помечаем только ТЕ, что сейчас на экране, как прочитанные
    unread_ids = @notifications.reject(&:is_read).map(&:id)
    if unread_ids.any?
      current_user.notifications.where(id: unread_ids)
                  .update_all(is_read: true, read_at: Time.current)
    end
  end

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
  # Твоя логика пометки прочитанными
  Notification.mark_all_as_read_for(current_user)

  respond_to do |format|
    format.html { redirect_back(fallback_location: notifications_path) }
    format.json { render json: { success: true } } 
  end
end
end