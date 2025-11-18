class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # POST /signup
  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        # Email requires confirmation
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        
        # Send verification code
        session[:pending_user_id] = resource.id
        resource.send_verification_code
        
        # Redirect to verification page
        redirect_to email_verification_path, notice: '登録完了！確認コードをメールで送信しました。'
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  # Permit additional parameters for sign up
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :bio, :location, :budget_min, :budget_max])
  end

  # Permit additional parameters for account update
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :bio, :location, :budget_min, :budget_max])
  end

  # Redirect path after sign up
  def after_sign_up_path_for(resource)
    email_verification_path
  end

  # Redirect path for inactive users
  def after_inactive_sign_up_path_for(resource)
    email_verification_path
  end
end