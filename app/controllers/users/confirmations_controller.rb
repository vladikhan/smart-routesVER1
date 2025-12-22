# encoding: utf-8
class Users::ConfirmationsController < Devise::ConfirmationsController
  
  def show
    super
  end

  protected

  # Куда редиректить после успешного подтверждения
  def after_confirmation_path_for(resource_name, resource)
    flash[:notice] = "メールアドレスが確認されました！"
    root_path # или new_user_session_path для логина
  end
end