class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_email_verification, unless: :devise_controller?
  before_action :set_notifications, if: :user_signed_in?
  before_action :prepare_notifications, if: :user_signed_in?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[username email])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[username bio location])
  end

  def check_email_verification
    return unless user_signed_in?
    # Не редиректим, если запрос JSON или JS (например, unread_count)
    return if request.format.json? || request.format.js?

    if !current_user.email_verified? &&
       !%w[email_verifications confirmations sessions].include?(controller_name)
      redirect_to email_verification_path, alert: 'メールアドレスの確認が必要です。'
    end
  end

  def set_notifications
    return unless request.format.html?
    @notifications = Notification::Operation::Recent.call(current_user: current_user)[:model]
  end

  def prepare_notifications
    # includes(:actor, :notifiable) убирает сотни запросов к БД
    @header_notifications = current_user.notifications
                                        .includes(:actor, :notifiable)
                                        .recent
                                        .limit(8)
    @unread_notifications_count = current_user.unread_notifications_count
  end

  def set_global_notifications
    @global_notifications = current_user.notifications
                                        .includes(:actor, :notifiable)
                                        .recent
                                        .limit(8)
  end
end
