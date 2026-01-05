class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    self.resource = resource_class.find_by_confirmation_token(params[:confirmation_token])

    if resource.present?
      redirect_to your_otp_page_path(confirmation_token: params[:confirmation_token])
    else
      super
    end

    protected

    def after_confirmation_path_for(resource_name, resource)
      flash[:notice] = 'メールアドレスが確認されました！'
      root_path
    end
  end
end
