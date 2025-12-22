require 'rails_helper'

RSpec.describe RoutesController, type: :controller do
  describe "Devise authentication test" do
    let(:user) { create(:user) }
    
    it "sign_in должен работать" do
      sign_in user
      expect(controller.current_user).to eq(user)
    end
  end
end
