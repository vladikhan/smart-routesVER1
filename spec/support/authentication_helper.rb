module AuthenticationHelper
  def sign_in(user)
    post user_session_path, params: {
      user: {
        email: user.email,
        password: user.password || 'password123'
      }
    }
  end
end

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include AuthenticationHelper, type: :request
end
