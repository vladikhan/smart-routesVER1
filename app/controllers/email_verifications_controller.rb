class EmailVerificationsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  def new
    # Если токена нет в параметрах, мы не можем показать страницу
    if params[:confirmation_token].present?
      @user = User.find_by!(confirmation_token: params[:confirmation_token])
    else
      redirect_to new_user_session_path, alert: "メールアドレス確認メールを送信しました"
    end
  end

  def show
  end

  def verify
    

    @user = User.find_by(confirmation_token: params[:confirmation_token])
    code = params[:verification_code].to_s.strip

    if @user && @user.verification_code.present? && @user.verification_code.to_s == code

      @user.update(email_verified: true, verification_code: nil)
      @user.confirm if !@user.confirmed?

      sign_in(@user)

      redirect_to root_path, notice: 'メールアドレスが確認されました'
    else

    
      @user ||= User.new
      flash.now[:alert] = '認証コードを入力してください。'
      render :new, status: :unprocessable_entity
    end
  end

  def resend

    @user = User.find_by(confirmation_token: params[:confirmation_token])
    
    if @user.nil?
      return redirect_to new_user_session_path, alert: 'セッションが切れました。再度ログインしてください'
    end

    if @user
      code = SecureRandom.random_number(1_000_000_00).to_s.rjust(8, '0')

      @user.update(
        verification_code: code,
        verification_code_sent_at: Time.current
      )
  
      begin
        UserMailer.verification_code_email(@user).deliver_now
        # Обязательно return!
        redirect_to email_verification_path(confirmation_token: @user.confirmation_token), notice: '確認コードを再送信しました'
        return 
      rescue Net::SMTPFatalError
        redirect_to email_verification_path(confirmation_token: @user.confirmation_token), alert: 'メールの送信に失敗しました'
        return
      end

    else
      redirect_to new_user_session_path, alert: 'セッションが切れました。再度ログインしてください'
    end
  end
end
