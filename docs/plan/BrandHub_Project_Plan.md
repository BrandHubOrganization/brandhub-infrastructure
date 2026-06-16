# BrandHub — Project Epic & Sprint Plan

---

## TEAM & PROJECT INFO

| Field | Detail |
|---|---|
| Project | BrandHub — AI-Powered Multi-Channel Content Platform |
| Team | Trung (Leader), Lộc (Frontend), Tuấn (AI), Ân (AI), Phước (Publisher) |
| Total Sprints | 16 Sprints (2 weeks each) + 4 AI Parallel Iterations |
| Duration | ~32 weeks |
| Stack | Java Spring Boot 3, Python FastAPI, React 18, React Native, MongoDB, PostgreSQL, Redis, ChromaDB, RabbitMQ, AWS S3 |

---

## TECH STACK SUMMARY

| Layer | Technology |
|---|---|
| Web Frontend | React 18 + Vite + TypeScript + Tailwind CSS + shadcn/ui |
| Mobile | React Native + Expo |
| Backend Business | Java 21 + Spring Boot 3 + Spring Security |
| Backend AI | Python 3.11 + FastAPI + LangChain |
| Backend Publisher | Java 21 + Spring Boot 3 |
| API Gateway | Spring Cloud Gateway |
| Primary DB | MongoDB (documents, content, social accounts) |
| Relational DB | PostgreSQL (payments, subscriptions, audit logs) |
| Cache | Redis (JWT blacklist, rate limit, OAuth state, trending cache) |
| Vector DB | ChromaDB (brand embeddings for RAG) |
| Message Queue | RabbitMQ (async publishing queue) |
| File Storage | AWS S3 |
| LLM | Llama 3 via Groq API + Claude API (fallback) |
| Image Gen | Stability AI API (SDXL) |
| Video Gen | Google Veo API |
| Virtual Ambassador | InstantID + InsightFace + ControlNet |
| Auth | JWT (Access: 15 min, Refresh: 30 days) + Google OAuth |
| Container | Docker + Docker Compose |
| CI/CD | GitHub Actions |
| Project Mgmt | Linear (sprints) + GitHub (code) |

---

## SYSTEM ARCHITECTURE

```
[Web Dashboard]  [Mobile App]
       |               |
   [API Gateway — Spring Cloud Gateway — Port 8080]
       |         |              |
[Business Svc] [AI Svc]  [Publisher Svc]
   Port 8081   Port 8082    Port 8083
       |           |              |
  [MongoDB]  [ChromaDB]     [RabbitMQ]
  [PostgreSQL] [AWS S3]     [Social APIs]
  [Redis]
```

**7 Repositories:** brandhub-business-service, brandhub-ai-service, brandhub-publisher-service, brandhub-api-gateway, brandhub-web-dashboard, brandhub-mobile-app, brandhub-infrastructure

---

## ROLES

| Role | Description |
|---|---|
| `ADMIN` | System admin — manages users, plans, platform |
| `AGENCY_OWNER` | Creates workspace, manages team & clients, billing |
| `ACCOUNT_MANAGER` | Manages assigned clients, reviews content, sends reports |
| `CONTENT_CREATOR` | Creates AI content, manages knowledge base, schedules posts |
| `BRAND_CLIENT` | View-only client portal: approve/reject content, view reports |
| `GUEST` | Unauthenticated — landing page + register only |

---

## PRIORITY LEGEND

| Symbol | Meaning |
|---|---|
| 🔴 Critical | Blocking other tasks, core architecture, auth, database schema |
| 🟡 High | Important features, CI/CD, main API endpoints |
| 🟢 Medium | Docs, testing, secondary features |

---

## PHASE 1 — Initiation & Documentation

---

## Sprint 1 — Project Kickoff (Weeks 1–2)

### EPIC E01 — Project Initiation

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E01-01 | Brainstorm and align on BrandHub topic idea, define scope and MVP | All (Team) | 🔴 Critical |
| DA-E01-02 | Team meeting to confirm roles and responsibilities of each member | Trung (Leader) | 🔴 Critical |
| DA-E01-03 | Find and contact a mentor suitable for the AI + microservices topic | Trung (Leader) | 🔴 Critical |
| DA-E01-04 | Assess each team member's technical skills (Java, Python, React, AI tools) | All (Team) | 🟡 High |
| DA-E01-05 | Submit project registration form on the Call4project system (insideuni.fpt.edu.vn) | Trung (Leader) | 🔴 Critical |

### EPIC E02 — Project Management Setup

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E02-01 | Create Linear workspace, set up 2-week sprint cadence, create issue templates | Trung (Leader) | 🔴 Critical |
| DA-E02-02 | Create GitHub Organization and 7 repos following polyrepo structure | Trung (Leader) | 🔴 Critical |
| DA-E02-03 | Set up branch protection rules, PR template, commit convention (Conventional Commits) | Trung (Leader) | 🔴 Critical |
| DA-E02-04 | Create project email and accounts for all services (AWS, GitHub Actions, Groq, Stability AI, etc.) | Trung (Leader) | 🔴 Critical |

---

## Sprint 2 — Requirements & Architecture (Weeks 3–4)

### EPIC E03 — Use Case Documentation

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E03-01 | List and group all 60 use cases by 6 roles (Admin, Agency Owner, Account Manager, Content Creator, Brand Client, Guest) | Phước (Publisher) | 🔴 Critical |
| DA-E03-02 | Write detailed descriptions for UC 01–20 (Admin + Agency Owner flows) — actor, description, main flow, alt flows | Trung (Leader) | 🔴 Critical |
| DA-E03-03 | Write detailed descriptions for UC 21–40 (Account Manager + Content Creator flows) | Phước (Publisher) | 🔴 Critical |
| DA-E03-04 | Write detailed descriptions for UC 41–60 (Brand Client + Social Publishing flows) | Phước (Publisher) | 🟡 High |
| DA-E03-05 | Review UC list with mentor, update based on feedback | All (Team) | 🟡 High |
| DA-E03-06 | Finalize UC table into Excel file (BrandHub_UseCases.xlsx) | Phước (Publisher) | 🟢 Medium |

### EPIC E04 — Functional & Non-Functional Requirements

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E04-01 | Write functional objectives per role (6 roles x features) | Trung (Leader) | 🔴 Critical |
| DA-E04-02 | Write non-functional requirements (UI, Performance, Security, Reliability, Usability) | Trung (Leader) | 🔴 Critical |
| DA-E04-03 | Add AI performance requirements (latency, throughput, model accuracy thresholds) to non-functional section | Ân (AI) | 🟡 High |
| DA-E04-04 | Add mobile requirements (FCM, offline draft, camera) to non-functional section | Lộc (Frontend) | 🟡 High |
| DA-E04-05 | Fill in and finalize the Capstone Register form (BrandHub_Capstone_Register.docx) | Trung (Leader) | 🔴 Critical |

