require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'factory_bot_rails'
require 'faker'
require 'database_cleaner/active_record'
require 'simplecov'

SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
end

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

DatabaseCleaner.allow_remote_database_url = true

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  #Factory Bot
  config.include FactoryBot::Syntax::Methods

  #Database Cleaner
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.before(:all) do
    # Укажите любой тестовый хост и порт.
    # В реальных условиях можно использовать 'example.com' или 'localhost:3000'.
    Rails.application.routes.default_url_options[:host] = 'localhost:3000'
  end

  #Devise helpers
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
require 'support/devise'

RSpec.configure do |config|

  config.use_transactional_fixtures = true

  

  config.before(:suite) do

    DatabaseCleaner.clean_with(:truncation)

  end

  config.before(:each) do

    DatabaseCleaner.strategy = :transaction

  end

  config.before(:each, js: true) do

    DatabaseCleaner.strategy = :truncation

  end

  config.before(:each) do

    DatabaseCleaner.start

  end

  config.after(:each) do

    DatabaseCleaner.clean

  end

end

