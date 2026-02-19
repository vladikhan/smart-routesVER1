FROM ruby:3.1.6-slim AS base

# Устанавливаем только необходимые системные зависимости
RUN apt-get update -qq && apt-get install -y imagemagick


RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    curl \
    && npm install -g yarn \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Устанавливаем гемы отдельно для кеширования слоев Docker
COPY Gemfile Gemfile.lock ./
# This image is used for development/test via docker-compose (volume-mounted app).
# Install development + test gems so `bundle exec rspec` works in-container.
RUN bundle config set --local without 'production' && \
    bundle install

# Копируем остальной код
COPY . .

# Скрипт для очистки PID (важно для ECS/Docker)
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]