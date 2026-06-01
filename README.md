# brandhub-infrastructure

Docker Compose stack, database initialization scripts, Dockerfiles, and environment templates for BrandHub.

## Overview

All infrastructure-as-code for running the full BrandHub platform locally or in a self-hosted environment.

## Structure

```
brandhub-infrastructure/
├── docker/
│   ├── docker-compose.yml      # Full stack: 7 app services + 5 infra services
│   └── .env.example            # All environment variables with defaults
└── scripts/
    ├── init-postgres.sql       # Subscription plans, payments, audit_logs tables + seed data
    └── init-mongo.js           # Collections, validators, and performance indexes
```

## Services

| Service | Image | Port |
|---|---|---|
| `api-gateway` | Custom (JDK 21) | 8080 |
| `business-service` | Custom (JDK 21) | 8081 |
| `ai-service` | Custom (Python 3.13) | 8082 |
| `publisher-service` | Custom (JDK 21) | 8083 |
| `web-dashboard` | Custom (nginx) | 3000 |
| `mongodb` | mongo:7 | 27017 |
| `postgres` | postgres:16-alpine | 5432 |
| `redis` | redis:7-alpine | 6379 |
| `rabbitmq` | rabbitmq:3.13-management | 5672 / 15672 |
| `chromadb` | chromadb/chroma | 8000 |

## Quick Start

```bash
cd docker
cp .env.example .env
# fill in secrets (JWT_SECRET, AES_SECRET_KEY, API keys, OAuth credentials)
docker compose up -d
```

Health checks are configured on all infrastructure services. Application services wait for their dependencies via `depends_on: condition: service_healthy`.

## Database Initialization

- **PostgreSQL**: `scripts/init-postgres.sql` creates `subscription_plans`, `subscriptions`, `payments`, `audit_logs` tables and seeds 4 plans (FREE / BASIC / PRO / ENTERPRISE).
- **MongoDB**: `scripts/init-mongo.js` creates 9 collections with schema validators and indexes (`users`, `workspaces`, `clients`, `social_accounts`, `posts`, `campaigns`, `content_requests`, `knowledge_documents`, `notifications`).

## Volumes

Named volumes: `mongo_data`, `postgres_data`, `redis_data`, `rabbitmq_data`, `chroma_data` — persisted across restarts.

## Environment Variables

See [docker/.env.example](docker/.env.example) for all required variables including:
- Database credentials
- JWT & AES secrets
- AWS S3 config
- AI API keys (Groq, Anthropic, Stability AI, Google Veo)
- Social OAuth credentials (Facebook, Instagram, TikTok, Threads, Zalo)
