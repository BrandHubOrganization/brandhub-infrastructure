#!/usr/bin/env bash
# start-all.sh — start full stack including mobile API dependencies
# Usage: ./scripts/start-all.sh [--build] [--detach]
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
    --build)  BUILD_FLAG="--build" ;;
    --detach) DETACH_FLAG="-d" ;;
    --no-detach) DETACH_FLAG="" ;;
  esac
done

echo "==> Starting BrandHub full stack..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up $BUILD_FLAG $DETACH_FLAG

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
  echo "==> Logs: docker compose -f docker/docker-compose.yml logs -f [service]"
  echo "==> Stop:  docker compose -f docker/docker-compose.yml down"
fi
