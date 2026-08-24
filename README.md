# BrandHub Infrastructure Setup Guide

Docker Compose stack, database initialization scripts, Dockerfiles, and environment templates for BrandHub.

## Overview

All infrastructure-as-code for running the full BrandHub platform locally or in a self-hosted environment.

## Structure

```
brandhub-infrastructure/
├── docker/
│   ├── docker-compose.infra.yml  # Core infra: postgres, redis, rabbitmq, chromadb, neo4j
│   ├── docker-compose.dev.yml    # Overlay: host ports for infra + pgadmin
│   ├── docker-compose.apps.yml   # 5 app services (api-gateway, business, ai, publisher, web-dashboard)
│   ├── run-compose.bat           # Wrapper: infra+dev by default, "full" arg adds apps
│   └── .env.example              # All environment variables with defaults
└── scripts/
    ├── init-postgres.sql       # Subscription plans, payments, audit_logs tables + seed data
    └── init-mongo.js           # Collections, validators, and performance indexes (run against Atlas, not local)
```

See [docs/architecture/local-run-architecture.md](docs/architecture/local-run-architecture.md) for the full breakdown of how the compose files compose and the service dependency chain.

## Step-by-Step Setup Guide

Follow these steps to get the full local stack running.

### 1. Prerequisites

Ensure you have the following installed on your system:

- **Docker & Docker Compose**: For running containerized services.
- **Git**: For cloning the repository.
- **Java 21**: Required if you plan to build or run Java services locally outside Docker.
- **Python 3.11**: Required for AI services.
- **Node 20**: Required for frontend and NodeJS services.

### 2. Clone the Repository

Clone the infrastructure repository to your local machine.

### 3. Environment Configuration

Navigate to the `docker` directory and set up your `.env` file:

```bash
cd docker
cp .env.example .env
```

Open the `.env` file in your preferred text editor and fill in the required secrets (JWT keys, AES_SECRET_KEY, API keys, OAuth credentials, etc.). `run-compose.bat` also auto-copies `.env.example` to `.env` on first run if missing.

### 4. Start the Stack

```bash
cd docker
run-compose.bat          # infra (postgres/redis/rabbitmq/chromadb/neo4j) + dev host ports + pgadmin
run-compose.bat full     # same, plus the 5 app services (build from sibling repos)
```

There is no single `docker-compose.yml` — the stack is split across `docker-compose.infra.yml`, `docker-compose.dev.yml`, and `docker-compose.apps.yml`, combined via `-f`. MongoDB is not part of the compose stack; `MONGODB_URI` in `.env` must point to an Atlas (cloud) cluster.

It may take a few minutes for all services to become healthy.

## Verification

Once the stack is up, you can verify that each service is running correctly using the following health checks:

- **MongoDB**: no local container — connect with `mongosh "$MONGODB_URI"` against the Atlas cluster configured in `.env`.

- **RabbitMQ Management UI**:
  Open [http://localhost:15672](http://localhost:15672) in your browser.

- **PostgreSQL**:

  ```bash
  pg_isready -h localhost -p 5432 -U postgres
  ```

  _(Expected output: `localhost:5432 - accepting connections`)_

- **Redis**:

  ```bash
  redis-cli ping
  ```

  _(Expected output: `PONG`)_

- **Web Dashboard**:
  Open [http://localhost:3000](http://localhost:3000)

## Troubleshooting

Here are solutions to some common setup issues:

### 1. Port Conflicts

**Issue**: `docker compose up` fails with a "bind: address already in use" error.
**Solution**: Another service on your machine is using the required port (e.g., 5432 for Postgres, 8080 for API Gateway). Stop the conflicting local service, or override the host port via the `*_HOST_PORT` env vars in `.env` (e.g. `POSTGRES_HOST_PORT=5433`) rather than editing the compose files directly.

Alternatively, you can find and kill the process using the port:

- **Windows**:
  ```powershell
  netstat -ano | findstr :<PORT>
  taskkill /PID <PID> /F
  ```

### 2. Docker Memory Limits

**Issue**: Containers exit unexpectedly with OOMKilled (Out of Memory) or services crash during startup.
**Solution**: The full stack requires significant memory. Open your Docker Desktop settings, navigate to Resources, and increase the Memory limit to at least 8GB (12GB+ recommended) and CPUs to at least 4.

### 3. ChromaDB Startup Delay

**Issue**: The AI service fails to connect to ChromaDB during initial startup.
**Solution**: ChromaDB can take longer to initialize, especially on the first run. The AI service should eventually retry and connect, but you can also manually restart the AI service after ChromaDB is healthy:

```bash
docker compose -p brandhub -f docker-compose.infra.yml -f docker-compose.apps.yml -f docker-compose.dev.yml restart ai-service
```

## Services Reference

| Service             | Image                             | Port         |
| ------------------- | ---------------------------------- | ------------ |
| `api-gateway`       | Custom (JDK 21)                    | 8080         |
| `business-service`  | Custom (JDK 21)                    | 8081         |
| `ai-service`        | Custom (Python 3.11)               | 8082         |
| `publisher-service` | Custom (JDK 21)                    | 8083         |
| `web-dashboard`     | Custom (nginx)                     | 3000         |
| `mongodb`           | Atlas (cloud, not containerized)   | —            |
| `postgres`          | postgres:17-alpine                 | 5432         |
| `redis`             | redis:7.2-alpine                   | 6379         |
| `rabbitmq`          | rabbitmq:3.12-management-alpine    | 5672 / 15672 |
| `chromadb`          | chromadb/chroma:0.6.3              | 8000         |
| `neo4j`             | neo4j:5.26-community               | 7474 / 7687  |
| `pgadmin`           | dpage/pgadmin4:9                   | 5050         |

## Database Initialization

- **PostgreSQL**: `scripts/init-postgres.sql` creates `subscription_plans`, `subscriptions`, `payments`, `audit_logs` tables and seeds 4 plans.
- **MongoDB**: `scripts/init-mongo.js` creates 9 collections with schema validators and indexes — run manually against the Atlas cluster, not auto-applied at container init.

## Volumes

Named volumes: `brandhub-postgres-data`, `brandhub-redis-data`, `brandhub-rabbitmq-data`, `brandhub-chroma-data`, `brandhub-neo4j-data`, `brandhub-neo4j-logs`, `brandhub-pgadmin-data` — persisted across restarts. No Mongo volume (cloud-hosted).
