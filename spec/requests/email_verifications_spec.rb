require 'rails_helper'

RSpec.describe 'EmailVerifications', type: :request do
  describe 'GET /email_verification' do
    it 'returns http success' do
      get email_verification_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /email_verification' do
    let(:user) { create(:user) }
    
    before { sign_in user }
    
    it 'verifies with valid code' do
      user.update(
        verification_code: '123456',
        verification_code_sent_at: Time.current
      )
      
      post email_verification_path, params: { code: '123456' }
      expect(response).to have_http_status(:redirect)
    end
  end
end