### EPIC E05 — System Architecture Design

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E05-01 | Draw system architecture overview diagram (7 services + 5 databases + RabbitMQ + clients) | Trung (Leader) | 🔴 Critical |
| DA-E05-02 | Define service responsibilities and boundaries (what each of the 7 services does and does NOT do) | Trung (Leader) | 🔴 Critical |
| DA-E05-03 | Draw database ownership diagram (which service owns which DB, cross-DB reference strategy) | Trung (Leader) | 🔴 Critical |
| DA-E05-04 | Document service-to-service communication (REST: business-ai, RabbitMQ: business-publisher, HTTP callback: publisher-business) | Trung (Leader) | 🔴 Critical |
| DA-E05-05 | Write Architecture Decision Records (ADRs) for 4 key decisions: polyrepo, MongoDB+PostgreSQL split, RabbitMQ, Spring Cloud Gateway | Trung (Leader) | 🔴 Critical |
| DA-E05-06 | Draw sequence diagrams for 4 core flows: content creation, approval workflow, auto-publishing, OAuth token refresh | Tuấn (AI) | 🔴 Critical |
| DA-E05-07 | Write the AI architecture section in the Technical Document (ai-service internal design, ChromaDB schema, LLM routing strategy) | Tuấn (AI) | 🟡 High |
| DA-E05-08 | Compile full technical document (BrandHub_Technical_Document.md) | Trung (Leader) | 🟡 High |

---

## Sprint 3 — Database, API & UI Design (Weeks 5–6)

### EPIC E06 — Database Design

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E06-01 | Define database strategy: which data goes into MongoDB, which into PostgreSQL, and why | Trung (Leader) | 🔴 Critical |
| DA-E06-02 | Design 12 MongoDB collections with full field types, required/optional flags, default values | Trung (Leader) | 🔴 Critical |
| DA-E06-03 | Design 5 PostgreSQL tables with constraints and internal foreign keys | Trung (Leader) | 🔴 Critical |
| DA-E06-04 | Define indexing strategy for MongoDB and PostgreSQL | Tuấn (AI) | 🟡 High |
| DA-E06-05 | Write DBML code for dbdiagram.io (MongoDB + PostgreSQL + Enums + Refs + TableGroups) | Tuấn (AI) | 🟡 High |
| DA-E06-06 | Document Redis key patterns (JWT blacklist, rate limit, OAuth state, trending cache) | Ân (AI) | 🟡 High |
| DA-E06-07 | Write database initialization scripts (init-mongo.js + init-postgres.sql) | Trung (Leader) | 🔴 Critical |
| DA-E06-08 | Write database access rules documentation (every query must include workspaceId filter; BRAND_CLIENT additionally requires clientId filter) | Trung (Leader) | 🔴 Critical |

### EPIC E07 — API Design & Swagger Spec

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E07-01 | Define all endpoints for business-service (Auth, User, Workspace, Client, Post, ContentRequest, SocialAccount, Analytics, Report, Subscription, Admin) | Trung (Leader) | 🔴 Critical |
| DA-E07-02 | Define endpoints for ai-service (/ai/content, /ai/image, /ai/video, /ai/ambassador, /ai/rag, /ai/trends) | Tuấn (AI) | 🔴 Critical |
| DA-E07-03 | Define RabbitMQ message format for publisher-service (publish job + callback message contract) | Phước (Publisher) | 🔴 Critical |
| DA-E07-04 | Write standard API response format (ApiResponse wrapper, error codes, HTTP status codes) | Trung (Leader) | 🔴 Critical |
| DA-E07-05 | Write OpenAPI YAML spec for business-service | Trung (Leader) | 🟡 High |
| DA-E07-06 | Write OpenAPI YAML spec for ai-service (all internal + public endpoints) | Tuấn (AI) | 🟡 High |
| DA-E07-07 | Document social platform API specs: FB Graph API, TikTok Content API, Threads API, Zalo OA API (versions, rate limits, payload formats) | Phước (Publisher) | 🟡 High |

### EPIC E08 — UI/UX Wireframe

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E08-01 | Create Figma wireframes for all main screens (Login, Dashboard, Workspace, Content Editor, Calendar, Client Portal, Analytics) | Lộc (Frontend) | 🔴 Critical |
| DA-E08-02 | Design component system (Button, Input, Modal, Table, Badge, Toast styles) | Lộc (Frontend) | 🔴 Critical |
| DA-E08-03 | Draw user flow diagrams for 3 main flows: content creation, approval, publishing | Lộc (Frontend) | 🟡 High |
| DA-E08-04 | Wireframe Client Portal (read-only calendar, approve/reject, analytics view) | Lộc (Frontend) | 🟡 High |

---

## PHASE 2 — Infrastructure Setup

---

## Sprint 4 — Infrastructure, CI/CD & Gateway (Weeks 7–8)

### EPIC E09 — Development Environment Setup

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E09-01 | Write docker-compose.yml to run the full infrastructure stack: MongoDB, PostgreSQL, Redis, RabbitMQ, ChromaDB | Trung (Leader) | 🔴 Critical |
| DA-E09-02 | Write init-mongo.js (create collections + indexes) and init-postgres.sql (create tables + seed subscription plans) | Trung (Leader) | 🔴 Critical |
| DA-E09-03 | Write .env.example consolidating all environment variables across 6 services | Trung (Leader) | 🔴 Critical |
| DA-E09-04 | Write clone-all.sh script to clone all 7 repos locally with a single command | Trung (Leader) | 🟡 High |
| DA-E09-05 | Write README.md for the infrastructure repo (step-by-step setup guide) | Phước (Publisher) | 🟢 Medium |

### EPIC E10 — CI/CD Pipeline

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E10-01 | Write GitHub Actions workflow for business-service (build + test + push Docker image) | Trung (Leader) | 🟡 High |
| DA-E10-02 | Write GitHub Actions workflow for publisher-service (build + test + push Docker image) | Phước (Publisher) | 🟡 High |
| DA-E10-03 | Write GitHub Actions workflow for ai-service (lint + test + build Docker image) | Tuấn (AI) | 🟡 High |
| DA-E10-04 | Write GitHub Actions workflow for web-dashboard (lint + build + deploy) | Lộc (Frontend) | 🟡 High |
| DA-E10-05 | Set up branch protection rules (require 1 approval before merging into develop) | Trung (Leader) | 🟢 Medium |

