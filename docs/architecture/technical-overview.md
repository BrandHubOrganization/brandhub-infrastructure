# BrandHub — System Technical Overview

> Navigation: [← Knowledge Base Hub](../index.md) · [← Architecture Index](./README.md) · [ADR Index](../adr/README.md) · [API Contracts](../api/README.md) · [Database Hub](../database/README.md)

Master technical blueprint of the **BrandHub** platform, verified directly against the production codebase across all 7 repositories and aligned with the canonical hierarchy: `Agency / Personal Studio → Workspace → Media Package → Media Campaign → Task → Post`.

---

## 1. Platform Scope & Canonical Domain Baseline

- **Product Lines & Subscription Catalog (6 Active Plans)**:
  - **Personal Studio (`agencies.company_type = 'PERSONAL'`, 1-user `Owner` cap)**: `STUDIO_FREE`, `STUDIO_PLUS`, `STUDIO_PRO`.
  - **Agency (`agencies.company_type = 'AGENCY'`)**: `BASIC` (Free), `PLUS` (`990,000 VND/month` with 3/6/12-month cycle discounts), and `ENTERPRISE` (`3,990,000 VND/month`, `500 GB` storage).
- **6 Canonical System Roles**: `Guest`, `Owner` (fixed per company via `agencies.owner_id`), `Manager`, `Creator`, `Client` (assigned per workspace in `workspace_members`), and `Admin` (platform-wide governance via `user_system_roles`).
- **Functional Scope**: **141 Atomic Functional Requirements (`3.2.1`–`3.10.14`)** mapped 1-to-1 with **141 Use Cases (`UC-001`–`UC-141`)** across **9 functional domains** ([BA Master Index](../ba/README.md), [Use Case Catalog](../ba/use-cases/README.md)).
- **4 Supported Social Publishing Platforms**: Strictly **Facebook**, **Instagram**, **TikTok**, and **Threads**.
- **Payment Gateway**: **SePay (VietQR)** (`SEEPAY`) for upgrade-only plan orders (`FR 3.9.1`–`3.9.2`), storage add-ons, and AI credit top-ups.

---

## 2. Polyrepo Runtime Stack (Real Codebase Versions)

Governed by [ADR-001](./../adr/adr-001-polyrepo.md) and visualized in [Polyrepo Structure](/view?file=architecture/polyrepo-structure.html):

