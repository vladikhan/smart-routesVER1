#!/bin/bash

# Path to the file with secrets on the SERVER
ENV_FILE="$HOME/.smart_routes.env"

# Check: if the file does not exist, the script will not proceed
if [ ! -f "$ENV_FILE" ]; then
    echo "❌  Error: File $ENV_FILE not found on the server!"
    exit 1
fi

# "Export" variables from the file to the current script session
export $(grep -v '^#' $ENV_FILE | xargs)

IMAGE_NAME="183898463321.dkr.ecr.ap-northeast-1.amazonaws.com/smart-routes:latest"
CONTAINER_NAME="smart-routes-app"

echo "Deploy starts..."

# 1. Cleaning
docker rm -f $CONTAINER_NAME || true
docker image prune -f

# 2. Launch (using variables $)
docker run -d \
  -p 3000:3000 \
  --name $CONTAINER_NAME \
  --add-host=host.docker.internal:host-gateway \
  -e RAILS_ENV=production \
  -e RAILS_MASTER_KEY=$RAILS_MASTER_KEY \
  -e DATABASE_URL=$DATABASE_URL \
  -e RAILS_LOG_TO_STDOUT=true \
  -e RAILS_SERVE_STATIC_FILES=true \
  $IMAGE_NAME

# 3. Migrations
docker exec $CONTAINER_NAME bundle exec rails db:migrate RAILS_ENV=production

echo "All set. All Secured"