### EPIC E11 — API Gateway

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E11-01 | Initialize brandhub-api-gateway project with Spring Cloud Gateway | Trung (Leader) | 🔴 Critical |
| DA-E11-02 | Write JWT validation filter (verify token on every request, extract userId + role into headers) | Trung (Leader) | 🔴 Critical |
| DA-E11-03 | Write rate limiting filter using Redis (100 requests/minute/user) | Trung (Leader) | 🔴 Critical |
| DA-E11-04 | Configure routing rules (map URL paths to the correct service) | Trung (Leader) | 🔴 Critical |
| DA-E11-05 | Write logging filter (log all inbound and outbound requests for debugging) | Trung (Leader) | 🟢 Medium |

---

## PHASE 3 — Backend Core

---

## Sprint 5 — Authentication & RBAC (Weeks 9–10)

### EPIC E12 — Authentication

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E12-01 | Implement Register API (validate email uniqueness, hash password with bcrypt cost=12) | Trung (Leader) | 🔴 Critical |
| DA-E12-02 | Implement Login API (verify password, issue JWT access token 15 min + refresh token 30 days) | Trung (Leader) | 🔴 Critical |
| DA-E12-03 | Implement Refresh Token API (verify refresh token, issue new access token) | Trung (Leader) | 🔴 Critical |
| DA-E12-04 | Implement Logout API (add JWT jti to Redis blacklist, clear cookie) | Trung (Leader) | 🔴 Critical |
| DA-E12-05 | Implement Forgot Password & Reset Password flow (email link with time-limited token) | Trung (Leader) | 🔴 Critical |
| DA-E12-06 | Implement Google OAuth login (callback, create user if not yet registered) | Trung (Leader) | 🟡 High |

### EPIC E13 — User & Profile Management

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E13-01 | Implement GET/PUT /api/v1/users/me (retrieve and update user profile) | Trung (Leader) | 🔴 Critical |
| DA-E13-02 | Implement avatar upload (receive file → upload to S3 → save URL to MongoDB) | Trung (Leader) | 🟡 High |
| DA-E13-03 | Implement Admin: GET /api/v1/admin/users (list all users with filters) | Ân (AI) | 🟡 High |
| DA-E13-04 | Implement Admin: Ban/Suspend user (set isActive=false, send notification) | Ân (AI) | 🟡 High |

### EPIC E14 — Role-Based Access Control (RBAC)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E14-01 | Write RBAC annotation/middleware for business-service (@RequireRole) | Trung (Leader) | 🔴 Critical |
| DA-E14-02 | Implement workspace isolation filter (every MongoDB query must include workspaceId filter) | Trung (Leader) | 🔴 Critical |
| DA-E14-03 | Implement client isolation for BRAND_CLIENT (can only view data belonging to their own clientId) | Trung (Leader) | 🔴 Critical |
| DA-E14-04 | Write permission matrix document (6 roles x all endpoints = allowed/not allowed) | Phước (Publisher) | 🟢 Medium |

---

## Sprint 6 — Workspace, Client & Subscription (Weeks 11–12)

### EPIC E15 — Workspace Management

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E15-01 | Implement POST /api/v1/workspaces (create new workspace, AGENCY_OWNER role) | Trung (Leader) | 🔴 Critical |
| DA-E15-02 | Implement GET /api/v1/workspaces/mine (retrieve workspace of the current user) | Trung (Leader) | 🔴 Critical |
| DA-E15-03 | Implement POST /api/v1/workspaces/{id}/members (invite member via email) | Trung (Leader) | 🔴 Critical |
| DA-E15-04 | Implement DELETE /api/v1/workspaces/{id}/members/{userId} (remove a member) | Trung (Leader) | 🟡 High |
| DA-E15-05 | Implement workspace settings (timezone, default platforms, report frequency) | Trung (Leader) | 🟡 High |

### EPIC E16 — Client & Agency Management

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E16-01 | Implement POST /api/v1/clients (AGENCY_OWNER creates a new brand client) | Trung (Leader) | 🔴 Critical |
| DA-E16-02 | Implement PUT /api/v1/clients/{id}/assign (AGENCY_OWNER assigns an Account Manager) | Trung (Leader) | 🔴 Critical |
| DA-E16-03 | Implement PUT /api/v1/clients/{id}/service-package (set monthly post limits and platforms) | Trung (Leader) | 🟡 High |
| DA-E16-04 | Implement GET /api/v1/clients (AGENCY_OWNER and ACCOUNT_MANAGER view client list) | Trung (Leader) | 🔴 Critical |

### EPIC E17 — Subscription & Billing

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E17-01 | Implement Admin CRUD for subscription plans (Free/Basic/Pro/Enterprise) | Trung (Leader) | 🔴 Critical |
| DA-E17-02 | Implement POST /api/v1/subscriptions/subscribe (AGENCY_OWNER subscribes to a plan) | Trung (Leader) | 🔴 Critical |
| DA-E17-03 | Implement payment flow (integrate payment gateway, create invoice) | Trung (Leader) | 🔴 Critical |
| DA-E17-04 | Implement GET /api/v1/subscriptions/invoices (billing history) | Ân (AI) | 🟡 High |

---

## PHASE 4 — Social Integration & AI Pipeline

---

## Sprint 7 — Social OAuth & Token Management (Weeks 13–14)

### EPIC E18 — Meta OAuth (Facebook + Instagram)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E18-01 | Implement Facebook Fanpage OAuth flow (redirect → callback → token exchange) | Phước (Publisher) | 🔴 Critical |
| DA-E18-02 | Implement Instagram Business account connection (linked via Facebook Business) | Phước (Publisher) | 🔴 Critical |
| DA-E18-03 | Implement AES-256 encryption for access token + refresh token before saving to MongoDB | Trung (Leader) | 🔴 Critical |
| DA-E18-04 | Implement disconnect flow (revoke token at Meta, remove from MongoDB) | Phước (Publisher) | 🟡 High |

### EPIC E19 — TikTok, Threads & Zalo OA OAuth

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E19-01 | Implement TikTok for Business OAuth (Client Credentials Flow) | Phước (Publisher) | 🔴 Critical |
| DA-E19-02 | Implement Threads OAuth (using Meta Graph API, scope: threads_basic + threads_content_publish) | Phước (Publisher) | 🔴 Critical |
| DA-E19-03 | Implement Zalo Official Account OAuth | Phước (Publisher) | 🔴 Critical |
| DA-E19-04 | Implement token status dashboard API (view ACTIVE/EXPIRED/REVOKED status for all accounts) | Trung (Leader) | 🟡 High |

### EPIC E20 — Token Lifecycle Management

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E20-01 | Implement scheduled token refresh job (runs at 2:00 AM daily, refreshes tokens expiring within 7 days) | Trung (Leader) | 🔴 Critical |
| DA-E20-02 | Implement alert notification when token refresh fails (send notification to Account Manager) | Trung (Leader) | 🔴 Critical |
| DA-E20-03 | Implement manual token refresh API (Account Manager triggers refresh manually) | Phước (Publisher) | 🟡 High |

