class SessionsController < Devise::SessionsController
  skip_before_action :check_email_verification, only: %i[create new]

  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  rescue StandardError
    flash.now[:alert] = '入力されたメールアドレスはアカウントにリンクされていません。'
    self.resource = resource_class.new(sign_in_params)
    render :new
  end

  def logout_confirm
  end

  def destroy
    Session::Operation::Logout.call(controller: self)
    redirect_to root_path, notice: 'ログアウトしました'
  end
end
