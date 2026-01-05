class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token, raise: false
  skip_before_action :verify_authenticity_token, raise: false
  skip_before_action :verify_authenticity_token, raise: false
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :bio, :location])
  end
end