---

## Sprint 8 — Publisher Service (Weeks 15–16)

### EPIC E21 — Publisher Service Core

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E21-01 | Initialize brandhub-publisher-service project (Spring Boot 3, RabbitMQ consumer setup) | Phước (Publisher) | 🔴 Critical |
| DA-E21-02 | Implement RabbitMQ consumer: receive PublishJobMessage (postId, platform, content, mediaUrls, scheduledAt) | Phước (Publisher) | 🔴 Critical |
| DA-E21-03 | Implement Facebook publish adapter (Graph API v19: /me/feed + /me/photos) | Phước (Publisher) | 🔴 Critical |
| DA-E21-04 | Implement Instagram publish adapter (Content Publishing API: create container → publish) | Phước (Publisher) | 🔴 Critical |
| DA-E21-05 | Implement TikTok publish adapter (Content Posting API v2) | Phước (Publisher) | 🔴 Critical |
| DA-E21-06 | Implement Threads publish adapter (Threads API: create container → publish, max 500 chars) | Phước (Publisher) | 🔴 Critical |
| DA-E21-07 | Implement Zalo OA publish adapter (Article API + Photo API) | Phước (Publisher) | 🔴 Critical |

### EPIC E22 — Publish Callback & Error Handling

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E22-01 | Implement HTTP callback to business-service after publishing completes (POST /internal/posts/{id}/publish-result) | Phước (Publisher) | 🔴 Critical |
| DA-E22-02 | Implement retry logic: on failure → retry up to 3 times with exponential backoff (1m, 5m, 15m) | Phước (Publisher) | 🔴 Critical |
| DA-E22-03 | Implement business-service handler for publish callback (update post status, create notification) | Trung (Leader) | 🔴 Critical |

---

## Sprint 9 — AI Service Wiring & Business Integration (Weeks 17–18)

### EPIC E23 — AI Service Internal API Wiring

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E23-01 | Expose /internal/ai/content/generate endpoint (receive topic + clientId + platform → return caption + hashtags) | Tuấn (AI) | 🔴 Critical |
| DA-E23-02 | Expose /internal/ai/image/generate endpoint (receive prompt + style → return S3 URL) | Tuấn (AI) | 🔴 Critical |
| DA-E23-03 | Expose /internal/ai/ambassador/generate endpoint (receive faceImage + productImage → return S3 URL) | Tuấn (AI) | 🔴 Critical |
| DA-E23-04 | Expose /internal/ai/video/generate endpoint (receive script + style → return S3 URL, async with polling) | Ân (AI) | 🔴 Critical |
| DA-E23-05 | Expose /internal/ai/trends/fetch endpoint (return top trending topics by platform + region) | Ân (AI) | 🟡 High |

### EPIC E24 — Business Service AI Integration

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E24-01 | Implement AI content generation flow in business-service: ContentRequest → call ai-service → save draft Post | Trung (Leader) | 🔴 Critical |
| DA-E24-02 | Implement image/ambassador generation trigger from Post editor (user selects AI generate image) | Trung (Leader) | 🔴 Critical |
| DA-E24-03 | Implement AI usage tracking (count ai_credits_per_month against subscription plan limits) | Trung (Leader) | 🟡 High |

---

## AI PARALLEL TRACK — AI Research & Implementation

> **Note:** AI Track runs in parallel alongside Sprints 5–12. Each AI Iteration is 2 weeks.

---

## AI Iteration 1 — Research & Evaluation (Parallel with Sprints 5–6)

### EPIC AI-01 — AI Model Research & Evaluation

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI01-01 | Research and compare InstantID vs IP-Adapter vs ControlNet for face-consistent virtual ambassador generation | Tuấn (AI) | 🔴 Critical |
| DA-AI01-02 | Test 3 virtual ambassador tools on 5 sample images, write comparison table (quality, speed, cost) | Tuấn (AI) | 🔴 Critical |
| DA-AI01-03 | Research Google Veo API: capabilities, pricing, rate limits, movement parameters | Ân (AI) | 🔴 Critical |
| DA-AI01-04 | Collect and test 20+ video generation prompts with various movement parameters, classify results | Ân (AI) | 🔴 Critical |
| DA-AI01-05 | Research product + model image compositing techniques: ControlNet inpainting, DALL-E edit, rembg + composite | Lộc (Frontend) | 🟡 High |
| DA-AI01-06 | Test 3 compositing methods on 10 product + model image pairs, evaluate naturalness and compute cost | Lộc (Frontend) | 🟡 High |
| DA-AI01-07 | Compare Llama 3 (Groq) vs Claude API: Vietnamese caption quality, speed, cost per call | All (Team) | 🔴 Critical |
| DA-AI01-08 | Write AI Research Summary Document consolidating results from all 3 tracks, save to docs/ repo | Ân (AI) | 🟢 Medium |

### EPIC AI-02 — AI Service Infrastructure Setup

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI02-01 | Initialize brandhub-ai-service project: FastAPI + Python 3.11 + folder structure (api/services/models/utils) | Lộc (Frontend) | 🔴 Critical |
| DA-AI02-02 | Configure 4 API clients from .env: ChromaDB client, Groq API client, Anthropic client, Stability AI client | Tuấn (AI) | 🔴 Critical |
| DA-AI02-03 | Configure AWS S3 client with boto3, write 3 helper functions: upload_file(), get_presigned_url(), delete_file() | Lộc (Frontend) | 🔴 Critical |
| DA-AI02-04 | Set up Pydantic base schemas for all request/response models | Ân (AI) | 🟡 High |
| DA-AI02-05 | Write Dockerfile for ai-service + add ai-service to docker-compose.yml in the infrastructure repo | Lộc (Frontend) | 🔴 Critical |
| DA-AI02-06 | Write internal API key authentication middleware (validate X-Internal-Key header) | Tuấn (AI) | 🔴 Critical |
| DA-AI02-07 | Document ChromaDB collection design (collection naming per client, metadata schema, query patterns) | Tuấn (AI) | 🟡 High |

---

## AI Iteration 2 — RAG, LLM & Trends (Parallel with Sprints 7–8)

