---
layout: doc
title: BrandHub Knowledge Base Hub
---

# BrandHub — Master Knowledge Base Hub

Welcome to the authoritative engineering, business analysis, architecture, database, AI R&D, and production operations knowledge base for **BrandHub** — an AI-Powered Multi-Platform Brand & Content Marketing Operations Suite for Agencies, Brands, and Creators (`SEP490` Capstone Project).

---

## 1. System Baseline at a Glance

### 1.1 Six Canonical System Roles (Mandatory Naming Standard)

Across all microservices, REST/WebSocket specifications, database seeders, UML diagrams, and SRS/SDD deliverables, BrandHub strictly enforces **6 canonical short role names**:

| Canonical Role | Code Enum | Scope & Primary Responsibilities |
| :--- | :---: | :--- |
| **`Guest`** | `GUEST` | Unauthenticated visitor browsing public landing pages, pricing, sign-up, Google OAuth login, OTP verification, password recovery, public surveys, and `/s/:token` share links |
| **`Owner`** | `OWNER` | Founder/owner of an `Agency` (or `Personal Hub`); governs agency profile, **SePay (VietQR)** subscription upgrades, workspace lifecycle, templates, `agency_credit_wallets`, and per-workspace AI credit caps |
| **`Manager`** | `MANAGER` | Operational lead assigned to a `Workspace` (≥1 active `Manager` required per workspace); coordinates package/campaign negotiation, task backlogs, assignments, intermediate approvals, and `Self-Approve` in `PERSONAL` mode |
| **`Creator`** | `CREATOR` | Creative producer inside a `Workspace`; authors multi-section Unicode deliverables across 8 `TaskType`s, applies watermarks/hashtags, runs AI Studio pipelines, and schedules/publishes approved posts |
| **`Client`** | `CLIENT` | External brand partner invited into `AGENCY`-mode Workspaces; maintains a reusable cross-agency `ClientProfile`, negotiates/approves Media Packages & Campaigns, submits `Content Request`s, uploads Brand Guidelines, and signs off final deliverables |
| **`Admin`** | `ADMIN` | Platform-level operator governing system broadcasts, platform KPIs, 5-host health monitoring, `Content Moderation Queue`, user accounts/strikes, AI Trend Crawler schedules, AI Credit unit pricing, SePay revenue, and PDF exports |

### 1.2 Functional Scope — 141 Atomic FRs across 9 Domains

The official baseline comprises **141 Functional Requirements (`3.2.1`–`3.10.14`)** mapped 1-to-1 with **141 Use Cases (`UC-001`–`UC-141`)**:

| SRS Section | Functional Domain | FR Range | UC Range | Count | Primary Documentation |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **3.2** | Authentication & Authorization | `3.2.1`–`3.2.9` | `UC-001`–`UC-009` | **9** | [BA Auth & Profile](./ba/02-authentication-profile.md) · [Use Cases](./ba/use-cases/01-authentication-profile.md) · [SRS](./feature/srs/01-authentication/README.md) |
| **3.3** | User & Client Profile | `3.3.1`–`3.3.4` | `UC-010`–`UC-013` | **4** | [BA Auth & Profile](./ba/02-authentication-profile.md) · [Use Cases](./ba/use-cases/01-authentication-profile.md) · [SRS](./feature/srs/02-profile/README.md) |
| **3.4** | Agency & Workspace | `3.4.1`–`3.4.26` | `UC-014`–`UC-039` | **26** | [BA Agency & Workspace](./ba/03-agency-workspace.md) · [Use Cases](./ba/use-cases/02-agency-workspace.md) · [SRS](./feature/srs/03-agency-workspace/README.md) |
| **3.5** | Media Package & Media Campaign | `3.5.1`–`3.5.13` | `UC-040`–`UC-052` | **13** | [BA Package & Campaign](./ba/04-media-package-campaign.md) · [Use Cases](./ba/use-cases/03-media-package-campaign.md) · [SRS](./feature/srs/04-media-package-campaign/README.md) |
| **3.6** | Content & Workflow | `3.6.1`–`3.6.35` | `UC-053`–`UC-087` | **35** | [BA Content & Workflow](./ba/05-content-task-workflow.md) · [Use Cases](./ba/use-cases/04-content-task-workflow.md) · [SRS](./feature/srs/05-content-task-workflow/README.md) |
| **3.7** | AI Features | `3.7.1`–`3.7.19` | `UC-088`–`UC-106` | **19** | [BA AI Features](./ba/06-ai-features.md) · [Use Cases](./ba/use-cases/05-ai-features.md) · [SRS](./feature/srs/06-ai-features/README.md) |
| **3.8** | Publishing & Social | `3.8.1`–`3.8.15` | `UC-107`–`UC-121` | **15** | [BA Publishing & Social](./ba/07-publishing-social.md) · [Use Cases](./ba/use-cases/06-publishing-social.md) · [SRS](./feature/srs/07-publishing-social/README.md) |
| **3.9** | Subscription & Billing | `3.9.1`–`3.9.6` | `UC-122`–`UC-127` | **6** | [BA Subscription & Billing](./ba/08-subscription-billing.md) · [Use Cases](./ba/use-cases/07-subscription.md) · [SRS](./feature/srs/08-subscription-billing/README.md) |
| **3.10** | Admin Functions | `3.10.1`–`3.10.14` | `UC-128`–`UC-141` | **14** | [BA Admin Functions](./ba/09-admin-functions.md) · [Use Cases](./ba/use-cases/08-admin-functions.md) · [SRS](./feature/srs/09-admin-functions/README.md) |
| **Total** | **9 Canonical Domains** | **`3.2.1`–`3.10.14`** | **`UC-001`–`UC-141`** | **141** | [Feature Specifications Hub](./feature/README.md) · [BA Master Hub](./ba/README.md) · [Use Case Hub](./ba/use-cases/README.md) |

- **Supported Social Publishing Platforms (4 strictly)**: **Facebook**, **Instagram**, **TikTok**, and **Threads** (no Zalo OA).
- **Payment Gateway**: **SePay (VietQR)** with idempotent ACID webhook settlement and upgrade-only subscription progression (`FR 3.9.1 Upgrade Plan`, `FR 3.9.2 Make Payment (SePay)`).

### 1.3 Two Product Lines & Six Subscription Tiers

1. **BrandHub AI Studio** (`PERSONAL` Solo Creator & Small Team line): `STUDIO_FREE`, `STUDIO_PLUS`, `STUDIO_PRO`
2. **BrandHub Agency Suite** (`AGENCY` B2B Multi-Workspace line): `BASIC`, `PLUS`, `ENTERPRISE`

### 1.4 Polyglot Persistence & Production Topology

- **Five-Engine Polyglot Persistence Layer**:
  - **PostgreSQL 17** (`97` relational tables) — identity, RBAC, agencies/workspaces, packages/campaigns, Billing V3 (**SePay VietQR**), `agency_credit_wallets`, `ai_credit_reservations`, `product_video_*`, S3/Client Vault storage quotas, Google Drive sync, mail batches, and `user_notifications` (`LISTEN/NOTIFY`) (`database/init/init-postgres-v2.sql`).
  - **MongoDB 7.0** (`52` document collections) — 8-type `tasks`, `task_sections` & immutable approval histories, `content_requests`, `materials` (`RepositoryEnvelopeCrypto`), `video_projects`, STOMP `chat_*` + Agora calls, `surveys`, and `posts` / `social_accounts` / `publish_logs` (`database/init/init-mongo.js`).
  - **Redis 7** — RS256 JWT token blacklist, API Gateway sliding-window rate limits, OAuth PKCE/state, Vietnam trend ZSET cache, and publisher per-platform deduplication locks (`processingPostIds:{postId}:{platform}`).
  - **ChromaDB** — per-client `384`-dim HNSW embeddings (`paraphrase-multilingual-MiniLM-L12-v2` / `all-MiniLM-L6-v2`) for Brand Knowledge & Trend GraphRAG.
  - **Neo4j 5** — Trend Knowledge Graph computing Personalized PageRank, Degree & Betweenness Centrality plus 1–2 hop GraphRAG entity traversal.
