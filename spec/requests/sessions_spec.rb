require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe 'GET /login' do
    it 'returns http success' do
      get new_user_session_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /login' do
    let(:user) { create(:user, password: 'password123', password_confirmation: 'password123') }

    context 'with valid credentials' do
      it 'logs in and redirects' do
        post user_session_path, params: {
          user: { email: user.email, password: 'password123' }
        }
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid password' do
      it 'does not log in and re-renders new' do
        post user_session_path, params: {
          user: { email: user.email, password: 'wrongpassword' }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with unknown email' do
      it 'does not log in' do
        post user_session_path, params: {
          user: { email: 'unknown@example.com', password: 'password123' }
        }
        expect(response).not_to have_http_status(:redirect)
      end
    end
  end

  describe 'DELETE /logout' do
    let(:user) { create(:user) }

    it 'logs out and redirects' do
      sign_in user
      delete destroy_user_session_path
      expect(response).to have_http_status(:redirect)
    end
  end
end
