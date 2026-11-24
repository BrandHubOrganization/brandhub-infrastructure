# Service Boundaries & Domain Ownership — BrandHub Architecture

> Navigation: [← Knowledge Base Hub](../index.md) · [← Architecture Index](./README.md) · [Technical Overview](./technical-overview.md) · [DB Ownership Diagram](/view?file=architecture/db-ownership-diagram.html)

Defines the non-negotiable runtime, data-ownership, and communication boundaries across every service in the BrandHub ecosystem (`Agency / Personal Studio → Workspace → Media Package → Media Campaign → Task → Post`).

---

## 1. `brandhub-api-gateway` (Java 21, Spring Cloud Gateway WebFlux, `:8080`)

- **Owns**:
  - **Redis Namespace (Write/Read)**: `ratelimit:gateway:{userId|ip}:{minute}` (`60s` TTL via reactive Lua `INCR` + `EXPIRE` in `RateLimitGatewayFilterFactory`).
  - **Redis Namespace (Read-Only)**: `jwt:blacklist:{jti}` (`JwtUtil.validateAndExtract()`).
  - **Perimeter Filter Pipeline**: `RequestIdWebFilter` (`X-Request-Id`), `InboundSecurityWebFilter` (blocks `;`/`..`/`%2e%2e` path smuggling, blocks `/api/v1/internal/**` and `/api/v1/test/**`, strips spoofed `X-User-Id`, `X-User-Role`, `X-Workspace-Id`, `X-Internal-Key` headers), `JwtAuthFilterGatewayFilterFactory` (`JWT_PUBLIC_KEY` RS256 verification), `LoggingGlobalFilter`, and `GlobalErrorWebExceptionHandler` (`ApiResponse<T>` JSON errors).
- **Does NOT Own**: Zero PostgreSQL, MongoDB, ChromaDB, Neo4j, or RabbitMQ connections; holds **no** `JWT_PRIVATE_KEY` or `AES_SECRET_KEY`; performs **no** workspace-membership RBAC queries.

---

## 2. `brandhub-business-service` (Java 21, Spring Boot 3, `:8081`)

- **Owns**:
  - **PostgreSQL 17 — All `97` Tables (`100%` Exclusive Owner)**:
    - *Identity & System Roles*: `users`, `user_oauth_providers`, `user_refresh_tokens`, `user_system_roles`, `account_activation_tokens`.
    - *Organization (`AGENCY` & `PERSONAL`)*: `agencies` (`owner_id`, `company_type`), `agency_members`, `agency_invitations`, `client_profiles`, `workspaces`, `workspace_members` (`MANAGER` \| `CREATOR` \| `CLIENT`), `workspace_invitations`, `workspace_templates`, `workspace_post_templates`, `workspace_hashtags`.
    - *Media Packages, Campaigns & Collaborators*: `media_packages`, `workspace_media_packages`, `package_negotiation_events`, `media_campaigns`, `campaign_versions`, `campaign_review_events`, `campaign_deployments`, `content_request_completion_jobs`, `third_party_collaborators`, `campaign_collaborators`.
    - *SePay (VietQR) Billing & Double-Entry AI Credits*: `subscription_plans` (`STUDIO_FREE/PLUS/PRO`, `BASIC/PLUS/ENTERPRISE`), `billing_plan_versions`, `billing_plan_cycle_prices`, `billing_plan_change_log`, `agency_subscriptions`, `billing_orders`, `billing_payments`, `billing_payment_events`, `transactions`, `agency_credit_wallets`, `credit_grants`, `workspace_credit_limits`, `ai_credit_operation_prices`, `ai_credit_reservations`, `credit_operations`, `credit_entries`.
    - *Product Video Coordinator, Storage/Drive/Vault, Mail & Governance*: `ai_caption_generations`, `ai_video_jobs`, `product_video_*` (`5` tables), `agency_storage_*`, `storage_addon_*`, `client_vault_*`, `repository_drive_*`, `mail_*`, `newsletter_usage`, `engagement_reminders`, `audit_logs`, `user_strikes`, `sanction_reviews`, `content_moderation_reviews`, `admin_*`, `user_notifications` (`LISTEN/NOTIFY`).
  - **MongoDB 7.0 — `49` of `52` Collections**: `tasks`, `task_approvals`, `task_comments`, `task_comment_uploads`, `task_notification_outbox`, `task_sections`, `task_section_versions`, `task_section_events`, `event_plans`, `press_recommendations`, `content_requests`, `posts`, `post_versions`, `social_accounts`, `materials`, `material_folders`, `material_versions`, `material_upload_sessions`, `material_references`, `material_audit_outbox`, `client_vault_shares`, `watermark_presets`, `chat_*` (`8` collections), `video_*` (`4` collections), `surveys`, `survey_responses`, `mail_templates`, `mail_recipient_groups`, `monitoring_*` (`4` collections), `notifications`, `report_jobs`, plus V1 seed-compat collections.
  - **Redis Namespaces**: `jwt:blacklist:{jti}`, `oauth:state:{state}`, OTP/2FA challenge keys.
  - **S3 Cryptographic Envelope (`RepositoryEnvelopeCrypto`)**: Pre-encrypts and streams `repository/*` and `client-vault/*` objects using `ALG_AES_256_GCM_HKDF_SHA512_COMMIT_KEY`.
  - **STOMP WebSockets**: `/ws/tasks` (Yjs CRDT collaborative content & awareness) and `/ws/chat` (workspace chat, Agora call signaling, and `/user/queue/notifications`).
