# Sprint 4 — Infrastructure, CI/CD & Gateway

**Timeline:** Weeks 7–8 (Jul 1–14, 2026)
**Jira:** DA Sprint 4
**Phase:** Phase 2 — Infrastructure Setup
**Goal:** Get the full local dev environment running via Docker Compose, configure CI/CD pipelines for all services, and implement the API Gateway with JWT validation and rate limiting.

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| E09 | Development Environment Setup | Trung, Phước |
| E10 | CI/CD Pipeline | Trung, Phước, Tuấn, Lộc |
| E11 | API Gateway | Trung |

**Deliverables by end of Sprint 4:**
- `docker-compose up` starts all 5 infrastructure services (MongoDB, PostgreSQL, Redis, RabbitMQ, ChromaDB)
- Database init scripts run automatically on first start
- GitHub Actions CI passes for all 4 services
- API Gateway running on port 8080: JWT validation + rate limiting + routing active

---

## EPIC E09 — Development Environment Setup

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E09-01 | Write docker-compose.yml to run full infrastructure: MongoDB, PostgreSQL, Redis, RabbitMQ, ChromaDB | Trung (Leader) | 🔴 Critical |
| DA-E09-02 | Write init-mongo.js (create collections + indexes) and init-postgres.sql (create tables + seed subscription plans) | Trung (Leader) | 🔴 Critical |
| DA-E09-03 | Write .env.example consolidating all environment variables for 6 services | Trung (Leader) | 🔴 Critical |
| DA-E09-04 | Write clone-all.sh script to clone all 7 repos with a single command | Trung (Leader) | 🟡 High |
| DA-E09-05 | Write README.md for infrastructure repo (step-by-step setup guide) | Phước (Publisher) | 🟢 Medium |

**docker-compose.yml services:**
```yaml
services:
  mongodb:     image: mongo:7, port 27017
  postgres:    image: postgres:16, port 5432
  redis:       image: redis:7-alpine, port 6379
  rabbitmq:    image: rabbitmq:3-management, ports 5672 + 15672
  chromadb:    image: chromadb/chroma, port 8000
```

**init-postgres.sql seed data:** 4 subscription plans (Free, Basic, Pro, Enterprise) with `ai_credits_per_month`, `max_clients`, `max_posts_per_month`, `platforms_allowed[]` columns.

**Notes:**
- DA-E09-02: init scripts must mount via `docker-compose volumes` — run automatically on container first start.
- DA-E09-03: include ALL env vars across all 6 services. Use sections: `[Gateway]`, `[Business]`, `[AI]`, `[Publisher]`.

---

## EPIC E10 — CI/CD Pipeline

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E10-01 | Write GitHub Actions workflow for business-service (build + test + push Docker image) | Trung (Leader) | 🟡 High |
| DA-E10-02 | Write GitHub Actions workflow for publisher-service (build + test + push Docker image) | Phước (Publisher) | 🟡 High |
| DA-E10-03 | Write GitHub Actions workflow for ai-service (lint + test + build Docker image) | Tuấn (AI) | 🟡 High |
| DA-E10-04 | Write GitHub Actions workflow for web-dashboard (lint + build + deploy) | Lộc (Frontend) | 🟡 High |
| DA-E10-05 | Configure branch protection rules (require 1 approval before merging into develop) | Trung (Leader) | 🟢 Medium |

**CI workflow steps per service:**
- Java services (business, publisher): `mvn test` → `docker build` → `docker push ghcr.io/...`
- Python service (ai): `flake8` + `pytest` → `docker build` → `docker push`
- React (web-dashboard): `eslint` + `tsc --noEmit` → `vite build`

**Notes:**
- Use GitHub Container Registry (ghcr.io) for Docker images — free for public repos.
- DA-E10-05: branch protection on `main` and `develop`. `main` requires 2 approvals.

---

## EPIC E11 — API Gateway

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E11-01 | Initialize brandhub-api-gateway project with Spring Cloud Gateway | Trung (Leader) | 🔴 Critical |
| DA-E11-02 | Write JWT validation filter (verify token on every request, extract userId + role into headers) | Trung (Leader) | 🔴 Critical |
| DA-E11-03 | Write rate limiting filter using Redis (100 requests/minute/user) | Trung (Leader) | 🔴 Critical |
| DA-E11-04 | Configure routing rules (map URL paths to correct services) | Trung (Leader) | 🔴 Critical |
| DA-E11-05 | Write logging filter (log all inbound/outbound requests for debugging) | Trung (Leader) | 🟢 Medium |

**Routing rules (DA-E11-04):**
```
/api/v1/auth/**         → business-service:8081
/api/v1/users/**        → business-service:8081
/api/v1/workspaces/**   → business-service:8081
/api/v1/clients/**      → business-service:8081
/api/v1/posts/**        → business-service:8081
/api/v1/subscriptions/**→ business-service:8081
/api/v1/admin/**        → business-service:8081
/ai/**                  → ai-service:8082
/internal/**            → BLOCKED (internal only, no external routing)
```

**JWT filter behavior (DA-E11-02):**
- Skip validation for: `POST /api/v1/auth/login`, `POST /api/v1/auth/register`, `GET /` (health)
- On valid token: add headers `X-User-Id`, `X-User-Role`, `X-Workspace-Id` to forwarded request
- On invalid/expired token: return `401 Unauthorized` immediately, do not forward

**Notes:**
- Rate limiter key: `userId` (from JWT). Unauthenticated requests rate-limit by IP.
- DA-E11-05 logging: log `{timestamp, method, path, userId, durationMs, statusCode}` — use structured JSON logging.

---

## Sprint 4 Checklist

- [ ] `docker-compose up` starts all 5 infra services without errors
- [ ] MongoDB collections + indexes created automatically on first start
- [ ] PostgreSQL tables + 4 subscription plan seeds created automatically
- [ ] `.env.example` covers all 6 services
- [ ] GitHub Actions CI passes for business-service
- [ ] GitHub Actions CI passes for publisher-service
- [ ] GitHub Actions CI passes for ai-service
- [ ] GitHub Actions CI passes for web-dashboard
- [ ] API Gateway starts and routes `/api/v1/auth/login` to business-service
- [ ] JWT validation filter rejects expired tokens with 401
- [ ] Rate limiting returns 429 after 100 req/min
- [ ] README.md setup guide: new dev can run `docker-compose up` in < 10 minutes
