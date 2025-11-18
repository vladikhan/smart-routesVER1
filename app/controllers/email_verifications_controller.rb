class EmailVerificationsController < ApplicationController
  def new
    #Show verification code input page
    @user = User.find_by(id: session[:pending_user_id])

    if @user.nil?
      redirect_to login_path, alert: 'セッションが期限切れです。もう一度ログインしてください。'
    end
  end

  def verify
    @user = User.find_by(id: session[:pending_user_id])

    if@user.nil?
      redirect_to login_path, alert: 'セッションが期限切れです。'
      return
  end

  code = params[:verification_code]&.strip

  if @user.verification_code_valid?(code)
    @user.update(
      confirmed_at: Time.current,
      verification_code: nil,
      verification_code_sent_at: nil
    )

    session[:pending_user_id] = nil
    session[:user_id] = @user.id

    redirect_to root_path, notice: 'メールアドレスが確認されました！'
  else
    if @user.verification_code_expired?
      flash.now[:alert] = 'コードの有効期限が切れています。再送信してください。'
    else
      flash.now[:alert] = 'コードが正しくありません。もう一度入力してください。'
    end

    render :new
  end
end
  def resend
    @user = User.find_by(id: session[:pending_user_id])

    if @user.send_verification_code
      redirect_to email_verification_path, notice:  '確認コードを再送信しました。'
    else
      redirect_to login_path, alert: 'セッションが期限切れです。'
    end
  end 
end