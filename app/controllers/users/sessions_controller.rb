class Users::SessionsController < Devise::SessionsController
  # GET /login
  def new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    yield resource if block_given?
    respond_with(resource, serialize_options(resource))
  end

  # POST /login
  def create
    self.resource = warden.authenticate!(auth_options)
    
    # Check if email is confirmed
    unless resource.confirmed?
      # Store user id in session
      session[:pending_user_id] = resource.id
      
      # Send verification code
      resource.send_verification_code
      
      # Redirect to verification page
      redirect_to email_verification_path
      return
    end
    
    # If confirmed, sign in normally
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end
end