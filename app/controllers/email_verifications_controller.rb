class EmailVerificationsController < ApplicationController
  before_action :authenticate_user!
  def new
    @user = current_user
  end

  def show
  end

  def verify
    code = params[:verification_code]

    if current_user.verification_code == code
      current_user.update(email_verified: true, verification_code: nil)
      redirect_to root_path, notice: 'メールアドレスが確認されました'
    else
      flash.now[:alert] = '確認コードが正しくありません'
      render :new, status: :unprocessable_entity
    end
  end

  def resend
    code = SecureRandom.random_number(1_000_000).to_s.rjust(6, '0')
    current_user.update(
      verification_code: code,
      verification_code_sent_at: Time.current
    )

    UserMailer.verification_code_email(current_user).deliver_now

    redirect_to email_verification_path, notice: '確認コードを再送信しました'
  end
end
