require 'rails_helper'

RSpec.describe RoutesController, type: :controller do
  let(:user) { create(:user) }
  
  describe "GET #new" do
    before do
      puts "User ID: #{user.id}"  
      puts "User: #{user.inspect}"
      sign_in user
      puts "Current user after sign_in: #{controller.current_user.inspect}" 
    end
    
    it "показывает страницу" do
      get :new
      puts "Response status: #{response.status}"  
      puts "Response location: #{response.location}"
      expect(response).to have_http_status(:success)
    end
  end
end