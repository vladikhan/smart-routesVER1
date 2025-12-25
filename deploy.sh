#!/bin/bash

# Variables for convenience

IMAGE_NAME="183898463321.dkr.ecr.ap-northeast-1.amazonaws.com/smart-routes:latest"
CONTAINER_NAME="smart-routes-app"

echo " Deploy starts..."

1. Stop and remove the old container, if there is one.
echo "Очистка старых контейнеров..."
docker rm -f $CONTAINER_NAME || true

# 2. Cleaning old containers.

echo " Launch of a new image..."
docker run -d \
  -p 3000:3000 \
  --name $CONTAINER_NAME \
  --add-host=host.docker.internal:host-gateway \
  -e RAILS_ENV=production \
  -e RAILS_MASTER_KEY='891bbca9c1be00865ffb4d2b82e0ec48' \
  -e RAILS_LOG_TO_STDOUT=true \
  -e DATABASE_URL='postgresql://smart_routes_user:secure_password_123@host.docker.internal:5432/smart_routes_production' \
  -e RAILS_SERVE_STATIC_FILES=true \
  $IMAGE_NAME

# 3.Launching migrations inside the container

echo " Checking database migrations..."
docker exec $CONTAINER_NAME bundle exec rails db:migrate RAILS_ENV=production

echo "Deployment complete! The application is available via Nginx."