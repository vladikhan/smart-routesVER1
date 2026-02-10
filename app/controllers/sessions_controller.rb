class SessionsController < Devise::SessionsController
  skip_before_action :check_email_verification, only: %i[create new]

  def create
  # 1. Сначала проверяем, существует ли пользователь вообще
  user = User.find_by(email: params[:user][:email])
  
  if user.nil?
    flash.now[:alert] = '入力されたメールアドレスはアカウントにリンクされていません。'
    self.resource = resource_class.new(sign_in_params)
    return render :new # Выходим раньше, чтобы не мучить Warden
  end

  # 2. Если юзер есть, отдаем всё на откуп Devise
  # Он сам проверит пароль, подтверждение email и т.д.
  super
end

  def logout_confirm
  end

  def destroy
    Session::Operation::Logout.call(controller: self)
    redirect_to root_path, notice: 'ログアウトしました'
  end
end
