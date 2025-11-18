# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/veridication_code_email
  def veridication_code_email
    UserMailer.veridication_code_email
  end

end
