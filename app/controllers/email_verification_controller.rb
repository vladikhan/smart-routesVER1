# app/controllers/email_verifications_controller.rb
class EmailVerificationsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:verify]
  
  def show
    # Показываем страницу подтверждения email
    render :show
  end
  
  def verify
    user = User.find_by(verification_code: params[:code])
    
    if user && user.verification_code_sent_at > 24.hours.ago
      user.update(email_verified: true, verification_code: nil)
      redirect_to root_path, notice: 'Email подтвержден!'
    else
      redirect_to root_path, alert: 'Неверный или истекший код'
    end
  end
end