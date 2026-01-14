class NotificationsController < ApplicationController
  before_action :authenticate_user!
  # skip_before_action :verify_authenticity_token, raise: false
  def index
    @notifications = current_user.notifications
                                 .includes(:actor, :notifiable)
                                 .order(created_at: :desc)
                                 .page(params[:page])
                                 .per(20)
  end

  def unread_count
    Rails.logger.info '=' * 80
    Rails.logger.info '🔍 NOTIFICATIONS DEBUG:'
    Rails.logger.info "  User authenticated: #{user_signed_in?}"
    Rails.logger.info "  Current user: #{current_user.inspect}"
    Rails.logger.info "  Session ID: #{session.id}"
    Rails.logger.info "  Cookies present: #{cookies.to_h.keys}"
    Rails.logger.info "  Request from: #{request.remote_ip}"
    Rails.logger.info '=' * 80
    # =====================================

    @unread_count = current_user.notifications.unread.count

    respond_to do |format|
      format.json do
        render json: {
          count: count,
          authenticated: true,
          user_id: current_user.id
        }
      end
    end
  rescue StandardError => e
    Rails.logger.error "❌ Error in unread_count: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    respond_to do |format|
      format.json { render json: { count: 0, error: e.message }, status: :internal_server_error }
      format.html { render json: { error: e.message }, status: :internal_server_error }
    end
  end

  def mark_as_read
    notification = current_user.notifications.find(params[:id])

    if notification.update(is_read: true)
      redirect_url = notification_target_path(notification)
      new_count = current_user.notifications.unread.count

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
rescue ActiveRecord::RecordNotFound
  respond_to do |format|
    format.html do
      redirect_to notifications_path, alert: '通知が見つかりません'
    end
    format.json do
      render json: {
        success: false,
        error: '通知が見つかりません'
      }, status: :not_found
    end
  end

  def mark_all_as_read
    updated_count = current_user.notifications.unread.count
    Notification.mark_all_as_read_for(current_user)

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path, notice: 'すべて既読にしました') }
      format.json { render json: { success: true, message: 'すべて既読にしました', updated_count: updated_count } }
    end
  end
rescue StandardError => e
  Rails.logger.error "❌ mark_all_as_read でエラーが発生しました: #{e.message}\n"

  respond_to do |format|
    format.html do
      redirect_back(fallback_location: notifications_path, alert: 'エラーが発生しました')
    end
    format.json do
      render json: {
        success: false,
        error: e.message
      }, status: :internal_server_error
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
  rescue StandardError => e
    Rails.logger.error "Error in notification_target_path: #{e.message}"
    root_path
  end
end