### EPIC AI-03 — RAG Knowledge Base Pipeline

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI03-01 | Implement document upload endpoint (accept PDF/DOCX/TXT/URL, save file to S3) | Lộc (Frontend) | 🔴 Critical |
| DA-AI03-02 | Build document chunking service using LangChain RecursiveCharacterTextSplitter (chunk_size=500, overlap=50) | Ân (AI) | 🔴 Critical |
| DA-AI03-03 | Build embedding pipeline (text chunk → vector via embedding model → store in ChromaDB with metadata: documentId, clientId, chunkIndex) | Tuấn (AI) | 🔴 Critical |
| DA-AI03-04 | Implement semantic search (query → embedding → top-K retrieval from ChromaDB filtered by clientId) | Tuấn (AI) | 🔴 Critical |
| DA-AI03-05 | Build RAG context builder (format top-K chunks into a context string for LLM prompt) | Ân (AI) | 🔴 Critical |
| DA-AI03-06 | Document deletion endpoint (remove chunks from ChromaDB + file from S3) | Lộc (Frontend) | 🟡 High |
| DA-AI03-07 | Test RAG accuracy (upload 3 real brand documents, verify retrieved context is correct and does not hallucinate) | Ân (AI) | 🔴 Critical |
| DA-AI03-08 | Write RAG pipeline documentation (architecture, tuning parameters, evaluation methodology) | Ân (AI) | 🟢 Medium |

### EPIC AI-04 — LLM Content Generation

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI04-01 | Build prompt template system (receive topic + RAG context + trend data + tone → generate full prompt) | Ân (AI) | 🔴 Critical |
| DA-AI04-02 | Integrate Llama 3 via Groq API (system prompt enforces: only use provided context, do not fabricate) | Tuấn (AI) | 🔴 Critical |
| DA-AI04-03 | Integrate Claude API as fallback when Groq is rate-limited or quality is low | Tuấn (AI) | 🔴 Critical |
| DA-AI04-04 | Implement platform-specific optimization (auto-truncate captions: FB 63k, Threads 500, TikTok 4k chars) | Lộc (Frontend) | 🟡 High |
| DA-AI04-05 | Implement hashtag generation endpoint (call Llama 3 with a simple prompt) | Lộc (Frontend) | 🟡 High |
| DA-AI04-06 | Implement regenerate with feedback (receive previous output + feedback → generate improved version) | Ân (AI) | 🟡 High |
| DA-AI04-07 | Anti-hallucination test (verify 20 generated captions — every claim must be sourced from brand context) | All (Team) | 🔴 Critical |
| DA-AI04-08 | Write Prompt Engineering Documentation (template design, system prompt best practices, tone guide) | Ân (AI) | 🟢 Medium |

### EPIC AI-05 — Trend Crawler Service

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI05-01 | Implement Google Trends crawler (pytrends) to fetch top trending keywords in Vietnam | Ân (AI) | 🟡 High |
| DA-AI05-02 | Implement TikTok trending hashtag crawler (web scraping or unofficial API) | Ân (AI) | 🟡 High |
| DA-AI05-03 | Normalize trend data into a standard format: {keyword, score, platform, relatedTopics[]} | Ân (AI) | 🟡 High |
| DA-AI05-04 | Implement Redis cache for trend data (TTL 6 hours, key: trends:vn:{date}:{category}) | Ân (AI) | 🟡 High |
| DA-AI05-05 | Implement trend suggestions API endpoint (GET /ai/trends?category=fashion&limit=20) | Ân (AI) | 🟡 High |
| DA-AI05-06 | Set up APScheduler to auto-crawl every 6 hours | Ân (AI) | 🟢 Medium |

---

## AI Iteration 3 — Image, Ambassador & Composition (Parallel with Sprints 9–10)

### EPIC AI-06 — Image Generation Pipeline

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI06-01 | Integrate Stability AI API (SDXL): text-to-image with style, aspect ratio, and negative prompt params | Lộc (Frontend) | 🔴 Critical |
| DA-AI06-02 | Build image generation endpoint (POST /ai/image/generate → return S3 URL) | Lộc (Frontend) | 🔴 Critical |
| DA-AI06-03 | Implement batch generation (generate 3 variations simultaneously for user to choose from) | Lộc (Frontend) | 🟡 High |
| DA-AI06-04 | Brand safety filter (default negative prompts to avoid inappropriate content) | Lộc (Frontend) | 🔴 Critical |
| DA-AI06-05 | Test 20 real product prompts, evaluate quality and generation time | Lộc (Frontend) | 🟡 High |

### EPIC AI-07 — Virtual Brand Ambassador (InstantID)

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI07-01 | Set up InstantID pipeline (load model, face encoder InsightFace, ControlNet depth) | Tuấn (AI) | 🔴 Critical |
| DA-AI07-02 | Implement reference photo processing (face detection + face embedding extraction) | Tuấn (AI) | 🔴 Critical |
| DA-AI07-03 | Build face-consistent generation endpoint (POST /ai/ambassador/generate: 1 reference + prompt → generated image preserving the original face) | Tuấn (AI) | 🔴 Critical |
| DA-AI07-04 | Test face consistency (generate 15 different images: varying pose/background/outfit from 1 reference → measure facial similarity score) | Tuấn (AI) | 🔴 Critical |
| DA-AI07-05 | Build ambassador gallery management (save reference + generated images to S3 by clientId) | Tuấn (AI) | 🟡 High |
| DA-AI07-06 | Apply ambassador endpoint (POST /ai/ambassador/apply: ambassador key + background key → composed image) | Tuấn (AI) | 🔴 Critical |
| DA-AI07-07 | Benchmark InstantID vs IP-Adapter on a test set of 20 images, document final decision | Tuấn (AI) | 🟡 High |
| DA-AI07-08 | Write implementation guide (parameters, tips for generating high-quality ambassadors) | Tuấn (AI) | 🟢 Low |

### EPIC AI-08 — Image Composition Pipeline

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI08-01 | Implement background removal for product images (rembg library, U2Net model) → output transparent PNG | Lộc (Frontend) | 🔴 Critical |
| DA-AI08-02 | Implement background removal for model/ambassador images | Lộc (Frontend) | 🔴 Critical |
| DA-AI08-03 | Build layer compositing service (product layer + model layer + background layer → single image using Pillow) | Lộc (Frontend) | 🔴 Critical |
| DA-AI08-04 | Implement shadow + lighting adjustment for natural-looking merges | Lộc (Frontend) | 🟡 High |
| DA-AI08-05 | Build composition endpoint (POST /ai/compose: product S3 key + model S3 key + background S3 key → composed image) | Lộc (Frontend) | 🔴 Critical |
| DA-AI08-06 | Test 20 product + model pairs, evaluate realism score, document failure cases | Lộc (Frontend) | 🟡 High |
| DA-AI08-07 | Write composition parameter guide (optimal sizes, best practices per product type) | Lộc (Frontend) | 🟢 Low |

---

## AI Iteration 4 — Video, Integration & Documentation (Parallel with Sprints 11–12)