| Repository | Language & Framework Versions | Key Internal Modules / Libraries | Runtime Target |
| :--- | :--- | :--- | :--- |
| `brandhub-api-gateway` | Java 21, Spring Cloud Gateway (WebFlux / Netty), Reactive Redis | `RequestIdWebFilter`, `InboundSecurityWebFilter`, `JwtAuthFilterGatewayFilterFactory`, `RateLimitGatewayFilterFactory`, `LoggingGlobalFilter`, `GlobalErrorWebExceptionHandler` | `:8080` (`gateway` EC2 `172.31.27.199` behind Nginx `:443`) |
| `brandhub-business-service` | Java 21, Spring Boot 3, Spring Security, JPA + JDBC, Spring Data MongoDB, Spring WebSocket STOMP, AWS Encryption SDK | `122` REST/STOMP controllers across `auth`, `user`, `agency`, `workspace`, `client`, `media`, `task`, `content`, `material`, `social`, `chat`, `survey`, `mail`, `video`, `ai`, `trend`, `collaborator`, `billing`, `analytics`, `monitoring`, `admin` | `:8081` (`core` EC2 `172.31.24.149`) |
| `brandhub-ai-service` | Python 3.11+, FastAPI, ChromaDB `1.5.9`, Neo4j Async Driver, SentenceTransformers, PhoBERT | `15` v1 routers + v2 commercial image + internal routers; `caption_service`, `ltx_director`, `qwen_ambassador_client`, `product_video`, `server_video_edit`, `trend_fit`, `CrawlBatchConsumer` | `:8082` (`ai` EC2 `172.31.20.60`) |
| `brandhub-publisher-service` | Java 21, Spring Boot 3, Spring AMQP, StringRedisTemplate | `PublishJobConsumer` (`processingPostIds:{postId}:{platform}` lock), `SocialOAuthController`, `TokenRefreshScheduler`, `FacebookPublishAdapter`, `InstagramPublishAdapter`, `TikTokPublishAdapter`, `ThreadsPublishAdapter` | `:8083` (`core` EC2 `172.31.24.149`) |
| `brandhub-web` | TypeScript `6.0`, React `19.2.6`, Vite `8.3.8`, Tailwind CSS `4.3.0` | TanStack Query `5.100`, Zustand `5.0`, Radix UI / Shadcn `4.13`, TipTap `3.35` + Yjs `13.6` CRDT, `@stomp/stompjs` `7.3`, Agora RTC `4.24.9`, FullCalendar `6.1`, Recharts `3.10`, `i18next` (`vi`/`en`) | `:3000` local / S3 + CloudFront (`brandhub.id.vn`) |
| `brandhub-mobile-app` | TypeScript `6.0`, Expo SDK `58.0.26`, React Native `0.88.1`, React `19.3.0` | React Navigation `7`, TanStack Query `5.100`, Zustand `5.0`, `@stomp/stompjs` `7.5`, Yjs `13.6`, Vision Camera `5.2`, `expo-secure-store`, `expo-local-authentication`, `expo-notifications` | Metro `:8090` local / Android & iOS |
| `brandhub-infrastructure` | Terraform `~> 6.0` (AWS Provider `6.70`), Docker Compose v2, Python 3.12, VitePress | `database/` (`init/`, `migrations/`), `docker/`, `prod/` (`hosts/`, `terraform/`, `loadtest/`), `gpu-workers/wan-vace/`, `scripts/`, `docs/` | AWS `134875421878`, Vast.ai GPU, GitHub Pages |

---

## 3. Polyglot Persistence & Real-Time Data Plane

Governed by [ADR-002](../adr/adr-002-database-split.md) and detailed in [Database Hub](../database/README.md) & [ERD Entity Descriptions](../database/schema/erd-entity-descriptions.md):

1. **PostgreSQL 17 (`97` tables in `database/init/init-postgres-v2.sql`)**: Solely owned by `brandhub-business-service` (`33` JPA `@Entity` classes + `64` SQL/JDBC tables). Stores identity, 2-tier RBAC, Media Packages & Campaigns, SePay billing orders/cycles/audit logs, double-entry AI credit wallets & reservations, `product_video_*` coordinator state, S3/Drive/Client Vault storage quotas, mail batches, and `user_notifications` (emitting PostgreSQL `NOTIFY user_notification` on commit).
2. **MongoDB 7.0 (`52` collections in `database/init/init-mongo.js`, MongoDB Atlas in prod)**: Stores `tasks`, `task_approvals`, `task_sections` (`DA-1274` role sections), `posts`, `content_requests`, `materials`/`material_folders`/`material_versions`/`client_vault_shares`, `chat_*` (`8` collections including Agora calls & scheduled messages), `video_*` (`4` collections), `surveys`/`survey_responses`, `mail_templates`, `social_accounts`, `monitoring_*`, `knowledge_documents`, `ai_usage_logs`, and `publish_logs`.
3. **Redis 7.2 (`redis:7.2-alpine`, AOF)**: Stores `jwt:blacklist:{jti}` (`15m`), `ratelimit:gateway:{userId}:{minute}` (`60s`), `oauth:state:{state}` (`10m`), publisher locks `processingPostIds:{postId}:{platform}` (`30m`), and Vietnam trend rankings `trends:vn:{date}:{category}` (`6h`) ([Redis Key Patterns](../database/redis-cache/redis-key-patterns.md)).
4. **ChromaDB 1.5.9 (`384d` HNSW)** & **Neo4j 5.26 / Aura**: Owned by `brandhub-ai-service` for tenant-isolated Brand Guideline RAG (`intfloat/multilingual-e5-small`) and Trend Knowledge Graph scoring ([Hybrid DB Schema](../database/ai-vector/hybrid-db-schema.md)).

