require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  let(:user) { create(:user, password: 'password123', password_confirmation: 'password123') }
  
  describe 'POST /login' do
    context '有効な認証情報' do
      it 'ログインできる' do
        post user_session_path, params: {
          user: { email: user.email, password: 'password123' }
        }
        expect(response).to have_http_status(:redirect)
      end
    end
    
    context '無効な認証情報' do
      it 'ログインできない' do
        post user_session_path, params: {
          user: { email: user.email, password: 'wrong' }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
