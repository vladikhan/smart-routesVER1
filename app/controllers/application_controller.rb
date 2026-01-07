class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_email_verification, unless: :devise_controller?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[username email])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[username bio location])
  end

  def check_email_verification
    if user_signed_in? && !current_user.email_verified? &&
       controller_name != 'email_verifications' &&
       controller_name != 'confirmations'

      redirect_to email_verification_path, alert: 'メールアドレスの確認が必要です。'
    end
  end
end
