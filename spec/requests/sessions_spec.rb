require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe 'GET /login' do
    it 'returns http success' do
      get new_user_session_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /login' do
    let(:user) { create(:user) }
    
    it 'logs in with valid credentials' do
      post user_session_path, params: {
        user: { email: user.email, password: 'password123' }
      }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'DELETE /logout' do
    let(:user) { create(:user) }
    
    it 'logs out' do
      sign_in user
      delete destroy_user_session_path
      expect(response).to have_http_status(:redirect)
    end
  end
end
