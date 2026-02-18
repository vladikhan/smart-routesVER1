ENV['RAILS_ENV'] ||= 'test'

# In docker-compose, `DATABASE_URL` is set for development (smart_routes_dev).
# Rails prefers `DATABASE_URL` over `config/database.yml`, even in test mode.
# Force a dedicated test database URL so RSpec doesn't purge the dev DB.
if ENV['RAILS_ENV'] == 'test'
  ENV['DATABASE_URL'] = ENV.fetch('TEST_DATABASE_URL', 'postgres://postgres:password@db:5432/smartroutes_test')
end

require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'shoulda/matchers'

# 1. Настройка DatabaseCleaner (особенно важно для Docker/CI)
DatabaseCleaner.allow_remote_database_url = true

# 2. Подключение support-файлов
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# 3. Проверка миграций
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

# 4. Гарантированная загрузка фабрик (защита от дублирования)
if FactoryBot.factories.count == 0
  FactoryBot.find_definitions
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  
  # Используем transactional fixtures, но DatabaseCleaner дает более тонкий контроль
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # --- Helpers ---
  config.include FactoryBot::Syntax::Methods
  config.include ActiveSupport::Testing::TimeHelpers


  
  # Devise Helpers (для контроллеров и системных тестов)
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system

  # ActionCable Helpers
  config.include ActionCable::TestHelper, type: :channel

  # --- DatabaseCleaner Strategy ---
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction

  end

  # Для тестов через браузер (JS: true) или feature-тестов нужна транзакция truncation
  config.before(:each, type: :feature) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # --- Localization ---
  config.before(:each) do
    Time.zone = 'Tokyo'
    Faker::Config.locale = 'ja'
  end
end

# 5. Настройка Shoulda Matchers
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
