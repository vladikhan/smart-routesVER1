# app/controllers/email_verification_controller.rb
class EmailVerificationController < ApplicationController
  before_action :authenticate_user!
  
  def resend
    if request.post?
      if current_user.confirmed?
        flash[:notice] = "メールアドレスは既に確認済みです"
      else
        current_user.send_confirmation_instructions
        flash[:notice] = "確認メールを再送信しました。メールをご確認ください。"
      end
      redirect_to root_path
    else
      # GET request - показываем форму
      render :resend
    end
  end
end