- **Production Infrastructure (`AWS ap-southeast-1`, Account `134875421878` + `Vast.ai` GPU)**:
  - **5 EC2 Hosts**: `gateway` (`t3.small` — Nginx TLS + Spring Cloud Gateway `:8080`), `core` (`m7i-flex.large` — Business `:8081`, Publisher `:8083`, PostgreSQL, Redis, RabbitMQ, ChromaDB, nightly S3 `db-backup`, `crawl-gate`), `ai` (`c7i-flex.large` — FastAPI AI Service `:8082`), `crawl` (`c7i-flex.large` — auto-sleep/wake Trend Crawler `:8084`), and `edit-video` (`m7i-flex.large` — auto-sleep/wake FFmpeg renderer `:8095`), fronted by S3 + CloudFront (`brandhub.id.vn`) and SSE-KMS media buckets (`brandhub-media-134875421878`).
  - **GPU Synthesis Tier**: Vast.ai GPU workers (`gpu-workers/wan-vace/`) running ComfyUI + **Wan 2.2 Fun VACE 14B + Wan 2.2 S2V 14B + Qwen Image 2.1** + Ollama `qwen2.5vl:7b`, paired with Groq Llama 3 & Anthropic Claude.

---

## 2. Complete Knowledge Base Directory

| Directory | Hub | Purpose & Key Canonical Documents |
| :--- | :--- | :--- |
| **`rule/`** | [rule/README.md](./rule/README.md) | Mandatory engineering standards: [Feature 4-Doc Workflow](./rule/feature-workflow.md), [Git Commit & PR Convention](./rule/git-commit-convention.md), and [Team Working Rules](/view?file=rule/team-rules.html) |
| **`guides/`** | [guides/README.md](./guides/README.md) | Developer playbooks: [8-Step Team Development Guide](./guides/team-workflow-guide.md) and [Jira + Claude Setup](./guides/jira-claude-setup.md) |
| **`adr/`** | [adr/README.md](./adr/README.md) | Architecture Decision Records: [ADR-001 Polyrepo](./adr/adr-001-polyrepo.md), [ADR-002 Polyglot DB Split](./adr/adr-002-database-split.md), [ADR-003 RabbitMQ](./adr/adr-003-rabbitmq.md), [ADR-004 Spring Cloud Gateway](./adr/adr-004-spring-cloud-gateway.md) |
| **`architecture/`** | [architecture/README.md](./architecture/README.md) | System blueprints: [Technical Overview](./architecture/technical-overview.md), [Service Boundaries](./architecture/service-boundaries.md), [Local Run Architecture](./architecture/local-run-architecture.md), [AI Service Architecture](./architecture/ai-service-architecture.md), [Business ↔ AI REST Contract](./architecture/business-ai-rest-contract.md), [Interactive Architecture Diagram](/view?file=architecture/architecture.html) |
| **`api/`** | [api/README.md](./api/README.md) | REST, WebSocket & Gateway contracts: [Business & Publisher Endpoints (`630` routes)](./api/business-service-endpoints.md), [AI OpenAPI Spec (`68` routes)](./api/openapi-spec-ai-service.md), [RS256 JWT Auth Flow](./api/rs256-jwt-flow.md), [API Response Envelope](./api/api-response-format.md), [Redis Rate Limiting](./api/redis-rate-limiting-filter.md) |
| **`database/`** | [database/README.md](./database/README.md) | Polyglot persistence: [Database Strategy V2/V3](./database/schema/database-strategy.md), [ERD Entity Descriptions (`97` PG + `52` Mongo)](./database/schema/erd-entity-descriptions.md), [Interactive Schema Diagram](/view?file=database/schema/brandhub-schema-diagram.html), [Redis Key Patterns](./database/redis-cache/redis-key-patterns.md), [DB Access Rules](./database/redis-cache/database-access-rules.md), [ChromaDB + Neo4j Hybrid Schema](./database/ai-vector/hybrid-db-schema.md) |
| **`ba/`** | [ba/README.md](./ba/README.md) | Business Analysis Single Source of Truth: [Organization Hierarchy](./ba/01-organization-structure.md), Domain Specs `02`–`09`, [Roles & Permissions Matrix](./ba/10-roles-permissions-matrix.md), [Data Entities Glossary](./ba/11-data-entities-glossary.md), [State Machines](./ba/12-state-machines.md), and [141 Use Cases (`UC-001`–`UC-141`)](./ba/use-cases/README.md) |
| **`feature/`** | [feature/README.md](./feature/README.md) | `spec → plan → task → test` feature specifications organized into `feature/srs/` (141 SRS FRs across 9 domains) and `feature/modules/` (cross-cutting, mobile, and studio modules) |
| **`ai-models/`** | [ai-models/README.md](./ai-models/README.md) | AI algorithms & GPU synthesis: [Text Normalization & PhoBERT (`T0`–`T2.5`)](./ai-models/text-normalization-pipeline-design.md), [Temporal Burst & BM25 (`T4`)](./ai-models/trend-prediction-bm25-design.md), [Graph Virality (`T6`)](./ai-models/graph-virality-score-design.md), [Crawl Trend Blueprint](./ai-models/crawl-trend-blueprint.md), [AI Iteration 2 Blueprint](./ai-models/ai-iteration-2-implementation-blueprint.md), [Wan 2.2 VACE Video Report](./ai-models/video-generation-research-report.md) |
| **`operations/`** | [operations/README.md](./operations/README.md) | Production ops (`AWS Account 134875421878`): [5-EC2 Deployment Runbook](./operations/deployment-acct134.md) and [Wake-on-Request Architecture](./operations/wake-on-request.md) |
| **`wireframe/`** | [wireframe/README.md](./wireframe/README.md) | UI/UX architecture (`React 19.2` + `Tailwind 4.3`): [V2/V3 Wireframe Blueprint](./wireframe/wireframe-blueprint.md) and [Wireframe-to-Code Checklist](./wireframe/wireframe-to-code-checklist.md) |
| **`screenshots/`** | [screenshots/README.md](./screenshots/README.md) | Verified UI screenshot evidence (`D15`–`D19`, `136` PNGs + `DA-D15-10` backend ledger) for Report 3 SRS |
| **`plan/`** | [plan/README.md](./plan/README.md) | Project roadmaps & audits: [Master Plan](./plan/brandhub-master-plan.md), [Sprint Plan V2 Overview](./plan/sprint-plan-v2-overview.md), [AI Iterations `1`–`5`](./plan/iterations/README.md), [Jira & API/UX Audits](./plan/audit/README.md), [Live Workload Dashboard](./dashboard.md) |
| **`archive/`** | [archive/README.md](./archive/README.md) | Historical traceability: [Early Crawl & GraphRAG Brainstorm](./archive/crawl-data-algorithm/README.md), [V1 Legacy Artifacts](./archive/v1-legacy/README.md), and [Historical Completion Reports](./archive/reports/README.md) |

