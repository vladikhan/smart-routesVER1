module RequestMacros
  def login_user
    user = FactoryBot.create(:user)
    sign_in user
    user
  end
end

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include RequestMacros, type: :request
end
