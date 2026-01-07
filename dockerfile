FROM ruby:3.1.6

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
		nodejs \
		npm \ 
		postgresql-client \
		build-essential \
		libpq-dev \
		&& npm install -g yarn \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN sed -i '1i require "logger"' config/application.rb

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]