---

## 3. Repository & Operational Pointers Outside `docs/`

Executable infrastructure-as-code, SQL/Mongosh/Cypher migrations, Docker Compose stacks, and GPU worker bundles reside at the root of `brandhub-infrastructure`:

- **Database Init, Migrations & Backups**: `database/README.md`, `database/init/init-postgres-v2.sql`, `database/init/init-mongo.js`, `database/migrations/README.md` (`postgres/`, `mongodb/`, `neo4j/`), and `database/backups/README.md`
- **Local Docker Compose Stacks**: `docker/README.md`, `docker/compose/dev/compose.yaml`, `docker/compose/dev-ai/compose.yaml`, `docker/compose/shared/*.yaml`, and `docker/compose/seed-guide.md`
- **AWS Production Manifests & Terraform**: `prod/README.md`, `prod/hosts/README.md`, `prod/hosts/core/db-backup/README.md`, `prod/terraform/README.md` (`01-iam` → `04-storage`), and `prod/loadtest/README.md`
- **Vast.ai GPU Video Worker**: `gpu-workers/README.md` and `gpu-workers/wan-vace/README.md`
- **Security & Automation Scripts**: `SECURITY.md`, `.gitleaks.toml`, and `scripts/README.md`
- **Official Capstone Deliverables**: sibling repository `brandhub-final_report/` (`report1`–`report7`, including `report3/report3_official.docx`) and workspace baseline `Các FR của hệ thống  - Feature_Function Requirement.csv`
