# ADR-002 — 5-Engine Polyglot Persistence Split

> Navigation: [← Knowledge Base Hub](../index.md) · [← ADR Index](./README.md) · [Database Hub](../database/README.md) · [DB Ownership Diagram](/view?file=architecture/db-ownership-diagram.html)

- **Status:** Accepted
- **Owners:** Core Backend & AI Architecture Leads
- **Related Docs:** [Database Strategy V2](../database/schema/database-strategy.md) · [ERD Entity Descriptions](../database/schema/erd-entity-descriptions.md) · [Database Access Rules](../database/redis-cache/database-access-rules.md)

---

## 1. Context & Problem Statement

BrandHub workloads exhibit five fundamentally different data shapes, consistency guarantees, and query access patterns:
1. **Strict ACID Financial, Identity & Organizational Invariants**: Two-tier tenant hierarchy (`Agency` with immutable `agencies.owner_id` → `Workspace` with per-workspace `Manager`, `Creator`, `Client`), dual-party Media Package sign-off (`approved_by_agency_at` + `approved_by_client_at`), **SePay (VietQR)** upgrade-only subscription orders, and double-entry AI credit & S3 storage ledgers cannot tolerate eventual consistency or lost updates.
2. **Polymorphic, High-Write Content & Collaboration Documents**: `Task` deliverables (`POST`, `SURVEY`, `SHORT_VIDEO`, `EVENT_PLAN`, `PRESS_RECOMMENDATION`, `KOL_BOOKING`, `WORKSHOP`, `EMAIL_NEWSLETTER`), append-only multi-round approvals, Yjs/rich-text snapshots, workspace chat threads, and Video Space timelines evolve rapidly with deeply nested payloads.
3. **Sub-Millisecond Ephemeral Coordination**: JWT `jti` revocation checks on every HTTP call, gateway sliding-window rate counters, OAuth CSRF states, and distributed publish locks.
4. **Dense Semantic Vector Search**: Tenant-isolated `384d` chunk retrieval over uploaded PDF/DOCX/URL Brand Guidelines (`FR 3.7.3`–`3.7.5`).
5. **Multi-Hop Social Entity Traversal**: Personalized PageRank, entity co-occurrence, and source-post provenance across crawled Vietnamese social trends (`FR 3.7.1`–`3.7.2`, `FR 3.7.6`).

---

## 2. Evaluated Options

| Option | Pros | Cons / Why Rejected or Selected |
| :--- | :--- | :--- |
| **Option A: PostgreSQL-Only** (`JSONB` + `pgvector` + recursive CTEs) | Single backup/transaction boundary; native SQL joins everywhere | Heavy write amplification on chat/task section edits and survey responses; recursive CTE graph scoring (`PageRank` / `WCC`) degrades sharply on noisy social graphs; couples AI vector load to core billing CPU (`core` EC2 `640m` Postgres budget) |
| **Option B: MongoDB-Only** (Multi-document transactions for billing/RBAC) | Uniform document model across services | Lacks native relational FK cascades across the 97-table organizational/billing spine; awkward double-entry credit grant allocation (`credit_reservation_allocations`) |
| **Option C: 5-Engine Polyglot Persistence with Strict Single-Service Ownership** *(Selected)* | Matches each workload to its purpose-built engine; isolates AI/graph memory from transactional billing | Requires application-level UUID joins, transactional outbox tables, and unified multi-engine backups (`db-backup`) |

---

## 3. Decision Architecture & Ownership Matrix

Every table, collection, or key namespace has **exactly one owning service** ([Service Boundaries](../architecture/service-boundaries.md)):

