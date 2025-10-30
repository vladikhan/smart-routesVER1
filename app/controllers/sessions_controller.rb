class SessionsController < ApplicationController
  def new
  end

  def create
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
