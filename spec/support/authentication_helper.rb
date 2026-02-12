module AuthenticationHelper
  # NOTE: don't override Devise's `sign_in` integration helper.
  # Use this helper only when you explicitly want to sign in via HTTP POST.
  def sign_in_via_post(user)
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