| Engine & Version | Production Placement | Scale | Owning Service(s) | Assigned Domain Data |
| :--- | :--- | :---: | :--- | :--- |
| **PostgreSQL 17** (`postgres:17-alpine`) | `core` EC2 (`brandhub-postgres`) | **97 tables** | `business-service` (`100%`) | Identity (`users`, `user_refresh_tokens`), `agencies` (`AGENCY` \| `PERSONAL`), `workspaces`, `workspace_members`, `client_profiles`, `media_packages`, `media_campaigns`, 6-plan SePay billing (`billing_plan_versions`, `billing_plan_cycle_prices`, `billing_orders`, `transactions`), AI credit & storage ledgers (`agency_credit_wallets`, `ai_credit_reservations`, `product_video_*`, `client_vault_*`), `engagement_reminders`, `user_notifications` (`LISTEN/NOTIFY`) |
| **MongoDB 7.0** (`mongo:7.0` local / **Atlas** prod) | Local Docker / MongoDB Atlas | **52 collections** | `business-service` (`49`), `ai-service` (`2`), `publisher-service` (`1`) | `tasks`, `task_approvals`, `task_sections`, `posts`, `content_requests`, `materials`, `material_folders`, `material_versions`, `client_vault_shares`, `chat_*` (`8` collections), `video_*` (`4` collections), `surveys`, `mail_templates`, `social_accounts` (Facebook, Instagram, TikTok, Threads), `monitoring_*`, `knowledge_documents`, `ai_usage_logs`, `publish_logs` |
| **Redis 7.2** (`redis:7.2-alpine`, AOF) | `core` EC2 (`172.31.24.149:6379`) | Key-Value / ZSET | `api-gateway`, `business-service`, `ai-service`, `publisher-service` | `jwt:blacklist:{jti}`, `ratelimit:gateway:{userId}:{minute}`, `oauth:state:{state}`, `processingPostIds:{postId}:{platform}`, `trends:vn:{date}:{category}` |
| **ChromaDB 1.5.9** (`chromadb/chroma:1.5.9`) | `core` EC2 (`172.31.24.149:8000`) | `384d` Cosine HNSW | `ai-service` | Per-tenant Brand Knowledge collections (`client_{clientId}` / `brandhub_rag` filtered by `where={"clientId": ...}`) |
| **Neo4j 5.26** (Community local / **Aura** prod) | Local add-on / Neo4j Aura | Property Graph | `ai-service` | `:Trend`, `:CrawledPost`, `:KOL`, `:Brand`, `:Location`, `:Dish` nodes + APOC Entity Resolution |

---

## 4. Real Codebase & Infrastructure Grounding

- **Bootstrap & Migrations (`database/`)**: `database/init/init-postgres-v2.sql` creates all 97 PostgreSQL tables (33 JPA `@Entity` classes + 64 SQL/JDBC tables in `brandhub-business-service`), while `database/init/init-mongo.js` creates all 52 MongoDB collections with `$jsonSchema` validators (29 `@Document` classes + 23 `MongoTemplate`/service stores). Incremental upgrades live in `database/migrations/{postgres,mongodb,neo4j}/`.
- **Cross-Store Consistency Without 2PC**: Cross-database workflows use durable outbox/tracking tables rather than distributed two-phase commits:
  - Campaign approval (`FR 3.5.8`) records `campaign_deployments` in PostgreSQL and idempotently materializes `tasks` in MongoDB (guarded by unique index `uq_tasks_campaign_work_item`).
  - Material upload/purge writes `material_audit_outbox` in MongoDB and reconciles quota bytes into `agency_storage_usage` / `client_vault_storage_usage` via `material_audit_receipts` in PostgreSQL.
- **Unified Nightly Backups (`prod/hosts/core/db-backup/`)**: A single FastAPI + APScheduler container on `core` EC2 dumps all 5 engines daily at `00:00 Asia/Ho_Chi_Minh` (`pg_dump -Fc`, `mongodump --archive --gzip`, `redis-cli --rdb`, ChromaDB `.tar.gz`, and Neo4j Bolt `.jsonl.gz`) into `s3://brandhub-db-backup-prd-134875421878` with 30-day lifecycle retention and point-in-time `POST /restore`.

---

## 5. Trade-offs & Operational Impact

### Positive Outcomes
- **Zero Financial Drift**: PostgreSQL row locks, immutable `billing_guard_plan_version` triggers, and `ai_credit_reservations` guarantee exact SePay billing and credit accounting even when upstream AI/GPU calls fail.
- **Schema Agility for Creative Tools**: Adding specialist task sections (`DA-1274`), chat attachments, or Video Space auto-edits only extends MongoDB `$jsonSchema` validators without locking relational tables.
- **Sub-20ms Trend Reads**: Serving ranked trends from Redis backed by Neo4j Aura + ChromaDB keeps heavy NLP/graph workloads off the transactional database.

### Accepted Costs & Mitigations
- **Application-Layer Soft Joins**: MongoDB documents reference PostgreSQL UUIDs (`workspaceId`, `campaignId`, `createdByClientProfileId`) without database-enforced foreign keys; enforced via mandatory repository-layer filters in [Database Access Rules](../database/redis-cache/database-access-rules.md).
- **Multi-Engine Operational Surface**: Engineers manage SQL, `mongosh`, and Cypher migrations, mitigated by deterministic Docker init mounts (`docker/compose/shared/databases.yaml`) and automated S3 backup/restore (`db-backup`).
