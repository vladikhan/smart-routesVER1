class Users::SessionsController < Devise::SessionsController
#before_action :configure_sign_in_params, only: [:create]

  # GET /login
  def new
    super
  end

  # POST /login
  def create
    super
  end

  #DELETE /logout
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    yield if block_given?
    respond_to_on_destroy
  end

  protected

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  end
end