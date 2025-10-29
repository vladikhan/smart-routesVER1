FROM ruby:3.1

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

WORKDIR /app
COPY Gemfile* ./
RUN bundle install

RUN apt-get update -qq && apt-get install -y nodejs npm
RUN npm install -g yarn

COPY . .

EXPOSE 3000
CMD ["bash"]