### EPIC AI-09 — AI Video Generation

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI09-01 | Integrate Google Veo API (authentication, generate request, async polling for status) | Ân (AI) | 🔴 Critical |
| DA-AI09-02 | Build video prompt template system (receive topic + movement type + duration → generate optimized Veo prompt) | Ân (AI) | 🔴 Critical |
| DA-AI09-03 | Implement movement parameter mapping (camera_pan, zoom_in, zoom_out, subject_walk → Veo params) | Ân (AI) | 🟡 High |
| DA-AI09-04 | Create prompt library: 10 marketing video types x 3 movement styles = 30 prompt templates | Ân (AI) | 🔴 Critical |
| DA-AI09-05 | Build video generation endpoint (POST /ai/video/generate → async, returns jobId → GET /ai/video/{jobId}/status for polling) | Ân (AI) | 🔴 Critical |
| DA-AI09-06 | Upload generated video to S3, extract thumbnail, return {videoUrl, thumbnailUrl, duration} | Ân (AI) | 🔴 Critical |
| DA-AI09-07 | Benchmark 30 prompts (quality, generation time, cost per video) → document results | Ân (AI) | 🟡 High |
| DA-AI09-08 | Write Video Generation Research Report (prompt guide, parameter cheat sheet, best practices) | Ân (AI) | 🟡 High |

