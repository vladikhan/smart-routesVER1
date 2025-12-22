require 'rails_helper'

RSpec.describe 'EmailVerifications', type: :request do
  let (:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /email_verification' do
    it 'returns http success' do
      get email_verification_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /email_verification' do
    it "redirect after successful verification" do
      post email_verification_path
      expect(response).to have_http_status(:redirect)
    end
  end
end
