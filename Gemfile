source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.1.4'

# --- Основное ---
gem 'bootsnap', '>= 1.4.4', require: false
gem 'jbuilder', '~> 2.7'
gem 'pg'
gem 'puma', '~> 5.0'
gem 'rails', '~> 6.1.7', '>= 6.1.7.6'
gem 'turbolinks', '~> 5'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'webpacker', '~> 5.0'

# --- Redis & Sidekiq (Для очередей и кэша) ---
gem 'redis', '~> 5.0'
gem 'redis-namespace'
gem 'redis-rails'
gem 'sidekiq', '~> 6.4'

# --- Архитектура Trailblazer (Корпоративный стандарт) ---
gem 'reform-rails'
gem 'trailblazer-cells'
gem 'trailblazer-rails'

# --- Аутентификация и безопасность ---
gem 'bcrypt', '~> 3.1.7'
gem 'devise'
gem 'devise-i18n'

# --- Загрузка файлов и AWS ---
gem 'asset_sync'
gem 'aws-sdk-s3', require: false
gem 'carrierwave', '~> 2.2'
gem 'fog-aws'
gem 'mime-types'
gem 'mini_magick', '~> 4.11'

# --- Frontend & UI ---
gem 'bootstrap', '~> 5.3'
gem 'html2slim' # Поможет тебе конвертировать старые файлы
gem 'slim-rails'
# gem 'sass-embedded', '~> 1.79'
gem 'cssbundling-rails'
gem 'jsbundling-rails', '~> 1.3'
gem 'sprockets-rails'

# --- Утилиты ---
gem 'acts_as_list'
gem 'counter_culture'
gem 'csv', '~> 3.3'
gem 'geocoder', '~> 1.8'
gem 'kaminari', '~> 1.2.2' # Пагинация
gem 'nokogiri'
gem 'rails-i18n'           # Локализация
gem 'slack-notifier'       # Уведомления в Slack
gem 'validates_timeliness', '~> 6.0'
gem 'valid_email2'

# --- Группа разработки и тестов ---
group :development, :test do
  gem 'bullet' # Ищет лишние запросы в базу (N+1)
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'database_cleaner-active_record'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 3.2'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 6.1.3'
  gem 'rubocop-rails', require: false
end

group :development do
  gem 'debug'
  gem 'letter_opener_web'
  gem 'listen', '~> 3.3'
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'spring'
  gem 'web-console', '>= 4.1.0'
end

group :test do
  gem 'capybara', '~> 3.40'
  gem 'selenium-webdriver', '~> 4.10'
  gem 'shoulda-matchers', '~> 5.3'
  gem 'simplecov', require: false
  gem 'webdrivers', '~> 5.2'
end

gem 'redis', '~>5.0'
gem 'redis-rails'

gem 'kaminari', '~> 1.2.2'

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Используем Dart Sass вместо sassc
# gem "sass-embedded", "~> 1.83.2"
gem 'cssbundling-rails'

gem 'sprockets-rails'

gem 'debug'

gem 'carrierwave', '~>2.2'
gem 'mini_magick', '~> 4.11'

# gem 'jquery-rails'
gem 'acts_as_list'

gem 'bootstrap', '~> 5.3'
# gem 'sass-rails'

gem 'jsbundling-rails', '~> 1.3'

gem 'dotenv-rails', '~> 3.1.8'

gem 'csv', '~> 3.3'
gem 'geocoder', '~> 1.8'
