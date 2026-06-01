#!/usr/bin/env bash
# start-no-mobile.sh — start full stack for web dev (excludes mobile app, includes all backend)
# Mobile app runs natively via: cd brandhub-mobile-app && npx expo start
# Usage: ./scripts/start-no-mobile.sh [--build] [--no-detach]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/../docker/docker-compose.yml"
ENV_FILE="$SCRIPT_DIR/../docker/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "[ERROR] .env not found. Copy docker/.env.example to docker/.env and fill in secrets."
  exit 1
fi

BUILD_FLAG=""
DETACH_FLAG="-d"

for arg in "$@"; do
  case $arg in
    --build)     BUILD_FLAG="--build" ;;
    --no-detach) DETACH_FLAG="" ;;
  esac
done

# All services except mobile (mobile app is Expo — runs natively, not in Docker)
SERVICES="mongo postgres redis rabbitmq chromadb pgadmin business-service ai-service publisher-service api-gateway web-dashboard"

echo "==> Starting BrandHub stack (web + backend, no mobile container)..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up $BUILD_FLAG $DETACH_FLAG $SERVICES

if [ -n "$DETACH_FLAG" ]; then
  echo ""
  echo "==> Services running:"
  echo "    Web Dashboard    http://localhost:3000"
  echo "    API Gateway      http://localhost:8080"
  echo "    Business Service http://localhost:8081"
  echo "    AI Service       http://localhost:8082"
  echo "    Publisher        http://localhost:8083"
  echo "    pgAdmin          http://localhost:5050  (admin@brandhub.local / admin)"
  echo "    RabbitMQ UI      http://localhost:15672"
  echo "    MongoDB          localhost:27017"
  echo "    PostgreSQL       localhost:5432"
  echo "    Redis            localhost:6379"
  echo "    ChromaDB         http://localhost:8000"
  echo ""
  echo "==> Mobile (Expo): cd brandhub-mobile-app && npx expo start"
  echo "    Set EXPO_PUBLIC_API_BASE_URL=http://<your-local-ip>:8080 in mobile .env"
fi
