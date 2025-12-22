module ControllerHelpers
  def sign_in_user
    @user ||= create(:user)
    sign_in @user
    @user
  end
end

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include ControllerHelpers, type: :controller
end