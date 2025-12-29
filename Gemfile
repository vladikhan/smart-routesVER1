source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Рекомендую использовать 3.1.4, если она уже настроена в Docker
ruby '~> 3.1.4'

# --- Основное ---
gem 'rails', '~> 6.1.7', '>= 6.1.7.6'
gem 'pg' # Используем Postgres (ВАЖНО для твоего Docker)
gem 'puma', '~> 5.0'
gem 'webpacker', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# --- Redis & Sidekiq (Для очередей и кэша) ---
gem 'redis', '~> 5.0'
gem 'redis-rails'
gem 'redis-namespace'
gem 'sidekiq', '~> 6.4'

# --- Архитектура Trailblazer (Корпоративный стандарт) ---
gem 'trailblazer-rails'
gem 'trailblazer-cells'
gem 'reform-rails'

# --- Аутентификация и безопасность ---
gem 'devise'
gem 'devise-i18n'
gem 'bcrypt', '~> 3.1.7'

# --- Загрузка файлов и AWS ---
gem 'carrierwave', '~> 2.2'
gem 'mini_magick', '~> 4.11'
gem 'fog-aws'
gem 'asset_sync'
gem 'aws-sdk-s3', require: false
gem 'mime-types'

# --- Frontend & UI ---
gem 'slim-rails'       # Коллега использует Slim вместо ERB
gem 'html2slim'       # Поможет тебе конвертировать старые файлы
gem 'bootstrap', '~> 5.3'
# gem 'sass-embedded', '~> 1.79'
gem 'cssbundling-rails'
gem 'jsbundling-rails', '~> 1.3'
gem 'sprockets-rails'

# --- Утилиты ---
gem 'kaminari', '~> 1.2.2' # Пагинация
gem 'rails-i18n'           # Локализация
gem 'dotenv-rails', '~> 3.1'
gem 'geocoder', '~> 1.8'
gem 'csv', '~> 3.3'
gem 'nokogiri'
gem 'counter_culture'
gem 'acts_as_list'
gem 'valid_email2'
gem 'validates_timeliness', '~> 6.0'
gem 'slack-notifier'       # Уведомления в Slack

# --- Группа разработки и тестов ---
group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 6.1.3'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 3.2'
  gem 'bullet'             # Ищет лишние запросы в базу (N+1)
  gem 'rubocop-rails', require: false
  gem 'rails-controller-testing'
  gem 'database_cleaner-active_record'
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'letter_opener_web' # Для просмотра писем в браузере
  gem 'debug'
end

group :test do
  gem 'capybara', '~> 3.40'
  gem 'selenium-webdriver', '~> 4.10'
  gem 'webdrivers', '~> 5.2'
  gem 'shoulda-matchers', '~> 5.3'
  gem 'simplecov', require: false
end