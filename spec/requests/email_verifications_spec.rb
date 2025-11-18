require 'rails_helper'

RSpec.describe "EmailVerifications", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/email_verifications/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /verify" do
    it "returns http success" do
      get "/email_verifications/verify"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /resend" do
    it "returns http success" do
      get "/email_verifications/resend"
      expect(response).to have_http_status(:success)
    end
  end

end