### EPIC AI-10 — AI Service Integration & API Finalize

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI10-01 | Finalize all FastAPI endpoints (/ai/content, /ai/image, /ai/video, /ai/ambassador, /ai/compose, /ai/rag/*, /ai/trends) | Lộc (Frontend) | 🔴 Critical |
| DA-AI10-02 | Error handling & retry for external AI API calls (exponential backoff, fallback provider) | All (Team) | 🟡 High |
| DA-AI10-03 | Integration test with business-service (verify all AI calls from business-service work correctly) | All (Team) | 🔴 Critical |
| DA-AI10-04 | Write Postman collection for all AI endpoints with example requests | Lộc (Frontend) | 🟢 Medium |
| DA-AI10-05 | Write Swagger/OpenAPI documentation for ai-service | Lộc (Frontend) | 🟢 Medium |

### EPIC AI-11 — AI Research Documentation & Demo

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-AI11-01 | Write Virtual Ambassador Technical Report (model comparison, implementation decisions, sample results gallery) | Tuấn (AI) | 🔴 Critical |
| DA-AI11-02 | Write Video Generation Research Report (full prompt library of 30 templates, movement parameter guide, cost analysis) | Ân (AI) | 🔴 Critical |
| DA-AI11-03 | Write Image Composition Research Report (technique comparison, best practices, quality evaluation) | Lộc (Frontend) | 🟡 High |
| DA-AI11-04 | Compile AI Cost Analysis (estimated cost per feature x average usage x 1000 users/month) | All (Team) | 🟡 High |
| DA-AI11-05 | Record AI feature demo video (showcase all 7 AI features working in practice) | All (Team) | 🔴 Critical |
| DA-AI11-06 | Present AI results to mentor (live demo + Q&A, collect feedback) | All (Team) | 🔴 Critical |

---

## PHASE 5 — Content Workflow & Publishing

---

## Sprint 10 — Content Requests & Calendar (Weeks 19–20)

### EPIC E28 — Content Request Management

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E28-01 | Implement POST /api/v1/content-requests (BRAND_CLIENT submits request: topic, platform, tone, deadline) | Trung (Leader) | 🔴 Critical |
| DA-E28-02 | Implement GET /api/v1/content-requests (ACCOUNT_MANAGER views list of requests from their assigned clients) | Trung (Leader) | 🔴 Critical |
| DA-E28-03 | Implement status tracking (SUBMITTED → ASSIGNED → IN_PROGRESS → PENDING_REVIEW → SENT_TO_CLIENT → APPROVED → REJECTED) | Trung (Leader) | 🔴 Critical |

### EPIC E29 — Task Assignment & Tracking

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E29-01 | Implement PUT /api/v1/content-requests/{id}/assign (ACCOUNT_MANAGER assigns task to CONTENT_CREATOR) | Trung (Leader) | 🔴 Critical |
| DA-E29-02 | Implement GET /api/v1/content-requests/my-tasks (CONTENT_CREATOR views their assigned tasks) | Trung (Leader) | 🔴 Critical |
| DA-E29-03 | Implement deadline management (alert when a task is approaching its deadline) | Ân (AI) | 🟡 High |

### EPIC E30 — Content Calendar & Scheduling

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E30-01 | Implement GET /api/v1/posts/calendar (retrieve posts by date range, filter by platform/status) | Trung (Leader) | 🔴 Critical |
| DA-E30-02 | Implement POST /api/v1/posts/{id}/schedule (ACCOUNT_MANAGER sets schedule: scheduledAt + targetPlatforms) | Trung (Leader) | 🔴 Critical |
| DA-E30-03 | Build ContentCalendar React component (drag-drop rescheduling, color-coded status indicators) | Lộc (Frontend) | 🔴 Critical |
| DA-E30-04 | Build PlatformPreview component (display preview in the correct format for FB, IG, TikTok, Threads) | Lộc (Frontend) | 🟡 High |

---

## Sprint 11 — Approval Workflow & Full Publishing (Weeks 21–22)

### EPIC E31 — Approval Workflow

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E31-01 | Implement POST /api/v1/posts/{id}/submit (CONTENT_CREATOR submits → PENDING_REVIEW) | Trung (Leader) | 🔴 Critical |
| DA-E31-02 | Implement POST /api/v1/posts/{id}/account-review (ACCOUNT_MANAGER approves or rejects + note) | Trung (Leader) | 🔴 Critical |
| DA-E31-03 | Implement POST /api/v1/posts/{id}/client-approve (BRAND_CLIENT approves → SCHEDULED) | Trung (Leader) | 🔴 Critical |
| DA-E31-04 | Implement POST /api/v1/posts/{id}/client-reject (BRAND_CLIENT rejects + feedback) | Trung (Leader) | 🔴 Critical |

### EPIC E32 — Publishing System

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E32-01 | Implement Smart Ingestion (package post + encrypted token + platform configs into a RabbitMQ message) | Trung (Leader) | 🔴 Critical |
| DA-E32-02 | Implement RabbitMQ consumer in publisher-service (FIFO, exactly-once, acknowledgement) | Phước (Publisher) | 🔴 Critical |
| DA-E32-03 | Implement Facebook adapter (Graph API: IMAGE post and REEL/VIDEO) | Phước (Publisher) | 🔴 Critical |
| DA-E32-04 | Implement Instagram adapter (2-step: create container → publish) | Phước (Publisher) | 🔴 Critical |
| DA-E32-05 | Implement TikTok adapter (Direct Post for video ≤60s, Creator Upload for video >60s) | Phước (Publisher) | 🔴 Critical |
| DA-E32-06 | Implement Threads adapter (2-step: create container → publish, max 500 chars) | Phước (Publisher) | 🔴 Critical |
| DA-E32-07 | Implement Zalo OA adapter | Phước (Publisher) | 🔴 Critical |
| DA-E32-08 | Implement HTTP callback → business-service after publish completes (update post status: PUBLISHED/FAILED) | Phước (Publisher) | 🔴 Critical |

### EPIC E33 — Publish Error Handling

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E33-01 | Implement retry logic (up to 3 attempts, exponential backoff: 30s, 60s, 120s) | Phước (Publisher) | 🔴 Critical |
| DA-E33-02 | Implement Dead Letter Queue handler (Admin can view and manually retry or discard failed posts) | Trung (Leader) | 🔴 Critical |
| DA-E33-03 | Implement failure notification (send alert to Account Manager when a post fails after all retries) | Trung (Leader) | 🔴 Critical |

---

## PHASE 6 — Frontend & Analytics

---

## Sprint 12 — Design System & Core Pages (Weeks 23–24)

### EPIC E34 — Design System & Base Components

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E34-01 | Set up shadcn/ui + Tailwind CSS + custom design tokens in web-dashboard | Lộc (Frontend) | 🔴 Critical |
| DA-E34-02 | Build common components: Button, Input, Modal, Toast, Table, Badge, Spinner, Dropdown | Lộc (Frontend) | 🔴 Critical |
| DA-E34-03 | Build layout components: Sidebar, Navbar, PageWrapper, AuthGuard | Lộc (Frontend) | 🔴 Critical |
| DA-E34-04 | Set up API service layer (Axios instance + interceptors + token refresh) | Lộc (Frontend) | 🔴 Critical |
| DA-E34-05 | Set up Zustand stores (authStore, workspaceStore, notificationStore) | Lộc (Frontend) | 🔴 Critical |

### EPIC E35 — Auth & Dashboard Pages

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E35-01 | Build Login/Register pages with Google OAuth button | Lộc (Frontend) | 🔴 Critical |
| DA-E35-02 | Build main Dashboard page (overview: total posts, success rate, team activity) | Lộc (Frontend) | 🔴 Critical |
| DA-E35-03 | Build Workspace management pages (create, settings, members) | Lộc (Frontend) | 🔴 Critical |
| DA-E35-04 | Build Client management pages (list, create, edit, service package) | Lộc (Frontend) | 🔴 Critical |

### EPIC E36 — Content Management Pages

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E36-01 | Build Content Request list page (filter by status, platform, deadline) | Lộc (Frontend) | 🔴 Critical |
| DA-E36-02 | Build Content Editor page with AI Generate Panel (call ai-service, display caption + hashtag + image) | Lộc (Frontend) | 🔴 Critical |
| DA-E36-03 | Build Content Calendar page (calendar view + drag-drop rescheduling) | Lộc (Frontend) | 🔴 Critical |
| DA-E36-04 | Build Platform Preview modal (accurately preview the format of each platform) | Lộc (Frontend) | 🟡 High |
| DA-E36-05 | Build Content Library page (media browser, template browser, hashtag groups) | Lộc (Frontend) | 🟡 High |

---

## Sprint 13 — Client Portal, Analytics & Notifications (Weeks 25–26)

### EPIC E37 — Client Portal

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E37-01 | Build Client Portal login (isolated, only shows data for the logged-in client) | Lộc (Frontend) | 🔴 Critical |
| DA-E37-02 | Build Client Calendar (read-only, view only, no editing) | Lộc (Frontend) | 🔴 Critical |
| DA-E37-03 | Build Client Approval page (view preview → approve/reject with feedback) | Lộc (Frontend) | 🔴 Critical |
| DA-E37-04 | Build Client Analytics page (publishing results, success rate, campaign summary) | Lộc (Frontend) | 🟡 High |

### EPIC E38 — Analytics & Reporting

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E38-01 | Implement analytics aggregation APIs (aggregate data from posts + publish_logs) | Trung (Leader) | 🔴 Critical |
| DA-E38-02 | Implement automated report generation (weekly/monthly PDF report for clients) | Trung (Leader) | 🟡 High |
| DA-E38-03 | Implement report email sending (automatically send email to Brand Client on schedule) | Ân (AI) | 🟡 High |
| DA-E38-04 | Build Analytics Dashboard (charts: publishing success rate, platform breakdown, campaign performance) | Lộc (Frontend) | 🔴 Critical |

### EPIC E39 — Notification System

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E39-01 | Implement notification CRUD APIs (/api/v1/notifications: GET, PUT read, PUT read-all) | Trung (Leader) | 🟡 High |
| DA-E39-02 | Implement notification creation when events occur (post published, task assigned, token expiry, etc.) | Trung (Leader) | 🔴 Critical |
| DA-E39-03 | Build Notification Center UI (dropdown bell icon, unread badge, list with mark as read) | Lộc (Frontend) | 🟡 High |

---

## PHASE 7 — Testing, Deployment & Final Report

---

## Sprint 14 — Mobile App (Weeks 27–28)

### EPIC E40 — Mobile App Core

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E40-01 | Set up React Native project with Expo, navigation (React Navigation v6) | Lộc (Frontend) | 🔴 Critical |
| DA-E40-02 | Build Auth screens (Login, Register, Forgot Password) | Lộc (Frontend) | 🔴 Critical |
| DA-E40-03 | Build Dashboard screen (simplified overview) | Lộc (Frontend) | 🔴 Critical |
| DA-E40-04 | Build Calendar screen (calendar view, post status) | Lộc (Frontend) | 🟡 High |
| DA-E40-05 | Build Approval screen for BRAND_CLIENT (view preview, approve/reject) | Lộc (Frontend) | 🔴 Critical |
| DA-E40-06 | Implement offline draft mode (save draft to AsyncStorage when offline, sync when back online) | Lộc (Frontend) | 🟡 High |

### EPIC E41 — Mobile Notifications

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E41-01 | Integrate Firebase Cloud Messaging (FCM) for push notifications | Lộc (Frontend) | 🔴 Critical |
| DA-E41-02 | Set up FCM server-side (send notification when events occur in business-service) | Trung (Leader) | 🔴 Critical |
| DA-E41-03 | Build Notification screen (list notifications, deep link on tap) | Lộc (Frontend) | 🟡 High |
| DA-E41-04 | Integrate native camera + media gallery upload | Lộc (Frontend) | 🟡 High |

---

## Sprint 15 — Testing & Bug Fixes (Weeks 29–30)

### EPIC E42 — Unit & Integration Testing

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E42-01 | Write unit tests for business-service (AuthService, WorkspaceService, PostService) | Trung (Leader) | 🔴 Critical |
| DA-E42-02 | Write unit tests for ai-service (content generation, RAG pipeline, image generation) | Tuấn (AI) | 🔴 Critical |
| DA-E42-03 | Write integration tests for main API endpoints (business-service) | Phước (Publisher) | 🔴 Critical |
| DA-E42-04 | Performance testing (load test with 200 concurrent users) | All (Team) | 🟡 High |
| DA-E42-05 | Test publishing flow E2E on sandbox accounts (FB/IG/TikTok/Threads/Zalo) | Phước (Publisher) | 🔴 Critical |

### EPIC E43 — Bug Fixes & Polish

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E43-01 | Sprint retrospective, compile bug list from testing | All (Team) | 🔴 Critical |
| DA-E43-02 | UI responsive fixes (test on various screen sizes: 1920px, 1440px, 1280px, mobile) | Lộc (Frontend) | 🟡 High |
| DA-E43-03 | Security audit checklist (check SQL injection, XSS, CSRF, token handling) | Trung (Leader) | 🔴 Critical |

---

## Sprint 16 — Deployment, Docs & Final Presentation (Weeks 31–32)

### EPIC E44 — Production Deployment

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E44-01 | Set up VPS/EC2 instance, install Docker, configure nginx | Trung (Leader) | 🔴 Critical |
| DA-E44-02 | Deploy all services via docker-compose.prod.yml, set up SSL with Let's Encrypt | Trung (Leader) | 🔴 Critical |
| DA-E44-03 | Set up monitoring (uptime check, error alerts) | Trung (Leader) | 🟡 High |
| DA-E44-04 | Smoke test on production environment | All (Team) | 🔴 Critical |

### EPIC E45 — Final Documentation

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E45-01 | Finalize Swagger API docs for business-service | Trung (Leader) | 🔴 Critical |
| DA-E45-02 | Write User Manual (usage guide for each role) | All (Team) | 🟡 High |
| DA-E45-03 | Write Deployment Guide (step-by-step guide to deploy from scratch) | Trung (Leader) | 🔴 Critical |
| DA-E45-04 | Record demo video (5–10 minute showcase of all features) | All (Team) | 🔴 Critical |

### EPIC E46 — Final Report & Presentation

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E46-01 | Write Capstone report (following FPT's official template) | All (Team) | 🔴 Critical |
| DA-E46-02 | Consolidate and review the entire report before submission | Trung (Leader) | 🔴 Critical |
| DA-E46-03 | Prepare slide deck (15–20 slides, including demo screenshots) | All (Team) | 🔴 Critical |
| DA-E46-04 | Q&A preparation (anticipate mentor questions on architecture, AI, and database design) | All (Team) | 🟡 High |

---

## SPRINT SUMMARY TABLE

| Sprint | Weeks | Phase | Key Deliverables |
|---|---|---|---|
| Sprint 1 | 1–2 | Initiation | Project registered, team roles confirmed, workspace + repos created |
| Sprint 2 | 3–4 | Requirements | 60 Use Cases documented, architecture diagrams, ADRs, Capstone form |
| Sprint 3 | 5–6 | Design | Database schema (MongoDB + PostgreSQL), API spec, Figma wireframes |
| Sprint 4 | 7–8 | Infrastructure | Docker Compose running, CI/CD pipelines active, API Gateway running |
| Sprint 5 | 9–10 | Auth & RBAC | Register/Login/OAuth working, JWT + refresh tokens, RBAC enforced |
| Sprint 6 | 11–12 | Core Business | Workspace CRUD, Client management, Subscription plans working |
| Sprint 7 | 13–14 | Social OAuth | All 5 platform OAuth flows working, AES-256 token encryption, token refresh job |
| Sprint 8 | 15–16 | Publisher | All 5 platform adapters working, retry logic, DLQ, callback to business |
| Sprint 9 | 17–18 | AI Wiring | All AI internal endpoints exposed and callable from business-service |
| AI Iter 1 | 5–6 | AI Research | Model comparison reports (ambassador, video, composition), infrastructure scaffolded |
| AI Iter 2 | 7–8 | AI RAG + LLM | RAG pipeline working, LLM content generation with anti-hallucination, trends crawler |
| AI Iter 3 | 9–10 | AI Image | Image generation, InstantID ambassador, image composition pipeline |
| AI Iter 4 | 11–12 | AI Video + API | Veo integration, all AI endpoints finalized, integration tests, research reports |
| Sprint 10 | 19–20 | Content Flow | Content requests, task assignment, content calendar + scheduling |
| Sprint 11 | 21–22 | Publishing | Approval workflow, full publishing system, error handling |
| Sprint 12 | 23–24 | Frontend Core | Design system, auth pages, dashboard, content management pages |
| Sprint 13 | 25–26 | Frontend Full | Client portal, analytics dashboard, notification center |
| Sprint 14 | 27–28 | Mobile | React Native app: auth, dashboard, calendar, approval, FCM |
| Sprint 15 | 29–30 | Testing | Unit + integration + E2E tests, bug fixes, security audit |
| Sprint 16 | 31–32 | Launch | Production deploy, final docs, capstone report, presentation |

---

## WORKLOAD DISTRIBUTION TABLE

| Member | Role | Tasks | Key Responsibilities |
|---|---|---|---|
| Trung | Leader / Business Service | 54 | Project init, system architecture, API Gateway, Auth, RBAC, Workspace, Client, Subscription, Content workflow, Approval, Notification, Deployment, Final report |
| Lộc | Frontend / AI Infra | 55 | UI wireframes, web-dashboard (all pages), React Native mobile, AI service project setup, S3 helper, image composition pipeline, image generation UI, ai-service Dockerfile |
| Tuấn | AI Engineer | 54 | Sequence diagrams, DB indexing strategy, API spec for ai-service, ChromaDB design, AI infra setup, RAG embedding, InstantID ambassador pipeline, unit tests for ai-service, CI/CD for ai-service |
| Ân | AI Engineer | 54 | Non-functional AI requirements, Redis key doc, Admin user APIs, RAG chunking & context builder, LLM prompt system, trend crawler, video generation (Veo), AI research summaries |
| Phước | Publisher Engineer | 53 | Use case docs (UC21–60), social platform API specs, RabbitMQ message contract, permission matrix, publisher-service setup, all 5 platform adapters, token manual refresh, integration tests for publisher |

> **Total tasks:** ~270 across all epics and AI track iterations.

---

## NOTES

- English is the standard language for all task descriptions, documentation, and project artifacts to ensure consistency across tools such as Linear, GitHub Issues, and Excel.
- "All (Team)" assignee means the task requires participation from all members (e.g., meetings, joint reviews, E2E testing).
- AI Parallel Track epics run concurrently with main sprints; timelines are aligned by sprint week ranges.
- Priority 🔴 Critical tasks must be unblocked first in each sprint before 🟡 High tasks begin.
- Task IDs follow format: DA-{EPIC_ID}-{SEQ} (e.g., DA-E01-01, DA-AI07-03).
