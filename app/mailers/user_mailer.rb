class UserMailer < ApplicationMailer
  default from: 'noreply@smartroutes.com'

  def verification_code_email(user)
    @user = user
    @code = user.veification_code
    @expiry_minutes = User::VERIFICATION_CODE_EXPIRY / 1.minute

    mail(
    to: @user.email,
    subject: '[Smart Routes] メールアドレス確認コード'
    )
  end
end
