# Sprint 3 — Database, API & UI Design

**Timeline:** Weeks 5–6 (Jun 16–30, 2026)
**Jira:** DA Sprint 3
**Phase:** Phase 1 — Initiation & Documentation
**Goal:** Finalize database schema design, define all API contracts, and produce Figma wireframes for all main screens.

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| E06 | Database Design | Trung, Tuấn, Ân |
| E07 | API Design & Swagger Spec | Trung, Tuấn, Phước |
| E08 | UI/UX Wireframe | Lộc |

**Deliverables by end of Sprint 3:**
- MongoDB schema: 12 collections fully designed
- PostgreSQL schema: 5 tables with constraints
- Redis key pattern document
- DBML diagram committed to dbdiagram.io
- OpenAPI YAML specs for business-service and ai-service
- RabbitMQ message contracts documented
- Figma wireframes for all main screens
- Component system design

---

## EPIC E06 — Database Design

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E06-01 | Define database strategy: which data goes into MongoDB, which into PostgreSQL, and why | Trung (Leader) | 🔴 Critical |
| DA-E06-02 | Design 12 MongoDB collections with full field types, required/optional flags, default values | Trung (Leader) | 🔴 Critical |
| DA-E06-03 | Design 5 PostgreSQL tables with constraints and internal foreign keys | Trung (Leader) | 🔴 Critical |
| DA-E06-04 | Define indexing strategy for MongoDB and PostgreSQL | Tuấn (AI) | 🟡 High |
| DA-E06-05 | Write DBML code for dbdiagram.io (MongoDB + PostgreSQL + Enums + Refs + TableGroups) | Tuấn (AI) | 🟡 High |
| DA-E06-06 | Document Redis key patterns (JWT blacklist, rate limit, OAuth state, trending cache) | Ân (AI) | 🟡 High |
| DA-E06-07 | Write database initialization scripts (init-mongo.js + init-postgres.sql) | Trung (Leader) | 🔴 Critical |
| DA-E06-08 | Write database access rules documentation (every query must include workspaceId filter; BRAND_CLIENT also requires clientId filter) | Trung (Leader) | 🔴 Critical |

**12 MongoDB collections:**
`users`, `workspaces`, `workspace_members`, `clients`, `social_accounts`, `posts`, `content_requests`, `knowledge_documents`, `notifications`, `publish_logs`, `ai_usage_logs`, `report_jobs`

**5 PostgreSQL tables:**
`subscription_plans`, `workspace_subscriptions`, `invoices`, `payments`, `audit_logs`

**Redis key patterns (Ân):**
- JWT blacklist: `jwt:blacklist:{jti}` → TTL = remaining token lifetime
- Rate limit: `ratelimit:{userId}:{minute}` → TTL = 60s
- OAuth state: `oauth:state:{state}` → TTL = 10 min
- Trending cache: `trends:vn:{date}:{category}` → TTL = 6h

**Notes:**
- DA-E06-01 must complete before E06-02/03 — the split strategy drives collection design.
- DA-E06-04 indexing: MongoDB compound index on `{workspaceId, createdAt}` for all content collections. PostgreSQL: index on `workspace_id` for all foreign key columns.
- DA-E06-07: init scripts must be idempotent (safe to run multiple times).

---

## EPIC E07 — API Design & Swagger Spec

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E07-01 | Define all endpoints for business-service (Auth, User, Workspace, Client, Post, ContentRequest, SocialAccount, Analytics, Report, Subscription, Admin) | Trung (Leader) | 🔴 Critical |
| DA-E07-02 | Define endpoints for ai-service (/ai/content, /ai/image, /ai/video, /ai/ambassador, /ai/rag, /ai/trends) | Tuấn (AI) | 🔴 Critical |
| DA-E07-03 | Define RabbitMQ message format for publisher-service (publish job + callback message contract) | Phước (Publisher) | 🔴 Critical |
| DA-E07-04 | Write standard API response format (ApiResponse wrapper, error codes, HTTP status codes) | Trung (Leader) | 🔴 Critical |
| DA-E07-05 | Write OpenAPI YAML spec for business-service | Trung (Leader) | 🟡 High |
| DA-E07-06 | Write OpenAPI YAML spec for ai-service (all internal + public endpoints) | Tuấn (AI) | 🟡 High |
| DA-E07-07 | Document social platform API specs: FB Graph API, TikTok Content API, Threads API, Zalo OA API (versions, rate limits, payload formats) | Phước (Publisher) | 🟡 High |

**ApiResponse wrapper format (DA-E07-04):**
```json
{
  "success": true,
  "data": { ... },
  "message": "string",
  "errorCode": null,
  "timestamp": "2026-06-16T10:00:00Z"
}
```

**RabbitMQ message contracts (DA-E07-03):**
- PublishJobMessage: `{postId, workspaceId, platform, contentText, mediaUrls[], scheduledAt, encryptedToken}`
- PublishCallbackMessage: `{postId, platform, status: PUBLISHED|FAILED, externalPostId?, errorMessage?, publishedAt}`

**Social platform rate limits (Phước to document):**
- Facebook Graph API v19: 200 calls/hour per user token
- TikTok Content API: 1000 calls/day
- Threads API: 250 posts/day
- Zalo OA: 100 posts/day

---

## EPIC E08 — UI/UX Wireframe

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E08-01 | Draw Figma wireframes for all main screens (Login, Dashboard, Workspace, Content Editor, Calendar, Client Portal, Analytics) | Lộc (Frontend) | 🔴 Critical |
| DA-E08-02 | Design component system (Button, Input, Modal, Table, Badge, Toast styles) | Lộc (Frontend) | 🔴 Critical |
| DA-E08-03 | Draw user flow diagrams for 3 main flows: content creation, approval, publishing | Lộc (Frontend) | 🟡 High |
| DA-E08-04 | Wireframe Client Portal (read-only calendar, approve/reject, analytics view) | Lộc (Frontend) | 🟡 High |

**Screens to wireframe (DA-E08-01):**
1. Login / Register / Forgot Password
2. Main Dashboard (role-aware: Agency Owner vs Content Creator view)
3. Workspace settings
4. Client list + Client detail
5. Content Request list
6. Content Editor (with AI Generate panel)
7. Content Calendar
8. Platform Preview modal
9. Client Portal (isolated view)
10. Analytics Dashboard

---

## Sprint 3 Checklist

- [ ] DB strategy document: MongoDB vs PostgreSQL split rationale written
- [ ] All 12 MongoDB collections designed with full fields
- [ ] All 5 PostgreSQL tables designed with constraints
- [ ] Indexing strategy documented
- [ ] DBML diagram live on dbdiagram.io
- [ ] Redis key patterns documented
- [ ] Database init scripts written and tested
- [ ] All business-service endpoints defined (DA-E07-01)
- [ ] All ai-service endpoints defined (DA-E07-02)
- [ ] RabbitMQ message contracts defined
- [ ] Standard ApiResponse format agreed and documented
- [ ] OpenAPI YAML specs committed for business-service and ai-service
- [ ] Social platform API specs documented (versions + rate limits)
- [ ] Figma wireframes for all 10 main screens
- [ ] Component system defined in Figma
