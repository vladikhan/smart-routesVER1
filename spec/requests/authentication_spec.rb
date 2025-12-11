require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  let(:user) { create(:user) }
  
  describe 'POST /login' do
    context '有効な認証情報' do
      it 'ログインできる' do
        post user_session_path, params: {
          user: {
            email: user.email,
            password: 'password123'
          }
        }
        expect(response).to have_http_status(:redirect)
      end
    end
    
    context '無効な認証情報' do
      it 'ログインできない' do
        post user_session_path, params: {
          user: {
            email: user.email,
            password: 'wrong_password'
          }
        }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('無効')
      end
    end
  end
  
  describe 'DELETE /logout' do
    before { sign_in user }
    
    it 'ログアウトできる' do
      delete destroy_user_session_path
      expect(response).to have_http_status(:redirect)
    end
  end
end