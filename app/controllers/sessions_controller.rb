class Users::SessionsController < Devise::SessionsController
  def new
    self.resource = resource_class.new(sign_in_params)
    super
  end

  def create
    self.resource = warden.authenticate!(auth_options)
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: 'ログインしました
      '
    else
      flash.now[:alert] = '入力されたメールアドレスはアカウントにリンクされていません。アカウントを検索してログイン'
      render :new
    end
  end

  def logout_confirm

  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: 'ログアウトしました'
  end
end
