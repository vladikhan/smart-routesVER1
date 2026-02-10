class EmailVerificationsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  def new
    # Если токена нет в параметрах, мы не можем показать страницу
    if params[:confirmation_token].present?
      @user = User.find_by!(confirmation_token: params[:confirmation_token])
    else
      redirect_to new_user_session_path, alert: "有効なトークンが見つかりません"
    end
  end

  def show
  end

  def verify
    @user = User.find_by(confirmation_token: params[:confirmation_token])
    code = params[:verification_code].to_s.strip

    if @user && @user.verification_code.to_s == code
      @user.update(email_verified: true, verification_code: nil)
      @user.confirm if !@user.confirmed?
      sign_in(@user)

      redirect_to root_path, notice: 'メールアドレスが確認されました'
    else

      puts "DEBUG: User code in DB: #{@user&.verification_code.inspect}"
    puts "DEBUG: Input code: #{input_code.inspect}"
    
      @user ||= User.new
      flash.now[:alert] = '確認コードが正しくありません'
      render :new, status: :unprocessable_entity
    end
  end

  def resend

    @user = User.find_by(confirmation_token: params[:confirmation_token])

    if @user
      code = SecureRandom.random_number(1_000_000).to_s.rjust(6, '0')

      @user.update(
        verification_code: code,
        verification_code_sent_at: Time.current
      )
  
      UserMailer.verification_code_email(@user).deliver_now
  
      redirect_to email_verification_path(confirmation_token: @user.confirmation_token), notice: '確認コードを再送信しました'
    else

      redirect_to new_user_session_path, alert: 'セッションが切れました。再度ログインしてください'  
    end
  end
end