---

## 4. Inter-Service Communication & Security Architecture

- **Perimeter Ingress & RS256 Auth ([ADR-004](../adr/adr-004-spring-cloud-gateway.md), [RS256 JWT Flow](../api/rs256-jwt-flow.md))**: `InboundSecurityWebFilter` strips spoofable `X-User-*` and `X-Internal-Key` headers at the edge; `JwtAuthFilterGatewayFilterFactory` verifies RS256 signatures using `JWT_PUBLIC_KEY` and checks Redis `jwt:blacklist:{jti}`; `brandhub-business-service` independently re-verifies the Bearer token and evaluates live PostgreSQL roles ([Roles & Permissions Matrix](../ba/10-roles-permissions-matrix.md)).
- **Real-Time STOMP WebSockets (`WebSocketConfig.java`)**:
  - `/ws/tasks`: Handshake-authenticated Yjs CRDT collaborative content sync (`/app/tasks/{taskId}/content` → persisted in `task_content_operations` → broadcast to `/topic/tasks/{taskId}/content`) plus ephemeral cursor awareness (`/topic/tasks/{taskId}/awareness`).
  - `/ws/chat`: Workspace channel messaging, reactions, read receipts, call signaling, and real-time in-app inbox pushes (`/user/queue/notifications` driven by PostgreSQL `LISTEN user_notification`).
- **Internal AI Orchestration ([Business–AI REST Contract](./business-ai-rest-contract.md))**: `business-service` reserves credits in `ai_credit_reservations`, calls `ai-service` (`:8082`) with `X-Internal-Key`, and settles or refunds credits atomically upon completion.
- **Asynchronous Social Publishing ([ADR-003](../adr/adr-003-rabbitmq.md), [RabbitMQ Contract](/view?file=architecture/rabbitmq-publisher-contract.html))**: `business-service` publishes `PublishJobMessage` to `publisher.job.exchange` (`publisher.job.queue`); `publisher-service` executes platform adapters with `1m`/`5m`/`15m` TTL retry queues and `publisher.job.dlq`.
- **Cryptographic Storage Controls**: Social OAuth tokens use `AES-256-GCM` (`CryptoUtils`), while private Workspace Repository and `Client` Vault S3 payloads (`repository/*`, `client-vault/*`) are pre-encrypted before S3 upload using AWS Encryption SDK `ALG_AES_256_GCM_HKDF_SHA512_COMMIT_KEY` (`RepositoryEnvelopeCrypto`).

---

## 5. Cloud Production (`AWS ap-southeast-1`) & On-Demand GPU Topology

- **Frontend Edge (`02-frontend`)**: Private S3 (`brandhub-web-prd-134875421878`) + CloudFront OAC + `brandhub-public-routes` viewer function (`brandhub.id.vn`).
- **5-Host Backend Fleet (`03-backend`)**: `gateway` (`172.31.27.199`, `t3.small`), `core` (`172.31.24.149`, `m7i-flex.large`, including nightly `db-backup` to `s3://brandhub-db-backup-prd-134875421878`), `ai` (`172.31.20.60`, `c7i-flex.large`), wakeable `crawl` (`172.31.20.50`, `c7i-flex.large` behind `crawl-gate` `:8084`), and wakeable `edit-video` (`172.31.20.80`, `m7i-flex.large` behind Nginx `/edit-video/`) — see [Deployment Runbook](../operations/deployment-acct134.md) and [Wake-on-Request Architecture](../operations/wake-on-request.md).
- **External Vast.ai GPU Workers (`gpu-workers/wan-vace/`)**: Runs **ComfyUI + Wan 2.2 Fun VACE 14B + Wan 2.2 S2V 14B + Qwen Image 2.1** (`>= 48 GB VRAM`) behind `X-API-Key` FastAPI (`vace_api.py` `:10200`) for 15–20s multi-segment product videos, virtual brand ambassadors, and commercial product photography.
