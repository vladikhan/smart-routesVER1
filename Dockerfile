FROM ruby:3.1.6-slim AS base

# Устанавливаем только необходимые системные зависимости
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
RUN bundle config set --local without 'development test' && \
    bundle install

# Копируем остальной код
COPY . .

# Скрипт для очистки PID (важно для ECS/Docker)
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]