- **Does NOT Own**: Never invokes external Facebook/Instagram/TikTok/Threads publishing APIs directly; never embeds vectors into ChromaDB or traverses Neo4j directly.

---

## 3. `brandhub-ai-service` (Python 3.11+, FastAPI, `:8082`)

- **Owns**:
  - **ChromaDB `1.5.9`**: Per-client/workspace `384d` vector collections (`client_{clientId}` / `brandhub_rag` with mandatory `where={"clientId": ...}` filter).
  - **Neo4j `5.26` / Aura**: Trend Knowledge Graph (`:Trend`, `:CrawledPost`, `:KOL`, `:Brand`, `:Location`, `:Dish`) + APOC Entity Resolution (`Neo4jTrendService`).
  - **MongoDB — `2` Collections**: `knowledge_documents` and `ai_usage_logs`.
  - **Redis Namespace**: `trends:vn:{YYYY-MM-DD}:{category}` (`6h` TTL) and trend snapshot/brand-fit caches.
  - **S3 Prefixes**: `rag/*`, `ai/*`, and `qwen-ambassador/*` on `brandhub-media-134875421878`, plus raw trend archives on `crawler-social-134875421878`.
- **Does NOT Own**: Zero connection to PostgreSQL or business MongoDB collections; never mutates `agency_credit_wallets` or `ai_credit_reservations` (all credit accounting stays in `business-service`).
- **Key Subsystems**:
  - Multi-provider LLM routing (`Groq`, `Google Gemini`, `Claude`) + `Humanizer` + `PhoBERT` emotion/sentiment + `text_moderation_service` (`FR 3.6.33`).
  - Remote **Vast.ai GPU Worker** orchestration: `qwen_ambassador_client.py` (Virtual Brand Ambassador & 3-reference commercial photography) and `ltx_director.py` (Claude storyboard/segment director → **Wan 2.2 Fun VACE 14B** `:10200` worker + `ffmpeg` CC0 music post-mix).
  - `server_video_edit` orchestration against `brandhub-edit-video` (`172.31.20.80:8095`) and trend ingestion via `CrawlBatchConsumer` + `brandhub-crawl` (`172.31.20.50:8084` via `crawl-gate`).

---

## 4. `brandhub-publisher-service` (Java 21, Spring Boot 3, `:8083`)

- **Owns**:
  - **MongoDB — `1` Collection**: `publish_logs` (platform HTTP request/response audit telemetry).
  - **RabbitMQ Publishing Queues**: `publisher.job.exchange` → `publisher.job.queue`, `publisher.retry.exchange` → `publish.jobs.retry.{1m,5m,15m}`, and `publisher.job.dlx` → `publisher.job.dlq`.
  - **Redis Lock Namespace**: `processingPostIds:{postId}:{platform}` (`30m` TTL in `PublishJobConsumer`).
- **Does NOT Own**: Zero PostgreSQL access and zero direct access to `posts` or `social_accounts` in MongoDB (syncs encrypted OAuth credentials and publish results with `business-service` via internal `X-Internal-Key` endpoints `/api/v1/internal/social-accounts/*` and publish result callbacks).
- **Supported Social Adapters (`SocialPlatform` Enum — Strictly 4 Platforms)**:
  1. `FacebookPublishAdapter` (`FR 3.8.8` Post, `FR 3.8.9` Story, `FR 3.8.10` Reels — Meta Graph `v19.0`)
  2. `InstagramPublishAdapter` (`FR 3.8.11` Post, `FR 3.8.12` Reels, `FR 3.8.13` Story — Meta Graph `v19.0`)
  3. `TikTokPublishAdapter` (`FR 3.8.14` Video — TikTok Content Posting API v2)
  4. `ThreadsPublishAdapter` (`FR 3.8.15` Post — Threads Publishing API)
  *(External offline/partner channels such as KOL/KOC, Online Newspaper, Banner Ads, and TV Channels — `FR 3.7.15`–`3.7.18` — are tracked as collaborator deliverables in `business-service`, never through `publisher-service`.)*

---

## 5. Auxiliary Compute & Client Boundaries

| Component | Runtime | Boundary Contract |
| :--- | :--- | :--- |
| **`brandhub-crawl`** | Python + Playwright/Camoufox (`172.31.20.50:8084`, wakeable) | Executes headless social scraping; streams raw batches over RabbitMQ to `ai-service` (`CrawlBatchConsumer`); woken via `crawl-gate` (`172.31.24.149:8084`) or EventBridge SSM `crawl-kick.sh` |
| **`brandhub-edit-video`** | Containerized Render Engine (`172.31.20.80:8095`, wakeable) | Reached via Gateway Nginx `/edit-video/` (`X-API-Key`) or `ai-service` `server_video_edit`; pulls/uploads media via short-lived `/api/v1/internal/video-edits/{jobId}/*` sessions |
| **`brandhub-web` & `brandhub-mobile-app`** | React 19 / Vite 8 & Expo 58 / RN 0.88 | Communicate **exclusively** through `api.brandhub.id.vn` (`:8080` locally) over HTTPS REST and `/ws/{chat,tasks}` STOMP; never hold AWS S3 IAM keys or AI provider secrets |
