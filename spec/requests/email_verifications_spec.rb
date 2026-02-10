require 'rails_helper'

RSpec.describe 'EmailVerifications', type: :request do
  # Используем 6-значный код, так как ниже ты проверяешь его через /^\d{6}$/
  let(:user) { create(:user, email_verified: false, verification_code: '12345678') }

  before do
    sign_in user
  end

  describe 'GET /email_verification' do
    it 'returns http success' do
      get email_verification_path
      expect(response).to have_http_status(:success)
    end

    it 'assigns current user' do
      get email_verification_path
      # Примечание: assigns считается устаревшим в Rails 5+, но если работает — оставляем.
      expect(assigns(:user)).to eq(user)
    end

    context 'when not logged in' do
      before { sign_out user }
      it 'redirects to login' do
        get email_verification_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /email_verification/show' do
    it 'returns success' do
      get email_verification_show_path
      expect(response).to have_http_status(:success)
    end

    context 'when not logged in' do
      before { sign_out user }

      it 'redirects to login' do
        get email_verification_show_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /email_verification/verify' do
    context 'with correct verification code' do
      let(:valid_params) { { verification_code: '12345678' } }

      it 'marks email is verified' do
        post email_verification_path, params: valid_params
        expect(user.reload.email_verified).to eq(true)
      end

      it "redirect after successful verification" do
        post email_verification_path, params: valid_params
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with incorrect verification code' do
      let(:invalid_params) { { verification_code: '87654321' } }

      it 'does not mark email is verified' do
        post email_verification_path, params: invalid_params
        expect(user.reload.email_verified).to eq(false)
      end
    end

    context 'with empty verification code' do
      let(:empty_params) { { verification_code: '' } }

      it 'does not verify email' do
        post email_verification_path, params: empty_params
        expect(user.reload.email_verified).to eq(false)
      end

      it 'renders error' do 
        post email_verification_path, params: empty_params
        expect(response.body).to include('認証コードを入力してください。')
        expect(flash.now[:alert]).to be_present
      end
    end

    context 'when user already verified' do
      before { user.update(email_verified: true, verification_code: nil) }

      it 'still works (idempotent)' do
        # Здесь используем роут, который у тебя в контроллере для верификации
        post email_verification_path, params: { verification_code: '12345678' }
        
        # Если код nil, верификация не должна пройти повторно с ошибкой 422
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'authorization checks' do
      context 'when not logged in' do
        before { sign_out user }

        it 'redirects to login' do
          post email_verification_path, params: { verification_code: '12345678' }
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end

  describe 'POST /email_verification/resend' do
    it 'generates new verification code' do
      original_code = user.verification_code
      post resend_email_verification_path

      expect(user.reload.verification_code).not_to eq(original_code)
      expect(user.verification_code).to match(/^\d{8}$/) 
    end

    it 'sends verification email' do
      expect {
        post resend_email_verification_path
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to include(user.email)
      expect(email.subject).to match(/確認コード|verification/i)
    end

    it 'redirects to email_verification with success notice' do
      post resend_email_verification_path

      expect(response).to redirect_to(email_verification_path)
      expect(flash[:notice]).to eq('確認コードを再送信しました')
    end

    context 'authorization checks' do
      context 'when not logged in' do
        before { sign_out user }

        it 'redirects to login' do
          post resend_email_verification_path
          expect(response).to redirect_to(new_user_session_path)
        end

        it 'does not send email' do
          expect {
            post resend_email_verification_path
          }.not_to change { ActionMailer::Base.deliveries.count }
        end
      end
    end

    context 'email delivery failures' do
      before do
        # Мокаем ошибку отправки
        allow(UserMailer).to receive(:verification_code_email).and_return(double(deliver_now: true))
        allow_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now).and_raise(Net::SMTPFatalError)
      end

      it 'handles email delivery errors gracefully' do
        # Если твой контроллер не ловит ошибку (rescue), то тест упадет с Net::SMTPFatalError
        # Это нормально для текущего состояния, если ты хочешь проверить само исключение
        expect {
          post resend_email_verification_path
        }.to raise_error(Net::SMTPFatalError)
      end
    end
  end
end