# BrandHub — Project Plan & Task Details (Hợp nhất)

> Tài liệu gộp từ `BrandHub_Project_Plan.md` (tổng quan + bảng task) và `BrandHub_Task_Details.md` (chi tiết từng task: Goal, Acceptance Criteria, Technical Notes, Dependencies).
> Click vào **Task ID** ở bất kỳ bảng nào trong Phần 1 để nhảy tới chi tiết tương ứng ở Phần 2.
> Task đánh dấu 🆕 là task phát sinh ngoài 406 task gốc — xem giải thích ở Phần 3.

## Mục lục

- [Phần 1 — Tổng quan & Bảng Task](#phần-1--tổng-quan--bảng-task) — team info, tech stack, kiến trúc, 46+ epic theo sprint, sprint summary, workload
- [Phần 2 — Chi tiết Task](#phần-2--chi-tiết-task) — Goal / Acceptance Criteria / Technical Notes / Dependencies cho từng task
- [Phần 3 — Task phát sinh ngoài plan gốc](#phần-3--tổng-hợp-task-phát-sinh-ngoài-plan-gốc) — 17 task xuất hiện trên Jira nhưng không có trong kế hoạch 406 task ban đầu

---

# PHẦN 1 — TỔNG QUAN & BẢNG TASK

---

## TEAM & PROJECT INFO

| Field         | Detail                                                                                                             |
| ------------- | ------------------------------------------------------------------------------------------------------------------ |
| Project       | BrandHub — AI-Powered Multi-Channel Content Platform                                                               |
| Team          | Trung (Leader), Lộc (AI Sub-lead), Tuấn (AI), Ân (AI), Phước (Publisher)                                           |
| Total Sprints | 16 Sprints (2 weeks each) + 4 AI Parallel Iterations                                                               |
| Duration      | ~32 weeks                                                                                                          |
| Stack         | Java Spring Boot 3, Python FastAPI, React 18, React Native, MongoDB, PostgreSQL, Redis, ChromaDB, RabbitMQ, AWS S3 |

---

## TECH STACK SUMMARY

| Layer              | Technology                                                     |
| ------------------ | -------------------------------------------------------------- |
| Web Frontend       | React 18 + Vite + TypeScript + Tailwind CSS + shadcn/ui        |
| Mobile             | React Native + Expo                                            |
| Backend Business   | Java 21 + Spring Boot 3 + Spring Security                      |
| Backend AI         | Python 3.11 + FastAPI + LangChain                              |
| Backend Publisher  | Java 21 + Spring Boot 3                                        |
| API Gateway        | Spring Cloud Gateway                                           |
| Primary DB         | MongoDB (documents, content, social accounts)                  |
| Relational DB      | PostgreSQL (payments, subscriptions, audit logs)               |
| Cache              | Redis (JWT blacklist, rate limit, OAuth state, trending cache) |
| Vector DB          | ChromaDB (brand embeddings for RAG)                            |
| Message Queue      | RabbitMQ (async publishing queue)                              |
| File Storage       | AWS S3                                                         |
| LLM                | Llama 3 via Groq API + Claude API (fallback)                   |
| Image Gen          | Stability AI API (SDXL)                                        |
| Video Gen          | Google Veo API                                                 |
| Virtual Ambassador | InstantID + InsightFace + ControlNet                           |
| Auth               | JWT (Access: 15 min, Refresh: 30 days) + Google OAuth          |
| Container          | Docker + Docker Compose                                        |
| CI/CD              | GitHub Actions                                                 |
| Project Mgmt       | Linear (sprints) + GitHub (code)                               |

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

| Role              | Description                                                   |
| ----------------- | ------------------------------------------------------------- |
| `ADMIN`           | System admin — manages users, plans, platform                 |
| `OWNER`    | Creates workspace, manages team & clients, billing            |
| `MANAGER` | Manages assigned clients, reviews content, sends reports      |
| `CREATOR` | Creates AI content, manages knowledge base, schedules posts   |
| `CLIENT`    | View-only client portal: approve/reject content, view reports |
| `GUEST`           | Unauthenticated — landing page + register only                |

---

## PRIORITY LEGEND

| Symbol      | Meaning                                                        |
| ----------- | -------------------------------------------------------------- |
| 🔴 Critical | Blocking other tasks, core architecture, auth, database schema |
| 🟡 High     | Important features, CI/CD, main API endpoints                  |
| 🟢 Medium   | Docs, testing, secondary features                              |

---

## PHASE 1 — Initiation & Documentation

---

## Sprint 1 — Project Kickoff (Weeks 1–2)

### EPIC E01 — Project Initiation

| Task ID                                                                                               | Description                                                                        | Assignee       | Priority    |
| ----------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- | -------------- | ----------- |
| [DA-E01-01](#da-e01-01-brainstorm-and-align-on-brandhub-topic-idea-define-scope-and-mvp)              | Brainstorm and align on BrandHub topic idea, define scope and MVP                  | All (Team)     | 🔴 Critical |
| [DA-E01-02](#da-e01-02-team-meeting-to-confirm-roles-and-responsibilities-of-each-member)             | Team meeting to confirm roles and responsibilities of each member                  | Trung (Leader) | 🔴 Critical |
| [DA-E01-03](#da-e01-03-find-and-contact-a-mentor-suitable-for-the-ai-microservices-topic)             | Find and contact a mentor suitable for the AI + microservices topic                | Trung (Leader) | 🔴 Critical |
| [DA-E01-04](#da-e01-04-assess-each-team-members-technical-skills-java-python-react-ai-tools)          | Assess each team member's technical skills (Java, Python, React, AI tools)         | All (Team)     | 🟡 High     |
| [DA-E01-05](#da-e01-05-submit-project-registration-form-on-the-call4project-system-insideunifpteduvn) | Submit project registration form on the Call4project system (insideuni.fpt.edu.vn) | Trung (Leader) | 🔴 Critical |

### EPIC E02 — Project Management Setup

| Task ID                                                                                                             | Description                                                                                        | Assignee       | Priority    |
| ------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- | -------------- | ----------- |
| [DA-E02-01](#da-e02-01-create-linear-workspace-set-up-2-week-sprint-cadence-create-issue-templates)                 | Create Linear workspace, set up 2-week sprint cadence, create issue templates                      | Trung (Leader) | 🔴 Critical |
| [DA-E02-02](#da-e02-02-create-github-organization-and-7-repos-following-polyrepo-structure)                         | Create GitHub Organization and 7 repos following polyrepo structure                                | Trung (Leader) | 🔴 Critical |
| [DA-E02-03](#da-e02-03-set-up-branch-protection-rules-pr-template-commit-convention-conventional-commits)           | Set up branch protection rules, PR template, commit convention (Conventional Commits)              | Trung (Leader) | 🔴 Critical |
| [DA-E02-04](#da-e02-04-create-project-email-and-accounts-for-all-services-aws-github-actions-groq-stability-ai-etc) | Create project email and accounts for all services (AWS, GitHub Actions, Groq, Stability AI, etc.) | Trung (Leader) | 🔴 Critical |

---

## Sprint 2 — Requirements & Architecture (Weeks 3–4)

### EPIC E03 — Use Case Documentation

| Task ID                                                                                                                                  | Description                                                                                                             | Assignee          | Priority    |
| ---------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E03-01](#da-e03-01-list-and-group-all-105-use-cases-by-6-roles-admin-owner-manager-creator-client-guest) | List and group all 105 use cases by 6 roles (Admin, Owner, Manager, Creator, Client, Guest) — **DONE**, see `docs/ba/use-cases/` | Phước (Publisher) | 🔴 Critical |
| [DA-E03-02](#da-e03-02-write-detailed-descriptions-for-uc-0112-authentication--profile-flows)                                                 | Write detailed descriptions for UC-01–12 (Authentication + Profile flows) — actor, description, main flow, alt flows — **DONE**, see `docs/ba/use-cases/01-authentication-profile.md`        | Trung (Leader)    | 🔴 Critical |
| [DA-E03-03](#da-e03-03-write-detailed-descriptions-for-uc-1373-agency-workspace-media-packagecampaign--content-task-workflow-flows)                                    | Write detailed descriptions for UC-13–73 (Agency/Workspace, Media Package/Campaign, Content & Task Workflow flows) — **DONE**, see `docs/ba/use-cases/02-agency-workspace.md`, `03-media-package-campaign.md`, `04-content-task-workflow.md`                                      | Phước (Publisher) | 🔴 Critical |
| [DA-E03-04](#da-e03-04-write-detailed-descriptions-for-uc-74106-ai-publishing-subscription--admin-flows)                                     | Write detailed descriptions for UC-74–106 (AI, Publishing, Subscription, Admin flows) — **DONE**, see `docs/ba/use-cases/05-ai-features.md`, `06-publishing-social.md`, `07-subscription.md`, `08-admin-management.md`                                       | Phước (Publisher) | 🟡 High     |
| [DA-E03-05](#da-e03-05-review-uc-list-with-mentor-update-based-on-feedback)                                                              | Review UC list with mentor, update based on feedback                                                                    | All (Team)        | 🟡 High     |
| [DA-E03-06](#da-e03-06-finalize-uc-table-into-excel-file-brandhubusecasesxlsx)                                                           | Finalize UC table into Excel file (BrandHub_UseCases.xlsx)                                                              | Phước (Publisher) | 🟢 Medium   |

### EPIC E04 — Functional & Non-Functional Requirements

| Task ID                                                                                                 | Description                                                                                                | Assignee          | Priority    |
| ------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E04-01](#da-e04-01-write-functional-objectives-per-role-6-roles-x-features)                         | Write functional objectives per role (6 roles x features)                                                  | Trung (Leader)    | 🔴 Critical |
| [DA-E04-02](#da-e04-02-write-non-functional-requirements-ui-performance-security-reliability-usability) | Write non-functional requirements (UI, Performance, Security, Reliability, Usability)                      | Trung (Leader)    | 🔴 Critical |
| [DA-E04-03](#da-e04-03-add-ai-performance-requirements-latency-throughput-model-accuracy-thresholds)    | Add AI performance requirements (latency, throughput, model accuracy thresholds) to non-functional section | Ân (AI)           | 🟡 High     |
| [DA-E04-04](#da-e04-04-add-mobile-requirements-fcm-offline-draft-camera-to-non-functional-section)      | Add mobile requirements (FCM, offline draft, camera) to non-functional section                             | Lộc (AI Sub-lead) | 🟡 High     |
| [DA-E04-05](#da-e04-05-fill-in-and-finalize-the-capstone-register-form-brandhubcapstoneregisterdocx)    | Fill in and finalize the Capstone Register form (BrandHub_Capstone_Register.docx)                          | Trung (Leader)    | 🔴 Critical |

### EPIC E05 — System Architecture Design

| Task ID                                                                                                                                             | Description                                                                                                                        | Assignee       | Priority    |
| --------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | -------------- | ----------- |
| [DA-E05-01](#da-e05-01-draw-system-architecture-overview-diagram-7-services-5-databases-rabbitmq-clients)                                           | Draw system architecture overview diagram (7 services + 5 databases + RabbitMQ + clients) — **DONE**, `docs/architecture/architecture.html`                                          | Trung (Leader) | 🔴 Critical |
| [DA-E05-02](#da-e05-02-define-service-responsibilities-and-boundaries-what-each-of-the-7-services-does-and-does-not-do)                             | Define service responsibilities and boundaries, re-scoped V2 (Agency→Workspace) — **DONE**, `docs/service-boundaries.md`                                  | Trung (Leader) | 🔴 Critical |
| [DA-E05-03](#da-e05-03-draw-database-ownership-diagram-which-service-owns-which-db-cross-db-reference-strategy)                                     | Draw database ownership diagram, re-scoped V2 (23 PG tables + 17 Mongo collections) — **DONE**, `docs/architecture/db-ownership-diagram.html`                                         | Trung (Leader) | 🔴 Critical |
| [DA-E05-04](#da-e05-04-document-service-to-service-communication-rest-business-ai-rabbitmq-business-publisher-http-callback-publisher-business)     | Document service-to-service communication — **DONE**, `docs/architecture/business-ai-rest-contract.md` (REST) + `docs/architecture/rabbitmq-publisher-contract.html` (RabbitMQ, đã fix platform list bỏ Zalo)     | Trung (Leader) | 🔴 Critical |
| [DA-E05-05](#da-e05-05-write-architecture-decision-records-adrs-for-4-key-decisions-polyrepo-mongodbpostgresql-split-rabbitmq-spring-cloud-gateway) | Write ADRs for 4 key decisions — **DONE**, `docs/adr/ADR-001` đến `ADR-004` | Trung (Leader) | 🔴 Critical |
| [DA-E05-06](#da-e05-06-draw-sequence-diagrams-for-4-core-flows-content-creation-approval-workflow-auto-publishing-oauth-token-refresh)              | Draw sequence diagrams, re-scoped V2 (Approval Sequence 4 bước, reject→restart-from-Creator) — **DONE**, `docs/architecture/sequence-diagrams.md`                 | Tuấn (AI)      | 🔴 Critical |
| [DA-E05-07](#da-e05-07-write-the-ai-architecture-section-in-the-technical-document-ai-service-internal-design-chromadb-schema-llm-routing-strategy) | Write AI architecture section, re-scoped V2 (ChromaDB naming đổi `workspace_*`→`agency_*`) — **DONE**, `docs/architecture/ai-service-architecture.md`    | Tuấn (AI)      | 🟡 High     |
| [DA-E05-08](#da-e05-08-compile-full-technical-document-brandhubtechnicaldocumentmd)                                                                 | Compile full technical document — **DONE**, `docs/BrandHub_Technical_Document.md`                                                                   | Trung (Leader) | 🟡 High     |

---

## Sprint 3 — Database, API & UI Design (Weeks 5–6)

### EPIC E06 — Database Design

| Task ID                                                                                                                                                         | Description                                                                                                                                 | Assignee       | Priority    |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ----------- |
| [DA-E06-01](#da-e06-01-define-database-strategy-which-data-goes-into-mongodb-vs-postgresql-and-why)                                                             | Define database strategy: which data goes into MongoDB, which into PostgreSQL, and why                                                      | Trung (Leader) | 🔴 Critical |
| [DA-E06-02](#da-e06-02-design-12-mongodb-collections-with-full-field-types-requiredoptional-flags-default-values)                                               | Design 12 MongoDB collections with full field types, required/optional flags, default values                                                | Trung (Leader) | 🔴 Critical |
| [DA-E06-03](#da-e06-03-design-5-postgresql-tables-with-constraints-and-internal-foreign-keys)                                                                   | Design 5 PostgreSQL tables with constraints and internal foreign keys                                                                       | Trung (Leader) | 🔴 Critical |
| [DA-E06-04](#da-e06-04-define-indexing-strategy-for-mongodb-and-postgresql)                                                                                     | Define indexing strategy for MongoDB and PostgreSQL                                                                                         | Tuấn (AI)      | 🟡 High     |
| [DA-E06-05](#da-e06-05-write-dbml-code-for-dbdiagramio-mongodb-postgresql-enums-refs-tablegroups)                                                               | Write DBML code for dbdiagram.io (MongoDB + PostgreSQL + Enums + Refs + TableGroups)                                                        | Tuấn (AI)      | 🟡 High     |
| [DA-E06-06](#da-e06-06-document-redis-key-patterns-jwt-blacklist-rate-limit-oauth-state-trending-cache)                                                         | Document Redis key patterns (JWT blacklist, rate limit, OAuth state, trending cache)                                                        | Ân (AI)        | 🟡 High     |
| [DA-E06-07](#da-e06-07-write-database-initialization-scripts-init-mongojs-init-postgressql)                                                                     | Write database initialization scripts (init-mongo.js + init-postgres.sql)                                                                   | Trung (Leader) | 🔴 Critical |
| [DA-E06-08](#da-e06-08-write-database-access-rules-documentation-every-query-must-include-workspaceid-filter-brandclient-additionally-requires-clientid-filter) | Write database access rules documentation (every query must include workspaceId filter; CLIENT additionally requires clientId filter) | Trung (Leader) | 🔴 Critical |

### EPIC E07 — API Design & Swagger Spec

| Task ID                                                                                                                                                            | Description                                                                                                                                            | Assignee          | Priority    |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------- | ----------- |
| [DA-E07-01](#da-e07-01-define-all-endpoints-for-business-service-auth-user-workspace-client-post-contentrequest-socialaccount-analytics-report-subscription-admin) | Define all endpoints for business-service (Auth, User, Workspace, Client, Post, ContentRequest, SocialAccount, Analytics, Report, Subscription, Admin) | Trung (Leader)    | 🔴 Critical |
| [DA-E07-02](#da-e07-02-define-endpoints-for-ai-service-aicontent-aiimage-aivideo-aiambassador-airag-aitrends)                                                      | Define endpoints for ai-service (/ai/content, /ai/image, /ai/video, /ai/ambassador, /ai/rag, /ai/trends)                                               | Tuấn (AI)         | 🔴 Critical |
| [DA-E07-03](#da-e07-03-define-rabbitmq-message-format-for-publisher-service-publish-job-callback-message-contract)                                                 | Define RabbitMQ message format for publisher-service (publish job + callback message contract)                                                         | Phước (Publisher) | 🔴 Critical |
| [DA-E07-04](#da-e07-04-write-standard-api-response-format-apiresponse-wrapper-error-codes-http-status-codes)                                                       | Write standard API response format (ApiResponse wrapper, error codes, HTTP status codes)                                                               | Trung (Leader)    | 🔴 Critical |
| [DA-E07-05](#da-e07-05-write-openapi-yaml-spec-for-business-service)                                                                                               | Write OpenAPI YAML spec for business-service                                                                                                           | Trung (Leader)    | 🟡 High     |
| [DA-E07-06](#da-e07-06-write-openapi-yaml-spec-for-ai-service-all-internal-public-endpoints)                                                                       | Write OpenAPI YAML spec for ai-service (all internal + public endpoints)                                                                               | Tuấn (AI)         | 🟡 High     |
| [DA-E07-07](#da-e07-07-document-social-platform-api-specs-fb-graph-api-v19-tiktok-content-api-v2-threads-api-zalo-oa-api-versions-rate-limits-payload-formats)     | Document social platform API specs: FB Graph API, TikTok Content API, Threads API (versions, rate limits, payload formats)                             | Phước (Publisher) | 🟡 High     |

### EPIC E08 — UI/UX Wireframe

| Task ID                                                                                                                                        | Description                                                                                                                    | Assignee          | Priority    |
| ---------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ | ----------------- | ----------- |
| [DA-E08-01](#da-e08-01-create-figma-wireframes-for-all-main-screens-login-dashboard-workspace-content-editor-calendar-client-portal-analytics) | Create Figma wireframes for all main screens (Login, Dashboard, Workspace, Content Editor, Calendar, Client Portal, Analytics) | Lộc (AI Sub-lead) | 🔴 Critical |
| [DA-E08-02](#da-e08-02-design-component-system-button-input-modal-table-badge-toast-styles)                                                    | Design component system (Button, Input, Modal, Table, Badge, Toast styles)                                                     | Lộc (AI Sub-lead) | 🔴 Critical |
| [DA-E08-03](#da-e08-03-draw-user-flow-diagrams-for-3-main-flows-content-creation-approval-publishing)                                          | Draw user flow diagrams for 3 main flows: content creation, approval, publishing                                               | Lộc (AI Sub-lead) | 🟡 High     |
| [DA-E08-04](#da-e08-04-wireframe-client-portal-read-only-calendar-approvereject-analytics-view)                                                | Wireframe Client Portal (read-only calendar, approve/reject, analytics view)                                                   | Lộc (AI Sub-lead) | 🟡 High     |
| [DA-E08-07](#da-e08-07-create-landing-page-ui-phát-sinh-ngoài-plan-gốc-prefix-jira-lỗi) 🆕                                                     | Create landing page UI                                                                                                         | Lộc (AI Sub-lead) | 🟡 High     |
| [DA-E08-05](#da-e08-05-create-a-view-local-document-website-automation-phát-sinh-ngoài-plan-gốc) 🆕                                            | Create a view-local document website automation                                                                                | Lộc (AI Sub-lead) | 🟢 Medium   |
| [DA-E08-08](#da-e08-08-integrated-html-for-view-document-phát-sinh-ngoài-plan-gốc) 🆕                                                          | Integrated .html for view document                                                                                             | Trung (Leader)    | 🟢 Medium   |

---

## PHASE 2 — Infrastructure Setup

---

## Sprint 4 — Infrastructure, CI/CD & Gateway (Weeks 7–8)

### EPIC E09 — Development Environment Setup

| Task ID                                                                                                                         | Description                                                                                                        | Assignee          | Priority    |
| ------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ | ----------------- | ----------- |
| [DA-E09-01](#da-e09-01-write-docker-composeyml-to-run-the-full-infrastructure-stack-mongodb-postgresql-redis-rabbitmq-chromadb) | Write docker-compose.yml to run the full infrastructure stack: MongoDB, PostgreSQL, Redis, RabbitMQ, ChromaDB      | Trung (Leader)    | 🔴 Critical |
| [DA-E09-02](#da-e09-02-write-init-postgressql-create-tables-seed-subscription-plans)                                            | Write init-mongo.js (create collections + indexes) and init-postgres.sql (create tables + seed subscription plans) | Trung (Leader)    | 🔴 Critical |
| [DA-E09-03](#da-e09-03-write-envexample-consolidating-all-environment-variables-across-6-services)                              | Write .env.example consolidating all environment variables across 6 services                                       | Trung (Leader)    | 🔴 Critical |
| [DA-E09-04](#da-e09-04-write-clone-allsh-script-to-clone-all-7-repos-locally-with-a-single-command)                             | Write clone-all.sh script to clone all 7 repos locally with a single command                                       | Trung (Leader)    | 🟡 High     |
| [DA-E09-05](#da-e09-05-write-readmemd-for-the-infrastructure-repo-step-by-step-setup-guide)                                     | Write README.md for the infrastructure repo (step-by-step setup guide)                                             | Phước (Publisher) | 🟢 Medium   |
| [DA-E09-06](#da-e09-06-infrastructure-business-service-keys) 🆕                                                                 | Infrastructure + Business Service keys                                                                             | Trung (Leader)    | 🔴 Critical |
| [DA-E09-07](#da-e09-07-ai-service-llm-keys-payment-gateway) 🆕                                                                  | AI Service — LLM keys + Payment Gateway                                                                            | Tuấn (AI)         | 🔴 Critical |
| [DA-E09-08](#da-e09-08-ai-service-imagevideo-gen-keys) 🆕                                                                       | AI Service — Image/Video Gen keys                                                                                  | Ân (AI)           | 🔴 Critical |
| [DA-E09-09](#da-e09-09-publisher-service-social-platform-oauth) 🆕                                                              | Publisher Service — Social Platform OAuth                                                                          | Phước (Publisher) | 🔴 Critical |
| [DA-E09-10](#da-e09-10-frontend-google-oauth-app) 🆕                                                                            | Frontend — Google OAuth App                                                                                        | Lộc (AI Sub-lead) | 🔴 Critical |
| [DA-E09-11](#da-e09-11-create-project-cost-sheet) 🆕                                                                            | Create project cost sheet                                                                                          | Trung (Leader)    | 🟡 High     |
| [DA-E09-12](#da-e09-12-register-brandhub-domain-phát-sinh-ngoài-plan-gốc) 🆕                                                    | Register brandhub domain                                                                                           | Lộc (AI Sub-lead) | 🟡 High     |
| [DA-E09-13](#da-e09-13-update-diagram-dbml-and-html-file-for-database-phát-sinh-ngoài-plan-gốc) 🆕                              | Update diagram, DBML and HTML file for database                                                                    | Trung (Leader)    | 🟡 High     |

### EPIC E10 — CI/CD Pipeline

| Task ID                                                                                                         | Description                                                                            | Assignee          | Priority  |
| --------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- | ----------------- | --------- |
| [DA-E10-01](#da-e10-01-write-github-actions-workflow-for-business-service-mvn-test-docker-build-push-to-ghcrio) | Write GitHub Actions workflow for business-service (build + test + push Docker image)  | Trung (Leader)    | 🟡 High   |
| [DA-E10-02](#da-e10-02-write-github-actions-workflow-for-publisher-service-mvn-test-docker-build-push)          | Write GitHub Actions workflow for publisher-service (build + test + push Docker image) | Phước (Publisher) | 🟡 High   |
| [DA-E10-03](#da-e10-03-write-github-actions-workflow-for-ai-service-flake8-pytest-docker-build-push)            | Write GitHub Actions workflow for ai-service (lint + test + build Docker image)        | Tuấn (AI)         | 🟡 High   |
| [DA-E10-04](#da-e10-04-write-github-actions-workflow-for-web-dashboard-eslint-tsc-vite-build-deploy)            | Write GitHub Actions workflow for web-dashboard (lint + build + deploy)                | Lộc (AI Sub-lead) | 🟡 High   |
| [DA-E10-05](#da-e10-05-set-up-branch-protection-rules-require-1-approval-before-merging-into-develop)           | Set up branch protection rules (require 1 approval before merging into develop)        | Trung (Leader)    | 🟢 Medium |
| [DA-E10-06](#da-e10-06-write-github-actions-workflow-for-api-gateway-build-test-push-docker-image) 🆕           | Write GitHub Actions workflow for api-gateway (build + test + push Docker image)       | Trung (Leader)    | 🟡 High   |

### EPIC E11 — API Gateway

| Task ID                                                                                                                                            | Description                                                                                     | Assignee       | Priority    |
| -------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- | -------------- | ----------- |
| [DA-E11-01](#da-e11-01-initialize-brandhub-api-gateway-project-with-spring-cloud-gateway)                                                          | Initialize brandhub-api-gateway project with Spring Cloud Gateway                               | Trung (Leader) | 🔴 Critical |
| [DA-E11-02](#da-e11-02-write-jwt-validation-filter-verify-rs256-token-on-every-request-extract-userid-role-into-x-user-id-and-x-user-role-headers) | Write JWT validation filter (verify token on every request, extract userId + role into headers) | Trung (Leader) | 🔴 Critical |
| [DA-E11-03](#da-e11-03-write-rate-limiting-filter-using-redis-100-requestsminuteuser-key-ratelimituseridminute)                                    | Write rate limiting filter using Redis (100 requests/minute/user)                               | Trung (Leader) | 🔴 Critical |
| [DA-E11-04](#da-e11-04-configure-routing-rules-map-url-paths-to-correct-downstream-service)                                                        | Configure routing rules (map URL paths to the correct service)                                  | Trung (Leader) | 🔴 Critical |
| [DA-E11-05](#da-e11-05-write-logging-filter-log-all-inbound-and-outbound-requests-for-debugging)                                                   | Write logging filter (log all inbound and outbound requests for debugging)                      | Trung (Leader) | 🟢 Medium   |
| [DA-E11-06](#da-e11-06-write-dockerfile-for-api-gateway) 🆕                                                                                        | Write Dockerfile for api-gateway                                                                | Trung (Leader) | 🔴 Critical |
| [DA-E11-07](#da-e11-07-write-global-error-response-handler-for-gateway) 🆕                                                                         | Write global error response handler for gateway                                                 | Trung (Leader) | 🟡 High     |

---

## PHASE 3 — Backend Core

---

## Sprint 5 — Authentication & RBAC (Weeks 9–10)

### EPIC E12 — Authentication

| Task ID                                                                                                                                                     | Description                                                                                                                                                | Assignee       | Priority    |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ----------- |
| [DA-E12-01](#da-e12-01-implement-register-api)                                                                                                              | Implement Register API (validate email uniqueness, hash password with bcrypt cost=12)                                                                      | Trung (Leader) | 🔴 Critical |
| [DA-E12-02](#da-e12-02-implement-login-api)                                                                                                                 | Implement Login API (verify password, issue JWT access token 15 min + refresh token 30 days)                                                               | Trung (Leader) | 🔴 Critical |
| [DA-E12-03](#da-e12-03-implement-refresh-token-api)                                                                                                         | Implement Refresh Token API (verify refresh token, issue new access token)                                                                                 | Trung (Leader) | 🔴 Critical |
| [DA-E12-04](#da-e12-04-implement-logout-api)                                                                                                                | Implement Logout API (add JWT jti to Redis blacklist, clear cookie)                                                                                        | Trung (Leader) | 🔴 Critical |
| [DA-E12-05](#da-e12-05-implement-forgot-password-reset-password-flow)                                                                                       | Implement Forgot Password & Reset Password flow (email link with time-limited token)                                                                       | Trung (Leader) | 🔴 Critical |
| [DA-E12-06](#da-e12-06-implement-google-oauth-login)                                                                                                        | Implement Google OAuth login (callback, create user if not yet registered)                                                                                 | Trung (Leader) | 🟡 High     |
| [DA-E12-07](#da-e12-07-research-hs256-vs-rs256-vs-es256-for-jwt-signing-phát-sinh-ngoài-plan-gốc) 🆕                                                        | Research HS256 vs RS256 vs ES256 for JWT signing                                                                                                           | Trung (Leader) | 🔴 Critical |
| [DA-E12-08](#da-e12-08-implement-change-password-phát-sinh-ngoài-plan-gốc) 🆕                                                                               | Implement Change Password (authenticated user updates their own password)                                                                                  | Trung (Leader) | 🟡 High     |
| [DA-E12-09](#da-e12-09-implement-facebook-oauth-login-phát-sinh-ngoài-plan-gốc) 🆕                                                                          | Implement Facebook OAuth login (callback, create user if not yet registered)                                                                               | Trung (Leader) | 🟡 High     |
| [DA-E12-10](#da-e12-10-implement-github-oauth-login-phát-sinh-ngoài-plan-gốc) 🆕                                                                            | Implement GitHub OAuth login (callback, create user if not yet registered)                                                                                 | Trung (Leader) | 🟡 High     |
| [DA-E12-11](#da-e12-11-implement-two-factor-authentication-2fa-totp-phát-sinh-ngoài-plan-gốc) 🆕                                                            | Implement Two-Factor Authentication (2FA, TOTP) — setup/confirm/disable/verify                                                                              | Trung (Leader) | 🟡 High     |
| [DA-E12-12](#da-e12-12-implement-deactivate-account-phát-sinh-ngoài-plan-gốc) 🆕                                                                            | Implement Deactivate Account (soft-delete, chặn owner Agency active)                                                                                        | Trung (Leader) | 🟡 High     |
| [DA-E12-13](#da-e12-13-implement-otp-attempt-lockout-phát-sinh-ngoài-plan-gốc) 🆕                                                                           | Implement OTP attempt lockout (5 lần sai → hủy session, fix rate-limit error code)                                                                          | Trung (Leader) | 🟢 Medium   |
| [DA-E12-14](#da-e12-14-fix-logoutrequireuserid-500--google-oauth-bug-phát-sinh-ngoài-plan-gốc) 🆕 🐛                                                        | Fix Logout/RequireUserId 500 error + Google OAuth token exchange bug (JSON → form-urlencoded)                                                               | Trung (Leader) | 🔴 Critical |
| [DA-E11-14](#da-e11-14-add-all-jpa-models-from-database-schema-for-business-service-repository-layer-phát-sinh-ngoài-plan-gốc-gắn-sai-epic-trên-jira) 🆕 ⚠️ | Add all JPA models from database schema for business-service + repository layer _(gắn sai epic trên Jira — nội dung thuộc data layer, không phải Gateway)_ | Trung (Leader) | 🔴 Critical |

### EPIC E13 — User & Profile Management

| Task ID                                                     | Description                                                                 | Assignee       | Priority    |
| ----------------------------------------------------------- | --------------------------------------------------------------------------- | -------------- | ----------- |
| [DA-E13-01](#da-e13-01-implement-getput-apiv1usersme)       | Implement GET/PUT /api/v1/users/me (retrieve and update user profile)       | Trung (Leader) | 🔴 Critical |
| [DA-E13-02](#da-e13-02-implement-avatar-upload)             | Implement avatar upload (receive file → upload to S3 → save URL to MongoDB) | Trung (Leader) | 🟡 High     |
| [DA-E13-03](#da-e13-03-implement-admin-get-apiv1adminusers) | Implement Admin: GET /api/v1/admin/users (list all users with filters)      | Ân (AI)        | 🟡 High     |
| [DA-E13-04](#da-e13-04-implement-admin-bansuspend-user)     | Implement Admin: Ban/Suspend user (set isActive=false, send notification)   | Ân (AI)        | 🟡 High     |

### EPIC E14 — Role-Based Access Control (RBAC)

| Task ID                                                                 | Description                                                                                      | Assignee          | Priority    |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ | ----------------- | ----------- |
| [DA-E14-01](#da-e14-01-write-requirerole-annotation-and-aop-aspect)     | Write RBAC annotation/middleware for business-service (@RequireRole)                             | Trung (Leader)    | 🔴 Critical |
| [DA-E14-02](#da-e14-02-implement-workspace-isolation-filter)            | Implement workspace isolation filter (every MongoDB query must include workspaceId filter)       | Trung (Leader)    | 🔴 Critical |
| [DA-E14-03](#da-e14-03-implement-client-isolation-for-brandclient-role) | Implement client isolation for CLIENT (can only view data belonging to their own clientId) | Trung (Leader)    | 🔴 Critical |
| [DA-E14-04](#da-e14-04-write-permission-matrix-document)                | Write permission matrix document (6 roles x all endpoints = allowed/not allowed)                 | Phước (Publisher) | 🟢 Medium   |

> 🔀 **E14 đã dời sang Sprint 6** do Sprint 5 tập trung hoàn thành auth core (E12).

### EPIC E34 — Design System & Base Components 🔀

> Dời từ Sprint 12. Xem [Rebalance Log](jira-status-audit-2026-07-11.md#rebalance-log--sau-sprint-4) trong Jira Audit.

| Task ID                                                            | Description                                                                           | Assignee          | Priority    |
| ------------------------------------------------------------------ | ------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E34-01](#da-e34-01-set-up-shadcnui-tailwind-css-design-tokens) | Set up shadcn/ui + Tailwind CSS + custom design tokens in web-dashboard               | Phước (Publisher) | 🔴 Critical |
| [DA-E34-02](#da-e34-02-build-common-ui-components)                 | Build common components: Button, Input, Modal, Toast, Table, Badge, Spinner, Dropdown | Phước (Publisher) | 🔴 Critical |
| [DA-E34-03](#da-e34-03-build-layout-components)                    | Build layout components: Sidebar, Navbar, PageWrapper, AuthGuard                      | Phước (Publisher) | 🔴 Critical |
| [DA-E34-04](#da-e34-04-set-up-axios-instance-with-interceptors)    | Set up API service layer (Axios instance + interceptors + token refresh)              | Phước (Publisher) | 🔴 Critical |
| [DA-E34-05](#da-e34-05-set-up-zustand-stores)                      | Set up Zustand stores (authStore, workspaceStore, notificationStore)                  | Phước (Publisher) | 🔴 Critical |

---

## Sprint 6 — Workspace, Client, RBAC & Core Pages (Weeks 11–12)

### EPIC E14 — Role-Based Access Control (RBAC) 🔀 _(dời từ Sprint 5)_

> Sprint 5 tập trung hoàn thành auth core (E12), RBAC chưa làm được → dời sang Sprint 6. Đây là foundational epic, block E15/E16.

| Task ID                                                                 | Description                                                                                      | Assignee          | Priority    |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ | ----------------- | ----------- |
| [DA-E14-01](#da-e14-01-write-requirerole-annotation-and-aop-aspect)     | Write RBAC annotation/middleware for business-service (@RequireRole)                             | Trung (Leader)    | 🔴 Critical |
| [DA-E14-02](#da-e14-02-implement-workspace-isolation-filter)            | Implement workspace isolation filter (every MongoDB query must include workspaceId filter)       | Trung (Leader)    | 🔴 Critical |
| [DA-E14-03](#da-e14-03-implement-client-isolation-for-brandclient-role) | Implement client isolation for CLIENT (can only view data belonging to their own clientId) | Trung (Leader)    | 🔴 Critical |
| [DA-E14-04](#da-e14-04-write-permission-matrix-document)                | Write permission matrix document (6 roles x all endpoints = allowed/not allowed)                 | Phước (Publisher) | 🟢 Medium   |

### EPIC E15 — Workspace Management

| Task ID                                                                 | Description                                                                    | Assignee       | Priority    |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------------------ | -------------- | ----------- |
| [DA-E15-01](#da-e15-01-implement-post-apiv1workspaces)                  | Implement POST /api/v1/workspaces (create new workspace, OWNER role)    | Trung (Leader) | 🔴 Critical |
| [DA-E15-02](#da-e15-02-implement-get-apiv1workspacesmine)               | Implement GET /api/v1/workspaces/mine (retrieve workspace of the current user) | Trung (Leader) | 🔴 Critical |
| [DA-E15-03](#da-e15-03-implement-post-apiv1workspacesidmembers)         | Implement POST /api/v1/workspaces/{id}/members (invite member via email)       | Trung (Leader) | 🔴 Critical |
| [DA-E15-04](#da-e15-04-implement-delete-apiv1workspacesidmembersuserid) | Implement DELETE /api/v1/workspaces/{id}/members/{userId} (remove a member)    | Trung (Leader) | 🟡 High     |
| [DA-E15-05](#da-e15-05-implement-workspace-settings)                    | Implement workspace settings (timezone, default platforms, report frequency)   | Trung (Leader) | 🟡 High     |

### EPIC E16 — Client & Agency Management

| Task ID                                                             | Description                                                                                | Assignee          | Priority    |
| ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | ----------------- | ----------- |
| [DA-E16-01](#da-e16-01-implement-post-apiv1clients)                 | Implement POST /api/v1/clients (OWNER creates a new client)                   | Phước (Publisher) | 🔴 Critical |
| [DA-E16-02](#da-e16-02-implement-put-apiv1clientsidassign)          | Implement PUT /api/v1/clients/{id}/assign (OWNER assigns an Manager)        | Phước (Publisher) | 🔴 Critical |
| [DA-E16-03](#da-e16-03-implement-put-apiv1clientsidservice-package) | Implement PUT /api/v1/clients/{id}/service-package (set monthly post limits and platforms) | Phước (Publisher) | 🟡 High     |
| [DA-E16-04](#da-e16-04-implement-get-apiv1clients)                  | Implement GET /api/v1/clients (OWNER and MANAGER view client list)          | Phước (Publisher) | 🔴 Critical |

> **EPIC E17 — Subscription & Billing đã dời sang Sprint 9** 🔀 (xem [Rebalance Log](jira-status-audit-2026-07-11.md#rebalance-log--sau-sprint-4) trong Jira Audit).

### EPIC E35 — Auth & Dashboard Pages 🔀 _(dời từ Sprint 12)_

| Task ID                                                      | Description                                                                                                    | Assignee          | Priority    |
| ------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| **Trung — Auth Pages**                                       |
| [DA-E35-01](#da-e35-01-build-login-page)                     | Build Login page (email/password form, error states, redirect to dashboard)                                    | Trung (Leader)    | 🔴 Critical |
| [DA-E35-05](#da-e35-05-build-register-page) 🆕               | Build Register page (account creation form, validation, redirect to dashboard)                                 | Trung (Leader)    | 🔴 Critical |
| [DA-E35-06](#da-e35-06-build-google-oauth-button) 🆕         | Build Google OAuth button + callback page (OAuth flow, handle new vs existing user)                            | Trung (Leader)    | 🔴 Critical |
| **Phước — Dashboard**                                        |
| [DA-E35-02](#da-e35-02-build-main-dashboard-page)            | Build main Dashboard page (overview: total posts, success rate, team activity, AI credits, connected accounts) | Phước (Publisher) | 🔴 Critical |
| **Trung — Workspace Pages**                                  |
| [DA-E35-03](#da-e35-03-build-create-workspace-page)          | Build Create Workspace page (form: name, industry; redirect to workspace after create)                         | Trung (Leader)    | 🔴 Critical |
| [DA-E35-07](#da-e35-07-build-workspace-settings-page) 🆕     | Build Workspace Settings page (timezone selector, default platforms, report frequency)                         | Trung (Leader)    | 🟡 High     |
| [DA-E35-08](#da-e35-08-build-workspace-members-page) 🆕      | Build Workspace Members page (member table, invite button, remove action with confirm)                         | Trung (Leader)    | 🔴 Critical |
| **Phước — Client Pages**                                     |
| [DA-E35-04](#da-e35-04-build-client-list-page)               | Build Client List page (table with search, filter by status, role-based visibility)                            | Phước (Publisher) | 🔴 Critical |
| [DA-E35-09](#da-e35-09-build-create-client-page) 🆕          | Build Create Client page (form: name, industry, brand color picker, logo upload)                               | Phước (Publisher) | 🔴 Critical |
| [DA-E35-10](#da-e35-10-build-edit-client-page) 🆕            | Build Edit Client page (pre-filled form: name, industry, brand color, logo)                                    | Phước (Publisher) | 🟡 High     |
| [DA-E35-11](#da-e35-11-build-client-service-package-page) 🆕 | Build Client Service Package page (posts/month input, platform checkboxes, AI credits slider)                  | Phước (Publisher) | 🟡 High     |

### EPIC E36 — Content Management Pages 🔀 _(dời từ Sprint 12)_

| Task ID                                                 | Description                                                                                                                                                         | Assignee          | Priority    |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| **Phước — Content Request**                             |
| [DA-E36-01](#da-e36-01-build-content-request-list-page) | Build Content Request list page (filter by status, platform, deadline; table with pagination)                                                                       | Phước (Publisher) | 🔴 Critical |
| **Phước — Content Editor**                              |
| [DA-E36-02](#da-e36-02-build-content-editor-page)       | Build Content Editor page (form: caption textarea, hashtag input, platform selector, image upload, schedule date)                                                   | Phước (Publisher) | 🔴 Critical |
| [DA-E36-06](#da-e36-06-build-ai-generate-panel) 🆕      | Build AI Generate Panel ("Generate with AI" button → call ai-service → display caption + hashtag + image; regenerate with feedback; "Use this" inserts into editor) | Phước (Publisher) | 🔴 Critical |
| **Phước — Calendar & Preview**                          |
| [DA-E36-03](#da-e36-03-build-content-calendar-page)     | Build Content Calendar page (calendar view + drag-drop rescheduling)                                                                                                | Phước (Publisher) | 🔴 Critical |
| [DA-E36-04](#da-e36-04-build-platform-preview-modal)    | Build Platform Preview modal (accurately preview the format of each platform)                                                                                       | Phước (Publisher) | 🟡 High     |
| **Phước — Content Library**                             |
| [DA-E36-05](#da-e36-05-build-media-browser-page)        | Build Media Browser page (S3 file browser, upload, folder view)                                                                                                     | Phước (Publisher) | 🟡 High     |
| [DA-E36-07](#da-e36-07-build-template-browser-page) 🆕  | Build Template Browser page (saved post drafts list, search, preview, use template)                                                                                 | Phước (Publisher) | 🟡 High     |
| [DA-E36-08](#da-e36-08-build-hashtag-groups-page) 🆕    | Build Hashtag Groups page (CRUD hashtag groups, assign to posts)                                                                                                    | Phước (Publisher) | 🟡 High     |

> 🆕 = task mới tách từ task gốc để granularity tốt hơn.

> 🔀 **E35 & E36 dời từ Sprint 12 lên Sprint 6** để có UI sớm cho auth + workspace + client + content, tận dụng Design System foundation đã có từ Sprint 5 (E34). Backend APIs (E15, E16) làm song song → UI có dữ liệu thật ngay.

---

## PHASE 4 — Social Integration & AI Pipeline

---

## Sprint 7 — Social OAuth & Token Management (Weeks 13–14)

### EPIC E18 — Meta OAuth (Facebook + Instagram)

| Task ID                                                                 | Description                                                                            | Assignee          | Priority    |
| ----------------------------------------------------------------------- | -------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E18-01](#da-e18-01-implement-facebook-fanpage-oauth-flow)           | Implement Facebook Fanpage OAuth flow (redirect → callback → token exchange)           | Phước (Publisher) | 🔴 Critical |
| [DA-E18-02](#da-e18-02-implement-instagram-business-account-connection) | Implement Instagram Business account connection (linked via Facebook Business)         | Phước (Publisher) | 🔴 Critical |
| [DA-E18-03](#da-e18-03-implement-aes-256-gcm-token-encryption)          | Implement AES-256 encryption for access token + refresh token before saving to MongoDB | Trung (Leader)    | 🔴 Critical |
| [DA-E18-04](#da-e18-04-implement-social-account-disconnect-flow)        | Implement disconnect flow (revoke token at Meta, remove from MongoDB)                  | Phước (Publisher) | 🟡 High     |

### EPIC E19 — TikTok & Threads OAuth

> **Zalo OA đã bị loại khỏi scope** (2026-09-03) — không tích hợp Zalo nữa. DA-E19-03 (Zalo OAuth) đã xóa khỏi Jira (DA-216).

| Task ID                                                     | Description                                                                                    | Assignee          | Priority    |
| ----------------------------------------------------------- | ---------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E19-01](#da-e19-01-implement-tiktok-for-business-oauth) | Implement TikTok for Business OAuth (Client Credentials Flow)                                  | Phước (Publisher) | 🔴 Critical |
| [DA-E19-02](#da-e19-02-implement-threads-oauth)             | Implement Threads OAuth (using Meta Graph API, scope: threads_basic + threads_content_publish) | Phước (Publisher) | 🔴 Critical |
| [DA-E19-04](#da-e19-04-implement-token-status-api)          | Implement token status dashboard API (view ACTIVE/EXPIRED/REVOKED status for all accounts)     | Trung (Leader)    | 🟡 High     |

### EPIC E20 — Token Lifecycle Management

| Task ID                                                       | Description                                                                                            | Assignee          | Priority    |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ | ----------------- | ----------- |
| [DA-E20-01](#da-e20-01-implement-scheduled-token-refresh-job) | Implement scheduled token refresh job (runs at 2:00 AM daily, refreshes tokens expiring within 7 days) | Trung (Leader)    | 🔴 Critical |
| [DA-E20-02](#da-e20-02-implement-token-refresh-failure-alert) | Implement alert notification when token refresh fails (send notification to Manager)           | Trung (Leader)    | 🔴 Critical |
| [DA-E20-03](#da-e20-03-implement-manual-token-refresh-api)    | Implement manual token refresh API (Manager triggers refresh manually)                         | Phước (Publisher) | 🟡 High     |

---

## Sprint 8 — Publisher Service (Weeks 15–16)

> **EPIC E37 — Client Portal đã dời từ Sprint 13 vào Sprint 8** 🔀 (2026-09-03) — đẩy sớm phần Client Portal (login, calendar, approval, analytics) để song song với Publisher Service.

### EPIC E21 — Publisher Service Core

| Task ID                                                                                                             | Description                                                                                                | Assignee          | Priority    |
| ------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E21-01](#da-e21-01-initialize-brandhub-publisher-service-project-spring-boot-3-rabbitmq-consumer-bean-setup)    | Initialize brandhub-publisher-service project (Spring Boot 3, RabbitMQ consumer setup)                     | Phước (Publisher) | 🔴 Critical |
| [DA-E21-02](#da-e21-02-implement-rabbitmq-consumer-receive-publishjobmessage-and-route-to-correct-platform-adapter) | Implement RabbitMQ consumer: receive PublishJobMessage (postId, platform, content, mediaUrls, scheduledAt) | Phước (Publisher) | 🔴 Critical |
| [DA-E21-03](#da-e21-03-implement-facebook-publish-adapter-graph-api-v19-mefeed-for-text-mephotos-for-image)         | Implement Facebook publish adapter (Graph API v19: /me/feed + /me/photos)                                  | Phước (Publisher) | 🔴 Critical |
| [DA-E21-04](#da-e21-04-implement-instagram-publish-adapter-2-step-create-container-publish)                         | Implement Instagram publish adapter (Content Publishing API: create container → publish)                   | Phước (Publisher) | 🔴 Critical |
| [DA-E21-05](#da-e21-05-implement-tiktok-publish-adapter-direct-post-60s-creator-upload-60s)                         | Implement TikTok publish adapter (Content Posting API v2)                                                  | Phước (Publisher) | 🔴 Critical |
| [DA-E21-06](#da-e21-06-implement-threads-publish-adapter-2-step-create-container-publish-enforce-max-500-chars)     | Implement Threads publish adapter (Threads API: create container → publish, max 500 chars)                 | Phước (Publisher) | 🔴 Critical |

> ~~DA-E21-07 — Implement Zalo OA publish adapter~~ — **loại khỏi scope** (2026-09-03), không tích hợp Zalo nữa.

### EPIC E22 — Publish Callback & Error Handling

| Task ID                                                                                                                                | Description                                                                                                       | Assignee          | Priority    |
| -------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E22-01](#da-e22-01-implement-http-callback-post-internalpostsidpublish-result-to-business-service)                                 | Implement HTTP callback to business-service after publishing completes (POST /internal/posts/{id}/publish-result) | Phước (Publisher) | 🔴 Critical |
| [DA-E22-02](#da-e22-02-implement-retry-logic-immediate-1min-5min-15min-dead-letter-queue)                                              | Implement retry logic: on failure → retry up to 3 times with exponential backoff (1m, 5m, 15m)                    | Phước (Publisher) | 🔴 Critical |
| [DA-E22-03](#da-e22-03-implement-business-service-handler-for-publish-callback-update-post-status-publishedfailed-create-notification) | Implement business-service handler for publish callback (update post status, create notification)                 | Trung (Leader)    | 🔴 Critical |

### EPIC E37 — Client Portal 🔀 _(dời từ Sprint 13)_

| Task ID                                             | Description                                                                      | Assignee          | Priority    |
| --------------------------------------------------- | -------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E37-01](#da-e37-01-build-client-portal-login)   | Build Client Portal login (isolated, only shows data for the logged-in client)   | Phước (Publisher) | 🔴 Critical |
| [DA-E37-02](#da-e37-02-build-client-calendar)       | Build Client Calendar (read-only, view only, no editing)                         | Phước (Publisher) | 🔴 Critical |
| [DA-E37-03](#da-e37-03-build-client-approval-page)  | Build Client Approval page (view preview → approve/reject with feedback)         | Phước (Publisher) | 🔴 Critical |
| [DA-E37-04](#da-e37-04-build-client-analytics-page) | Build Client Analytics page (publishing results, success rate, campaign summary) | Phước (Publisher) | 🟡 High     |

---

## Sprint 9 — AI Service Wiring & Business Integration (Weeks 17–18)

### EPIC E23 — AI Service Internal API Wiring

| Task ID                                                     | Description                                                                                                     | Assignee  | Priority    |
| ----------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | --------- | ----------- |
| [DA-E23-01](#da-e23-01-expose-internalaicontentgenerate)    | Expose /internal/ai/content/generate endpoint (receive topic + clientId + platform → return caption + hashtags) | Tuấn (AI) | 🔴 Critical |
| [DA-E23-02](#da-e23-02-expose-internalaiimagegenerate)      | Expose /internal/ai/image/generate endpoint (receive prompt + style → return S3 URL)                            | Tuấn (AI) | 🔴 Critical |
| [DA-E23-03](#da-e23-03-expose-internalaiambassadorgenerate) | Expose /internal/ai/ambassador/generate endpoint (receive faceImage + productImage → return S3 URL)             | Tuấn (AI) | 🔴 Critical |
| [DA-E23-04](#da-e23-04-expose-internalaivideogenerate)      | Expose /internal/ai/video/generate endpoint (receive script + style → return S3 URL, async with polling)        | Ân (AI)   | 🔴 Critical |
| [DA-E23-05](#da-e23-05-expose-internalaitrendsfetch)        | Expose /internal/ai/trends/fetch endpoint (return top trending topics by platform + region)                     | Ân (AI)   | 🟡 High     |

### EPIC E24 — Business Service AI Integration

| Task ID                                                                          | Description                                                                                                  | Assignee       | Priority    |
| -------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ | -------------- | ----------- |
| [DA-E24-01](#da-e24-01-implement-ai-content-generation-flow-in-business-service) | Implement AI content generation flow in business-service: ContentRequest → call ai-service → save draft Post | Trung (Leader) | 🔴 Critical |
| [DA-E24-02](#da-e24-02-implement-image-and-ambassador-generation-trigger)        | Implement image/ambassador generation trigger from Post editor (user selects AI generate image)              | Trung (Leader) | 🔴 Critical |
| [DA-E24-03](#da-e24-03-implement-ai-usage-tracking)                              | Implement AI usage tracking (count ai_credits_per_month against subscription plan limits)                    | Trung (Leader) | 🟡 High     |

### EPIC E17 — Subscription & Billing 🔀

> Dời từ Sprint 6. Xem [Rebalance Log](jira-status-audit-2026-07-11.md#rebalance-log--sau-sprint-4) trong Jira Audit.

| Task ID                                                             | Description                                                                        | Assignee       | Priority    |
| ------------------------------------------------------------------- | ---------------------------------------------------------------------------------- | -------------- | ----------- |
| [DA-E17-01](#da-e17-01-implement-admin-crud-for-subscription-plans) | Implement Admin CRUD for subscription plans (Free/Basic/Pro/Enterprise)            | Trung (Leader) | 🔴 Critical |
| [DA-E17-02](#da-e17-02-implement-post-apiv1subscriptionssubscribe)  | Implement POST /api/v1/subscriptions/subscribe (OWNER subscribes to a plan) | Trung (Leader) | 🔴 Critical |
| [DA-E17-03](#da-e17-03-implement-stripe-payment-webhook-flow)       | Implement payment flow (integrate payment gateway, create invoice)                 | Trung (Leader) | 🔴 Critical |
| [DA-E17-04](#da-e17-04-implement-get-apiv1subscriptionsinvoices)    | Implement GET /api/v1/subscriptions/invoices (billing history)                     | Ân (AI)        | 🟡 High     |

---

## AI PARALLEL TRACK — AI Research & Implementation

> **Note:** AI Track runs in parallel alongside Sprints 5–12. Each AI Iteration is 2 weeks.

---

## AI Iteration 1 — Research & Evaluation (Parallel with Sprints 5–6)

### EPIC AI-01 — AI Model Research & Evaluation

| Task ID                                                                                                                                | Description                                                                                                  | Assignee          | Priority    |
| -------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ | ----------------- | ----------- |
| [DA-AI01-01](#da-ai01-01-research-and-compare-instantid-vs-ip-adapter-vs-controlnet-for-face-consistent-virtual-ambassador-generation) | Research and compare InstantID vs IP-Adapter vs ControlNet for face-consistent virtual ambassador generation | Tuấn (AI)         | 🔴 Critical |
| [DA-AI01-02](#da-ai01-02-test-3-virtual-ambassador-tools-on-5-sample-images-write-comparison-table-quality-speed-cost)                 | Test 3 virtual ambassador tools on 5 sample images, write comparison table (quality, speed, cost)            | Tuấn (AI)         | 🔴 Critical |
| [DA-AI01-03](#da-ai01-03-research-google-veo-api-capabilities-pricing-rate-limits-movement-parameters)                                 | Research Google Veo API: capabilities, pricing, rate limits, movement parameters                             | Ân (AI)           | 🔴 Critical |
| [DA-AI01-04](#da-ai01-04-collect-and-test-20-video-generation-prompts-with-various-movement-parameters-classify-results)               | Collect and test 20+ video generation prompts with various movement parameters, classify results             | Ân (AI)           | 🔴 Critical |
| [DA-AI01-05](#da-ai01-05-research-product-model-image-compositing-techniques-controlnet-inpainting-dall-e-edit-rembg-composite)        | Research product + model image compositing techniques: ControlNet inpainting, DALL-E edit, rembg + composite | Lộc (AI Sub-lead) | 🟡 High     |
| [DA-AI01-06](#da-ai01-06-test-3-compositing-methods-on-10-product-model-image-pairs-evaluate-naturalness-and-compute-cost)             | Test 3 compositing methods on 10 product + model image pairs, evaluate naturalness and compute cost          | Lộc (AI Sub-lead) | 🟡 High     |
| [DA-AI01-07](#da-ai01-07-compare-llama-3-groq-vs-claude-api-vietnamese-caption-quality-speed-cost-per-call)                            | Compare Llama 3 (Groq) vs Claude API: Vietnamese caption quality, speed, cost per call                       | All (Team)        | 🔴 Critical |
| [DA-AI01-08](#da-ai01-08-write-ai-research-summary-document-consolidating-results-from-all-3-tracks)                                   | Write AI Research Summary Document consolidating results from all 3 tracks, save to docs/ repo               | Ân (AI)           | 🟢 Medium   |

### EPIC AI-02 — AI Service Infrastructure Setup

| Task ID                                                                                                                          | Description                                                                                                     | Assignee          | Priority    |
| -------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-AI02-01](#da-ai02-01-initialize-brandhub-ai-service-project-fastapi-python-311-folder-structure)                             | Initialize brandhub-ai-service project: FastAPI + Python 3.11 + folder structure (api/services/models/utils)    | Lộc (AI Sub-lead) | 🔴 Critical |
| [DA-AI02-02](#da-ai02-02-configure-4-api-clients-from-env-chromadb-groq-anthropic-stability-ai)                                  | Configure 4 API clients from .env: ChromaDB client, Groq API client, Anthropic client, Stability AI client      | Tuấn (AI)         | 🔴 Critical |
| [DA-AI02-03](#da-ai02-03-configure-aws-s3-client-with-boto3-write-uploadfile-getpresignedurl-deletefile-helpers)                 | Configure AWS S3 client with boto3, write 3 helper functions: upload_file(), get_presigned_url(), delete_file() | Lộc (AI Sub-lead) | 🔴 Critical |
| [DA-AI02-04](#da-ai02-04-set-up-pydantic-base-schemas-for-all-requestresponse-models)                                            | Set up Pydantic base schemas for all request/response models                                                    | Ân (AI)           | 🟡 High     |
| [DA-AI02-05](#da-ai02-05-write-dockerfile-for-ai-service-add-ai-service-to-docker-composeyml-in-infrastructure-repo)             | Write Dockerfile for ai-service + add ai-service to docker-compose.yml in the infrastructure repo               | Lộc (AI Sub-lead) | 🔴 Critical |
| [DA-AI02-06](#da-ai02-06-write-internal-api-key-authentication-middleware-validate-x-internal-key-header-on-all-internal-routes) | Write internal API key authentication middleware (validate X-Internal-Key header)                               | Tuấn (AI)         | 🔴 Critical |
| [DA-AI02-07](#da-ai02-07-document-chromadb-collection-design-collection-naming-per-clientid-metadata-schema-query-patterns)      | Document ChromaDB collection design (collection naming per client, metadata schema, query patterns)             | Tuấn (AI)         | 🟡 High     |

---

## AI Iteration 2 — RAG, LLM & Trends (Parallel with Sprints 7–8)

### EPIC AI-03 — Brand Knowledge Base & Ingestion Pipeline

| Task ID                                                                                                                                | Description                                                                                                                            | Assignee       | Priority    |
| -------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ----------- |
| [DA-AI03-01](#da-ai03-01-implement-document-upload-endpoint-accept-pdfdocxtxturl-save-file-to-s3)                                      | Implement document upload endpoint (accept PDF/DOCX/TXT/URL, save file to S3)                                                          | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI03-02](#da-ai03-02-build-document-chunking-service-using-langchain-recursivecharactertextsplitter-chunksize500-overlap50)        | Build document chunking service using LangChain RecursiveCharacterTextSplitter (chunk_size=500, overlap=50)                            | Ân (AI)        | 🔴 Critical |
| [DA-AI03-03](#da-ai03-03-build-embedding-pipeline-text-chunk-embedding-store-in-chromadb-with-metadata)                                | Build embedding pipeline (text chunk → vector via embedding model → store in ChromaDB with metadata: documentId, clientId, chunkIndex) | Tuấn (AI)      | 🔴 Critical |
| [DA-AI03-04](#da-ai03-04-implement-semantic-search-query-embedding-top-k-retrieval-from-chromadb-filtered-by-clientid)                 | Implement semantic search (query → embedding → top-K retrieval from ChromaDB filtered by clientId)                                     | Tuấn (AI)      | 🔴 Critical |
| [DA-AI03-05](#da-ai03-05-build-rag-context-builder-format-top-k-chunks-into-context-string-for-llm-prompt)                             | Build RAG context builder (format top-K chunks into a context string for LLM prompt)                                                   | Ân (AI)        | 🔴 Critical |
| [DA-AI03-06](#da-ai03-06-document-deletion-endpoint-remove-chunks-from-chromadb-file-from-s3)                                          | Document deletion endpoint (remove chunks from ChromaDB + file from S3)                                                                | Lộc (Sub-lead) | 🟡 High     |
| [DA-AI03-07](#da-ai03-07-test-rag-accuracy-upload-3-real-brand-documents-verify-retrieved-context-is-correct-and-does-not-hallucinate) | Test RAG accuracy (upload 3 real brand documents, verify retrieved context is correct and does not hallucinate)                        | Ân (AI)        | 🔴 Critical |
| [DA-AI03-08](#da-ai03-08-write-rag-pipeline-documentation-architecture-tuning-parameters-evaluation-methodology)                       | Write RAG pipeline documentation (architecture, tuning parameters, evaluation methodology)                                             | Ân (AI)        | 🟢 Medium   |

### EPIC AI-04 — LLM Content Generation (Jira Epic: DA-79)

| Task ID                                                                   |                           Jira Key                           | Description                                                                                           | Assignee       |  Priority   |     Status     |
| ------------------------------------------------------------------------- | :----------------------------------------------------------: | ----------------------------------------------------------------------------------------------------- | -------------- | :---------: | :------------: |
| [DA-AI04-01](#da-ai04-01--build-prompt-template-system)                   | [DA-240](https://letritrung2605.atlassian.net/browse/DA-240) | Build prompt template system (receive topic + RAG context + trend data + tone → generate full prompt) | Ân (AI)        | 🔴 Critical | 🟡 In Progress |
| [DA-AI04-02](#da-ai04-02--integrate-llama-3-via-groq-api)                 | [DA-253](https://letritrung2605.atlassian.net/browse/DA-253) | Integrate Llama 3 via Groq API (system prompt: "only use provided context, do not fabricate")         | Tuấn (AI)      | 🔴 Critical |  🔵 In review  |
| [DA-AI04-03](#da-ai04-03--integrate-claude--gemini-api-as-fallback)       | [DA-271](https://letritrung2605.atlassian.net/browse/DA-271) | Integrate Fallback LLM API (Google Gemini 1.5 Flash / Claude) with Failover Circuit Breaker           | Tuấn (AI)      | 🔴 Critical |    ⚪ To Do    |
| [DA-AI04-04](#da-ai04-04--implement-platform-specific-caption-truncation) | [DA-286](https://letritrung2605.atlassian.net/browse/DA-286) | Implement platform-specific caption truncation (FB 63k, Threads 500, TikTok 4k chars)                 | Lộc (Sub-lead) |   🟡 High   |    ⚪ To Do    |
| [DA-AI04-05](#da-ai04-05--implement-hashtag-generation-endpoint)          | [DA-231](https://letritrung2605.atlassian.net/browse/DA-231) | Implement hashtag generation endpoint (`POST /api/v1/ai/content/hashtags`)                            | Lộc (Sub-lead) |   🟡 High   |    ⚪ To Do    |
| [DA-AI04-06](#da-ai04-06--implement-regenerate-with-feedback)             | [DA-246](https://letritrung2605.atlassian.net/browse/DA-246) | Implement regenerate with feedback (`POST /api/v1/ai/content/regenerate`)                             | Ân (AI)        |   🟡 High   | 🟡 In Progress |
| [DA-AI04-07](#da-ai04-07--anti-hallucination-test)                        | [DA-261](https://letritrung2605.atlassian.net/browse/DA-261) | Anti-hallucination test (verify 20 generated captions — claim verification)                           | Tuấn (AI)      | 🔴 Critical |  🔵 In review  |
| [DA-AI04-08](#da-ai04-08--write-prompt-engineering-documentation)         | [DA-274](https://letritrung2605.atlassian.net/browse/DA-274) | Write Prompt Engineering Documentation (template design, system prompt best practices, tone guide)    | Ân (AI)        |  🟢 Medium  |    ⚪ To Do    |

### EPIC AI-05 — Trend Crawler, Prediction Engine & Storage Service (Status: ✅ Completed in Sprint 7 / Spike)

> **Ghi chú:** Toàn bộ các task của Epic AI-05 đã được team hoàn thành 100% từ Sprint 7 / Spike. Hạ tầng Trend Crawler, Neo4j Graph, ChromaDB và Redis Cache hiện đã online, đóng vai trò Live Data Provider cho Epic AI-04.

| Task ID                                                                                                                           | Description                                                                                                     | Assignee       | Priority    |
| --------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | -------------- | ----------- |
| [DA-AI05-01](#da-ai05-01--aggregate-and-select-required-scraping-apis-on-apify--scrape-creators-for-social-media-data-collection) | Aggregate and Select Required Scraping APIs on Apify & Scrape Creators for Social Media Data Collection         | Tuấn (AI)      | 🔴 Critical |
| [DA-AI05-02](#da-ai05-02--demo-crawled-social-media-data-on-google-sheets)                                                        | Demo Crawled Social Media Data on Google Sheets                                                                 | Tuấn (AI)      | 🟡 High     |
| [DA-AI05-03](#da-ai05-03--complete-end-to-end-social-media-crawl-workflow-via-n8n-or-custom-code)                                 | Complete End-to-End Social Media Crawl Workflow via N8N or Custom Code                                          | Tuấn (AI)      | 🔴 Critical |
| [DA-AI05-04](#da-ai05-04--host-and-set-up-chromadb-or-neo4j-database-instance-for-storing-raw-collected-data)                     | Host and Set Up ChromaDB or Neo4j Database Instance for Storing Raw Collected Data                              | Tuấn (AI)      | 🔴 Critical |
| [DA-AI05-05](#da-ai05-05--message-queue--buffer-layer-integration-redis-queue--kafka)                                             | Message Queue / Buffer Layer Integration (Redis Queue / Kafka)                                                  | Tuấn (AI)      | 🔴 Critical |
| [DA-AI05-06](#da-ai05-06--underthesea-nlp-tokenization)                                                                           | Underthesea NLP Tokenization                                                                                    | Ân (AI)        | 🔴 Critical |
| [DA-AI05-07A](#da-ai05-07a--neo4j-knowledge-graph-entity-traversal-service)                                                       | Neo4j Knowledge Graph Entity Traversal Service                                                                  | Tuấn (AI)      | 🔴 Critical |
| [DA-AI05-07B](#da-ai05-07b--chromadb-trend-vector-snippet-retrieval-service)                                                      | ChromaDB Trend Vector Snippet Retrieval Service                                                                 | Tuấn (AI)      | 🔴 Critical |
| [DA-AI05-07C](#da-ai05-07c--trend-context-synthesizer--token-optimizer-engine)                                                    | Trend Context Synthesizer & Token Optimizer Engine                                                              | Ân (AI)        | 🔴 Critical |
| [DA-AI05-07D](#da-ai05-07d--redis-trend-context-read-through-cache-layer)                                                         | Redis Trend Context Read-Through Cache Layer                                                                    | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI05-07E](#da-ai05-07e--unified-trend-context-retrieval-api-endpoint-post-trendscontext)                                      | Unified Trend Context Retrieval API Endpoint (`POST /api/v1/ai/trends/context`)                                 | Ân (AI)        | 🔴 Critical |
| [DA-AI05-07F](#da-ai05-07f--slang-map--text-normalization-engine)                                                                 | Slang Map & Text Normalization Engine                                                                           | Ân (AI)        | 🔴 Critical |
| [DA-AI05-08](#da-ai05-08--bm25-anomaly-calculation-spike-detection)                                                               | BM25 Anomaly Calculation (Spike Detection)                                                                      | Ân (AI)        | 🔴 Critical |
| [DA-AI05-09](#da-ai05-09--neo4j-interaction-graph-construction)                                                                   | Neo4j Interaction Graph Construction                                                                            | Ân (AI)        | 🔴 Critical |
| [DA-AI05-10](#da-ai05-10--gds-engine-scheduled-execution-run-periodic-algorithms-nightly-or-every-few-hours)                      | GDS Engine Scheduled Execution (Run periodic algorithms nightly or every few hours)                             | Ân (AI)        | 🔴 Critical |
| [DA-AI05-11](#da-ai05-11--degree-filter--botnet-detection-calculate-in-degree---flag-isstopwordtrue-if-spam)                      | Degree Filter & Botnet Detection (Calculate In-Degree -> Flag isStopWord=true if Spam)                          | Ân (AI)        | 🔴 Critical |
| [DA-AI05-12](#da-ai05-12--personalized-pagerank-engine-calculate-niche-virality-score-for-posts)                                  | Personalized PageRank Engine (Calculate Niche Virality Score for Posts)                                         | Ân (AI)        | 🔴 Critical |
| [DA-AI05-13](#da-ai05-13--betweenness-centrality-engine-find-bridge-keywords-between-communities---trending-keywords)             | Betweenness Centrality Engine (Find Bridge Keywords between Communities -> Trending Keywords)                   | Ân (AI)        | 🔴 Critical |
| [DA-AI05-14](#da-ai05-14--final-scoring-engine-bm25-anomaly-x-virality)                                                           | Final Scoring Engine (BM25 Anomaly x Virality)                                                                  | Ân (AI)        | 🔴 Critical |
| [DA-AI05-15](#da-ai05-15--filter-top-10-20-trends-engine)                                                                         | Filter Top 10-20 Trends Engine                                                                                  | Ân (AI)        | 🔴 Critical |
| [DA-AI05-16](#da-ai05-16--redis-zset-caching-engine-trendsvndatecategory-ttl-6h)                                                  | Redis ZSET Caching Engine (`trends:vn:{date}:{category}`, TTL 6h)                                               | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI05-17](#da-ai05-17--upsert-neo4j-node-trend)                                                                                | Upsert Neo4j Node `:Trend`                                                                                      | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI05-18](#da-ai05-18--deep-crawl-trigger-engine-posts--comments-collector)                                                    | Deep Crawl Trigger Engine (Posts & Comments Collector)                                                          | Lộc (Sub-lead) | 🟡 High     |
| [DA-AI05-19](#da-ai05-19--langchain-text-chunking-size-500-overlap-50)                                                            | LangChain Text Chunking (Size 500, Overlap 50)                                                                  | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI05-20](#da-ai05-20--text-embedding-pipeline-all-minilm-l6-v2-384d)                                                          | Text Embedding Pipeline (`all-MiniLM-L6-v2`, 384d)                                                              | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI05-21](#da-ai05-21--chromadb-vector-store-integration-hnsw-index-engine)                                                    | ChromaDB Vector Store Integration (HNSW Index Engine)                                                           | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI05-22](#da-ai05-22--llm-ner--relation-extraction-engine)                                                                    | LLM NER & Relation Extraction Engine                                                                            | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI05-23](#da-ai05-23--neo4j-knowledge-graph-ingestion-engine)                                                                 | Neo4j Knowledge Graph Ingestion Engine                                                                          | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI05-24](#da-ai05-24--entity-resolution-job-knowledge-graph-fusion)                                                           | Entity Resolution Job (Knowledge Graph Fusion)                                                                  | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI05-25](#da-ai05-25--raw-data-ingestion-json-parsing-object-normalization--hash-deduplication-engine-t0)                     | Raw Data Ingestion, JSON Parsing, Object Normalization & Hash Deduplication Engine (T0)                         | Ân (AI)        | 🔴 Critical |
| [DA-AI05-26](#da-ai05-26--bot-clone--spam-filter-engine-rule-kb1-kb2-kb3ab-kb5-kb6-t1)                                            | Bot, Clone & Spam Filter Engine (Rule KB1, KB2, KB3A/B, KB5, KB6) (T1)                                          | Ân (AI)        | 🔴 Critical |
| [DA-AI05-30](#da-ai05-30--vietnamese-nlp-preprocessing-engine-clean--nfkc--tokenize--slang--stopword-t2)                          | Vietnamese NLP Preprocessing Engine (Clean + NFKC + Tokenize + Slang + Stopword) (T2)                           | Ân (AI)        | 🔴 Critical |
| [DA-AI05-27](#da-ai05-27--multi-class-topic-classification-engine-6-categories-t3)                                                | Multi-Class Topic Classification Engine (6 Categories: tech, food, sports, entertainment, news, education) (T3) | Ân (AI)        | 🔴 Critical |
| [DA-AI05-31](#da-ai05-31--bm25-spike-detection-engine-split-window--bigram--time-series-t4)                                       | BM25 Spike Detection Engine (Split-Window + Bigram + Time-Series) (T4)                                          | Ân (AI)        | 🔴 Critical |
| [DA-AI05-28](#da-ai05-28--engagement-virality-score--reaction-mood-analysis-engine-t5)                                            | Engagement Virality Score & Reaction Mood Analysis Engine (haha/wow/care/sad/angry) (T5)                        | Ân (AI)        | 🔴 Critical |
| [DA-AI05-29](#da-ai05-29--jaccard-clustering-community-detection-engine-t6)                                                       | Jaccard Clustering Community Detection Engine (T6)                                                              | Ân (AI)        | 🔴 Critical |
| [DA-AI05-32](#da-ai05-32--trend-fusion--object-assembly-engine-cluster--trend-objects-t7)                                         | Trend Fusion & Object Assembly Engine (Cluster → Trend Objects) (T7)                                            | Ân (AI)        | 🔴 Critical |

### EPIC AI-4.99 — Analyze deeply crawl trend flow

| Task ID                                                                                                               | Description                                                                               | Assignee                 | Priority    |
| --------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------ | ----------- |
| [DA-AI04-99-01](#da-ai04-99-01--design--research-data-collection-layer-google-trends-tiktok-crawlers-social-firehose) | Design & research data collection layer (Google Trends, TikTok crawlers, Social firehose) | Tuấn (AI)                | 🔴 Critical |
| [DA-AI04-99-02](#da-ai04-99-02--research-trend-prediction-engine-algorithm-word-tokenization--bm25-anomaly-detection) | Research trend prediction engine algorithm (Word tokenization & BM25 Anomaly Detection)   | Ân (AI)                  | 🔴 Critical |
| [DA-AI04-99-03](#da-ai04-99-03--design-interaction-graph-analysis--centrality-algorithm-for-virality-score)           | Design interaction graph analysis & Centrality algorithm for Virality Score               | Ân (AI)                  | 🔴 Critical |
| [DA-AI04-99-04](#da-ai04-99-04--design-text-normalization--chunking-pipeline)                                         | Design text normalization & chunking pipeline                                             | Ân (AI) + Trung (Leader) | 🟡 High     |
| [DA-AI04-99-05](#da-ai04-99-05--design-hybrid-database-schema-chromadb--neo4j-ner-graph)                              | Design hybrid database schema (ChromaDB + Neo4j NER Graph)                                | Lộc (AI Sub-lead)        | 🔴 Critical |
| [DA-AI04-99-06](#da-ai04-99-06--design-redis-cache--neo4j-upsert-flow)                                                | Design Redis cache & Neo4j upsert flow                                                    | Lộc (AI Sub-lead)        | 🟡 High     |
| [DA-AI04-99-07](#da-ai04-99-07--compile-final-crawl-trend-analysis-blueprint-document)                                | Compile final crawl trend analysis blueprint document                                     | Tuấn (AI)                | 🟡 High     |

---

## AI Iteration 3 — Image, Ambassador & Composition (Parallel with Sprints 9–10)

### EPIC AI-06 — Commercial Image Generation Pipeline 🔀

> **Mở rộng theo kiến trúc v2.0 (Self-Hosted Architecture, 6 Topic LoRAs, Commercial Studio, Brand Ambassador IP-Adapter & FLUX.2 Native Multi-Reference Migration — Tổng cộng 38 tasks chia thành 6 Phase):** Triển khai Self-Hosted SDXL + Hệ sinh thái 6 Topic LoRAs trọng điểm (Food & Beverage, Fashion, Entertainment, Cosmetics, Tech, Living) kèm cơ chế Intent Routing tự động bắt tín hiệu prompt + Identity LoRA Serving Engine (SDXL-Lightning 4-step kiểm chứng song song), Form-to-Prompt Engine (Core UX), Batch Concurrency, Brand Safety Guardrails, Benchmark 20 Prompts, Canonical Identity Curation, Identity Dataset Standardization, Cloud Training Fault-Tolerance (Resume), Multi-Adapter LoRA Dynamic Loading & S3 Versioned Registry. Nâng cấp toàn diện Commercial Studio Harmonization & Advanced Canvas Control (Phase 4) và mở rộng Brand Ambassador Dual-Image IP-Adapter & 1-Click Storyboards (Phase 5, nâng quy mô từ 29 lên 33 tasks). Toàn bộ hình ảnh thương mại và danh tính đại sứ được xử lý độc lập trên cụm GPU riêng qua HTTP Adapter, loại bỏ hoàn toàn phụ thuộc vào Cloud API bên thứ 3 (Stability AI). Phân bổ nhân sự: Lộc (Backend/Client Adapter/Dynamic Loader/Studio), Ân (Prompt/Safety/Dataset/Catalog), Tuấn (GPU Serving/Identity LoRA/IP-Adapter/Checkpoint). Xem [Rebalance Log](jira-status-audit-2026-07-11.md#rebalance-log--sau-sprint-4) trong Jira Audit.

| Task ID | Description | Assignee | Priority |
| :--- | :--- | :--- | :--- |
| **Phase 1: Core Concept Studio Scaffolding & Colab Prototype (Track A)** | | | |
| [DA-AI06-01](#da-ai06-01--sdxl-runtimeinference-server-setup--sdxl-lightning-verification) | SDXL Runtime/Inference Server Setup & SDXL-Lightning Verification (Colab/VM, Base Checkpoint) | Tuấn (AI) | 🔴 Critical |
| [DA-AI06-02](#da-ai06-02--self-hosted-sdxl-inference-client-adapter) | Self-Hosted SDXL Inference Client Adapter (HTTP to GPU Server, error handling) | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI06-03](#da-ai06-03--aspect-ratio--sdxl-pixel-bucketing-engine) | Aspect Ratio & SDXL Pixel Bucketing Engine (1:1, 4:3, 16:9, 9:16, 2:3, 21:9) | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI06-04](#da-ai06-04--visual-style-preset-mapping-engine) | Visual Style Preset Mapping Engine (15 Master Commercial Styles & 6 Topic LoRAs Matrix) | Ân (AI) | 🟡 High |
| [DA-AI06-05](#da-ai06-05--multi-tier-safety-negative-prompt-injection) | Multi-tier Safety Negative Prompt Injection (Brand Safety & Fallback Negative) | Ân (AI) | 🔴 Critical |
| [DA-AI06-06](#da-ai06-06--input-sanitization--blacklist-guardrails) | Input Sanitization & Blacklist Guardrails (Regex & Prompt Injection Jailbreak Scanner) | Ân (AI) | 🔴 Critical |
| [DA-AI06-07](#da-ai06-07--hybrid-form-to-prompt-engine-core-ux-feature) | Hybrid Form-to-Prompt Engine (Core UX: Fast Rule Synthesizer + Prompt Signal Intent Routing + Perspective Guard) | Ân (AI) | 🔴 Critical |
| [DA-AI06-08](#da-ai06-08--pydantic-schemas--post-aiimagegenerate-route) | Pydantic Schemas & POST /ai/image/generate Route (Track A - Concept Studio với Topic Routing) | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI06-09](#da-ai06-09--in-memory-streaming-s3-upload--brand-logo-stamp) | In-Memory Streaming S3 Upload & Brand Logo Stamp (24h Presigned URLs, Pillow Logo Stamp) | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI06-10](#da-ai06-10--latency-tracking-custom-headers--observability) | Latency Tracking, Custom Response Headers & Observability (P95 < 30s SLO) | Lộc (Sub-lead) | 🟡 High |
| [DA-AI06-11](#da-ai06-11--concurrent-generation-orchestration-via-asynciogather) | Concurrent Generation Orchestration via asyncio.gather (1-4 variations, default 3) | Lộc (Sub-lead) | 🟡 High |
| [DA-AI06-12](#da-ai06-12--seed-diversity--visual-variation-strategy) | Seed Diversity & Visual Variation Strategy (Angle & Lighting diversity) | Ân (AI) | 🟡 High |
| [DA-AI06-13](#da-ai06-13--partial-failure-handling--credit-safety) | Partial Failure Handling & Credit Safety Audit (Only bill successful images) | Lộc (Sub-lead) | 🟡 High |
| **Phase 2: Real Product Studio Inpainting & Commercial Benchmark (Track B)** | | | |
| [DA-AI06-14](#da-ai06-14--real-product-studio-inpainting--commercial-placement-track-b) | Real Product Studio Inpainting & Commercial Placement (Track B: rembg CPU + RealVisXL Inpaint) | Tuấn & Lộc | 🔴 Critical |
| [DA-AI06-15](#da-ai06-15--20-commercial-product-prompts-dataset-across-5-categories) | 20 Commercial Product Prompts Dataset Across 5 Categories (Track A & Track B Benchmark) | Ân (AI) | 🟡 High |
| [DA-AI06-16](#da-ai06-16--automated-benchmark-runner--latencyquality-metrics) | Automated Benchmark Runner & Latency/Quality Metrics (Automated evaluation script) | Lộc (Sub-lead) | 🟡 High |
| [DA-AI06-17](#DA-AI06-17--prompt-template-library--sdxl-failure-analysis-report) | Prompt Template Library & SDXL Failure Analysis Report (Top 10 templates, 5 failure modes) | Ân (AI) | 🟡 High |
| **Phase 3: Virtual Identity Ambassador LoRA (Expansion Track)** | | | |
| [DA-AI06-18](#da-ai06-18--canonical-identity--multi-view-references-curation) | Canonical Identity & Multi-View References Curation (Spec hồ sơ danh tính, 25-35 ảnh đa góc) | Ân (AI) | 🔴 Critical |
| [DA-AI06-19](#da-ai06-19--training-dataset-collection--quality-curation) | Training Dataset Collection & Quality Curation (120-150 commercial images 1024x1024) | Ân (AI) | 🟡 High |
| [DA-AI06-20](#da-ai06-20--automated--manual-dataset-captioning-pipeline) | Automated & Manual Dataset Captioning Pipeline (WD14 Tagger / Vision LLM + Trigger word) | Ân (AI) | 🟡 High |
| [DA-AI06-21](#da-ai06-21--identity-dataset-standardization--versioned-manifest) | Identity Dataset Standardization & Versioned Manifest (Crop/scale, trigger token, dataset manifest) | Ân & Lộc | 🔴 Critical |
| [DA-AI06-22](#da-ai06-22--cloud-training-fault-tolerance-checkpoint-restart--exact-resume) | Cloud Training Fault-Tolerance: Checkpoint, Restart & Exact Resume (Lưu snapshot, resume step) | Tuấn (AI) | 🔴 Critical |
| [DA-AI06-23](#da-ai06-23--identity-lora-fine-tuning-pipeline-for-virtual-identity) | Topic & Identity LoRA Fine-Tuning Pipeline (Kohya_ss/Diffusers cho 6 Domain Topics và Virtual Identity) | Tuấn (AI) | 🔴 Critical |
| [DA-AI06-24](#da-ai06-24--identity-lora-artifact-packaging--s3-versioned-registry) | LoRA Artifact Packaging & S3 Versioned Registry (Namespace topics/ & identities/, metadata) | Tuấn & Lộc | 🟡 High |
| [DA-AI06-25](#da-ai06-25--identity-lora-dynamic-loader--model-compatibility-check) | Multi-Adapter Dynamic LoRA Loader & Model Compatibility Check (Warm Pre-load 6 Topic LoRAs, Hot-swap < 25ms, Handoff sang AI-07) | Tuấn & Lộc | 🟡 High |
| **Phase 4: Commercial Studio Harmonization & Advanced Canvas Control (Post-Evaluation Upgrade)** | | | |
| [DA-AI06-26](#da-ai06-26--product-studio-canvas-transform--2d-pose-positioning-engine) | Product Studio Canvas Transform & 2D Pose Positioning Engine (X/Y, Scale, Rotation, Flip & Surface Semantics) | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI06-27](#da-ai06-27--visual-optical-harmonizer--dual-layer-directional-shadow-engine) | Visual Optical Harmonizer & Dual-Layer Directional Shadow Engine (Reinhard LAB, Ambient Bleed, Penumbra Shadow) | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI06-28](#da-ai06-28--fast-llm-commercial-studio-prompt-rewriter--surface-semantics) | Fast LLM Commercial Studio Prompt Rewriter & Placement Surface Semantics (Groq LLaMA 3.3 / Gemini fallback) | Ân & Lộc | 🟡 High |
| [DA-AI06-29](#da-ai06-29--dual-mode-interactive-studio-controller) | Dual-Mode Interactive Studio Controller (Quick 1-Click Presets & Granular Fine-Tune Sliders on /studio) | Lộc (Sub-lead) | 🟡 High |
| **Phase 5: Brand Ambassador IP-Adapter & 1-Click Storyboards (Advanced Visual Consistency)** | | | |
| [DA-AI06-30](#da-ai06-30--dual-image-ip-adapter-integration-on-sdxl-inference-worker-colab-t4kaggle-p100) | Dual-Image IP-Adapter Integration on SDXL Inference Worker (Colab T4/Kaggle P100) | Tuấn & Lộc | 🔴 Critical |
| [DA-AI06-31](#da-ai06-31--brand-ambassador-model-sheet-presets-ngoc-chau-22--storage-catalog) | Brand Ambassador Model Sheet Presets (Ngọc Châu 22) & Storage Catalog | Ân & Lộc | 🟡 High |
| [DA-AI06-32](#da-ai06-32--seamless-1-click-storyboards-ui--zero-cutout-routing) | Seamless 1-Click Storyboards UI & Zero-Cutout Routing | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI06-33](#da-ai06-33--e2e-integration-testing--character-consistency-benchmarks) | E2E Integration Testing & Character Consistency Benchmarks | Lộc, Tuấn, Ân | 🔴 Critical |
| **Phase 6: FLUX.2 Native Multi-Reference Commercial Studio & Async Pipeline Migration** | | | |
| [DA-AI06-34](#da-ai06-34--research-flux2-production-hardware--runtime-decision) | [DA-1250](https://letritrung2605.atlassian.net/browse/DA-1250) — Research FLUX.2 Production Hardware & Runtime Decision | Lộc (AI Sub-lead) | 🔴 Critical |
| [DA-AI06-35](#da-ai06-35--durable-asynchronous-commercial-generation-orchestration) | [DA-1251](https://letritrung2605.atlassian.net/browse/DA-1251) — Durable Asynchronous Commercial Generation Orchestration | Lộc (AI Sub-lead) | 🔴 Critical |
| [DA-AI06-36](#da-ai06-36--flux2-private-gpu-worker-idempotency--failure-recovery) | [DA-1252](https://letritrung2605.atlassian.net/browse/DA-1252) — FLUX.2 Private GPU Worker, Idempotency & Failure Recovery | Lộc (AI Sub-lead) | 🔴 Critical |
| [DA-AI06-37](#da-ai06-37--commercial-studio-gateway-authentication--async-ui-contract) | [DA-1253](https://letritrung2605.atlassian.net/browse/DA-1253) — Commercial Studio Gateway Authentication & Async UI Contract | Lộc (AI Sub-lead) | 🟡 High |
| [DA-AI06-38](#da-ai06-38--flux2-benchmark-canary-cutover--legacy-retirement) | [DA-1254](https://letritrung2605.atlassian.net/browse/DA-1254) — FLUX.2 Benchmark, Canary, Cutover & Legacy Retirement | Lộc (AI Sub-lead) | 🟡 High |

### EPIC AI-07 — Virtual Brand Ambassador (SDXL + Identity LoRA + DWPose ControlNet) 🔀

> **Mở rộng theo kiến trúc v2.0 (SDXL + Identity LoRA + DWPose ControlNet Serving Engine):** Phân rã toàn diện pipeline đại sứ thương hiệu ảo sang cụm GPU Server RTX 4090 (24GB VRAM). Sinh ảnh toàn thân (full-body shot) chuẩn xác danh tính người mẫu và khống chế tư thế linh hoạt bằng DWPose 133 điểm keypoints kết hợp Identity LoRA; InstantID đóng vai trò pipeline đối chứng trong các bài đo lường benchmark. Tích hợp InsightFace buffalo_l in-memory preprocessing, bộ lọc 4 edge cases thị giác (Fail-fast HTTP 422), Pydantic Schemas & Server-Timing, Cosine Similarity Gating (≥ 0.85), S3 Gallery CRUD multi-tenant, bóc nền Singleton qua rembg U2Net, ghép phối sáng tự nhiên, 5 phong cách thương mại, model guardrails chống dị tật, kiểm thử 15 ảnh đa góc và benchmark đối đầu định lượng với InstantID baseline. Phân bổ nhân sự cân bằng: Lộc (Backend/S3/Compositing/API - 5 tasks), Tuấn (GPU Serving/Model Engine/DWPose/Benchmark - 5 tasks), Ân (Face Preprocess/Prompt UX/Testing - 6 tasks).

| Task ID | Description | Assignee | Priority |
| :--- | :--- | :--- | :--- |
| [DA-AI07-01](#da-ai07-01--model-weights--checkpoints-management-sdxl-dwpose-controlnet) | Model Weights & Checkpoints Management (SDXL Base, DWPose Onnx, SDXL Pose ControlNet) | Tuấn (AI) | 🔴 Critical |
| [DA-AI07-02](#da-ai07-02--in-memory-face-preprocessing--512-dim-embedding-extraction) | In-Memory Face Preprocessing & 512-dim Embedding Extraction (OpenCV, InsightFace buffalo_l) | Ân (AI) | 🔴 Critical |
| [DA-AI07-03](#da-ai07-03--4-edge-case-visual-input-defense--fail-fast-guardrails) | 4-Edge-Case Visual Input Defense & Fail-Fast Guardrails (NoFace, MultiFace, ExtremePose, Blurry) | Ân (AI) | 🟡 High |
| [DA-AI07-04](#da-ai07-04--ambassador-full-body-serving-engine-sdxl--identity-lora--pose-controlnet) | Ambassador Full-Body Serving Engine (SDXL + Identity LoRA + Pose ControlNet DWPose) | Tuấn (AI) | 🔴 Critical |
| [DA-AI07-05](#da-ai07-05--rewriting-ambassador-api-route--control-flow) | Rewriting Ambassador API Route & Control Flow (LoRA+Pose Main, InstantID Baseline Flag) | Lộc (AI Sub-lead) | 🔴 Critical |
| [DA-AI07-06](#da-ai07-06--pydantic-schemas--post-aiambassadorgenerate-route) | Pydantic Schemas & POST /ai/ambassador/generate Route (Multipart upload, Server-Timing) | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI07-07](#da-ai07-07--face-consistency-metric-engine--cosine-similarity-gating--085) | Face Consistency Metric Engine & Cosine Similarity Gating (PASS ≥ 0.85, WARN, FAIL) | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI07-08](#da-ai07-08--ambassador-s3-gallery-management-crud-presigned-urls-1h) | Ambassador S3 Gallery Management (CRUD, Presigned URLs 1h, Multi-tenant) | Lộc (Sub-lead) | 🟡 High |
| [DA-AI07-09](#da-ai07-09--ambassador-singleton-background-removal-via-rembg-u2net) | Ambassador Singleton Background Removal via rembg (U2Net, alpha matting, < 1.5s) | Lộc (Sub-lead) | 🟡 High |
| [DA-AI07-10](#da-ai07-10--ambassador-background-placement-post-aiambassadorapply--natural-relighting) | Ambassador Background Placement POST /ai/ambassador/apply & Natural Relighting (Drop shadow) | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI07-11](#da-ai07-11--5-commercial-ambassador-style--wardrobe-presets) | 5 Commercial Ambassador Style & Wardrobe Presets (Fashion, Business, Casual, Sport, Luxury) | Ân (AI) | 🟡 High |
| [DA-AI07-12](#da-ai07-12--multi-tier-model-guardrails--anti-plastic-negative-prompts) | Multi-tier Model Guardrails & Anti-Plastic Negative Prompts (Hands, eyes, skin texture) | Ân (AI) | 🔴 Critical |
| [DA-AI07-13](#da-ai07-13--multi-angle-face-consistency-benchmark-15-images--86-pass--085) | Multi-Angle Face Consistency Benchmark (15 Images, 5 angles x 3 outfits, ≥ 86% Pass ≥ 0.85) | Ân (AI) | 🔴 Critical |
| [DA-AI07-14](#da-ai07-14--comprehensive-ambassador-benchmark-lorapose-vs-instantid-baseline) | Comprehensive Ambassador Benchmark: LoRA+Pose vs InstantID Baseline (20 Images, 4 metrics) | Tuấn & Ân | 🟡 High |
| [DA-AI07-15](#da-ai07-15--5-master-commercial-ambassador-templates--operational-guide) | 5 Master Commercial Ambassador Templates & Operational Guide (Starter configs & GPU guide) | Ân (AI) | 🟢 Low |
| [DA-AI07-16](#da-ai07-16--dwpose-keypoints-extraction--control-image-normalization) | DWPose Keypoints Extraction & Control Image Normalization (133 points, skeleton canvas) | Tuấn (AI) | 🔴 Critical |

### EPIC AI-08 — Image Composition Pipeline 🔀

> **Kiến trúc Hybrid Composition & End-to-End Pipeline:** Kết hợp luồng ghép ảnh Pillow 2D / rembg U2Net (Fast Zero-GPU Fallback, xử lý < 2s cho ảnh sản phẩm thông thường) với luồng AI Composition chuyên sâu: Virtual Try-On (VTON: IDM-VTON / CatVTON thử đồ thời trang), Local Refinement Inpainting (phục hồi chi tiết mắt, bàn tay với retry limiter tối đa 2 lần & QA Gate Pre/Post Upscale), Stage Runner tuần tự kiểm soát VRAM GPU RTX 4090 không vượt quá 20GB, lưu intermediate outputs hỗ trợ resume on failure, và hoàn thiện End-to-End Cloud Ambassador Pipeline bàn giao AI service contract. Phân bổ: Tuấn (VTON/Refinement/Compositing), Lộc (Stage Runner/E2E API/Handoff), Ân (Benchmark/QA/Templates). Xem [Rebalance Log](jira-status-audit-2026-07-11.md#rebalance-log--sau-sprint-4) trong Jira Audit.

| Task ID | Description | Assignee | Priority |
| :--- | :--- | :--- | :--- |
| [DA-AI08-01](#da-ai08-01-implement-background-removal-for-product-images-rembg-u2net-output-transparent-png) | Implement background removal for product images (rembg library, U2Net model) → output transparent PNG | Tuấn (AI) | 🔴 Critical |
| [DA-AI08-02](#da-ai08-02-implement-background-removal-for-modelambassador-images) | Implement background removal for model/ambassador images | Tuấn (AI) | 🔴 Critical |
| [DA-AI08-03](#da-ai08-03-build-layer-compositing-service-product-layer-model-layer-background-layer-pillow-composite) | Build layer compositing service (product layer + model layer + background layer → single image using Pillow) | Tuấn (AI) | 🔴 Critical |
| [DA-AI08-04](#da-ai08-04-implement-shadow-lighting-adjustment-for-natural-looking-merges) | Implement shadow + lighting adjustment for natural-looking merges | Tuấn (AI) | 🟡 High |
| [DA-AI08-05](#da-ai08-05-build-post-aicompose-endpoint) | Build composition endpoint (POST /ai/compose: product S3 key + model S3 key + background S3 key → composed image) | Tuấn (AI) | 🔴 Critical |
| [DA-AI08-06](#da-ai08-06-test-20-product-model-pairs-evaluate-realism-document-failure-cases) | Test 20 product + model pairs, evaluate realism score, document failure cases | Tuấn (AI) | 🟡 High |
| [DA-AI08-07](#da-ai08-07-write-composition-parameter-guide-optimal-image-sizes-best-practices-per-product-category) | Write composition parameter guide (optimal sizes, best practices per product type) | Tuấn (AI) | 🟢 Low |
| [DA-AI08-08](#da-ai08-08--virtual-try-on-vton-model-benchmark-idm-vton-vs-catvton--sku-fidelity) | Virtual Try-On (VTON) Benchmark: IDM-VTON vs CatVTON, SKU Texture & Pattern Fidelity | Tuấn & Ân | 🔴 Critical |
| [DA-AI08-09](#da-ai08-09--local-refinement--facehand-detailer-with-retry-limiter--prepost-qa) | Local Refinement & Face/Hand Detailer (Retry limiter ≤ 2, Pre/Post Upscale QA Gate) | Tuấn & Ân | 🔴 Critical |
| [DA-AI08-10](#da-ai08-10--sequential-stage-runner-vram-lifecycle--crash-recovery) | Sequential Stage Runner (VRAM ≤ 20GB, Intermediate Outputs, Resume on Failure) | Lộc & Tuấn | 🔴 Critical |
| [DA-AI08-11](#da-ai08-11--end-to-end-cloud-ambassador-pipeline--ai-service-contract-handoff) | End-to-End Cloud Ambassador Pipeline Integration & AI Service Contract Handoff | Lộc, Tuấn, Ân | 🔴 Critical |

---

## AI Iteration 4 — Video, Integration & Documentation (Parallel with Sprints 11–12)

### EPIC AI-09 — AI Video Generation

| Task ID | Description | Assignee | Priority |
| --- | --- | --- | --- |
| [DA-AI09-01](#da-ai09-01--pydantic-schemas--async-video-job-state-management-in-redis) | Pydantic Schemas & Redis Async Job State Machine (PENDING → PROCESSING → COMPLETED/FAILED, TTL 24h, zero-thumbnail) | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI09-02](#da-ai09-02--google-veo-api-client--async-generation-engine) | Google Veo API Client & Async Generation Engine (Vertex AI auth, job dispatch, async polling loop, timeout guard) | Tuấn (AI) | 🔴 Critical |
| [DA-AI09-03](#da-ai09-03--movement-parameter-mapping--camera-motion-translation-engine) | Movement Parameter Mapping (Pan, Tilt, Zoom, Dolly, Static) & Video Configurations (16:9/9:16/1:1, 24/30 FPS) | Tuấn (AI) | 🟡 High |
| [DA-AI09-04](#da-ai09-04--direct-s3-video-streamer-ffprobe-duration-extractor--presigned-url-7-days-zero-thumbnail) | Direct S3 Stream, FFprobe Duration & Presigned URL 7 ngày (Zero Thumbnail: loại bỏ decode ffmpeg tối đa tốc độ) | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI09-05](#da-ai09-05--fastapi-video-endpoints-post-aivideogenerate--get-aivideojobidstatus--async-polling) | FastAPI Video Endpoints (POST /ai/video/generate returns jobId, GET /ai/video/{jobId}/status polling, no thumbnail) | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI09-06](#da-ai09-06--video-prompt-engineering-engine--form-to-prompt-converter) | Video Prompt Engineering Engine & Form-to-Prompt Converter (Topic, tone, camera motion → Veo prompt) | Ân (AI) | 🔴 Critical |
| [DA-AI09-07](#da-ai09-07--master-marketing-video-prompt-library-10-archetypes--3-motion-styles--30-templates) | Master Marketing Video Prompt Library (10 Archetypes × 3 Motion Styles = 30 Production-ready Templates) | Ân (AI) | 🔴 Critical |
| [DA-AI09-08](#da-ai09-08--content-safety-guardrails--negative-motion-constraints-for-video) | Content Safety Guardrails & Negative Motion Constraints (Anti-jitter, anti-distortion, brand safety filter) | Ân (AI) | 🟡 High |
| [DA-AI09-09](#da-ai09-09--empirical-quality--cost-benchmark-across-30-video-templates) | Empirical Quality & Cost Benchmark across 30 Video Templates (Generation time, stability, cost per video) | Ân (AI) | 🟡 High |
| [DA-AI09-10](#da-ai09-10--video-generation-pipeline-integration-end-to-end-testing--technical-report) | Video Generation Pipeline Integration, End-to-End Testing, OpenAPI/Postman & Technical Research Report | Lộc (Lead) & Tuấn, Ân | 🔴 Critical |

### EPIC AI-10 — AI Service Integration & API Finalize

| Task ID                                                                                                                               | Description                                                                                                             | Assignee          | Priority    |
| ------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-AI10-01](#da-ai10-01-finalize-all-fastapi-endpoints)                                                                              | Finalize all FastAPI endpoints (/ai/content, /ai/image, /ai/video, /ai/ambassador, /ai/compose, /ai/rag/\*, /ai/trends) | Lộc (AI Sub-lead) | 🔴 Critical |
| [DA-AI10-02](#da-ai10-02-error-handling-retry-for-external-ai-api-calls-exponential-backoff-fallback-provider-on-rate-limit)          | Error handling & retry for external AI API calls (exponential backoff, fallback provider)                               | All (Team)        | 🟡 High     |
| [DA-AI10-03](#da-ai10-03-integration-test-with-business-service-verify-all-ai-calls-from-business-service-reach-ai-service-correctly) | Integration test with business-service (verify all AI calls from business-service work correctly)                       | All (Team)        | 🔴 Critical |
| [DA-AI10-04](#da-ai10-04-write-postman-collection-for-all-ai-endpoints-with-example-requests-and-responses)                           | Write Postman collection for all AI endpoints with example requests                                                     | Lộc (AI Sub-lead) | 🟢 Medium   |
| [DA-AI10-05](#da-ai10-05-write-swaggeropenapi-documentation-for-ai-service-auto-generated-via-fastapi-docs)                           | Write Swagger/OpenAPI documentation for ai-service                                                                      | Lộc (AI Sub-lead) | 🟢 Medium   |

### EPIC AI-11 — AI Research Documentation & Demo

| Task ID                                                                                                           | Description                                                                                                           | Assignee          | Priority    |
| ----------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-AI11-01](#da-ai11-01-write-virtual-ambassador-technical-report)                                               | Write Virtual Ambassador Technical Report (model comparison, implementation decisions, sample results gallery)        | Tuấn (AI)         | 🔴 Critical |
| [DA-AI11-02](#da-ai11-02-write-video-generation-research-report-full-prompt-library-movement-guide-cost-analysis) | Write Video Generation Research Report (full prompt library of 30 templates, movement parameter guide, cost analysis) | Ân (AI)           | 🔴 Critical |
| [DA-AI11-03](#da-ai11-03-write-image-composition-research-report)                                                 | Write Image Composition Research Report (technique comparison, best practices, quality evaluation)                    | Lộc (AI Sub-lead) | 🟡 High     |
| [DA-AI11-04](#da-ai11-04-compile-ai-cost-analysis-estimated-cost-per-feature-average-usage-1000-usersmonth)       | Compile AI Cost Analysis (estimated cost per feature x average usage x 1000 users/month)                              | All (Team)        | 🟡 High     |
| [DA-AI11-05](#da-ai11-05-record-ai-feature-demo-video-showcase-all-7-ai-features-working-end-to-end)              | Record AI feature demo video (showcase all 7 AI features working in practice)                                         | All (Team)        | 🔴 Critical |
| [DA-AI11-06](#da-ai11-06-present-ai-results-to-mentor-live-demo-qa-collect-feedback-for-final-report)             | Present AI results to mentor (live demo + Q&A, collect feedback)                                                      | All (Team)        | 🔴 Critical |

---

## PHASE 5 — Content Workflow & Publishing

---

## Sprint 10 — Content Requests & Calendar (Weeks 19–20)

### EPIC E28 — Task & Content Workflow _(re-scope V2, 2026-09-15 — cũ: "Content Request Management", nay chứa DA-E51-xx)_

| Task ID                                                      | Description                                                                                                            | Assignee       | Priority    |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------- | -------------- | ----------- |
| [DA-E28-01](#da-e28-01-implement-post-apiv1content-requests) | Implement POST /api/v1/content-requests (CLIENT submits request: topic, platform, tone, deadline)                | Trung (Leader) | 🔴 Critical |
| [DA-E28-02](#da-e28-02-implement-get-apiv1content-requests)  | Implement GET /api/v1/content-requests (MANAGER views list of requests from their assigned clients)            | Trung (Leader) | 🔴 Critical |
| [DA-E28-03](#da-e28-03-implement-status-transition-logic)    | Implement status tracking (SUBMITTED → ASSIGNED → IN_PROGRESS → PENDING_REVIEW → SENT_TO_CLIENT → APPROVED → REJECTED) | Trung (Leader) | 🔴 Critical |

### EPIC E29 — Task Assignment & Tracking _(GỘP vào E28 — DA-120 đã Cancel trên Jira 2026-09-15, sau đó không còn tồn tại trên Jira nữa (đã bị xoá) — giữ mục này chỉ để tham khảo lịch sử)_

| Task ID                                                             | Description                                                                                          | Assignee       | Priority    |
| ------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- | -------------- | ----------- |
| [DA-E29-01](#da-e29-01-implement-put-apiv1content-requestsidassign) | Implement PUT /api/v1/content-requests/{id}/assign (MANAGER assigns task to CREATOR) | Trung (Leader) | 🔴 Critical |
| [DA-E29-02](#da-e29-02-implement-get-apiv1content-requestsmy-tasks) | Implement GET /api/v1/content-requests/my-tasks (CREATOR views their assigned tasks)         | Trung (Leader) | 🔴 Critical |
| [DA-E29-03](#da-e29-03-implement-deadline-alert-notification)       | Implement deadline management (alert when a task is approaching its deadline)                        | Ân (AI)        | 🟡 High     |

### EPIC E30 — Media Package & Campaign _(re-scope V2, 2026-09-15 — cũ: "Content Calendar & Scheduling", nay chứa DA-E50-xx)_

| Task ID                                                       | Description                                                                                               | Assignee          | Priority    |
| ------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E30-01](#da-e30-01-implement-get-apiv1postscalendar)      | Implement GET /api/v1/posts/calendar (retrieve posts by date range, filter by platform/status)            | Trung (Leader)    | 🔴 Critical |
| [DA-E30-02](#da-e30-02-implement-post-apiv1postsidschedule)   | Implement POST /api/v1/posts/{id}/schedule (MANAGER sets schedule: scheduledAt + targetPlatforms) | Trung (Leader)    | 🔴 Critical |
| [DA-E30-03](#da-e30-03-build-contentcalendar-react-component) | Build ContentCalendar React component (drag-drop rescheduling, color-coded status indicators)             | Lộc (AI Sub-lead) | 🔴 Critical |
| [DA-E30-04](#da-e30-04-build-platformpreview-component)       | Build PlatformPreview component (display preview in the correct format for FB, IG, TikTok, Threads)       | Lộc (AI Sub-lead) | 🟡 High     |

---

## Sprint 11 — Approval Workflow & Full Publishing (Weeks 21–22)

### EPIC E31 — Approval Workflow _(re-scope V2, 2026-09-15 — nay theo Approval Sequence state machine, xem DA-E51-02/03)_

| Task ID                                                           | Description                                                                                   | Assignee       | Priority    |
| ----------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | -------------- | ----------- |
| [DA-E31-01](#da-e31-01-implement-post-apiv1postsidsubmit)         | Implement POST /api/v1/posts/{id}/submit (CREATOR submits → PENDING_REVIEW)           | Trung (Leader) | 🔴 Critical |
| [DA-E31-02](#da-e31-02-implement-post-apiv1postsidaccount-review) | Implement POST /api/v1/posts/{id}/account-review (MANAGER approves or rejects + note) | Trung (Leader) | 🔴 Critical |
| [DA-E31-03](#da-e31-03-implement-post-apiv1postsidclient-approve) | Implement POST /api/v1/posts/{id}/client-approve (CLIENT approves → SCHEDULED)          | Trung (Leader) | 🔴 Critical |
| [DA-E31-04](#da-e31-04-implement-post-apiv1postsidclient-reject)  | Implement POST /api/v1/posts/{id}/client-reject (CLIENT rejects + feedback)             | Trung (Leader) | 🔴 Critical |

### EPIC E32 — Publishing System _(re-scope V2, 2026-09-15 — nay chứa DA-E52-xx)_

| Task ID                                                                            | Description                                                                                               | Assignee          | Priority    |
| ---------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E32-01](#da-e32-01-implement-smart-ingestion-publishjobmessage-packaging)      | Implement Smart Ingestion (package post + encrypted token + platform configs into a RabbitMQ message)     | Trung (Leader)    | 🔴 Critical |
| [DA-E32-02](#da-e32-02-implement-rabbitmq-consumer-in-publisher-service)           | Implement RabbitMQ consumer in publisher-service (FIFO, exactly-once, acknowledgement)                    | Phước (Publisher) | 🔴 Critical |
| [DA-E32-03](#da-e32-03-implement-facebook-adapter)                                 | Implement Facebook adapter (Graph API: IMAGE post and REEL/VIDEO)                                         | Phước (Publisher) | 🔴 Critical |
| [DA-E32-04](#da-e32-04-implement-instagram-adapter)                                | Implement Instagram adapter (2-step: create container → publish)                                          | Phước (Publisher) | 🔴 Critical |
| [DA-E32-05](#da-e32-05-implement-tiktok-adapter)                                   | Implement TikTok adapter (Direct Post for video ≤60s, Creator Upload for video >60s)                      | Phước (Publisher) | 🔴 Critical |
| [DA-E32-06](#da-e32-06-implement-threads-adapter)                                  | Implement Threads adapter (2-step: create container → publish, max 500 chars)                             | Phước (Publisher) | 🔴 Critical |
| [DA-E32-08](#da-e32-08-implement-http-callback-post-internalpostsidpublish-result) | Implement HTTP callback → business-service after publish completes (update post status: PUBLISHED/FAILED) | Phước (Publisher) | 🔴 Critical |

> ~~DA-E32-07 — Implement Zalo OA adapter~~ — **loại khỏi scope** (2026-09-03), đã xóa khỏi Jira (DA-361).

### EPIC E33 — Publish Error Handling & Content Safety _(re-scope V2, 2026-09-15 — bổ sung Compliance/Copyright check, xem DA-E51-11/12)_

| Task ID                                                       | Description                                                                                        | Assignee          | Priority    |
| ------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E33-01](#da-e33-01-implement-retry-logic)                 | Implement retry logic (up to 3 attempts, exponential backoff: 30s, 60s, 120s)                      | Phước (Publisher) | 🔴 Critical |
| [DA-E33-02](#da-e33-02-implement-dead-letter-queue-admin-api) | Implement Dead Letter Queue handler (Admin can view and manually retry or discard failed posts)    | Trung (Leader)    | 🔴 Critical |
| [DA-E33-03](#da-e33-03-implement-failure-notification)        | Implement failure notification (send alert to Manager when a post fails after all retries) | Trung (Leader)    | 🔴 Critical |

---

## PHASE 6 — Frontend & Analytics

> **CHÍNH SÁCH MỚI (2026-09-03):** Từ giai đoạn tiếp theo trở đi, KHÔNG tách epic/task FE riêng nữa. FE tích hợp chung vào task BE tương ứng (1 task = làm API + build page/component đi kèm luôn) — team làm song song BE với FE trong cùng 1 task cho đơn giản, thay vì tách 2 task riêng (1 BE + 1 FE) như E35/E36 trước đây. Áp dụng từ Sprint 8 trở đi — E37 Client Portal là epic FE cuối cùng còn tách riêng, đã move vào Sprint 8.

---

## Sprint 12 — Core Pages (Weeks 23–24)

> **EPIC E34 — Design System đã dời lên Sprint 5** 🔀 (xem [Rebalance Log](jira-status-audit-2026-07-11.md#rebalance-log--sau-sprint-4) trong Jira Audit).
> **EPIC E35 & E36 đã dời lên Sprint 6** 🔀 (2026-08-02) — UI auth + workspace + client + content cần có sớm để song song với backend APIs.

### EPIC E35 — Auth & Dashboard Pages 🔀 _(đã dời lên Sprint 6)_

| Task ID                                                  | Description                                                                    | Assignee          | Priority    |
| -------------------------------------------------------- | ------------------------------------------------------------------------------ | ----------------- | ----------- |
| [DA-E35-01](#da-e35-01-build-login-and-register-pages)   | Build Login/Register pages with Google OAuth button                            | Trung (Leader)    | 🔴 Critical |
| [DA-E35-02](#da-e35-02-build-main-dashboard-page)        | Build main Dashboard page (overview: total posts, success rate, team activity) | Phước (Publisher) | 🔴 Critical |
| [DA-E35-03](#da-e35-03-build-workspace-management-pages) | Build Workspace management pages (create, settings, members)                   | Trung (Leader)    | 🔴 Critical |
| [DA-E35-04](#da-e35-04-build-client-management-pages)    | Build Client management pages (list, create, edit, service package)            | Phước (Publisher) | 🔴 Critical |

### EPIC E36 — Content Management Pages 🔀 _(đã dời lên Sprint 6)_

| Task ID                                                                  | Description                                                                                           | Assignee          | Priority    |
| ------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E36-01](#da-e36-01-build-content-request-list-page)                  | Build Content Request list page (filter by status, platform, deadline)                                | Phước (Publisher) | 🔴 Critical |
| [DA-E36-02](#da-e36-02-build-content-editor-page-with-ai-generate-panel) | Build Content Editor page with AI Generate Panel (call ai-service, display caption + hashtag + image) | Phước (Publisher) | 🔴 Critical |
| [DA-E36-03](#da-e36-03-build-content-calendar-page)                      | Build Content Calendar page (calendar view + drag-drop rescheduling)                                  | Phước (Publisher) | 🔴 Critical |
| [DA-E36-04](#da-e36-04-build-platform-preview-modal)                     | Build Platform Preview modal (accurately preview the format of each platform)                         | Phước (Publisher) | 🟡 High     |
| [DA-E36-05](#da-e36-05-build-content-library-page)                       | Build Content Library page (media browser, template browser, hashtag groups)                          | Phước (Publisher) | 🟡 High     |

---

## Sprint 13 — Client Portal, Analytics & Notifications (Weeks 25–26)

> **EPIC E37 đã dời lên Sprint 8** 🔀 (2026-09-03) — epic FE cuối cùng còn tách riêng, đẩy sớm để kịp song song với E22/E32. Từ đây các task FE còn lại (E38-04, E39-03, mobile...) không tách epic riêng nữa mà gộp vào task BE tương ứng.

### EPIC E38 — Analytics & Reporting

| Task ID                                                           | Description                                                                                           | Assignee          | Priority    |
| ----------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E38-01](#da-e38-01-implement-analytics-aggregation-apis)      | Implement analytics aggregation APIs (aggregate data from posts + publish_logs)                       | Trung (Leader)    | 🔴 Critical |
| [DA-E38-02](#da-e38-02-implement-automated-pdf-report-generation) | Implement automated report generation (weekly/monthly PDF report for clients)                         | Trung (Leader)    | 🟡 High     |
| [DA-E38-03](#da-e38-03-implement-scheduled-report-email-sending)  | Implement report email sending (automatically send email to Client on schedule)                 | Ân (AI)           | 🟡 High     |
| [DA-E38-04](#da-e38-04-build-analytics-dashboard)                 | Build Analytics Dashboard (charts: publishing success rate, platform breakdown, campaign performance) | Phước (Publisher) | 🔴 Critical |

### EPIC E39 — Notification System

| Task ID                                                                   | Description                                                                                           | Assignee          | Priority    |
| ------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E39-01](#da-e39-01-implement-notification-crud-apis)                  | Implement notification CRUD APIs (/api/v1/notifications: GET, PUT read, PUT read-all)                 | Trung (Leader)    | 🟡 High     |
| [DA-E39-02](#da-e39-02-implement-notification-creation-for-7-event-types) | Implement notification creation when events occur (post published, task assigned, token expiry, etc.) | Trung (Leader)    | 🔴 Critical |
| [DA-E39-03](#da-e39-03-build-notification-center-ui)                      | Build Notification Center UI (dropdown bell icon, unread badge, list with mark as read)               | Phước (Publisher) | 🟡 High     |

---

## PHASE 7 — Testing, Deployment & Final Report

---

## Sprint 14 — Mobile App (Weeks 27–28)

### EPIC E40 — Mobile App Core

| Task ID                                                  | Description                                                                                   | Assignee          | Priority    |
| -------------------------------------------------------- | --------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E40-01](#da-e40-01-set-up-react-native-expo-project) | Set up React Native project with Expo, navigation (React Navigation v6)                       | Phước (Publisher) | 🔴 Critical |
| [DA-E40-02](#da-e40-02-build-auth-screens-mobile)        | Build Auth screens (Login, Register, Forgot Password)                                         | Phước (Publisher) | 🔴 Critical |
| [DA-E40-03](#da-e40-03-build-dashboard-screen-mobile)    | Build Dashboard screen (simplified overview)                                                  | Phước (Publisher) | 🔴 Critical |
| [DA-E40-04](#da-e40-04-build-calendar-screen-mobile)     | Build Calendar screen (calendar view, post status)                                            | Phước (Publisher) | 🟡 High     |
| [DA-E40-05](#da-e40-05-build-approval-screen-mobile)     | Build Approval screen for CLIENT (view preview, approve/reject)                         | Phước (Publisher) | 🔴 Critical |
| [DA-E40-06](#da-e40-06-implement-offline-draft-mode)     | Implement offline draft mode (save draft to AsyncStorage when offline, sync when back online) | Phước (Publisher) | 🟡 High     |

### EPIC E41 — Mobile Notifications

| Task ID                                                             | Description                                                                      | Assignee          | Priority    |
| ------------------------------------------------------------------- | -------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E41-01](#da-e41-01-integrate-fcm-push-notifications-mobile)     | Integrate Firebase Cloud Messaging (FCM) for push notifications                  | Phước (Publisher) | 🔴 Critical |
| [DA-E41-02](#da-e41-02-set-up-fcm-server-side-in-business-service)  | Set up FCM server-side (send notification when events occur in business-service) | Trung (Leader)    | 🔴 Critical |
| [DA-E41-03](#da-e41-03-build-notification-screen-mobile)            | Build Notification screen (list notifications, deep link on tap)                 | Phước (Publisher) | 🟡 High     |
| [DA-E41-04](#da-e41-04-integrate-expo-image-picker-and-expo-camera) | Integrate native camera + media gallery upload                                   | Phước (Publisher) | 🟡 High     |

---

## Sprint 15 — Testing & Bug Fixes (Weeks 29–30)

### EPIC E42 — Unit & Integration Testing

| Task ID                                                              | Description                                                                          | Assignee          | Priority    |
| -------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ----------------- | ----------- |
| [DA-E42-01](#da-e42-01-write-unit-tests-for-business-service)        | Write unit tests for business-service (AuthService, WorkspaceService, PostService)   | Trung (Leader)    | 🔴 Critical |
| [DA-E42-02](#da-e42-02-write-unit-tests-for-ai-service)              | Write unit tests for ai-service (content generation, RAG pipeline, image generation) | Tuấn (AI)         | 🔴 Critical |
| [DA-E42-03](#da-e42-03-write-integration-tests-for-business-service) | Write integration tests for main API endpoints (business-service)                    | Phước (Publisher) | 🔴 Critical |
| [DA-E42-04](#da-e42-04-performance-test)                             | Performance testing (load test with 200 concurrent users)                            | All (Team)        | 🟡 High     |
| [DA-E42-05](#da-e42-05-e2e-publishing-test)                          | Test publishing flow E2E on sandbox accounts (FB/IG/TikTok/Threads)                  | Phước (Publisher) | 🔴 Critical |

### EPIC E43 — Bug Fixes & Polish

| Task ID                                                               | Description                                                                        | Assignee          | Priority    |
| --------------------------------------------------------------------- | ---------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E43-01](#da-e43-01-sprint-retrospective-and-bug-list-compilation) | Sprint retrospective, compile bug list from testing                                | All (Team)        | 🔴 Critical |
| [DA-E43-02](#da-e43-02-ui-responsive-fixes)                           | UI responsive fixes (test on various screen sizes: 1920px, 1440px, 1280px, mobile) | Lộc (AI Sub-lead) | 🟡 High     |
| [DA-E43-03](#da-e43-03-security-audit)                                | Security audit checklist (check SQL injection, XSS, CSRF, token handling)          | Trung (Leader)    | 🔴 Critical |

---

## Sprint 16 — Deployment, Docs & Final Presentation (Weeks 31–32)

### EPIC E44 — Production Deployment

| Task ID                                                               | Description                                                                    | Assignee       | Priority    |
| --------------------------------------------------------------------- | ------------------------------------------------------------------------------ | -------------- | ----------- |
| [DA-E44-01](#da-e44-01-provision-ec2-and-configure-nginx)             | Set up VPS/EC2 instance, install Docker, configure nginx                       | Trung (Leader) | 🔴 Critical |
| [DA-E44-02](#da-e44-02-deploy-all-services-via-docker-composeprodyml) | Deploy all services via docker-compose.prod.yml, set up SSL with Let's Encrypt | Trung (Leader) | 🔴 Critical |
| [DA-E44-03](#da-e44-03-set-up-uptimerobot-and-diskcpu-alerts)         | Set up monitoring (uptime check, error alerts)                                 | Trung (Leader) | 🟡 High     |
| [DA-E44-04](#da-e44-04-run-production-smoke-test)                     | Smoke test on production environment                                           | All (Team)     | 🔴 Critical |

### EPIC E45 — Final Documentation

| Task ID                                                       | Description                                                        | Assignee       | Priority    |
| ------------------------------------------------------------- | ------------------------------------------------------------------ | -------------- | ----------- |
| [DA-E45-01](#da-e45-01-finalize-swaggeropenapi-documentation) | Finalize Swagger API docs for business-service                     | Trung (Leader) | 🔴 Critical |
| [DA-E45-02](#da-e45-02-write-user-manual)                     | Write User Manual (usage guide for each role)                      | All (Team)     | 🟡 High     |
| [DA-E45-03](#da-e45-03-write-deployment-guide)                | Write Deployment Guide (step-by-step guide to deploy from scratch) | Trung (Leader) | 🔴 Critical |
| [DA-E45-04](#da-e45-04-record-demo-video)                     | Record demo video (5–10 minute showcase of all features)           | All (Team)     | 🔴 Critical |

### EPIC E46 — Final Report & Presentation

| Task ID                                                      | Description                                                                            | Assignee       | Priority    |
| ------------------------------------------------------------ | -------------------------------------------------------------------------------------- | -------------- | ----------- |
| [DA-E46-01](#da-e46-01-write-capstone-report)                | Write Capstone report (following FPT's official template)                              | All (Team)     | 🔴 Critical |
| [DA-E46-02](#da-e46-02-consolidate-and-review-entire-report) | Consolidate and review the entire report before submission                             | Trung (Leader) | 🔴 Critical |
| [DA-E46-03](#da-e46-03-prepare-slide-deck)                   | Prepare slide deck (15–20 slides, including demo screenshots)                          | All (Team)     | 🔴 Critical |
| [DA-E46-04](#da-e46-04-qa-preparation)                       | Q&A preparation (anticipate mentor questions on architecture, AI, and database design) | All (Team)     | 🟡 High     |

---

## EPIC E49 — Public Landing Page 🆕 _(phát sinh ngoài plan gốc)_

> **Note:** Landing page không nằm trong 46 epic gốc của BrandHub. Task gốc là DA-407 (`[DA-E010-07] Create landing page UI`) bị sai prefix và chỉ có 1 task đơn lẻ không phản ánh đúng khối lượng công việc. Epic E49 này được tạo để formalize toàn bộ 11 sections của landing page public thành 9 task. Code đã commit ngày 2026-08-02 (commit `c697568`, gắn nhãn sai `DA-305` — đúng ra phải là DA-E49).

| Task ID                                                        | Description                                                                                            | Assignee       | Priority    |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ | -------------- | ----------- |
| [DA-E49-01](#da-e49-01-build-cinematic-hero-section)           | Build Cinematic Hero section (GSAP scroll animation: 4 platform posts → BrandHub MacBook reveal → CTA) | Trung (Leader) | 🔴 Critical |
| [DA-E49-02](#da-e49-02-build-features-section)                 | Build Features section (6 feature cards with icons, hover effects, scroll animations)                  | Trung (Leader) | 🟡 High     |
| [DA-E49-03](#da-e49-03-build-how-it-works-section)             | Build How It Works section (4-step timeline with alternating layout, scroll slide-in)                  | Trung (Leader) | 🟡 High     |
| [DA-E49-04](#da-e49-04-build-stats-counter--logowall-sections) | Build Stats Counter + LogoWall sections (animated count-up + 12 trusted-by brand logos)                | Trung (Leader) | 🟢 Medium   |
| [DA-E49-05](#da-e49-05-build-templates--testimonials-sections) | Build Templates + Testimonials sections (3 template cards + 3 customer quotes with stars)              | Trung (Leader) | 🟢 Medium   |
| [DA-E49-06](#da-e49-06-build-pricing-section)                  | Build Pricing section (3-tier plans: Starter, Pro, Enterprise with feature checklists)                 | Trung (Leader) | 🟡 High     |
| [DA-E49-07](#da-e49-07-build-faq--cta--footer-sections)        | Build FAQ + CTA + Footer sections (accordion FAQ, conversion CTA banner, 5-column footer)              | Trung (Leader) | 🟡 High     |
| [DA-E49-08](#da-e49-08-set-up-i18n-translation-keys)           | Set up i18n translation keys for all landing page sections (EN + VI)                                   | Trung (Leader) | 🟡 High     |
| [DA-E49-09](#da-e49-09-wire-dashboardpage-with-auth-gating)    | Wire DashboardPage with auth-gating (guest → landing page, authenticated → role-based redirect)        | Trung (Leader) | 🔴 Critical |

**Landing page sections:**

- Cinematic Hero: GSAP ScrollTrigger, pin 3500px, 4 social platform post cards → BrandHub MacBook Air reveal → CTA overlay
- MacBook mockup: aluminum chassis + macOS Sonoma wallpaper + Safari window with 4 interactive dashboard tabs + macOS Dock (12 app icons)
- Social proof: animated stat counters + 12 brand logo names
- Features: 6 cards (Planning, Creation, Publishing, Analytics, Collaboration, Automation)
- How It Works: 4-step alternating timeline (Plan → Create → Schedule → Publish)
- Templates: 3 cards (Social, Blog, Email) with gradient previews
- Testimonials: 3 customer quotes with 5-star ratings
- Pricing: 3-tier (Starter, Pro highlighted, Enterprise) with feature checklists
- FAQ: 5-item accordion, CTA banner, 5-column footer with social SVG icons
- Full i18n: all text via react-i18next, EN+VI translation keys
- Auth-gating: DashboardPage.tsx dual-purpose (guest→landing, authenticated→role redirect)

> 🆕 = epic mới, không có trong plan gốc. Tất cả 9 task đã code xong → status = Done.

---

## SPRINT SUMMARY TABLE

| Sprint    | Weeks | Phase          | Key Deliverables                                                                     |
| --------- | ----- | -------------- | ------------------------------------------------------------------------------------ |
| Sprint 1  | 1–2   | Initiation     | Project registered, team roles confirmed, workspace + repos created                  |
| Sprint 2  | 3–4   | Requirements   | 105 Use Cases documented, architecture diagrams, ADRs, Capstone form                  |
| Sprint 3  | 5–6   | Design         | Database schema (MongoDB + PostgreSQL), API spec, Figma wireframes                   |
| Sprint 4  | 7–8   | Infrastructure | Docker Compose running, CI/CD pipelines active, API Gateway running                  |
| Sprint 5  | 9–10  | Auth & RBAC    | Register/Login/OAuth working, JWT + refresh tokens, RBAC enforced                    |
| Sprint 6  | 11–12 | Core Business  | Workspace CRUD, Client management, Auth/Dashboard/Workspace/Client/Content pages     |
| Sprint 7  | 13–14 | Social OAuth   | All 5 platform OAuth flows working, AES-256 token encryption, token refresh job      |
| Sprint 8  | 15–16 | Publisher      | All 5 platform adapters working, retry logic, DLQ, callback to business              |
| Sprint 9  | 17–18 | AI Wiring      | All AI internal endpoints exposed and callable from business-service                 |
| AI Iter 1 | 5–6   | AI Research    | Model comparison reports (ambassador, video, composition), infrastructure scaffolded |
| AI Iter 2 | 7–8   | AI RAG + LLM   | RAG pipeline working, LLM content generation with anti-hallucination, trends crawler |
| AI Iter 3 | 9–10  | AI Image       | Image generation, InstantID ambassador, image composition pipeline                   |
| AI Iter 4 | 11–12 | AI Video + API | Veo integration, all AI endpoints finalized, integration tests, research reports     |
| Sprint 10 | 19–20 | Content Flow   | Content requests, task assignment, content calendar + scheduling                     |
| Sprint 11 | 21–22 | Publishing     | Approval workflow, full publishing system, error handling                            |
| Sprint 12 | 23–24 | Frontend Core  | Design system, auth pages, dashboard, content management pages                       |
| Sprint 13 | 25–26 | Frontend Full  | Client portal, analytics dashboard, notification center                              |
| Sprint 14 | 27–28 | Mobile         | React Native app: auth, dashboard, calendar, approval, FCM                           |
| Sprint 15 | 29–30 | Testing        | Unit + integration + E2E tests, bug fixes, security audit                            |
| Sprint 16 | 31–32 | Launch         | Production deploy, final docs, capstone report, presentation                         |

---

## WORKLOAD DISTRIBUTION TABLE

> **Cập nhật sau Sprint 4** 🔀 — bảng dưới phản ánh phân bổ **mới** sau khi tái cân bằng. Bảng gốc (trước rebalance) đã lưu trong [Rebalance Log](jira-status-audit-2026-07-11.md#rebalance-log--sau-sprint-4) của `jira-status-audit-2026-07-11.md` để đối chiếu.

| Member | Role                                    | Tasks (mới) | Key Responsibilities                                                                                                                                                          |
| ------ | --------------------------------------- | ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Trung  | Leader / Business Service               | ~64         | Project init, system architecture, API Gateway, Auth, RBAC, Workspace, Client, Subscription (dời S6→S9), Content workflow, Approval, Notification, Deployment, Final report   |
| Phước  | Publisher Engineer / Frontend+Mobile UI | ~52         | Use case docs, social platform API specs, RabbitMQ, permission matrix, publisher-service + 5 platform adapters, **toàn bộ Web Dashboard UI (E34–E39) + Mobile App (E40–E41)** |
| Lộc    | AI Sub-lead                             | ~35         | AI service infra setup, S3 helper, RAG pipeline hỗ trợ, AI endpoint finalize/docs — **không còn task Frontend/Mobile**                                                        |
| Tuấn   | AI Engineer                             | ~31         | Sequence diagrams, DB indexing, ChromaDB design, RAG embedding, InstantID Ambassador (AI-07), **Image Composition Pipeline (AI-08, nhận từ Lộc)**                             |
| Ân     | AI Engineer                             | ~41         | Non-functional AI reqs, Redis key doc, RAG chunking, LLM prompt system, trend crawler, video generation (Veo), **Image Generation Pipeline (AI-06, nhận từ Lộc)**             |

> **Total tasks:** 406 task gốc + 17 task phát sinh 🆕 + 7 task phân tích/thiết kế AI-4.99 🆕 = 430 task (tổng không đổi sau rebalance — chỉ đổi người và vị trí sprint). Xem [Phần 3 — Task phát sinh](#phần-3--tổng-hợp-task-phát-sinh-ngoài-plan-gốc) để biết lý do phát sinh từng task, và [Rebalance Log](jira-status-audit-2026-07-11.md#rebalance-log--sau-sprint-4) trong Jira Audit để biết lý do tái phân bổ.

---

## NOTES

- English is the standard language for all task descriptions, documentation, and project artifacts to ensure consistency across tools such as Linear, GitHub Issues, and Excel.
- "All (Team)" assignee means the task requires participation from all members (e.g., meetings, joint reviews, E2E testing).
- AI Parallel Track epics run concurrently with main sprints; timelines are aligned by sprint week ranges.
- Priority 🔴 Critical tasks must be unblocked first in each sprint before 🟡 High tasks begin.
- Task IDs follow format: DA-{EPIC_ID}-{SEQ} (e.g., DA-E01-01, DA-AI07-03).

---

# PHẦN 1.5 — V2 RE-SCOPE (Epic breakdown, chưa gán người/sprint)

> **Bối cảnh:** Business model đã re-scope sang V2 (Agency → Workspace → Media Package → Media Campaign → Task), xem `docs/ba/`. Audit code thật `brandhub-business-service` (2026-09-15) xác nhận: một số Epic đã khớp V2 dù Jira ghi status khác, một số Epic thiếu hoàn toàn.
>
> **Quy trình dùng phần này:** (1) Đọc Epic + task con dưới đây → (2) Trung/team tự gán người vào từng task, ghi tên vào cột Assignee → (3) Sau khi gán xong, ghép Epic vào sprint (Epic có thể lồng/chạy song song xuyên nhiều sprint, miễn mỗi sprint mỗi người đều có việc) → (4) Trung confirm → (5) mới đẩy lên Jira. **Chưa đẩy Jira ở bước này.**
>
> **Không đụng:** E01–E11 (setup/infra/diagram, đã xong, không liên quan model V1/V2), E12 Authentication (khớp V2), E15 Workspace Management (khớp V2 phần lớn) — 3 nhóm này giữ nguyên như Phần 1.

---

## Epic đã xong thật, KHÔNG cần sửa (bằng chứng code)

| Epic | Bằng chứng | Kết luận |
|---|---|---|
| E12 — Authentication | `AuthController.java`, `AuthServiceImpl.java`, OAuth Google/GitHub/LinkedIn/Microsoft đầy đủ, không phụ thuộc model tổ chức | Giữ nguyên, không có task mới |
| E15 — Workspace Management | `WorkspaceController.java:33-148` CRUD + invite member + audit-log đầy đủ | Giữ nguyên phần lõi; chỉ thêm 1 task nhỏ liên kết `agencyId` (xem EPIC E16 dưới) |

---

## Epic CẦN SỬA (Jira ghi Done/In Review nhưng code chưa đạt V2 đầy đủ)

### EPIC E13 — User & Profile Management (re-scope)

> Jira ghi "Done". Code thật: `User.java:53-54` field `role` là String tự do, không liên kết rõ với `SystemRole`/`MemberRole`; User không có field mặc định trỏ Agency.

| Task ID (tạm) | Description | Complexity | Spec Reference |
|---|---|---|---|
| DA-E13-05 | Refactor `User.role` từ String tự do sang liên kết đúng `SystemRole` enum (ADMIN/USER), tách bạch khỏi `MemberRole` (OWNER/MANAGER/CREATOR/CLIENT theo Workspace) | S | `docs/ba/02-authentication-profile.md`, `docs/ba/10-roles-permissions-matrix.md` |
| DA-E13-06 | Client Profile tách bảng riêng khỏi `users` theo quyết định V2, field `linked_user_id` nullable | M | `docs/feature/profile/3-3-3-view-client-profile/spec.md`, `docs/feature/profile/3-3-4-update-client-profile/spec.md`, `docs/ba/11-data-entities-glossary.md` |

**Ước lượng:** 2 task con, Complexity S+M — không lớn, có thể ghép chung sprint với Epic khác.

### EPIC E14 — Role-Based Access Control (RBAC) (bổ sung)

> Cơ chế `RequireRole`/`MemberRole` đã đúng kiến trúc V2 (role theo từng Workspace), nhưng thiếu quyền cấp Agency.

| Task ID (tạm) | Description | Complexity | Spec Reference |
|---|---|---|---|
| DA-E14-05 | Thêm kiểm soát quyền cấp Agency (chỉ Agency Owner mới xoá Agency, mời Member vào Agency, xem toàn bộ Workspace của Agency) | M | `docs/ba/01-organization-structure.md` mục 4 "Role gán theo Workspace", `docs/ba/10-roles-permissions-matrix.md` |
| DA-E14-06 | Cập nhật Permission Matrix Document theo đúng 2 tầng quyền: Agency-level + Workspace-level | S | `docs/ba/10-roles-permissions-matrix.md` |

**Ước lượng:** 2 task con, Complexity M+S.

### EPIC E16 — Agency & Client Management (viết lại phần Agency, GIỮ NGUYÊN phần Client — đã xong)

> **[RE-AUDIT 2026-09-15, trên `origin/develop` mới nhất sau merge DA-220 + DA-339]** Audit lần đầu (trên branch cũ, thiếu 12 commit) kết luận sai "Client chỉ có model, chưa có API" — **đã lỗi thời, sửa lại ở đây**.
>
> - **Client: ĐÃ XONG THẬT.** `ClientController.java` (`/api/v1/clients`) có đủ `POST` create, `PUT /{id}/assign` assign Manager, `PUT /{id}/service-package`, `GET` list (phân trang/search/filter). `ClientServiceImpl` (202 dòng) implement logic thật, bảo vệ bằng `@PreAuthorize`. **Không cần task sửa Client nữa** — DA-E16-10/11 dưới đây coi như hoàn thành, bỏ khỏi backlog.
> - **Agency: VẪN CHƯA CÓ GÌ**, đúng như audit lần đầu. Commit `fcb1e19 feat(DA-220): implement agency owner crud` **tên gây hiểu lầm** — thực chất commit đó chỉ tạo `ClientController`/`ClientService`, KHÔNG tạo entity Agency nào. Chỉ có role string `AGENCY_OWNER` trong `MemberRole` enum, không có bảng Agency thật.
> - **`Workspace.agency_id` FK: vẫn chưa có** — `Workspace.java` chỉ có `ownerId` (UUID), gap này chưa được vá dù đã qua 2 lần audit.

> **Lưu ý đánh số:** `DA-E16-01..04` đã dùng cho Client (Jira cũ, ĐÃ XONG — xem ghi chú trên). Task Agency mới đánh số tiếp `DA-E16-05` trở đi để không trùng ID.

| Task ID (tạm) | Description | Complexity | Spec Reference |
|---|---|---|---|
| DA-E16-05 | Tạo entity `Agency` (id, name, owner_id 1-1, logo_url, description, status, soft-delete) + repository | M | `docs/ba/01-organization-structure.md` mục 2 "Agency" |
| DA-E16-06 | Implement POST /api/v1/agencies (User tạo Agency mới, tự động là Owner) | S | `docs/feature/agency-workspace/3-4-3-create-agency/spec.md` |
| DA-E16-07 | Implement GET /api/v1/agencies/mine + GET/PUT /api/v1/agencies/{id} (list + view/update Agency Profile) | S | `docs/feature/agency-workspace/3-4-1-list-agency/spec.md`, `3-4-2-view-agency-dashboard`, `3-4-4-view-agency-profile`, `3-4-5-update-agency-profile` |
| DA-E16-08 | Implement DELETE /api/v1/agencies/{id} (soft-delete, khôi phục 30 ngày) | S | `docs/feature/agency-workspace/3-4-6-remove-agency/spec.md` |
| DA-E16-09 | Entity `AgencyMember` + invite Member qua email (hết hạn 3 ngày) + Remove Member (giữ nguyên tài nguyên họ tạo ra) | M | `docs/feature/agency-workspace/3-4-7-invite-agency-member/spec.md`, `3-4-8-view-agency-invitation-status`, `3-4-9-remove-member` |
| DA-E16-10 | Thêm field `agency_id` (FK) vào `Workspace.java`, migration | S | `docs/ba/01-organization-structure.md` mục 1 "Mô hình tổng quan", `docs/database/schema-v2/database-strategy.md` |
| DA-E16-11 | Client Profile tái sử dụng xuyên Agency (liên kết `ClientProfile` từ E13-06) | M | `docs/feature/profile/3-3-3-view-client-profile/spec.md`, `docs/feature/profile/3-3-4-update-client-profile/spec.md` |
| DA-E16-12 | Workspace Template — lưu cấu hình Workspace để tái sử dụng | S | `docs/feature/agency-workspace/3-4-17-save-workspace-template/spec.md` |

**Ước lượng (đã cập nhật sau re-audit):** 8 task con thật sự cần làm (bớt 1 so với 12 ban đầu vì Client đã xong), vẫn là domain **chặn (blocking)** — Agency entity phải xong trước khi RBAC Agency-level (E14) và Media Package/Campaign (E50) có thể triển khai đúng.

### EPIC E17 — Subscription & Billing (xác nhận lại phạm vi gắn Plan)

> Có model (`WorkspaceSubscription`, `SubscriptionPlan`, `Payment`) nhưng gắn cấp Workspace. `docs/ba/08-subscription-billing.md` yêu cầu gắn cấp **User/Owner** (áp dụng toàn Agency), đổi tên PayOS thay vì Stripe.

| Task ID (tạm) | Description | Complexity | Spec Reference |
|---|---|---|---|
| DA-E17-05 | Đổi `WorkspaceSubscription` → `UserSubscription` (gắn User/Owner, áp dụng toàn bộ Agency của họ) | M | `docs/ba/08-subscription-billing.md`, `docs/feature/subscription-billing/3-9-1-upgrade-plan/spec.md`, `docs/feature/subscription-billing/3-9-2-downgrade-plan/spec.md` |
| DA-E17-06 | Đổi `Payment` → `Transaction`, tích hợp PayOS thay vì Stripe/generic gateway | M | `docs/feature/subscription-billing/3-9-3-make-payment-payos/spec.md`, `docs/feature/subscription-billing/3-9-4-view-invoice-history/spec.md` |
| DA-E17-07 | Entity `AiCreditLedger` (sổ credit AI theo tháng, reset hàng tháng, KHÔNG rollover) | M | `docs/feature/subscription-billing/3-9-5-view-ai-credit-tracking/spec.md`, `docs/feature/subscription-billing/3-9-6-buy-credit/spec.md`, `docs/feature/subscription-billing/3-9-7-set-credit/spec.md`, `docs/ba/08-subscription-billing.md` |

**Ước lượng:** 3 task con, Complexity M — phụ thuộc quyết định nghiệp vụ trong `docs/ba/08-subscription-billing.md`.

---

## Epic CHƯA TỒN TẠI — viết mới hoàn toàn (0 dòng code)

### EPIC E50 — Media Package & Campaign (domain mới hoàn toàn, thay thế 1 phần E16 cũ)

| Task ID (tạm) | Description | Complexity | Spec Reference |
|---|---|---|---|
| DA-E50-01 | Entity `MediaPackage` (1 bảng, cột `is_template` phân biệt Template/Custom) | M | `docs/ba/04-media-package-campaign.md`, `docs/feature/media-package-campaign/3-5-1-create-media-package/spec.md` |
| DA-E50-02 | Implement CRUD Media Package (Admin tạo template, Owner/Manager tạo custom) | M | `docs/feature/media-package-campaign/3-5-1-create-media-package/spec.md`, `docs/feature/media-package-campaign/3-5-2-view-the-template-media-package/spec.md` |
| DA-E50-03 | Entity `WorkspaceMediaPackage` (package áp dụng cho Workspace cụ thể) | M | `docs/feature/media-package-campaign/3-5-3-request-media-package/spec.md` |
| DA-E50-04 | Implement đàm phán Package — negotiation loop, ACID 2-bên-approve (`final_terms`, `approved_by_agency_at`, `approved_by_client_at`) | C | `docs/feature/media-package-campaign/3-5-3-request-media-package/spec.md`, `docs/ba/12-state-machines.md` mục 2 "Media Package (đàm phán)" |
| DA-E50-05 | Implement approve reset rule: khi 1 bên sửa `final_terms`, transaction phải reset approve bên kia về NULL cùng transaction | C | `docs/feature/media-package-campaign/3-5-4-approve-media-package/spec.md`, `docs/ba/12-state-machines.md` mục 2 |
| DA-E50-06 | Entity `MediaCampaign` (sinh từ Package đã approve, immutable sau approve) | M | `docs/feature/media-package-campaign/3-5-5-create-media-campaign/spec.md`, `docs/ba/12-state-machines.md` mục 3 "Media Campaign" |
| DA-E50-07 | Implement approve Campaign → auto-generate Task backlog | C | `docs/feature/media-package-campaign/3-5-6-approve-media-campaign/spec.md` |
| DA-E50-08 | Entity `ThirdPartyCollaborator` (danh bạ đối tác báo/banner/TV cấp Agency) | S | `docs/ba/07-publishing-social-collaborator.md`, `docs/ba/12-state-machines.md` mục 6 "Third-party Collaborator" |
| DA-E50-09 | Entity `CampaignCollaborator` (N-N, trạng thái contacted/negotiating/confirmed/live theo từng Campaign) | M | `docs/ba/07-publishing-social-collaborator.md`, `docs/ba/12-state-machines.md` mục 6 |
| DA-E50-10 | Implement Content Request (Client submit yêu cầu nội dung, FSM pending→in_progress→accepted/denied, denied=terminal) | M | `docs/feature/media-package-campaign/3-5-7-create-content-request/spec.md`, `docs/feature/media-package-campaign/3-5-8-track-request-status/spec.md`, `docs/feature/media-package-campaign/3-5-9-update-request/spec.md`, `docs/feature/media-package-campaign/3-5-10-cancel-request/spec.md`, `docs/ba/12-state-machines.md` mục 1 "Content Request" |

**Ước lượng:** 10 task con, có 3 task Complex (negotiation loop 2-bên-approve là phần nghiệp vụ khó nhất toàn dự án) — domain nặng nhất về logic, nhẹ về UI.

### EPIC E51 — Task & Content Workflow (domain mới hoàn toàn — MongoDB, thay thế toàn bộ E28-E31 cũ)

> `content-task-workflow` là domain lớn nhất theo `docs/feature/` (35 FR). E28-E33 cũ trong Phần 1 coi như **archived/thay thế** bởi Epic này — giữ nguyên text cũ để tham khảo lịch sử nhưng không dùng làm nguồn task nữa.

> **Cập nhật 2026-09-15 (theo `docs/Các FR của hệ thống - Feature_Function Requirement.csv`, cột "Code"):** Tách task theo từng FR con (thay vì gộp nhiều FR/task) để tránh mơ hồ khi giao việc, và gán Assignee. 14 task gốc → 22 task. Xem chi tiết Goal/AC đầy đủ ở Phần 2 (mục "PHASE V2 — Media Package/Campaign & Task Workflow").

| Task ID (tạm) | Description | Assignee | Complexity | Spec Reference |
|---|---|---|---|---|
| DA-E51-01 | Collection `tasks` (generic 3 loại: post/livestream/survey, discriminator `type`) | Lộc | C | `docs/ba/05-content-task-workflow.md`, `docs/feature/content-task-workflow/3-6-1-identify-task-detail/spec.md`, `docs/ba/11-data-entities-glossary.md` |
| DA-E51-02 | Collection `task_approvals` (tách riêng khỏi tasks, giữ approval cũ khi step sau reject) | Lộc | C | `docs/ba/12-state-machines.md` mục 4 "Task — Approval Sequence", `docs/ba/11-data-entities-glossary.md` |
| DA-E51-03 | Implement Approval Sequence 4-bước (Creator→Manager→Client) | Phước | C | `docs/feature/content-task-workflow/3-6-9-approval-sequence-creator-manager-client/spec.md`, `docs/ba/12-state-machines.md` mục 4 |
| DA-E51-04 | Implement Task backlog + assign (Manager assign cho Creator) | Lộc | M | `docs/feature/content-task-workflow/3-6-2-assign-task-to-creator/spec.md` |
| DA-E51-05 | Implement Task views: List, Calendar, Gantt/Timeline, Kanban board, Filter | Phước | M | `docs/feature/content-task-workflow/3-6-4-list-task-view/spec.md`, `3-6-5-calendar-task-view`, `3-6-6-grantt-timeline-task-view`, `3-6-7-kanban-board-task-view`, `3-6-8-view-task-filter` (cùng thư mục `docs/feature/content-task-workflow/`) |
| DA-E51-06 | Collection `material_repository` + View Material (FR 3.6.11) | Tuấn | M | `docs/feature/content-task-workflow/3-6-11-view-material-repository/spec.md` |
| DA-E51-06b | Add Material to Repository (FR 3.6.12) | Tuấn | S | `docs/feature/content-task-workflow/3-6-12-add-material-repository/spec.md` |
| DA-E51-06c | Update Material in Repository (FR 3.6.13) | Tuấn | S | `docs/feature/content-task-workflow/3-6-13-update-material-repository/spec.md` |
| DA-E51-06d | Remove Material from Repository (FR 3.6.14) | Tuấn | S | `docs/feature/content-task-workflow/3-6-14-remove-material-repository/spec.md` |
| DA-E51-06e | Apply Watermark to Material (FR 3.6.15) | Trung | M | `docs/feature/content-task-workflow/3-6-15-apply-watermark/spec.md` |
| DA-E51-06f | Download Material (FR 3.6.16) | Tuấn | S | `docs/feature/content-task-workflow/3-6-16-download-material/spec.md` |
| DA-E51-06g | Entity/Endpoint `brand_collections` (Client-supplied reference assets) | Tuấn | M | `docs/ba/05-content-task-workflow.md` |
| DA-E51-07 | Apply Hashtag to Task (FR 3.6.17) | Tuấn | S | `docs/feature/content-task-workflow/3-6-17-apply-hastag/spec.md` |
| DA-E51-07b | Collection `hashtag_collections` + View Collection (FR 3.6.18) | Tuấn | S | `docs/feature/content-task-workflow/3-6-18-view-hastag-collection/spec.md` |
| DA-E51-07c | Add Hashtag to Collection (FR 3.6.19) | Tuấn | S | `docs/feature/content-task-workflow/3-6-19-add-hastag-collection/spec.md` |
| DA-E51-07d | Update Hashtag in Collection (FR 3.6.20) | Tuấn | S | `docs/feature/content-task-workflow/3-6-20-update-hastag-collection/spec.md` |
| DA-E51-07e | Remove Hashtag from Collection (FR 3.6.21) | Tuấn | S | `docs/feature/content-task-workflow/3-6-21-remove-hastag-collection/spec.md` |
| DA-E51-08 | Write Livestream Idea (FR 3.6.22) | Phước | S | `docs/feature/content-task-workflow/3-6-22-write-livestream-idea/spec.md` |
| DA-E51-08b | Write Livestream Script (FR 3.6.23) | Phước | S | `docs/feature/content-task-workflow/3-6-23-write-livestream-script/spec.md` |
| DA-E51-08c | Track Livestream Status (FR 3.6.24) | Phước | M | `docs/feature/content-task-workflow/3-6-24-track-livestream-status/spec.md`, `docs/ba/12-state-machines.md` mục 5 |
| DA-E51-08d | Generate Meeting Link (FR 3.6.27) | Phước | S | `docs/feature/content-task-workflow/3-6-27-generate-meeting-link/spec.md` |
| DA-E51-09 | Create Survey (FR 3.6.25) | Phước | M | `docs/feature/content-task-workflow/3-6-25-create-survey/spec.md` |
| DA-E51-09b | View Survey Analysis (FR 3.6.26) | Phước | S | `docs/feature/content-task-workflow/3-6-26-view-survey-analysis/spec.md` |
| DA-E51-10 | View Mail Template (FR 3.6.28, role TBD — [OPEN QUESTION]) | Trung | S | `docs/feature/content-task-workflow/3-6-28-view-mail-template/spec.md` |
| DA-E51-10b | Create Mail Template (FR 3.6.29) | Trung | S | `docs/feature/content-task-workflow/3-6-29-create-mail-template/spec.md` |
| DA-E51-10c | Update Mail Template (FR 3.6.30) | Trung | S | `docs/feature/content-task-workflow/3-6-30-update-mail-template/spec.md` |
| DA-E51-10d | Delete Mail Template (FR 3.6.31) | Trung | S | `docs/feature/content-task-workflow/3-6-31-delete-mail-template/spec.md` |
| DA-E51-10e | Send Email via Template (FR 3.6.32) | Trung | M | `docs/feature/content-task-workflow/3-6-32-send-email-via-template/spec.md` |
| DA-E51-11 | Implement compliance check (content moderation) | Tuấn | M | `docs/feature/content-task-workflow/3-6-33-check-compliance-content/spec.md` |
| DA-E51-12 | Implement copyright infringement check — dùng API bên thứ 3, trả JSON mức độ (bạo lực/copyright...), hiển thị chung 1 panel cảnh báo với compliance check (DA-E51-11) [CONFIRMED 2026-09-15] | Tuấn | M | `docs/feature/content-task-workflow/3-6-34-check-copyright-infringement/spec.md` |
| DA-E51-13 | Collection `content_versions` (Content History) | Tuấn | S | `docs/feature/content-task-workflow/3-6-35-view-content-history/spec.md` |
| DA-E51-14 | Collection `posts` (đổi nghĩa V2: chỉ bài ĐÃ PUBLISH thành công) | Phước | S | `docs/ba/12-state-machines.md` mục 7 "Post — trạng thái Publish" |
| DA-E51-15 🆕 | Implement Realtime Chat (FR 3.6.36 — task mới, chưa từng có trong plan) | Lộc | M | FR 3.6.36 (chưa có spec riêng) |

**Ước lượng:** 22 task con (tăng từ 14 sau khi tách theo FR), 3 task Complex (Approval Sequence + reject-giữ-approval-cũ là rủi ro kỹ thuật cao nhất dự án — xem `docs/ba/12-state-machines.md` mục 4). Đây là domain lớn nhất, nên tách làm ít nhất 2 đợt (core Task+Approval trước, Material/Livestream/Survey/Mail sau).

### EPIC E52 — Publishing & Social (đã audit `brandhub-publisher-service` trên `origin/develop`, 2026-09-15)

> **Tốt hơn dự kiến ban đầu.** Adapter publish (Facebook/Instagram/Threads/TikTok) đã **implement thật**, không chỉ interface — `SocialPublishAdapter` + 4 class impl riêng platform, TikTok phân biệt Direct Post (≤60s) vs Creator Upload (>60s) đúng theo spec. RabbitMQ consumer (`PublishJobConsumer`) đã có, dùng Redis SETNX chống trùng job, nack→DLQ cơ bản đã hoạt động (merge qua PR #5 DA-227). Còn thiếu: **toàn bộ OAuth flow** (0 controller/service authorize/callback — hiện chỉ demo bằng access token nhập tay qua `TestController`), token refresh job (không có `@Scheduled` nào), publish callback webhook nhận kết quả thật từ platform, retry có backoff.

> **Cập nhật 2026-09-15 (CSV Code):** Toàn bộ 3.8.x gán cho Phước theo CSV. Task ID thật trong Phần 2 là DA-E52-01..08 (8 task, không phải dải số cũ 01..17 ở đây — bảng dưới giữ nguyên số cũ để tham khảo mô tả, số thật xem Phần 2).

| Task ID (tạm) | Description | Assignee | Complexity | Trạng thái | Spec Reference |
|---|---|---|---|---|---|
| DA-E52-01..04 | Meta OAuth (Facebook + Instagram) — authorize redirect → callback → token exchange | Phước | M | **Chưa có, cần viết mới** | `docs/feature/publishing-social/3-8-1-connect-social-account/spec.md`, `docs/ba/07-publishing-social-collaborator.md` |
| DA-E52-05..07 | TikTok & Threads OAuth + Token status dashboard API | Phước | M | **Chưa có, cần viết mới** | `docs/feature/publishing-social/3-8-1-connect-social-account/spec.md`, `docs/feature/publishing-social/3-8-2-disconnect-account/spec.md` |
| DA-E52-08 | Implement AES-256 encryption lưu token — hạ tầng `CryptoUtils` đã có sẵn, chỉ cần nối vào flow OAuth thật | Phước | S | CryptoUtils đã có, chưa có gì gọi nó trong OAuth vì OAuth chưa tồn tại | `docs/ba/07-publishing-social-collaborator.md` |
| DA-E52-09..10 | Scheduled token refresh job (chạy định kỳ, cảnh báo khi refresh fail) | Phước | M | **Chưa có, cần viết mới** | `docs/ba/07-publishing-social-collaborator.md` |
| DA-E52-11..14 | Publisher Service Core: adapters FB/IG/TikTok/Threads | — | — | **ĐÃ XONG**, bỏ khỏi backlog | `docs/feature/publishing-social/3-8-9-publish-facebook-post/spec.md` … `3-8-16-publish-threads-post` (8 spec, cùng thư mục) |
| DA-E52-15 | RabbitMQ consumer + Redis dedup lock | — | — | **ĐÃ XONG**, bỏ khỏi backlog | `docs/architecture/rabbitmq-publisher-contract.html` |
| DA-E52-16 | Publish callback webhook (nhận kết quả publish thật từ platform → cập nhật status) | Phước | M | **Chưa có, cần viết mới** — hiện chỉ có nack/DLQ nội bộ, không có webhook nhận response async từ social platform | `docs/feature/publishing-social/3-8-4-view-post-track-detail/spec.md`, `docs/feature/publishing-social/3-8-8-view-status-tracking/spec.md` |
| DA-E52-17 | Retry logic có exponential backoff (hiện chỉ nack 1 lần → DLQ, chưa retry nhiều lần với backoff) | Phước | M | **Cần bổ sung** | `docs/architecture/rabbitmq-publisher-contract.html` |

**Ước lượng (sau audit thật):** ~11 task con cần làm thật (giảm gần nửa so với ước lượng ban đầu 20, vì phần adapter core + RabbitMQ đã xong) — trọng tâm còn lại là **OAuth** (toàn bộ 3 platform) và **callback/retry hoàn chỉnh**, không phải viết lại adapter.

### EPIC E53 — Analytics, Notification & Admin (đã audit backend `business-service` + frontend `web-dashboard`, 2026-09-15)

> **Phát hiện quan trọng — mismatch Backend/Frontend:** `brandhub-web-dashboard` (`origin/develop`) đã dựng **UI đầy đủ** cho 21 domain page, bao gồm `admin`, `analytics`, `notification-settings`, `calendar`, `requests`, `portal`, `library`, `hashtag-groups`, `templates`... nhưng **18/22 service layer vẫn là mock** (`src/services/mock/mock*.ts` — mockAdminService, mockAnalyticsService, mockNotificationService, mockCalendarService, mockContentRequestService, mockPortalService...). Chỉ 4 service dùng API thật: `authService`, `userService`, `workspaceService` (+ client giờ có thể tính thêm, cần xác nhận riêng). Backend thật: `AdminController` chỉ 2 endpoint (`GET /users`, `PUT /users/{id}/ban`) — không có content moderation, system health. Notification/Analytics/Report: **0 code backend**, chỉ 1 enum rỗng `ReportFrequency`.
>
> **Ý nghĩa cho kế hoạch:** đây là domain có rủi ro "tưởng đã xong" cao nhất — nhìn UI chạy được (vì mock) dễ đánh giá nhầm là đã hoàn thành. Việc thật cần làm là viết Backend API rồi thay `mock*Service.ts` bằng service gọi API thật, KHÔNG cần viết lại UI.

> **Cập nhật 2026-09-15 (CSV Code):** Tách DA-E53-06 cũ (gộp System Health + Content Moderation + User Management — 3 người khác nhau theo CSV) thành các task riêng theo assignee thật. 8 task gốc → 10 task. Xem chi tiết Goal/AC đầy đủ ở Phần 2 (mục "PHASE V2 — Analytics, Notification & Admin").

| Task ID (tạm) | Description | Assignee | Complexity | Trạng thái | Spec Reference |
|---|---|---|---|---|---|
| DA-E53-01 | Backend: implement analytics aggregation API (FR 3.10.2, 3.10.11) | Ân | C | Backend 0%, frontend UI có sẵn (`pages/analytics/`) chỉ cần đổi service layer | `docs/feature/admin-management/3-10-2-platform-statistics-overview/spec.md`, `docs/feature/admin-management/3-10-11-view-revenue-dasboard/spec.md` |
| DA-E53-02 | Backend: report generation PDF (FR 3.10.12) | Ân | M | Backend 0% | `docs/feature/admin-management/3-10-12-export-report-file-pdf/spec.md` |
| DA-E53-03 | Frontend: thay `mockAnalyticsService.ts` → gọi API thật | Ân | S | Chỉ cần khi DA-E53-01/02 xong | (theo cùng spec DA-E53-01/02) |
| DA-E53-04 | Backend: Notification CRUD API + trigger tạo notification khi event xảy ra (FR 3.10.1) | Ân | M | Backend 0%, `notificationStore.ts` + UI đã có sẵn | `docs/feature/admin-management/3-10-1-push-notification/spec.md` |
| DA-E53-05 | Frontend: thay `mockNotificationService.ts` → API thật | Ân | S | | `docs/feature/admin-management/3-10-1-push-notification/spec.md` |
| DA-E53-06 | Backend: System Health Monitoring endpoint (FR 3.10.3) | Tuấn | M | Frontend `SystemHealthPanel.tsx` chờ sẵn | `docs/feature/admin-management/3-10-3-system-health-monitoring/spec.md` |
| DA-E53-07 | Backend: Content Moderation Queue (FR 3.10.4) | Ân | M | Frontend `ModerationQueueList.tsx` chờ sẵn | `docs/feature/admin-management/3-10-4-content-moderation-queue/spec.md` |
| DA-E53-08 | Backend: User Management view/create/update (FR 3.10.6/7/8) | Ân | M | `AdminController` chỉ có 2 endpoint hiện tại | `docs/feature/admin-management/3-10-6-view-user/spec.md`, `3-10-7-create-user`, `3-10-8-update-user` |
| DA-E53-09 | Backend: User verify/disable/deactivate (FR 3.10.5, 3.10.9) — [OPEN QUESTION] "Admin xoá Admin" chưa chốt | Ân | M | Chặn bởi DA-E53-08 | `docs/feature/admin-management/3-10-5-user-management-verifydisabledelete/spec.md`, `3-10-9-deactive-user`, `docs/ba/09-admin-management.md` |
| DA-E53-10 | Frontend: thay `mockAdminService.ts` → API thật | Ân | S | | (theo cùng spec DA-E53-06/07/08/09) |

**Ước lượng:** 10 task con (tăng từ 8 sau khi tách System Health cho Tuấn riêng khỏi phần Ân) — nhẹ hơn dự kiến ở phần frontend (UI có sẵn, chỉ đổi service layer ~1 buổi/domain), nặng ở phần backend analytics aggregation (nhiều nguồn dữ liệu Task/Post/Publish log, các domain này bản thân cũng đang viết mới ở E50/E51 — nên **E53 phải làm SAU khi E50/E51 có data thật để aggregate**, không làm song song từ đầu.

---

## Tổng hợp quy mô (đã cập nhật 2026-09-15 — Assignee gán theo `docs/Các FR của hệ thống - Feature_Function Requirement.csv` cột "Code", KHÔNG dùng cột "Người làm tài liệu"; loại trừ toàn bộ FR 3.7 AI Features)

| Epic | Task con | Assignee (chính) | Complexity nổi bật | Trạng thái |
|---|---|---|---|---|
| E13 (sửa) | 2 | **Trung** (khớp 3.2/3.3.x) | S, M | Cần sửa |
| E14 (bổ sung) | 2 | **Trung** (khớp 3.2/3.3.x) | M, S | Cần sửa |
| E16 (viết Agency, Client ĐÃ XONG) | **8** ~~12~~ | **Trung** (khớp 3.4.x) | Toàn S/M, là domain **blocking** | Agency cần viết mới; Client bỏ khỏi backlog (đã xong) |
| E17 (xác nhận lại) | 3 | **Tuấn** (khớp 3.9.x) | M | Cần sửa |
| E50 Media Package/Campaign | 10 | **Lộc** (khớp 3.5.x) | 3× Complex (negotiation loop) | Viết mới, 0% code |
| E51 Task & Content Workflow | **22** ~~14~~ | **Lộc/Phước/Tuấn/Trung** (mix theo từng FR con — xem bảng Epic E51) | 3× Complex (Approval Sequence) | Viết mới, 0% code — domain lớn nhất |
| E52 Publishing & Social | **11** ~~20~~ | **Phước** (khớp 3.8.x) | OAuth 3 platform + callback/retry | Adapter+RabbitMQ **đã xong**; OAuth+refresh job+callback thật **chưa có** |
| E53 Analytics/Notification/Admin | **10** ~~8~~ ~~13~~ | **Ân** (đa số 3.10.x) + **Tuấn** (riêng 3.10.3 System Health) | Backend aggregation (C) | Backend gần 0%; **frontend UI đã dựng sẵn cho tất cả (mock service)** — chỉ cần nối API thật |
| **Tổng** | **~60 task con** ~~58~~ ~~76~~ | | | Tăng 2 so với lần trước sau khi tách theo FR (E51/E53), giảm 16 so với ước lượng ban đầu |

> **Phát hiện xuyên suốt quan trọng nhất:** `brandhub-web-dashboard` đã dựng UI cho toàn bộ 21 domain (`admin, analytics, calendar, requests, portal, library, hashtag-groups, templates, notification-settings, social-accounts, security, publish, editor...`) nhưng đa số dùng `src/services/mock/mock*.ts`. Nghĩa là **frontend không phải điểm nghẽn** cho hầu hết domain — điểm nghẽn thật là **Backend API** cho Agency, Media Package/Campaign, Task/Content Workflow, Analytics, Notification, Admin mở rộng, và OAuth publisher. Khi ước lượng workload/người, ưu tiên phân người có kinh nghiệm backend vào các domain 0%, và tận dụng người khác để "nối API thật thay mock" (việc nhỏ, nhanh) sau khi backend endpoint sẵn sàng — đây chính là cách "đảm bảo không ai rảnh tay" mà không cần chờ 1 domain xong 100% mới bắt đầu domain sau.
>
> **Cập nhật assignee 2026-09-15:** E17/E50/E51/E52/E53 đã gán Assignee đầy đủ theo CSV (xem chi tiết từng task ở Phần 2). E13/E14/E16 chưa nằm trong phạm vi CSV lần này (không phải FR do CSV người-làm-code ghi, và 1 phần đã audit code xong) — vẫn để trống, chờ Trung xác nhận riêng nếu cần.
>
> **Việc tiếp theo (theo đúng quy trình đã thống nhất):** Trung review lại Assignee đã gán, xác nhận đúng ý hay cần đổi. Sau khi confirm, quay lại để ghép Epic vào 4 sprint tới — ưu tiên: E16 (Agency) phải làm sớm nhất vì **chặn** E14-Agency-level, E50, và một phần E51 (Task cần Campaign tồn tại trước). Chưa đẩy bất kỳ task nào ở trên lên Jira cho tới khi Trung confirm.

---

# PHẦN 1.6 — SPRINT PLAN V2 (Sprint 8–12, 2026-09-15)

> **Chưa đẩy Jira.** Đây là bản kế hoạch trên tài liệu để Trung duyệt trước. Sprint 8–12 = 5 sprint (theo lịch Jira thật: Sprint 8 08/09–22/09, Sprint 9 14/09–28/09, các sprint sau nối tiếp 2 tuần/sprint — ngày chính xác Trung tự chỉnh trên Jira khi đẩy). Sprint 13–14 Trung tự làm sau (chuẩn bị bảo vệ) — không nằm trong phạm vi bảng dưới.
>
> **Quy tắc chia:** Effort quy đổi ước lượng ~ngày làm/task: 🟢S ≈ 0.5 ngày, 🟡M ≈ 1.5 ngày, 🔴C ≈ 3 ngày (code+test). Mỗi sprint 2 tuần ≈ 8-9 ngày làm việc thật/người. Một Epic có thể kéo qua nhiều sprint — bình thường, không dồn ép cho xong trong 1 sprint. Thứ tự trong mỗi ô tuân theo cột "Dependencies" đã ghi ở Phần 1.5/Phần 2 — không đảo thứ tự khi thực hiện.
>
> **Chuỗi phụ thuộc chính (lý do thứ tự dưới đây):** E13→E14→E16 (Trung, tuyến tính, phải xong trước để mở khoá E50/E17) → E50 (Lộc, cần `agencyId` từ E16) → E51-04 (cần E50-07 deploy Campaign→Task) → E51-03 Approval Sequence (cần E51-01/02/04) → E53 (Ân/Tuấn, cần E50/E51 có data thật để aggregate, làm sau cùng). Các nhánh KHÔNG phụ thuộc gì kể trên (E52 toàn bộ, E51 Material/Hashtag, E53 Notification/User-mgmt) được xếp sớm nhất có thể để không ai rảnh tay chờ E16.

## Sprint 8 (08/09–22/09) — Nền tảng chặn (Agency/RBAC) + các nhánh độc lập

| Người | Task (theo thứ tự làm) | Epic | Ghi chú |
|---|---|---|---|
| **Trung** | DA-E13-05 → DA-E13-06 → DA-E14-05 → DA-E14-06 → DA-E16-05 → DA-E16-06 | E13, E14, E16 | Chuỗi tuyến tính bắt buộc, không đảo được. DA-E16-05 (Agency Entity) là task **chặn toàn bộ dự án** — ưu tiên cao nhất, cần xong sớm trong sprint để Lộc/Tuấn có Agency thật dùng ở Sprint 9 |
| **Lộc** | DA-E51-01 → DA-E51-02 → DA-E50-01 (nếu Trung xong E16-05 kịp giữa sprint) | E51, E50 | E51-01/02 (Task/Approval collection) hoàn toàn độc lập — làm trước để không chờ Trung. E50-01 chỉ bắt đầu được sau khi DA-E16-05 xong |
| **Phước** | DA-E52-01 → DA-E52-02 → DA-E52-03 → DA-E52-04 | E52 | Toàn bộ Meta+TikTok+Threads OAuth — không phụ thuộc ai, chạy full tốc độ từ đầu |
| **Tuấn** | DA-E51-06 → DA-E51-06b → DA-E51-06c → DA-E51-06d → DA-E51-06f → DA-E51-06g → DA-E53-06 | E51, E53 | Material Repository + System Health — không phụ thuộc E16, làm hết trong sprint này |
| **Ân** | DA-E53-04 → DA-E53-05 → DA-E53-08 → DA-E53-09 | E53 | Notification CRUD + User Management — không phụ thuộc E50/E51, tận dụng làm sớm |

## Sprint 9 (14/09–28/09) — Agency hoàn tất, Media Package bắt đầu thật

| Người | Task (theo thứ tự làm) | Epic | Ghi chú |
|---|---|---|---|
| **Trung** | DA-E16-07 → DA-E16-08 → DA-E16-09 → DA-E16-10 → DA-E16-12 → DA-E16-11 (cần DA-E13-06 xong từ Sprint 8) | E16 | Hoàn tất toàn bộ Agency — mở khoá E50/E17 đầy đủ cho Lộc/Tuấn |
| **Lộc** | DA-E50-01 (nếu chưa xong) → DA-E50-02 → DA-E50-03 → DA-E50-08 | E50 | Từ đây Agency đã có, làm full tốc độ Media Package |
| **Phước** | DA-E52-05 → DA-E52-06 → DA-E52-07 → DA-E52-08 | E52 | Token refresh job + callback + retry — hoàn tất toàn bộ E52 trong sprint này |
| **Tuấn** | DA-E17-05 → DA-E17-06 → DA-E51-07 → DA-E51-07b → DA-E51-07c → DA-E51-07d → DA-E51-07e | E17, E51 | E17 mở khoá được vì E16-05 đã xong từ Sprint 8; Hashtag Collection không phụ thuộc gì thêm |
| **Ân** | DA-E53-04/05 dở từ Sprint 8 nếu chưa xong → hỗ trợ review/test Notification, chuẩn bị nghiên cứu aggregation cho E53-01 (chưa code được, chờ data Sprint 10-11) | E53 | Nhẹ hơn các sprint khác vì E53-01/02/03/07 (phần nặng) đều bị chặn — dùng thời gian dư để research/viết doc chuẩn bị |

## Sprint 10 (đầu tháng 10) — Media Package hoàn tất, Task/Content Workflow bắt đầu

| Người | Task (theo thứ tự làm) | Epic | Ghi chú |
|---|---|---|---|
| **Trung** | DA-E51-06e → DA-E51-10 → DA-E51-10b → DA-E51-10c → DA-E51-10d → DA-E51-10e | E51 | E13/E14/E16 đã xong hết ở Sprint 9 — Trung chuyển sang phần Mail Template + Watermark còn lại trong E51 |
| **Lộc** | DA-E50-04 → DA-E50-05 → DA-E50-06 → DA-E50-09 | E50 | Negotiation loop 2-bên-approve (Complex nhất của E50) — cần tập trung, không chia việc khác chung sprint |
| **Phước** | DA-E51-05 (List/Calendar/Gantt/Kanban views — cần DA-E51-01 Lộc đã xong từ Sprint 8) | E51 | Bắt đầu tham gia E51 phần view, độc lập với Approval Sequence |
| **Tuấn** | DA-E17-07 → DA-E51-13 (cần E17-07 xong) | E17, E51 | AI Credit Ledger + Content History no-double-charge — chuỗi phụ thuộc trong chính Tuấn |
| **Ân** | DA-E53-08/09 dở (nếu Sprint 9 chưa xong) → bắt đầu research/viết khung DA-E53-01 (analytics aggregation) — code thật chờ Sprint 11 khi có data | E53 | Vẫn nhẹ — đây là sprint cuối trước khi E53 có việc thật để aggregate |

## Sprint 11 (giữa/cuối tháng 10) — Approval Sequence (rủi ro cao nhất), Analytics bắt đầu code thật

| Người | Task (theo thứ tự làm) | Epic | Ghi chú |
|---|---|---|---|
| **Trung** | QA-E13 → QA-E14 → QA-E16 (viết integration test + verify từng Acceptance Criteria cho E13/E14/E16 đã code Sprint 8-9) | E13, E14, E16 (QA) | Task thật có checklist cụ thể — không đổi assignee CSV (E51 Livestream/Survey vẫn của Phước). Đây là domain **blocking** nhất dự án, QA kỹ trước khi các domain khác build tiếp trên nó là bắt buộc, không phải việc "cho có" |
| **Lộc** | DA-E50-07 → DA-E50-10 → DA-E51-04 | E50, E51 | E50-07 (approve Campaign→auto-generate Task backlog) là điểm nối E50→E51 — xong task này mới mở khoá E51-04 cho chính Lộc và Phước |
| **Phước** | DA-E51-08 → DA-E51-08b → DA-E51-08c → DA-E51-08d → DA-E51-09 → DA-E51-09b (Livestream/Survey — cần DA-E51-04 Lộc xong giữa sprint) | E51 | Nếu DA-E51-04 chưa xong đầu sprint, Phước làm trước phần không phụ thuộc (không có — toàn bộ nhánh Livestream/Survey đều chờ E51-04; nếu trễ, Phước hỗ trợ QA E52 đã xong) |
| **Tuấn** | DA-E51-11 → DA-E51-12 (Compliance + Copyright check — cần DA-E51-04 xong) | E51 | Cùng điểm chờ E51-04 như Phước — nếu Lộc xong sớm trong sprint, Tuấn bắt đầu ngay |
| **Ân** | DA-E53-01 → DA-E53-02 → DA-E53-03 (Analytics aggregation — bắt đầu có data thật từ E50/E51 để aggregate) | E53 | Sprint đầu tiên Ân có việc nặng — Complexity C, cần trọn sprint |

## Sprint 12 (đầu/giữa tháng 11) — Approval Sequence hoàn tất, E53 hoàn thiện

| Người | Task (theo thứ tự làm) | Epic | Ghi chú |
|---|---|---|---|
| **Trung** | QA-E50 → QA-E17 (viết integration test + verify Acceptance Criteria cho toàn bộ E50 Lộc và E17 Tuấn đã code Sprint 9-11) | E50, E17 (QA) | Tiếp nối QA Sprint 11 (E13/E14/E16) sang 2 domain lớn tiếp theo — cần xong trước khi demo/bảo vệ Sprint 13-14 |
| **Lộc** | DA-E51-02/03 phối hợp với Phước để chốt Approval Sequence (đã làm nền E51-01/02, hỗ trợ kỹ thuật trực tiếp cho phần khó nhất) | E51 | Hỗ trợ CÓ mục tiêu cụ thể: cùng Phước debug state machine Approval Sequence, không phải ngồi chờ |
| **Phước** | DA-E51-03 (Approval Sequence state machine — Complex nhất của E51, cần trọn thời gian) → DA-E51-14 (posts collection, cần DA-E52-05 Phước tự làm đã xong Sprint 9) | E51 | Việc rủi ro kỹ thuật cao nhất toàn dự án — không xếp thêm task khác cùng sprint cho Phước |
| **Tuấn** | QA-E51-Tuấn (viết integration test cho DA-E51-06/06b-g, 07/07b-e, 11, 12, 13 — toàn bộ phần E51 do Tuấn code từ Sprint 8-10) | E51 (QA) | Việc code chính của Tuấn đã xong hết Sprint 10 — sprint này QA lại đúng domain mình vừa làm, có checklist cụ thể theo AC đã viết ở Phần 2, không phải "hỗ trợ" chung |
| **Ân** | DA-E53-07 (Content Moderation Queue — cần DA-E51-11/12 Tuấn xong Sprint 11) → DA-E53-10 (thay toàn bộ mock service Admin/Analytics/Notification bằng API thật — task tổng kết E53) | E53 | DA-E53-10 chỉ làm được sau khi DA-E53-06 (Tuấn), 07/08/09 (Ân) đều xong — task cuối cùng đóng epic E53 |

## Việc còn lại sau Sprint 12 (chưa xếp, chờ Trung tự làm ở Sprint 13-14)

- `DA-E51-03` Approval Sequence + `DA-E51-15` Chat nếu tràn từ Sprint 12
- Buffer test/QA toàn bộ E50/E51/E52/E53 trước demo/bảo vệ
- E13/E14/E16 KHÔNG có phần dư — Trung xong hết ở Sprint 9

---

# PHẦN 3 — TỔNG HỢP TASK PHÁT SINH NGOÀI PLAN GỐC

> Nguồn: đối soát toàn bộ Jira project `DA` (406 task) với plan gốc 406 task ID. 17 task dưới đây xuất hiện trên Jira / trong Task Details nhưng không nằm trong `BrandHub_Project_Plan.md` phiên bản gốc — đã bổ sung vào Phần 1 (đánh dấu 🆕) và Phần 2.

| Task ID      | Epic gắn vào                                                       | Assignee | Vì sao phát sinh                                                                                                               | Chi tiết                                                                                                                                        |
| ------------ | ------------------------------------------------------------------ | -------- | ------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| DA-E08-05    | E08 (UI/UX Wireframe)                                              | Lộc      | Tooling phụ — tự động hoá trang xem tài liệu local                                                                             | [Xem](#da-e08-05-create-a-view-local-document-website-automation-phát-sinh-ngoài-plan-gốc)                                                      |
| DA-E08-08    | E08                                                                | Trung    | Tích hợp file HTML (diagram) vào doc site — đi cùng DA-E08-05                                                                  | [Xem](#da-e08-08-integrated-html-for-view-document-phát-sinh-ngoài-plan-gốc)                                                                    |
| DA-E08-07    | E08 (gán tạm — Jira ghi nhầm `E010`)                               | Lộc      | Landing page public — không có trong 46 epic gốc; prefix Jira lỗi (`E010` thay vì epic UI thật)                                | [Xem](#da-e08-07-create-landing-page-ui-phát-sinh-ngoài-plan-gốc-prefix-jira-lỗi)                                                               |
| DA-E09-06    | E09 (Dev Environment)                                              | Trung    | Sub-task thu thập key hạ tầng — tách từ DA-E09-03 để giao việc rõ theo người                                                   | [Xem](#da-e09-06-infrastructure-business-service-keys)                                                                                          |
| DA-E09-07    | E09                                                                | Tuấn     | Sub-task thu thập key LLM + payment gateway                                                                                    | [Xem](#da-e09-07-ai-service-llm-keys-payment-gateway)                                                                                           |
| DA-E09-08    | E09                                                                | Ân       | Sub-task thu thập key Image/Video Gen                                                                                          | [Xem](#da-e09-08-ai-service-imagevideo-gen-keys)                                                                                                |
| DA-E09-09    | E09                                                                | Phước    | Sub-task thu thập OAuth credentials 5 platform                                                                                 | [Xem](#da-e09-09-publisher-service-social-platform-oauth)                                                                                       |
| DA-E09-10    | E09                                                                | Lộc      | Sub-task tạo Google OAuth App                                                                                                  | [Xem](#da-e09-10-frontend-google-oauth-app)                                                                                                     |
| DA-E09-11    | E09                                                                | Trung    | Cost sheet — không có trong plan gốc, cần cho báo cáo capstone/mentor                                                          | [Xem](#da-e09-11-create-project-cost-sheet)                                                                                                     |
| DA-E09-12    | E09                                                                | Lộc      | Đăng ký domain thật — cần cho OAuth redirect URI (không dùng được localhost với 1 số platform)                                 | [Xem](#da-e09-12-register-brandhub-domain-phát-sinh-ngoài-plan-gốc)                                                                             |
| DA-E09-13    | E09                                                                | Trung    | Cập nhật lại DB diagram sau khi đổi schema (users/workspaces chuyển MongoDB→PostgreSQL)                                        | [Xem](#da-e09-13-update-diagram-dbml-and-html-file-for-database-phát-sinh-ngoài-plan-gốc)                                                       |
| DA-E10-06    | E10 (CI/CD)                                                        | Trung    | CI/CD cho api-gateway bị thiếu trong plan gốc (chỉ có 4/5 service)                                                             | [Xem](#da-e10-06-write-github-actions-workflow-for-api-gateway-build-test-push-docker-image)                                                    |
| DA-E11-06    | E11 (API Gateway)                                                  | Trung    | Dockerfile api-gateway bị thiếu — cần để CI/CD build được                                                                      | [Xem](#da-e11-06-write-dockerfile-for-api-gateway)                                                                                              |
| DA-E11-07    | E11                                                                | Trung    | Global error handler chuẩn hoá `ApiResponse` — phát hiện gap khi review DA-E11-01                                              | [Xem](#da-e11-07-write-global-error-response-handler-for-gateway)                                                                               |
| DA-E12-07    | E12 (Authentication)                                               | Trung    | Nghiên cứu thuật toán JWT (HS256/RS256/ES256) — lẽ ra phải làm **trước** DA-E12-01 và DA-E11-02 vì cả 2 đều giả định RS256 sẵn | [Xem](#da-e12-07-research-hs256-vs-rs256-vs-es256-for-jwt-signing-phát-sinh-ngoài-plan-gốc)                                                     |
| DA-E11-14 ⚠️ | Gắn `E11` trên Jira — **sai epic**, nội dung thực thuộc data layer | Trung    | JPA models + repository cho 11 bảng PostgreSQL — code chạy trước khi plan cập nhật; nên gắn gần E13 mới đúng logic             | [Xem](#da-e11-14-add-all-jpa-models-from-database-schema-for-business-service-repository-layer-phát-sinh-ngoài-plan-gốc-gắn-sai-epic-trên-jira) |

| DA-AI05-07 | AI-05 (Trend Crawler) | Tuấn (AI) | Mở rộng ý tưởng crawl ngoài Google Trends/TikTok đã có | [Xem](#da-ai05-07-brainstorm-ai-crawl-idea-phát-sinh-ngoài-plan-gốc) |

> > > > > > > 5c259fda04390825822aed6b514cff238aa9e22a

**Ghi chú khác phát hiện trong quá trình đối soát (không tạo task riêng):**

- `DA-408 "Create git-commit-convention rule"` (Jira, Trung, Done) — **trùng nội dung** với acceptance criteria của DA-E02-03 (đã có sẵn "commit convention"). Không tạo task riêng, đã note trong DA-E02-03.
- `DA-562 "test slack"` (Jira, Tuấn, To Do) — **rác**, không phải task dự án thật. Đề xuất xoá khỏi Jira, không đưa vào doc này.
- `DA-407` trên Jira có prefix `[DA-E010-07]` (thừa số 0, và epic E10 vốn là CI/CD không liên quan UI) — đã chuẩn hoá thành `DA-E08-07` trong doc này.

**Việc cần làm:**

1. Sửa lại prefix task trên Jira cho khớp: `DA-407` → đổi epic gắn đúng (không phải E010)
2. Xác nhận lại DA-E11-14 nên thuộc epic nào chính thức (đề xuất: tạo epic mới "Business Service Data Layer" hoặc gộp vào E13)
3. Xoá `DA-562` khỏi Jira backlog

---

# PHẦN 2 — CHI TIẾT TASK

> Mỗi task gồm: Goal, Acceptance Criteria, Technical Notes, Dependencies. Task ID khớp với bảng ở Phần 1 — dùng trình duyệt "Find" (Ctrl+F) hoặc mục lục file để tra nhanh theo Task ID nếu không bấm được link.

## How to use this section

Each task section uses this structure:

- **Goal** — what the task accomplishes and why it matters to the system
- **Acceptance Criteria** — testable conditions for "done"
- **Technical Notes** — libraries, patterns, config values, pitfalls to avoid
- **Dependencies** — what this task blocks and what blocks it

---

## How to use this file

Each task section uses this structure:

- **Goal** — what the task accomplishes and why it matters to the system
- **Acceptance Criteria** — testable conditions for "done"
- **Technical Notes** — libraries, patterns, config values, pitfalls to avoid
- **Dependencies** — what this task blocks and what blocks it

Task IDs match Linear issues format: DA-{EPIC_ID}-{SEQ}

---

## Phase 1 — Initiation & Documentation (Sprints 1–3)

---

### DA-E01-01 — Brainstorm and align on BrandHub topic idea, define scope and MVP

**Assignee:** All (Team) | **Priority:** 🔴 Critical

**Goal:** Reach full team consensus on the BrandHub product concept, feature scope, and MVP boundaries so all subsequent planning work has a stable foundation.

**Acceptance Criteria:**

- [ ] A written MVP scope document exists listing in-scope and explicitly out-of-scope features
- [ ] All team members have signed off (commented/reacted) on the scope document in the shared workspace
- [ ] MVP feature list maps to at least one use case per role (Admin, Owner, Manager, Creator, Client, Guest)

**Technical Notes:**

- Use a shared doc (Notion or Google Docs) to capture decisions; avoid verbal-only alignment
- Explicitly call out AI features (content generation, image generation, RAG) as Phase 1 vs Phase 2 to prevent scope creep

**Dependencies:** Blocks: DA-E01-02, DA-E01-03, DA-E01-05. Blocked by: None.

---

### DA-E01-02 — Team meeting to confirm roles and responsibilities of each member

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Formally assign each team member a technical domain so there is zero ambiguity about who owns which service or deliverable throughout the project.

**Acceptance Criteria:**

- [ ] A RACI or responsibility table is published listing each member's primary service ownership and documentation duties
- [ ] Every service (business-service, ai-service, publisher-service, api-gateway, web-dashboard, mobile) has exactly one primary owner assigned
- [ ] Meeting notes with decisions are stored in the shared project workspace

**Dependencies:** Blocks: DA-E01-04, DA-E02-01. Blocked by: DA-E01-01.

---

### DA-E01-03 — Find and contact a mentor suitable for the AI + microservices topic

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Secure a mentor with relevant AI and microservices experience before the project registration deadline so the team has guidance from day one.

**Acceptance Criteria:**

- [ ] At least one mentor candidate with AI/microservices background is identified and contacted
- [ ] Mentor confirms availability and agreement to supervise the BrandHub capstone
- [ ] Mentor contact information and expected meeting cadence are recorded in the project workspace

**Dependencies:** Blocks: DA-E01-05, DA-E03-05. Blocked by: DA-E01-01.

---

### DA-E01-04 — Assess each team member's technical skills (Java, Python, React, AI tools)

**Assignee:** All (Team) | **Priority:** 🟡 High

**Goal:** Produce a skills matrix that allows the team leader to assign tasks aligned with each member's strengths and identify gaps that need upskilling or external resources.

**Acceptance Criteria:**

- [ ] Each member self-rates proficiency (Beginner/Intermediate/Advanced) in: Java/Spring Boot, Python/FastAPI, React/TypeScript, React Native, Docker, SQL/NoSQL, AI/LLM tooling
- [ ] Skills matrix is stored in the shared workspace and visible to all members
- [ ] Any critical skill gaps (e.g., no one experienced with Groq or Stability AI) are flagged with a mitigation note

**Dependencies:** Blocks: DA-E02-01. Blocked by: DA-E01-02.

---

### DA-E01-05 — Submit project registration form on the Call4project system (insideuni.fpt.edu.vn)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Complete the official university project registration before the submission deadline so the team is formally enrolled and eligible for capstone evaluation.

**Acceptance Criteria:**

- [ ] Registration form is submitted on insideuni.fpt.edu.vn with all required fields completed
- [ ] Submission confirmation (email or system acknowledgement) is saved and shared with all team members
- [ ] Mentor name listed on the form matches the confirmed mentor from DA-E01-03

**Dependencies:** Blocks: None. Blocked by: DA-E01-01, DA-E01-03.

---

### DA-E02-01 — Create Linear workspace, set up 2-week sprint cadence, create issue templates

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Establish the team's project management foundation in Linear so all tasks, sprints, and progress are tracked in a single organized system from the start.

**Acceptance Criteria:**

- [ ] Linear workspace named "BrandHub" is created and all team members are invited with appropriate roles
- [ ] Sprint cycles are configured as 2-week intervals starting from the project kick-off date
- [ ] Issue templates exist for at minimum: Feature, Bug, Documentation, and Research task types

**Dependencies:** Blocks: DA-E02-02. Blocked by: DA-E01-02, DA-E01-04.

---

### DA-E02-02 — Create GitHub Organization and 7 repos following polyrepo structure

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Provision the seven canonical repositories under a shared GitHub Organization so all team members can begin committing to isolated, correctly named codebases.

**Acceptance Criteria:**

- [ ] GitHub Organization is created and all team members are added as members
- [ ] All 7 repos exist with exact names: brandhub-business-service, brandhub-ai-service, brandhub-publisher-service, brandhub-api-gateway, brandhub-web-dashboard, brandhub-mobile-app, brandhub-infrastructure
- [ ] Each repo has a base README.md, .gitignore appropriate to its language/framework, and an initial commit on `main`

**Technical Notes:**

- Use organization-level secrets for shared credentials (GHCR token, Groq API key) rather than per-repo secrets to reduce maintenance
- Set default branch to `main`; create `develop` branch immediately as the integration target

**Dependencies:** Blocks: DA-E02-03, DA-E02-04, DA-E10-01, DA-E10-02, DA-E10-03, DA-E10-04, DA-E11-01. Blocked by: DA-E02-01.

---

### DA-E02-03 — Set up branch protection rules, PR template, commit convention (Conventional Commits)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Enforce code quality gates and consistent commit history across all 7 repositories so the codebase remains reviewable and CI-friendly throughout development.

**Acceptance Criteria:**

- [ ] Branch protection is enabled on `main` and `develop` in all 7 repos: require PR, require at least 1 approval, block direct push
- [ ] A `.github/pull_request_template.md` file exists in each repo with sections for: Summary, Changes, Testing, Screenshots
- [ ] A `CONTRIBUTING.md` or `.github/CONTRIBUTING.md` documents the Conventional Commits standard (feat, fix, docs, chore, refactor, test) with examples

**Technical Notes:**

- Use a GitHub Organization-level ruleset (available in GitHub Free for orgs) to apply protection rules across all repos from one place rather than configuring each individually
- Recommend enforcing commit message format via `commitlint` in a pre-commit hook or CI step

**Dependencies:** Blocks: DA-E10-01, DA-E10-02, DA-E10-03, DA-E10-04, DA-E10-05. Blocked by: DA-E02-02.

> **Ghi chú phát sinh:** Jira có task riêng `DA-408 "Create git-commit-convention rule"` (Trung, Done) — trùng nội dung với acceptance criteria thứ 3 ở trên (CONTRIBUTING.md/Conventional Commits). Không tạo task riêng trong doc này để tránh trùng lặp; đã gộp vào DA-E02-03.

---

### DA-E02-04 — Create project email and accounts for all services (AWS, GitHub Actions, Groq, Stability AI, etc.)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Provision all third-party service accounts under a shared project identity so credentials are team-owned, not tied to any individual member's personal account.

**Acceptance Criteria:**

- [ ] A dedicated project email address (e.g., brandhub.capstone@gmail.com) is created and credentials shared securely with all team members
- [ ] Accounts created and verified for: GitHub (org already exists), Groq API, Stability AI, and any social platform developer portals needed (Facebook Developer, TikTok for Developers)
- [ ] All API keys and credentials are stored in a shared secrets manager (e.g., a shared Bitwarden vault or GitHub Organization secrets) — never committed to any repo

**Technical Notes:**

- Groq free tier: 30 RPM, 6,000 RPM on paid; document tier limits in the project wiki so AI developers can plan request budgets
- Stability AI requires a separate API key per environment (dev/prod); provision at minimum a dev key now

**Dependencies:** Blocks: DA-E10-01, DA-E10-02, DA-E10-03, DA-E10-04. Blocked by: DA-E02-02.

---

### DA-E03-01 — List and group all 105 use cases by 6 roles (Admin, Owner, Manager, Creator, Client, Guest)

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical | **Status:** ✅ DONE 2026-09-17

**Goal:** Produce a complete, numbered, role-grouped use case inventory that gives every team member a shared reference for what BrandHub must do before any detailed writing begins.

**Acceptance Criteria:**

- [x] Exactly 105 use cases are listed, each with a unique ID (UC-01 through UC-106, no gaps/duplicates) — count corrected from the original 60-UC placeholder after cross-checking the real source CSV (`Các FR của hệ thống - Use Case.csv`)
- [x] Each use case is assigned to exactly one primary role (Admin, Owner, Manager, Creator, Client, or Guest) — see `docs/ba/use-cases/00-index.md` role grouping table
- [x] The list is stored in a shared document and accessible to the full team for review and comment — `docs/ba/use-cases/`

**Technical Notes:**

- Grouped by domain (8 files matching `docs/ba/02-09` FR groups) rather than by role blocks — cleaner mapping to FR source, avoids UC-to-FR drift

**Output:** `docs/ba/use-cases/00-index.md` (index) + 8 domain files.

**Dependencies:** Blocks: DA-E03-02, DA-E03-03, DA-E03-04, DA-E03-06. Blocked by: DA-E01-01.

---

### DA-E03-02 — Write detailed descriptions for UC-01–12 (Authentication + Profile flows)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical | **Status:** ✅ DONE 2026-09-17

**Goal:** Produce fully described use cases for UC-01 through UC-12 so that Authentication and Profile feature requirements are unambiguous for backend developers implementing those flows.

**Acceptance Criteria:**

- [x] Each of UC-01 to UC-12 includes: Actor, Precondition, Main Flow (numbered steps), Alternative Flows — see `docs/ba/use-cases/01-authentication-profile.md`
- [x] Covers: Sign Up/In (email + Google OAuth), Password Reset/Change, 2FA, Sign Out, Deactivate Account, personal Profile + Client Profile

**Technical Notes:**

- Role split changed from the original "Admin + Owner" assumption to the real FR grouping (Authentication + Profile, FR 3.2–3.3) — matches `docs/ba/02-authentication-profile.md`, not the old 6-role-fixed model

**Dependencies:** Blocks: DA-E03-05, DA-E04-01. Blocked by: DA-E03-01.

---

### DA-E03-03 — Write detailed descriptions for UC-13–73 (Agency/Workspace, Media Package/Campaign & Content Task Workflow flows)

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical | **Status:** ✅ DONE 2026-09-17

**Goal:** Produce fully described use cases for UC-13 through UC-73 covering the core day-to-day content workflow so developers building content and approval features have precise requirements.

**Acceptance Criteria:**

- [x] Each of UC-13 to UC-73 includes: Actor, Precondition, Main Flow, Alternative Flows — see `docs/ba/use-cases/02-agency-workspace.md`, `03-media-package-campaign.md`, `04-content-task-workflow.md`
- [x] Manager use cases cover: Workspace/Agency management, assigning content to creators, reviewing drafts, Task Approval Sequence, reporting to clients
- [x] Creator use cases cover: content writing, material/hashtag management, livestream/survey flows, task views, submitting for approval

**Technical Notes:**

- The approval workflow use case (UC-47) clearly distinguishes CREATOR → (optional QC) → MANAGER → CLIENT as sequential, restart-from-start-on-reject steps, matching `docs/ba/05-content-task-workflow.md` §4

**Dependencies:** Blocks: DA-E03-05, DA-E04-01. Blocked by: DA-E03-01.

---

### DA-E03-04 — Write detailed descriptions for UC-74–106 (AI, Publishing, Subscription & Admin flows)

**Assignee:** Phước (Publisher) | **Priority:** 🟡 High | **Status:** ✅ DONE 2026-09-17

**Goal:** Produce fully described use cases for UC-74 through UC-106 covering AI features, Client/publishing portal interactions, subscription/billing, and Admin management so downstream services are built to spec.

**Acceptance Criteria:**

- [x] Each of UC-74 to UC-106 includes: Actor, Precondition, Main Flow, Alternative Flows — see `docs/ba/use-cases/05-ai-features.md`, `06-publishing-social.md`, `07-subscription.md`, `08-admin-management.md`
- [x] Client-relevant use cases cover: connecting social accounts, viewing post dashboard/detail, subscription/credit management
- [x] Social publishing use cases cover: preview/schedule/track, per-platform publish (Facebook/Instagram/TikTok/Threads), fail-state tracking

**Technical Notes:**

- Publishing flow use cases (UC-87–89) reference System/CREATOR as dual actor (queued job + manual trigger context) — flag any RabbitMQ contract assumptions once DA-E07-03 is available
- Zalo OA explicitly out of scope — 4 platforms only (Facebook/Instagram/TikTok/Threads)

**Dependencies:** Blocks: DA-E03-05, DA-E04-01. Blocked by: DA-E03-01.

---

### DA-E03-05 — Review UC list with mentor, update based on feedback

**Assignee:** All (Team) | **Priority:** 🟡 High

**Goal:** Validate the full 105-use-case set with the assigned mentor to catch scope, feasibility, or completeness issues before the team invests effort writing detailed requirements documents.

**Acceptance Criteria:**

- [ ] A mentor review session is scheduled and held with at least 3 team members present
- [ ] All mentor feedback items are logged with a resolution status (Accepted / Rejected with rationale / Deferred)
- [ ] The UC list is updated to incorporate all accepted feedback and the final version is re-shared with the team

**Dependencies:** Blocks: DA-E03-06, DA-E04-01, DA-E04-02. Blocked by: DA-E01-03, DA-E03-02, DA-E03-03, DA-E03-04.

---

### DA-E03-06 — Finalize UC table into Excel file (BrandHub_UseCases.xlsx)

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Package the finalized use case list into a structured Excel file formatted for university submission and mentor reference.

**Acceptance Criteria:**

- [ ] BrandHub_UseCases.xlsx contains columns: UC ID, Title, Actor, Priority, Status, Related Epic, Brief Description
- [ ] All 105 use cases are present with no blank required fields
- [ ] File is uploaded to the shared project folder and linked from the project wiki

**Dependencies:** Blocks: None. Blocked by: DA-E03-05.

---

### DA-E04-01 — Write functional objectives per role (6 roles x features)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Translate the approved use cases into a concise functional requirements section organized by role so that each team member has a definitive feature checklist for their implementation work.

**Acceptance Criteria:**

- [ ] Functional objectives exist for all 6 roles: ADMIN, OWNER, MANAGER, CREATOR, CLIENT, GUEST
- [ ] Each role section lists its features as testable "The system shall…" statements
- [ ] Every functional objective traces back to at least one UC ID from the approved use case list

**Technical Notes:**

- Use the exact role names from the JWT claim (ADMIN, OWNER, etc.) throughout to ensure naming consistency with the implementation

**Dependencies:** Blocks: DA-E04-05, DA-E07-01. Blocked by: DA-E03-02, DA-E03-03, DA-E03-04, DA-E03-05.

---

### DA-E04-02 — Write non-functional requirements (UI, Performance, Security, Reliability, Usability)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Define measurable non-functional requirements so that architecture and implementation decisions have objective quality targets to meet.

**Acceptance Criteria:**

- [ ] NFRs are written for all 5 categories: UI/UX, Performance, Security, Reliability, Usability — each with at least 3 measurable criteria
- [ ] Performance NFRs include: API p95 response time target, minimum concurrent user count, dashboard load time
- [ ] Security NFRs include: JWT access token TTL (15 min), refresh token TTL (30 days), rate limit threshold (100 req/min/user), HTTPS enforcement

**Technical Notes:**

- Align rate limit NFR with the api-gateway implementation value: 100 requests/minute/user using Redis key `ratelimit:{userId}:{minute}`
- Do not set AI generation latency targets here; those are covered in DA-E04-03

**Dependencies:** Blocks: DA-E04-05. Blocked by: DA-E03-05.

---

### DA-E04-03 — Add AI performance requirements (latency, throughput, model accuracy thresholds)

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Define specific, measurable performance targets for all AI features so the ai-service implementation has clear acceptance thresholds for latency and quality.

**Acceptance Criteria:**

- [ ] Latency targets are defined for each ai-service endpoint: /ai/content, /ai/image, /ai/video, /ai/ambassador, /ai/rag, /ai/trends
- [ ] Throughput targets (requests/minute) are specified per endpoint, accounting for Groq and Stability AI free-tier limits
- [ ] Minimum acceptable quality thresholds are defined for content generation (e.g., coherence, language match) and image generation (e.g., resolution, rejection criteria)

**Technical Notes:**

- Groq free tier: ~30 RPM; document this as a hard system constraint and specify queue/retry behavior when limit is hit
- RAG retrieval (/ai/rag) latency target must account for ChromaDB vector search time; budget at least 500ms separately from LLM inference time

**Dependencies:** Blocks: DA-E04-05. Blocked by: DA-E03-05.

---

### DA-E04-04 — Add mobile requirements (FCM, offline draft, camera) to non-functional section

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Document mobile-specific requirements so the React Native app is built with the correct offline, notification, and device capability behaviors from the start.

**Acceptance Criteria:**

- [ ] FCM push notification requirement is documented: minimum notification delivery latency, supported notification types (approval request, publish success/failure)
- [ ] Offline draft requirement is documented: which fields can be edited offline, sync behavior when connectivity is restored
- [ ] Camera/media requirement is documented: supported formats for image upload, maximum file size, whether video capture is in MVP scope

**Technical Notes:**

- Expo SDK provides `expo-camera`, `expo-image-picker`, and `expo-notifications` — confirm FCM setup works via Expo's push notification service (EAS) rather than raw FCM to avoid native build complexity
- Offline draft sync must define conflict resolution strategy (last-write-wins vs. server-authoritative) to avoid ambiguity during implementation

**Dependencies:** Blocks: DA-E04-05. Blocked by: DA-E03-05.

---

### DA-E04-05 — Fill in and finalize the Capstone Register form (BrandHub_Capstone_Register.docx)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Complete the official university capstone registration document with all required technical and team information so it is ready for submission to the faculty.

**Acceptance Criteria:**

- [ ] BrandHub_Capstone_Register.docx is fully filled in with no blank required fields
- [ ] Document includes: project title, team members with student IDs, mentor name, functional objectives summary, non-functional requirements summary, and technology stack
- [ ] Final document is reviewed by all team members and approved before submission

**Dependencies:** Blocks: None. Blocked by: DA-E04-01, DA-E04-02, DA-E04-03, DA-E04-04.

---

### DA-E05-01 — Draw system architecture overview diagram (7 services + 5 databases + RabbitMQ + clients)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Produce a single authoritative architecture diagram showing all system components and their connections so every team member has a shared visual mental model of the full system.

**Acceptance Criteria:**

- [ ] Diagram includes all 7 services: api-gateway (8080), business-service (8081), ai-service (8082), publisher-service (8083), web-dashboard, mobile app, and infrastructure
- [ ] Diagram includes all 5 data stores: MongoDB (27017), PostgreSQL (5432), Redis (6379), ChromaDB (8000), and RabbitMQ (5672/15672) with their owning service clearly indicated
- [ ] External actors (Web Browser, Mobile App, Social Platform APIs) are shown as separate nodes with arrows indicating communication direction and protocol (HTTP/HTTPS, AMQP)

**Technical Notes:**

- Use draw.io or Excalidraw for diagramming so the source file can be committed to the brandhub-infrastructure repo alongside documentation
- Color-code by layer: client → gateway → services → data stores to aid readability

**Dependencies:** Blocks: DA-E05-02, DA-E05-03, DA-E05-04, DA-E05-08. Blocked by: DA-E01-01.

---

### DA-E05-02 — Define service responsibilities and boundaries (what each of the 7 services does and does NOT do)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Write explicit responsibility and anti-responsibility definitions for each service to prevent scope overlap and cross-service coupling during implementation.

**Acceptance Criteria:**

- [ ] Each of the 7 services has a written "Owns" list and a "Does NOT own" list
- [ ] No two services share ownership of the same concern (e.g., only business-service owns user authentication; only publisher-service sends to social APIs)
- [ ] Document is stored in the brandhub-infrastructure repo under `docs/service-boundaries.md`

**Technical Notes:**

- Key boundary to make explicit: business-service orchestrates publishing by sending a RabbitMQ message; publisher-service executes the actual social API call and sends a callback — business-service must never call social APIs directly

**Dependencies:** Blocks: DA-E05-05, DA-E05-08. Blocked by: DA-E05-01.

---

### DA-E05-03 — Draw database ownership diagram (which service owns which DB, cross-DB reference strategy)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Visually document which service exclusively owns each database and how cross-service data references are handled so developers do not create unauthorized cross-database joins or direct DB access.

**Acceptance Criteria:**

- [ ] Diagram shows: business-service → MongoDB + PostgreSQL + Redis; ai-service → ChromaDB + Redis (read-only for rate limit); publisher-service → Redis (read-only for job state)
- [ ] Cross-DB reference strategy is documented: services reference foreign entities by ID only, never by joining across databases
- [ ] Diagram is committed to brandhub-infrastructure repo under `docs/`

**Technical Notes:**

- Document that publisher-service must not have a direct connection string to MongoDB or PostgreSQL — it receives all needed data in the RabbitMQ message payload

**Dependencies:** Blocks: DA-E06-01, DA-E05-08. Blocked by: DA-E05-01.

---

### DA-E05-04 — Document service-to-service communication (REST: business-ai, RabbitMQ: business-publisher, HTTP callback: publisher-business)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Produce a complete communication contract document so that each service team knows exactly how to send and receive messages from other services without ad hoc coordination.

**Acceptance Criteria:**

- [ ] REST communication from business-service to ai-service is documented with: base URL, auth mechanism, timeout value, retry policy
- [ ] RabbitMQ publish job message from business-service to publisher-service is documented with: exchange name, routing key, queue name, full message JSON schema
- [ ] HTTP callback from publisher-service back to business-service is documented with: endpoint URL pattern, callback payload schema, expected HTTP response codes, retry behavior on callback failure

**Technical Notes:**

- Use a shared internal API key (not JWT) for business→ai-service calls since ai-service is not exposed through the public gateway; document the header name (e.g., `X-Internal-Api-Key`)
- RabbitMQ exchange type: use `direct` exchange for publish jobs to ensure exactly one publisher-service instance processes each job

**Dependencies:** Blocks: DA-E07-01, DA-E07-02, DA-E07-03, DA-E05-08. Blocked by: DA-E05-02.

---

### DA-E05-05 — Write Architecture Decision Records (ADRs) for 4 key decisions: polyrepo, MongoDB+PostgreSQL split, RabbitMQ, Spring Cloud Gateway

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Document the rationale behind the four most consequential architecture decisions so the team can defend them to the mentor and future reviewers, and so the decisions are not revisited without cause.

**Acceptance Criteria:**

- [ ] Four ADR files exist: `ADR-001-polyrepo.md`, `ADR-002-database-split.md`, `ADR-003-rabbitmq.md`, `ADR-004-spring-cloud-gateway.md`
- [ ] Each ADR follows the standard format: Status, Context, Decision, Consequences (positive and negative)
- [ ] ADRs are committed to brandhub-infrastructure repo under `docs/adr/`

**Technical Notes:**

- ADR-002 must explain why MongoDB is used for content/posts/analytics (flexible schema, document model) while PostgreSQL is used for users/workspaces/subscriptions (ACID transactions, relational integrity) — this is the question mentors most commonly ask
- ADR-003 must justify async over synchronous REST for publishing: social API latency (2–30s), retry isolation, and publisher-service independent scalability

**Dependencies:** Blocks: DA-E05-08. Blocked by: DA-E05-02, DA-E05-03.

---

### DA-E05-06 — Draw sequence diagrams for 4 core flows: content creation, approval workflow, auto-publishing, OAuth token refresh

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Produce detailed sequence diagrams for the four most complex system flows so developers know the exact call order, data passed at each step, and error handling paths before writing code.

**Acceptance Criteria:**

- [ ] Content creation sequence diagram covers: client → gateway → business-service → ai-service (content generation) → response with draft saved to MongoDB
- [ ] Approval workflow sequence diagram covers: creator submits → manager reviews → optional client approval → status transitions and notifications at each step
- [ ] Auto-publishing sequence covers: scheduler trigger → business-service → RabbitMQ publish message → publisher-service → social API call → HTTP callback → business-service updates post status
- [ ] OAuth token refresh sequence covers: client detects 401 → sends refresh token cookie → gateway forwards to business-service → JWT blacklist check via Redis → new access token issued → old jti added to `jwt:blacklist:{jti}`

**Technical Notes:**

- Use PlantUML or Mermaid so diagrams are text-based and committable to the repo; avoid image-only diagrams
- Token refresh diagram must show that the old jti is written to Redis blacklist (`jwt:blacklist:{jti}`) before the new token is issued, not after

**Dependencies:** Blocks: DA-E05-08, DA-E11-02. Blocked by: DA-E05-04.

---

### DA-E05-07 — Write the AI architecture section in the Technical Document (ai-service internal design, ChromaDB schema, LLM routing strategy)

**Assignee:** Tuấn (AI) | **Priority:** 🟡 High

**Goal:** Document the internal design of ai-service so the AI developers have a clear implementation blueprint and so the mentor can evaluate the AI subsystem's technical soundness.

**Acceptance Criteria:**

- [ ] ai-service internal architecture is documented: FastAPI router structure, service layer separation, async task handling for long-running generation jobs
- [ ] ChromaDB schema is documented: collection names, metadata fields stored per embedding, embedding model used (e.g., sentence-transformers model name)
- [ ] LLM routing strategy is documented: which model/endpoint is used for each task type (content generation → Groq LLaMA, image → Stability AI, RAG → Groq with ChromaDB retrieval)

**Technical Notes:**

- Document the Groq model ID used (e.g., `llama3-8b-8192` or `mixtral-8x7b-32768`) as a configuration value, not hardcoded, so it can be swapped without code changes
- ChromaDB collection naming convention: use `workspace_{workspaceId}_brand_voice` to enforce workspace isolation at the collection level

**Dependencies:** Blocks: DA-E05-08. Blocked by: DA-E05-04.

---

### DA-E05-08 — Compile full technical document (BrandHub_Technical_Document.md)

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Assemble all architecture, design, and decision artifacts into a single cohesive technical document that serves as the primary reference for developers and the official submission to the mentor.

**Acceptance Criteria:**

- [ ] Document contains all major sections: System Overview, Service Boundaries, Database Design, API Contracts, Sequence Diagrams, AI Architecture, ADRs, Security Model, Deployment Architecture
- [ ] All diagrams referenced in the document are embedded or linked with accessible URLs
- [ ] Document is reviewed by all team members, version-tagged (v1.0), and stored in the brandhub-infrastructure repo under `docs/`

**Dependencies:** Blocks: None. Blocked by: DA-E05-01, DA-E05-02, DA-E05-03, DA-E05-04, DA-E05-05, DA-E05-06, DA-E05-07.

---

### DA-E06-01 — Define database strategy: which data goes into MongoDB vs PostgreSQL and why

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Establish a written, rule-based data placement strategy so every developer knows without ambiguity whether a new entity belongs in MongoDB or PostgreSQL.

**Acceptance Criteria:**

- [ ] A written strategy document lists the decision criteria for MongoDB (flexible schema, document-oriented, high write throughput) vs PostgreSQL (ACID transactions, relational integrity, financial/subscription data)
- [ ] Each of the 17 planned collections/tables is mapped to its database with a one-line rationale
- [ ] The document is approved by the team leader and stored in brandhub-infrastructure repo under `docs/`

**Technical Notes:**

- Hard rule: all financial data (subscriptions, billing records) lives in PostgreSQL for ACID compliance; no exceptions
- Hard rule: all content entities (posts, content requests, analytics events) live in MongoDB due to flexible schema and high write volume

**Dependencies:** Blocks: DA-E06-02, DA-E06-03. Blocked by: DA-E05-03.

---

### DA-E06-02 — Design 12 MongoDB collections with full field types, required/optional flags, default values

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Produce a complete MongoDB schema specification for all 12 collections so developers can implement Spring Data MongoDB repositories and Mongoose schemas without guessing field names or types.

**Acceptance Criteria:**

- [ ] All 12 collections are documented with every field: name, BSON type, required/optional, default value, and a brief description
- [ ] Every collection includes the mandatory fields: `_id` (ObjectId), `workspaceId` (String, required, indexed), `createdAt` (Date), `updatedAt` (Date)
- [ ] Embedded document structures and arrays are fully expanded — no fields left as "TBD"

**Technical Notes:**

- Use String type (not ObjectId) for cross-collection references (e.g., `workspaceId`, `userId`) since business-service cross-references PostgreSQL IDs which are UUIDs
- `posts` collection must include a `status` enum field with all valid state values: DRAFT, PENDING_REVIEW, APPROVED, SCHEDULED, PUBLISHING, PUBLISHED, FAILED, REJECTED

**Dependencies:** Blocks: DA-E06-05, DA-E06-07, DA-E07-01. Blocked by: DA-E06-01.

---

### DA-E06-03 — Design 5 PostgreSQL tables with constraints and internal foreign keys

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Produce a complete PostgreSQL schema specification for all 5 tables so developers can write JPA entities and Flyway migrations without ambiguity about constraints, keys, or data types.

**Acceptance Criteria:**

- [ ] All 5 tables are documented with every column: name, PostgreSQL data type, nullable, default value, constraints (PK, FK, UNIQUE, CHECK)
- [ ] Foreign keys between tables are explicitly defined with ON DELETE behavior specified for each
- [ ] Tables include at minimum: `users`, `workspaces`, `workspace_members`, `subscription_plans`, `workspace_subscriptions`

**Technical Notes:**

- Use `UUID` (not SERIAL/BIGINT) as primary key type for all tables to avoid ID collision across environments and to match the `sub` claim format in JWT
- `workspace_members` table must have a composite unique constraint on `(workspace_id, user_id)` to prevent duplicate membership records

**Dependencies:** Blocks: DA-E06-05, DA-E06-07, DA-E07-01. Blocked by: DA-E06-01.

---

### DA-E06-04 — Define indexing strategy for MongoDB and PostgreSQL

**Assignee:** Tuấn (AI) | **Priority:** 🟡 High

**Goal:** Specify all database indexes needed to meet API performance requirements so the initialization scripts and application code create them from day one, not as a post-launch optimization.

**Acceptance Criteria:**

- [ ] Every MongoDB collection has its indexes listed: field(s), index type (single, compound, text, TTL), and the query pattern it supports
- [ ] Every PostgreSQL table has its indexes listed beyond the automatic PK index, including indexes on foreign key columns and any columns used in WHERE clauses
- [ ] TTL index is defined on any MongoDB collection used for temporary data (e.g., OAuth state cache if stored in MongoDB rather than Redis)

**Technical Notes:**

- Mandatory compound index on MongoDB collections: `{ workspaceId: 1, createdAt: -1 }` for all time-series queries (posts, analytics events)
- PostgreSQL: add index on `workspace_members(workspace_id)` and `workspace_members(user_id)` separately since both are common query patterns

**Dependencies:** Blocks: DA-E06-07. Blocked by: DA-E06-02, DA-E06-03.

---

### DA-E06-05 — Write DBML code for dbdiagram.io (MongoDB + PostgreSQL + Enums + Refs + TableGroups)

**Assignee:** Tuấn (AI) | **Priority:** 🟡 High

**Goal:** Produce a complete, renderable DBML file covering all 17 collections/tables so the team has a visual, shareable database diagram for documentation and mentor review.

**Acceptance Criteria:**

- [ ] DBML file renders without errors on dbdiagram.io
- [ ] All 12 MongoDB collections and 5 PostgreSQL tables are represented with their fields and types
- [ ] Enums are defined for all enum-typed fields (e.g., UserRole, PostStatus, SubscriptionTier); TableGroups separate MongoDB from PostgreSQL; Refs show cross-collection/table relationships

**Technical Notes:**

- DBML does not natively support BSON types; use the closest SQL equivalent (e.g., ObjectId → varchar, Array → text[]) and add a comment noting the actual BSON type
- Commit the `.dbml` file to brandhub-infrastructure repo under `docs/database/` alongside the exported diagram PNG

**Dependencies:** Blocks: DA-E05-08. Blocked by: DA-E06-02, DA-E06-03.

---

### DA-E06-06 — Document Redis key patterns (JWT blacklist, rate limit, OAuth state, trending cache)

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Define all Redis key patterns, TTLs, and value formats used across the system so that every service writing to or reading from Redis uses consistent, non-colliding key structures.

**Acceptance Criteria:**

- [ ] All 4 key pattern families are documented: JWT blacklist, rate limiting, OAuth state, and trending/analytics cache
- [ ] Each pattern entry includes: key template, example key, value type, value content, TTL, and which service reads/writes it
- [ ] Document explicitly states that JWT blacklist TTL must equal the access token TTL (15 minutes) so blacklist entries expire naturally when the token would have expired anyway

**Technical Notes:**

- Key patterns must exactly match what is configured in api-gateway and business-service code:
  - `jwt:blacklist:{jti}` → value: `"1"`, TTL: 15 minutes
  - `ratelimit:{userId}:{minute}` → value: request count (INCR), TTL: 60 seconds
  - `oauth:state:{state}` → value: JSON with provider + redirect URI, TTL: 10 minutes
- Use Redis `INCR` + `EXPIRE` (set only on first INCR) pattern for rate limiting, not a Lua script, for simplicity

**Dependencies:** Blocks: DA-E11-03. Blocked by: DA-E05-04.

---

### DA-E06-07 — Write database initialization scripts (init-mongo.js + init-postgres.sql)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Produce runnable initialization scripts that create all collections, indexes, tables, constraints, and seed data so any developer can spin up a fully configured local database with a single `docker-compose up` command.

**Acceptance Criteria:**

- [ ] `init-mongo.js` creates all 12 collections with schema validation rules (where applicable) and all indexes defined in DA-E06-04
- [ ] `init-postgres.sql` creates all 5 tables with all constraints and seeds at least 3 subscription plan records (e.g., FREE, PROFESSIONAL, ENTERPRISE)
- [ ] Both scripts are idempotent (safe to run multiple times without error) and are mounted into the Docker containers via the docker-compose.yml from DA-E09-01

**Technical Notes:**

- MongoDB init script path in docker-compose: `/docker-entrypoint-initdb.d/init-mongo.js` — MongoDB Docker image automatically executes `.js` files in this directory on first start
- PostgreSQL init script path: `/docker-entrypoint-initdb.d/init-postgres.sql` — same convention; use `CREATE TABLE IF NOT EXISTS` for idempotency

**Dependencies:** Blocks: DA-E09-01, DA-E09-02. Blocked by: DA-E06-02, DA-E06-03, DA-E06-04.

---

### DA-E06-08 — Write database access rules documentation (every query must include workspaceId filter; CLIENT additionally requires clientId filter)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Document mandatory data access rules as a non-negotiable implementation contract so that no developer accidentally builds a query that can leak data across workspaces or client accounts.

**Acceptance Criteria:**

- [ ] Rule 1 is documented: every MongoDB query on a multi-tenant collection must include `{ workspaceId: <value> }` as a filter condition — no exceptions
- [ ] Rule 2 is documented: all queries executed in the context of a CLIENT role must additionally filter by `{ clientId: <value> }`
- [ ] Document includes a code example (Java/Spring Data style) showing a compliant and a non-compliant query side by side

**Technical Notes:**

- Enforce Rule 1 at the repository layer in Spring Data MongoDB using a custom `ReactiveMongoTemplate` or `@Query` annotation pattern that always injects `workspaceId` from the security context — do not rely on individual developers remembering to add the filter
- The `workspaceId` value must be extracted from the JWT claim (`workspaceId` field) passed via the `X-Workspace-Id` header set by api-gateway after token validation

**Dependencies:** Blocks: DA-E07-01. Blocked by: DA-E06-02, DA-E06-03.

---

### DA-E07-01 — Define all endpoints for business-service (Auth, User, Workspace, Client, Post, ContentRequest, SocialAccount, Analytics, Report, Subscription, Admin)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Produce a complete endpoint inventory for business-service so that api-gateway routing rules, frontend API clients, and OpenAPI specs can all be written from a single authoritative source.

**Acceptance Criteria:**

- [ ] Every endpoint is listed with: HTTP method, path, required role(s), request body schema (or "none"), and response body schema
- [ ] All 11 functional groups are covered: Auth, User, Workspace, Client, Post, ContentRequest, SocialAccount, Analytics, Report, Subscription, Admin
- [ ] Each endpoint specifies which JWT claims it requires from the gateway headers (X-User-Id, X-User-Role, X-Workspace-Id)

**Technical Notes:**

- Path convention: `/api/v1/{resource}` for all business-service endpoints; this must match the routing rules in api-gateway
- Auth endpoints (`/api/v1/auth/**`) must be in the gateway's public (no-JWT) allowlist; document this explicitly on each auth endpoint entry

**Dependencies:** Blocks: DA-E07-04, DA-E07-05, DA-E11-04. Blocked by: DA-E04-01, DA-E06-02, DA-E06-03, DA-E06-08.

---

### DA-E07-02 — Define endpoints for ai-service (/ai/content, /ai/image, /ai/video, /ai/ambassador, /ai/rag, /ai/trends)

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Produce a complete endpoint specification for ai-service so that business-service developers know exactly how to call each AI endpoint and what response format to expect.

**Acceptance Criteria:**

- [ ] All 6 endpoint groups are documented: /ai/content, /ai/image, /ai/video, /ai/ambassador, /ai/rag, /ai/trends
- [ ] Each endpoint includes: HTTP method, full path, request body schema with field types, response schema, error codes, and expected p95 latency (from DA-E04-03)
- [ ] Authentication mechanism for internal calls is documented (X-Internal-Api-Key header, value from environment variable)

**Technical Notes:**

- ai-service is NOT routed through the public api-gateway; business-service calls it directly on its internal Docker network hostname (`ai-service:8082`)
- All endpoints should be async-capable (FastAPI `async def`) to avoid blocking the event loop during Groq/Stability AI HTTP calls; use `httpx.AsyncClient` not the synchronous `requests` library

**Dependencies:** Blocks: DA-E07-06, DA-E05-08. Blocked by: DA-E05-04, DA-E05-07.

---

### DA-E07-03 — Define RabbitMQ message format for publisher-service (publish job + callback message contract)

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Establish the exact JSON schema for both the publish job message and the callback message so business-service and publisher-service can be developed independently against the same contract.

**Acceptance Criteria:**

- [ ] Publish job message schema is fully defined: all fields with types, required/optional, and example values — must include at minimum: jobId, postId, workspaceId, platform (FB/TikTok/Threads), scheduledAt, content (text, mediaUrls), socialAccountCredentials reference
- [ ] Callback message schema is fully defined: jobId, postId, status (SUCCESS/FAILED), platformPostId (on success), errorCode + errorMessage (on failure), processedAt
- [ ] Exchange name, routing keys, and queue names are specified for both message directions

**Technical Notes:**

- Exchange name: `brandhub.publishing` (direct exchange); routing key for job: `publish.job`; routing key for callback: `publish.callback`
- Do NOT include raw OAuth access tokens in the message payload; instead include a `socialAccountId` reference and have publisher-service fetch credentials from a secure store or receive them as an encrypted field

**Dependencies:** Blocks: DA-E05-04. Blocked by: DA-E05-02.

---

### DA-E07-04 — Write standard API response format (ApiResponse wrapper, error codes, HTTP status codes)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Define a single, mandatory API response envelope used by both business-service and ai-service so that frontend clients and the mobile app can use one consistent response-parsing pattern.

**Acceptance Criteria:**

- [ ] `ApiResponse<T>` wrapper schema is defined with fields: `success` (boolean), `data` (T, nullable), `error` (object with `code` and `message`, nullable), `timestamp` (ISO 8601)
- [ ] A complete error code catalogue is written covering all expected error conditions across Auth, Content, AI, Publishing, and Admin domains (minimum 20 error codes)
- [ ] HTTP status code usage is standardized: 200 OK, 201 Created, 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 409 Conflict, 429 Too Many Requests, 500 Internal Server Error — with the specific scenario each is used for

**Technical Notes:**

- Implement `ApiResponse` as a generic Java record in business-service and as a Pydantic model in ai-service to enforce structure at the framework level
- 429 Too Many Requests must be returned by api-gateway (not business-service) when the Redis rate limit is exceeded; the response body must still follow the `ApiResponse` wrapper format

**Dependencies:** Blocks: DA-E07-05, DA-E07-06. Blocked by: DA-E07-01.

---

### DA-E07-05 — Write OpenAPI YAML spec for business-service

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Produce a complete, valid OpenAPI 3.1 YAML specification for business-service so that frontend developers can generate typed API clients and the spec can be served via Swagger UI during development.

**Acceptance Criteria:**

- [ ] OpenAPI YAML is valid and renders without errors in Swagger Editor (editor.swagger.io)
- [ ] All endpoints from DA-E07-01 are present with full request/response schemas, security requirements, and example values
- [ ] The file is committed to the brandhub-business-service repo under `docs/openapi.yaml` and auto-served via SpringDoc (`/swagger-ui.html`) when the service runs

**Technical Notes:**

- Add `springdoc-openapi-starter-webmvc-ui` dependency to business-service `pom.xml`; annotate controllers with `@Tag` and `@Operation` so the YAML can be auto-generated from code annotations rather than maintained manually
- Include `X-User-Id`, `X-User-Role`, and `X-Workspace-Id` as header parameters in every secured endpoint definition since these are injected by the gateway, not passed by the client

**Dependencies:** Blocks: None. Blocked by: DA-E07-01, DA-E07-04.

---

### DA-E07-06 — Write OpenAPI YAML spec for ai-service (all internal + public endpoints)

**Assignee:** Tuấn (AI) | **Priority:** 🟡 High

**Goal:** Produce a complete, valid OpenAPI 3.1 YAML specification for ai-service so that business-service developers have a precise integration contract and the spec is available via FastAPI's built-in Swagger UI.

**Acceptance Criteria:**

- [ ] OpenAPI YAML is valid and auto-served by FastAPI at `/docs` (Swagger UI) and `/openapi.json` when ai-service runs
- [ ] All endpoints from DA-E07-02 are documented with full request/response schemas and `X-Internal-Api-Key` security scheme defined
- [ ] Response schemas include both success and error examples with realistic AI-generated content samples

**Technical Notes:**

- FastAPI auto-generates OpenAPI from type annotations — use Pydantic v2 models for all request/response bodies to get accurate schema generation; do not write the YAML manually
- Export the final spec by calling `GET /openapi.json` on the running service and committing the output to `docs/openapi.json` in the brandhub-ai-service repo

**Dependencies:** Blocks: None. Blocked by: DA-E07-02, DA-E07-04.

---

### DA-E07-07 — Document social platform API specs: FB Graph API v19, TikTok Content API v2, Threads API (versions, rate limits, payload formats)

**Assignee:** Phước (Publisher) | **Priority:** 🟡 High

**Goal:** Compile the external social platform API constraints into one reference document so publisher-service developers do not need to read four separate developer portals during implementation.

**Acceptance Criteria:**

- [ ] Each of the 4 platforms is documented with: API version pinned, authentication method, post creation endpoint, media upload method, rate limits, and error response format
- [ ] Platform-specific payload format examples are included for at minimum: text post, image post, and video post (where supported)
- [ ] Known gotchas or restrictions are documented (e.g., TikTok video minimum duration, Threads media attachment limits)

**Technical Notes:**

- Pin API versions explicitly: Facebook Graph API v19.0, TikTok Content Posting API v2; note that using unpinned versions risks breaking changes
- Document Facebook's Page Access Token vs. User Access Token distinction — publisher-service will need Page Access Tokens (long-lived) for posting; document the token exchange flow

**Dependencies:** Blocks: None. Blocked by: DA-E03-04.

---

### DA-E08-01 — Create Figma wireframes for all main screens (Login, Dashboard, Workspace, Content Editor, Calendar, Client Portal, Analytics)

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Produce low-to-mid fidelity wireframes for all primary screens so frontend developers can begin component implementation without waiting for high-fidelity design, and so the UX flow can be validated with the mentor early.

**Acceptance Criteria:**

- [ ] Wireframes exist for all 7 screen categories: Login/Auth, Main Dashboard, Workspace Management, Content Editor (with AI generation panel), Content Calendar, Client Portal, Analytics Dashboard
- [ ] Each wireframe shows the layout for both the primary user role and any role-specific variations (e.g., Content Editor view for CREATOR vs. review view for MANAGER)
- [ ] Figma file is shared with the team via a view link and the URL is recorded in the project wiki

**Technical Notes:**

- Design for 1440px desktop width as the primary breakpoint for web-dashboard; include a 375px mobile frame for the 3 screens that appear in the mobile app (Content Calendar, Notifications, Post Preview)
- Use shadcn/ui component names as annotations on wireframe elements (e.g., label a modal as "Dialog", a dropdown as "Select") to speed up implementation mapping

**Dependencies:** Blocks: DA-E08-02, DA-E08-03, DA-E08-04. Blocked by: DA-E03-01, DA-E04-04.

---

### DA-E08-02 — Design component system (Button, Input, Modal, Table, Badge, Toast styles)

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Define the visual design tokens and component variants that will be used across the web-dashboard so that all UI components have a consistent look without per-developer style decisions.

**Acceptance Criteria:**

- [ ] Design tokens are defined in Figma for: primary/secondary/destructive colors, typography scale (font family, sizes, weights), spacing scale, border radius values, and shadow levels
- [ ] Component variants are designed for: Button (primary, secondary, destructive, ghost, sizes), Input (default, error, disabled), Modal/Dialog, Table (with sort headers, pagination), Badge (status colors for PostStatus enum values), Toast (success, error, warning, info)
- [ ] All tokens and component names in Figma match their shadcn/ui equivalents so developers can implement them without translation

**Technical Notes:**

- shadcn/ui uses CSS variables for theming (`--primary`, `--secondary`, etc.) — define Figma variables with the same names to make the design-to-code handoff mechanical
- Badge color mapping to PostStatus: DRAFT (gray), PENDING_REVIEW (yellow), APPROVED (blue), SCHEDULED (purple), PUBLISHED (green), FAILED (red), REJECTED (red/dark)

**Dependencies:** Blocks: None. Blocked by: DA-E08-01.

---

### DA-E08-03 — Draw user flow diagrams for 3 main flows: content creation, approval, publishing

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Produce UX-layer user flow diagrams (screen-to-screen, not sequence diagrams) for the three most critical end-user journeys so frontend developers know which screens connect to which and what triggers each navigation.

**Acceptance Criteria:**

- [ ] Content creation flow diagram covers: entry point (Dashboard) → AI prompt input → generation result → draft editing → save draft / submit for review
- [ ] Approval flow diagram covers: notification received → review screen → approve/request changes/reject → notification sent to creator → (if approved) calendar placement
- [ ] Publishing flow diagram covers: scheduled post on calendar → publish trigger → status polling or push notification → success state or failure state with retry option

**Technical Notes:**

- Use Figma's connector arrows (not a separate tool) so flow diagrams live in the same file as wireframes and stay in sync when screens change
- Each flow node should reference the wireframe frame by name so developers can jump directly from the flow diagram to the corresponding screen design

**Dependencies:** Blocks: None. Blocked by: DA-E08-01.

---

### DA-E08-04 — Wireframe Client Portal (read-only calendar, approve/reject, analytics view)

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Design the CLIENT-facing portal screens so the team has a clear, minimal interface target for the client-facing features that differ significantly from the internal agency dashboard.

**Acceptance Criteria:**

- [ ] Read-only content calendar wireframe shows: monthly/weekly view, post status indicators, post detail preview panel (text + image, no edit controls)
- [ ] Approve/reject interaction is wireframed: approve button, reject with required comment field, confirmation state
- [ ] Analytics view wireframe shows: reach/impressions/engagement metrics per platform, date range selector, export button placeholder

**Technical Notes:**

- Client portal must be visually distinct from the agency dashboard — consider a stripped navigation (no workspace switcher, no AI tools) to reinforce the limited-access context for the CLIENT role
- Approve/reject actions must show the current post status (from the PostStatus enum) to indicate whether action has already been taken

**Dependencies:** Blocks: None. Blocked by: DA-E08-01.

---

### DA-E08-05 — Create a view-local document website automation _(phát sinh, ngoài plan gốc)_

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Tự động hoá việc tạo trang xem tài liệu (docs) local để team và mentor có thể duyệt tài liệu dự án dưới dạng website thay vì đọc raw markdown/html rời rạc.

**Acceptance Criteria:**

- [ ] Script/tool sinh ra trang tổng hợp tài liệu từ `brandhub-infrastructure/docs/`
- [ ] Chạy local được (không cần deploy), phục vụ việc review nội bộ

**Ghi chú:** Task không có trong `BrandHub_Task_Details.md` gốc — phát sinh trong quá trình làm doc site. Jira: DA-405, status Done.

**Dependencies:** Blocks: DA-E08-08. Blocked by: None.

---

### DA-E08-08 — Integrated .html for view document _(phát sinh, ngoài plan gốc)_

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Tích hợp các file `.html` (architecture diagrams, DB schema diagrams) vào trang xem tài liệu để duyệt trực quan thay vì mở từng file riêng lẻ.

**Acceptance Criteria:**

- [ ] Toàn bộ file `.html` trong `docs/architecture/` và `docs/database/` hiển thị được qua doc site

**Ghi chú:** Task không có trong plan gốc, phát sinh cùng nhóm với DA-E08-05. Jira: DA-409, status Done.

**Dependencies:** Blocks: None. Blocked by: DA-E08-05.

---

### DA-E08-07 — Create landing page UI _(phát sinh, ngoài plan gốc — prefix Jira lỗi)_

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Thiết kế/code landing page public cho BrandHub (không phải dashboard nội bộ) — trang giới thiệu sản phẩm trước khi user đăng nhập.

**Acceptance Criteria:**

- [ ] Landing page hiển thị được, có CTA đăng ký/đăng nhập
- [ ] Responsive cơ bản

**Ghi chú:** Task không nằm trong 46 epic gốc — landing page không được lên kế hoạch từ đầu. Trên Jira prefix ghi `[DA-E010-07]` (thừa số 0, và epic E10 vốn là CI/CD chứ không liên quan UI) — đây rõ ràng là lỗi gõ, nội dung thực chất thuộc mảng UI/Frontend (gần E08). Đặt tại đây cho đúng logic, giữ nickname `DA-E08-07` để không trùng số thứ tự đã dùng. Jira: DA-407, status Done.

**Dependencies:** Blocks: None. Blocked by: DA-E08-01.

---

### DA-E09-01 — Write docker-compose.yml to run the full infrastructure stack: MongoDB, PostgreSQL, Redis, RabbitMQ, ChromaDB

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Produce a single docker-compose.yml that any developer can run to start the complete local infrastructure stack with correct ports, volumes, health checks, and network configuration.

**Acceptance Criteria:**

- [ ] docker-compose.yml defines all 5 infrastructure services with exact image versions: MongoDB 7, PostgreSQL 16, Redis 7-alpine, RabbitMQ 3-management, ChromaDB (latest pinned tag)
- [ ] All services expose their canonical ports: 27017, 5432, 6379, 5672+15672, 8000
- [ ] Every service has a `healthcheck` configured and all application-level services declare `depends_on` with `condition: service_healthy`

**Technical Notes:**

- Mount init scripts into the correct paths: `./init-mongo.js:/docker-entrypoint-initdb.d/init-mongo.js` and `./init-postgres.sql:/docker-entrypoint-initdb.d/init-postgres.sql`
- Define a single Docker network (`brandhub-network`) so all services can address each other by service name; this network name must be documented for developers adding application service containers later
- Pin RabbitMQ to `rabbitmq:3-management` not `latest`; add `RABBITMQ_DEFAULT_USER` and `RABBITMQ_DEFAULT_PASS` from `.env` file

**Dependencies:** Blocks: DA-E09-04. Blocked by: DA-E06-07.

---

### DA-E09-02 — Write init-postgres.sql (create tables + seed subscription plans)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Produce the PostgreSQL initialization script that creates the complete schema and seed data so that `docker-compose up` results in a fully ready database without any manual setup steps. MongoDB is hosted on Atlas (cloud) — no local init script needed.

**Acceptance Criteria:**

- [ ] `init-postgres.sql` creates all 11 PostgreSQL tables with all constraints using `CREATE TABLE IF NOT EXISTS`
- [ ] Seeds 3 subscription plan rows: FREE (0 USD), PROFESSIONAL (49 USD/month), ENTERPRISE (199 USD/month)
- [ ] Script executes without errors when run against a fresh PostgreSQL 16 container

**Technical Notes:**

- Create the `pgcrypto` extension before table creation: `CREATE EXTENSION IF NOT EXISTS "pgcrypto";` — enables `gen_random_uuid()` as UUID default (no need for `uuid-ossp`)
- Create all ENUM types before table creation
- Use `CREATE TYPE ... AS ENUM` with `IF NOT EXISTS` guard (PostgreSQL 14+) or wrap in DO block for compatibility
- Table creation order must respect FK dependencies: `users` → `workspaces` → `workspace_members`, `clients` → `subscription_plans` → `workspace_subscriptions` → `invoices` → `payments`
- `audit_logs` uses `bigserial` PK, not UUID

**Dependencies:** Blocks: DA-E09-01. Blocked by: DA-E06-03, DA-E06-04.

---

### DA-E09-03 — Write .env.example consolidating all environment variables across 6 services

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Produce a single `.env.example` file listing every environment variable required by all 6 services so that any developer can onboard by copying the file, filling in secrets, and running the stack.

**Acceptance Criteria:**

- [ ] `.env.example` includes variables for all 6 services grouped by service with comment headers
- [ ] Every variable has an inline comment explaining its purpose and an example or placeholder value (never a real secret)
- [ ] Variables include: all DB connection strings (PostgreSQL URL, Redis URL, ChromaDB URL, MongoDB Atlas URI), JWT secret, AES key, internal service key, all third-party API keys, all social platform credentials

**Technical Notes:**

- MongoDB Atlas URI format: `MONGODB_URI=mongodb+srv://<user>:<password>@<cluster>.mongodb.net/brandhub?retryWrites=true&w=majority` — không dùng `mongo:27017` local nữa
- Add a `# CAUTION: never commit the real .env file` warning comment at the top of `.env.example`; ensure `.env` is in `.gitignore` in every repo

**Dependencies:** Blocks: DA-E09-04, DA-E09-05, DA-E09-06, DA-E09-07, DA-E09-08, DA-E09-09, DA-E09-10. Blocked by: DA-E07-01, DA-E07-02.

---

### DA-E09-06 — Infrastructure + Business Service keys

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Generate và cung cấp toàn bộ keys thuộc phạm vi infrastructure và business-service để Trung tổng hợp vào `.env`.

**Acceptance Criteria:**

- [ ] Generate `JWT_SECRET` (min 256-bit): `openssl rand -hex 32`
- [ ] Generate `AES_SECRET_KEY` (exactly 32 chars): `openssl rand -hex 16`
- [ ] Generate `INTERNAL_SERVICE_KEY`: `openssl rand -hex 24`
- [ ] Set PostgreSQL credentials: `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`
- [ ] Set Redis password: `REDIS_PASSWORD`
- [ ] Set RabbitMQ credentials: `RABBITMQ_USERNAME`, `RABBITMQ_PASSWORD`
- [ ] Set pgAdmin credentials: `PGADMIN_DEFAULT_EMAIL`, `PGADMIN_DEFAULT_PASSWORD`
- [ ] Set AWS S3: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_S3_BUCKET`, `AWS_S3_REGION`

**Dependencies:** Blocks: DA-E09-03. Blocked by: DA-E02-04.

---

### DA-E09-07 — AI Service — LLM keys + Payment Gateway

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Cung cấp API keys cho LLM providers và xác nhận payment gateway để tổng hợp vào `.env`.

**Acceptance Criteria:**

- [ ] Cung cấp `GROQ_API_KEY` — lấy tại [console.groq.com](https://console.groq.com) → API Keys
- [ ] Cung cấp `ANTHROPIC_API_KEY` — lấy tại [console.anthropic.com](https://console.anthropic.com) → API Keys
- [ ] Xác nhận `LLM_PROVIDER` default (`groq` hay `anthropic`)
- [ ] Cung cấp `MONGODB_URI` từ Atlas — lấy tại Atlas → Cluster → Connect → Drivers
- [ ] Xác nhận payment gateway (VNPay / MoMo / Stripe) và cung cấp keys tương ứng:
  - VNPay: `VNPAY_TMN_CODE`, `VNPAY_HASH_SECRET`, `VNPAY_URL`, `VNPAY_RETURN_URL`
  - MoMo: `MOMO_PARTNER_CODE`, `MOMO_ACCESS_KEY`, `MOMO_SECRET_KEY`, `MOMO_REDIRECT_URL`, `MOMO_IPN_URL`
  - Stripe: `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`

**Dependencies:** Blocks: DA-E09-03. Blocked by: DA-E02-04.

---

### DA-E09-08 — AI Service — Image/Video Gen keys

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Cung cấp API keys cho image và video generation services để tổng hợp vào `.env`.

**Acceptance Criteria:**

- [ ] Cung cấp `STABILITY_AI_API_KEY` — lấy tại [platform.stability.ai](https://platform.stability.ai) → API Keys
- [ ] Cung cấp `GOOGLE_VEO_API_KEY` — lấy tại Google AI Studio hoặc Google Cloud Console → Credentials
- [ ] Xác nhận ChromaDB không cần auth thêm (mặc định không có token); nếu có thì cung cấp `CHROMADB_AUTH_TOKEN`

**Dependencies:** Blocks: DA-E09-03. Blocked by: DA-E02-04.

---

### DA-E09-09 — Publisher Service — Social Platform OAuth

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Tạo developer apps và cung cấp OAuth credentials cho 5 social platforms để tổng hợp vào `.env`.

**Acceptance Criteria:**

- [ ] Cung cấp `FACEBOOK_APP_ID` + `FACEBOOK_APP_SECRET` — lấy tại [developers.facebook.com](https://developers.facebook.com) → App → Settings → Basic
- [ ] Xác nhận `FACEBOOK_REDIRECT_URI` + `INSTAGRAM_REDIRECT_URI`
- [ ] Cung cấp `TIKTOK_CLIENT_KEY` + `TIKTOK_CLIENT_SECRET` — lấy tại [developers.tiktok.com](https://developers.tiktok.com) → Manage Apps
- [ ] Xác nhận `TIKTOK_REDIRECT_URI`
- [ ] Cung cấp `ZALO_APP_ID` + `ZALO_APP_SECRET` — lấy tại [developers.zalo.me](https://developers.zalo.me) → App → Settings
- [ ] Xác nhận `THREADS_REDIRECT_URI` (Threads dùng chung Facebook App)

**Dependencies:** Blocks: DA-E09-03. Blocked by: DA-E02-04.

---

### DA-E09-10 — Frontend — Google OAuth App

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Tạo Google OAuth 2.0 Client và cung cấp credentials cho cả frontend và backend để tổng hợp vào `.env`.

**Acceptance Criteria:**

- [ ] Tạo Google OAuth App tại [console.cloud.google.com](https://console.cloud.google.com) → APIs & Services → Credentials → Create OAuth 2.0 Client ID
- [ ] Cung cấp `GOOGLE_CLIENT_ID` — dùng cho cả business-service (verify token) và web-dashboard (OAuth button)
- [ ] Cung cấp `GOOGLE_CLIENT_SECRET` — backend only
- [ ] Xác nhận `GOOGLE_REDIRECT_URI` (ví dụ: `http://localhost:8080/api/v1/auth/oauth2/callback/google`)
- [ ] Xác nhận `VITE_API_BASE_URL` cho web-dashboard (gateway URL local: `http://localhost:8080`)

**Dependencies:** Blocks: DA-E09-03. Blocked by: DA-E02-04.

---

### DA-E09-04 — Write clone-all.sh script to clone all 7 repos locally with a single command

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Eliminate the manual multi-step repo cloning process so any new developer can set up the full local environment with a single script execution.

**Acceptance Criteria:**

- [ ] `clone-all.sh` clones all 7 repos from the GitHub Organization into sibling directories relative to the script's location
- [ ] Script is idempotent: if a repo directory already exists, it runs `git pull` on the existing clone instead of erroring
- [ ] Script prints the GitHub Organization URL and all 7 repo names being cloned so the developer can verify the correct source

**Technical Notes:**

- Make the GitHub Organization name a variable at the top of the script (e.g., `ORG="brandhub-capstone"`) so it can be updated in one place if the org is renamed
- Test the script on both macOS/Linux (bash) and Windows (Git Bash) since team members use different OSes

**Dependencies:** Blocks: None. Blocked by: DA-E09-01.

---

### DA-E09-05 — Write README.md for the infrastructure repo (step-by-step setup guide)

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Produce a clear, step-by-step setup guide in the brandhub-infrastructure README so that any team member or evaluator can get the full local stack running without asking for help.

**Acceptance Criteria:**

- [ ] README covers the complete setup sequence: prerequisites (Docker, Git, Java 21, Python 3.11, Node 20), clone step, `.env` configuration, `docker-compose up`, and verification steps
- [ ] Verification section includes the expected output or health check URL for each service (e.g., MongoDB: `mongosh --eval "db.runCommand({ping:1})"`, RabbitMQ management UI: `http://localhost:15672`)
- [ ] Troubleshooting section lists at least 3 common setup issues with their solutions (e.g., port conflicts, Docker memory limits, ChromaDB startup delay)

**Dependencies:** Blocks: None. Blocked by: DA-E09-03.

---

### DA-E09-11 — Create project cost sheet

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Produce a spreadsheet estimating the total cost of running BrandHub across all third-party services and infrastructure so the team has a clear budget picture for the capstone report and mentor review.

**Acceptance Criteria:**

- [ ] Sheet covers all paid/freemium services: Groq API, Anthropic API, Stability AI, Google Veo API, MongoDB Atlas, AWS S3, VPS/EC2 hosting
- [ ] Each row includes: Service name, Plan/Tier used, Unit price, Estimated monthly usage, Monthly cost (USD), Notes
- [ ] Includes a summary row with total estimated monthly cost at 3 scales: dev/test (team internal), demo (mentor presentation), production (1000 users/month)
- [ ] File saved to `brandhub-infrastructure/docs/` as `BrandHub_Cost_Sheet.xlsx` or Google Sheet link added to `docs/index.md`

**Technical Notes:**

- Groq: free tier 30 req/min — estimate based on avg content generation calls per user per day
- Stability AI: ~$0.002–$0.04/image depending on resolution
- Google Veo: check current pricing at Google AI Studio (may still be in preview/waitlist)
- MongoDB Atlas: M0 free tier sufficient for dev; M10 (~$57/month) for production estimate
- AWS S3: estimate storage (media files) + transfer cost separately

**Dependencies:** Blocks: None. Blocked by: DA-E09-03.

---

### DA-E09-12 — Register brandhub domain _(phát sinh, ngoài plan gốc)_

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Đăng ký domain thật cho BrandHub để phục vụ deploy, demo mentor và các redirect URI OAuth (Facebook, Google... cần domain public thay vì localhost).

**Acceptance Criteria:**

- [ ] Domain đăng ký xong, trỏ DNS cơ bản (A/CNAME record placeholder cho production sau này)
- [ ] Domain name cập nhật vào `.env.example` làm base cho các redirect URI

**Ghi chú:** Không có trong plan gốc — phát sinh vì OAuth flow (E12, E18, E19) cần domain thật để test callback, không chỉ localhost. Jira: DA-423, status In Progress.

**Dependencies:** Blocks: DA-E12-06, DA-E18-01, DA-E19-02. Blocked by: None.

---

### DA-E09-13 — Update diagram, DBML and HTML file for database _(phát sinh, ngoài plan gốc)_

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Cập nhật lại các diagram/DBML/HTML mô tả database sau khi schema thay đổi (users, workspaces, workspace_members, clients chuyển từ MongoDB sang PostgreSQL — xem `DA-E06-01_database-strategy.md`), để tài liệu khớp với schema thật.

**Acceptance Criteria:**

- [ ] `brandhub-dbml.dbml` phản ánh đúng 11 bảng PostgreSQL + 8 collection MongoDB hiện tại
- [ ] `db-ownership-diagram.html` và `brandhub-schema-diagram.html` cập nhật khớp DBML mới

**Ghi chú:** Bảo trì tài liệu sau quyết định đổi schema — không có trong plan gốc vì thay đổi schema xảy ra sau khi DA-E06-05 đã hoàn thành. Jira: DA-558, status In Review.

**Dependencies:** Blocks: None. Blocked by: DA-E06-01, DA-E06-05.

---

### DA-E10-01 — Write GitHub Actions workflow for business-service (mvn test + docker build + push to ghcr.io)

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Automate the build, test, and container publish pipeline for business-service so that every push to `develop` or `main` produces a verified, tagged Docker image in ghcr.io without manual intervention.

**Acceptance Criteria:**

- [ ] Workflow triggers on: push to `develop`, push to `main`, and pull_request targeting `develop`
- [ ] Workflow steps execute in order: checkout → set up Java 21 → `mvn test` → `docker build` → login to ghcr.io → `docker push` with tags `latest` and the commit SHA
- [ ] Workflow fails the entire pipeline if `mvn test` fails; Docker build and push steps are skipped on test failure

**Technical Notes:**

- Use `actions/setup-java@v4` with `distribution: 'temurin'` and `java-version: '21'`
- Cache Maven local repository with `actions/cache@v4` using key `${{ runner.os }}-maven-${{ hashFiles('**/pom.xml') }}` to reduce build time from ~4 min to ~1 min after first run
- ghcr.io image name must follow the pattern: `ghcr.io/{org}/{repo}:{tag}` — use `GITHUB_REPOSITORY` env var to construct this automatically

**Dependencies:** Blocks: None. Blocked by: DA-E02-02, DA-E02-03, DA-E02-04.

---

### DA-E10-02 — Write GitHub Actions workflow for publisher-service (mvn test + docker build + push)

**Assignee:** Phước (Publisher) | **Priority:** 🟡 High

**Goal:** Automate the CI/CD pipeline for publisher-service so that every merge to `develop` produces a tested and published container image, identical in structure to the business-service pipeline.

**Acceptance Criteria:**

- [ ] Workflow triggers on push to `develop`, push to `main`, and pull_request targeting `develop`
- [ ] All steps mirror DA-E10-01: Java 21 setup with Temurin, Maven test, Docker build, ghcr.io push with SHA tag and `latest`
- [ ] Maven cache is configured using the same key pattern as DA-E10-01 for consistency

**Technical Notes:**

- publisher-service pom.xml will include RabbitMQ test dependencies (`spring-amqp-test`); ensure the test phase does not attempt to connect to a real RabbitMQ instance by configuring an embedded or mocked broker in test scope
- Reuse the same workflow YAML structure from DA-E10-01 to minimize divergence; consider a shared reusable workflow (`.github/workflows/java-ci.yml`) in the org if the team wants to DRY the pattern

**Dependencies:** Blocks: None. Blocked by: DA-E02-02, DA-E02-03, DA-E02-04.

---

### DA-E10-03 — Write GitHub Actions workflow for ai-service (flake8 + pytest + docker build + push)

**Assignee:** Tuấn (AI) | **Priority:** 🟡 High

**Goal:** Automate the CI/CD pipeline for ai-service with Python-appropriate linting and testing steps so that code quality is enforced and images are published on every merge to `develop`.

**Acceptance Criteria:**

- [ ] Workflow triggers on push to `develop`, push to `main`, and pull_request targeting `develop`
- [ ] Workflow steps: checkout → setup Python 3.11 → `pip install -r requirements.txt` → `flake8 .` → `pytest` → docker build → ghcr.io push
- [ ] Workflow fails if either `flake8` or `pytest` fails; Docker steps are skipped on failure

**Technical Notes:**

- Use `actions/setup-python@v5` with `python-version: '3.11'` and cache pip dependencies with `actions/cache@v4` using key `${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}`
- Add a `.flake8` config file to the repo root with `max-line-length = 120` to avoid fighting the default 79-character limit on FastAPI/Pydantic code
- Mock all external AI API calls (Groq, Stability AI) in pytest using `unittest.mock.patch` or `respx` for httpx; never make real API calls in CI

**Dependencies:** Blocks: None. Blocked by: DA-E02-02, DA-E02-03, DA-E02-04.

---

### DA-E10-04 — Write GitHub Actions workflow for web-dashboard (eslint + tsc + vite build + deploy)

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Automate the frontend CI pipeline so that TypeScript errors and lint violations are caught on every PR and a production-ready Vite build is verified before merge.

**Acceptance Criteria:**

- [ ] Workflow triggers on push to `develop`, push to `main`, and pull_request targeting `develop`
- [ ] Workflow steps: checkout → setup Node 20 → `npm ci` → `npm run lint` (ESLint) → `npm run type-check` (tsc --noEmit) → `npm run build` (vite build)
- [ ] Workflow fails if any of lint, type-check, or build steps fail

**Technical Notes:**

- Use `actions/setup-node@v4` with `node-version: '20'` and cache npm with `cache: 'npm'` parameter
- Add `"type-check": "tsc --noEmit"` to `package.json` scripts if not already present — `vite build` does not perform full TypeScript type checking by default
- The deploy step is not in scope for this task; add a placeholder commented-out step so the workflow is ready for deployment configuration later

**Dependencies:** Blocks: None. Blocked by: DA-E02-02, DA-E02-03, DA-E02-04.

---

### DA-E10-05 — Set up branch protection rules (require 1 approval before merging into develop)

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Enforce a mandatory peer review gate on the `develop` branch across all 7 repositories so no unreviewed code can be merged into the integration branch.

**Acceptance Criteria:**

- [ ] Branch protection on `develop` in all 7 repos requires at least 1 approving review before merge
- [ ] "Dismiss stale pull request approvals when new commits are pushed" is enabled so approvals are not carried over after code changes
- [ ] Status checks (CI workflows from DA-E10-01 through DA-E10-04) are added as required checks where applicable

**Technical Notes:**

- Use a GitHub Organization ruleset to apply this consistently across all repos rather than configuring each repo individually; the ruleset can target branches matching the pattern `develop`
- Exempt the team leader account from the approval requirement on the infrastructure repo only (since some infrastructure commits may need emergency merges during initial setup)

**Dependencies:** Blocks: None. Blocked by: DA-E02-03, DA-E10-01, DA-E10-02, DA-E10-03, DA-E10-04, DA-E10-06.

---

### DA-E10-06 — Write GitHub Actions workflow for api-gateway (build + test + push Docker image)

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Add CI/CD pipeline for api-gateway so every push to `develop` automatically builds, tests, and pushes the Docker image — consistent with DA-E10-01 through DA-E10-04.

**Acceptance Criteria:**

- [ ] Workflow triggers on push to `develop` and pull_request targeting `develop`
- [ ] Steps: checkout → set up JDK 21 → Maven build + test (`mvn verify`) → build Docker image → push to container registry
- [ ] Workflow file saved at `.github/workflows/ci.yml` in `brandhub-api-gateway` repo

**Technical Notes:**

- Mirror the structure of DA-E10-01 (business-service workflow) — same JDK version, same Maven cache setup, same Docker build args
- Add `DOCKER_USERNAME` and `DOCKER_TOKEN` as GitHub repository secrets (same credentials as other services)

**Dependencies:** Blocks: DA-E10-05. Blocked by: DA-E11-06.

---

### DA-E11-01 — Initialize brandhub-api-gateway project with Spring Cloud Gateway

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Bootstrap the api-gateway Spring Boot project with the correct dependencies and base configuration so subsequent filter and routing tasks have a working project to build on.

**Acceptance Criteria:**

- [ ] Spring Boot 3 project is initialized with dependencies: `spring-cloud-starter-gateway`, `spring-boot-starter-data-redis-reactive`, `spring-boot-starter-actuator`, `jjwt-api` (JWT library)
- [ ] Application runs on port 8080 with `docker-compose up` and responds to `GET /actuator/health` with HTTP 200
- [ ] `application.yml` includes base configuration: server port, Redis connection (from env var), and a placeholder routes section

**Technical Notes:**

- Use Spring Cloud Gateway reactive (WebFlux-based), not the legacy MVC version — all filters must be implemented as `GatewayFilter` or `GlobalFilter` using Project Reactor types (`Mono`, `Flux`)
- Spring Cloud Gateway version must be compatible with Spring Boot 3: use the Spring Cloud 2023.x BOM (`spring-cloud.version=2023.0.x`) in `pom.xml`

**Dependencies:** Blocks: DA-E11-02, DA-E11-03, DA-E11-04, DA-E11-05, DA-E11-06. Blocked by: DA-E02-02.

---

### DA-E11-02 — Write JWT validation filter (verify RS256 token on every request, extract userId + role into X-User-Id and X-User-Role headers)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Implement the JWT validation GlobalFilter so that every request reaching a downstream service is guaranteed to carry verified user identity headers, and unauthenticated requests are rejected at the gateway.

**Acceptance Criteria:**

- [ ] Filter verifies the JWT signature using the RS256 public key loaded from a PEM file configured via environment variable
- [ ] On valid token: extracts `sub` (userId), `role`, and `workspaceId` claims and forwards them as `X-User-Id`, `X-User-Role`, and `X-Workspace-Id` headers to the downstream service
- [ ] On invalid or expired token: returns HTTP 401 with `ApiResponse` error body without forwarding the request
- [ ] Public paths (`/api/v1/auth/**`) bypass JWT validation and are passed through without a token

**Technical Notes:**

- Use `io.jsonwebtoken:jjwt-impl` and `jjwt-jackson` at version 0.12.x for RS256 verification; load the public key using `RsaKeyConvertor` from the PEM file on application startup, not per-request
- Check Redis `jwt:blacklist:{jti}` after signature validation but before forwarding — if the jti key exists in Redis, return 401 even if the signature is valid (this handles logout/token rotation)
- Store the RS256 public key path in `JWT_PUBLIC_KEY_PATH` environment variable; read with `@Value("${jwt.public-key-path}")` from application.yml binding

**Dependencies:** Blocks: DA-E11-03, DA-E11-04. Blocked by: DA-E11-01, DA-E05-06.

---

### DA-E11-03 — Write rate limiting filter using Redis (100 requests/minute/user, key: ratelimit:{userId}:{minute})

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Implement per-user rate limiting at the gateway layer using Redis so that no single user can exceed 100 requests per minute, protecting downstream services from abuse without application-layer changes.

**Acceptance Criteria:**

- [ ] Filter increments a Redis counter keyed `ratelimit:{userId}:{minute}` (where `{minute}` is `epoch_seconds / 60`) on every authenticated request
- [ ] If the counter exceeds 100 after increment, the filter returns HTTP 429 with `ApiResponse` error body and does not forward the request
- [ ] TTL of 60 seconds is set on the Redis key at creation using `INCR` then `EXPIRE` only on first increment, so keys expire automatically after the minute window passes

**Technical Notes:**

- Use the DA-E06-06 contract: Redis `INCR` followed by conditional `EXPIRE` only when the increment result is `1`. Do not use a Lua script for this task.
- The `{userId}` value in the key must come from the `X-User-Id` header set by the JWT validation filter (DA-E11-02); the rate limiting filter must run after the JWT filter in the filter chain
- Rate limit threshold must be externalized as a configuration property (`gateway.rate-limit.requests-per-minute=100`) so it can be changed without redeployment

**Dependencies:** Blocks: DA-E11-04. Blocked by: DA-E11-02, DA-E06-06.

---

### DA-E11-04 — Configure routing rules (map URL paths to correct downstream service)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Define all gateway routing rules so that every incoming request is forwarded to the correct downstream service with no manual URL management needed on the client side.

**Acceptance Criteria:**

- [ ] Routes are configured in `application.yml` for all downstream targets: `/api/v1/auth/**` and `/api/v1/**` → business-service:8081; ai-service routes are internal only (no gateway route)
- [ ] Each route applies the JWT validation filter and rate limiting filter in the correct order (JWT first, then rate limit)
- [ ] Public routes (`/api/v1/auth/**`) have the JWT filter explicitly disabled using a route-level predicate or filter exclusion

**Technical Notes:**

- Use Spring Cloud Gateway's `RewritePath` filter if the downstream service expects a different path prefix than what the gateway exposes
- Downstream service URIs must use Docker service hostnames (e.g., `http://business-service:8081`) configured via environment variable (`BUSINESS_SERVICE_URI`) rather than hardcoded values
- Add `/actuator/**` as a gateway-local route (no forwarding) so health checks work without auth

**Dependencies:** Blocks: DA-E11-05. Blocked by: DA-E11-02, DA-E11-03, DA-E07-01.

---

### DA-E11-05 — Write logging filter (log all inbound and outbound requests for debugging)

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Implement a GlobalFilter that logs request and response metadata for every gateway-processed request so developers can trace issues across services during local development and staging.

**Acceptance Criteria:**

- [ ] Filter logs inbound request: timestamp, HTTP method, path, `X-User-Id` header value (if present), and request ID (generated UUID if not provided by client)
- [ ] Filter logs outbound response: same request ID, downstream service URI, HTTP response status code, and total processing time in milliseconds
- [ ] Log level is `DEBUG` by default and can be set to `INFO` or `OFF` via `gateway.logging.level` configuration property without code changes

**Technical Notes:**

- Use `Ordered.LOWEST_PRECEDENCE` for the logging filter's order so it wraps all other filters and captures total end-to-end gateway processing time accurately
- Never log request bodies or Authorization headers — only log metadata to avoid accidentally persisting tokens or user content in log files
- Use `exchange.getResponse().beforeCommit()` or `then()` operator to hook into the response completion to capture the status code and calculate elapsed time

**Dependencies:** Blocks: None. Blocked by: DA-E11-04.

---

### DA-E11-06 — Write Dockerfile for api-gateway

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Produce a production-ready Dockerfile for api-gateway so `docker-compose up` can build and run the service without manual steps.

**Acceptance Criteria:**

- [ ] Dockerfile uses multi-stage build: stage 1 (`maven:3.9-eclipse-temurin-21`) runs `mvn package -DskipTests`, stage 2 (`eclipse-temurin:21-jre-alpine`) copies the fat JAR and runs it
- [ ] Final image exposes port 8080 and starts with `java -jar app.jar`
- [ ] `docker-compose.yml` in infrastructure repo already references this Dockerfile correctly — verify `docker-compose up api-gateway` builds and starts successfully

**Technical Notes:**

- Add `.dockerignore` in `brandhub-api-gateway` repo: exclude `target/`, `.git/`, `*.md` to keep build context small
- Set `JAVA_OPTS` env var in Dockerfile: `ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"` so JVM respects container memory limits

**Dependencies:** Blocks: DA-E10-06, DA-E11-02, DA-E11-03, DA-E11-04, DA-E11-05. Blocked by: DA-E11-01.

---

### DA-E11-07 — Write global error response handler for gateway

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Ensure all error responses from the gateway (JWT invalid, downstream service down, route not found) return the standard `ApiResponse` JSON format defined in DA-E07-04 instead of Spring's default Whitelabel error page.

**Acceptance Criteria:**

- [ ] `401 Unauthorized` (JWT missing/invalid/expired) returns `{ "success": false, "code": "UNAUTHORIZED", "message": "..." }`
- [ ] `403 Forbidden` (valid JWT but insufficient role) returns `{ "success": false, "code": "FORBIDDEN", "message": "..." }`
- [ ] `503 Service Unavailable` (downstream service unreachable) returns `{ "success": false, "code": "SERVICE_UNAVAILABLE", "message": "..." }`
- [ ] `404 Not Found` (no matching route) returns `{ "success": false, "code": "NOT_FOUND", "message": "Route not found" }`
- [ ] All error responses have `Content-Type: application/json`

**Technical Notes:**

- Implement by extending `DefaultErrorWebExceptionHandler` (WebFlux approach) — do NOT use `@ControllerAdvice` which is MVC-only and does not work with reactive gateway
- Register the custom handler as a `@Bean` with `@Order(Ordered.HIGHEST_PRECEDENCE)` to override Spring's default error handler

**Dependencies:** Blocks: None. Blocked by: DA-E11-02, DA-E07-04.

---

## Phase 2 — Infrastructure Setup (Sprint 4)

---

### DA-E12-01 — Implement Register API

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Create a secure user registration endpoint that validates email uniqueness and stores credentials hashed with bcrypt cost=12.

**Acceptance Criteria:**

- [ ] POST /api/v1/auth/register accepts {email, password, fullName} and returns 201 with userId
- [ ] Duplicate email returns 409 Conflict with descriptive error message
- [ ] Password is hashed using bcrypt with cost factor 12 before persisting to MongoDB
- [ ] Email format and password complexity (min 8 chars, at least 1 number) are validated with 400 on failure
- [ ] User document is saved with default role OWNER and isActive=true

**Technical Notes:**

- Use `BCryptPasswordEncoder(12)` bean — do not use the no-arg constructor (defaults to cost=10)
- Index `email` field in MongoDB with `unique: true` to enforce uniqueness at DB level
- Return generic error messages to avoid user enumeration attacks

**Dependencies:** Blocks: [DA-E12-02, DA-E13-01]. Blocked by: [None].

---

### DA-E12-02 — Implement Login API

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Authenticate users with email/password and issue a short-lived RS256 JWT access token plus a long-lived HttpOnly refresh token cookie.

**Acceptance Criteria:**

- [ ] POST /api/v1/auth/login accepts {email, password} and returns 200 with access token (15 min expiry) in response body
- [ ] Refresh token (30-day expiry) is set as HttpOnly, Secure, SameSite=Strict cookie named `refreshToken`
- [ ] Invalid credentials return 401 with no detail distinguishing email vs password failure
- [ ] JWT payload contains {sub: userId, role, workspaceId, jti} signed with RS256 private key
- [ ] jti is a UUID v4, unique per token issuance

**Technical Notes:**

- Load RSA private key from environment variable or Vault; never hard-code in source
- Use `java.util.UUID.randomUUID()` for jti generation
- `workspaceId` may be null for users not yet attached to a workspace; handle gracefully in downstream filters
- Library: `io.jsonwebtoken:jjwt-api` or `com.nimbusds:nimbus-jose-jwt`

**Dependencies:** Blocks: [DA-E12-03, DA-E12-04, DA-E14-01]. Blocked by: [DA-E12-01].

---

### DA-E12-03 — Implement Refresh Token API

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow clients to silently renew expired access tokens by presenting a valid refresh token cookie, without requiring re-login.

**Acceptance Criteria:**

- [ ] POST /api/v1/auth/refresh reads `refreshToken` HttpOnly cookie and returns a new access token (15 min) in response body
- [ ] Refresh token is validated for signature, expiry, and not present in Redis blacklist
- [ ] Stolen/replayed refresh tokens (already blacklisted) return 401 Unauthorized
- [ ] A new refresh token cookie with a fresh 30-day TTL is issued on each successful refresh (rolling refresh)
- [ ] Old refresh token's jti is added to Redis blacklist with TTL = remaining lifetime of the old token

**Technical Notes:**

- Key: `jwt:blacklist:{jti}` in Redis; value can be `"1"` — only existence matters
- Rolling refresh prevents refresh token from expiring on active users; document the trade-off (slightly extended exposure window)
- Do not rotate the refresh token if the old one is already expired — return 401 and force re-login

**Dependencies:** Blocks: [DA-E12-04]. Blocked by: [DA-E12-02].

---

### DA-E12-04 — Implement Logout API

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Invalidate the current session by blacklisting the access token's jti in Redis and clearing the refresh token cookie.

**Acceptance Criteria:**

- [ ] POST /api/v1/auth/logout requires a valid access token in Authorization header; returns 200
- [ ] Access token's jti is written to Redis key `jwt:blacklist:{jti}` with TTL equal to the access token TTL: 15 minutes
- [ ] Refresh token HttpOnly cookie is cleared (Set-Cookie with Max-Age=0)
- [ ] Subsequent requests using the blacklisted access token return 401
- [ ] Unauthenticated logout requests (no token) return 401, not 500

**Technical Notes:**

- Calculate remaining TTL: `jwtExpiry.toEpochMilli() - Instant.now().toEpochMilli()` in milliseconds, then convert to seconds for Redis `SETEX`
- If the access token is already expired, still attempt to clear the cookie but no need to blacklist an already-expired token
- The JWT filter must check Redis blacklist on every request, not just at logout

**Dependencies:** Blocks: [None]. Blocked by: [DA-E12-02, DA-E12-03].

---

### DA-E12-05 — Implement Forgot Password & Reset Password Flow

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow users to securely recover their account via a time-limited email link backed by a Redis token with 1-hour TTL.

**Acceptance Criteria:**

- [ ] POST /api/v1/auth/forgot-password accepts {email}; always returns 200 regardless of whether email exists (prevent enumeration)
- [ ] A cryptographically random token (UUID v4 or SecureRandom 32 bytes hex) is stored in Redis as `pwd:reset:{token}` → userId, TTL = 3600 seconds
- [ ] Reset link sent via email contains the token as a query param: `https://app.brandhub.io/reset-password?token={token}`
- [ ] POST /api/v1/auth/reset-password accepts {token, newPassword}; validates token exists in Redis, hashes new password with bcrypt cost=12, saves to MongoDB, deletes Redis key
- [ ] Expired or already-used tokens return 400 with "Token invalid or expired" message
- [ ] After successful reset, all existing refresh tokens for the user are invalidated (or flag lastPasswordChange and reject older tokens)

**Technical Notes:**

- Use `SecureRandom` not `Math.random()` for token generation
- Deleting the Redis key after use enforces single-use — do this atomically if possible
- Send email via JavaMailSender or an external provider (SendGrid/SES); use async `@Async` to not block the HTTP response
- Invalidating all sessions post-reset: store `lastPasswordChange` timestamp in User document and compare against token `iat` in the JWT filter

**Dependencies:** Blocks: [None]. Blocked by: [DA-E12-01].

---

### DA-E12-06 — Implement Google OAuth Login

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Enable users to sign in with their Google account via PKCE flow, auto-creating a local user record on first login.

**Acceptance Criteria:**

- [ ] GET /api/v1/auth/google returns a redirect URL to Google's authorization endpoint with code_challenge (PKCE S256) and a state value
- [ ] State is stored in Redis as `oauth:state:{state}` with 10-minute TTL before redirecting
- [ ] GET /api/v1/auth/google/callback validates state against Redis (returns 400 if missing/mismatched), exchanges code + code_verifier for tokens
- [ ] If Google email does not exist in MongoDB, a new User document is created (role=OWNER, no password field)
- [ ] On success, issues the same JWT access token + refresh cookie as the standard login flow and redirects to frontend
- [ ] Existing email registered via password login is linked to the Google account (merge, not duplicate)

**Technical Notes:**

- Use `spring-security-oauth2-client` or manual HTTP calls via `RestClient` to Google's token endpoint
- PKCE: generate `code_verifier` (32 random bytes, Base64URL-encoded), `code_challenge = BASE64URL(SHA256(code_verifier))`
- Store `code_verifier` alongside state in Redis so it is available at callback time
- Google ID token (`id_token`) can be decoded without a second API call to get email + name + picture

**Dependencies:** Blocks: [None]. Blocked by: [DA-E12-01, DA-E12-02].

---

### DA-E12-07 — Research HS256 vs RS256 vs ES256 for JWT signing _(phát sinh, ngoài plan gốc)_

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Chốt thuật toán ký JWT trước khi code Auth (DA-E12-01 đến DA-E12-06) và JWT filter ở Gateway (DA-E11-02), vì DA-E11-02 đã giả định RS256 nhưng chưa có task nào chính thức quyết định điều này.

**Acceptance Criteria:**

- [ ] So sánh HS256 (symmetric) vs RS256/ES256 (asymmetric) về: khả năng verify token ở Gateway mà không cần chia sẻ secret với business-service, performance, độ phức tạp key rotation
- [ ] Quyết định cuối cùng + lý do ghi vào ADR hoặc note trong `DA-E05-05` (Architecture Decision Records)

**Ghi chú:** Task lẽ ra nên đứng **trước** DA-E12-01 và DA-E11-02 (cả hai đều phụ thuộc kết quả nghiên cứu này), nhưng phát sinh muộn trên Jira sau khi DA-E11-02 đã viết sẵn giả định RS256. Không đổi thứ tự numbering để tránh xáo trộn — chỉ note dependency ngược tại đây. Jira: DA-560, status In Review.

**Dependencies:** Blocks: DA-E12-01, DA-E12-02, DA-E12-03, DA-E11-02 (retroactive — các task này đã implement trước khi task nghiên cứu này xong). Blocked by: None.

---

### DA-E12-08 — Implement Change Password _(phát sinh, ngoài plan gốc)_

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Cho phép user đã đăng nhập tự đổi mật khẩu (khác với Forgot/Reset Password ở DA-E12-05, vốn dành cho user quên mật khẩu và chưa đăng nhập được).

**Acceptance Criteria:**

- [ ] `POST /api/v1/auth/change-password` yêu cầu access token hợp lệ (Authorization header)
- [ ] `ChangePasswordRequest` DTO nhận `currentPassword` + `newPassword`, validate `newPassword` theo cùng rule độ mạnh với Register
- [ ] Verify `currentPassword` khớp với hash hiện tại trước khi cho đổi (401/400 nếu sai)
- [ ] Hash `newPassword` bằng bcrypt cost=12, ghi đè password hiện tại
- [ ] Không tự động logout các session khác (out of scope — chỉ đổi password)

**Ghi chú:** Code đã implement và commit (`AuthController.changePassword`, `AuthService.changePassword`, `ChangePasswordRequest` DTO) nhưng commit message gắn nhầm key `DA-160` — DA-160 trên Jira thực chất là Forgot/Reset Password (DA-E12-05), một task khác. Không sửa lại commit cũ (đã push); task Jira mới này (DA-E12-08) là task đúng đại diện cho tính năng Change Password.

**Dependencies:** Blocks: [None]. Blocked by: [DA-E12-01, DA-E12-02].

---

### DA-E12-09 — Implement Facebook OAuth login _(phát sinh, ngoài plan gốc)_

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Cho phép user đăng nhập bằng tài khoản Facebook, dùng chung `OAuthController`/`OAuthService` backend-driven flow với Google OAuth (DA-E12-06) và GitHub OAuth (DA-E12-10).

**Acceptance Criteria:**

- [ ] `GET /api/v1/auth/oauth/facebook` redirect sang Facebook authorization URL
- [ ] `GET /api/v1/auth/oauth/facebook/callback` exchange code, tạo user mới nếu email chưa tồn tại, issue JWT + refresh cookie, redirect về FE `/oauth-callback?token=...`
- [ ] `OAuthProvider` enum có giá trị `FACEBOOK` (đã tồn tại từ trước)
- [ ] Existing email đăng ký qua password login được link với tài khoản Facebook (merge, không tạo duplicate)

**Technical Notes:**

- Dùng chung `OAuthController` unified endpoint `/api/v1/auth/oauth/{provider}` — không tạo controller riêng cho từng provider
- Cấu hình `OAuthProperties` cho `clientId`/`clientSecret`/`redirectUri` của Facebook trong `application.yml` + `.env`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E12-01, DA-E12-02].

---

### DA-E12-10 — Implement GitHub OAuth login _(phát sinh, ngoài plan gốc)_

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Cho phép user đăng nhập bằng tài khoản GitHub, dùng chung `OAuthController`/`OAuthService` backend-driven flow với Google OAuth (DA-E12-06) và Facebook OAuth (DA-E12-09).

**Acceptance Criteria:**

- [ ] `GET /api/v1/auth/oauth/github` redirect sang GitHub authorization URL
- [ ] `GET /api/v1/auth/oauth/github/callback` exchange code, tạo user mới nếu email chưa tồn tại, issue JWT + refresh cookie, redirect về FE `/oauth-callback?token=...`
- [ ] `OAuthProvider` enum bổ sung giá trị `GITHUB` (mới thêm trong thay đổi này)
- [ ] Existing email đăng ký qua password login được link với tài khoản GitHub (merge, không tạo duplicate)

**Technical Notes:**

- Dùng chung `OAuthController` unified endpoint `/api/v1/auth/oauth/{provider}` — không tạo controller riêng cho từng provider
- Cấu hình `OAuthProperties` cho `clientId`/`clientSecret`/`redirectUri` của GitHub trong `application.yml` + `.env`
- GitHub OAuth không trả email trực tiếp trong token response mặc định nếu user để private — cần gọi thêm `GET /user/emails` API của GitHub nếu email null từ profile response

**Dependencies:** Blocks: [None]. Blocked by: [DA-E12-01, DA-E12-02].

---

### DA-E12-11 — Implement Two-Factor Authentication (2FA, TOTP) _(phát sinh, ngoài plan gốc)_

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Cho phép user bật/tắt 2FA TOTP (RFC 6238), bắt buộc xác thực OTP sau login khi đã bật, dùng chung app authenticator chuẩn (Google Authenticator, Authy...).

**Acceptance Criteria:**

- [x] `POST /api/v1/auth/2fa/setup` sinh secret, lưu Redis `2fa:setup:{userId}` (TTL 10 phút), trả `qrCodeUrl` dạng `otpauth://totp/...`, KHÔNG trả secret thô ra response
- [x] `POST /api/v1/auth/2fa/confirm` verify code đúng với secret pending → set `twoFactorEnabled=true`, `totpSecret` lưu DB, xóa secret pending khỏi Redis
- [x] `POST /api/v1/auth/2fa/disable` verify code đúng → tắt 2FA, xóa `totpSecret`
- [x] Login khi 2FA bật → trả `twoFactorToken` (JWT riêng, TTL 5 phút, claim `type=2fa`), KHÔNG trả access/refresh token
- [x] `POST /api/v1/auth/2fa/verify` nhận `twoFactorToken` + code → verify TOTP, issue access+refresh token giống login thường
- [x] Time-step window ±1 (clock drift), Base32 secret, HMAC-SHA1, 6 digit, 30s step

**Technical Notes:**

- `TotpUtil` hand-rolled theo RFC 6238, không phụ thuộc thư viện ngoài
- Error codes: `TWO_FA_ALREADY_ENABLED`, `TWO_FA_NOT_ENABLED`, `TWO_FA_CODE_INVALID`, `TWO_FA_TOKEN_INVALID`

**Ghi chú:** Không có trong plan gốc — phát sinh từ audit toàn diện authentication (2026-09-18). Code đã implement (`AuthController` 4 endpoint `/2fa/*`, `AuthServiceImpl`, `TotpUtil`, `TwoFactorSetupResponse`). Docs: `docs/feature/authentication/3-2-7-two-factor-authentication-2fa-totp/{spec,plan,task,test}.md`. Jira: DA-1232, status In Review.

**Dependencies:** Blocks: [None]. Blocked by: [DA-E12-01, DA-E12-02].

---

### DA-E12-12 — Implement Deactivate Account _(phát sinh, ngoài plan gốc)_

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Cho phép user tự vô hiệu hóa tài khoản (soft-delete), chặn nếu đang là owner duy nhất của 1 Agency active.

**Acceptance Criteria:**

- [x] `POST /api/v1/auth/deactivate` yêu cầu access token + verify lại `password`
- [x] Password sai → 400 `WRONG_CURRENT_PASSWORD`
- [x] User là owner của Agency `status=ACTIVE` → chặn, 409 `AGENCY_OWNERSHIP_ACTIVE`, buộc transfer ownership trước khi được deactivate
- [x] Set `User.status=DEACTIVATED` — soft delete, không xóa cứng record User/Agency/Workspace
- [x] Sau deactivate, login trả 403 `ACCOUNT_DEACTIVATED`; refresh token cũng bị từ chối

**Technical Notes:**

- `AgencyRepository.findByOwnerId` (mới thêm) để check active agency ownership
- `checkStatus()` dùng chung trong `login`/`refresh`/2FA-`verify` để chặn account deactivated đồng nhất

**Ghi chú:** Không có trong plan gốc — phát sinh từ audit toàn diện authentication (2026-09-18). Code đã implement (`AuthController.deactivate`, `AuthServiceImpl.deactivate`, `DeactivateRequest` DTO, `ErrorCode.ACCOUNT_DEACTIVATED`/`AGENCY_OWNERSHIP_ACTIVE`). Docs: `docs/feature/authentication/3-2-9-deactivate-account/{spec,plan,task,test}.md`. Jira: DA-1233, status In Review.

**Dependencies:** Blocks: [None]. Blocked by: [DA-E12-01, DA-E12-02].

---

### DA-E12-13 — Implement OTP attempt lockout _(phát sinh, ngoài plan gốc)_

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Chặn brute-force mã OTP đăng ký/verify email — sai quá 5 lần thì hủy OTP hiện tại, buộc resend.

**Acceptance Criteria:**

- [x] Redis counter `otp:attempt:{email}` tăng mỗi lần sai code, TTL 10 phút (khớp OTP TTL)
- [x] Đạt 5 lần sai → xóa `otpCode`/`otpExpiry` của user, trả 400 `OTP_TOO_MANY_ATTEMPTS`
- [x] Verify đúng hoặc resend OTP → reset counter về 0
- [x] Rate-limit resend OTP (60s cooldown) trả đúng `RATE_LIMIT_EXCEEDED` (trước đó dùng nhầm mã `RESET_TOKEN_USED`)

**Technical Notes:**

- `ErrorCode.OTP_TOO_MANY_ATTEMPTS` (mới thêm)
- Áp dụng chung cho luồng Sign Up (DA-E12-01) và OTP Verification vì dùng chung hàm `verifyOtp()`

**Ghi chú:** Không có trong plan gốc — phát hiện qua audit test coverage (2026-09-18): spec/test.md đã ghi "sai 5 lần hủy session" nhưng code cũ chưa có giới hạn thử. Docs: `docs/feature/authentication/3-2-6-otp-verification/test.md`, `3-2-1-sign-up/test.md`. Jira: DA-1234, status In Review.

**Dependencies:** Blocks: [None]. Blocked by: [DA-E12-01].

---

### DA-E12-14 — Fix Logout/RequireUserId 500 error + Google OAuth bug _(phát sinh, ngoài plan gốc)_

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Fix 3 lỗi phát hiện qua audit toàn diện authentication — logout/requireUserId trả 500 thay vì lỗi có kiểm soát, Google OAuth flow không chạy được.

**Bugs fixed:**

- [x] `AuthServiceImpl.logout()` — access token hết hạn/tampered ném `JwtException` không bắt → 500. Fix: try/catch, trả 200 idempotent, vẫn revoke refresh token nếu có.
- [x] `AuthController.requireUserId()` — token hợp lệ nhưng subject không phải UUID (hoặc JWT lỗi) → `IllegalArgumentException`/`JwtException` không bắt → 500. Fix: catch → 401 `INVALID_CREDENTIALS`.
- [x] `GoogleOAuthService.fetchProfile()` — token exchange gửi JSON body, Google API yêu cầu `application/x-www-form-urlencoded` → luôn fail. Fix: dùng `MultiValueMap` + `MediaType.APPLICATION_FORM_URLENCODED`.

**Technical Notes:**

- `requireUserId()` là entrypoint chung cho mọi endpoint yêu cầu `Authorization: Bearer` (link/phone, set-password, 2FA, deactivate, me...) — fix áp dụng toàn bộ
- Bug OAuth liên quan trực tiếp DA-E12-06 (Google OAuth Login) — đây là fix cho flow đã implement ở đó, không phải feature mới

**Ghi chú:** Không có trong plan gốc — phát hiện qua audit test coverage cho ngoại lệ/unhappy-case (2026-09-18). Docs: `docs/feature/authentication/3-2-8-sign-out/test.md` (TC-02, TC-06), `3-2-3-sign-in-with-google-oauth/{spec,test}.md` (TC-05, TC-07). Jira: DA-1235, status In Review.

**Dependencies:** Blocks: [None]. Blocked by: [DA-E12-02, DA-E12-04, DA-E12-06].

---

### DA-E11-14 — Add all JPA models from database schema for business-service + repository layer _(phát sinh, ngoài plan gốc — gắn sai epic trên Jira)_

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Tạo toàn bộ JPA entity classes cho 11 bảng PostgreSQL (theo `brandhub-dbml.dbml`) và Spring Data JPA repository tương ứng cho từng entity, làm nền tảng data layer cho business-service trước khi code Auth/RBAC/Workspace.

**Acceptance Criteria:**

- [ ] 11 JPA entity classes tương ứng 11 bảng: `users`, `user_oauth_providers`, `user_refresh_tokens`, `workspaces`, `workspace_members`, `clients`, `subscription_plans`, `workspace_subscriptions`, `invoices`, `payments`, `audit_logs`
- [ ] Mỗi entity có Spring Data JPA `Repository` interface riêng
- [ ] Quan hệ FK ánh xạ đúng theo DBML (vd: `workspace_members` có FK tới `users` và `workspaces`)

**Ghi chú:** Trên Jira task này gắn vào epic E11 (API Gateway) — **gắn sai epic**, nội dung thực chất thuộc business-service data layer, hợp lý hơn nếu đặt trước E13 (User & Profile Management) hoặc epic riêng cho data layer. Giữ nguyên task ID `DA-E11-14` theo Jira để tra cứu ngược, nhưng vị trí trong doc đặt ở đây (trước E13) cho đúng logic phụ thuộc. Jira: DA-559, status Done.

**Dependencies:** Blocks: DA-E13-01, DA-E14-01, DA-E15-01, DA-E16-01, DA-E17-01. Blocked by: DA-E06-02, DA-E06-03.

---

### DA-E13-01 — Implement GET/PUT /api/v1/users/me

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Provide authenticated users with endpoints to view and update their own profile information.

**Acceptance Criteria:**

- [ ] GET /api/v1/users/me returns {userId, email, fullName, avatarUrl, role, workspaceId, createdAt} for the authenticated user
- [ ] PUT /api/v1/users/me accepts {fullName, timezone, notificationPreferences} and returns the updated profile
- [ ] Email field is NOT updatable via this endpoint (requires separate verification flow)
- [ ] userId is extracted from the JWT `sub` claim — never accepted as a request parameter
- [ ] 401 is returned when the Authorization header is missing or token is invalid/blacklisted

**Technical Notes:**

- Create a `UserProfileResponse` DTO; never return the password hash field
- Use a `@AuthenticationPrincipal` resolver or custom `HandlerMethodArgumentResolver` to inject the authenticated user from the SecurityContext
- Validate that `timezone` is a valid IANA timezone ID using `ZoneId.of()`

**Dependencies:** Blocks: [DA-E13-02]. Blocked by: [DA-E12-01, DA-E12-02, DA-E14-01].

---

### DA-E13-02 — Implement Avatar Upload

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Allow users to upload a profile avatar that is stored in S3 under a deterministic key and referenced by URL in their MongoDB document.

**Acceptance Criteria:**

- [ ] POST /api/v1/users/me/avatar accepts `multipart/form-data` with field `file`; returns 200 with {avatarUrl}
- [ ] File is uploaded to S3 key `avatars/{userId}/{timestamp}.{ext}` where timestamp is epoch millis and ext is derived from MIME type
- [ ] Only JPEG, PNG, and WebP are accepted; other types return 400
- [ ] File size is capped at 5 MB; larger uploads return 413
- [ ] After successful S3 upload, `avatarUrl` field in MongoDB User document is updated atomically
- [ ] Previous avatar file in S3 is deleted after the new one is confirmed uploaded

**Technical Notes:**

- Use AWS SDK v2 `S3AsyncClient` for non-blocking uploads; do not use deprecated v1 `AmazonS3`
- Derive extension from `ContentType` header, not the original filename (filename is untrusted user input)
- Generate a pre-signed URL for the response or make the S3 bucket path publicly readable via a CloudFront distribution
- Delete old avatar: retrieve old key from MongoDB before updating, then issue `DeleteObjectRequest` after update

**Dependencies:** Blocks: [None]. Blocked by: [DA-E13-01].

---

### DA-E13-03 — Implement Admin: GET /api/v1/admin/users

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Provide administrators with a paginated, filterable list of all users across the platform for oversight and moderation.

**Acceptance Criteria:**

- [ ] GET /api/v1/admin/users returns paginated list of users; supports query params: `page`, `size`, `role`, `isActive`, `search` (partial email/name match)
- [ ] Endpoint is restricted to ADMIN role; returns 403 for any other role
- [ ] Response includes {userId, email, fullName, role, workspaceId, isActive, createdAt, lastLoginAt}
- [ ] Password hash is never included in any response field
- [ ] Default page size is 20; maximum is 100

**Technical Notes:**

- Use Spring Data MongoDB `Pageable` with `MongoTemplate` for dynamic query building when multiple optional filters are combined
- `search` filter should use a MongoDB `$regex` with `$options: 'i'` on both email and fullName fields
- Requires `@RequireRole("ADMIN")` on the controller method (depends on DA-E14-01)

**Dependencies:** Blocks: [DA-E13-04]. Blocked by: [DA-E14-01].

---

### DA-E13-04 — Implement Admin: Ban/Suspend User

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Allow administrators to deactivate a user account immediately, invalidating all active sessions and notifying the user.

**Acceptance Criteria:**

- [ ] PUT /api/v1/admin/users/{userId}/ban sets `isActive=false` in MongoDB; returns 200
- [ ] All active refresh tokens for the target user are invalidated (set `lastBannedAt` timestamp and reject tokens issued before it in JWT filter)
- [ ] Banned user's access token is blacklisted in Redis if the jti is retrievable; otherwise rely on `lastBannedAt` check
- [ ] A notification email is sent to the banned user's email address with reason
- [ ] Attempting to ban an already-banned user returns 409 Conflict
- [ ] Attempting to ban an ADMIN account returns 403 Forbidden

**Technical Notes:**

- Full jti enumeration is not practical; use a `bannedAt` timestamp stored on the User document and add a check in the JWT filter: reject any token with `iat < user.bannedAt`
- Notification email should be sent asynchronously via `@Async` to avoid blocking the response
- Requires `@RequireRole("ADMIN")` on the controller method

**Dependencies:** Blocks: [None]. Blocked by: [DA-E13-03, DA-E14-01].

---

### DA-E13-05 — Refactor User.role to SystemRole Enum (V2 re-scope)

**Assignee:** Trung | **Priority:** 🟢 Medium

**Goal:** Replace the free-form String `role` field on `User` with a proper `SystemRole` enum (ADMIN/USER), cleanly separated from `MemberRole` (OWNER/MANAGER/CREATOR/CLIENT), which is scoped per Workspace and lives on `WorkspaceMember`, not on `User`.

**Acceptance Criteria:**

- [ ] `User.role` changed from `String` to `SystemRole` enum with values `ADMIN`, `USER`
- [ ] No existing API response contract changes (`role` field in `/api/v1/users/me` still returns the same string shape)
- [ ] All places reading `User.role` as a raw string are updated to use the enum
- [ ] Existing data migrated: any `User.role` value not matching `ADMIN`/`USER` defaults to `USER` with a warning logged

**Technical Notes:**

- Do not confuse this with `MemberRole` (`OWNER/MANAGER/CREATOR/CLIENT`) — that stays on `WorkspaceMember`, unaffected by this task
- This is an internal refactor only; no new endpoint

**Spec Reference:** `docs/ba/02-authentication-profile.md`, `docs/ba/10-roles-permissions-matrix.md` mục 1 "Bảng role hệ thống V2"

**Dependencies:** Blocks: [DA-E14-05]. Blocked by: [None].

---

### DA-E13-06 — Implement Client Profile (separate entity from User)

**Assignee:** Trung | **Priority:** 🟡 High

**Goal:** Introduce a `ClientProfile` entity, separate from `User`, so a user acting as CLIENT in one Agency's Workspace can reuse the same profile (`displayName`, `company`, `phone`, `note`) when invited as CLIENT into a different Agency's Workspace, without re-entering the data.

**Acceptance Criteria:**

- [ ] `ClientProfile` entity created with `linked_user_id` (nullable FK to User), `displayName`, `company`, `phone`, `note`
- [ ] `GET /api/v1/client-profile/me` returns 200 with the caller's Client Profile
- [ ] First-time CLIENT invite acceptance auto-creates the `ClientProfile` if none exists yet
- [ ] Subsequent CLIENT invites (different Agency) reuse the existing `ClientProfile` — verified with a 2-Agency test scenario
- [ ] A user who has never accepted a CLIENT invite receives 404 `CLIENT_PROFILE_NOT_FOUND`
- [ ] `ClientProfile` is independent of the regular User Profile (FR 3.3.1) — a user can hold both simultaneously

**Technical Notes:**

- `linked_user_id` is nullable per the V2 data model decision in `docs/ba/11-data-entities-glossary.md` — do not make this a required 1:1 FK
- This is a new PostgreSQL table, not a MongoDB collection (per `docs/database/schema-v2/database-strategy.md` split)

**Spec Reference:** `docs/feature/profile/3-3-3-view-client-profile/spec.md`, `docs/feature/profile/3-3-4-update-client-profile/spec.md`, `docs/ba/11-data-entities-glossary.md`

**Dependencies:** Blocks: [DA-E16-11]. Blocked by: [None].

---

### DA-E14-01 — Write @RequireRole Annotation and AOP Aspect

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Implement a declarative, annotation-driven role enforcement mechanism for all controller endpoints using Spring AOP.

**Acceptance Criteria:**

- [ ] `@RequireRole({"OWNER", "MANAGER"})` annotation is defined and applicable at method and class level
- [ ] An AOP `@Around` aspect intercepts all annotated methods and extracts the authenticated user's role from the SecurityContext
- [ ] Requests from users whose role is not in the allowed list receive 403 Forbidden with body `{error: "Insufficient permissions"}`
- [ ] Unauthenticated requests (no valid JWT) receive 401 before the aspect is evaluated
- [ ] Aspect is covered by unit tests validating allowed, denied, and unauthenticated scenarios

**Technical Notes:**

- Annotate the aspect with `@Aspect` and `@Component`; pointcut: `@annotation(requireRole)` to capture the annotation instance directly
- Extract role from `SecurityContextHolder.getContext().getAuthentication().getAuthorities()`
- Class-level `@RequireRole` should apply to all methods unless a method-level annotation overrides it (method takes precedence)
- Register the aspect before `@Transactional` in the proxy chain to avoid opening transactions for unauthorized requests

**Dependencies:** Blocks: [DA-E13-03, DA-E13-04, DA-E14-02, DA-E14-03, DA-E15-01, DA-E16-01]. Blocked by: [DA-E12-02].

---

### DA-E14-02 — Implement Workspace Isolation Filter

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Ensure every MongoDB query in business-service is automatically scoped to the authenticated user's workspaceId, preventing cross-tenant data leakage.

**Acceptance Criteria:**

- [ ] A Spring `HandlerInterceptor` or AOP aspect extracts `workspaceId` from the JWT and stores it in a `ThreadLocal` context holder
- [ ] All repository methods that query collection data accept or inject `workspaceId`; queries without it fail with a runtime exception
- [ ] Integration test confirms that a user from Workspace A cannot retrieve documents belonging to Workspace B even if they guess the document ID
- [ ] The filter is applied automatically — no developer needs to manually pass workspaceId in every service call
- [ ] Users with null workspaceId (newly registered, no workspace yet) receive 403 on any workspace-scoped endpoint

**Technical Notes:**

- Use a `WorkspaceContext` class with a static `ThreadLocal<String> workspaceId`; clear it in an `afterCompletion` hook to prevent thread pool leakage
- Alternatively, use Spring Security's `Authentication` object to carry workspaceId as a custom `GrantedAuthority` or principal attribute
- For MongoDB, apply the workspace filter using a `MongoTemplate` wrapper or a custom `@Query` base method on all repositories

**Dependencies:** Blocks: [DA-E14-03, DA-E15-01, DA-E16-01, DA-E16-04]. Blocked by: [DA-E14-01].

---

### DA-E14-03 — Implement Client Isolation for CLIENT Role

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Ensure users with the CLIENT role can only access data belonging to their own clientId, enforced at the query layer.

**Acceptance Criteria:**

- [ ] All MongoDB queries executed in a CLIENT session include both `workspaceId` and `clientId` filters
- [ ] A CLIENT user attempting to access another client's data receives 403 Forbidden, not 404 or 200
- [ ] `clientId` is stored in the User document and included in the JWT payload for CLIENT users
- [ ] Integration test verifies CLIENT user cannot read posts, analytics, or reports of a sibling client in the same workspace
- [ ] OWNER and MANAGER roles are NOT subject to the clientId filter (they see all clients in their workspace)

**Technical Notes:**

- Extend the `WorkspaceContext` holder from DA-E14-02 to also carry an optional `clientId`
- In the repository layer, check if the calling role is CLIENT and conditionally append the `clientId` filter — this can be done in a base repository method
- Consider a custom `@ClientScoped` annotation on repository methods that must enforce client isolation, making enforcement explicit and auditable

**Dependencies:** Blocks: [None]. Blocked by: [DA-E14-02].

---

### DA-E14-04 — Write Permission Matrix Document

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Document the complete access control matrix mapping all 6 roles to every API endpoint so the team has a single source of truth for RBAC decisions.

**Acceptance Criteria:**

- [ ] Document covers all 6 roles: ADMIN, OWNER, MANAGER, CREATOR, PUBLISHER, CLIENT
- [ ] Every API endpoint from epics E12–E24 is listed with allowed roles marked
- [ ] Document is stored in the project wiki or Confluence and linked from the main README
- [ ] Document is reviewed and signed off by Trung (Leader) before Sprint 6 begins
- [ ] Any discrepancy found between the document and code annotations is treated as a bug

**Dependencies:** Blocks: [None]. Blocked by: [DA-E14-01].

---

### DA-E14-05 — Implement Agency-level Permission Checks (V2 addition)

**Assignee:** Trung | **Priority:** 🟡 High

**Goal:** Extend the RBAC mechanism to cover Agency-level actions (delete Agency, invite/remove Agency Member, view all Workspaces under an Agency) which sit above the existing per-Workspace `MemberRole` checks.

**Acceptance Criteria:**

- [ ] Only the Agency's `owner_id` (1:1) may: delete the Agency, invite/remove Agency Members
- [ ] Agency Owner can list/view all Workspaces belonging to their Agency, regardless of their `MemberRole` in each individual Workspace
- [ ] An Agency Member (invited but with no Workspace role yet) has zero permissions beyond viewing the Agency they belong to
- [ ] Attempting an Agency-level action as a non-Owner returns 403

**Technical Notes:**

- This is a new permission layer, distinct from `@RequireRole(MemberRole...)` — needs a separate check (e.g. `@RequireAgencyOwner` or explicit `agency.getOwnerId().equals(currentUserId)` check in the service layer)
- Depends on the `Agency` entity existing (DA-E16-01)

**Spec Reference:** `docs/ba/01-organization-structure.md` mục 4 "Role gán theo Workspace — quy tắc cốt lõi", `docs/ba/10-roles-permissions-matrix.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E16-01, DA-E13-05].

---

### DA-E14-06 — Update Permission Matrix Document for 2-tier RBAC (V2)

**Assignee:** Trung | **Priority:** 🟢 Medium

**Goal:** Update the Permission Matrix Document (DA-E14-04) to reflect the V2 two-tier authorization model: Agency-level permissions (Owner-only actions) layered on top of the existing per-Workspace `MemberRole` permissions.

**Acceptance Criteria:**

- [ ] Document distinguishes Agency-level rows from Workspace-level rows explicitly (not mixed in one flat table)
- [ ] Covers all endpoints from E16 (Agency & Client), E50 (Media Package/Campaign), E51 (Task workflow) in addition to the original E12–E24 scope
- [ ] Reviewed and signed off before implementation of DA-E14-05 is considered complete

**Technical Notes:** This is documentation only, no code change.

**Spec Reference:** `docs/ba/10-roles-permissions-matrix.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E14-05].

---

### DA-E15-01 — Implement POST /api/v1/workspaces

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow OWNER users to create a new workspace, which becomes the top-level container for all their clients and team members.

**Acceptance Criteria:**

- [ ] POST /api/v1/workspaces accepts {name, timezone, defaultPlatforms} and returns 201 with the created workspace document
- [ ] Only users with role OWNER may call this endpoint; others receive 403
- [ ] A user who already has a workspace receives 409 Conflict (one workspace per OWNER)
- [ ] Creator is automatically added as the first member of the workspace with OWNER membership
- [ ] Created workspace document includes: {workspaceId, name, ownerId, timezone, defaultPlatforms, createdAt, memberCount: 1}

**Technical Notes:**

- After workspace creation, update the User document to set `workspaceId` and re-issue tokens (or instruct the client to call the refresh endpoint so the new workspaceId appears in the JWT)
- Validate `timezone` with `ZoneId.of()` and `defaultPlatforms` against an enum {FACEBOOK, INSTAGRAM, TIKTOK, THREADS, ZALO}

**Dependencies:** Blocks: [DA-E15-02, DA-E15-03, DA-E16-01]. Blocked by: [DA-E14-01, DA-E14-02].

---

### DA-E15-02 — Implement GET /api/v1/workspaces/mine

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow any authenticated workspace member to retrieve the details of their current workspace.

**Acceptance Criteria:**

- [ ] GET /api/v1/workspaces/mine returns workspace document for the workspaceId embedded in the JWT
- [ ] Response includes {workspaceId, name, ownerId, timezone, defaultPlatforms, memberCount, currentPlan, createdAt}
- [ ] Users with null workspaceId in their JWT receive 404 with "No workspace found"
- [ ] Response is accessible to all roles within the workspace (not restricted by role)
- [ ] workspaceId is extracted from JWT only, never from a query parameter

**Technical Notes:**

- `currentPlan` should be joined from the Subscription collection; use a single MongoDB aggregation or two separate queries — avoid N+1
- Cache this response in Redis for 60 seconds with key `workspace:mine:{workspaceId}` to reduce DB load; invalidate on workspace settings update

**Dependencies:** Blocks: [DA-E15-03, DA-E15-05]. Blocked by: [DA-E15-01].

---

### DA-E15-03 — Implement POST /api/v1/workspaces/{id}/members

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Enable workspace owners to invite new members by email, sending an invitation link and provisioning their account with the correct role.

**Acceptance Criteria:**

- [ ] POST /api/v1/workspaces/{id}/members accepts {email, role} where role is one of MANAGER, CREATOR, PUBLISHER, CLIENT
- [ ] Only OWNER of that workspace may call this endpoint; 403 otherwise
- [ ] If the email is already a registered user, they are added to the workspace and notified via email
- [ ] If the email is not yet registered, a pending invitation record is created and an invitation email with a signup link is sent
- [ ] Inviting an email already in the workspace returns 409 Conflict
- [ ] Member count on the workspace document is incremented atomically

**Technical Notes:**

- Invitation token stored in Redis: `workspace:invite:{token}` → {workspaceId, email, role}, TTL = 7 days
- Use MongoDB `$inc` operator to increment `memberCount` atomically
- Subscription plan client limits apply: check current client count against plan limits before adding a CLIENT role member

**Dependencies:** Blocks: [DA-E15-04]. Blocked by: [DA-E15-01, DA-E17-01].

---

### DA-E15-04 — Implement DELETE /api/v1/workspaces/{id}/members/{userId}

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Allow workspace owners to remove a member from their workspace, revoking their access immediately.

**Acceptance Criteria:**

- [ ] DELETE /api/v1/workspaces/{id}/members/{userId} removes the member and returns 204 No Content
- [ ] Only OWNER of that specific workspace may perform this action; 403 otherwise
- [ ] Removing the workspace owner themselves returns 400 Bad Request
- [ ] Removed user's active JWT sessions are invalidated using the `lastBannedAt`-style timestamp approach (set `removedFromWorkspaceAt`, reject tokens with workspaceId in JWT that were issued before this timestamp)
- [ ] Member count on the workspace document is decremented atomically

**Technical Notes:**

- Set `workspaceId = null` on the removed User document so they lose workspace context on next token refresh
- Clearing workspaceId from the User document is sufficient if the JWT filter validates workspaceId against the current User document on each request (adds a DB read per request — weigh against the alternative of short token lifetime)

**Dependencies:** Blocks: [None]. Blocked by: [DA-E15-03].

---

### DA-E15-05 — Implement Workspace Settings

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Allow workspace owners to configure workspace-level defaults such as timezone, default social platforms, and report frequency.

**Acceptance Criteria:**

- [ ] PUT /api/v1/workspaces/{id}/settings accepts {timezone, defaultPlatforms, reportFrequency} and returns 200 with updated settings
- [ ] Only OWNER of the workspace may update settings; 403 otherwise
- [ ] `timezone` must be a valid IANA timezone string; invalid values return 400
- [ ] `defaultPlatforms` must be a subset of {FACEBOOK, INSTAGRAM, TIKTOK, THREADS, ZALO}; invalid values return 400
- [ ] `reportFrequency` must be one of {WEEKLY, MONTHLY}; invalid value returns 400
- [ ] Redis cache for workspace (from DA-E15-02) is invalidated on successful update

**Technical Notes:**

- Use `ZoneId.of(timezone)` inside a try-catch `DateTimeException` to validate timezone
- Store `defaultPlatforms` as an enum list in MongoDB; validate using `@ValidPlatforms` custom constraint annotation for clean controller code

**Dependencies:** Blocks: [None]. Blocked by: [DA-E15-02].

---

### DA-E16-01 — Implement POST /api/v1/clients

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow OWNER to create a new client record within their workspace, subject to the subscription plan's client limit.

**Acceptance Criteria:**

- [ ] POST /api/v1/clients accepts {brandName, industry, logoUrl, contactEmail, allowedPlatforms} and returns 201 with the created client record
- [ ] Only OWNER may create clients; 403 otherwise
- [ ] Current client count is checked against the subscription plan limit before creation; exceeding the limit returns 403 with {error: "Client limit reached", upgradeUrl}
- [ ] Created client document includes: {clientId, workspaceId, brandName, industry, logoUrl, contactEmail, allowedPlatforms, createdAt}
- [ ] `workspaceId` is injected from the JWT, never accepted from the request body

**Technical Notes:**

- Client count check + insert should be wrapped in a logical transaction; since MongoDB single-document atomicity does not span collections, use an optimistic lock or a counter field on the Workspace document with `$inc` and conditional update
- Subscription plan limit lookup: query the active subscription for the workspace, then fetch the plan's `maxClients` field

**Dependencies:** Blocks: [DA-E16-02, DA-E16-03, DA-E16-04]. Blocked by: [DA-E14-01, DA-E14-02, DA-E15-01, DA-E17-01].

---

### DA-E16-02 — Implement PUT /api/v1/clients/{id}/assign

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow OWNER to assign a Manager to a client, establishing the primary relationship for that client's day-to-day management.

**Acceptance Criteria:**

- [ ] PUT /api/v1/clients/{id}/assign accepts {accountManagerId} and returns 200 with updated client document
- [ ] Only OWNER may perform assignment; 403 otherwise
- [ ] The target userId must exist in the same workspace and have role MANAGER; invalid targets return 400
- [ ] The client document must belong to the caller's workspaceId; mismatched workspaceId returns 404 (do not leak existence)
- [ ] Re-assigning an already-assigned client replaces the previous Manager without error

**Technical Notes:**

- Workspace isolation filter (DA-E14-02) must be active; the query for the client record will automatically include `workspaceId`
- After assignment, notify the new Manager by email with client brand name and a link to the client dashboard

**Dependencies:** Blocks: [None]. Blocked by: [DA-E16-01, DA-E14-02].

---

### DA-E16-03 — Implement PUT /api/v1/clients/{id}/service-package

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Allow OWNER to configure monthly post limits and permitted social platforms for each individual client.

**Acceptance Criteria:**

- [ ] PUT /api/v1/clients/{id}/service-package accepts {monthlyPostLimit, allowedPlatforms} and returns 200 with updated client record
- [ ] Only OWNER may update service packages; 403 otherwise
- [ ] `monthlyPostLimit` must be a positive integer; negative or zero values return 400
- [ ] `allowedPlatforms` must be a non-empty subset of {FACEBOOK, INSTAGRAM, TIKTOK, THREADS, ZALO}; invalid values return 400
- [ ] Client must belong to the caller's workspace; otherwise 404

**Technical Notes:**

- The `monthlyPostLimit` set here acts as a per-client cap, separate from the workspace-level plan limit; both limits must be respected when creating posts
- Store `allowedPlatforms` as an enum list; validate using a custom constraint or `@Valid` with a Set<Platform> field

**Dependencies:** Blocks: [None]. Blocked by: [DA-E16-01].

---

### DA-E16-04 — Implement GET /api/v1/clients

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Provide OWNER and MANAGER roles with a filtered, paginated list of clients in their workspace.

**Acceptance Criteria:**

- [ ] GET /api/v1/clients returns paginated list of clients scoped to the JWT's workspaceId
- [ ] OWNER sees all clients in the workspace; MANAGER sees only clients assigned to them
- [ ] Supports query params: `page`, `size`, `search` (partial brandName match), `platform` (filter by allowedPlatforms)
- [ ] CLIENT role receives 403 on this endpoint (they use a different profile endpoint)
- [ ] Default page size is 20; maximum 100

**Technical Notes:**

- MANAGER filter: add `assignedAccountManagerId = currentUserId` condition alongside `workspaceId` filter — handled in the service layer by inspecting the caller's role
- Use `MongoTemplate` with a dynamic `Criteria` chain for combining optional filters cleanly

**Dependencies:** Blocks: [None]. Blocked by: [DA-E16-01, DA-E14-02].

---

### DA-E16-05 — Create Agency Entity (V2, new domain)

**Assignee:** Trung | **Priority:** 🔴 Critical

**Goal:** Introduce the `Agency` entity — the top-level organizational unit of V2 — which does not exist in the current codebase at all.

**Acceptance Criteria:**

- [ ] `Agency` table/entity: `id`, `name`, `description`, `logoUrl`, `ownerId` (1:1 FK to User, immutable after creation), `status` (ACTIVE/SOFT_DELETED), `deletedAt`
- [ ] Repository layer with standard CRUD methods
- [ ] No transfer-of-ownership mechanism (explicitly out of scope per BA)

**Technical Notes:** This is pure foundation — no endpoint yet, just entity + repository. Endpoints follow in DA-E16-06..09.

**Spec Reference:** `docs/ba/01-organization-structure.md` mục 2 "Agency", `docs/ba/11-data-entities-glossary.md`

**Dependencies:** Blocks: [DA-E16-06, DA-E16-07, DA-E16-08, DA-E16-09, DA-E14-05, DA-E50-01]. Blocked by: [None].

---

### DA-E16-06 — Implement POST /api/v1/agencies (Create Agency)

**Assignee:** Trung | **Priority:** 🔴 Critical

**Goal:** Allow a User to create a new Agency, automatically becoming its Owner.

**Acceptance Criteria:**

- [ ] `POST /api/v1/agencies` accepts `{name, description?, logoUrl?}`, returns 201 with `{id, name, ownerId}`
- [ ] `ownerId` is set to the calling user's id from the JWT — never accepted from the request body
- [ ] Empty `name` returns 400 `VALIDATION_ERROR`
- [ ] No limit on number of Agencies a User can own in this FR's scope (may later be capped by Subscription Plan — see E17, needs confirmation at design time)

**Technical Notes:** Consider whether Agency count should be checked against `UserSubscription` limits here or left for a later constraint (per spec, not yet confirmed).

**Spec Reference:** `docs/feature/agency-workspace/3-4-3-create-agency/spec.md`, `docs/ba/03-agency-workspace-management.md`

**Dependencies:** Blocks: [DA-E16-07, DA-E16-08, DA-E16-09]. Blocked by: [DA-E16-05].

---

### DA-E16-07 — Implement Agency Profile View/Update + List Mine

**Assignee:** Trung | **Priority:** 🟡 High

**Goal:** Let a User view all Agencies they own, and view/update a given Agency's profile.

**Acceptance Criteria:**

- [ ] `GET /api/v1/agencies/mine` returns all Agencies owned by the caller
- [ ] `GET /api/v1/agencies/{id}` returns the Agency's public profile (name, description, logoUrl)
- [ ] `PUT /api/v1/agencies/{id}` allows the Owner to update `name`, `description`, `logoUrl`
- [ ] Non-owner attempting to update returns 403

**Spec Reference:** `docs/feature/agency-workspace/3-4-1-list-agency/spec.md`, `docs/feature/agency-workspace/3-4-2-view-agency-dashboard/spec.md`, `docs/feature/agency-workspace/3-4-4-view-agency-profile/spec.md`, `docs/feature/agency-workspace/3-4-5-update-agency-profile/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E16-06].

---

### DA-E16-08 — Implement DELETE /api/v1/agencies/{id} (Soft-delete + Restore)

**Assignee:** Trung | **Priority:** 🟡 High

**Goal:** Allow the Owner to soft-delete an Agency (with a 30-day restore window), cascading `inactive` status to all child Workspaces.

**Acceptance Criteria:**

- [ ] `DELETE /api/v1/agencies/{id}` sets `status=SOFT_DELETED`, `deletedAt=now()`; returns 200
- [ ] All child Workspaces transition to `inactive` in the same operation
- [ ] `POST /api/v1/agencies/{id}/restore` restores the Agency AND all its Workspaces to their prior state, only within 30 days of `deletedAt`
- [ ] Restore attempted after 30 days returns 410 `RESTORE_WINDOW_EXPIRED`
- [ ] Non-owner attempting delete/restore returns 403

**Technical Notes:** Hard-delete after 30 days is a separate scheduled cleanup job, out of scope for this task (per BA, "thiết kế kỹ thuật riêng").

**Spec Reference:** `docs/feature/agency-workspace/3-4-6-remove-agency/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E16-06, DA-E16-09 (for cascading Workspace agency_id link)].

---

### DA-E16-09 — Entity AgencyMember + Invite/Remove Member Flow

**Assignee:** Trung | **Priority:** 🟡 High

**Goal:** Implement the Agency membership layer: a junction entity with NO role column (role only exists at the Workspace level), plus invite-by-email (3-day expiry) and remove-member flows.

**Acceptance Criteria:**

- [ ] `AgencyMember` junction entity: `agencyId`, `userId`, `joinedAt` — explicitly no `role` column
- [ ] `POST /api/v1/agencies/{id}/invitations` accepts `{email}`, creates an invitation expiring in 3 days, sends email + in-app notification
- [ ] Email already an Agency Member returns 409 `ALREADY_MEMBER`
- [ ] Invited email with no existing User account still receives the invite; auto-accepted on registration with that same email
- [ ] `DELETE /api/v1/agencies/{id}/members/{memberId}` removes the `AgencyMember` record — member instantly loses access to ALL Workspaces of that Agency
- [ ] Resources the removed member created (Task, Material, Content...) are NOT deleted — they remain Agency/Workspace property
- [ ] Re-inviting a previously removed member restores their ability to use resources they created before
- [ ] Attempting to remove the Owner returns 409 `CANNOT_REMOVE_OWNER`
- [ ] In-progress Tasks assigned to a removed member are NOT auto-unassigned (manual reassignment by Manager required)

**Technical Notes:** Invitation expiry can reuse the same pattern as Workspace invitations if one already exists in the codebase (check `WorkspaceInvitation`-equivalent before writing from scratch).

**Spec Reference:** `docs/feature/agency-workspace/3-4-7-invite-agency-member/spec.md`, `docs/feature/agency-workspace/3-4-8-view-agency-invitation-status/spec.md`, `docs/feature/agency-workspace/3-4-9-remove-member/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E16-06].

---

### DA-E16-10 — Add agency_id FK to Workspace (close E15 gap)

**Assignee:** Trung | **Priority:** 🔴 Critical

**Goal:** Close a gap confirmed across two code audits: `Workspace` currently only has `ownerId`, with no link to the `Agency` it belongs to — meaning the core V2 hierarchy (Agency → N Workspaces) cannot be represented at the data level yet.

**Acceptance Criteria:**

- [ ] `Workspace.agencyId` (FK, NOT NULL) added
- [ ] `GET /api/v1/agencies/{id}` and related Agency views can now correctly list "all Workspaces under this Agency"

**Technical Notes:** **[CONFIRMED 2026-09-15, Trung]** No real dev/staging data to preserve — dev DB can be dropped/recreated as needed, no careful backfill migration required. Just add the FK as NOT NULL directly.

**Spec Reference:** `docs/ba/01-organization-structure.md` mục 1 "Mô hình tổng quan", `docs/database/schema-v2/database-strategy.md`

**Dependencies:** Blocks: [DA-E16-07 (accurate "all workspaces" listing)]. Blocked by: [DA-E16-05].

---

### DA-E16-11 — Client Profile Reuse Across Agencies (link to DA-E13-06)

**Assignee:** Trung | **Priority:** 🟡 High

**Goal:** Ensure the `Client.java` entity correctly links to the `ClientProfile` introduced in DA-E13-06, so a Client's profile data is shared/reused when the same person is invited as CLIENT into a different Agency's Workspace.

**Acceptance Criteria:**

- [ ] `Client` entity references `ClientProfile` (via `linked_user_id` or equivalent) instead of duplicating profile fields per-Workspace
- [ ] Verify with a 2-Agency test: the same Client sees identical `displayName`/`company`/`phone`/`note` regardless of which Agency's Workspace they are viewing from

**Technical Notes:** `Client.java` already exists with a full Controller/Service (confirmed via code audit) — this task is about wiring it to `ClientProfile`, not building Client from scratch.

**Spec Reference:** `docs/feature/profile/3-3-3-view-client-profile/spec.md`, `docs/feature/profile/3-3-4-update-client-profile/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E13-06].

---

### DA-E16-12 — Implement Save Workspace Template

**Assignee:** Trung | **Priority:** 🟢 Medium

**Goal:** Allow an Owner to save an existing Workspace's configuration as a reusable Template for faster setup of future Workspaces.

**Acceptance Criteria:**

- [ ] `POST /api/v1/workspaces/{id}/save-as-template` accepts `{templateName}`, returns 201 with `{templateId}`
- [ ] Template captures basic config (not specific Members/Clients) — e.g. Media Package template used
- [ ] `GET /api/v1/agencies/{id}/workspace-templates` lists all templates for the Agency
- [ ] Template survives deletion of the original Workspace it was based on (independent record)
- [ ] Non-owner attempting to save a template returns 403

**Spec Reference:** `docs/feature/agency-workspace/3-4-17-save-workspace-template/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E16-06].

---

### DA-E17-01 — Implement Admin CRUD for Subscription Plans

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow platform administrators to manage subscription plan definitions (Free, Basic, Pro, Enterprise) including their pricing and feature limits.

**Acceptance Criteria:**

- [ ] POST /api/v1/admin/plans creates a plan with {name, priceUsd, maxClients, maxPostsPerMonth, maxAiCredits, stripePriceId}; returns 201
- [ ] GET /api/v1/admin/plans returns all plans; GET /api/v1/plans returns publicly visible plans (no admin auth required)
- [ ] PUT /api/v1/admin/plans/{id} updates plan details; DELETE /api/v1/admin/plans/{id} soft-deletes (isActive=false)
- [ ] All admin plan endpoints require ADMIN role; 403 otherwise
- [ ] Plan names must be unique; duplicate name on create returns 409

**Technical Notes:**

- Seed the four default plans on application startup using a `CommandLineRunner` or Liquibase/Mongock migration script — check if they exist before inserting
- Plans: Free ($0, 1, 10, 20 AI credits), Basic ($29, 5, 50, 100), Pro ($79, 20, 200, 500), Enterprise ($199, unlimited — store as -1 for unlimited)
- `stripePriceId` maps to the corresponding Stripe recurring price; must be set before the subscribe endpoint goes live

**Dependencies:** Blocks: [DA-E15-03, DA-E16-01, DA-E17-02]. Blocked by: [DA-E14-01].

---

### DA-E17-02 — Implement POST /api/v1/subscriptions/subscribe

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow OWNER to initiate a plan subscription by creating a Stripe Checkout session and recording the pending subscription intent.

**Acceptance Criteria:**

- [ ] POST /api/v1/subscriptions/subscribe accepts {planId} and returns 200 with {checkoutUrl} to redirect the user to Stripe
- [ ] Only OWNER may subscribe; 403 for other roles
- [ ] Creates a Stripe Customer if one does not already exist for this workspace; stores `stripeCustomerId` on the Workspace document
- [ ] Stripe Checkout session is created with `mode=subscription`, the plan's `stripePriceId`, and a success/cancel redirect URL
- [ ] Subscription is NOT activated until the Stripe webhook confirms payment (DA-E17-03 handles this)

**Technical Notes:**

- Use Stripe Java SDK (`com.stripe:stripe-java`); initialize with secret key from environment variable
- Set `metadata: {workspaceId}` on the Stripe Checkout session so the webhook can identify the workspace
- Never store raw card details; Stripe Checkout handles PCI compliance

**Dependencies:** Blocks: [DA-E17-03]. Blocked by: [DA-E17-01].

---

### DA-E17-03 — Implement Stripe Payment Webhook Flow

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Handle Stripe webhook events to activate, update, or cancel subscriptions in MongoDB based on confirmed payment events.

**Acceptance Criteria:**

- [ ] POST /api/v1/webhooks/stripe verifies Stripe-Signature header using the webhook secret; invalid signature returns 400
- [ ] `checkout.session.completed` event activates the subscription: creates Subscription document with {workspaceId, planId, stripeCustomerId, stripeSubscriptionId, status: ACTIVE, currentPeriodEnd}
- [ ] `invoice.payment_failed` event sets subscription status to PAST_DUE and notifies the OWNER by email
- [ ] `customer.subscription.deleted` event sets subscription status to CANCELLED and downgrades workspace to Free plan limits
- [ ] Webhook endpoint does not require JWT authentication (it is called by Stripe, not the user)
- [ ] Idempotency: duplicate webhook delivery for the same event ID is safely ignored

**Technical Notes:**

- Verify signature with `Webhook.constructEvent(payload, sigHeader, endpointSecret)` from the Stripe SDK — do this before any processing
- Store the Stripe `event.id` in a processed-events collection to enforce idempotency
- Raw request body must be read as bytes before any JSON parsing; Spring's `@RequestBody String` or a custom filter preserving the raw body is required for signature verification

**Dependencies:** Blocks: [DA-E17-04]. Blocked by: [DA-E17-02].

---

### DA-E17-04 — Implement GET /api/v1/subscriptions/invoices

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Provide OWNER with a billing history showing past invoices retrieved from Stripe for their workspace.

**Acceptance Criteria:**

- [ ] GET /api/v1/subscriptions/invoices returns paginated list of invoices for the current workspace's Stripe customer
- [ ] Each invoice includes {invoiceId, amountUsd, status, paidAt, invoicePdfUrl, periodStart, periodEnd}
- [ ] Only OWNER may access billing history; 403 for other roles
- [ ] Workspace with no Stripe customer (Free plan, never subscribed) returns empty list, not 404
- [ ] Supports `limit` and `startingAfter` cursor params (maps to Stripe's native pagination)

**Technical Notes:**

- Use Stripe SDK `Invoice.list(params)` with `customer = stripeCustomerId`; do not store invoice data in MongoDB (always fetch live from Stripe)
- Map Stripe's `amount_due` (in cents) to USD by dividing by 100
- Cache results in Redis for 5 minutes (`invoices:{workspaceId}`) to avoid hammering the Stripe API

**Dependencies:** Blocks: [None]. Blocked by: [DA-E17-03].

---

### DA-E17-05 — Rename WorkspaceSubscription to UserSubscription (V2 re-scope)

**Assignee:** Tuấn | **Priority:** 🟡 High

**Goal:** Move the Subscription Plan binding from Workspace-level to User/Owner-level, so one paid plan applies across the Owner's entire Agency (all their Workspaces), matching the V2 business decision.

**Acceptance Criteria:**

- [ ] `WorkspaceSubscription` → `UserSubscription`, keyed by `userId` (the Agency Owner), not `workspaceId`
- [ ] `GET /api/v1/subscriptions/plans` lists Basic/Pro/Enterprise with `maxWorkspaces`, `monthlyCredit`, `price`
- [ ] Plan limits (max Workspaces, AI credit) are enforced against the Owner's total usage across all their Workspaces, not per-Workspace

**Technical Notes:** **[CONFIRMED 2026-09-15, Trung]** No real subscription/payment transactions running yet — safe to rename/restructure freely, no data migration needed.

**Spec Reference:** `docs/feature/subscription-billing/3-9-1-upgrade-plan/spec.md`, `docs/feature/subscription-billing/3-9-2-downgrade-plan/spec.md`, `docs/ba/08-subscription-billing.md`

**Dependencies:** Blocks: [DA-E17-06]. Blocked by: [DA-E16-05 (Agency must exist to attribute Workspaces to an Owner's Agency)].

---

### DA-E17-06 — Rename Payment to Transaction + Integrate PayOS

**Assignee:** Tuấn | **Priority:** 🟡 High

**Goal:** Replace the generic/Stripe-style `Payment` entity with `Transaction`, integrated with PayOS (the confirmed V2 payment provider), following strict ACID semantics for plan/credit activation.

**Acceptance Criteria:**

- [ ] `Payment` → `Transaction` entity, status enum `PENDING/SUCCESS/FAILED`
- [ ] `POST /api/v1/payments/create` accepts `{type: upgrade_plan|buy_credit, refId}`, returns PayOS checkout URL + `transactionId`
- [ ] `POST /api/v1/payments/callback` (PayOS webhook) validates signature; invalid signature returns 400 `INVALID_WEBHOOK_SIGNATURE` without processing
- [ ] On successful callback: `Transaction.status=SUCCESS` AND Plan/Credit activation happen atomically — a partial failure (e.g. Transaction updated but Plan not activated) must roll back both
- [ ] Webhook retry with the same `transactionId` is idempotent — does not double-activate Plan/Credit
- [ ] Plan only takes effect AFTER payment confirmation, never before

**Technical Notes:** Requires a real PayOS API key/sandbox to test the callback flow end-to-end — flag this as an external dependency early.

**Spec Reference:** `docs/feature/subscription-billing/3-9-3-make-payment-payos/spec.md`, `docs/feature/subscription-billing/3-9-4-view-invoice-history/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E17-05].

---

### DA-E17-07 — Implement AI Credit Ledger (new domain)

**Assignee:** Tuấn | **Priority:** 🟡 High

**Goal:** Track AI feature usage (image/content/video generation) per Creator per month, with monthly reset and explicitly NO rollover of unused credit.

**Acceptance Criteria:**

- [ ] `AiCreditLedger` entity: tracks `used`, `limit`, breakdown by feature type (image/content/video — maps to FR 3.7.2/3.7.5/3.7.7), per Creator per month
- [ ] `GET /api/v1/ai-credit/me?month=YYYY-MM` returns the calling Creator's own usage
- [ ] `GET /api/v1/agencies/{id}/ai-credit?month=YYYY-MM` (Owner only) returns aggregated usage across all Creators in the Agency
- [ ] Non-owner attempting to view another Creator's credit returns 403 `FORBIDDEN`
- [ ] Monthly reset: unused credit does NOT carry over to the next month (confirmed business rule, not an [OPEN QUESTION] — resolved per `docs/ba/08`)
- [ ] Credit consumption is triggered by the AI feature calls themselves (E24 — AI Service Integration), this task only covers the ledger + read APIs

**Spec Reference:** `docs/feature/subscription-billing/3-9-5-view-ai-credit-tracking/spec.md`, `docs/feature/subscription-billing/3-9-6-buy-credit/spec.md`, `docs/feature/subscription-billing/3-9-7-set-credit/spec.md`, `docs/ba/08-subscription-billing.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E17-05, DA-E24-03 (AI usage tracking trigger)].

---

### DA-E18-01 — Implement Facebook Fanpage OAuth Flow

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Enable Managers to connect a Facebook Fanpage to a client, obtaining a long-lived page access token via OAuth.

**Acceptance Criteria:**

- [ ] GET /api/v1/social/facebook/connect?clientId={clientId} redirects to Facebook's OAuth dialog with required scopes (pages_manage_posts, pages_read_engagement)
- [ ] State parameter is stored in Redis as `oauth:state:{state}` → {clientId, userId}, TTL = 10 minutes
- [ ] GET /api/v1/social/facebook/callback validates state, exchanges short-lived code for a user access token, then exchanges for a long-lived page access token (60-day TTL)
- [ ] Page token is encrypted with AES-256-GCM before saving to MongoDB (DA-E18-03 must be complete first)
- [ ] SocialAccount document is created with {clientId, workspaceId, platform: FACEBOOK, pageId, pageName, tokenStatus: ACTIVE, expiresAt}
- [ ] If the same Fanpage is already connected for this client, the token is refreshed rather than creating a duplicate

**Technical Notes:**

- Facebook short-lived → long-lived exchange: POST to `https://graph.facebook.com/oauth/access_token` with `grant_type=fb_exchange_token`
- Then call `/{user-id}/accounts` to list pages and let the user select; for MVP, auto-select the first page or require the pageId as a query param
- Long-lived user tokens expire in 60 days; page tokens obtained from a long-lived user token do not expire — confirm this via the `GET /debug_token` endpoint

**Dependencies:** Blocks: [DA-E18-04, DA-E20-01]. Blocked by: [DA-E14-02, DA-E18-03].

---

### DA-E18-02 — Implement Instagram Business Account Connection

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Connect an Instagram Business Account to a client by leveraging the Facebook Business Manager OAuth flow (Instagram is accessed via Facebook Graph API).

**Acceptance Criteria:**

- [ ] Instagram connection piggybacks on the Facebook OAuth flow; additional scopes `instagram_basic, instagram_content_publish` are added to DA-E18-01's OAuth request
- [ ] After Facebook OAuth, the API calls `/{facebook-page-id}?fields=instagram_business_account` to retrieve the linked Instagram account ID
- [ ] SocialAccount document is created for the Instagram account with {clientId, workspaceId, platform: INSTAGRAM, igAccountId, igUsername, tokenStatus: ACTIVE}
- [ ] If no Instagram Business Account is linked to the Facebook Page, return 400 with a descriptive error and a help link
- [ ] Instagram and Facebook connections are stored as separate SocialAccount documents

**Technical Notes:**

- Instagram Basic Display API is for personal accounts; use Instagram Graph API via Facebook for Business accounts — do not confuse the two
- The page access token from DA-E18-01 is reused for Instagram Graph API calls; no separate Instagram token is needed
- Validate that the Instagram account is of type BUSINESS or CREATOR; personal accounts cannot publish content

**Dependencies:** Blocks: [DA-E18-04]. Blocked by: [DA-E18-01, DA-E18-03].

---

### DA-E18-03 — Implement AES-256-GCM Token Encryption

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Encrypt all social platform access tokens and refresh tokens with AES-256-GCM before persisting to MongoDB to protect credentials at rest.

**Acceptance Criteria:**

- [ ] A `TokenEncryptionService` bean encrypts and decrypts strings using AES-256-GCM
- [ ] Each encryption operation generates a unique 96-bit IV; the IV is stored alongside the ciphertext (e.g., as `{base64(iv)}:{base64(ciphertext)}`)
- [ ] The 256-bit encryption key is loaded from an environment variable or Vault; it is never hardcoded or committed to source control
- [ ] All social account token fields in MongoDB contain only the encrypted form; plaintext tokens never appear in any log or DB document
- [ ] Unit tests verify that encrypt(decrypt(x)) == x and that two encryptions of the same plaintext produce different ciphertexts (due to random IV)

**Technical Notes:**

- Use `javax.crypto.Cipher` with `"AES/GCM/NoPadding"`, `GCMParameterSpec(128, iv)` for 128-bit authentication tag
- Key derivation: if the raw key is provided as a Base64 string, decode it to a `SecretKeySpec`; document the expected format clearly
- Do not use AES-ECB or AES-CBC for this use case; GCM provides authenticated encryption which detects tampering

**Dependencies:** Blocks: [DA-E18-01, DA-E18-02, DA-E19-01, DA-E19-02, DA-E19-03]. Blocked by: [None].

---

### DA-E18-04 — Implement Social Account Disconnect Flow

**Assignee:** Phước (Publisher) | **Priority:** 🟡 High

**Goal:** Allow Managers to disconnect a social account by revoking the token at Meta's Graph API and removing the record from MongoDB.

**Acceptance Criteria:**

- [ ] DELETE /api/v1/social/accounts/{accountId} revokes the token at Meta Graph API (`DELETE /{user-id}/permissions`) then deletes the SocialAccount document; returns 204
- [ ] Only OWNER and MANAGER assigned to the client may disconnect; 403 otherwise
- [ ] If Meta API revocation fails (network error, already revoked), the local record is still deleted and the error is logged — do not block the user
- [ ] Attempting to disconnect an already-disconnected account returns 404
- [ ] Account must belong to the caller's workspaceId; mismatched workspaceId returns 404

**Technical Notes:**

- Decrypt the token using `TokenEncryptionService` (DA-E18-03) before calling the Meta API
- Wrap the Meta API call in a try-catch; log failure with the accountId and platform but proceed with local deletion (fire-and-forget revocation)
- For Instagram accounts, revocation is handled via the same Facebook user permission deletion endpoint

**Dependencies:** Blocks: [None]. Blocked by: [DA-E18-01, DA-E18-02].

---

### DA-E19-01 — Implement TikTok for Business OAuth

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Enable connection of a TikTok for Business account to a client using TikTok's Client Credentials OAuth flow with video.publish scope.

**Acceptance Criteria:**

- [ ] GET /api/v1/social/tiktok/connect?clientId={clientId} redirects to TikTok's OAuth dialog with scope `video.publish,user.info.basic`
- [ ] State parameter stored in Redis `oauth:state:{state}` with 10-minute TTL
- [ ] GET /api/v1/social/tiktok/callback validates state, exchanges code for access token and refresh token, stores both encrypted in MongoDB
- [ ] SocialAccount document is created with {clientId, workspaceId, platform: TIKTOK, tiktokUserId, displayName, tokenStatus: ACTIVE, expiresAt}
- [ ] Token encryption uses `TokenEncryptionService` (DA-E18-03)

**Technical Notes:**

- TikTok's OAuth 2.0 authorization endpoint: `https://www.tiktok.com/v2/auth/authorize/`
- TikTok access tokens expire in 24 hours; refresh tokens in 365 days — set `expiresAt` accordingly and ensure the nightly refresh job (DA-E20-01) handles this short TTL
- Use TikTok Content Posting API v2 (`https://open.tiktokapis.com/v2/`) for publishing, not the deprecated v1 endpoint

**Dependencies:** Blocks: [DA-E20-01]. Blocked by: [DA-E18-03, DA-E14-02].

---

### DA-E19-02 — Implement Threads OAuth

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Connect a Threads account to a client using Meta Graph API OAuth with threads_basic and threads_content_publish scopes.

**Acceptance Criteria:**

- [ ] GET /api/v1/social/threads/connect?clientId={clientId} redirects to Meta's OAuth dialog with scopes `threads_basic,threads_content_publish`
- [ ] State parameter stored in Redis `oauth:state:{state}` with 10-minute TTL
- [ ] GET /api/v1/social/threads/callback validates state, exchanges code for a short-lived token, then for a long-lived token (60-day TTL)
- [ ] SocialAccount document created with {clientId, workspaceId, platform: THREADS, threadsUserId, username, tokenStatus: ACTIVE, expiresAt}
- [ ] Token is encrypted before saving using `TokenEncryptionService` (DA-E18-03)

**Technical Notes:**

- Threads uses the same Meta developer app as Facebook/Instagram; add Threads permissions in the same Facebook App dashboard
- Long-lived token exchange endpoint: `https://graph.threads.net/access_token` — distinct from the Facebook token exchange URL
- Threads API base URL: `https://graph.threads.net/v1.0/`

**Dependencies:** Blocks: [DA-E20-01]. Blocked by: [DA-E18-03, DA-E14-02].

---

### ~~DA-E19-03 — Implement Zalo Official Account OAuth~~

> **Loại khỏi scope** (2026-09-03) — không tích hợp Zalo OA. Task đã xóa khỏi Jira (DA-216).

---

### DA-E19-04 — Implement Token Status API

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Expose an endpoint that returns the real-time connection status of all social accounts for a client, enabling the UI to display connection health at a glance.

**Acceptance Criteria:**

- [ ] GET /api/v1/social/accounts returns list of SocialAccount records for the JWT's workspaceId, optionally filtered by `clientId` query param
- [ ] Each account includes {accountId, platform, displayName, tokenStatus, expiresAt, lastRefreshedAt}
- [ ] `tokenStatus` values: ACTIVE (valid, > 7 days remaining), EXPIRING_SOON (valid, ≤ 7 days remaining), EXPIRED (past expiresAt), REVOKED (manually disconnected or revocation confirmed)
- [ ] CLIENT role receives only their own clientId's accounts (clientId filter applied from DA-E14-03)
- [ ] Tokens themselves (encrypted ciphertext) are never included in this response

**Technical Notes:**

- `tokenStatus` is computed at query time from `expiresAt` vs `Instant.now()` unless the status was explicitly set to REVOKED — do not rely solely on a pre-computed field that may be stale
- Consider a hybrid approach: store status in MongoDB (updated by refresh jobs) but recompute EXPIRED status on the fly if `expiresAt < now` regardless of stored status

**Dependencies:** Blocks: [DA-E20-03]. Blocked by: [DA-E18-01, DA-E18-02, DA-E19-01, DA-E19-02, DA-E14-03].

---

### DA-E20-01 — Implement Scheduled Token Refresh Job

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Automatically refresh expiring social platform tokens on a nightly schedule to maintain uninterrupted publishing capability.

**Acceptance Criteria:**

- [ ] A Spring `@Scheduled(cron = "0 0 2 * * *")` job runs at 2:00 AM daily and refreshes tokens for all platforms expiring within 7 days
- [ ] Successfully refreshed tokens update {accessToken (encrypted), refreshToken (encrypted), expiresAt, lastRefreshedAt, tokenStatus: ACTIVE} in MongoDB
- [ ] Failed refresh attempts do not crash the job; errors are caught per-account and logged; DA-E20-02 is triggered for each failure
- [ ] Job execution is idempotent: re-running manually produces no duplicate refreshes within the same window

**Technical Notes:**

- Use `@EnableScheduling` on a `@Configuration` class; inject the scheduler via `TaskScheduler` for testability
- Process accounts in batches (e.g., 50 at a time) using MongoDB cursor pagination to avoid loading all accounts into memory
- For multi-instance deployments, use a distributed lock (Redisson `RLock` or Redis `SET NX EX`) to ensure only one instance runs the job at a time

**Dependencies:** Blocks: [DA-E20-02, DA-E20-03]. Blocked by: [DA-E18-01, DA-E18-02, DA-E19-01, DA-E19-02].

---

### DA-E20-02 — Implement Token Refresh Failure Alert

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Notify the assigned Manager immediately when a token refresh fails so they can re-authenticate the social account before publishing is disrupted.

**Acceptance Criteria:**

- [ ] When a refresh job fails for an account, `tokenStatus` is updated to EXPIRING_SOON (if token not yet expired) or EXPIRED
- [ ] An email notification is sent to the Manager assigned to that client with: platform name, account display name, error reason, and a deep link to reconnect
- [ ] If no Manager is assigned, the notification is sent to the workspace OWNER instead
- [ ] Notifications are not duplicated: if a token has already sent a failure alert within the last 24 hours, suppress subsequent alerts until the token is refreshed or re-authenticated
- [ ] Notification suppression state is stored in Redis: `alert:token_fail:{accountId}`, TTL = 24 hours

**Technical Notes:**

- Emit a Spring `ApplicationEvent` (e.g., `TokenRefreshFailedEvent`) from the refresh job and handle it in a separate `@EventListener` — keeps the job logic clean
- Email template should include a clear call-to-action button; use Thymeleaf templates if already used elsewhere in the project

**Dependencies:** Blocks: [None]. Blocked by: [DA-E20-01].

---

### DA-E20-03 — Implement Manual Token Refresh API

**Assignee:** Phước (Publisher) | **Priority:** 🟡 High

**Goal:** Allow Managers to manually trigger a token refresh for a specific social account outside of the scheduled job cycle.

**Acceptance Criteria:**

- [ ] POST /api/v1/social/accounts/{accountId}/refresh triggers an immediate token refresh for the specified account; returns 200 with updated {tokenStatus, expiresAt}
- [ ] Only OWNER and MANAGER assigned to the client may trigger manual refresh; 403 otherwise
- [ ] If the refresh token itself is expired or invalid, returns 400 with {error: "Re-authentication required", reconnectUrl}
- [ ] Account must belong to the caller's workspaceId; mismatched workspaceId returns 404
- [ ] Rate-limited to 5 manual refresh attempts per account per hour to prevent abuse (Redis counter with 1-hour TTL)

**Technical Notes:**

- Reuse the same refresh logic extracted from DA-E20-01 into a `TokenRefreshService`; the scheduled job and this endpoint both call the same service method
- Rate limit key: `ratelimit:manual_refresh:{accountId}`, increment with `INCR` and set TTL on first increment with `EXPIRE`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E19-04, DA-E20-01].

---

### DA-E23-01 — Expose /internal/ai/content/generate

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Provide an internal HTTP endpoint that generates social media captions and hashtags using AI, callable only by business-service with a shared secret key.

**Acceptance Criteria:**

- [ ] POST /internal/ai/content/generate accepts {topic, clientId, platform, tone} in the request body; returns {caption, hashtags, generatedAt}
- [ ] Requires `X-Internal-Key` header matching the configured secret; missing or mismatched key returns 401
- [ ] Endpoint is NOT exposed through the API Gateway or accessible from the public internet; only internal service-to-service communication
- [ ] `platform` must be one of {FACEBOOK, INSTAGRAM, TIKTOK, THREADS, ZALO}; invalid value returns 400
- [ ] Response time SLA: 95th percentile under 5 seconds; timeouts return 504

**Technical Notes:**

- Validate `X-Internal-Key` in a `OncePerRequestFilter` that runs before any business logic; store the expected key in an environment variable
- Use Spring's `@Profile("!test")` or a separate security configuration to exclude this filter in unit tests
- This endpoint deducts 1 AI credit per call; credit deduction is handled by business-service (DA-E24-03), not this endpoint

**Dependencies:** Blocks: [DA-E24-01]. Blocked by: [None].

---

### DA-E23-02 — Expose /internal/ai/image/generate

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Provide an internal endpoint that generates an AI image from a text prompt and style, uploads it to S3, and returns the S3 URL.

**Acceptance Criteria:**

- [ ] POST /internal/ai/image/generate accepts {prompt, style, clientId} and returns {imageUrl, s3Key, generatedAt}
- [ ] Requires `X-Internal-Key` header; missing or invalid key returns 401
- [ ] Generated image is uploaded to S3 under a deterministic key (e.g., `ai-images/{clientId}/{timestamp}.png`); the public or pre-signed URL is returned
- [ ] If the image generation model fails or times out, returns 503 with a retry-after hint
- [ ] Response time SLA: 95th percentile under 30 seconds given typical image generation latency; implement async if needed

**Technical Notes:**

- Integrate with an image generation provider (e.g., Stability AI, DALL-E 3, or Replicate); abstract behind an `ImageGenerationProvider` interface for swappability
- Upload to S3 using AWS SDK v2 `S3AsyncClient`; do not return raw image bytes in the HTTP response — always upload to S3 first
- This call costs 3 AI credits; deduction handled by business-service (DA-E24-03)

**Dependencies:** Blocks: [DA-E24-02]. Blocked by: [None].

---

### DA-E23-03 — Expose /internal/ai/ambassador/generate

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Provide an internal endpoint that composites a face image onto a product image using AI to create brand ambassador visuals.

**Acceptance Criteria:**

- [ ] POST /internal/ai/ambassador/generate accepts {faceImageS3Key, productImageS3Key, clientId} and returns {composedImageUrl, s3Key, generatedAt}
- [ ] Requires `X-Internal-Key` header; missing or invalid key returns 401
- [ ] Both S3 keys must exist and be accessible; invalid keys return 400 with descriptive error
- [ ] Composed image is uploaded to S3 under `ai-ambassador/{clientId}/{timestamp}.png`; URL is returned
- [ ] This operation may take 15–60 seconds; endpoint should support async processing with a jobId if synchronous response is not feasible within gateway timeout

**Technical Notes:**

- This call costs 5 AI credits; deduction handled by business-service (DA-E24-03)
- If async: return 202 Accepted with {jobId}; provide GET /internal/ai/ambassador/jobs/{jobId} for polling status and result URL
- Use pre-signed S3 URLs to download input images into the AI processing service without making the buckets fully public

**Dependencies:** Blocks: [DA-E24-02]. Blocked by: [None].

---

### DA-E23-04 — Expose /internal/ai/video/generate

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Provide an internal async endpoint that generates a short video from a script and style, returning a jobId for polling until the S3 URL is ready.

**Acceptance Criteria:**

- [ ] POST /internal/ai/video/generate accepts {script, style, clientId} and immediately returns 202 Accepted with {jobId}
- [ ] Requires `X-Internal-Key` header; missing or invalid key returns 401
- [ ] GET /internal/ai/video/jobs/{jobId} returns {status: PENDING|PROCESSING|COMPLETED|FAILED, videoUrl (when COMPLETED), errorMessage (when FAILED)}
- [ ] On completion, generated video is uploaded to S3 under `ai-video/{clientId}/{jobId}.mp4` and `videoUrl` is populated
- [ ] Job state is persisted in MongoDB or Redis with TTL = 24 hours after completion

**Technical Notes:**

- This call costs 10 AI credits; deduct synchronously at job submission time (before video is generated) so the credit is reserved; if generation fails, consider a credit refund policy
- Use a message queue (Redis Streams or RabbitMQ) to decouple job submission from processing
- Expose the polling endpoint with the same `X-Internal-Key` guard

**Dependencies:** Blocks: [DA-E24-02]. Blocked by: [None].

---

### DA-E23-05 — Expose /internal/ai/trends/fetch

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Provide an internal endpoint that returns trending topics per platform and region, served from Redis cache to ensure fast and consistent responses.

**Acceptance Criteria:**

- [ ] GET /internal/ai/trends/fetch?platform={platform}&region={region} returns {trends: [{topic, score, relatedHashtags}], cachedAt, ttlSeconds}
- [ ] Requires `X-Internal-Key` header; missing or invalid key returns 401
- [ ] Data is served from Redis cache; a background job refreshes the cache periodically (every 1–6 hours depending on platform)
- [ ] If cache is empty or stale, fetches fresh data from an external trends source (e.g., Google Trends API, TikTok Trending API) and repopulates Redis
- [ ] `platform` must be one of {FACEBOOK, INSTAGRAM, TIKTOK, THREADS, ZALO}; `region` is an ISO 3166-1 alpha-2 country code

**Technical Notes:**

- Redis key: `trends:{platform}:{region}`, value: serialized JSON list, TTL matches refresh interval
- Cache miss fallback must be resilient: if the external trends API is unavailable, return cached data even if stale rather than returning 503
- This endpoint does not cost AI credits (it is a data lookup, not a generation call)

**Dependencies:** Blocks: [None]. Blocked by: [None].

---

### DA-E24-01 — Implement AI Content Generation Flow in Business-Service

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Wire the user-facing content generation request through business-service to ai-service, save the result as a Draft Post, and enforce AI credit limits.

**Acceptance Criteria:**

- [ ] POST /api/v1/posts/ai-generate accepts {clientId, topic, platform, tone} and returns {postId, caption, hashtags, status: DRAFT}
- [ ] business-service calls /internal/ai/content/generate on ai-service with `X-Internal-Key` header before creating the Post document
- [ ] If the workspace has insufficient AI credits (0 remaining), returns 429 with {creditsUsed, creditsLimit, upgradeUrl} before calling ai-service
- [ ] On success, deducts 1 AI credit (DA-E24-03) and saves a Post document with {clientId, workspaceId, caption, hashtags, platform, status: DRAFT, aiGenerated: true}
- [ ] If ai-service returns an error, no credit is deducted and the error is surfaced to the caller with 502 Bad Gateway

**Technical Notes:**

- Use Spring's `RestClient` or `WebClient` to call ai-service; configure a 10-second timeout
- Store the ai-service base URL in `application.yml` under `services.ai.base-url`; inject via `@Value`
- Credit check and deduction must be in the same logical transaction scope; use an optimistic lock on the credit counter field to prevent race conditions

**Dependencies:** Blocks: [None]. Blocked by: [DA-E23-01, DA-E24-03, DA-E14-02].

---

### DA-E24-02 — Implement Image and Ambassador Generation Trigger

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow users in the Post editor to trigger AI image or ambassador composite generation and receive the resulting S3 URL to embed in their post.

**Acceptance Criteria:**

- [ ] POST /api/v1/posts/{postId}/ai-image accepts {prompt, style} and returns {imageUrl, creditsDeducted: 3}
- [ ] POST /api/v1/posts/{postId}/ai-ambassador accepts {faceImageS3Key, productImageS3Key} and returns {jobId} (async) with a polling URL
- [ ] Both endpoints check AI credit availability before calling ai-service; insufficient credits return 429
- [ ] On image generation success, the returned S3 URL is attached to the Post document's `mediaUrls` array
- [ ] On ambassador generation, the Post document is updated with {ambassadorJobId, status: AI_PROCESSING}; a webhook or polling response updates it to READY when the job completes

**Technical Notes:**

- Image generation: synchronous call to DA-E23-02, deduct 3 credits on success
- Ambassador generation: async call to DA-E23-03, deduct 5 credits at submission time; document the refund policy if the job fails
- Expose GET /api/v1/posts/{postId}/ai-ambassador/status that polls the ai-service job status and updates the Post document when COMPLETED

**Dependencies:** Blocks: [None]. Blocked by: [DA-E23-02, DA-E23-03, DA-E24-03, DA-E14-02].

---

### DA-E24-03 — Implement AI Usage Tracking

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Track and enforce monthly AI credit consumption per workspace, returning structured 429 responses with upgrade prompts when limits are reached.

**Acceptance Criteria:**

- [ ] Each AI call type deducts the correct credit amount: content=1, image=3, ambassador=5, video=10
- [ ] Credits are tracked per workspace per calendar month in MongoDB: {workspaceId, month (YYYY-MM), creditsUsed, creditsLimit}
- [ ] Before any AI call, a `checkAndDeductCredits(workspaceId, cost)` method atomically checks remaining credits and deducts if sufficient
- [ ] When credits are exhausted, returns 429 with {creditsUsed, creditsLimit, upgradeUrl} where `upgradeUrl = "https://app.brandhub.io/billing/upgrade"`
- [ ] `creditsLimit` is read from the workspace's active subscription plan; Free=20, Basic=100, Pro=500, Enterprise=unlimited (-1 = skip check)

**Technical Notes:**

- Use MongoDB `findOneAndUpdate` with `$inc` and a conditional filter (`creditsUsed + cost <= creditsLimit`) to perform the check-and-deduct atomically — avoids race conditions without a distributed lock
- For Enterprise (unlimited): short-circuit the credit check and only record usage for analytics
- Reset `creditsUsed` to 0 at the start of each calendar month; implement via a `@Scheduled(cron = "0 0 0 1 * *")` job or compute it from a monthly usage log collection

**Dependencies:** Blocks: [DA-E24-01, DA-E24-02]. Blocked by: [DA-E17-01].

---

## AI Parallel Track — Iterations 1–4

---

### DA-AI01-01 — Research and compare InstantID vs IP-Adapter vs ControlNet for face-consistent virtual ambassador generation

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Evaluate the three leading face-consistency approaches to select the best-fit architecture for BrandHub's virtual ambassador feature before any implementation begins.

**Acceptance Criteria:**

- [ ] Comparison table covers: inference speed, VRAM requirement, face similarity score methodology, licensing, and hosting options (Colab/Replicate/self-hosted)
- [ ] Each approach is tested with at least one public demo or code sample and results are documented
- [ ] A clear recommendation (with rationale) is written as the final section of the research note

**Technical Notes:**

- InstantID requires InsightFace buffalo_l (~300MB) and a ControlNet depth model; check Replicate hosted versions to avoid GPU setup cost in research phase
- IP-Adapter works with standard diffusers pipeline; compare face_id variants (IP-Adapter-FaceID-Plus vs base)
- ControlNet inpainting is the fallback compositing approach, not a direct face-ID method — distinguish this clearly in the comparison

**Dependencies:** Blocks: DA-AI01-02, DA-AI07-01. Blocked by: None.

---

### DA-AI01-02 — Test 3 virtual ambassador tools on 5 sample images, write comparison table (quality, speed, cost)

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Produce empirical evidence (not just literature review) for the ambassador tool decision by running all three approaches against identical inputs.

**Acceptance Criteria:**

- [ ] All 3 tools run against the same 5 sample reference photos; raw output images are saved and linked in the document
- [ ] Comparison table includes columns: tool, avg generation time (s), estimated cost per image, cosine similarity score vs reference, subjective realism rating (1-5)
- [ ] Winning tool is confirmed and justification is written with enough detail to defend the choice to the mentor

**Technical Notes:**

- Use InsightFace `get_feat()` to compute cosine similarity between reference embedding and generated face embedding; target ≥ 0.85
- Run Replicate API for InstantID during research to avoid local GPU requirement; log per-call latency and credit cost
- Use consistent positive/negative prompts across all tools to eliminate prompt variance from results

**Dependencies:** Blocks: DA-AI07-01. Blocked by: DA-AI01-01.

---

### DA-AI01-03 — Research Google Veo API: capabilities, pricing, rate limits, movement parameters

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Establish a factual baseline for Veo API constraints so that the video pipeline design does not make assumptions that break in production.

**Acceptance Criteria:**

- [ ] Document lists: supported resolutions, max duration, accepted input types (text-only vs image+text), output format
- [ ] Pricing per video second and rate limits (requests/min, concurrent jobs) are confirmed from official docs or billing sandbox
- [ ] Movement/camera parameter list is enumerated (e.g., camera_pan, zoom_in, subject_walk) with accepted value ranges
- [ ] Async flow confirmed: POST → jobId → poll GET status → final video URL lifecycle is documented with example JSON

**Technical Notes:**

- Veo API is under Google Cloud Vertex AI; access requires project allowlisting — confirm access status early and escalate if not granted
- Redis polling design depends on the actual poll interval recommendation from Google docs; do not assume 5s without checking

**Dependencies:** Blocks: DA-AI01-04, DA-AI09-01. Blocked by: None.

---

### DA-AI01-04 — Collect and test 20+ video generation prompts with various movement parameters, classify results

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Build an empirical prompt library that maps specific movement parameters to predictable visual outcomes, reducing guesswork during product video generation.

**Acceptance Criteria:**

- [ ] At least 20 prompts tested, covering at minimum: product showcase, lifestyle scene, brand intro, seasonal campaign categories
- [ ] Each result is classified on: movement accuracy (does the video match the requested motion), visual quality (1-5), generation time
- [ ] A "top 10 best-performing prompts" shortlist is extracted and formatted as starter templates for DA-AI09-04

**Technical Notes:**

- Tag each prompt with movement_type (camera_pan / zoom_in / zoom_out / subject_walk / static) to feed the parameter mapping in DA-AI09-03
- Save video outputs to a shared S3 bucket or Google Drive folder with consistent naming: `veo_test_{prompt_id}_{movement_type}.mp4`

**Dependencies:** Blocks: DA-AI09-02, DA-AI09-04. Blocked by: DA-AI01-03.

---

### DA-AI01-05 — Research product + model image compositing techniques: ControlNet inpainting, DALL-E edit, rembg + composite

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Identify the compositing approach that best balances output realism, compute cost, and implementation complexity before building the composition service.

**Acceptance Criteria:**

- [ ] Three techniques are researched: ControlNet inpainting, DALL-E 2/3 edit API, and rembg + Pillow manual composite
- [ ] Research note documents: API availability, estimated cost per composite, GPU/CPU requirements, known failure modes
- [ ] Recommendation section states which technique BrandHub should use as primary and which as fallback, with rationale

**Technical Notes:**

- rembg known failure cases to document explicitly: transparent/glass packaging, fine hair edges, reflective surfaces (mirrors, metallic products)
- DALL-E edit requires RGBA PNG input with mask; test whether product cutout masks from rembg are compatible

**Dependencies:** Blocks: DA-AI01-06, DA-AI08-01. Blocked by: None.

---

### DA-AI01-06 — Test 3 compositing methods on 10 product + model image pairs, evaluate naturalness and compute cost

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Validate the compositing technique recommendation with real product images representative of BrandHub's target clientele (fashion, beauty, F&B).

**Acceptance Criteria:**

- [ ] 10 product + model image pairs tested across all 3 methods; raw composite outputs saved and linked
- [ ] Evaluation rubric applied to each output: edge blending (1-5), shadow realism (1-5), lighting consistency (1-5), compute time (s), cost (USD)
- [ ] Failure cases are photographed and catalogued with root cause notes (e.g., "transparent bottle — rembg retains background pixels")

**Technical Notes:**

- Include at least 2 "hard" cases: one with hair-heavy model photo and one with a reflective/glass product, to stress-test rembg limits
- Use identical Pillow composite pipeline for all 3 so the only variable is the background/mask source

**Dependencies:** Blocks: DA-AI08-01. Blocked by: DA-AI01-05.

---

### DA-AI01-07 — Compare Llama 3 (Groq) vs Claude API: Vietnamese caption quality, speed, cost per call

**Assignee:** All (Team) | **Priority:** 🔴 Critical

**Goal:** Determine the primary and fallback LLM pairing for caption generation based on measurable Vietnamese language quality, not assumption.

**Acceptance Criteria:**

- [ ] 20 Vietnamese marketing captions generated per model using identical prompts and brand context documents
- [ ] Blind evaluation by all team members rates captions on: fluency, brand tone adherence, factual accuracy, cultural appropriateness (1-5 each)
- [ ] Cost per 1000 calls and average latency (ms) documented for both providers; final recommendation recorded in AI Research Summary

**Technical Notes:**

- Use the same anti-hallucination system prompt for both: "only use provided context, do not fabricate facts"
- Groq Llama 3 rate limit is 30 req/min; measure how often this is hit in a realistic burst test of 30 rapid requests
- Test Claude Haiku vs Claude Sonnet for cost-quality tradeoff on the fallback side

**Dependencies:** Blocks: DA-AI04-02, DA-AI04-03, DA-AI01-08. Blocked by: None.

---

### DA-AI01-08 — Write AI Research Summary Document consolidating results from all 3 tracks

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Produce a single document that a mentor or new team member can read to understand all AI architecture decisions and the evidence behind them.

**Acceptance Criteria:**

- [ ] Document includes sections for: Virtual Ambassador (DA-AI01-01/02), Video Generation (DA-AI01-03/04), Image Compositing (DA-AI01-05/06), LLM Comparison (DA-AI01-07)
- [ ] Each section references raw data/output links and states the final decision clearly
- [ ] Document is stored in the shared team repository and linked in the project README

**Dependencies:** Blocks: None. Blocked by: DA-AI01-02, DA-AI01-04, DA-AI01-06, DA-AI01-07.

---

### DA-AI02-01 — Initialize brandhub-ai-service project: FastAPI + Python 3.11 + folder structure

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Create the canonical project skeleton so all AI developers work in a consistent directory layout from day one.

**Acceptance Criteria:**

- [ ] Repository created with folders: `api/`, `services/`, `models/`, `utils/`, `tests/`, `requirements.txt`, `.env.example`
- [ ] FastAPI app boots with `uvicorn` on port 8082 and returns `{"status": "ok"}` at `GET /health`
- [ ] `requirements.txt` pins: fastapi, uvicorn, pydantic, python-dotenv, and placeholder entries for chromadb, groq, anthropic, boto3, stability-sdk

**Technical Notes:**

- Use Python 3.11 explicitly in `.python-version` and Dockerfile `FROM python:3.11-slim`
- Structure `api/` as routers (one file per feature: content.py, image.py, video.py, ambassador.py, compose.py, rag.py, trends.py)

**Dependencies:** Blocks: DA-AI02-02, DA-AI02-03, DA-AI02-04, DA-AI02-05, DA-AI02-06. Blocked by: None.

---

### DA-AI02-02 — Configure 4 API clients from .env: ChromaDB, Groq, Anthropic, Stability AI

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Provide a single `clients.py` module that all services import, ensuring no API key is hardcoded and all clients are initialized once at startup.

**Acceptance Criteria:**

- [ ] `utils/clients.py` exports: `chroma_client`, `groq_client`, `anthropic_client`, `stability_client` — all initialized from `os.environ`
- [ ] `.env.example` documents all required keys: `CHROMA_HOST`, `CHROMA_PORT`, `GROQ_API_KEY`, `ANTHROPIC_API_KEY`, `STABILITY_API_KEY`
- [ ] Application startup fails fast with a clear error message if any required env var is missing
- [ ] Unit test confirms each client object is not None when valid dummy keys are provided

**Technical Notes:**

- ChromaDB: use `chromadb.HttpClient(host, port)` for containerized Chroma; do not use the in-memory client in any environment
- Wrap client initialization in a `lifespan` context manager (FastAPI 0.95+) rather than module-level globals to support clean shutdown

**Dependencies:** Blocks: DA-AI03-03, DA-AI04-02, DA-AI04-03, DA-AI06-01, DA-AI07-01. Blocked by: DA-AI02-01.

---

### DA-AI02-03 — Configure AWS S3 client with boto3, write upload_file(), get_presigned_url(), delete_file() helpers

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Provide a tested S3 utility layer that every AI feature can use without reimplementing boto3 boilerplate or handling credentials directly.

**Acceptance Criteria:**

- [ ] `utils/s3.py` implements: `upload_file(local_path, s3_key) -> str`, `get_presigned_url(s3_key, expires_in=3600) -> str`, `delete_file(s3_key) -> bool`
- [ ] All three functions have unit tests using `moto` to mock S3; tests pass in CI without real AWS credentials
- [ ] Bucket name and region read from env vars `S3_BUCKET_NAME` and `AWS_REGION`; `.env.example` updated

**Technical Notes:**

- `upload_file()` should accept both a file path and a `bytes` object (for in-memory image/video buffers from AI generation)
- Set `ContentType` correctly on upload (image/png, video/mp4) so presigned URLs serve with correct MIME type in browser

**Dependencies:** Blocks: DA-AI03-01, DA-AI06-02, DA-AI07-05, DA-AI09-06. Blocked by: DA-AI02-01.

---

### DA-AI02-04 — Set up Pydantic base schemas for all request/response models

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Define the data contracts for all AI endpoints upfront so that parallel implementation work does not produce incompatible request/response shapes.

**Acceptance Criteria:**

- [ ] `models/` contains schema files for: content (caption request/response), image generation, video generation, ambassador, compose, RAG document, trends
- [ ] All schemas inherit from a `BaseRequest` / `BaseResponse` with common fields (e.g., `clientId: str`, `requestId: Optional[str]`)
- [ ] Schemas are importable and validate correctly using `pytest` model instantiation tests

**Technical Notes:**

- Use `model_config = ConfigDict(str_strip_whitespace=True)` on all request models to avoid whitespace bugs in clientId lookups
- Caption response schema must include `platform: Literal["facebook","instagram","tiktok","threads","zalo"]` to enforce platform-awareness downstream

**Dependencies:** Blocks: DA-AI03-01, DA-AI04-01, DA-AI06-02, DA-AI07-03, DA-AI08-05, DA-AI09-05. Blocked by: DA-AI02-01.

---

### DA-AI02-05 — Write Dockerfile for ai-service + add ai-service to docker-compose.yml in infrastructure repo

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Make the ai-service runnable in the shared development environment with one `docker-compose up` command alongside all other BrandHub services.

**Acceptance Criteria:**

- [ ] `Dockerfile` builds successfully; image boots, passes `GET /health`, and exits cleanly on SIGTERM
- [ ] `docker-compose.yml` entry exposes port 8082, injects env vars from `.env`, and declares dependency on ChromaDB and Redis services
- [ ] `docker-compose up ai-service` from a clean clone (no local Python install) produces a running service within 3 minutes

**Technical Notes:**

- Use multi-stage build if any heavy ML libraries (torch, insightface) are included; otherwise `python:3.11-slim` is sufficient for Iterations 1-2
- GPU-dependent services (InstantID) must NOT be included in the standard Dockerfile; use a separate `Dockerfile.gpu` or delegate to Replicate API

**Dependencies:** Blocks: DA-AI10-03. Blocked by: DA-AI02-01.

---

### DA-AI02-06 — Write internal API key authentication middleware (validate X-Internal-Key header on all /internal/\* routes)

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Prevent unauthorized access to internal ai-service endpoints that are called by business-service but must not be publicly reachable.

**Acceptance Criteria:**

- [ ] FastAPI middleware or dependency checks `X-Internal-Key` header on all routes prefixed `/internal/`
- [ ] Requests with missing or incorrect key receive `401 Unauthorized` with body `{"error": "invalid_internal_key"}`
- [ ] Valid key is read from env var `INTERNAL_API_KEY`; hardcoded fallback values are forbidden
- [ ] Unit tests cover: valid key passes, missing header rejected, wrong key rejected

**Technical Notes:**

- Implement as a FastAPI `Depends()` dependency rather than middleware so it can be applied selectively per router without affecting public endpoints
- Use `secrets.compare_digest()` for key comparison to prevent timing attacks

**Dependencies:** Blocks: DA-AI10-03. Blocked by: DA-AI02-01.

---

### DA-AI02-07 — Document ChromaDB collection design (collection naming per clientId, metadata schema, query patterns)

**Assignee:** Tuấn (AI) | **Priority:** 🟡 High

**Goal:** Define and record the ChromaDB data model so all developers embed and query documents consistently without schema drift between features.

**Acceptance Criteria:**

- [ ] Document specifies collection naming convention (e.g., `client_{clientId}`) and the rationale for collection-per-client isolation
- [ ] Metadata schema per document chunk is defined: `{documentId: str, clientId: str, chunkIndex: int, source: str, uploadedAt: str}`
- [ ] Query patterns documented: top-K semantic search filtered by clientId, delete by documentId (fetch IDs then delete)

**Technical Notes:**

- ChromaDB does not support cross-collection queries; collection-per-client means listing all client documents requires a collection-level API call, not a query — document this limitation
- `where` filter syntax for metadata: `{"clientId": {"$eq": client_id}}` — include exact ChromaDB filter syntax in the doc to avoid trial-and-error

**Dependencies:** Blocks: DA-AI03-02, DA-AI03-03, DA-AI03-04. Blocked by: DA-AI02-01.

---

### DA-AI03-01 — Implement document upload endpoint (accept PDF/DOCX/TXT/URL, save file to S3)

**Assignee:** Lộc (Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Provide the entry point for brand knowledge ingestion so that clients can upload brand documents that the RAG pipeline will index.

**Acceptance Criteria:**

- [ ] `POST /ai/rag/documents` accepts multipart file upload (PDF, DOCX, TXT) and an optional URL parameter
- [ ] File is uploaded to S3 at key `rag/{clientId}/{documentId}/{filename}` and a document record is returned with `{documentId, s3Key, status: "processing"}`
- [ ] URL input fetches the page content (via `requests` + `BeautifulSoup`) and saves as `.txt` to S3 before proceeding
- [ ] File size limit enforced (max 10MB); unsupported extensions return `400 Bad Request`

**Technical Notes:**

- Use `python-docx` for DOCX text extraction and `pdfplumber` for PDF; do not rely on OCR for this iteration
- Trigger chunking pipeline (DA-AI03-02) asynchronously via `BackgroundTasks` so the upload endpoint returns immediately without waiting for embedding

# **Dependencies:** Blocks: DA-AI03-02, DA-AI03-07. Blocked by: DA-AI02-03, DA-AI02-04.

## PHẦN I: CHI TIẾT CÀI ĐẶT EPIC AI-03 (BRAND KNOWLEDGE BASE & INGESTION PIPELINE)

> > > > > > > 5c259fda04390825822aed6b514cff238aa9e22a

**Implementation Details:**

- **Files affected:** `app/api/v1/documents.py` and `app/models/response.py`
- **Functions/Classes to create:** `async def upload_document(file: UploadFile = File(None), url: str = Form(None), client_id: str = Form(...), background_tasks: BackgroundTasks)`
- **Processing flow:**
  1. Verify file format (only allow `.pdf`, `.docx`, `.txt`). If invalid, return HTTP 400.
  2. Upload file to S3 via helper in `app/core/s3.py`.
  3. If URL: fetch HTML, clean with BeautifulSoup to extract raw text, save as a temporary `.txt` file, and upload to S3.
  4. Generate `document_id = str(uuid.uuid4())`.
  5. Register background task `process_document_background_task(s3_key, client_id, document_id)`.
  6. Return JSON status response immediately.
- **Code Skeleton:**

```python
# app/api/v1/documents.py
from fastapi import APIRouter, UploadFile, File, Form, BackgroundTasks, HTTPException
from app.models.response import IngestionResponse
import uuid

router = APIRouter()

@router.post("/upload", response_model=IngestionResponse)
async def upload_document(
    client_id: str = Form(...),
    file: UploadFile = File(None),
    url: str = Form(None),
    background_tasks: BackgroundTasks = BackgroundTasks()
):
    if not file and not url:
        raise HTTPException(status_code=400, detail="Must provide either file or URL")

    document_id = str(uuid.uuid4())
    s3_key = f"rag/{client_id}/{document_id}/source_file"

    # Kích hoạt xử lý bất đồng bộ qua BackgroundTasks
    background_tasks.add_task(
        process_document_background_task,
        s3_key=s3_key,
        client_id=client_id,
        document_id=document_id
    )

    return IngestionResponse(
        documentId=document_id,
        clientId=client_id,
        s3Key=s3_key,
        status="processing"
    )

async def process_document_background_task(s3_key: str, client_id: str, document_id: str):
    # Luồng ngầm: Chunking -> Embedding & ChromaDB -> NER & Neo4j
    pass
```

---

### DA-AI03-01 — Brand Document Upload API (`POST /api/v1/ai/rag/documents`)

**Goal:** Provide the primary entry point for brand knowledge ingestion so enterprise clients can upload internal brand guidelines, product manuals, and PR reports with multi-tenant isolation.

**Acceptance Criteria:**

- [ ] Endpoint `POST /api/v1/ai/rag/documents` accepts multipart file upload (PDF, DOCX, TXT) and mandatory `clientId`
- [ ] Uploads raw document to AWS S3 at path key `rag/{clientId}/{documentId}/{filename}` and returns `{documentId, s3Key, status: "processing"}`
- [ ] Validates file extension and maximum size limit (10MB); returns `400 Bad Request` if invalid
- [ ] Triggers document chunking and multi-tenant tagging pipeline asynchronously via `BackgroundTasks`

**Technical Notes:**

- Stack: FastAPI / Spring Boot 3, boto3, multipart/form-data.
- Endpoint: `POST /api/v1/ai/rag/documents`.
- Security: Enforce `clientId` isolation on all incoming ingestion requests.

**Dependencies:**
Blocks: DA-AI03-02, DA-AI03-03, DA-AI03-04. Blocked by: DA-AI02-03.

**Implementation Details:**

- **Files affected:** `app/services/chunking.py`
- **Functions/Classes to create:** `class DocumentChunker` with function `def chunk_document(self, file_bytes: bytes, file_type: str) -> List[str]`
- **Processing flow:**
  1. Based on `file_type` (pdf, docx, txt), use the corresponding library (`pdfplumber` or `python-docx`) to extract text.
  2. Initialize `RecursiveCharacterTextSplitter` with parameters `chunk_size=500` and `chunk_overlap=50`.
  3. Return list of raw text chunks with extra whitespace removed.
- **Code Skeleton:**

```python
# app/services/chunking.py
from langchain.text_splitter import RecursiveCharacterTextSplitter
import pdfplumber
from io import BytesIO

class DocumentChunker:
    def __init__(self):
        self.splitter = RecursiveCharacterTextSplitter(
            chunk_size=500,
            chunk_overlap=50,
            separators=["\n\n", "\n", ".", ",", " ", ""]
        )

    def extract_text(self, file_bytes: bytes, file_type: str) -> str:
        if file_type == "pdf":
            with pdfplumber.open(BytesIO(file_bytes)) as pdf:
                return "".join([page.extract_text() or "" for page in pdf.pages])
        return file_bytes.decode("utf-8")

    def chunk_document(self, file_bytes: bytes, file_type: str) -> list[str]:
        text = self.extract_text(file_bytes, file_type)
        chunks = self.splitter.split_text(text)
        return [c.strip() for c in chunks if c.strip()]
```

---

### DA-AI03-02 — Object Storage Ingestion (`rag/{clientId}/{docId}/{filename}`) & Document Deletion

**Goal:** Handle object storage operations for brand knowledge files including structured pathing, presigned URL generation, and complete document purge across S3, ChromaDB, and Neo4j.

**Acceptance Criteria:**

- [ ] Files are stored cleanly in S3 under `rag/{clientId}/{docId}/{filename}`
- [ ] Endpoint `DELETE /api/v1/ai/rag/documents/{documentId}` purges the source file from S3 and removes all corresponding chunks from ChromaDB and nodes from Neo4j tagged with matching `documentId` and `clientId`
- [ ] Returns `404 Not Found` if document ID does not exist or does not belong to `clientId`

**Technical Notes:**

- ChromaDB delete filter: `collection.delete(where={"$and": [{"documentId": document_id}, {"clientId": client_id}]})`
- Neo4j purge query: `MATCH (n:BrandEntity {documentId: $documentId, clientId: $clientId}) DETACH DELETE n`

**Dependencies:**
Blocks: None. Blocked by: DA-AI03-01.

**Implementation Details:**

- **Files affected:** `app/services/embedding.py`
- **Functions/Classes to create:** `class EmbeddingService` with function `def store_chunks(self, client_id: str, document_id: str, chunks: List[str])`
- **Processing flow:**
  1. Initialize ChromaDB client connecting to host/port from configuration.
  2. Retrieve or create collection named `client_{client_id}`.
  3. Load the local `sentence-transformers/all-MiniLM-L6-v2` model.
  4. Perform batch insert (50 chunks/batch) inserting vector list with metadata into ChromaDB.
- **Code Skeleton:**

```python
# app/services/embedding.py
import chromadb
from sentence_transformers import SentenceTransformer

class EmbeddingService:
    def __init__(self, chromadb_host: str, chromadb_port: int):
        self.chroma_client = chromadb.HttpClient(host=chromadb_host, port=chromadb_port)
        self.embed_model = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

    def store_chunks(self, client_id: str, document_id: str, chunks: list[str]):
        collection = self.chroma_client.get_or_create_collection(name=f"client_{client_id}")

        batch_size = 50
        for i in range(0, len(chunks), batch_size):
            batch_chunks = chunks[i:i+batch_size]
            embeddings = self.embed_model.encode(batch_chunks).tolist()
            ids = [f"{document_id}_{idx}" for idx in range(i, i+len(batch_chunks))]
            metadatas = [{"documentId": document_id, "clientId": client_id, "chunkIndex": idx} for idx in range(i, i+len(batch_chunks))]

            collection.add(
                documents=batch_chunks,
                embeddings=embeddings,
                metadatas=metadatas,
                ids=ids
            )
```

---

### DA-AI03-03.1 — Build Neo4j connection pool management (app/core/neo4j.py)

**Assignee:** Lộc (Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Create a Singleton connection manager to Neo4j to ensure thread-safe, fast graph DB queries.

**Acceptance Criteria:**

- [ ] Implement Singleton `Neo4jDatabase` in `app/core/neoj4.py`
- [ ] Support context-managed sessions for query execution

**Dependencies:** Blocks: DA-AI03-03.2, DA-AI03-04.1. Blocked by: DA-AI03-03.

**Implementation Details:**

- **Files affected:** `app/core/neoj4.py`
- **Functions/Classes to create:** `class Neo4jDatabase` (Singleton Pattern) with context-managed functions.
- **Processing flow:**
  1. Read URI/User/Password config from `.env` and create a `GraphDatabase.driver()` instance.
  2. Provide safe Cypher query execution via session context managers (`execute_read`, `execute_write`).
- **Code Skeleton:**

```python
# app/core/neoj4.py
from neo4j import GraphDatabase

class Neo4jDatabase:
    _instance = None

    def __new__(cls, uri=None, user=None, password=None):
        if cls._instance is None:
            cls._instance = super(Neo4jDatabase, cls).__new__(cls)
            cls._instance.driver = GraphDatabase.driver(uri, auth=(user, password))
        return cls._instance

    def query(self, cypher_query: str, parameters: dict = None):
        with self.driver.session() as session:
            result = session.run(cypher_query, parameters or {})
            return [record.data() for record in result]
```

---

### DA-AI03-03.2 — NER extraction and relations ingestion into Neo4j using Cypher

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Extract entities and relations from text chunks and insert them into Neo4j using `MERGE` statements.

**Acceptance Criteria:**

- [ ] Implement `NERGraphService` in `app/services/graph_ingestion.py`
- [ ] Write Cypher queries using `MERGE` to store Nodes (`User`, `Trend`, `Community`) and Edges (`POSTED`, `INTERACTED`)

**Dependencies:** Blocks: DA-AI03-04.1. Blocked by: DA-AI03-03.1.

**Implementation Details:**

- **Files affected:** `app/services/graph_ingestion.py`
- **Functions/Classes to create:** `class NERGraphService` with function `def inject_relation(self, client_id: str, document_id: str, relation: dict)`
- **Processing flow:**
  1. Send chunk to LLM to extract entities and relations (JSON format).
  2. Execute Cypher queries using `MERGE` clause to insert into Neo4j (using `clientId` and `documentId` labels for tenant isolation).
- **Code Skeleton:**

```python
# app/services/graph_ingestion.py
from app.core.neoj4 import Neo4jDatabase

class NERGraphService:
    def __init__(self, db: Neo4jDatabase):
        self.db = db

    def inject_relation(self, client_id: str, document_id: str, relation: dict):
        query = f"""
        MERGE (s:{relation['source_type']} {{name: $source, clientId: $clientId}})
        MERGE (t:{relation['target_type']} {{name: $target, clientId: $clientId}})
        MERGE (s)-[r:{relation['relation']} {{documentId: $documentId}}]->(t)
        """
        self.db.query(query, {
            "source": relation["source"],
            "target": relation["target"],
            "clientId": client_id,
            "documentId": document_id
        })
```

---

### DA-AI03-03.3 — Implement query normalization (lowercase, remove emoji, slang replacement)

**Assignee:** Lộc (Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Clean user query text to match entities in database by removing emoji, punctuation, and correcting abbreviations.

**Acceptance Criteria:**

- [ ] Implement `QueryNormalizer` in `app/services/normalization.py` using synonym map

**Dependencies:** Blocks: DA-AI03-04. Blocked by: DA-AI03-03.

**Implementation Details:**

- **Files affected:** `app/services/normalization.py`
- **Functions/Classes to create:** `class QueryNormalizer` with function `def normalize_query(self, query: str) -> str`
- **Processing flow:**
  1. Remove emojis and special characters using Regex.
  2. Replace abbreviations and slang with standard Vietnamese words using a pre-configured JSON dictionary.
- **Code Skeleton:**

```python
# app/services/normalization.py
import re
import json

class QueryNormalizer:
    def __init__(self, dict_path: str):
        with open(dict_path, 'r', encoding='utf-8') as f:
            self.synonyms = json.load(f)

    def normalize_query(self, query: str) -> str:
        query = re.sub(r'[^\w\s]', '', query).lower().strip()
        words = query.split()
        normalized_words = [self.synonyms.get(w, w) for w in words]
        return " ".join(normalized_words)
```

---

### DA-AI03-04 — Implement semantic search (query → embedding → top-K retrieval from ChromaDB filtered by clientId)

# **Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

### DA-AI03-03 — Document Chunking & Multi-tenant Tagging Engine (`clientId` Security Isolation)

> > > > > > > 5c259fda04390825822aed6b514cff238aa9e22a

**Goal:** Chunk uploaded brand documents and tag all vector embeddings and knowledge graph nodes with `clientId` metadata to ensure multi-tenant security isolation.

**Acceptance Criteria:**

- [ ] Uses LangChain `RecursiveCharacterTextSplitter` with `chunk_size = 500` characters and `chunk_overlap = 50` characters
- [ ] Embeds text chunks via `all-MiniLM-L6-v2` (384d) and stores in ChromaDB HNSW Index with mandatory metadata: `{clientId, documentId, chunkIndex}`
- [ ] Extracts brand entities/relations via LLM NER and ingests into Neo4j graph with `:BrandEntity {clientId: $clientId}` label
- [ ] Guarantees zero cross-tenant data leakage during vector and graph queries

**Technical Notes:**

- Every ChromaDB vector query and Neo4j Cypher traversal for brand knowledge MUST enforce `clientId` filtering.

**Dependencies:**
Blocks: DA-AI03-04. Blocked by: DA-AI03-01.

**Implementation Details:**

- **Files affected:** `app/services/search.py`
- **Functions/Classes to create:** `def search(self, query: str, client_id: str, k: int = 5) -> List[str]`
- **Processing flow:**
  1. Vectorize query using `all-MiniLM-L6-v2` model.
  2. Query ChromaDB collection `client_{client_id}` filtering by metadata `clientId == client_id`.
  3. Retrieve Top-K nearest results.
- **Code Skeleton:**

```python
# app/services/search.py
class SemanticSearchService:
    def __init__(self, chroma_client, embed_model):
        self.chroma_client = chroma_client
        self.embed_model = embed_model

    def search(self, query: str, client_id: str, k: int = 5) -> list:
        collection = self.chroma_client.get_collection(name=f"client_{client_id}")
        query_vector = self.embed_model.encode(query).tolist()

        results = collection.query(
            query_embeddings=[query_vector],
            n_results=k,
            where={"clientId": client_id}
        )
        return results["documents"][0] if results["documents"] else []
```

---

### DA-AI03-04.1 — Build graph traversal service (1-2 hops BFS/DFS in Neo4j)

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Traverse local interaction graph 1-2 hops from starting entity nodes to fetch related context.

**Acceptance Criteria:**

- [ ] Implement `GraphTraversalService` in `app/services/graph_traversal.py`

**Dependencies:** Blocks: DA-AI03-04.2. Blocked by: DA-AI03-04, DA-AI03-03.2.

**Implementation Details:**

- **Files affected:** `app/services/graph_traversal.py`
- **Functions/Classes to create:** `class GraphTraversalService` with function `def traverse(self, entry_points: List[str], client_id: str) -> List[dict]`
- **Processing flow:**
  1. From the list of `entry_points`, run Cypher to traverse Neo4j within 1-2 hops (Limit 50).
  2. Aggregate the list of related entities and return.
- **Code Skeleton:**

```python
# app/services/graph_traversal.py
from app.core.neoj4 import Neo4jDatabase

class GraphTraversalService:
    def __init__(self, db: Neo4jDatabase):
        self.db = db

    def traverse(self, entry_points: list[str], client_id: str) -> list[dict]:
        query = """
        MATCH (start:Entity {clientId: $clientId})
        WHERE start.name IN $entryPoints
        MATCH path = (start)-[r:PROMOTED|CHECK_IN_AT|BELONGS_TO*1..2]-(connected:Entity)
        RETURN start.name AS source, type(r[0]) AS rel, connected.name AS target
        LIMIT 50
        """
        return self.db.query(query, {"entryPoints": entry_points, "clientId": client_id})
```

---

### DA-AI03-04.2 — Implement BM25 scoring & graph node pruning

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Prune traversal output nodes using BM25 relevance score against query to filter noise.

**Acceptance Criteria:**

- [ ] Implement `GraphPruningService` in `app/services/pruning.py` using `rank_bm25`

**Dependencies:** Blocks: DA-AI03-05. Blocked by: DA-AI03-04.1.

**Implementation Details:**

- **Files affected:** `app/services/pruning.py`
- **Functions/Classes to create:** `class GraphPruningService` with function `def prune(self, query: str, traversed_nodes: List[dict]) -> List[dict]`
- **Processing flow:**
  1. Tokenize query and node descriptions.
  2. Score BM25 for each node against the query using `rank_bm25` library.
  3. Prune nodes below threshold (threshold < 1.0) and return.
- **Code Skeleton:**

```python
# app/services/pruning.py
from rank_bm25 import BM25Okapi

class GraphPruningService:
    def prune(self, query: str, traversed_nodes: list[dict], threshold: float = 1.0) -> list[dict]:
        if not traversed_nodes:
            return []
        corpus = [node["target"].split() for node in traversed_nodes]
        bm25 = BM25Okapi(corpus)

        scores = bm25.get_scores(query.split())
        return [traversed_nodes[idx] for idx, score in enumerate(scores) if score >= threshold]
```

---

### DA-AI03-05 — Build RAG context builder (format top-K chunks into context string for LLM prompt)

# **Assignee:** Ân (AI) | **Priority:** 🔴 Critical

### DA-AI03-04 — Test RAG Accuracy for Brand Knowledge Base

> > > > > > > 5c259fda04390825822aed6b514cff238aa9e22a

**Goal:** Validate retrieval precision and answer accuracy for brand knowledge RAG queries across multi-tenant contexts.

**Acceptance Criteria:**

- [ ] Upload 3 real brand documents from different industries (fashion, F&B, tech)
- [ ] Perform 10 test queries per brand document; verify retrieved context precision ≥ 80%
- [ ] Verify 0% cross-tenant data leakage (Client A queries never return Client B document chunks)
- [ ] Verify zero factual hallucinations in generated answers against brand guidelines

**Technical Notes:**

- Tech stack: Python, pytest, ChromaDB, Groq Llama 3.
- Automated test suite validating precision/recall and tenant isolation.

**Dependencies:**
Blocks: DA-AI03-05. Blocked by: DA-AI03-03.

**Implementation Details:**

- **Files affected:** `app/services/context_builder.py`
- **Functions/Classes to create:** `class RAGContextBuilder` with function `def build(self, chunks: List[str], relations: List[dict]) -> str`
- **Processing flow:**
  1. Group ChromaDB chunks into indexed lists `[1]`, `[2]`.
  2. Format Neo4j relations logically: `- Entity [source] has relation [rel] to [target]`.
  3. Concatenate into a single context string, capped at 3000 characters.
- **Code Skeleton:**

```python
# app/services/context_builder.py
class RAGContextBuilder:
    def build(self, chunks: list[str], relations: list[dict]) -> str:
        context_parts = ["=== Brand Document Content ==="]
        for idx, chunk in enumerate(chunks):
            context_parts.append(f"[{idx+1}] {chunk}")

        context_parts.append("\n=== Brand Graph Connections ===")
        for rel in relations:
            context_parts.append(f"- Entity [{rel['source']}] has relation [{rel['rel']}] to [{rel['target']}]")

        return "\n".join(context_parts)
```

---

### DA-AI03-06 — Document deletion endpoint (remove chunks from ChromaDB + file from S3)

# **Assignee:** Lộc (Sub-lead) | **Priority:** 🟡 High

### DA-AI03-05 — Write RAG Pipeline & Multi-tenant Isolation Documentation

> > > > > > > 5c259fda04390825822aed6b514cff238aa9e22a

**Goal:** Produce complete technical documentation covering the Brand Knowledge Ingestion flow, chunking parameters, vector/graph schema, and multi-tenant security isolation mechanisms.

**Acceptance Criteria:**

- [ ] Document covers end-to-end data flow (Upload -> S3 -> Chunking -> ChromaDB/Neo4j Tagging -> Multi-tenant Querying)
- [ ] Details multi-tenant security compliance rules and tuning parameters (`chunk_size=500`, `overlap=50`)
- [ ] Outlines evaluation results from accuracy testing in DA-AI03-04

**Technical Notes:**

- Location: `docs/architecture/rag_pipeline_multitenant_isolation.md`.

**Dependencies:**
Blocks: DA-AI04-01. Blocked by: DA-AI03-04.

---

## PHẦN II: CHI TIẾT CÀI ĐẶT EPIC AI-04 (LLM CONTENT GENERATION)

> **Jira Epic:** [`DA-79: AI-04 — LLM Content Generation`](https://letritrung2605.atlassian.net/browse/DA-79) | **Lộ trình:** AI Iteration 2 (Sprint 8)

---

### DA-AI04-01 — Build prompt template system (receive topic + RAG context + trend data + tone → generate full prompt)

**Jira Key:** [`DA-240`](https://letritrung2605.atlassian.net/browse/DA-240) | **Assignee:** Ân (AI) | **Priority:** 🔴 Critical

### DA-AI03-09 — Create Entity Resolution background cron job (merge duplicate nodes)

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Automatically clean duplicate entities (e.g. synonyms) in Neo4j database periodically.

**Acceptance Criteria:**

- [ ] Implement `EntityResolutionService` in `app/services/entity_resolution.py`
- [ ] Merge nodes with cosine similarity > 85% using Neo4j APOC `apoc.refactor.mergeNodes`

**Dependencies:** Blocks: None. Blocked by: DA-AI03-03.2.

**Implementation Details:**

- **Files affected:** `app/services/entity_resolution.py` and `app/core/scheduler.py`
- **Functions/Classes to create:** `class EntityResolutionService` with function `def resolve(self, client_id: str)`
- **Processing flow:**
  1. Fetch entity node names within Neo4j database.
  2. Embed names using MiniLM and compute cosine similarity.
  3. For node pairs with similarity > 85% (e.g., "HN" and "Hà Nội"), execute APOC merge Cypher query `apoc.refactor.mergeNodes`.
- **Code Skeleton:**

```python
# app/services/entity_resolution.py
from app.core.neoj4 import Neo4jDatabase
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity

class EntityResolutionService:
    def __init__(self, db: Neo4jDatabase):
        self.db = db
        self.model = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

    def resolve(self, client_id: str):
        nodes = self.db.query("MATCH (n:Location {clientId: $clientId}) RETURN n.name as name", {"clientId": client_id})
        names = [n["name"] for n in nodes]
        if len(names) < 2: return

        embeddings = self.model.encode(names)
        sim_matrix = cosine_similarity(embeddings)

        for i in range(len(names)):
            for j in range(i+1, len(names)):
                if sim_matrix[i][j] > 0.85:
                    merge_query = """
                    MATCH (n1:Location {name: $name1, clientId: $clientId})
                    MATCH (n2:Location {name: $name2, clientId: $clientId})
                    CALL apoc.refactor.mergeNodes([n1, n2]) YIELD node
                    RETURN node
                    """
                    self.db.query(merge_query, {"name1": names[i], "name2": names[j], "clientId": client_id})
```

---

## PHẦN II: CHI TIẾT CÀI ĐẶT EPIC AI-04 (LLM CONTENT GENERATION)

---

### DA-AI04-01 — Build prompt template system (topic + RAG context + trend data + tone + platform → full LLM prompt)

**Goal:** Xây dựng hệ thống khuôn mẫu prompt có thể tái sử dụng và tầng Consumer Adapters độc lập (`BrandRAGAdapter` & `TrendContextAdapter`) theo chuẩn Interface-First / Dependency Injection để tầng sinh nội dung giao tiếp với tri thức thương hiệu và xu hướng qua interface/HTTP service tiêu chuẩn, đảm bảo cách ly hoàn toàn (zero-import) khỏi ChromaDB và Neo4j drivers.

**Acceptance Criteria:**

- [ ] Khai báo abstract protocols `IBrandRAGAdapter` và `ITrendContextAdapter` tại `services/adapters/interfaces.py`.
- [ ] Module `services/adapters/brand_rag_adapter.py` hiện thực `IBrandRAGAdapter`, cung cấp hàm `fetch_brand_context(client_id: str, topic: str, top_k: int = 3) -> BrandContextDTO`.
- [ ] Module `services/adapters/trend_adapter.py` hiện thực `ITrendContextAdapter`, cung cấp hàm `fetch_trend_context(trend_keyword: str) -> TrendContextDTO` kết nối với subsystem AI-05 đã hoàn thành.
- [ ] Module `services/prompt/prompt_builder.py` triển khai `build_caption_prompt(topic: str, brand_context: Optional[BrandContextDTO], trend_context: Optional[TrendContextDTO], tone: str, platform: str) -> PromptBundle`.
- [ ] Hỗ trợ 7 tone giọng: `professional`, `casual`, `humorous`, `inspirational`, `authoritative`, `empathetic`, `trendy`.
- [ ] System prompt luôn chứa chỉ thị chống ảo giác bất biến: _"Chỉ sử dụng thông tin được cung cấp trong [Brand Context]. Tuyệt đối không tự bịa đặt tính năng, giá bán, chính sách hoặc ưu đãi."_
- [ ] Cung cấp Mock implementations (`MockBrandRAGAdapter`, `MockTrendContextAdapter`) bàn giao cho Lộc vào cuối Day 2 để phục vụ testing và DI.

**Technical Notes:**

- Location: `app/services/prompt_builder.py`, `app/services/adapters/brand_adapter.py`, `app/services/adapters/trend_adapter.py`.
- Context format: `=== BRAND CONTEXT ===\n{rag_context}\n\n=== TREND CONTEXT ===\n{trend_data}`.

**Dependencies:**

- Blocks: DA-AI04-02, DA-AI04-05, DA-AI04-06.
- Blocked by: DA-AI03-05.

**Implementation Details:**

- **Files affected:** `app/services/prompt_builder.py`
- **Functions/Classes to create:** `class PromptBuilder` with function `def build(self, topic: str, context: str, tone: str, platform: str) -> str`
- **Processing flow:**
  1. Read prompt template using `Jinja2`.
  2. Assign hook formula based on `tone` and `platform` (Curiosity, Direct Benefit, FOMO).
  3. Render and return the complete prompt expecting a JSON response structure (Hook, Body, CTA).
- **Code Skeleton:**

```python
# app/services/prompt_builder.py
from jinja2 import Template

PROMPT_TEMPLATE = """
Write a social media post for {{ platform }} based on the context.
[CONTEXT]
{{ context }}
[USER REQUEST]
Topic: {{ topic }} | Tone: {{ tone }}
[REQUIREMENTS]
Return strictly a JSON object:
{"hook_3s": "Compelling hook using the {{ hook_formula }} formula under 15 words.", "body": "Post body.", "cta": "CTA"}
"""

class PromptBuilder:
    def build(self, topic: str, context: str, tone: str, platform: str) -> str:
        hook_formula = "Curiosity"
        if tone == "urgent": hook_formula = "FOMO"
        elif tone == "professional": hook_formula = "Direct Benefit"

        template = Template(PROMPT_TEMPLATE)
        return template.render(platform=platform, context=context, topic=topic, tone=tone, hook_formula=hook_formula)
```

---

### DA-AI04-02 — Integrate Llama 3 via Groq API (system prompt: "only use provided context, do not fabricate")

**Jira Key:** [`DA-253`](https://letritrung2605.atlassian.net/browse/DA-253) | **Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Tích hợp Primary LLM Provider (Llama 3 qua Groq API) vào engine sinh bài viết sử dụng output từ prompt template system làm input, tối ưu hóa tốc độ phản hồi và xử lý giới hạn request.

**Acceptance Criteria:**

- [ ] `services/llm.py` function `generate_caption_groq(prompt: str) -> str` calls Groq API with `llama3-8b-8192` or `llama3-70b-8192` model
- [ ] System message is always prepended; user message contains the assembled prompt from DA-AI04-01
- [ ] Rate limit (30 req/min) is handled: on `429` response, raise a custom `RateLimitError` that caller catches and routes to fallback
- [ ] Response text is returned stripped of leading/trailing whitespace; empty responses raise `LLMEmptyResponseError`

**Technical Notes:**

- Tech stack: `groq` Python SDK (`pip install groq`).
- Log every Groq call with model, prompt token count, completion token count, latency_ms.

**Dependencies:**

- Blocks: DA-AI04-03, DA-AI04-05, DA-AI04-07.
- Blocked by: DA-AI04-01, DA-AI02-02, DA-AI01-07.

**Implementation Details:**

- **Files affected:** `app/services/llm_coordinator.py`
- **Functions/Classes to create:** `class LLMCoordinator` with function `async def generate(self, prompt: str) -> dict`
- **Processing flow:**
  1. Send request to Groq API (`llama-3.1-70b-versatile`, `temperature=0.3`, JSON response format).
  2. Catch 429 rate limit or timeout errors and automatically failover to Claude API (`claude-3-5-sonnet`).
  3. Ensure clean JSON output format parsing and return.
- **Code Skeleton:**

```python
# app/services/llm_coordinator.py
from groq import Groq
from anthropic import Anthropic
import json

class LLMCoordinator:
    def __init__(self, groq_key: str, anthropic_key: str):
        self.groq_client = Groq(api_key=groq_key)
        self.claude_client = Anthropic(api_key=anthropic_key)

    async def generate(self, prompt: str) -> dict:
        try:
            completion = self.groq_client.chat.completions.create(
                model="llama-3.1-70b-versatile",
                messages=[{"role": "user", "content": prompt}],
                temperature=0.3,
                response_format={"type": "json_object"}
            )
            return json.loads(completion.choices[0].message.content)
        except Exception as e:
            message = self.claude_client.messages.create(
                model="claude-3-5-sonnet-20241022",
                max_tokens=1000,
                temperature=0.3,
                messages=[{"role": "user", "content": prompt}]
            )
            return json.loads(message.content[0].text)
```

---

### DA-AI04-03 — Integrate Fallback LLM API (Google Gemini 1.5 Flash / Claude) with Failover Circuit Breaker

**Jira Key:** [`DA-271`](https://letritrung2605.atlassian.net/browse/DA-271) | **Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Tích hợp Fallback LLM Client (Google Gemini `gemini-1.5-flash` / Claude) kết hợp bộ định tuyến chịu lỗi áp dụng mẫu Circuit Breaker 3 trạng thái, tự động chuyển mạch khi Groq gặp lỗi rate-limit (HTTP 429), lỗi mạng hoặc timeout.

**Acceptance Criteria:**

- [ ] Module `services/llm/gemini_client.py` hiện thực `generate_with_gemini(prompt_bundle: PromptBundle, temperature: float = 0.7, max_tokens: int = 1024) -> LLMOutput` sử dụng package `google-genai` / `google-generativeai`.
- [ ] Module `utils/circuit_breaker.py` hiện thực Circuit Breaker 3 trạng thái: `CLOSED` (bình thường), `OPEN` (ngắt mạch khi lỗi $> 50\%$ trong 10 req), `HALF_OPEN` (thử nghiệm sau 60s).
- [ ] Module `services/llm/resilient_router.py` cung cấp hàm `generate_caption_resilient(prompt_bundle: PromptBundle) -> LLMResponse`.
- [ ] Khai báo interface protocol `ILLMRouter` tại `services/llm/protocols.py` và FastAPI dependency provider `get_llm_router() -> ILLMRouter` trong `app/api/v1/deps.py`.
- [ ] Cung cấp `MockLLMRouter` cho Lộc và Ân viết unit test độc lập qua `app.dependency_overrides`.
- [ ] Gắn nhãn tường minh metadata trong response: `provider="gemini"`, `fallback_used=True`, `fallback_reason="groq_rate_limited"`.

**Technical Notes:**

- Tránh phụ thuộc thư viện ngoài phức tạp; triển khai in-memory Circuit Breaker thread-safe hoặc dựa trên Redis nếu cần chia sẻ state đa worker.
- Đóng vai trò là LLM provider chính cho Orchestrator `DA-AI04-06` và Regenerate `DA-AI04-09`.

**Dependencies:**

- Blocks: DA-AI04-10 (Hard Gate); DA-AI04-06 & DA-AI04-09 (Soft Interface — downstream dev sử dụng MockLLMRouter).
- Blocked by: DA-AI04-03, DA-AI04-04 (Bắt đầu sau khi hoàn tất tích hợp 2 SDKs).

---

### DA-AI04-06 — Content Generation Pipeline Orchestrator & API Endpoint

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Xây dựng bộ điều phối pipeline sinh nội dung và publish endpoint `POST /api/v1/ai/content/generate`, kết nối các Adapter dữ liệu, Prompt Builder và Failover LLM Router thành luồng nghiệp vụ hoàn chỉnh thông qua Dependency Injection.

**Acceptance Criteria:**

- [ ] Endpoint `POST /api/v1/ai/content/generate` tiếp nhận `ContentGenerateRequest(client_id, topic, platform, tone, trend_keyword, ...)` và trả về `ContentGenerateResponse`.
- [ ] Pipeline thực thi bất đồng bộ: Gọi đồng thời RAG Adapter & Trend Adapter qua `asyncio.gather(..., return_exceptions=True)`.
- [ ] Đưa kết quả vào Prompt Builder $\rightarrow$ Gửi đến Resilient LLM Router (`DA-AI04-05`).
- [ ] Tự động chạy hậu xử lý cắt chuỗi an toàn (`truncate_caption` từ `DA-AI04-07`).
- [ ] Trả về đầy đủ payload gồm: `caption`, `platform`, `tone`, `provider_used`, `fallback_used`, `generation_time_ms`.
- [ ] Bộ unit test hoàn chỉnh (`tests/test_content_orchestrator.py`) mock 100% các dependencies qua `app.dependency_overrides`, đảm bảo endpoint pass toàn bộ test cases mà không cần kết nối live DB hay live LLM API.

**Technical Notes:**

- Router FastAPI đặt tại `app/api/v1/endpoints/content.py`.
- Áp dụng triệt để FastAPI Dependency Injection (`Depends(get_brand_rag_adapter)`, `Depends(get_trend_context_adapter)`, `Depends(get_llm_router)`), cho phép Lộc inject các Mock Adapter và Mock LLM Router để test độc lập luồng pipeline ngay từ Day 3 mà không cần chờ live services (ChromaDB, Neo4j, Groq, Gemini) sẵn sàng.
- Giám sát độ trễ toàn trình (P95 target $< 3.0$s khi dùng Groq).

**Dependencies:**

- Soft Dependencies (Interface/Contract Decoupled via DI — Không bị block): Phụ thuộc vào interface của `DA-AI04-01`, `DA-AI04-02`, `DA-AI04-05`. Lộc code và viết unit tests ngay từ Day 3 bằng Mock implementations, không chờ đợi.
- Hard Pre-requisite: `DA-AI04-07` (`truncate_caption` — do chính Lộc tự hoàn thành ở Day 1-2).
- Downstream Target: Cung cấp pipeline cho `DA-AI04-10` (Integration Quality Gate).

**Implementation Details:**

- **Files affected:** `app/services/llm_coordinator.py`
- **Functions/Classes to create:** `class ClaudeFallbackService`
- **Processing flow:**
  1. Trigger Claude API (`claude-3-5-sonnet`) when Groq API raises `RateLimitError` or timeout.
  2. Pass the exact same prompt context and JSON formatting instructions.
  3. Log the failover event to monitoring.
- **Code Skeleton:**

```python
# app/services/llm_coordinator.py
from groq import Groq
from anthropic import Anthropic
import json

class LLMCoordinator:
    def __init__(self, groq_key: str, anthropic_key: str):
        self.groq_client = Groq(api_key=groq_key)
        self.claude_client = Anthropic(api_key=anthropic_key)

    async def generate(self, prompt: str) -> dict:
        try:
            completion = self.groq_client.chat.completions.create(
                model="llama-3.1-70b-versatile",
                messages=[{"role": "user", "content": prompt}],
                temperature=0.3,
                response_format={"type": "json_object"}
            )
            return json.loads(completion.choices[0].message.content)
        except Exception as e:
            message = self.claude_client.messages.create(
                model="claude-3-5-sonnet-20241022",
                max_tokens=1000,
                temperature=0.3,
                messages=[{"role": "user", "content": prompt}]
            )
            return json.loads(message.content[0].text)
```

---

### DA-AI04-04 — Implement platform-specific caption truncation (FB 63k, Threads 500, TikTok 4k chars)

**Jira Key:** [`DA-286`](https://letritrung2605.atlassian.net/browse/DA-286) | **Assignee:** Lộc (Sub-lead) | **Priority:** 🟡 High

**Goal:** Đảm bảo bài viết sinh ra không bao giờ bị các nền tảng mạng xã hội từ chối do vượt quá giới hạn ký tự, áp dụng thuật toán cắt câu thông minh (Sentence Delimiter Truncation).

**Acceptance Criteria:**

- [ ] Module `utils/truncation.py` hiện thực `truncate_caption(text: str, platform: str) -> str`.
- [ ] Giới hạn ký tự từng nền tảng: Facebook: 63,206, Threads: 500, TikTok: 4,000, Instagram: 2,200, Zalo: 10,000 chars.
- [ ] Thuật toán cắt tại dấu kết thúc câu gần nhất (`.`, `!`, `?`, `\n`) trước ngưỡng giới hạn, không cắt đứt từ ngữ giữa chừng; thêm `"..."` nếu bị cắt.
- [ ] Bộ unit tests độc lập bao phủ 100% các edge cases (chuỗi đúng giới hạn, chuỗi vượt 1 ký tự, giới hạn Threads).

**Technical Notes:**

- File: `app/utils/truncation.py`. Pure standalone string utility, zero external dependencies.
  **Assignee:** Lộc (Sub-lead) | **Priority:** 🟡 High

**Dependencies:**

- Blocks: DA-AI04-07.
- Blocked by: **None** (Bắt đầu ngay từ Day 1, Zero blocking!).

**Implementation Details:**

- **Files affected:** `app/services/length_optimizer.py`
- **Functions/Classes to create:** `class LengthOptimizer` with function `def optimize(self, content: dict, platform: str) -> dict`
- **Processing flow:**
  1. Validate generated post length against platform limits (FB: 63k, Threads: 500, TikTok: 4k chars).
  2. If limits are exceeded, request LLM to summarize/shorten while retaining core brand context.
  3. Return modified JSON payload.
- **Code Skeleton:**

```python
# app/services/length_optimizer.py
class LengthOptimizer:
    def optimize(self, post_data: dict, platform: str) -> dict:
        body = post_data["body"]
        if platform == "threads" and len(body) > 500:
            # Gọi LLM tóm tắt cô đọng (Call Haiku summarize)
            pass
        elif platform == "tiktok" and len(body) > 4000:
            body = self.smart_truncate(body, max_chars=3950)
        post_data["body"] = body
        return post_data

    def smart_truncate(self, text: str, max_chars: int) -> str:
        if len(text) <= max_chars: return text
        truncated = text[:max_chars]
        last_end = max(truncated.rfind('.'), truncated.rfind('!'), truncated.rfind('?'))
        return truncated[:last_end + 1] + "..." if last_end != -1 else truncated + "..."
```

---

### DA-AI04-05 — Implement hashtag generation endpoint (POST /ai/content/hashtags)

**Jira Key:** [`DA-231`](https://letritrung2605.atlassian.net/browse/DA-231) | **Assignee:** Lộc (Sub-lead) | **Priority:** 🟡 High

**Goal:** Cung cấp tính năng và endpoint API chuyên biệt `POST /api/v1/ai/content/hashtags` để người dùng có thể yêu cầu danh sách hashtag tối ưu độc lập với việc sinh bài viết.

**Acceptance Criteria:**

- [ ] Endpoint `POST /api/v1/ai/content/hashtags` tiếp nhận `{caption: str, platform: str, clientId: str, count: int}` và trả về `{hashtags: List[str]}`.
- [ ] Gọi Groq SDK với prompt chuyên biệt trích xuất hashtag.
- [ ] Hashtags được format không dấu cách, có tiền tố `#` (ví dụ `#thoiTrang`, không phải `#thoi trang`).
- [ ] Giới hạn số lượng theo best practices từng nền tảng (Instagram: tối đa 30, TikTok: tối đa 10, Nền tảng khác: tối đa 5).

**Technical Notes:**

- File: `app/api/v1/endpoints/content.py` và `app/services/hashtag_extractor.py`.
- Tận dụng Groq client SDK có sẵn từ `DA-AI04-02`.

### DA-AI04-05 — Implement hashtag generation endpoint (POST /ai/content/hashtags)

# **Assignee:** Lộc (Sub-lead) | **Priority:** 🟡 High

### DA-AI04-05 — Implement hashtag generation endpoint (POST /api/v1/ai/content/hashtags)

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

> > > > > > > 5c259fda04390825822aed6b514cff238aa9e22a

**Goal:** Provide an automated API endpoint to extract and generate relevant social media hashtags based on caption content, brand industry, and current trending topics.

**Acceptance Criteria:**

- [ ] Endpoint `POST /api/v1/ai/content/hashtags` accepts `{caption: str, platform: str, count: int}` and returns `{hashtags: List[str]}`
- [ ] Calls Llama 3 via Groq with specialized hashtag extraction prompt
- [ ] Filters out duplicate, banned, or offensive hashtags
- [ ] Formats hashtags according to platform best practices (3-5 for IG/Threads, 5-10 for TikTok)

**Technical Notes:**

- Endpoint: `POST /api/v1/ai/content/hashtags`.
- Response format: `{"hashtags": ["#BrandHub", "#ContentAI", "#MarketingTrends"]}`.

**Dependencies:**

- Blocks: DA-AI04-07.
- Blocked by: DA-AI04-02.

**Implementation Details:**

- **Files affected:** `app/api/v1/generate.py` and `app/services/hashtag_extractor.py`
- **Functions/Classes to create:** `class HashtagExtractor` with function `def extract_hashtags(self, content: str, brand_name: str, trend_name: str) -> List[str]`
- **Processing flow:**
  1. LLM extracts distinctive keywords from text.
  2. Normalize Vietnamese text to remove spaces, accents, and special characters, formatting as CamelCase hashtags (e.g. `#trasuanuong`).
  3. Append brand hashtags and trending hashtags, deduplicate and return.
- **Code Skeleton:**

```python
# app/services/hashtag_extractor.py
import re
import unicodedata

class HashtagExtractor:
    def normalize(self, text: str) -> str:
        text = unicodedata.normalize('NFKD', text).encode('ascii', 'ignore').decode('utf-8')
        return re.sub(r'[^a-zA-Z0-9]', '', text).lower()

    def extract_hashtags(self, content: str, brand_name: str, trend_name: str) -> list[str]:
        # Trích lọc từ khóa
        keywords = ["do uong", "mua dong"]
        hashtags = [f"#{self.normalize(kw)}" for kw in keywords]
        hashtags.append(f"#{self.normalize(brand_name)}")
        hashtags.append(f"#{self.normalize(trend_name)}")
        return list(set(hashtags))
```

---

### DA-AI04-06 — Implement regenerate with feedback (receive previous caption + user feedback → generate improved version)

**Jira Key:** [`DA-246`](https://letritrung2605.atlassian.net/browse/DA-246) | **Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Cho phép người dùng chỉnh sửa và tinh chỉnh bài viết lặp đi lặp lại thông qua phản hồi bằng ngôn ngữ tự nhiên mà không cần bắt đầu lại từ đầu.

**Acceptance Criteria:**

- [ ] Endpoint `POST /api/v1/ai/content/regenerate` tiếp nhận `ContentRegenerateRequest(previous_caption: str, feedback: str, platform: str, client_id: str)` và trả về caption mới.
- [ ] Feedback được nhúng vào prompt: _"The previous caption was: {previous_caption}. User feedback: {feedback}. Generate an improved version."_
- [ ] Vẫn giữ nguyên các chỉ thị chống ảo giác và context RAG thương hiệu của `client_id`.
- [ ] Sử dụng FastAPI `Depends(get_llm_router)` để đảm bảo tính chịu lỗi khi gọi LLM.
- [ ] End-to-end test: Gửi bài viết cũ + feedback _"viết ngắn lại và vui vẻ hơn"_ $\rightarrow$ xác nhận bài viết mới ngắn hơn và có sự chuyển biến về tone giọng.

**Technical Notes:**

- File: `app/api/v1/endpoints/content.py`.
- Không truyền caption cũ dưới dạng assistant message để tránh LLM bị bám quá chặt vào câu chữ cũ; nhúng trực tiếp vào user prompt.

**Dependencies:**

- Blocks: DA-AI04-07.
- Blocked by: DA-AI04-01, DA-AI04-03.

**Implementation Details:**

- **Files affected:** `app/api/v1/generate.py`
- **Functions/Classes to create:** Endpoint `POST /ai/generate/refine` accepting `RefineRequest`
- **Processing flow:**
  1. Receive original post, feedback prompt, and `clientId`.
  2. Construct refinement prompt instructing LLM to shift tone/style according to feedback while strictly respecting initial RAG context.
  3. Call LLMCoordinator and return refined JSON.
- **Code Skeleton:**

```python
# app/api/v1/generate.py (Mục Refine)
from fastapi import APIRouter
from app.models.request import RefineRequest

router = APIRouter()

@router.post("/refine")
async def refine_content(req: RefineRequest):
    # 1. Khởi dựng prompt chỉnh sửa
    # prompt = render(REFINE_TEMPLATE, original_post=req.previousCaption, feedback=req.feedback)
    # 2. Gọi LLM Coordinator
    # return await llm_coordinator.generate(prompt)
    pass
```

---

## PHẦN III: CHI TIẾT CÀI ĐẶT EPIC AI-05 (TREND CRAWLER & SCORING SERVICE)

---

### DA-AI04-07 — Anti-hallucination test (verify 20 generated captions — every claim must be sourced from brand context)

**Jira Key:** [`DA-261`](https://letritrung2605.atlassian.net/browse/DA-261) | **Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Kiểm chứng toàn diện cơ chế chống ảo giác bằng cách sinh 20 bài viết dưới các chủ đề phức tạp và đối soát để xác nhận không có bất kỳ thông tin nào ngoài phạm vi RAG context được đưa vào bài viết.

**Acceptance Criteria:**

- [ ] Chạy bộ kiểm thử tự động trên 20 kịch bản sinh nội dung thực tế qua 5 bộ tri thức thương hiệu chuẩn.
- [ ] Xác nhận **100% dữ kiện** trong caption sinh ra phải map ngược về được các chunks RAG nguồn.
- [ ] Xác nhận **0% số điện thoại, giá tiền, hoặc ưu đãi bịa đặt**.
- [ ] Tỷ lệ ảo giác (Hallucination rate) = **0%** (bất kỳ sai lệch nào đều là blocker không nghiệm thu).

**Technical Notes:**

- Tech stack: Python, pytest, Groq Llama 3, ChromaDB.
- Location: `tests/test_anti_hallucination.py`.

**Dependencies:**

- Blocks: DA-AI04-08.
- Blocked by: DA-AI04-02, DA-AI04-03, DA-AI04-04.

---

### DA-AI04-08 — Write Prompt Engineering Documentation (template design, system prompt best practices, tone guide)

**Jira Key:** [`DA-274`](https://letritrung2605.atlassian.net/browse/DA-274) | **Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Đảm bảo toàn bộ khuôn mẫu prompt và hướng dẫn định dạng phong cách được tài liệu hóa đầy đủ để phục vụ mở rộng, bảo trì và tích hợp LLM trong tương lai.

**Acceptance Criteria:**

- [ ] Tài liệu hóa cấu trúc prompt, các biến truyền vào, quy tắc format từng nền tảng và hướng dẫn 7 tone giọng.
- [ ] Ghi chép cấu trúc `=== BRAND CONTEXT ===` và kỹ thuật Grounding rules chống ảo giác.
- [ ] Bảng so sánh thực nghiệm hiệu năng/chất lượng giữa Groq Llama 3 và Google Gemini 1.5 Flash.

**Technical Notes:**

- Location: `docs/ai/prompt_engineering_guide.md`.

**Dependencies:**

- Blocks: None.
- Blocked by: DA-AI04-01, DA-AI04-07.

---

### DA-AI05-07A — Neo4j Knowledge Graph Entity Traversal Service

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Xây dựng module truy vấn đồ thị độc lập, thực hiện duyệt 1-hop/2-hop từ node `:Trend` để trích xuất các thực thể liên quan mật thiết (KOLs, Thương hiệu, Sự kiện, Chủ đề con).

**Acceptance Criteria:**

- [ ] Module `services/trends/graph_retriever.py` cung cấp hàm `traverse_trend_graph(trend_keyword: str, depth: int = 1) -> List[GraphEntityRelation]`.
- [ ] Thực thi Cypher tối ưu:
  ```cypher
  MATCH (t:Trend {name: $trend_keyword})-[r:RELATED_TO|POPULAR_IN|MENTIONS]-(e)
  RETURN e.name AS entity_name, labels(e)[0] AS entity_type, type(r) AS relation_type, r.weight AS weight
  ORDER BY r.weight DESC LIMIT 15
  ```
- [ ] Index đồ thị được sử dụng trên `Trend.name` đảm bảo thời gian truy vấn $< 30$ms.
- [ ] Xử lý an toàn khi không tìm thấy node Trend hoặc khi Neo4j instance ngắt kết nối (trả về danh sách rỗng, không raise exception).

**Technical Notes:**

- Tech stack: `neo4j` Python driver, Async Session pooling.

- [ ] Document covers: prompt template structure (annotated with section purposes), system prompt rationale, tone parameter examples (one sample output per tone)
- [ ] Anti-hallucination approach is explained with the exact system prompt wording used
- [ ] Known prompt failure modes from DA-AI04-07 testing are listed with mitigations

**Dependencies:** Blocks: None. Blocked by: DA-AI04-07.

---

### DA-AI05-01 — Setup n8n flow to crawl trend data from Google Trends

**Assignee:** Tuấn (AI) | **Priority:** 🟡 High

**Goal:** Move trend collection out of hand-written Python and into a scheduled n8n workflow, so crawl frequency, sources, and retry policy can be changed from the n8n UI without redeploying the AI service.

**Acceptance Criteria:**

- [ ] `n8n` service added to `docker/docker-compose.infra.yml` (image `n8nio/n8n` pinned to a concrete tag, joined to `brandhub-network`, named volume `n8n-data:/home/node/.n8n`); editor port `5678` exposed only from `docker/docker-compose.dev.yml`
- [ ] `N8N_ENCRYPTION_KEY`, `N8N_BASIC_AUTH_USER`, `N8N_BASIC_AUTH_PASSWORD`, `GENERIC_TIMEZONE=Asia/Ho_Chi_Minh` declared in `docker/.env.example` and marked required (`:?`) in the compose file, matching the existing variable style
- [ ] Workflow `brandhub-trend-crawler` runs on a Schedule Trigger every 6 hours (aligned with the Redis TTL in DA-AI05-04)
- [ ] Workflow fetches Vietnam trending keywords through an HTTP Request node against the Google Trends daily-trends feed (`geo=VN`, `hl=vi`); a manual run returns ≥ 20 keywords
- [ ] A Code node normalizes every item to `{keyword: str, score: int, source: "google", crawledAt: ISO8601}` — the shape DA-AI05-03 consumes
- [ ] Workflow POSTs the batch to `POST /internal/trends/ingest` on the AI service with a shared-secret header; the node retries 3× with exponential backoff, and a failing run routes to an n8n Error Workflow that notifies the team channel
- [ ] Workflow exported with credentials excluded and committed at `docker/n8n/workflows/trend_crawler.json` so it can be re-imported on any environment
- [ ] Runbook documented (import workflow → set credentials → manual run → read execution log)

**Technical Notes:**

- `pytrends` is dropped for this task: it is an unofficial client that breaks whenever Google changes its response shape. Hitting the RSS feed directly from an HTTP Request node is easier to keep alive, and a format change is fixed in the n8n UI instead of via a redeploy.
- Never commit a raw export — n8n writes credential references into workflow JSON. Export with credentials excluded and keep secrets in n8n Credentials backed by `N8N_ENCRYPTION_KEY`.
- Without a persistent `/home/node/.n8n` volume **and** a fixed `N8N_ENCRYPTION_KEY`, every stored credential becomes unreadable the next time the container is recreated.
- n8n reaches the AI service by container name on `brandhub-network` (e.g. `http://brandhub-ai-service:8000`), not `localhost`.
- Community edition (fair-code / Sustainable Use License) is free for internal self-hosted use — no license cost for this deployment.
- # If Google blocks the VPS IP, add a proxy to the HTTP Request node rather than moving the logic back into Python.
- [ ] Documentation published at `docs/ai/prompt_engineering_guide.md`
- [ ] Includes full prompt templates for Facebook, Instagram, TikTok, and Threads
- [ ] Details anti-hallucination system prompt rules and tone adjustment parameters

**Technical Notes:**

- Tech stack: Markdown.
  > > > > > > > 5c259fda04390825822aed6b514cff238aa9e22a

**Dependencies:**
Blocks: DA-AI05-07C. Blocked by: DA-AI05-04, DA-AI05-23.

---

### DA-AI05-07B — ChromaDB Trend Vector Snippet Retrieval Service

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Xây dựng module semantic vector search độc lập trong bộ sưu tập `social_trend_chunks` để tìm kiếm các bài viết, trích đoạn thảo luận có điểm tương tác cao liên quan đến xu hướng.

**Acceptance Criteria:**

- [ ] Module `services/trends/vector_retriever.py` cung cấp hàm `search_trend_snippets(trend_keyword: str, top_k: int = 4) -> List[TrendSnippetDTO]`.
- [ ] Embed từ khóa tìm kiếm bằng model `all-MiniLM-L6-v2` (384d) và truy vấn collection `social_trend_chunks`.
- [ ] Lọc kết quả metadata theo ngưỡng tương tác (`virality_score >= 0.5`) nếu có.
- [ ] Trả về danh sách snippets sạch gồm: `text_snippet`, `platform`, `author`, `engagement_score`, `similarity_score`.
- [ ] Đảm bảo timeout truy vấn $< 80$ms.

**Technical Notes:**

- Tái sử dụng ChromaDB client cấu hình từ `utils/clients.py`.

**Dependencies:**
Blocks: DA-AI05-07C. Blocked by: DA-AI05-04, DA-AI05-21.

---

### DA-AI05-07C — Trend Context Synthesizer & Token Optimizer Engine

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Hợp nhất các quan hệ từ đồ thị tri thức (DA-AI05-07A) và các trích đoạn văn bản vector (DA-AI05-07B) thành một chuỗi ngữ cảnh Markdown súc tích, giới hạn chặt chẽ dưới 800 tokens, tổng hợp viral hooks và tiếng lóng cộng đồng.

**Acceptance Criteria:**

- [ ] Module `services/trends/context_formatter.py` cung cấp hàm `synthesize_trend_context(trend_keyword: str, graph_data: List[GraphEntityRelation], snippets: List[TrendSnippetDTO]) -> TrendSynthesizedContext`.
- [ ] Context định dạng cấu trúc Markdown chuẩn:
  ```markdown
  ### TREND CONTEXT: {trend_keyword}

  - Related Entities: {comma-separated entities with types}
  - Key Discussions & Angles: {bullet points summarized from top snippets}
  - Community Slang & Hooks: {extracted keywords/phrases}
  ```
- [ ] Ràng buộc Token Limit nghiêm ngặt: Kiểm tra số token bằng tokenizer; nếu vượt quá 800 tokens, tự động cắt tỉa các snippet có score thấp hơn.
- [ ] Chuyển đổi dữ liệu sang DTO `TrendContextResponse` có trường `formatted_context` sẵn sàng đưa vào prompt LLM.

**Technical Notes:**

- Tích hợp hàm `score_keywords` (BM25) nếu cần loại bỏ các thực thể nhiễu không phổ biến.

**Dependencies:**
Blocks: DA-AI05-07D, DA-AI05-07E. Blocked by: DA-AI05-07A, DA-AI05-07B.

---

### DA-AI05-07D — Redis Trend Context Read-Through Cache Layer

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Xây dựng tầng cache Read-Through trên Redis cho Trend Context đã tổng hợp, giúp giảm tải tối đa cho Neo4j và ChromaDB, đưa latency phục vụ xuống mức sub-15ms.

**Acceptance Criteria:**

- [ ] Module `services/trends/context_cache.py` quản lý 2 hàm: `get_cached_context(trend_slug: str) -> Optional[TrendContextResponse]` và `set_cached_context(trend_slug: str, data: TrendContextResponse, ttl_seconds: int = 1800)`.
- [ ] Chuẩn hóa key lưu trữ: `trends:context:{trend_slug}` (sử dụng slug tiếng Việt không dấu, e.g. `tra-sua-dat-nung`).
- [ ] Đặt thời gian sống (TTL) mặc định 30 phút (1,800 giây).
- [ ] Benchmark kiểm tra: Thời gian phản hồi khi hit cache đạt $\le 15$ms.
- [ ] Nếu Redis down hoặc mất kết nối: Tự động pass-through qua bộ tính toán mà không gây gián đoạn API.

**Technical Notes:**

- Tech stack: `redis-py` async, serialization qua Pydantic JSON encoder.

**Dependencies:**
Blocks: DA-AI05-07E. Blocked by: DA-AI05-16.

---

### DA-AI05-07E — Unified Trend Context Retrieval API Endpoint (`POST /api/v1/ai/trends/context`)

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Xuất bản endpoint RESTful chính thức `POST /api/v1/ai/trends/context`, tích hợp tầng Cache và tầng Retrieval song song, đóng vai trò Provider cho Consumer Adapter của Content Generation.

**Acceptance Criteria:**

- [ ] Khai báo route `POST /api/v1/ai/trends/context` tiếp nhận `TrendContextRequest(trend_keyword: str, depth: int = 1, include_snippets: bool = True)`.
- [ ] Luồng xử lý:
  1. Kiểm tra cache Redis (`DA-AI05-07D`); nếu có $\rightarrow$ trả về ngay lập tức ($< 20$ms).
  2. Nếu cache miss $\rightarrow$ Kích hoạt song song `traverse_trend_graph` và `search_trend_snippets` qua `asyncio.gather`.
  3. Hợp nhất bằng `synthesize_trend_context` (`DA-AI05-07C`).
  4. Ghi ngược vào Redis cache và trả về cho client.
- [ ] Xử lý sự cố toàn diện: Nếu cả Neo4j và ChromaDB đều không có dữ liệu, trả về object `TrendContextResponse` có `found=False` và `formatted_context=""` thay vì trả về lỗi 500.
- [ ] Áp dụng FastAPI Dependency Injection: Router sử dụng `Depends(get_trend_cache)`, `Depends(get_graph_retriever)`, `Depends(get_vector_retriever)` để dễ dàng inject mock services khi test endpoint mà không cần khởi chạy Neo4j hoặc ChromaDB.
- [ ] Tuân thủ SLA hiệu năng: Cold query $\le 500$ms, Cached query $\le 20$ms.

**Technical Notes:**

- Router khai báo tại `app/api/v1/endpoints/trends.py`.
- Đóng vai trò là Provider dữ liệu live cho `DA-AI04-01` (Consumer Adapters).

**Dependencies:**

- Blocks: DA-AI04-01 (Live integration ở giai đoạn cuối).
- Blocked by: DA-AI05-07C, DA-AI05-07D. (Lưu ý: DA-AI04-01 ở Epic AI-04 không bị block vì adapter sử dụng DTO contract và mock HTTP response qua `respx` khi dev).

**Implementation Details:**

- **Files affected:** `docker/docker-compose.infra.yml`, `docker/docker-compose.dev.yml`, `docker/.env.example`, `docker/n8n/workflows/trend_crawler.json`, `app/api/internal/trends.py`
- **Nodes to create (workflow `brandhub-trend-crawler`):** `Schedule Trigger` → `HTTP Request (Google Trends RSS)` → `XML` → `Code (normalize)` → `HTTP Request (POST ingest)`
- **Processing flow:**
  1. Schedule Trigger fires every 6 hours in `Asia/Ho_Chi_Minh`.
  2. HTTP Request node GETs `https://trends.google.com/trending/rss?geo=VN` with a browser-like `User-Agent`.
  3. XML node converts the RSS payload into JSON items.
  4. Code node maps each item to `{keyword, score, source, crawledAt}`, scoring linearly by rank so the output stays comparable with the TikTok crawler in DA-AI05-02.
  5. HTTP Request node POSTs the array to the ingest endpoint with header `X-Internal-Token`; on non-2xx it retries 3× with exponential backoff, then hands off to the Error Workflow.
- **Code Skeleton:**

```yaml
# docker/docker-compose.infra.yml — thêm service n8n vào stack hiện có
  n8n:
    image: n8nio/n8n:1.75.2
    container_name: brandhub-n8n
    restart: unless-stopped
    environment:
      # Mất key này là mất toàn bộ credentials đã lưu -> bắt buộc set từ .env
      N8N_ENCRYPTION_KEY: ${N8N_ENCRYPTION_KEY:?N8N_ENCRYPTION_KEY is required}
      N8N_BASIC_AUTH_ACTIVE: "true"
      N8N_BASIC_AUTH_USER: ${N8N_BASIC_AUTH_USER:?N8N_BASIC_AUTH_USER is required}
      N8N_BASIC_AUTH_PASSWORD: ${N8N_BASIC_AUTH_PASSWORD:?N8N_BASIC_AUTH_PASSWORD is required}
      GENERIC_TIMEZONE: Asia/Ho_Chi_Minh
    volumes:
      - n8n-data:/home/node/.n8n
    networks:
      - brandhub-network

# Khai báo thêm vào block volumes có sẵn ở cuối file
volumes:
  n8n-data:
    name: brandhub-n8n-data
```

```javascript
// Code node "normalize" — chạy sau XML node, trả về đúng shape DA-AI05-03 cần
const crawledAt = new Date().toISOString();

// RSS trả về rss.channel.item; ép về array vì 1 item sẽ không phải array
const raw = $input.first().json.rss?.channel?.item ?? [];
const items = Array.isArray(raw) ? raw : [raw];

return items.slice(0, 20).map((item, rank) => ({
  json: {
    keyword: (item.title ?? "").toString().trim(),
    score: 100 - rank * 5, // điểm tuyến tính theo rank, làm volume base tạm thời
    source: "google",
    crawledAt,
  },
}));
```

---

### DA-AI05-02 — Implement TikTok trending hashtag crawler (web scraping or unofficial API, fallback to pytrends)

# **Assignee:** Tuấn (AI) | **Priority:** 🟡 High

## PHẦN III: CHI TIẾT CÀI ĐẶT EPIC AI-05 (TREND CRAWLER, PREDICTION ENGINE & STORAGE SERVICE)

> > > > > > > 5c259fda04390825822aed6b514cff238aa9e22a

---

### DA-AI05-01 — Aggregate and Select Required Scraping APIs on Apify & Scrape Creators for Social Media Data Collection

**Goal:** Select, integrate, and configure external social media scraping APIs on Apify and Scrape Creators platforms to collect raw posts, reels, and comments across Facebook, Instagram, and TikTok.

**Acceptance Criteria:**

- [ ] Evaluate and select Apify Actors and Scrape Creators endpoints for TikTok, Facebook, and Instagram scraping
- [ ] Configure API keys, rate limits, request retries, and target payload formats
- [ ] Return raw social media data payloads formatted in standardized JSON (`{post_id, author, content, interactions, timestamp}`)

**Technical Notes:**

- Tech stack: Apify, Scrape Creators, REST APIs, Python.

**Dependencies:**
Blocks: DA-AI05-02, DA-AI05-03. Blocked by: DA-AI02-01.

**Implementation Details:**

- **Files affected:** `app/services/crawlers/tiktok_scraper.py`
- **Functions/Classes to create:** `class TikTokScraper` with function `def fetch_tiktok_trends(self) -> List[dict]`
- **Processing flow:**
  1. Launch Playwright scraper targeting TikTok Creative Center (Vietnam region).
  2. Scrape top trending hashtags, popularity score, and related video views.
  3. If blocked or rate-limited, fall back to pytrends search with `tiktok trending vietnam`.
- **Code Skeleton:**

```python
# app/services/crawlers/tiktok_scraper.py
from playwright.async_api import async_playwright
import logging

logger = logging.getLogger(__name__)

class TikTokCreativeCenterCrawler:
    def __init__(self):
        self.url = "https://ads.tiktok.com/business/creativecenter/trends/vietnam"

    async def fetch_tiktok_trends(self) -> list[dict]:
        results = []
        try:
            async with async_playwright() as p:
                browser = await p.chromium.launch(headless=True)
                page = await browser.new_page()
                await page.goto(self.url, wait_until="networkidle")

                # Selector giả định cho các phần tử chứa hashtag thịnh hành
                elements = await page.query_selector_all(".trend-hashtag-name")
                for rank, el in enumerate(elements[:20]):
                    name = await el.inner_text()
                    results.append({
                        "keyword": name.strip().replace("#", ""),
                        "score": 100 - rank * 5,
                        "source": "tiktok"
                    })
                await browser.close()
        except Exception as e:
            logger.error(f"Error crawling TikTok Creative Center: {str(e)}")
        return results
```

---

### DA-AI05-02 — Demo Crawled Social Media Data on Google Sheets

**Goal:** Build a demonstration pipeline that exports crawled social media data into Google Sheets for rapid inspection, verification, and stakeholder review.

**Acceptance Criteria:**

- [ ] `services/trends/normalizer.py` accepts raw output from Google Trends and TikTok crawlers and returns `List[TrendItem]` where `TrendItem = {keyword: str, score: float, platform: str, relatedTopics: List[str]}`
- [ ] Scores from different platforms are normalized to 0.0–1.0 range
- [ ] Duplicate keywords across platforms are merged with scores averaged and platforms listed as an array

**Dependencies:** Blocks: DA-AI05-04. Blocked by: DA-AI05-01, DA-AI05-02.

**Implementation Details:**

- **Files affected:** `app/services/word_segmentation.py`
- **Functions/Classes to create:** `class VietnameseSegmenter` with function `def segment_and_clean(self, raw_text: str) -> List[str]`
- **Processing flow:**
  1. Filter out URLs, special characters, and emojis using regex.
  2. Segment raw text into meaningful Vietnamese word compounds using `underthesea` library (`word_tokenize`).
  3. Filter out Vietnamese stop words and return clean tokens.
- **Code Skeleton:**

```python
# app/services/word_segmentation.py
from underthesea import word_tokenize
import re

class VietnameseSegmenter:
    def __init__(self, stop_words_path: str = None):
        # Nạp bộ từ điển stop words
        self.stop_words = set()
        if stop_words_path:
            with open(stop_words_path, 'r', encoding='utf-8') as f:
                self.stop_words = set([line.strip() for line in f])

    def clean_text(self, text: str) -> str:
        # Lọc URL
        text = re.sub(r'http\S+|www\S+|https\S+', '', text, flags=re.MULTILINE)
        # Lọc ký tự đặc biệt
        text = re.sub(r'[^\w\s]', '', text)
        return text.lower().strip()

    def segment_and_clean(self, raw_text: str) -> list[str]:
        cleaned = self.clean_text(raw_text)
        tokens = word_tokenize(cleaned, format="text").split()

        # Format của underthesea trả về dấu gạch dưới "_" cho từ ghép, ví dụ: "trà_sữa"
        # Ta khôi phục lại dấu cách và lọc stop words
        result_tokens = []
        for token in tokens:
            word = token.replace("_", " ")
            if word not in self.stop_words and len(word) > 1:
                result_tokens.append(word)
        return result_tokens
```

---

### DA-AI05-04 — Implement Redis cache for trend data (key: trends:vn:{date}:{category}, TTL 6 hours)

**Assignee:** Lộc (Sub-lead) | **Priority:** 🟡 High

**Goal:** Prevent excessive crawling and rate-limit exposure by caching trend data for 6 hours per category per day.

**Acceptance Criteria:**

- [ ] `utils/trends_cache.py` implements `get_cached_trends(category) -> Optional[List]` and `set_cached_trends(category, data)` with `TTL = 21600` seconds
- [ ] Cache key format: `trends:vn:{YYYY-MM-DD}:{category}` using current UTC date
- [ ] # On Redis connection failure, function logs error and returns `None` so callers fall back to live crawl without crashing
- [ ] Automated export of sample crawled social media posts into a structured Google Sheet
- [ ] Includes fields: Platform, Author, Content, Likes, Shares, Comments Count, Post Date, Raw Hashtags
- [ ] Real-time or scheduled update trigger via Python script / N8N webhook
  > > > > > > > 5c259fda04390825822aed6b514cff238aa9e22a

**Technical Notes:**

- Tech stack: Google Sheets API, Python, N8N.

**Dependencies:**
Blocks: DA-AI05-03. Blocked by: DA-AI05-01.

**Implementation Details:**

- **Files affected:** `app/services/trend_predictor.py` and `app/core/redis.py`
- **Functions/Classes to create:** `class TrendSyncService` with function `def sync_trends(self, top_trends: List[dict], category: str)`
- **Processing flow:**
  1. Connect to Redis and store trend list as Sorted Set (ZSET) with key `trends:vn:{category}` using `final_score` as member score.
  2. Set key TTL to 6 hours.
  3. Upsert results into Neo4j using Cypher `MERGE ... ON CREATE SET ... ON MATCH SET`.
- **Code Skeleton:**

```python
# app/services/trend_sync.py
import redis
from app.core.neoj4 import Neo4jDatabase

class TrendSyncService:
    def __init__(self, redis_client: redis.Redis, neodb: Neo4jDatabase):
        self.redis = redis_client
        self.neodb = neodb

    def sync_trends(self, top_trends: list[dict], category: str):
        # 1. Sync Redis Sorted Set
        redis_key = f"trends:vn:{category}"
        self.redis.delete(redis_key)  # Reset cache cũ

        for rank, item in enumerate(top_trends):
            # ZADD key score member
            self.redis.zadd(redis_key, {item["trend"]: item["final_score"]})
        self.redis.expire(redis_key, 21600)  # Thiết lập TTL 6 tiếng (21600 giây)

        # 2. Sync Neo4j (MERGE & ON MATCH SET)
        for rank, item in enumerate(top_trends):
            query = """
            MERGE (t:Trend {name: $name})
            ON CREATE SET t.created_at = timestamp(), t.final_score = $score, t.rank = $rank
            ON MATCH SET t.final_score = $score, t.rank = $rank
            """
            self.neodb.query(query, {
                "name": item["trend"],
                "score": item["final_score"],
                "rank": rank + 1
            })
```

---

### DA-AI05-05 — Implement trend suggestions API endpoint (GET /ai/trends?category=fashion&limit=20)

# **Assignee:** Lộc (Sub-lead) | **Priority:** 🟡 High

### DA-AI05-03 — Complete End-to-End Social Media Crawl Workflow via N8N or Custom Code

> > > > > > > 5c259fda04390825822aed6b514cff238aa9e22a

**Goal:** Construct an automated end-to-end scheduled workflow in N8N (or Python FastAPI worker) to trigger scraping tasks, handle proxy rotation, retry failed requests, and pass collected data to buffer queues.

**Acceptance Criteria:**

- [ ] `GET /ai/trends` accepts query params `category` and `limit` (default 20, max 50)
- [ ] Response: `{trends: List[TrendItem], cachedAt: ISO8601 timestamp, ttlSeconds: int}`
- [ ] Cache hit serves instantly from Redis; cache miss triggers live crawl, caches result, then responds
- [ ] If both cache miss and crawl fail, returns `503` with `{"error": "trend_data_unavailable"}` rather than empty list

**Dependencies:** Blocks: DA-AI04-01 (trend data injection into prompts). Blocked by: DA-AI05-04.

**Implementation Details:**

- **Files affected:** `app/api/v1/trends.py`
- **Functions/Classes to create:** Endpoint `GET /ai/trends` accepting `category` and `limit`
- **Processing flow:**
  1. Retrieve category trends from Redis cache.
  2. If cache miss, fetch trends from Neo4j DB and trigger async background reload task.
  3. Return trend keywords and scores.
- **Code Skeleton:**

```python
# app/api/v1/trends.py
from fastapi import APIRouter, Query, HTTPException
from app.core.redis import get_redis_client
from app.core.neoj4 import Neo4jDatabase

router = APIRouter()

@router.get("")
async def get_top_trends(
    category: str = Query("fnb"),
    limit: int = Query(10)
):
    redis_client = get_redis_client()
    redis_key = f"trends:vn:{category}"

    # 1. Đọc từ Redis cache
    cached_trends = redis_client.zrevrange(redis_key, 0, limit - 1, withscores=True)
    if cached_trends:
        return [{"trend": item[0].decode("utf-8"), "score": item[1]} for item in cached_trends]

    # 2. Fallback sang Neo4j nếu Redis trống
    neodb = Neo4jDatabase()
    query = "MATCH (t:Trend) RETURN t.name as name, t.final_score as score ORDER BY t.final_score DESC LIMIT $limit"
    db_results = neodb.query(query, {"limit": limit})

    if not db_results:
        return []

    # Trả về kết quả và kích hoạt nạp lại cache Redis (Chạy ngầm)
    return [{"trend": item["name"], "score": item["score"]} for item in db_results]
```

---

### DA-AI05-06 — Set up APScheduler to auto-crawl every 6 hours

**Assignee:** Lộc (Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Keep the trend cache warm by proactively refreshing all tracked categories on a schedule rather than relying on user requests to trigger crawls.

**Acceptance Criteria:**

- [ ] `APScheduler` job runs every 6 hours, crawls trends for all configured categories (fashion, food, beauty, tech, lifestyle), and updates Redis
- [ ] Scheduler starts automatically when FastAPI app starts via `lifespan` context manager
- [ ] # Failed crawl jobs log the error and do not crash the scheduler; next scheduled run proceeds normally
- [ ] N8N workflow `brandhub-social-crawl-pipeline` deployed with schedule trigger (every 6 hours)
- [ ] Automated execution: API trigger -> Fetch posts & comments -> Format validation -> Ingestion trigger
- [ ] Error handling with automated retries (3x backoff) and alert webhooks on failure
  > > > > > > > 5c259fda04390825822aed6b514cff238aa9e22a

**Technical Notes:**

- Tech stack: N8N, Python, Webhooks, Docker.

**Dependencies:**
Blocks: DA-AI05-04, DA-AI05-05. Blocked by: DA-AI05-01.

**Implementation Details:**

- **Files affected:** `app/core/scheduler.py` and `app/main.py`
- **Functions/Classes to create:** `class TrendScheduler`
- **Processing flow:**
  1. Initialize `APScheduler` (`AsyncIOScheduler`) on application startup.
  2. Schedule background job `run_trend_crawl_job` to execute every 6 hours.
  3. Job triggers crawlers, normalizer, scoring engine, and syncs cache/Neo4j.
- **Code Skeleton:**

```python
# app/core/scheduler.py
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from app.services.crawlers.google_trends import GoogleTrendsCrawler
from app.services.crawlers.tiktok_scraper import TikTokCreativeCenterCrawler
from app.services.trend_predictor import BM25AnomalyDetector, GraphViralityEngine
from app.services.trend_sync import TrendSyncService

scheduler = AsyncIOScheduler()

async def run_crawlers_and_predict_trends():
    # 1. Chạy các Crawler lấy dữ liệu thô
    google_crawler = GoogleTrendsCrawler()
    tiktok_crawler = TikTokCreativeCenterCrawler()

    google_data = google_crawler.fetch_google_trends()
    tiktok_data = await tiktok_crawler.fetch_tiktok_trends()

    # Gom tất cả token thô
    raw_tokens = [item["keyword"] for item in google_data + tiktok_data]

    # 2. Phát hiện bất thường bằng BM25
    detector = BM25AnomalyDetector()
    # Giả định lấy baseline corpus từ DB lịch sử
    baseline_corpus = [["trà", "sữa", "đất", "nung"], ["capybara"], ["mỳ", "quảng"]]
    candidates = detector.calculate_anomaly_scores(raw_tokens, baseline_corpus)

    # 3. Chấm điểm lan truyền qua đồ thị Neo4j
    # graph_engine = GraphViralityEngine(neodb)
    # top_trends = graph_engine.calculate_virality_and_final_scores(candidates, "system")

    # 4. Lưu trữ cache và Database
    # trend_sync_service.sync_trends(top_trends, "fnb")

def init_scheduler():
    # Cấu hình scheduler chạy định kỳ mỗi 6 tiếng
    scheduler.add_job(run_crawlers_and_predict_trends, 'interval', hours=6)
    scheduler.start()
```

---

### DA-AI05-07 — Brainstorm AI crawl idea _(phát sinh, ngoài plan gốc)_

# **Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

### DA-AI05-04 — Host and Set Up ChromaDB or Neo4j Database Instance for Storing Raw Collected Data

> > > > > > > 5c259fda04390825822aed6b514cff238aa9e22a

**Goal:** Provision and configure persistent database instances (ChromaDB vector store & Neo4j graph database) dedicated to storing raw and processed social media data.

**Acceptance Criteria:**

- [ ] Dockerized deployment of ChromaDB and Neo4j instances in infrastructure stack
- [ ] Persistent storage volumes, security authentication, memory tuning, and health check endpoints configured
- [ ] Connection pool manager verified for high-throughput write operations

**Technical Notes:**

- Tech stack: ChromaDB, Neo4j 5.x, Docker, Cloud Instance.

**Dependencies:**
Blocks: DA-AI05-05, DA-AI05-09. Blocked by: DA-AI02-05.

---

### DA-AI05-05 — Message Queue / Buffer Layer Integration (Redis Queue / Kafka)

**Goal:** Implement an asynchronous buffer layer using Redis Queue or Kafka to decouple raw data crawling from downstream NLP pre-processing and trend prediction engines.

**Acceptance Criteria:**

- [ ] Setup ingestion queue `queue:social:raw_posts` for streaming collected raw JSON items
- [ ] Producer module in Crawler workflow pushes batch items to queue with idempotency keys
- [ ] Consumer worker pulls messages asynchronously and routes them to Tầng 2 (NLP Tokenization Engine)

**Technical Notes:**

- Tech stack: Redis Queue / Kafka, Python, AsyncIO.

**Dependencies:**
Blocks: DA-AI05-06. Blocked by: DA-AI05-03, DA-AI05-04.

---

### DA-AI05-06 — Underthesea NLP Tokenization

**Goal:** Perform Vietnamese word tokenization and compound phrase extraction on raw social media post contents using Underthesea NLP.

**Acceptance Criteria:**

- [ ] `services/tokenization.py` accepts raw text strings and outputs tokenized compound words (e.g., _"trà sữa đất nung"_ -> `["trà_sữa", "đất_nung"]`)
- [ ] Clean regex removal of URLs, special symbols, and noise characters prior to tokenization
- [ ] Benchmarked execution time < 50ms per post payload

**Technical Notes:**

- Tech stack: Python 3.11, Underthesea NLP.

**Dependencies:**
Blocks: DA-AI05-07F. Blocked by: DA-AI05-05.

---

### DA-AI05-07F — Slang Map & Text Normalization Engine

> **Note:** For the primary Trend Context Retrieval API subsystem (`POST /api/v1/ai/trends/context` combining Neo4j & ChromaDB), see [DA-AI05-07A through DA-AI05-07E](#da-ai05-07a--neo4j-knowledge-graph-entity-traversal-service).

**Goal:** Build a normalization engine that maps Vietnamese social media slang, teen-code, and abbreviations to standard terminology.

**Acceptance Criteria:**

- [ ] Custom mapping dictionary (JSON/YAML) covering popular slang (e.g. _"mlem"_ -> _"ngon/hấp dẫn"_, _"gank"_ -> _"trợ giúp"_, _"khum"_ -> _"không"_)
- [ ] Standardizes tokens, lowercases text, and strips uninformative noise characters
- [ ] Provides extensible lookup API for dynamic dictionary updates

**Technical Notes:**

- Tech stack: Python, Custom Slang Map Dictionary.

**Dependencies:**
Blocks: DA-AI05-08, DA-AI05-09. Blocked by: DA-AI05-06.

---

### DA-AI05-08 — BM25 Anomaly Calculation (Spike Detection)

**Goal:** Calculate term frequency anomaly scores using BM25 algorithms, comparing current 6-hour windows against 7-day historical baselines to detect surging keywords.

**Acceptance Criteria:**

- [ ] Implements BM25 anomaly detector comparing current 6h window term frequency against 7-day baseline corpus
- [ ] Calculates IDF and term saturation parameters (`k1=1.5`, `b=0.75`)
- [ ] Selects candidate keywords exceeding the anomaly spike threshold

**Technical Notes:**

- Tech stack: Python, rank_bm25, NumPy.

**Dependencies:**
Blocks: DA-AI05-14. Blocked by: DA-AI05-07F.

---

### DA-AI05-09 — Neo4j Interaction Graph Construction

**Goal:** Construct a social interaction graph in Neo4j connecting Users, Posts, and Keywords (`:User-[:POSTED|:RETWEETED|:COMMENTED]->:Post`).

**Acceptance Criteria:**

- [ ] Schema definition: Nodes (`:User`, `:Post`, `:Keyword`, `:Community`), Edges (`:POSTED`, `:INTERACTED`, `:MENTIONS`)
- [ ] High-speed batch Cypher `MERGE` ingestion from normalized post streams
- [ ] Graph indices created on `user_id`, `post_id`, and `keyword` fields for rapid traversal

**Technical Notes:**

- Tech stack: Neo4j 5.x, Cypher, Python.

**Dependencies:**
Blocks: DA-AI05-10. Blocked by: DA-AI05-07F, DA-AI05-04.

---

### DA-AI05-10 — GDS Engine Scheduled Execution (Run periodic algorithms nightly or every few hours)

**Goal:** Schedule and execute Neo4j Graph Data Science (GDS) algorithms periodically to compute structural metrics on the interaction graph.

**Acceptance Criteria:**

- [ ] Graph projection setup using `gds.graph.project` in RAM
- [ ] APScheduler trigger configured to run GDS algorithms nightly or every 6 hours
- [ ] Automated cleanup and release of in-memory graph projections post-computation

**Technical Notes:**

- Tech stack: Neo4j GDS (Graph Data Science), APScheduler / Cron.

**Dependencies:**
Blocks: DA-AI05-11, DA-AI05-12, DA-AI05-13. Blocked by: DA-AI05-09.

---

### DA-AI05-11 — Degree Filter & Botnet Detection (Calculate In-Degree -> Flag isStopWord=true if Spam)

**Goal:** Detect and filter spam, botnets, and unnatural amplification by evaluating node In-Degree metrics and flagging artificial clusters.

**Acceptance Criteria:**

- [ ] Compute In-Degree centrality across interaction graph nodes
- [ ] Flag accounts/keywords exceeding statistical anomaly limits with `isStopWord=true` / `isSpam=true`
- [ ] Exclude flagged spam nodes from downstream virality calculations

**Technical Notes:**

- Tech stack: Neo4j Cypher, Degree Centrality.

**Dependencies:**
Blocks: DA-AI05-14. Blocked by: DA-AI05-10.

---

### DA-AI05-12 — Personalized PageRank Engine (Calculate Niche Virality Score for Posts)

**Goal:** Run Personalized PageRank algorithms on the Neo4j interaction graph to calculate organic Niche Virality Scores for social posts and topics.

**Acceptance Criteria:**

- [ ] Execute `gds.pageRank.stream` with personalization weights assigned to verified high-authority creators/KOLs
- [ ] Outputs normalized Virality Score in range `[0, 1]` for candidate posts and keywords
- [ ] Write back `viralityScore` property to Neo4j nodes

**Technical Notes:**

- Tech stack: Neo4j GDS, PageRank, Python.

**Dependencies:**
Blocks: DA-AI05-14. Blocked by: DA-AI05-10.

---

### DA-AI05-13 — Betweenness Centrality Engine (Find Bridge Keywords between Communities -> Trending Keywords)

**Goal:** Calculate Betweenness Centrality to identify "bridge" keywords connecting distinct community clusters, signalling cross-community trending topics.

**Acceptance Criteria:**

- [ ] Execute `gds.betweenness.stream` on community graph projections
- [ ] Identify high-betweenness keywords acting as bridges between different interest groups
- [ ] Combine bridge score with topic virality metrics

**Technical Notes:**

- Tech stack: Neo4j GDS, Betweenness Centrality.

**Dependencies:**
Blocks: DA-AI05-14. Blocked by: DA-AI05-10.

---

### DA-AI05-14 — Final Scoring Engine (BM25 Anomaly x Virality)

**Goal:** Compute the final trend score by multiplying the BM25 Spike Anomaly Score with the Organic Virality Score.

**Acceptance Criteria:**

- [ ] Implement formula: `Final Score = BM25 Anomaly Score * Virality Score (Organic Engagement)`
- [ ] Combine anomaly output from DA-AI05-08 and graph scores from DA-AI05-11..13
- [ ] Rank candidate topics by Final Score

**Technical Notes:**

- Tech stack: Python, NumPy.

**Dependencies:**
Blocks: DA-AI05-15. Blocked by: DA-AI05-08, DA-AI05-11, DA-AI05-12, DA-AI05-13.

---

### DA-AI05-15 — Filter Top 10-20 Trends Engine

**Goal:** Filter and select the Top 10–20 highest-scoring trending topics to be stored in cache and passed to downstream deep crawling and GraphRAG ingestion layers.

**Acceptance Criteria:**

- [ ] Sort candidate pool by `Final Score` descending
- [ ] Deduplicate semantically identical trend topics
- [ ] Select Top 10–20 trends and output structured payload `{trend_id, keyword, category, final_score, timestamp}`

**Technical Notes:**

- Tech stack: Python, Pandas.

**Dependencies:**
Blocks: DA-AI05-16, DA-AI05-17, DA-AI05-18. Blocked by: DA-AI05-14.

---

### DA-AI05-16 — Redis ZSET Caching Engine (`trends:vn:{date}:{category}`, TTL 6h)

**Goal:** Cache the top trending topics in Redis ZSET data structures for ultra-fast API retrieval by the web dashboard and business services.

**Acceptance Criteria:**

- [ ] Store trend list in Redis ZSET key: `trends:vn:{date}:{category}`
- [ ] Member is `trend_id / keyword`, Score is `Final Score`
- [ ] Configure TTL of 6 hours for automatic expiration upon fresh crawl cycles

**Technical Notes:**

- Tech stack: Redis 7.x, Spring Redis / redis-py.

**Dependencies:**
Blocks: None. Blocked by: DA-AI05-15.

---

### DA-AI05-17 — Upsert Neo4j Node `:Trend`

**Goal:** Sync and upsert official Top 10-20 trends into Neo4j graph database as persistent `:Trend` nodes.

**Acceptance Criteria:**

- [ ] Execute Cypher `MERGE (t:Trend {id: $trend_id}) SET t.name = $name, t.score = $score, t.category = $category, t.updatedAt = timestamp()`
- [ ] Connect `:Trend` nodes to associated keywords and community nodes

**Technical Notes:**

- Tech stack: Neo4j Cypher, Python.

**Dependencies:**
Blocks: DA-AI05-22, DA-AI05-23. Blocked by: DA-AI05-15.

---

### DA-AI05-18 — Deep Crawl Trigger Engine (Posts & Comments Collector)

**Goal:** Trigger deep crawling for the Top 10–20 identified trends to collect all related posts and detailed comments for rich knowledge graph ingestion.

**Acceptance Criteria:**

- [ ] Push Top 10-20 trend topics to deep crawl job queue
- [ ] Trigger scrapers to gather complete post contents, top comments, and user interactions specific to those trends
- [ ] Route deep crawl payloads to LangChain Chunking & Embedding layer

**Technical Notes:**

- Tech stack: Python, Apify/N8N, Async Queue.

**Dependencies:**
Blocks: DA-AI05-19. Blocked by: DA-AI05-15.

---

### DA-AI05-19 — LangChain Text Chunking (Size 500, Overlap 50)

**Goal:** Split deep-crawled trend posts and comments into uniform chunks suitable for vector embedding and GraphRAG processing.

**Acceptance Criteria:**

- [ ] LangChain `RecursiveCharacterTextSplitter` configured with `chunk_size = 500` characters, `chunk_overlap = 50` characters
- [ ] Preserves context around Vietnamese sentence boundaries (`\n\n`, `\n`, `.`, `,`)
- [ ] Outputs clean text chunks tagged with source trend metadata

**Technical Notes:**

- Tech stack: Python, LangChain.

**Dependencies:**
Blocks: DA-AI05-20, DA-AI05-22. Blocked by: DA-AI05-18.

---

### DA-AI05-20 — Text Embedding Pipeline (`all-MiniLM-L6-v2`, 384d)

**Goal:** Convert text chunks into 384-dimensional dense vector embeddings using `all-MiniLM-L6-v2`.

**Acceptance Criteria:**

- [ ] Batch vectorization of text chunks using `all-MiniLM-L6-v2` model
- [ ] Outputs 384-dimensional float vectors
- [ ] Benchmarked throughput > 100 chunks/sec on CPU/GPU

**Technical Notes:**

- Tech stack: Sentence-Transformers, PyTorch, Python.

**Dependencies:**
Blocks: DA-AI05-21. Blocked by: DA-AI05-19.

---

### DA-AI05-21 — ChromaDB Vector Store Integration (HNSW Index Engine)

**Goal:** Store chunk vectors in ChromaDB with HNSW indexing for high-speed cosine similarity retrieval.

**Acceptance Criteria:**

- [ ] Create/manage ChromaDB collections for trend market intelligence
- [ ] Ingest embeddings with HNSW index configuration
- [ ] Store rich metadata per vector (`{trend_id, chunk_id, source_url, timestamp}`)

**Technical Notes:**

- Tech stack: ChromaDB, HNSW Index Engine, Python.

**Dependencies:**
Blocks: None. Blocked by: DA-AI05-20.

---

### DA-AI05-22 — LLM NER & Relation Extraction Engine

**Goal:** Extract Named Entities (Brand, Product, Person, Location, Sentiment) and Relationships (`MENTIONS`, `HAS_SENTIMENT`, `COMPARES_TO`) from deep-crawled text chunks using LLM prompts.

**Acceptance Criteria:**

- [ ] Structured LLM prompt template enforcing JSON output format for entities and relations
- [ ] Extracts entity types: `Brand`, `Product`, `Person`, `Event`, `Emotion`
- [ ] Extracts relationship edges connecting entities to `:Trend` nodes

**Technical Notes:**

- Tech stack: Python, LangChain, Groq Llama 3 API.

**Dependencies:**
Blocks: DA-AI05-23. Blocked by: DA-AI05-19.

---

### DA-AI05-23 — Neo4j Knowledge Graph Ingestion Engine

**Goal:** Ingest LLM-extracted entities and relations into the Neo4j Knowledge Graph to construct a market intelligence graph network.

**Acceptance Criteria:**

- [ ] Cypher `MERGE` queries to create nodes and relationships in Neo4j
- [ ] Links extracted entities directly to `:Trend` nodes
- [ ] APOC procedure usage for optimized batch graph writes

**Technical Notes:**

- Tech stack: Neo4j 5.x, Cypher, APOC.

**Dependencies:**
Blocks: DA-AI05-24. Blocked by: DA-AI05-22, DA-AI05-17.

---

### DA-AI05-24 — Entity Resolution Job (Knowledge Graph Fusion)

**Goal:** Execute background entity resolution jobs to merge duplicate or synonymous entity nodes in the Knowledge Graph (e.g., _"VinFast"_, _"Vin Fast"_, _"VFS"_ -> `:Brand {name: "VinFast"}`).

**Acceptance Criteria:**

- [ ] Entity similarity computation using fuzzy string matching and vector embedding similarity
- [ ] Merge duplicate nodes using `apoc.refactor.mergeNodes` in Neo4j
- [ ] Consolidate relationship edges to maintain graph integrity

**Technical Notes:**

- Tech stack: Python, Neo4j APOC, Fuzzy Matching.

**Dependencies:**
Blocks: None. Blocked by: DA-AI05-23.

---

### DA-AI05-25 — Raw Data Ingestion, JSON Parsing, Object Normalization & Hash Deduplication Engine (T0)

**Goal:** Ingest raw social media crawl data, parse unstructured raw JSON payloads into standardized Post/Comment objects, normalize metadata schema, and perform URL & text content hash deduplication to eliminate duplicate records before downstream pipeline processing.

**Acceptance Criteria:**

- [ ] Parse raw JSON outputs from Apify/crawlers into normalized Post/Comment Pydantic schemas.
- [ ] Standardize metadata fields (ISO 8601 timestamps, author identifiers, engagement counts, platform tags).
- [ ] Compute MD5/SHA256 hashes for URL and text body to perform deduplication via Redis Bloom Filter / ZSET lookup.
- [ ] Achieve ≥ 99.5% ingestion success rate on raw payloads and 100% suppression of duplicate records.

**Technical Notes:**

- Pipeline Step: T0 (Ingestion Layer).
- Tech Stack: Python 3.11, Pydantic v2, hashlib, Redis.
- Assignee: Ân (AI) | Priority: 🔴 Critical

**Dependencies:**
Blocks: DA-AI05-26. Blocked by: DA-AI02-01.

---

### DA-AI05-26 — Bot, Clone & Spam Filter Engine (Rules KB1, KB2, KB3A/B, KB5, KB6) (T1)

**Goal:** Build an automated noise suppression engine to filter out bot accounts, clone profiles, spam comments, and coordinated seeding activities using rules KB1, KB2, KB3A/B, KB5, and KB6 prior to NLP & graph analysis.

**Acceptance Criteria:**

- [ ] Implement Rule KB1 (Profile verification: default avatar, random username, recently created account filter).
- [ ] Implement Rule KB2 (Duplicate comment detection across multiple posts).
- [ ] Implement Rule KB3A/B (Time-window comment velocity / flood detection).
- [ ] Implement Rule KB5 (Sticker/emoji-only comments & promotional/spam keyword regex matching).
- [ ] Implement Rule KB6 (One-way interaction ratio & botnet farm activity detection).
- [ ] Attach `isSpam: boolean` and `spamRule: string` flags to records; eliminate ≥ 90% of bot noise.

**Technical Notes:**

- Pipeline Step: T1 (Bot/Clone/Spam Filter).
- Tech Stack: Python, Redis Rate Limiter / Sliding Window, Regex Engine.
- Assignee: Ân (AI) | Priority: 🔴 Critical

**Dependencies:**
Blocks: DA-AI05-30, DA-AI05-28. Blocked by: DA-AI05-25.

---

### DA-AI05-30 — Vietnamese NLP Preprocessing Engine (Clean + NFKC + Tokenize + Slang + Stopword) (T2)

**Goal:** Build a comprehensive Vietnamese NLP text preprocessing pipeline executing text cleaning, Unicode NFKC/NFC normalization, compound word tokenization, slang/teencode expansion, and contextual stopword filtering to produce clean, standardized token arrays for downstream topic classification (T3) and BM25 anomaly detection (T4).

**Acceptance Criteria:**

- [ ] **Step 1 - Cleaning:** Strip URLs, HTML tags, hashtags, emojis, and unprintable special symbols while preserving Vietnamese punctuation boundaries.
- [ ] **Step 2 - Unicode Normalization:** Normalize font variations and mathematical bold/italic characters via Unicode NFKC, then ensure canonical decomposition/recomposition with NFC.
- [ ] **Step 3 - Lowercase & Strip:** Lowercase text and sanitize character sets, keeping Vietnamese Latin Extended and standard alphanumeric characters.
- [ ] **Step 4 - Tokenization:** Integrate Underthesea NLP word segmentation (`word_tokenize`) to extract compound words and domain terms (e.g., _"trà sữa đất nung"_ $\rightarrow$ `["trà_sữa", "đất_nung"]`).
- [ ] **Step 5 - Slang Mapping:** Apply dictionary lookup (~90 rules) to expand social teencode, abbreviations, and slang into standard Vietnamese (e.g., _"ko"_ $\rightarrow$ _"không"_, _"dc"_ $\rightarrow$ _"được"_, _"mlem"_ $\rightarrow$ _"ngon/hấp dẫn"_).
- [ ] **Step 6 - Stopword Removal:** Filter ~150 domain stopwords while preserving meaningful 1-character Vietnamese words (`ý`, `ở`, `ạ`) and dropping orphan ASCII characters.
- [ ] Benchmark pipeline throughput: average processing latency $< 30$ms per post text.

**Technical Notes:**

- Pipeline Step: T2 (NLP Preprocessing Layer - Thiết kế tham chiếu `docs/ai-models/DA-570-text-normalization-pipeline-design.md`).
- Tech Stack: Python 3.11, Underthesea NLP, `unicodedata`, Regex, Slang Dictionary.
- Assignee: Ân (AI) | Priority: 🔴 Critical

**Dependencies:**
Blocks: DA-AI05-27, DA-AI05-08. Blocked by: DA-AI05-26.

---

### DA-AI05-27 — Multi-Class Topic Classification Engine (6 Categories) (T3)

**Goal:** Automatically classify social posts into 6 primary industry verticals (`tech`, `food`, `sports`, `entertainment`, `news`, `education`) to enable category-specific trend aggregation and consumer interest mapping.

**Acceptance Criteria:**

- [ ] Build a multi-class text classification pipeline targeting 6 categories: Tech, Food, Sports, Entertainment, News, Education.
- [ ] Assign secondary sub-topics and output a classification confidence score ($0.0 \le \text{confidence} \le 1.0$).
- [ ] Achieve macro F1-Score ≥ 85% on a test benchmark of 500 Vietnamese social posts.
- [ ] Expose batch processing interface with average latency < 50ms per post.

**Technical Notes:**

- Pipeline Step: T3 (Topic Classification).
- Tech Stack: Python, Underthesea / PhoBERT / Zero-Shot Classifier, FastAPI.
- Assignee: Ân (AI) | Priority: 🔴 Critical

**Dependencies:**
Blocks: DA-AI05-31. Blocked by: DA-AI05-30.

---

### DA-AI05-31 — BM25 Spike Detection Engine (Split-Window + Bigram + Time-Series) (T4)

**Goal:** Build an anomaly spike detection engine utilizing modified BM25 on temporal split-windows, statistical bigram phrase extraction, and time-series trend tracking to detect surging topics and keywords from cleaned social posts across categories.

**Acceptance Criteria:**

- [ ] **Split-Window Division:** Split sliding time window into Background baseline ($T_{bg}$, first half) and Target window ($T_{target}$, second half) to isolate surging terms against historical frequency.
- [ ] **Statistical Bigram Phrase Extraction:** Detect co-occurring adjacent tokens ($\ge 5\%$ of posts, minimum 2 co-occurrences) and consolidate into compound phrases with a +20% score boost.
- [ ] **Modified BM25 Scoring:** Implement anomaly BM25 formula $BM25(q) = \frac{TF_{target} \cdot (k_1 + 1)}{TF_{target} + k_1 \cdot \left(1 - b + b \cdot \frac{|T_{target}|}{\text{avg\_len}}\right)} \times IDF(q)$ with $k_1=1.5, b=0.75$ and smooth $IDF = \ln\left(\frac{N_{bg} - DF_{bg} + 0.5}{DF_{bg} + 0.5}\right) + 1.0$.
- [ ] **Non-Parametric Noise Filtering:** Enforce 4 strict filters: $TF_{target} \ge 3$, $DF_{target} \ge 2$, $DF_{bg} \le 50\% \cdot N_{bg}$, and term length $> 2$.
- [ ] **Side-Channel Boost:** Ingest `trendSignals[]` flagged in T1 to amplify genuine cross-post viral terms.
- [ ] **Time-Series Tracking:** Calculate keyword acceleration/velocity across continuous time slices.
- [ ] Process $\ge 1,000$ posts within $< 100$ms batch execution time.

**Technical Notes:**

- Pipeline Step: T4 (BM25 Spike Detection Layer - Thiết kế tham chiếu `docs/ai-models/DA-568-trend-prediction-bm25-design.md`).
- Tech Stack: Python 3.11, NumPy, rank_bm25 / math, Pandas.
- Assignee: Ân (AI) | Priority: 🔴 Critical

**Dependencies:**
Blocks: DA-AI05-28, DA-AI05-29. Blocked by: DA-AI05-27, DA-AI05-30.

---

### DA-AI05-28 — Engagement Virality Score & Reaction Mood Analysis Engine (T5)

**Goal:** Calculate post virality scores based on engagement weighted formulas and perform detailed reaction mood breakdown (haha, wow, care, sad, angry, like, share, comment) to measure audience sentiment and content resonance.

**Acceptance Criteria:**

- [ ] Calculate composite Engagement Score: $Score = w_1 \cdot Like + w_2 \cdot Comment + w_3 \cdot Share + w_4 \cdot Reaction$.
- [ ] Compute Mood Breakdown metrics (Haha, Wow, Care, Sad, Angry ratio) to derive Positivity/Negativity Index & Controversy Rate.
- [ ] Persist virality scores and mood vectors into document metadata for trend ranking algorithms.
- [ ] Maintain execution speed < 10ms per document record.

**Technical Notes:**

- Pipeline Step: T5 (Engagement & Mood Analysis).
- Tech Stack: Python, NumPy, Pandas, Pydantic.
- Assignee: Ân (AI) | Priority: 🔴 Critical

**Dependencies:**
Blocks: DA-AI05-29, DA-AI05-14. Blocked by: DA-AI05-31, DA-AI05-26.

---

### DA-AI05-29 — Jaccard Clustering Community Detection Engine (T6)

**Goal:** Identify and group related audience communities and topic clusters using Jaccard Similarity Clustering on keyword and interaction sets, separated as a dedicated community detection task prior to graph fusion (T7).

**Acceptance Criteria:**

- [ ] Implement Jaccard Similarity Matrix calculation: $J(A, B) = \frac{|A \cap B|}{|A \cup B|}$ for post keyword and user interaction sets.
- [ ] Perform hierarchical / graph clustering on items exceeding Jaccard threshold ($J \ge 0.6$) to form distinct Community clusters.
- [ ] Assign unique Community IDs and compute cluster size and density weights.
- [ ] Feed community cluster outputs directly into the T7 Graph Fusion & Entity Resolution engine.

**Technical Notes:**

- Pipeline Step: T6 (Community Detection Layer - Section 5 in Docs).
- Tech Stack: Python, SciPy, scikit-learn, NetworkX.
- Assignee: Ân (AI) | Priority: 🔴 Critical

**Dependencies:**
Blocks: DA-AI05-32, DA-AI05-24. Blocked by: DA-AI05-28, DA-AI05-31.

---

### DA-AI05-32 — Trend Fusion & Object Assembly Engine (Cluster → Trend Objects) (T7)

**Goal:** Assemble and fuse isolated surging keywords and community clusters into structured, business-ready "Trend Objects" with dynamic titling, dominant topic/mood assignment, status lifecycle tracking, and cross-topic super trend detection.

**Acceptance Criteria:**

- [ ] **Advanced Co-occurrence Grouping:** Merge keywords sharing Jaccard similarity $> 0.25$ or appearing together across $\ge 2$ posts into a unified trend cluster to prevent fragmented single-keyword alerts.
- [ ] **Trend Object Construction:** Generate structured Trend Object schema containing:
  - `title`: Concatenation of 2-3 highest-ranked keywords in the cluster.
  - `topic`: Dominant category resolved from T3 classifications.
  - `mood`: Dominant sentiment and reaction distribution resolved from T5.
  - `status`: Lifecycle tagging: _Peaking_ (avg posts $> 30$, $\ge 2$ keywords), _Rising_ (avg posts $> 15$), _New_ (recently detected).
- [ ] **Cross-Topic Super Trend Detection:** Identify and flag keywords or clusters appearing in the Top 20 BM25 of $\ge 2$ distinct industry topics as `SUPER_TREND`.
- [ ] **Ranking & Anti-Noise Prioritization:** Prioritize multi-keyword clusters over isolated single keywords; deprioritize solo terms to suppress noise.
- [ ] Output finalized Trend Objects ready for Redis cache (`DA-AI05-16`) and Neo4j `:Trend` node upsert (`DA-AI05-17`).

**Technical Notes:**

- Pipeline Step: T7 (Fusion & Trend Assembly Layer - Thiết kế tham chiếu `docs/ai-models/DA-569-graph-virality-score-design.md`).
- Tech Stack: Python 3.11, Pydantic v2, NetworkX, SciPy.
- Assignee: Ân (AI) | Priority: 🔴 Critical

**Dependencies:**
Blocks: DA-AI05-15, DA-AI05-16, DA-AI05-17. Blocked by: DA-AI05-29.

---

### DA-AI04-99-01 — Design & research data collection layer (Google Trends, TikTok crawlers, Social firehose)

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Research and document crawling mechanisms, anti-blocking solutions, and scheduling for data collection from Google Trends (`pytrends`), TikTok Creative Center, and Facebook Public Groups to gather raw posts with interaction metadata (likes, shares, comments).

**Acceptance Criteria:**

- [ ] Document Google Trends configuration via `pytrends` (geo='VN', timeframe='now 7-d') including rate limits
- [ ] Research and document TikTok Creative Center crawl mechanism (Playwright headless) and KOL post feed API (RapidAPI TikTok Scraper)
- [ ] Design Facebook public group crawl flow with rotating proxy service (Bright Data / Webshare) for anti-blocking
- [ ] Configure `APScheduler` to run background jobs every 6 hours, output cached to Redis as JSON

**Technical Notes:**

- IP anti-blocking (Proxy Rotation, Spoofing Headers, Random User-Agents) mandatory for TikTok and Facebook scrapers
- Google Trends: `TrendReq.realtime_trending_searches(pn='VN')`
- Targeted list: 50-100 KOL usernames/IDs + Facebook public group URLs
- Sample crawl JSON output:
  ```json
  {
    "source": "tiktok/facebook/google",
    "crawl_time": "2026-07-18T20:00:00Z",
    "posts": [
      {
        "post_id": "tt_738291038102",
        "author": "ninheating",
        "content": "Sample Vietnamese post content about trà sữa đất nung #trasuadatnung",
        "interactions": {
          "likes": 45000,
          "shares": 1200,
          "comments_count": 850
        },
        "comments": [
          { "user": "reviewer_A", "text": "Is this the place at 10 Hàng Bồ?" }
        ]
      }
    ]
  }
  ```

**Dependencies:** Blocks: DA-AI04-99-02.

---

### DA-AI04-99-02 — Research trend prediction engine algorithm (Word tokenization & BM25 Anomaly Detection)

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Design the mathematical formula and programming logic for Vietnamese word tokenization and BM25 anomaly scoring on raw crawled posts, filtering the Top 100 candidate keywords/phrases with the highest anomaly scores.

**Acceptance Criteria:**

- [ ] Select Vietnamese tokenization library (`Underthesea` or `PyVi`) and set up custom dictionary for compound/neologism recognition
- [ ] Define BM25 formula for anomaly detection: compare TF of current 6h window against IDF of 30-day history
- [ ] Determine filtering thresholds and BM25 score normalization mechanism to select Top 100 candidates

**Technical Notes:**

- Pipeline: Regex cleaning (emoji, URL) → `Underthesea.word_tokenize()` → BM25 scoring
- BM25 input is output from `DA-AI04-99-01`
- JSON output format:
  ```json
  [
    { "keyword": "trà sữa đất nung", "anomaly_score": 8.45 },
    { "keyword": "capybara", "anomaly_score": 7.12 }
  ]
  ```
- Formula: \(\text{Anomaly_Score}(D, q_i) = \text{IDF}(q_i) \cdot \frac{f(q_i, D) \cdot (k_1 + 1)}{f(q_i, D) + k_1 \cdot \left(1 - b + b \cdot \frac{|D|}{\text{avgdl}}\right)}\)
- Handle Vietnamese text with/without diacritics; strip stop words

**Dependencies:** Blocked by: DA-AI04-99-01. Blocks: DA-AI04-99-03.

---

### DA-AI04-99-03 — Design interaction graph analysis & Centrality algorithm for Virality Score

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Design Neo4j interaction graph for 100 trend candidates, apply Degree Centrality and Betweenness Centrality (Neo4j GDS) to compute a Virality Score, and produce the final Top 10-20 official trend ranking.

**Acceptance Criteria:**

- [ ] Define raw interaction graph schema (Nodes: `User`, `Trend`, `Community`; Edges: `POSTED`, `INTERACTED`)
- [ ] Write Cypher queries to run Degree Centrality and Betweenness Centrality via Neo4j GDS
- [ ] Establish final scoring formula: $Final\_Trend\_Score = Anomaly\_Score \times Graph\_Virality\_Score$
- [ ] Implement botnet filtering mechanism using Clustering Coefficient

**Technical Notes:**

- Input: Top 100 candidates from `DA-AI04-99-02` + user/KOL interaction data from `DA-AI04-99-01`
- Graph construction: Nodes (`:User`, `:Trend`, `:Community`), Edges (`:POSTED`, `:INTERACTED`)
- Graph projection: `gds.graph.project`
- Centrality: Degree (Reach) + Betweenness (Cross-community virality) → `Graph_Virality_Score ∈ [0, 1]`
- Final score: \[\text{Final_Trend_Score} = \text{Anomaly_Score} \times \text{Graph_Virality_Score}\]
- JSON output format:
  ```json
  [
    {
      "rank": 1,
      "trend": "trà sữa đất nung",
      "final_score": 7.52,
      "anomaly_score": 8.45,
      "virality_score": 0.89
    }
  ]
  ```
- Ensure Graph Projection is RAM-efficient for periodic execution

**Dependencies:** Blocked by: DA-AI04-99-02. Blocks: DA-AI04-99-06, DA-AI04-99-07.

---

### DA-AI04-99-04 — Design text normalization & chunking pipeline

**Assignee:** Ân (AI) + Trung (Leader) | **Priority:** 🟡 High

**Goal:** Define Vietnamese text cleaning rules (slang normalization, emoji/junk URL removal) and configure LangChain `RecursiveCharacterTextSplitter` (chunk_size=500, overlap=50) for knowledge base ingestion in trend analysis.

**Acceptance Criteria:**

- [ ] Build Regex rules and normalization dictionary for Vietnamese slang/abbreviations (e.g. "khum" → "không", "k" → "không", "ly" → "cốc")
- [ ] Configure LangChain `RecursiveCharacterTextSplitter` with chunk_size=500, overlap=50, split priority `\n` → `.` → `,` → whitespace

**Technical Notes:**

- Input: Top 10-20 trend names from `DA-AI04-99-06` + raw posts/comments from deep crawl bot
- Output: Clean text chunks as JSON:
  ```json
  {
    "trendName": "trà sữa đất nung",
    "chunks": [
      {
        "chunk_id": "chunk_0",
        "text": "Trà Sữa Đất Nung at 10 Hàng Bồ, Hoàn Kiếm, Hà Nội..."
      }
    ]
  }
  ```
- Ensure chunk boundaries do not break Vietnamese sentence semantics

**Dependencies:** Blocked by: DA-AI04-99-06. Blocks: DA-AI04-99-05.

---

### DA-AI04-99-05 — Design hybrid database schema (ChromaDB + Neo4j NER Graph)

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Design schema and sync mechanism between Vector DB (ChromaDB with `all-MiniLM-L6-v2` 384-dim embeddings) and Graph DB (Neo4j with entity nodes `KOL`, `Dish`, `Location`), linked via `:Trend` node to support GraphRAG queries.

**Acceptance Criteria:**

- [ ] Define ChromaDB schema: ID, document content, embedding model, metadata filter (`trendName`)
- [ ] Define Neo4j schema: Nodes (`KOL`, `Dish`, `Location`, `Trend`), Edges (`PROMOTED`, `ASSOCIATED_WITH`, `LOCATED_IN`)
- [ ] Design background Entity Resolution job to merge semantically similar Neo4j nodes
- [ ] Ensure ChromaDB `trendName` metadata + Neo4j relationships both point to the same root `:Trend` node (supporting Hybrid Retrieval latency < 100ms)

**Technical Notes:**

- Input: clean text chunks with `trendName` from `DA-AI04-99-04`
- NER pipeline: text chunk → LLM (Llama 3 API) → entity list → Cypher `MERGE`
- Chroma config: `all-MiniLM-L6-v2`, 384-dim vector, metadata field `trendName`
- ChromaDB needs optimized index for `trendName` metadata filter → latency < 100ms

**Dependencies:** Blocked by: DA-AI04-99-04. Blocks: DA-AI04-99-07.

---

### DA-AI04-99-06 — Design Redis cache & Neo4j upsert flow

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Design Redis cache structure (Sorted Set ZSET, TTL 6h) and Cypher upsert queries (`MERGE` + `ON CREATE SET` / `ON MATCH SET`) for trend scores to Neo4j, ensuring `/ai/trends` API reads directly from Redis.

**Acceptance Criteria:**

- [ ] Design Redis structure: key `trends:vn:{date}:{category}`, Sorted Set type, score = `final_score`, TTL 6h
- [ ] Write Cypher `MERGE` + `ON CREATE SET` / `ON MATCH SET` to upsert score/rank into `:Trend` node without losing creation history
- [ ] Ensure Redis and Neo4j writes are transactional to prevent dashboard sync issues

**Technical Notes:**

- Input: Top 10-20 trend ranking from `DA-AI04-99-03`
- Output: Redis (sync cache, hot read) + Neo4j (historical storage, graph query)

**Dependencies:** Blocked by: DA-AI04-99-03. Blocks: DA-AI04-99-07.

---

### DA-AI04-99-07 — Compile final crawl trend analysis blueprint document

**Assignee:** Tuấn (AI) | **Priority:** 🟡 High

**Goal:** Consolidate all analysis, algorithms (BM25, Centrality), mathematical formulas, database schemas (ChromaDB, Neo4j, Redis), and API designs from tasks DA-AI04-99-01 → 06 into a complete blueprint document `report_crawl_trend_analysis.md` for handoff to the development team.

**Acceptance Criteria:**

- [ ] Complete `report_crawl_trend_analysis.md` with full Mermaid diagrams and real JSON/vector/graph property examples
- [ ] Handoff and alignment meeting with all AI team members

**Technical Notes:**

- Blueprint stored in the project design docs directory, used as reference throughout development

**Dependencies:** Blocked by: DA-AI04-99-03, DA-AI04-99-05, DA-AI04-99-06.

---

### DA-AI06-01 — SDXL Runtime/Inference Server Setup & SDXL-Lightning Verification

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Cấu hình và thiết lập runtime suy luận SDXL chạy độc lập (khởi đầu từ Google Colab Pro T4 16GB / Kaggle GPU Workstation, sẵn sàng di chuyển lên Dedicated GPU Server RTX 4090 24GB / AWS EC2 G5 A10G); chốt checkpoint Base chính thức `SG161222/RealVisXL_V4.0`, cấu hình suy luận FP16 kết hợp PyTorch 2.x SDPA; thiết lập môi trường kiểm chứng độc lập cho SDXL-Lightning 4-step/8-step để so sánh chất lượng thương mại và latency.

**Acceptance Criteria:**

- [ ] Thiết lập môi trường Python 3.10+, PyTorch 2.1+, CUDA 12.1+ và Diffusers 0.27+ trên Google Colab / VM Server.
- [ ] Tải và nạp thành công Base Model `SG161222/RealVisXL_V4.0` (FP16 `.safetensors`, ~6.6GB) vào VRAM:
  - Khởi tạo `StableDiffusionXLPipeline` với `torch_dtype=torch.float16`, `variant="fp16"`.
  - Kích hoạt PyTorch 2.x SDPA (`enable_xformers_memory_efficient_attention()` hoặc native scaled dot product attention).
  - VRAM sử dụng khi nạp model $\le 9.5\text{GB}$; khi suy luận 1 ảnh 1024x1024 $\le 12.0\text{GB}$.
- [ ] Thiết lập pipeline kiểm chứng độc lập cho SDXL-Lightning (ByteDance 4-step / 8-step UNet checkpoints hoặc LoRA):
  - Chạy so sánh đối chứng trên cùng 5 prompts: RealVisXL chuẩn (30 steps, Euler a, CFG 5.0) vs SDXL-Lightning (4 steps, Euler, CFG 1.5).
  - Ghi nhận metrics: Thời gian sinh ảnh, độ chi tiết chữ/vật liệu và mức ngốn VRAM.
- [ ] Xây dựng script Colab Tunnel / HTTP Mock Server (sử dụng FastAPi + `ngrok` hoặc `localtunnel`) để cung cấp endpoint trực tiếp cho Client Adapter kiểm thử:
  - Cung cấp route `POST /generate` nhận payload JSON và trả về raw image bytes PNG.
  - Cung cấp route `GET /health` trả về trạng thái GPU (`cuda_available`, `vram_allocated_mb`, `gpu_name`).
- [ ] Viết tài liệu hướng dẫn khởi chạy runtime Colab / VM tại `docs/infra/sdxl_runtime_setup.md`.

**Technical Notes:**

- Chuẩn Ponytail: Giai đoạn đầu không dựng cụm Kubernetes hay Triton Server phức tạp; chỉ cần 1 FastAPI standalone worker bọc `diffusers` pipeline.
- Đặt `torch.backends.cuda.matmul.allow_tf32 = True` và `torch.backends.cudnn.allow_tf32 = True` để tăng 20% tốc độ suy luận trên Ampere/Ada Lovelace.

**Dependencies:** Blocks: DA-AI06-02, DA-AI06-22, DA-AI06-23, DA-AI06-25, DA-AI07-01. Blocked by: None.

---

### DA-AI06-02 — Self-Hosted SDXL Inference Client Adapter

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Xây dựng module client bất đồng bộ (`app/services/sdxl_client.py`) kết nối trực tiếp đến GPU Inference Server (chạy runtime từ task DA-AI06-01) bằng `httpx.AsyncClient` theo chuẩn Ponytail/YAGNI, loại bỏ hoàn toàn phụ thuộc vào Cloud API bên thứ 3 và hỗ trợ truyền tham số linh hoạt giữa Concept Mode và Inpainting Mode.

**Acceptance Criteria:**

- [ ] Module `SDXLInferenceClient` khởi tạo nhận cấu hình `base_url = settings.sdxl_engine_url` và `api_token = settings.sdxl_engine_token` (nếu có).
- [ ] Hàm `generate_raw(prompt, negative_prompt, width, height, style_preset=None, seed=None, steps=30, cfg_scale=5.0) -> tuple[bytes, int, str]` gửi request `POST {base_url}/generate` đến GPU Server.
- [ ] Nhận dữ liệu stream raw bytes PNG trực tiếp từ GPU Server, chuyển thành `bytes` PNG chuẩn (zero temporary disk write).
- [ ] Xử lý ngoại lệ kết nối & lỗi GPU Server:
  - HTTP 400 / 422: Ném `InvalidGenerationPayloadError` kèm log chi tiết lỗi tham số
  - HTTP 503 / Timeout: GPU Server đang quá tải, cold start hoặc không phản hồi -> Ném `GPUEngineUnavailableError`
  - HTTP 500 (CUDA OOM): Ném `GPUOutOfMemoryError` báo hiệu engine hết VRAM để retry hoặc báo log
  - Timeout cấu hình: `httpx.AsyncClient(timeout=60.0)` phù hợp với thời gian sinh ảnh SDXL
- [ ] Hỗ trợ kiểm tra sức khỏe node GPU: Hàm `health_check() -> bool` gọi `GET {base_url}/health` để xác định GPU Worker đang sẵn sàng.
- [ ] Đạt 100% unit test với `pytest-httpx` mô phỏng phản hồi sinh ảnh thành công và các kịch bản lỗi mạng/GPU.

**Technical Notes:**

- Chuẩn Ponytail/YAGNI: Không cài thêm SDK nặng nề; chỉ dùng `httpx` tiêu chuẩn của FastAPI.
- Kết nối thông suốt với cả Colab Tunnel (trong giai đoạn dev) và VM Dedicated Server (khi lên production) mà không cần sửa code.

**Dependencies:** Blocks: DA-AI06-03, DA-AI06-08, DA-AI06-14. Blocked by: DA-AI06-01.

---

### DA-AI06-03 — Aspect Ratio & SDXL Pixel Bucketing Engine

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Chuẩn hóa các kích thước ảnh đầu vào theo cơ chế Pixel Bucketing chuẩn của SDXL 1.0 (~1 Megapixel, mỗi chiều chia hết cho 64) nhằm triệt tiêu méo hình, cắt xén chủ thể và biến dạng tỷ lệ thương mại.

**Acceptance Criteria:**

- [ ] Hỗ trợ đầy đủ 6 tỷ lệ khung hình thương mại phổ biến:
  - `1:1` -> `1024 x 1024` (Instagram Post, Square Banner, Marketplace Thumbnail)
  - `4:3` -> `1152 x 896` (Standard Display Ads, Presentation)
  - `16:9` -> `1344 x 768` (Website Hero Header, YouTube Landscape, Facebook Cover)
  - `9:16` -> `768 x 1344` (TikTok Video Background, Instagram Story, Reels)
  - `2:3` -> `832 x 1216` (Poster dọc, Lookbook thời trang)
  - `21:9` -> `1536 x 640` (Ultrawide Panoramic Banner)
- [ ] Hàm `get_bucketed_dimensions(aspect_ratio: str) -> tuple[int, int]` ánh xạ chính xác tỷ lệ sang pixel.
- [ ] Ném `UnsupportedAspectRatioError` với thông điệp rõ ràng nếu client truyền tỷ lệ không hợp lệ.
- [ ] Mọi cặp kích thước trả về đều đảm bảo: `(width * height) ≈ 1_048_576` pixels ($\pm 5\%$) và `width % 64 == 0`, `height % 64 == 0`.
- [ ] Đạt 100% unit test kiểm thử toàn bộ 6 tỷ lệ và các trường hợp nhập sai.

**Technical Notes:**

- SDXL được huấn luyện đa độ phân giải trên các bucket chia hết cho 64; lệch khỏi các bucket này sẽ gây biến dạng hình thể nặng.

**Dependencies:** Blocks: DA-AI06-08. Blocked by: None.

---

### DA-AI06-04 — Visual Style Preset Mapping Engine

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Xây dựng danh mục 15 Master Commercial Styles thương mại chuyên biệt kết hợp Ma trận tương thích 6 Topic LoRAs (Food, Fashion, Entertainment, Cosmetics, Tech, Living); ánh xạ lựa chọn của người dùng sang các token thị giác chuẩn mực về ánh sáng, góc máy, vật liệu và không khí tiếp thị, loại bỏ việc người dùng phải tự nghĩ prompt phức tạp.

**Acceptance Criteria:**

- [ ] Module `StylePresetEngine` quản lý 15 Master Style Presets đa ngành:
  - `minimalist_studio`: `on smooth geometric concrete pedestal, clean negative space, soft ambient studio daylight, architectural shadows, minimalist scandinavian design` (Tương thích: Tech, Living)
  - `luxury_marble_gold`: `on polished black carrara marble podium with fine golden veins, dramatic low-key studio lighting, gold rim highlights, high-end luxury commercial` (Tương thích: Cosmetics, Fashion)
  - `kbeauty_pastel_fresh`: `soft morning diffused sunlight, delicate water ripples, blurred pastel peony petals, clean airy aesthetic, premium skincare photography` (Tương thích: Cosmetics)
  - `tropical_nature_organic`: `on wet raw slate stone, surrounded by lush monstera leaves, natural sunlight filtering through canopy, organic clean product shot` (Tương thích: F&B, Cosmetics)
  - `cyberpunk_neon_tech`: `on brushed titanium circular platform, sharp blue and magenta neon rim lighting, dark moody background, sleek tech gadget showcase` (Tương thích: Tech, Entertainment)
  - `rustic_warm_food`: `on rustic dark oak kitchen table, subtle rising steam, fresh rosemary herbs, warm tungsten ambient light, cozy culinary photography` (Tương thích: F&B)
  - `vibrant_pop_color`: `dynamic color-blocking background, bright saturated studio lighting, sharp geometric shadows, energetic commercial advertising` (Tương thích: Fashion, F&B)
  - `editorial_high_fashion`: `stark studio backdrop, high contrast directional strobe lighting, avant-garde magazine lookbook aesthetic` (Tương thích: Fashion)
  - ... (cùng các presets: Retro Vintage, Pure Clean Domestic, Festive Holiday, Stage Concert).
- [ ] Bổ sung Ma trận tương thích Topic LoRA: Mỗi preset chỉ định `default_topic_id` và `recommended_lora_scale` ($0.60 - 0.75$) để tối ưu chất cảm vật liệu khi kết hợp với Topic LoRA tương ứng.
- [ ] Mỗi preset đóng gói: `positive_tokens`, `negative_tokens_override`, `recommended_cfg` và `recommended_steps`.
- [ ] Hàm `apply_style_preset(prompt: str, preset_name: str) -> tuple[str, str, Optional[str]]` ghép token vào prompt chính xác, trả về topic gợi ý đi kèm.
- [ ] Cho phép `preset_name=None` hoặc `"none"` để sinh ảnh theo mô tả thuần túy không qua preset.

**Technical Notes:**

- Các token phong cách được đặt ở cuối prompt chủ thể để bổ trợ bối cảnh mà không làm lu mờ vật thể trung tâm.

**Dependencies:** Blocks: DA-AI06-07, DA-AI06-08, DA-AI06-15. Blocked by: None.

---

### DA-AI06-05 — Multi-tier Safety Negative Prompt Injection

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Xây dựng hệ thống tiêm Negative Prompt an toàn đa tầng: triệt tiêu nội dung NSFW, bạo lực, lỗi dị tật ngón tay; tự động tiêm fallback negative ngăn người lạ xuất hiện khi chụp sản phẩm tĩnh không kèm model (`person, human, face, hands, body...`).

**Acceptance Criteria:**

- [ ] Tầng 1 — Base Brand Safety Negative: Luôn được tiêm vào mọi request:
  `nudity, nsfw, pornographic, violence, gore, deformed anatomy, bad eyes, extra fingers, mutated hands, missing limbs, blur, low quality, oversaturated, watermark, signature, username, error, ugly`.
- [ ] Tầng 2 — Product Only Fallback Negative: Tự động kích hoạt khi request KHÔNG chọn model character (`has_character = False`):
  `person, human, woman, man, girl, boy, model, face, eyes, hands, fingers, skin, portrait, character`.
- [ ] Tầng 3 — User Negative Prompt Concatenation: Hợp nhất an toàn prompt phủ định do người dùng nhập thêm (loại bỏ trùng lặp từ khóa, không cho phép xóa đè Tầng 1).
- [ ] Hàm `build_negative_prompt(user_negative: Optional[str], has_character: bool = False) -> str` trả về chuỗi negative prompt hoàn chỉnh.
- [ ] Unit test chứng minh: Request chụp sản phẩm không model tuyệt đối không sinh ra khuôn mặt hoặc bàn tay người ngẫu nhiên.

**Technical Notes:**

- Fallback negative cho sản phẩm tĩnh giải quyết 95% trường hợp SDXL tự ý vẽ thêm người mẫu cầm sản phẩm ngoài ý muốn.

**Dependencies:** Blocks: DA-AI06-07, DA-AI06-08, DA-AI06-15. Blocked by: None.

---

### DA-AI06-06 — Input Sanitization & Blacklist Guardrails

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Quét và chặn đứng các prompt độc hại, tấn công tiêm nhiễm (Jailbreak, Prompt Injection) và từ khóa cấm ngay tại tầng API trước khi gửi sang GPU Server, bảo vệ uy tín thương hiệu và tiết kiệm tài nguyên GPU.

**Acceptance Criteria:**

- [ ] Danh mục từ cấm (`resources/guardrails/blacklist.txt`):
  - Từ ngữ khiêu dâm, bạo lực, chính trị nhạy cảm, người nổi tiếng / trẻ em.
  - Tên các thương hiệu cạnh tranh lớn nhằm tránh tranh chấp bản quyền logo trực diện.
- [ ] Regex Scanner phát hiện các mẫu Prompt Injection kinh điển: `ignore previous instructions`, `system prompt`, `dan mode`, `bypass safety filter`.
- [ ] Hàm `sanitize_and_validate_prompt(prompt: str) -> str`:
  - Chuẩn hóa ký tự Unicode, loại bỏ các ký tự điều khiển ẩn (zero-width spaces).
  - Giới hạn độ dài: tối đa 500 ký tự cho prompt người dùng.
  - Ném `PromptPolicyViolationError(violated_term)` khi phát hiện vi phạm.
- [ ] Đạt 100% unit test kiểm thử 30 câu test case độc hại và câu prompt hợp lệ.

**Technical Notes:**

- Fail-fast tại tầng CPU giúp tiết kiệm 100% tài nguyên GPU cho các request vi phạm chính sách.

**Dependencies:** Blocks: DA-AI06-08, DA-AI06-15. Blocked by: None.

---

### DA-AI06-07 — Hybrid Form-to-Prompt Engine (Core UX Feature)

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Xây dựng engine tự động tổng hợp Form nhập liệu trực quan (Ngành hàng, Bối cảnh, Ánh sáng, Màu sắc, Góc chụp) kết hợp với Prompt mô tả của người dùng thành Master Prompt tiếng Anh chuẩn studio thương mại; tích hợp bộ nhận diện tín hiệu chủ đề tự động (**Implicit Intent Routing Signal Detector**) để tự động phát hiện và gán đúng 1 trong 6 Topic LoRAs (Food, Fashion, Entertainment, Cosmetics, Tech, Living) kèm Perspective Guard khóa góc chụp đồng bộ.

**Acceptance Criteria:**

- [ ] Cấu trúc Form Input tiếp thị hỗ trợ:
  - `industry_topic`: Chọn cụ thể từ 6 topics `["fnb", "fashion", "entertainment", "cosmetics", "tech", "living"]` hoặc để mặc định `"auto"` (Tự động nhận diện)
  - `subject`: Tên và đặc điểm sản phẩm (vd: "chai serum hoa hồng thủy tinh")
  - `environment_preset`: Chọn bối cảnh podium/studio từ danh mục 15 Master Styles
  - `camera_angle`: Perspective Guard (`eye_level`, `top_down_flatlay`, `angle_45_studio`)
  - `lighting`: Lựa chọn ánh sáng (`softbox_diffused`, `dramatic_rim_light`, `warm_golden_hour`)
  - `brand_colors`: Danh sách mã màu Hex từ Brand Kit (ví dụ: `["#008060", "#F4F6F8"]`)
  - `custom_user_prompt`: Câu mô tả bổ sung tự do của người dùng (tùy chọn)
- [ ] Xây dựng bộ nhận diện tín hiệu 3 tầng (**Hybrid 3-Tier Intent Router**):
  - **Tầng 1 (Explicit):** Nếu người dùng chủ động chọn `industry_topic` khác `"auto"` -> Gán trực tiếp Topic LoRA tương ứng ($0\text{ms}$ CPU, độ chính xác $100\%$).
  - **Tầng 2 (Implicit Signal Matcher):** Khi `industry_topic="auto"` hoặc gõ prompt tự do -> Chạy bộ quét Pre-compiled Regex song ngữ (Việt - Anh) đối chiếu với từ điển từ khóa đặc thù của 6 ngành hàng:
    - *Food/F&B:* `cà phê`, `trà sữa`, `bánh mì`, `đồ ăn`, `hơi bốc khói`, `nước ép`, `coffee`, `burger`, `beverage`... -> `lora_food_v1`
    - *Fashion:* `váy`, `áo khoác`, `blazer`, `túi xách`, `giày`, `lụa`, `streetwear`, `dress`, `suit`, `lookbook`... -> `lora_fashion_v1`
    - *Entertainment:* `sân khấu`, `concert`, `ánh đèn neon`, `poster phim`, `dj`, `lễ hội`, `rave`, `stage`... -> `lora_entertainment_v1`
    - *Cosmetics:* `serum`, `son môi`, `kem dưỡng`, `toner`, `nước hoa`, `chăm sóc da`, `skincare`, `lotion`... -> `lora_beauty_v1`
    - *Tech:* `tai nghe`, `điện thoại`, `laptop`, `smartwatch`, `bàn phím cơ`, `gadget`, `headphones`... -> `lora_tech_v1`
    - *Living:* `phòng khách`, `căn hộ`, `ban công`, `nội thất`, `furniture`, `cozy interior`, `living room`... -> `lora_living_v1`
    - Tốc độ xử lý đạt $< 0.2\text{ms}$ trên CPU, không tạo nghẽn mạng/hạ tầng.
  - **Tầng 3 (Safe Fallback):** Nếu prompt trung tính hoặc xuất hiện xung đột từ khóa ngang điểm -> Trả về `lora_id = None`, `lora_weight = 0.0` (sử dụng Base Model `RealVisXL_V4.0` thuần túy).
- [ ] Module `PromptSynthesizer` thực thi:
  - Trả về object `IntentResult`: `{"detected_topic": str, "lora_id": Optional[str], "trigger_token": Optional[str], "lora_weight": float, "source": "explicit"|"implicit"|"fallback"}`.
  - Tự động tiêm Trigger Token tương ứng vào Master Prompt khi có LoRA được kích hoạt.
  - **Color Token Translation:** Dịch mã Hex thành từ khóa màu tự nhiên (`#008060` -> `emerald green accent lighting`).
  - **Perspective Guard:** Ép token góc chụp tương ứng (`eye_level` -> `shot at eye-level, perfectly horizontal camera perspective`).
  - Lắp ráp Master Prompt hoàn chỉnh: `[Trigger Token], [Subject], [Environment], [Color Lighting], [Camera Angle], [Master Commercial Quality Tokens]`.
- [ ] Unit test kiểm tra độ chính xác của bộ quét Intent với 50 câu prompt mẫu (Việt & Anh) đạt độ chính xác $\ge 92\%$.

**Technical Notes:**

- Chuẩn Ponytail: Sử dụng Pre-compiled Regex stdlib thay vì nạp mô hình BERT/LLM phân loại nặng nề; tốc độ quét đạt < 0.2ms trên CPU, tiết kiệm 100% VRAM GPU.

**Dependencies:** Blocks: DA-AI06-08, DA-AI06-15. Blocked by: DA-AI06-04, DA-AI06-05.

---

### DA-AI06-08 — Pydantic Schemas & POST /ai/image/generate Route

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Xây dựng API router và Data Contract kiểm duyệt dữ liệu đầu vào / đầu ra cho endpoint sinh ảnh ý tưởng `POST /ai/image/generate` (Track A - Concept Studio); tích hợp điều phối Topic Routing tự động; điều phối toàn bộ chuỗi xử lý từ làm sạch prompt, bucketing, gọi GPU đến trả về kết quả.

**Acceptance Criteria:**

- [ ] Định nghĩa Pydantic Schemas trong `app/schemas/image_generation.py`:
  - `ImageGenerateRequest`: `prompt: Optional[str]`, `form_data: Optional[CommercialFormInput]`, `industry_topic: Optional[str] = "auto"` (hỗ trợ `["fnb", "fashion", "entertainment", "cosmetics", "tech", "living", "auto"]`), `aspect_ratio: str = "1:1"`, `style_preset: Optional[str]`, `seed: Optional[int]`, `steps: int = 30`, `has_character: bool = False`, `brand_id: Optional[str]`.
  - `ImageGenerateResponse`: `image_url: str`, `width: int`, `height: int`, `aspect_ratio: str`, `seed: int`, `detected_topic: Optional[str]`, `applied_lora: Optional[str]`, `lora_weight: float`, `generation_time_ms: int`.
- [ ] Endpoint `POST /ai/image/generate` điều phối chuỗi xử lý:
  - B1: Validate & sanitize prompt qua DA-AI06-06.
  - B2: Tổng hợp Master Prompt & nhận diện Topic LoRA qua DA-AI06-07 (gọi Intent Router) và Style Preset qua DA-AI06-04.
  - B3: Tính toán kích thước Pixel Bucketing qua DA-AI06-03.
  - B4: Tiêm Safety Negative Prompt qua DA-AI06-05.
  - B5: Gửi request kèm `lora_id` và `lora_weight` đến SDXL Client Adapter (DA-AI06-02).
  - B6: Tải ảnh lên S3 qua DA-AI06-09 và trả về Presigned URL kèm metadata chủ đề được nhận diện.
- [ ] Trả về mã lỗi HTTP chuẩn:
  - 400: Vi phạm từ khóa cấm hoặc tham số không hợp lệ
  - 503: GPU Worker bận hoặc không khả dụng
  - 500: Lỗi hệ thống nội bộ
- [ ] Đạt 100% unit test với router FastAPI, mô phỏng phản hồi giả lập thành công.

**Technical Notes:**

- Hệ thống tự động kích hoạt Topic LoRA tương ứng nếu bắt được tín hiệu, nhưng nếu không có tín hiệu vẫn chạy Base Model mượt mà mà không bao giờ bị nghẽn (Zero-block).

**Dependencies:** Blocks: DA-AI06-09. Blocked by: DA-AI06-02, DA-AI06-03, DA-AI06-04, DA-AI06-05, DA-AI06-06, DA-AI06-07.

---

### DA-AI06-09 — In-Memory Streaming S3 Upload & Brand Logo Stamp

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Tiếp nhận luồng bytes từ GPU, tùy chọn đóng dấu Logo thương hiệu in-memory bằng Pillow theo chuẩn Zero-Training Brand Kit và streaming thẳng lên AWS S3 (zero disk I/O), cấp phát Presigned URL có thời hạn 24h.

**Acceptance Criteria:**

- [ ] Hàm `process_and_upload_image(raw_bytes: bytes, s3_key: str, logo_bytes: Optional[bytes] = None, logo_position: str = "bottom_right") -> str`:
  - Đọc trực tiếp từ `io.BytesIO(raw_bytes)` trong RAM, không ghi file tạm ra ổ đĩa.
  - Nếu có `logo_bytes`: Sử dụng `PIL.Image` dán logo sắc nét vào góc chỉ định (cách viền 5% Safe Margin Padding), bảo toàn 100% alpha transparency.
  - Upload stream lên AWS S3 bằng `boto3.client('s3').upload_fileobj()` với `ContentType='image/png'`.
  - Sinh Presigned URL thời hạn 24 giờ (`expires_in=86400`).
- [ ] Cấu hình S3 Key có phân vùng rõ ràng: `s3://brandhub-media/{client_id}/images/{YYYY}/{MM}/{uuid}.png`.
- [ ] Đạt 100% unit test với `moto` mock AWS S3 và kiểm thử dán logo bằng Pillow.

**Technical Notes:**

- Zero Disk I/O: Giảm hao mòn ổ đĩa server và triệt tiêu nguy cơ rò rỉ dữ liệu thương hiệu trên đĩa cục bộ.
- Logo Stamp thực thi trong < 20ms trên CPU, mang lại giá trị nhận diện thương hiệu tuyệt đối mà không cần train LoRA.

**Dependencies:** Blocks: DA-AI06-10, DA-AI06-11, DA-AI06-14. Blocked by: DA-AI06-08.

---

### DA-AI06-10 — Latency Tracking, Custom Response Headers & Observability

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Đo lường chi tiết thời gian thực thi từng công đoạn, gắn custom headers `X-Generation-Time-Ms` và ghi log có cấu trúc để giám sát SLO (P95 < 30s).

**Acceptance Criteria:**

- [ ] Gắn custom header vào response:
  - `X-Generation-Time-Ms`: Tổng thời gian từ khi nhận request đến khi trả về URL
  - `X-GPU-Inference-Time-Ms`: Thời gian GPU suy luận thuần túy
  - `X-SDXL-Bucket`: Kích thước width x height được chọn
- [ ] Ghi log có cấu trúc dạng JSON: `timestamp`, `request_id`, `client_id`, `prompt_length`, `aspect_ratio`, `steps`, `latency_ms`, `status`.
- [ ] Thiết lập ngưỡng cảnh báo: Nếu tổng latency vượt quá 30 giây, ghi log WARNING kèm thông số chi tiết để điều tra nghẽn mạng/GPU.

**Technical Notes:**

- Dùng `time.perf_counter()` đo thời gian với độ chính xác cao.

**Dependencies:** Blocks: DA-AI06-11, DA-AI06-16. Blocked by: DA-AI06-09.

---

### DA-AI06-11 — Concurrent Generation Orchestration via asyncio.gather

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Xây dựng endpoint `POST /ai/image/generate/batch` cho phép sinh đồng thời 2–4 biến thể ảnh trong một request bằng `asyncio.gather` được kiểm soát bởi Semaphore để tránh gây quá tải VRAM của GPU Worker.

**Acceptance Criteria:**

- [ ] Endpoint `POST /ai/image/generate/batch` nhận tham số `num_images: int = Field(default=3, ge=1, le=4)`.
- [ ] Sử dụng `asyncio.Semaphore(settings.max_concurrent_gpu_tasks)` để giới hạn số lượng request đồng thời gửi tới GPU Server.
- [ ] Sử dụng `asyncio.gather(*tasks, return_exceptions=True)` để thực thi song song các biến thể ảnh.
- [ ] Trả về mảng danh sách `images: list[ImageVariationResult]` kèm chỉ số `variation_index` và `seed`.
- [ ] Unit test kiểm chứng: Khi client yêu cầu 3 ảnh, hệ thống gọi đúng 3 luồng suy luận và gom kết quả đầy đủ.

**Technical Notes:**

- Điều phối concurrency tại tầng API giúp bảo vệ GPU Worker khỏi việc bị nghẽn queue hoặc crash do quá tải yêu cầu đồng thời.

**Dependencies:** Blocks: DA-AI06-12, DA-AI06-13. Blocked by: DA-AI06-09, DA-AI06-10.

---

### DA-AI06-12 — Seed Diversity & Visual Variation Strategy

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Đảm bảo các ảnh trong cùng một batch sinh ra có sự đa dạng góc máy/bố cục rõ rệt nhưng vẫn giữ nguyên vẹn tính nhất quán về sản phẩm và phong cách chủ đạo.

**Acceptance Criteria:**

- [ ] Cơ chế sinh Seed: Mỗi biến thể trong batch nhận một `seed` ngẫu nhiên độc lập (`random.randint(1, 2**32 - 1)`).
- [ ] Bổ sung vi biến thể góc chụp (Sub-angle Variation) cho từng ảnh trong batch nếu người dùng không khóa cứng góc máy:
  - Biến thể 1: `front eye-level view`
  - Biến thể 2: `slight high angle 30 degree view`
  - Biến thể 3: `close-up detailed macro shot`
- [ ] Đảm bảo tính tái lập: Nếu client truyền lại đúng mảng `seed` cũ, hệ thống sinh lại chính xác 100% hình ảnh tương ứng.
- [ ] Unit test kiểm tra: Các seeds trong cùng batch không bao giờ bị trùng lặp.

**Dependencies:** Blocks: DA-AI06-13. Blocked by: DA-AI06-11.

---

### DA-AI06-13 — Partial Failure Handling & Credit Safety

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Xử lý sự cố từng phần trong batch (nếu 1 ảnh bị lỗi timeout/GPU thì các ảnh thành công khác vẫn trả về bình thường) và audit trừ credit chính xác theo số lượng ảnh thực sự thành công.

**Acceptance Criteria:**

- [ ] Khi thực thi batch qua `asyncio.gather(..., return_exceptions=True)`:
  - Phân loại kết quả thành `successful_images` và `failed_images`.
  - Nếu có ít nhất 1 ảnh thành công: Trả về HTTP 200 kèm danh sách ảnh hợp lệ và thông báo cảnh báo về ảnh lỗi (`partial_success = True`).
  - Nếu toàn bộ ảnh đều lỗi: Trả về HTTP 503 / 500 kèm chi tiết nguyên nhân lỗi.
- [ ] Tích hợp tính năng trừ credit: Chỉ gửi event trừ credit cho số lượng ảnh thực tế thành công (`billed_credits = len(successful_images)`).
- [ ] Ghi audit log giao dịch credit: `client_id`, `requested_count`, `successful_count`, `refunded_credits`.

**Technical Notes:**

- Bảo vệ quyền lợi tài chính của khách hàng, triệt tiêu tình trạng người dùng bị trừ tiền oan khi GPU gặp lỗi gián đoạn mạng.

**Dependencies:** Blocks: DA-AI06-14, DA-AI06-15. Blocked by: DA-AI06-11, DA-AI06-12.

---

### DA-AI06-14 — Real Product Studio Inpainting & Commercial Placement (Track B)

**Assignee:** Tuấn (AI) & Lộc (Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Xây dựng pipeline Inpainting chuyên dụng cho ảnh sản phẩm thật của merchant (`POST /ai/image/generate-product-studio` — Track B). Tách nền sạch bằng `rembg` (chạy ONNX trên CPU), tự động căn giữa và tạo binary mask bảo vệ, sử dụng `RealVisXL Inpainting` tái tạo bối cảnh studio với bóng đổ tiếp xúc tự nhiên (Contact Shadow Injection) và làm mềm viền (Pillow Feathering), bảo toàn 100% chi tiết logo/nhãn mác (Zero Product Distortion).

**Acceptance Criteria:**

- [ ] Xây dựng endpoint `POST /ai/image/generate-product-studio` tiếp nhận `product_image` (Multipart/form-data hoặc base64/URL) kèm các tham số bối cảnh studio.
- [ ] Bước 1 — Background Removal & Centering (CPU):
  - Tách nền sản phẩm bằng `rembg` (model `u2net` hoặc `birefnet-general`) hoàn toàn trên CPU (thời gian $\le 1.5\text{s}$).
  - Căn chỉnh tỷ lệ sản phẩm chiếm 40% – 55% diện tích khung hình trung tâm, đặt trên mặt phẳng sàn chuẩn.
- [ ] Bước 2 — Binary Inpaint Mask Generation:
  - Sinh mask nhị phân từ kênh Alpha: Vùng sản phẩm = 0 (khóa tuyệt đối), vùng nền = 255 (cho phép AI sinh bối cảnh).
  - Áp dụng `PIL.ImageFilter.GaussianBlur(radius=1.5)` làm mềm viền tiếp giáp (Alpha Feathering 1–2px) để tránh hiện tượng viền sắc lẹm.
- [ ] Bước 3 — Studio Inpainting Execution (GPU):
  - Gửi ảnh sản phẩm + mask + prompt bối cảnh sang `AutoPipelineForInpainting` của RealVisXL.
  - Vùng sản phẩm gốc được giữ nguyên bản 100% từng điểm ảnh (Zero Distortion cho nhãn mác, font chữ, logo).
- [ ] Bước 4 — Contact Shadow Injection (CPU):
  - Đổ bóng mờ tiếp xúc hình ellipse dưới chân sản phẩm bằng Pillow để sản phẩm hòa nhập tự nhiên vào mặt bục studio, xóa bỏ cảm giác "cắt dán lơ lửng".
- [ ] Tích hợp kiểm thử đối chứng: 5 sản phẩm thực tế (chai nước hoa, hộp bánh, lon nước ngọt, chai serum, tai nghe) đạt chất lượng thương mại hoàn hảo.

**Technical Notes:**

- Tính năng sống còn phân biệt BrandHub với các công cụ tạo ảnh đồ họa thông thường; bảo đảm 100% tính toàn vẹn thương hiệu cho nhà bán hàng.

**Dependencies:** Blocks: DA-AI06-15. Blocked by: DA-AI06-02, DA-AI06-08, DA-AI06-09, DA-AI06-13.

---

### DA-AI06-15 — 20 Commercial Product Prompts Dataset Across 5 Categories

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Thiết kế bộ benchmark dataset gồm 20 kịch bản sản phẩm thương mại thực tế, phân bổ đều trên 5 nhóm ngành hàng trọng điểm để đánh giá định lượng cả Track A (Concept) và Track B (Real Product Inpainting).

**Acceptance Criteria:**

- [ ] Soạn thảo file cấu hình `tests/benchmarks/commercial_20_prompts.json` gồm 20 kịch bản chi tiết:
  - **Category 1: F&B** (4 kịch bản: Cà phê phin truyền thống, Nước ngọt lon mùa hè, Bánh ngọt phong cách Pháp, Rượu vang cao cấp)
  - **Category 2: Cosmetics & Skincare** (4 kịch bản: Chai serum tinh chất hoa hồng, Hũ kem dưỡng da thủy tinh, Thỏi son lì velvet, Dầu gội organic)
  - **Category 3: Fashion & Accessories** (4 kịch bản: Đồng hồ dây da cổ điển, Kính mát thời trang, Giày sneaker thể thao, Ví da tối giản)
  - **Category 4: Electronics & Tech** (4 kịch bản: Tai nghe true wireless, Loa bluetooth chống nước, Bàn phím cơ không dây, Ốp lưng điện thoại)
  - **Category 5: Home & Living** (4 kịch bản: Nến thơm tinh dầu, Bình giữ nhiệt inox, Cốc gốm thủ công, Nước rửa tay tạo bọt)
- [ ] Mỗi kịch bản bao gồm: `id`, `category`, `product_name`, `input_prompt`, `form_options`, `style_preset`, `target_aspect_ratio`, `expected_elements`, `ground_truth_product_image_url` (cho Track B).
- [ ] Bộ dataset được lưu trữ và lập phiên bản trên Git/S3 để tái sử dụng xuyên suốt toàn bộ các đợt benchmark.

**Dependencies:** Blocks: DA-AI06-16. Blocked by: DA-AI06-04, DA-AI06-05, DA-AI06-06, DA-AI06-07, DA-AI06-13, DA-AI06-14.

---

### DA-AI06-16 — Automated Benchmark Runner & Latency/Quality Metrics

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Xây dựng script tự động chạy qua toàn bộ 20 prompt benchmark, đo đạc latency P95 và chấm điểm định lượng (Visual Quality >= 4.2/5, Brand Consistency Score >= 4.0/5, Product Preservation = 100%).

**Acceptance Criteria:**

- [ ] Xây dựng script `scripts/run_commercial_benchmark.py`:
  - Đọc tự động file `commercial_20_prompts.json`.
  - Thực thi tuần tự hoặc batch qua API `POST /ai/image/generate` (Track A) và `POST /ai/image/generate-product-studio` (Track B).
  - Tự động tải ảnh kết quả về thư mục kiểm chứng `artifacts/benchmark_results/{timestamp}/`.
- [ ] Thu thập và tính toán các chỉ số kỹ thuật:
  - Latency: Min, Max, Mean, Median, P95 (mục tiêu P95 $\le 15\text{s}$ trên GPU server).
  - Tỷ lệ thành công: Success Rate $\ge 95\%$.
  - Mức tiêu thụ VRAM trung bình và đỉnh điểm.
- [ ] Đánh giá chất lượng hình ảnh theo thang điểm 5:
  - Visual Quality (Độ nét, chi tiết, vật liệu) $\ge 4.2/5.0$
  - Product Preservation (Bảo toàn nguyên vẹn nhãn mác trong Track B) = $100\%$
- [ ] Xuất báo cáo tự động dạng Markdown: `benchmark_summary.md` kèm bảng số liệu và lưới ảnh thumbnail trực quan.

**Dependencies:** Blocks: DA-AI06-17. Blocked by: DA-AI06-10, DA-AI06-15.

---

### DA-AI06-17 — Prompt Template Library & SDXL Failure Analysis Report

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Biên soạn tài liệu phân tích 5 lỗi cố hữu của SDXL trong ảnh thương mại, giải pháp khắc phục thực tế và đóng gói Top 10 Master Templates cho người dùng cuối; bàn giao báo cáo cho EPIC Documentation DA-AI11-03.

**Acceptance Criteria:**

- [ ] Phân tích chi tiết 5 lỗi cố hữu (Failure Modes) của SDXL và cơ chế phòng vệ:
  1. *Text Rendering Distortion (Chữ bị méo mó):* Khắc phục bằng Track B Inpainting + Pillow Logo Stamp.
  2. *Lệch trục phối cảnh (Perspective Mismatch):* Khắc phục bằng Perspective Guard qua Form UX.
  3. *Hiện tượng dán phẳng (Sticker Effect):* Khắc phục bằng Pillow Alpha Feathering + Contact Shadow.
  4. *Biến dạng chi thể (Anatomy artifacts khi có người):* Khắc phục bằng Brand Safety Negative Prompt.
  5. *Độ bão hòa quá mức (Oversaturation):* Khắc phục bằng việc khống chế CFG Scale ở mức $4.5 - 6.0$.
- [ ] Đóng gói thư viện Top 10 Master Templates sẵn sàng sử dụng cho Web Dashboard.
- [ ] Xuất bản tài liệu kỹ thuật hoàn chỉnh tại `docs/research/sdxl_commercial_failure_analysis.md`.

**Dependencies:** Blocks: DA-AI11-03 (Documentation Epic). Blocked by: DA-AI06-16.

---

### DA-AI06-18 — Canonical Identity & Multi-View References Curation

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Xây dựng bộ đặc tả danh tính chuẩn (Canonical Identity Spec) và thu thập/sinh tập ảnh tham chiếu đa góc chụp cho từng virtual identity (25–35 ảnh) làm nền tảng huấn luyện LoRA Đại sứ ảo độc quyền.

**Acceptance Criteria:**

- [ ] Tài liệu đặc tả hồ sơ danh tính (`resources/identities/{identity_id}/identity_spec.json`):
  - Nhân trắc học: Độ tuổi, giới tính, tone da, màu mắt, cấu trúc xương mặt, dáng mũi.
  - Phong cách thời trang và thần thái thương hiệu (Brand Persona).
- [ ] Tuyển chọn và làm sạch bộ ảnh tham chiếu đa góc chụp (25–35 ảnh):
  - 10 ảnh cận cảnh khuôn mặt (Headshot: chính diện, nghiêng 45°, nghiêng 90°, ngước nhẹ, cúi nhẹ).
  - 10 ảnh trung cảnh nửa người (Upper body: nhiều kiểu trang phục công sở/casual).
  - 5–10 ảnh toàn thân (Full body: các tư thế đứng, ngồi, cầm sản phẩm).
  - Biểu cảm đa dạng: Cười tươi, tự tin, trung tính, thanh lịch.
- [ ] Độ phân giải ảnh gốc $\ge 1024 	imes 1024$, ánh sáng rõ nét, không bị mờ nhòe hay nhiễu hạt.
- [ ] Kiểm duyệt 100% ảnh đạt chuẩn nhân diện đồng nhất trước khi đưa vào pipeline captioning.

**Dependencies:** Blocks: DA-AI06-21. Blocked by: None.

---

### DA-AI06-19 — Training Dataset Collection & Quality Curation

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Thu thập, tuyển chọn và chuẩn hóa bộ dữ liệu hình ảnh thương mại chất lượng cao (120 – 150 ảnh) phục vụ huấn luyện LoRA cho BrandHub.

**Acceptance Criteria:**

- [ ] Thu thập 120 – 150 ảnh thương mại có bản quyền / giấy phép thương mại mở hoặc sinh synthetic data chất lượng cao từ Midjourney/Flux.
- [ ] Đảm bảo sự phân bổ cân đối:
  - 40% ảnh chân dung người mẫu tương tác với sản phẩm.
  - 40% ảnh chụp sản phẩm studio cận cảnh.
  - 20% ảnh bối cảnh không gian sống/lifestyle thương mại.
- [ ] Bộ lọc chất lượng tự động: Script loại bỏ các ảnh có độ phân giải $< 1024 	imes 1024$, tỷ lệ khung hình dị thường hoặc dung lượng file $< 200\text{KB}$.
- [ ] Cấu trúc lưu trữ đồng bộ: `datasets/raw/{category}/{item_id}.png`.

**Dependencies:** Blocks: DA-AI06-20. Blocked by: None.

---

### DA-AI06-20 — Automated & Manual Dataset Captioning Pipeline

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Xây dựng pipeline tự động sinh mô tả chi tiết (captions) cho tập ảnh dataset kết hợp gán nhãn trigger word định danh bằng WD14 Tagger / Vision LLM.

**Acceptance Criteria:**

- [ ] Xây dựng script tự động gán nhãn `scripts/dataset/auto_caption.py`:
  - Sử dụng WD14 Tagger (SmilingWolf) trích xuất danbooru tags chi tiết cho từng ảnh.
  - Hỗ trợ Vision LLM (Florence-2 hoặc BLIP-2) sinh câu mô tả ngữ nghĩa tự nhiên dạng văn xuôi.
- [ ] Cơ chế chèn Trigger Token độc quyền:
  - Tiêm trigger word định danh (ví dụ: `ohwx_model`, `brandhub_ambassador_v1`) vào vị trí đầu tiên của mọi file caption text.
- [ ] Hỗ trợ công cụ rà soát thủ công: Cho phép AI Engineer duyệt qua danh sách ảnh + caption, sửa nhanh các tag sai lệch trước khi train.
- [ ] Xuất ra cặp file tương ứng: `{image_name}.png` và `{image_name}.txt`.

**Dependencies:** Blocks: DA-AI06-23. Blocked by: DA-AI06-19.

---

### DA-AI06-21 — Identity Dataset Standardization & Versioned Manifest

**Assignee:** Ân (AI) & Lộc (Review) | **Priority:** 🔴 Critical

**Goal:** Xây dựng pipeline chuẩn hóa dữ liệu ảnh danh tính: crop/scale thông minh 1024x1024, chia tập train/val 90/10 và đóng gói `dataset_manifest.json` lên S3.

**Acceptance Criteria:**

- [ ] Script `scripts/dataset/standardize_identity_dataset.py`:
  - Nhận diện khuôn mặt trung tâm và tự động smart-crop / resize về chuẩn $1024 	imes 1024$ không méo tỷ lệ.
  - Phân chia tập dữ liệu: 90% Training set, 10% Validation set.
- [ ] Tạo file metadata `dataset_manifest.json`:
  - Ghi nhận: `dataset_version`, `identity_id`, `total_images`, `train_count`, `val_count`, `checksum_sha256` của từng file.
- [ ] Đóng gói và đẩy dataset lên S3: `s3://brandhub-datasets/identities/{identity_id}/{version}/`.
- [ ] Khả năng tải về và giải nén 1-click trên môi trường training Cloud GPU.

**Dependencies:** Blocks: DA-AI06-23. Blocked by: DA-AI06-18.

---

### DA-AI06-22 — Cloud Training Fault-Tolerance: Checkpoint, Restart & Exact Resume

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Thiết lập cơ chế tự động hóa lưu checkpoint định kỳ mỗi 200 steps và khôi phục trạng thái huấn luyện chính xác (Exact Resume) trên Kaggle/Cloud GPU khi bị ngắt phiên đột ngột.

**Acceptance Criteria:**

- [ ] Cấu hình lưu checkpoint trong script huấn luyện:
  - Tự động lưu checkpoint mỗi 200 steps (lưu đầy đủ model weights, optimizer state, lr_scheduler state và step counter).
  - Tự động đồng bộ checkpoint lên S3 / Google Drive sau mỗi chu kỳ lưu để phòng ngừa phiên chạy bị tắt đột ngột (spot instance preemption hoặc timeout 12h của Colab/Kaggle).
- [ ] Tính năng Exact Resume:
  - Tham số `--resume_from_checkpoint <path_or_s3_uri>` tự động nạp lại đúng step đã dừng, không phải train lại từ đầu.
  - Khôi phục chính xác learning rate schedule và random seed state.
- [ ] Kiểm thử kịch bản giả lập ngắt phiên: Giả lập ngắt tiến trình ở step 450, khởi chạy lại với resume và kiểm chứng tiến trình tiếp tục chạy mượt mà từ step 451 đến 1000.

**Technical Notes:**

- Tiết kiệm 100% thời gian và chi phí huấn luyện khi tận dụng các GPU Spot giá rẻ hoặc Colab miễn phí.

**Dependencies:** Blocks: DA-AI06-23. Blocked by: DA-AI06-01.

---

### DA-AI06-23 — Identity LoRA Fine-Tuning Pipeline for Virtual Identity

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Huấn luyện Identity LoRA (Rank 32, Alpha 16) cho từng virtual identity trên nền SDXL; xuất checkpoint dạng `.safetensors` dung lượng $\le 150\text{MB}$.

**Acceptance Criteria:**

- [ ] Cấu hình huấn luyện chuẩn Kohya_ss / Diffusers LoRA:
  - Base Model: `SG161222/RealVisXL_V4.0`
  - Tham số LoRA: Network Rank $r = 32$, Network Alpha $lpha = 16$, Target modules: UNet Attention cross/self projection layers
  - Tối ưu hóa: AdamW 8-bit, Learning Rate $1	imes 10^{-4}$ (UNet), $5	imes 10^{-5}$ (Text Encoder), Cosine with Restarts schedule
  - Tích hợp kỹ thuật Regularization images (150 class images "a handsome man" / "a beautiful woman") để ngăn chặn hiện tượng model quên kiến thức nền (catastrophic forgetting).
- [ ] Quá trình huấn luyện diễn ra ổn định trong 1000 – 1500 steps, loss hội tụ mượt mà không bị spiking.
- [ ] Xuất file trọng số chuẩn: `{identity_id}_lora_v1.safetensors` với dung lượng $\le 150\text{MB}$.
- [ ] Sinh lưới ảnh kiểm chứng (Validation Grid) sau mỗi 250 steps để đánh giá trực quan độ giống gương mặt.

**Technical Notes:**

- Kiểm soát VRAM ở mức $\le 16\text{GB}$ bằng xformers và gradient checkpointing.

**Dependencies:** Blocks: DA-AI06-24, DA-AI06-25. Blocked by: DA-AI06-01, DA-AI06-20, DA-AI06-21, DA-AI06-22.

---

### DA-AI06-24 — LoRA Artifact Packaging & S3 Versioned Registry

**Assignee:** Tuấn (AI) & Lộc (Sub-lead) | **Priority:** 🟡 High

**Goal:** Đóng gói weights 6 Topic LoRAs và Identity LoRAs sau huấn luyện cùng metadata hoàn chỉnh và bộ từ điển từ khóa tín hiệu, đẩy lên S3 Model Registry theo phân cấp Namespace và chuẩn Semantic Versioning (`v1.0.0`).

**Acceptance Criteria:**

- [ ] Đóng gói artifact hoàn chỉnh bao gồm:
  - File trọng số `{model_id}.safetensors`
  - `metadata.json`: Ghi nhận `model_id`, `type: "topic" | "identity"`, `version`, `base_model`, `trigger_token`, `recommended_weight_scale` ($0.60 - 0.75$), `trained_steps`, `sample_prompts`.
  - `intent_keywords.json` (dành cho Topic LoRAs): Danh mục từ khóa song ngữ (Việt - Anh) phục vụ Intent Routing Engine.
  - `sample_validation_grid.png` (lưới ảnh kiểm chứng chất lượng ở các steps).
- [ ] Đẩy lên S3 theo phân cấp Namespace rõ ràng:
  - Topic LoRAs: `s3://brandhub-models/topics/{topic_id}/{version}/`
  - Identity LoRAs: `s3://brandhub-models/identities/{identity_id}/{version}/`
- [ ] Cơ chế đánh version theo Semantic Versioning (`v1.0.0`, `v1.1.0`).
- [ ] Xây dựng API nội bộ `GET /ai/models/registry` cho phép backend truy vấn danh sách model và tải từ điển intent keywords khi khởi động.

**Technical Notes:**

- Tách biệt hoàn toàn tầng Training MLOps và tầng Inference API; registry là điểm giao tiếp duy nhất giữa 2 tầng.

**Dependencies:** Blocks: DA-AI06-25. Blocked by: DA-AI06-23.

---

### DA-AI06-25 — Multi-Adapter Dynamic LoRA Loader & Model Compatibility Check

**Assignee:** Tuấn (AI) & Lộc (Sub-lead) | **Priority:** 🟡 High

**Goal:** Xây dựng cơ chế tải và nạp sẵn (Warm Pre-load) 6 Topic LoRAs vào VRAM GPU Worker, hỗ trợ chuyển đổi adapter siêu tốc (Hot-swap $< 25\text{ms}$) dựa trên Intent Routing; hỗ trợ nạp động Identity LoRA theo `identity_id` và **bàn giao adapter hoàn chỉnh sang phục vụ EPIC AI-07 (Virtual Brand Ambassador)**.

**Acceptance Criteria:**

- [ ] Xây dựng module `MultiAdapterDynamicLoader`:
  - **Warm Pre-load:** Tự động nạp sẵn cả 6 Topic LoRAs từ SSD local cache vào `StableDiffusionXLPipeline` khi worker khởi động (chỉ chiếm ~500MB VRAM).
  - **Hot-swap siêu tốc:** Khi nhận request có `detected_topic`: Gọi `pipe.set_adapters([topic_id], adapter_weights=[weight])` với độ trễ hoán đổi $< 25\text{ms}$ (zero-disk read).
  - **Chống lem trọng số (State Clean):** Luôn gọi `pipe.disable_lora()` trong khối `finally:` để đưa pipeline về trạng thái Base nguyên bản, triệt tiêu rò rỉ trọng số giữa các request.
- [ ] **Hỗ trợ Dual-Adapter Stacking:** Cho phép nạp đồng thời `Topic LoRA` (tạo bối cảnh ngành) + `Identity LoRA` (tạo khuôn mặt đại sứ ảo) với trọng số độc lập (vd: `topic=0.65`, `identity=0.75`).
- [ ] Kiểm tra tính tương thích: Xác thực metadata trước khi nạp; từ chối nạp nếu LoRA không được train trên nền SDXL.
- [ ] **Bàn giao chính thức sang EPIC AI-07:** Module `MultiAdapterDynamicLoader` được đóng gói hoàn chỉnh thành service dùng chung để các task `DA-AI07-04` và `DA-AI07-05` gọi trực tiếp khi sinh ảnh đại sứ ảo kết hợp ControlNet.

**Technical Notes:**

- Pre-load toàn bộ 6 Topic LoRAs vào GPU Worker loại bỏ 100% hiện tượng VRAM Thrashing và nghẽn mạng S3 khi phục vụ tải thực tế.

**Dependencies:** Blocks: DA-AI07-04, DA-AI07-05. Blocked by: DA-AI06-01, DA-AI06-23, DA-AI06-24.

---

### DA-AI06-26 — Product Studio Canvas Transform & 2D Pose Positioning Engine

**Assignee:** Lộc (Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Xây dựng hệ thống điều khiển tọa độ không gian 2D trên Canvas: cho phép tùy biến linh hoạt tọa độ ngang $X \in [0.0, 1.0]$ (Quy tắc 1/3 bố cục), tọa độ dọc $Y \in [0.0, 1.0]$ (sàn, bục, bay lơ lửng), tỷ lệ thu phóng ($0.20 - 0.90$), xoay góc nghiêng 2D ($-45^\circ \text{ đến } +45^\circ$), lật ảnh đối xứng và lựa chọn bề mặt tiếp xúc (`on_podium`, `on_floor`, `floating`, `on_shelf`, `in_water`).

**Acceptance Criteria:**

- [ ] Cập nhật schema `ProductPlacementTransform` và mở rộng `ProductStudioGenerateRequest` trong `app/schemas/product_studio.py`
- [ ] Nâng cấp hàm `scale_and_position_product` trong `app/services/image/product_matting.py` hỗ trợ xoay `Image.rotate(-rotation, expand=True)`, lật `transpose(FLIP_LEFT_RIGHT)`, tính toán tọa độ neo chính xác theo kích thước sau xoay.
- [ ] Trả về Bounding Box chuẩn xác `(x1, y1, x2, y2)` để `inpainting_mask.py` khoét mặt nạ inpaint và `shadow_injection.py` vẽ bóng tiếp xúc ăn khớp 100%.
- [ ] Bảo đảm backward-compatible: nếu không truyền tham số mới, hệ thống giữ nguyên mặc định căn giữa `pos_x=0.50`, `pos_y=0.82`, `scale=0.50`.
- [ ] 100% unit tests kiểm thử các phép biến đổi hình học đều PASSED.

**Technical Notes:**

- Thực hiện hoàn toàn in-memory qua Pillow/NumPy, thời gian xử lý $< 10\text{ms}$, tiêu tốn 0 MB VRAM GPU.

**Dependencies:** Blocks: DA-AI06-27, DA-AI06-29. Blocked by: DA-AI06-14.

---

### DA-AI06-27 — Visual Optical Harmonizer & Dual-Layer Directional Shadow Engine

**Assignee:** Lộc (Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Khắc phục triệt để hiện tượng "sticker dán đè" bằng bộ hòa trộn quang học CPU (0 VRAM, ~20ms): Reinhard Color Adaptation có bảo toàn Luminance & Logo ($L^*$), Ambient Light Bleeding (Soft-light blend 3-5px mép viền), và Dual-layer Directional Shadow (Contact AO + Penumbra Cast Shadow xiên ngả theo hướng sáng).

**Acceptance Criteria:**

- [ ] Hàm `reinhard_color_transfer_preserve_luminance()` trong `app/services/image/product_compositor.py`:
  - Chuyển đổi sang không gian màu CIELAB.
  - Bảo toàn $\ge 95\%$ kênh $L^*$ và vùng logo, chỉ nhuộm màu trên kênh $a^*, b^*$ với hệ số `harmonization_level` (mặc định $0.35$ / $35\%$).
- [ ] Hàm `apply_ambient_bleed()`: Trích xuất viền trong $3-5\text{px}$ và hòa trộn màu trung bình của hậu cảnh qua chế độ Soft-Light, xóa bỏ viền cắt sắc lẹm.
- [ ] Hàm `generate_directional_shadow()` trong `app/services/image/shadow_injection.py`:
  - Layer 1: Contact Occlusion Shadow ôm sát đáy sản phẩm.
  - Layer 2: Directional Cast Penumbra Shadow sử dụng ma trận Affine Shear ngả theo góc sáng, suy giảm độ đậm và tăng độ nhòe theo khoảng cách.
  - Tự động làm mờ hoặc tắt bóng khi `placement_surface == "floating"`.
- [ ] Đạt chuẩn bảo toàn thương hiệu: chữ in và logo bao bì sắc nét nguyên bản, màu sắc vỏ sản phẩm ngấm tự nhiên ánh sáng studio.

**Technical Notes:**

- Vectorized computation bằng OpenCV/NumPy giúp toàn bộ pipeline hòa trộn chỉ mất ~15-25ms trên CPU.

**Dependencies:** Blocks: DA-AI06-29. Blocked by: DA-AI06-26.

---

### DA-AI06-28 — Fast LLM Commercial Studio Prompt Rewriter & Placement Surface Semantics

**Assignee:** Ân (AI) & Lộc (Sub-lead) | **Priority:** 🟡 High

**Goal:** Xây dựng tầng tự động dịch thuật và nâng cấp mô tả tiếng Việt tự do thành Prompt Studio 5 phân đoạn chuẩn commercial quốc tế qua Groq LLaMA 3.3 70B (~250ms, fallback Gemini 1.5 Flash), tự động tiêm từ khóa bề mặt nâng đỡ (`on_podium`, `floating`...) và Studio Negative Guardrails.

**Acceptance Criteria:**

- [ ] Cập nhật `app/services/image/prompt_synthesizer.py`:
  - Nhận diện tiếng Việt và chuyển mạch sang Fast LLM Rewriter qua Groq API (fallback Gemini khi timeout/429).
  - Chuẩn hóa prompt theo cấu trúc 5 phân đoạn: Subject Placement + Pedestal/Surface + Studio Lighting & Ambience + Technical Camera Specs.
  - Tự động cộng hưởng từ khóa theo `placement_surface` (ví dụ `on_podium` $\to$ `"standing gracefully on a minimalist travertine stone display pedestal"`).
  - Tự động tiêm negative prompt chuyên biệt chặn vẽ thêm sản phẩm thừa, chặn bệt màu.
- [ ] Độ trễ xử lý $\le 300\text{ms}$, tỷ lệ fallback thành công $100\%$.

**Technical Notes:**

- Tận dụng `app/services/llm.py` và Groq client đã có sẵn trong repo để giữ zero new dependencies.

**Dependencies:** Blocks: DA-AI06-29. Blocked by: DA-AI06-07.

---

### DA-AI06-29 — Dual-Mode Interactive Studio Controller (Quick Presets & Fine-Tune Sliders)

**Assignee:** Lộc (Sub-lead) | **Priority:** 🟡 High

**Goal:** Nâng cấp giao diện Web Studio (`app/templates/studio.html`) tích hợp đồng thời cả 2 phương án điều khiển: Bộ nút bấm chọn nhanh 1 chạm (Quick Presets: Trái / Giữa / Phải, Bục đá / Sàn / Bay lửng) VÀ Bộ thanh trượt tinh chỉnh trực quan (Position X/Y, Scale, Rotation, Harmonization Level 0-100%) phục vụ cả người dùng phổ thông lẫn kiểm thử chuyên sâu.

**Acceptance Criteria:**

- [ ] Cập nhật giao diện `studio.html` với khu vực "Studio Stage & Canvas Controls":
  - Nút bấm chọn nhanh: `[⬅️ Trái 1/3]`, `[🎯 Chính giữa]`, `[➡️ Phải 1/3]`.
  - Nút chọn bề mặt: `[🏛️ Bục đá]`, `[🪵 Sàn gỗ]`, `[✨ Bay lơ lửng]`, `[💧 Mặt nước]`.
  - Bảng tinh chỉnh chi tiết (collapsible / direct): Thanh trượt Position X (0-100%), Position Y (0-100%), Scale (20-90%), Rotation (-45° đến +45°), Harmonization Level (0-100%, mặc định 35%).
- [ ] Cập nhật script JavaScript gửi đúng payload mở rộng lên endpoint `POST /api/v1/ai/image/generate/product-studio`.
- [ ] Hiển thị thông số kỹ thuật (Server-Timing, Harmonization Level, Transform applied) trên thanh trạng thái kết quả.

**Technical Notes:**

- Giao diện Dark Theme hiện đại, đồng bộ phong cách phòng thu thương mại cao cấp.

**Dependencies:** Blocked by: DA-AI06-26, DA-AI06-27, DA-AI06-28. Blocks: DA-AI06-32.

---

### DA-AI06-30 — Dual-Image IP-Adapter Integration on SDXL Inference Worker (Colab T4/Kaggle P100)

**Assignee:** Tuấn & Lộc | **Priority:** 🔴 Critical

**Goal:** Xây dựng và tích hợp worker suy luận SDXL hỗ trợ Dual-Image IP-Adapter (`ip-adapter_sdxl_vit-h`) trên hạ tầng GPU điện toán đám mây (Google Colab T4 / Kaggle P100), cho phép truyền đồng thời ảnh người mẫu đại sứ (Ngọc Châu 22) và ảnh sản phẩm thương mại để tổng hợp hình ảnh nhất quán mà không cần huấn luyện lại mô hình, phơi bày API qua FastAPI và Cloudflare Tunnel.

**Acceptance Criteria:**

- [ ] Hoàn thiện script/notebook worker (`BrandHub_SDXL_Inference_Worker_IPAdapter_v1.0.ipynb`) chạy ổn định trên môi trường GPU Google Colab T4 (16GB VRAM) và Kaggle GPU P100 (16GB VRAM).
- [ ] Nạp trọng số Base Model `SG161222/RealVisXL_V4.0` (FP16) kết hợp `ip-adapter_sdxl_vit-h.safetensors` và CLIP Image Encoder (`laion/CLIP-ViT-H-14-laion2B-s32B-b79K`).
- [ ] Hỗ trợ tiếp nhận đồng thời 2 ảnh tham chiếu (`ambassador_image`, `product_image`) với các thang đo trọng số điều khiển độc lập (`ip_adapter_scale_ambassador`, `ip_adapter_scale_product`, dải tối ưu 0.6 - 0.8).
- [ ] Tích hợp máy chủ FastAPI ngầm trên worker, phơi bày endpoint `/generate` và tự động thiết lập Cloudflare Tunnel công khai (`trycloudflare.com`).
- [ ] Tối ưu hóa bộ nhớ: VRAM sử dụng khi inference $\le 12.5\text{GB}$, thời gian sinh ảnh đạt 8s–12s/ảnh (30 steps EulerAncestral).

**Technical Notes:**

- Nạp IP-Adapter trực tiếp vào `StableDiffusionXLPipeline` bằng phương thức `load_ip_adapter`.
- Áp dụng kỹ thuật SDPA (`torch.nn.functional.scaled_dot_product_attention`) để tăng tốc và tiết kiệm bộ nhớ FP16.
- Hỗ trợ cơ chế suy diễn đơn ảnh (chỉ đại sứ hoặc chỉ sản phẩm) để tương thích ngược.

**Dependencies:** Blocks: DA-AI06-32, DA-AI06-33. Blocked by: DA-AI06-01, DA-AI06-16.

---

### DA-AI06-31 — Brand Ambassador Model Sheet Presets (Ngọc Châu 22) & Storage Catalog

**Assignee:** Ân & Lộc | **Priority:** 🟡 High

**Goal:** Xây dựng bộ hồ sơ Model Sheet chuẩn hóa cho Đại sứ thương hiệu độc quyền "Ngọc Châu (22 tuổi - Việt Nam)", quản lý danh mục ảnh tham chiếu đa góc mặt và biểu cảm trên AWS S3 / Local Storage Catalog, đồng thời đóng gói catalog metadata vào backend.

**Acceptance Criteria:**

- [ ] Tuyển chọn và chuẩn hóa bộ Model Sheet tham chiếu cho đại sứ "Ngọc Châu 22" (bao gồm góc chính diện, góc nghiêng 45°, biểu cảm nụ cười thương mại rạng rỡ, đặc điểm nhận dạng nốt ruồi xương hàm phải).
- [ ] Xây dựng catalog quản lý tại `brandhub-ai-service/resources/ambassadors/ngoc_chau_22/` hoặc AWS S3 prefix `models/ambassadors/ngoc_chau_22/`.
- [ ] Tạo file đặc tả metadata `ambassador_catalog.json` chứa: `ambassador_id`, `name`, `age`, `nationality`, `key_features`, `recommended_prompt_triggers`, `default_reference_image_path`.
- [ ] Thiết lập cơ chế cache in-memory CLIP visual embeddings cho ảnh tham chiếu của Ngọc Châu để triệt tiêu thời gian đọc đĩa lặp lại khi có request.

**Technical Notes:**

- Định dạng ảnh chuẩn PNG 1024x1024, lọc mờ Laplacian variance $\ge 120$ và chuẩn hóa ánh sáng studio trung tính.
- Tích hợp helper function `get_ambassador_preset(ambassador_id: str)` trong catalog engine.

**Dependencies:** Blocks: DA-AI06-32, DA-AI06-33. Blocked by: DA-AI06-21.

---

### DA-AI06-32 — Seamless 1-Click Storyboards UI & Zero-Cutout Routing

**Assignee:** Lộc (Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Nâng cấp Web Studio (`/studio`) với giao diện Storyboards 1-Click thông minh: tự động chuyển đổi giữa chế độ Chụp tĩnh 2 Pha (Cụm 8 - Canvas cắt dán & hòa trộn quang học) và chế độ Đại sứ Tự nhiên (Cụm 9 - Zero-Cutout IP-Adapter), tự động ẩn các thanh trượt 2D khi chọn người mẫu để tối giản thao tác người dùng theo triết lý Ponytail.

**Acceptance Criteria:**

- [ ] Nâng cấp giao diện `app/templates/studio.html` tích hợp thanh chọn Storyboard 1-Click (Card selection: Thoa son trước gương, Cầm serum bên cửa sổ, Chụp sản phẩm tĩnh mặt nước...).
- [ ] Logic Zero-Cutout tự động: Khi người dùng chọn "Đại sứ Ngọc Châu", hệ thống tự động ẩn toàn bộ thanh trượt căn chỉnh 2D (Position, Scale, Rotation), chuyển quyền composition hoàn toàn cho IP-Adapter SDXL.
- [ ] Nếu người dùng chọn "Không dùng người mẫu" (Chụp tĩnh), giao diện lập tức kích hoạt lại bộ điều khiển Canvas Transform 2D và Optical Harmonizer của Cụm 8.
- [ ] Nút CTA duy nhất "🚀 SÁNG TẠO CHIẾN DỊCH 1-CLICK" điều hướng thông minh đến endpoint phù hợp dựa trên ngữ cảnh lựa chọn.
- [ ] Hiển thị đầy đủ telemetry trực quan (Latency, IP-Adapter scale, Token count < 40 tokens) trên giao diện kết quả.

**Technical Notes:**

- Triết lý Ponytail: Tận dụng JavaScript thuần trên frontend template, không thêm framework nặng bên ngoài.
- Prompt tiếng Anh tự động sinh ra ngắn gọn dưới 40 tokens, bảo toàn cửa sổ CLIP 77 tokens của SDXL.

**Dependencies:** Blocks: DA-AI06-33. Blocked by: DA-AI06-29, DA-AI06-30, DA-AI06-31.

---

### DA-AI06-33 — E2E Integration Testing & Character Consistency Benchmarks

**Assignee:** Lộc, Tuấn, Ân | **Priority:** 🔴 Critical

**Goal:** Xây dựng bộ kiểm thử tích hợp End-to-End (E2E) và đo kiểm benchmark định lượng độ nhất quán danh tính đại sứ Ngọc Châu (Face Similarity $\ge 0.85$), tương tác ngón tay tự nhiên (không dị tật), tính đồng nhất quang học và đo lường độ trễ toàn trình.

**Acceptance Criteria:**

- [ ] Xây dựng test suite E2E tự động (`tests/test_ip_adapter_storyboard_e2e.py`) kiểm tra luồng từ Frontend Form $\rightarrow$ FastAPI Gateway $\rightarrow$ Colab GPU Worker $\rightarrow$ Rendered Output.
- [ ] Thực thi bộ Benchmark trên 3 kịch bản thương mại chính:
  1. Kịch bản 1: Ngọc Châu thoa son MAC trước gương studio.
  2. Kịch bản 2: Ngọc Châu nâng chai serum bên cửa sổ nắng mai.
  3. Kịch bản 3: Chụp sản phẩm tĩnh mặt nước (kiểm tra tương thích ngược luồng Cụm 8).
  - [ ] Nghiệm thu chất lượng định lượng:
    - Cosine Face Similarity giữa ảnh sinh và Model Sheet gốc đạt $\ge 0.85$ trên $\ge 85\%$ số ảnh sinh.
    - Không phát sinh lỗi viền cắt dán 2D (Zero-Cutout hoàn hảo, ngón tay ôm tự nhiên quanh sản phẩm).
    - Độ trễ toàn trình (E2E Latency) đạt 8s–12s/ảnh trên Colab GPU T4.
- [ ] Biên soạn báo cáo nghiệm thu kỹ thuật và cập nhật vào tài liệu hệ thống.

**Technical Notes:**

- Sử dụng InsightFace buffalo_l để tự động tính toán cosine similarity score giữa khuôn mặt sinh ra và Model Sheet gốc.

**Dependencies:** Blocked by: DA-AI06-30, DA-AI06-31, DA-AI06-32.

---

### DA-AI06-34 — Research FLUX.2 Production Hardware & Runtime Decision

**Jira Key:** [`DA-1250`](https://letritrung2605.atlassian.net/browse/DA-1250) | **Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Nghiên cứu, đánh giá và chốt quyết định kiến trúc mô hình FLUX.2 Klein 4B thay thế SDXL IP-Adapter + 2D sticker compositing; đối soát yêu cầu phần cứng (BF16, peak 11.8GB VRAM) trên RTX 5880 Ada, Kaggle Dual T4 và Cloud GPU.

**Acceptance Criteria:**

- [ ] Hoàn tất tài liệu đặc tả kiến trúc SRS Commercial Studio v2 (`docs/SRS_COMMERCIAL_IMAGE_GENERATION_v2.md`) với luồng Native Multi-Reference (2 ảnh tham chiếu: product index 0, ambassador index 1).
- [ ] Báo cáo đánh giá tương thích phần cứng: khẳng định BF16 native bắt buộc, phân tích hạn chế sm_75/sm_60 (T4/P100), xác lập SLA latency sub-second (< 1.5s trên RTX 5880 Ada).
- [ ] Xác nhận tính khả thi pháp lý thương mại hóa qua giấy phép mở Apache 2.0 của FLUX.2 Klein 4B (loại bỏ Klein 9B và FLUX.2-dev vì non-commercial).

**Technical Notes:**

- FLUX.2 Klein 4B sử dụng kiến trúc DiT (Diffusion Transformer) với text encoder Qwen2.5 7B.
- Yêu cầu GPU hỗ trợ native bfloat16 (tối ưu nhất trên Ada Lovelace / Ampere).

**Dependencies:** Blocks: DA-AI06-35, DA-AI06-36. Blocked by: DA-AI06-05.

---

### DA-AI06-35 — Durable Asynchronous Commercial Generation Orchestration

**Jira Key:** [`DA-1251`](https://letritrung2605.atlassian.net/browse/DA-1251) | **Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Thiết kế và hiện thực hóa cơ chế điều phối sinh ảnh thương mại bất đồng bộ bền vững (Durable Async Orchestration) qua Redis State Machine, hỗ trợ polling tiến độ và giải phóng bộ nhớ process memory.

**Acceptance Criteria:**

- [ ] API endpoint `POST /api/v2/ai/image/commercial/generate` hỗ trợ async submission trả về `generation_id` ngay lập tức hoặc synchronous execution theo flag client.
- [ ] Lưu trữ trạng thái `CommercialGenerationState` (PENDING, PROCESSING, COMPLETED, FAILED) vào Redis với TTL 24h thay cho biến in-memory dictionary.
- [ ] Endpoint `GET /api/v2/ai/image/commercial/generations/{generation_id}` trả về metadata, URL và telemetry ổn định giữa nhiều uvicorn workers.

**Technical Notes:**

- State machine chuyển dịch: `SUBMITTED` → `DISPATCHED` → `RUNNING` → `COMPLETED` / `FAILED`.
- Tự động hủy job và hoàn trả quota nếu timeout vượt quá 120s.

**Dependencies:** Blocks: DA-AI06-37. Blocked by: DA-AI06-34.

---

### DA-AI06-36 — FLUX.2 Private GPU Worker, Idempotency & Failure Recovery

**Jira Key:** [`DA-1252`](https://letritrung2605.atlassian.net/browse/DA-1252) | **Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Hoàn thiện worker GPU chuyên dụng (`flux2_commercial_worker.py`) với cơ chế xác thực Bearer token, thread safety lock, khử non-finite tensor (NaN guard) và tự phục hồi sau lỗi OOM.

**Acceptance Criteria:**

- [ ] Worker khởi chạy trên cổng 8001, tự động nạp `flux.2-klein-4b` và `ae.safetensors` một lần duy nhất vào CUDA BF16.
- [ ] Cơ chế `_require_finite` ngăn ngừa 100% rủi ro sinh ảnh đen hoặc NaN.
- [ ] Bắt lỗi `torch.cuda.OutOfMemoryError` trả HTTP 500 kèm chuỗi chuẩn `CUDA out of memory` để client kích hoạt xử lý khôi phục bộ nhớ.
- [ ] Hỗ trợ đầy đủ các bucket thương mại: 1024x1024, 896x1120, 576x1024 (`MAX_OUTPUT_PIXELS = 1048576`).

**Technical Notes:**

- Tích hợp asyncio semaphore / threading lock bảo đảm worker chỉ xử lý 1 request GPU tại một thời điểm.
- In-memory VRAM garbage collection (`torch.cuda.empty_cache()`) sau mỗi generation.

**Dependencies:** Blocks: DA-AI06-38. Blocked by: DA-AI06-34.

---

### DA-AI06-37 — Commercial Studio Gateway Authentication & Async UI Contract

**Jira Key:** [`DA-1253`](https://letritrung2605.atlassian.net/browse/DA-1253) | **Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Tích hợp xác thực dịch vụ `X-Internal-Key`, chuẩn hóa contract Async UI giữa Web Studio frontend và Gateway API v2, loại bỏ hoàn toàn các trường dữ liệu 2D canvas transform cũ.

**Acceptance Criteria:**

- [ ] Gateway route `/api/v2/ai/image/commercial/generate` chặn 100% request thiếu hoặc sai `X-Internal-Key` (HTTP 401).
- [ ] Prompt safety guardrail chặn từ khóa vi phạm chính sách trả HTTP 400 `policy_violation`.
- [ ] Web Studio (`studio.html`) gọi endpoint v2, hỗ trợ hiển thị trạng thái sinh ảnh, telemetry (latency, VRAM, model preset Ngọc Châu) và hiển thị ảnh trực tiếp.

**Technical Notes:**

- Contract đơn giản hóa: chỉ nhận `prompt`, `aspect_ratio`, `ambassador_id`, `product_image`. Toàn bộ tính toán ánh sáng và vị trí do FLUX.2 tự động xử lý.

**Dependencies:** Blocks: DA-AI06-38. Blocked by: DA-AI06-35, DA-AI06-36.

---

### DA-AI06-38 — FLUX.2 Benchmark, Canary, Cutover & Legacy Retirement

**Jira Key:** [`DA-1254`](https://letritrung2605.atlassian.net/browse/DA-1254) | **Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Thực thi bộ kiểm thử benchmark định lượng 20 kịch bản thương mại (`commercial_20_prompts.json`), triển khai canary testing, cutover chính thức sang FLUX.2 v2 và decommission các pipeline SDXL 2D sticker cũ.

**Acceptance Criteria:**

- [ ] Benchmark 20 prompts đạt 100% success rate, p95 latency < 2.5s, không phát sinh CUDA OOM.
- [ ] Đánh giá chất lượng: triệt tiêu hoàn toàn lỗi z-order ("thỏi son đè đầu người mẫu") và lỗi viền răng cưa 2D sticker.
- [ ] Chuyển 100% traffic Web Studio sang API v2.
- [ ] Dọn dẹp/lưu trữ an toàn các mã nguồn thừa của SDXL 2D compositing.

**Technical Notes:**

- Quy trình Canary: 10% traffic → 50% traffic → 100% cutover sau khi đối soát Face Similarity ≥ 0.85 và CLIP score.

**Dependencies:** Blocks: None. Blocked by: DA-AI06-36, DA-AI06-37.

---

### DA-AI07-01 — Model Weights & Checkpoints Management (SDXL, DWPose ControlNet)

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Xây dựng module tự động tải, kiểm tra tính toàn vẹn (checksum) và nạp offline/online toàn bộ trọng số mô hình cho SDXL base (`RealVisXL_V4.0`), DWPose estimator và SDXL Pose ControlNet; bộ weights InstantID chỉ kích hoạt tải khi chạy bài toán benchmark đối chứng.

**Acceptance Criteria:**

- [ ] Module `ModelWeightsManager` quản lý cache tại `resources/models/`, hỗ trợ biến môi trường `MODELS_CACHE_DIR`
- [ ] Tải và xác thực checkpoint Base Model `SG161222/RealVisXL_V4.0` (FP16 `.safetensors`, ~6.6GB)
- [ ] Tải trọng số DWPose Onnx Models: `yolox_l.onnx` (body/hand detector) và `dw-ll_ucoco_384.onnx` (pose keypoints estimator, ~250MB)
- [ ] Tải SDXL Pose ControlNet: `thibaud/controlnet-openpose-sdxl-1.0` (FP16 `.safetensors`, ~2.5GB)
- [ ] Phân vùng weights InstantID (`InstantX/InstantID/ControlNetModel` và `ip-adapter.bin`) thành module tùy chọn (optional benchmark weights)
- [ ] Cơ chế tự động verify SHA256/kích thước file; nếu lỗi tự động re-download mà không làm gián đoạn service

**Technical Notes:**

- Đảm bảo quyền ghi vào thư mục cache; nạp qua `huggingface_hub.snapshot_download` hoặc `hf_hub_download` với resume capability.

**Dependencies:** Blocks: DA-AI07-02, DA-AI07-04, DA-AI07-16. Blocked by: DA-AI06-01.

---

### DA-AI07-02 — In-Memory Face Preprocessing & 512-dim Embedding Extraction

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Tiền xử lý ảnh người mẫu tham chiếu hoàn toàn trên RAM (zero disk I/O), bóc tách vector đặc trưng 512 chiều chuẩn hóa L2 và sinh landmark canvas 5 điểm mốc cho IdentityNet.

**Acceptance Criteria:**

- [ ] Hàm `preprocess_face(image_bytes: bytes) -> FacePreprocessResult` giải mã ảnh bằng OpenCV (`cv2.imdecode`) từ RAM
- [ ] Sử dụng InsightFace `buffalo_l` trích xuất `normed_embedding` 512 chiều ($\|v\|_2 = 1.0$)
- [ ] Tạo ảnh landmark canvas nền đen vẽ 5 điểm mốc ngũ quan (`kps`: 2 mắt, mũi, 2 khóe miệng) đúng định dạng hình học của InstantID
- [ ] Đạt 100% unit test với ảnh mẫu, đảm bảo vector đầu ra có shape `(512,)` và không chứa phần tử null/zero

**Technical Notes:**

- Không lưu file tạm ra ổ cứng SSD/HDD nhằm giảm latency I/O và triệt tiêu rủi ro lộ dữ liệu người mẫu.
- Khởi tạo singleton `FaceAnalysis(name='buffalo_l', providers=['CUDAExecutionProvider', 'CPUExecutionProvider'])` để tái sử dụng giữa các request.

**Dependencies:** Blocks: DA-AI07-03, DA-AI07-04. Blocked by: DA-AI07-01.

---

### DA-AI07-03 — 4-Edge-Case Visual Input Defense & Fail-Fast Guardrails

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Phát hiện sớm và từ chối các ảnh đầu vào không hợp lệ để bảo vệ GPU VRAM khỏi việc render lãng phí các ảnh lỗi.

**Acceptance Criteria:**

- [ ] **Case 1 (Không có mặt):** Ném `NoFaceDetectedError` (HTTP 422: "Không tìm thấy khuôn mặt trong ảnh tham chiếu")
- [ ] **Case 2 (Nhiều người):** Tự động tính diện tích bounding box $(x_2-x_1) \times (y_2-y_1)$, chọn khuôn mặt lớn nhất và ghi log `WARN`
- [ ] **Case 3 (Mặt quá nghiêng):** Đọc góc quay 3D `face.pose`. Nếu $|\text{yaw}| > 60^\circ$ hoặc $|\text{pitch}| > 45^\circ$, ném `FacePoseExceededError` (HTTP 422: "Khuôn mặt quá nghiêng, yêu cầu góc nhìn bán diện hoặc chính diện")
- [ ] **Case 4 (Mặt quá mờ):** Tính phương sai Laplacian `cv2.Laplacian(face_crop, cv2.CV_64F).var()`. Nếu $< 100.0$, ném `FaceBlurryError` (HTTP 422: "Ảnh khuôn mặt quá mờ, không đủ chi tiết nhận diện")

**Technical Notes:**

- Fail-fast guardrails giúp giảm 90% các request lỗi trước khi chạm vào hàng đợi GPU, bảo vệ VRAM và credit hệ thống.

**Dependencies:** Blocks: DA-AI07-06. Blocked by: DA-AI07-02.

---

### DA-AI07-04 — Ambassador Full-Body Serving Engine (SDXL + Identity LoRA + Pose ControlNet)

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Xây dựng pipeline suy luận chính thức sinh ảnh đại sứ thương hiệu toàn thân (full-body shot) chuẩn xác danh tính bằng cách kết hợp SDXL Base, Identity LoRA và Pose ControlNet (DWPose); InstantID đóng vai trò pipeline đối chứng.

**Acceptance Criteria:**

- [ ] Khởi tạo pipeline kết hợp `StableDiffusionXLPipeline` + ControlNet (`thibaud/controlnet-openpose-sdxl-1.0`)
- [ ] Nhận ảnh control image dạng skeleton trích xuất từ DWPose (chuẩn 133 điểm keypoints)
- [ ] Nạp động Identity LoRA theo `identity_id` của đại sứ được chọn
- [ ] Sinh ảnh full-body 1024x1024 khống chế chuẩn dáng đứng/ngồi/cầm sản phẩm theo ảnh mẫu
- [ ] Thời gian sinh ảnh đạt 10.0 – 14.5 giây trên RTX 4090 (24GB VRAM), mức ngốn VRAM $\le 16.5\text{GB}$
- [ ] Đạt chuẩn kiểm tra: Khuôn mặt rõ nét, da tự nhiên, bàn tay cầm sản phẩm đủ 5 ngón, không dị tật

**Technical Notes:**

- Tuyệt đối không bật CPU offload trên RTX 4090 để đảm bảo SLA < 15s cho 30 diffusion steps.
- Dọn dẹp adapter cũ trước khi nạp adapter mới để tránh rò rỉ trọng số khuôn mặt giữa các request.

**Dependencies:** Blocks: DA-AI07-05, DA-AI07-06. Blocked by: DA-AI07-01, DA-AI06-25, DA-AI07-16.

---

### DA-AI07-05 — Rewriting Ambassador API Route & Control Flow

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Viết lại endpoint `POST /ai/ambassador/generate` theo pipeline mới (SDXL + Identity LoRA + Pose ControlNet); loại bỏ InstantID khỏi luồng xử lý chính, bổ sung cờ `model_type: lora_pose | instantid` phục vụ kiểm thử đối chứng.

**Acceptance Criteria:**

- [ ] Schema request nhận: `identity_id`, `pose_reference_image` (hoặc `pose_preset_id`), `prompt`, `negative_prompt`, `aspect_ratio`, `model_type` (default: `"lora_pose"`, optional: `"instantid"`)
- [ ] Khi `model_type == "lora_pose"`: Điều phối luồng qua pipeline SDXL + LoRA + Pose ControlNet
- [ ] Khi `model_type == "instantid"`: Điều phối qua pipeline đối chứng InstantID phục vụ đo lường
- [ ] Phân bổ thời gian thực thi (DWPose extraction, LoRA load, Diffusion denoising) qua header `Server-Timing`
- [ ] Xử lý ngoại lệ chuẩn HTTP 422 (lỗi pose/mặt) và HTTP 503 (GPU worker bận/OOM)

**Technical Notes:**

- Cho phép backend override linh hoạt dải tham số: `controlnet_conditioning_scale` (mặc định 0.80), `guidance_scale` (CFG 5.0), `num_inference_steps` (30 steps).

**Dependencies:** Blocks: DA-AI07-06, DA-AI07-07. Blocked by: DA-AI07-04.

---

### DA-AI07-06 — Pydantic Schemas & POST /ai/ambassador/generate Route

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Xây dựng API router FastAPI cho chức năng sinh ảnh đại sứ, tiếp nhận multipart upload, validate dữ liệu, điều phối suy luận và trả về kết quả kèm chỉ số đo latency.

**Acceptance Criteria:**

- [ ] Nhận `UploadFile` (ảnh chân dung) + Form data (`prompt`, `style_preset`, `negative_prompt`, `client_id`,...)
- [ ] Định nghĩa Pydantic schema `AmbassadorGenerateResponse` chứa: `imageUrl` (S3 presigned), `s3Key`, `similarityScore`, `seed`, `latencyBreakdown`
- [ ] Tích hợp đo lường thời gian bằng `time.perf_counter()`: `face_detect_ms`, `inference_ms`, `s3_upload_ms`, `total_ms`; trả về trong response header `Server-Timing`
- [ ] Bắt và chuẩn hóa toàn bộ mã lỗi: 400 (Bad request), 422 (Edge cases mặt), 503 (GPU busy/OOM)

**Technical Notes:**

- Triển khai router tại `app/routers/ambassador.py`.
- Tận dụng `BackgroundTasks` hoặc async execution để không block event loop của FastAPI khi xử lý ảnh nặng.

**Dependencies:** Blocks: DA-AI07-07, DA-AI07-08. Blocked by: DA-AI07-03, DA-AI07-04, DA-AI07-05.

---

### DA-AI07-07 — Face Consistency Metric Engine & Cosine Similarity Gating (≥ 0.85)

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Xây dựng engine tự động tính Cosine Similarity giữa ảnh tham chiếu và ảnh vừa sinh ra, phân loại chất lượng 3 cấp độ (PASS, WARNING, FAIL) phục vụ kiểm soát chất lượng tự động.

**Acceptance Criteria:**

- [ ] Hàm tính Cosine Similarity tức thời: $\text{Sim}(v_{\text{ref}}, v_{\text{gen}}) = v_{\text{ref}} \cdot v_{\text{gen}}$ (khi vector đã chuẩn hóa L2)
- [ ] Tái sử dụng model InsightFace singleton từ Task 02 để trích xuất mặt trên ảnh kết quả (thời gian đo < 50ms)
- [ ] Cài đặt Gating 3 mức:
  - **`PASS` ($\ge 0.85$):** Đạt chuẩn danh tính thương hiệu, lưu S3 và gắn nhãn hợp lệ
  - **`WARNING` ($0.75 \le \text{Score} < 0.85$):** Ghi log `WARN`, gắn badge cảnh báo độ nét cho user
  - **`FAIL` ($< 0.75$ hoặc không thấy mặt):** Gắn cờ vi phạm nhận diện, thông báo lỗi hoặc kích hoạt retry

**Technical Notes:**

- Lưu điểm `similarity_score` vào metadata của S3 object để phục vụ audit và analytics sau này.

**Dependencies:** Blocks: DA-AI07-13. Blocked by: DA-AI07-06.

---

### DA-AI07-08 — Ambassador S3 Gallery Management (CRUD, Presigned URLs 1h)

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Cung cấp hệ thống API cho doanh nghiệp lưu trữ, truy xuất và xóa thư viện ảnh đại sứ theo phân vùng clientId trên AWS S3.

**Acceptance Criteria:**

- [ ] Phân vùng S3 multi-tenant:
  - Ảnh tham chiếu gốc: `clients/{clientId}/ambassadors/references/{uuid}.png`
  - Ảnh đã sinh: `clients/{clientId}/ambassadors/generated/{uuid}.png`
- [ ] `POST /ai/ambassador/references`: Upload và lưu ảnh gốc, cache vector embedding vào metadata hoặc Redis
- [ ] `GET /ai/ambassador/gallery?clientId={id}`: Liệt kê danh sách ảnh kèm Presigned GET URL có thời hạn 1 giờ (`expires_in=3600`)
- [ ] `DELETE /ai/ambassador/references/{key}`: Xóa an toàn object trên S3, kiểm tra bảo mật đúng tiền tố `clientId`

**Technical Notes:**

- Kế thừa module S3 helper tại `app/utils/s3.py`.
- Áp dụng pagination cho gallery endpoint (mặc định 20 items/page).

**Dependencies:** Blocks: None. Blocked by: DA-AI07-06.

---

### DA-AI07-09 — Ambassador Singleton Background Removal via rembg (U2Net)

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Xây dựng service tách nền người mẫu đại sứ thành layer trong suốt RGBA để chuẩn bị cho công đoạn ghép vào bối cảnh sản phẩm thương mại.

**Acceptance Criteria:**

- [ ] Khởi tạo duy nhất 1 session `rembg.new_session("u2net")` dạng Singleton trong RAM (tránh load lại model gây nghẽn)
- [ ] Hàm `remove_background(image_bytes: bytes) -> bytes` trả về ảnh PNG có kênh alpha trong suốt
- [ ] Xử lý viền tóc người mẫu bằng thuật toán alpha matting mềm để hạn chế hiện tượng răng cưa / lem viền
- [ ] Đạt thời gian bóc nền < 1.5 giây / ảnh 1024x1024

**Technical Notes:**

- Session `rembg` tiêu tốn ~200MB VRAM/RAM; cần warm-up trước một dummy run lúc khởi động app.

**Dependencies:** Blocks: DA-AI07-10. Blocked by: DA-AI07-06.

---

### DA-AI07-10 — Ambassador Background Placement POST /ai/ambassador/apply & Natural Relighting

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Ghép người mẫu đại sứ đã bóc nền lên ảnh nền sản phẩm; tự động đồng bộ ánh sáng và tạo bóng đổ nhân tạo để tạo ấn phẩm quảng cáo hoàn chỉnh.

**Acceptance Criteria:**

- [ ] `POST /ai/ambassador/apply` nhận `{ambassadorKey, backgroundKey, clientId, position_preset, scale}`
- [ ] Tái sử dụng `CompositionService` (kế thừa từ EPIC AI-08), phối màu tự nhiên: Phủ ambient color tint (5-8% opacity) theo tông màu chủ đạo của Background lên người mẫu
- [ ] Tạo bóng đổ giả lập (Artificial Drop Shadow): Nghiêng bóng xuống mặt sàn và làm mờ viền bằng `ImageFilter.GaussianBlur(radius=15)`
- [ ] Upload ảnh hoàn thiện lên `clients/{clientId}/ambassadors/composited/{uuid}.png` và trả về Presigned URL

**Technical Notes:**

- Sử dụng Pillow composite in-memory; kiểm tra kích thước bounding box giữa background và ambassador để tự động tính tỉ lệ scale phù hợp (default 0.85).

**Dependencies:** Blocks: None. Blocked by: DA-AI07-08, DA-AI07-09, DA-AI08-03.

---

### DA-AI07-11 — 5 Commercial Ambassador Style & Wardrobe Presets

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Thiết kế 5 bộ master prompt presets tương ứng với 5 ngành hàng lớn, định hình chuẩn trang phục, ánh sáng và bối cảnh cho đại sứ thương hiệu.

**Acceptance Criteria:**

- [ ] **Preset 1 (Fashion):** Haute couture tailored suit, ánh sáng studio tối giản, phong cách tạp chí Vogue
- [ ] **Preset 2 (Business):** Áo vest navy hiện đại, bối cảnh văn phòng kính ngập tràn ánh sáng ban ngày tự nhiên, đáng tin cậy
- [ ] **Preset 3 (Casual):** Đồ linen thoải mái tại quán cafe ngoài trời, ánh sáng hoàng hôn golden hour, gần gũi
- [ ] **Preset 4 (Sportswear):** Đồ tập techwear năng động tại phòng gym hiện đại, ánh sáng rim light kịch tính
- [ ] **Preset 5 (Luxury):** Đầm dạ hội lụa / tuxedo sang trọng, bối cảnh tiệc champagne, ánh sáng điện ảnh chiaroscuro
- [ ] Đóng gói thành file cấu hình `resources/ambassador_presets.json` có thể mở rộng mà không cần sửa code

**Technical Notes:**

- Mỗi preset bao gồm: `positive_modifier`, `recommended_aspect_ratio`, `lighting_profile`, `color_palette`.

**Dependencies:** Blocks: DA-AI07-06, DA-AI07-13. Blocked by: None.

---

### DA-AI07-12 — Multi-tier Model Guardrails & Anti-Plastic Negative Prompts

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Xây dựng bộ negative prompts chuyên sâu triệt tiêu các lỗi kinh điển của mô hình sinh người mẫu: da nhựa tượng sáp, mắt lé, và dị tật ngón tay.

**Acceptance Criteria:**

- [ ] **Guardrails giải phẫu tay:** Chặn bàn tay biến dạng, thừa/thiếu ngón (`deformed hands, extra fingers, fused fingers, mutated limbs`)
- [ ] **Guardrails mắt & ngũ quan:** Chặn mắt lé, con ngươi lệch, mặt chảy sáp (`strabismus, cross-eyed, mismatched pupils, melting face`)
- [ ] **Guardrails chất liệu da (Anti-plastic):** Chặn da tượng sáp, da búp bê nhựa (`plastic skin, wax figure, mannequin, overly smoothed, doll-like`)
- [ ] **Positive Reinforcement:** Tự động tiêm các token tăng độ nét da thật: `photorealistic skin texture, visible natural skin pores, subsurface scattering`
- [ ] Tích hợp bộ lọc Content Safety (chặn ảnh nhạy cảm, bạo lực, xúc phạm)

**Technical Notes:**

- Tiêm chuỗi negative guardrails vào đầu `negative_prompt` trước khi gửi vào pipeline InstantID.

**Dependencies:** Blocks: DA-AI07-06, DA-AI07-13. Blocked by: None.

---

### DA-AI07-13 — Multi-Angle Face Consistency Benchmark (15 Images, ≥ 86% Pass ≥ 0.85)

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Thực nghiệm kiểm chứng tiêu chuẩn chất lượng: Sinh 15 ảnh liên tiếp từ 1 ảnh gốc với ma trận đa dạng góc máy và trang phục; đo đạc chỉ số Cosine Similarity thực tế.

**Acceptance Criteria:**

- [ ] Ma trận kiểm thử: 5 góc chụp (Chính diện 0°, nghiêng 30°, nghiêng 45°, nghiêng hẳn 90°, góc từ trên xuống) $\times$ 3 trang phục (Vest, Casual, Thể thao) = 15 ảnh
- [ ] Tự động chạy đo Cosine Similarity qua script `tests/benchmark_ambassador_consistency.py`
- [ ] **Tiêu chuẩn nghiệm thu:** Tối thiểu 13 / 15 ảnh ($\ge 86.7\%$) đạt điểm Cosine Similarity $\ge 0.85$
- [ ] Xuất báo cáo bảng ma trận thống kê: Prompt, Latency, Similarity score, trạng thái Pass/Fail (Mean, Min, Max score)

**Technical Notes:**

- Đảm bảo giữ nguyên seed và các hyperparameter đã hiệu chuẩn từ DA-AI07-05 trong suốt quá trình benchmark để đảm bảo tính khách quan.

**Dependencies:** Blocks: DA-AI07-14. Blocked by: DA-AI07-05, DA-AI07-07, DA-AI07-11, DA-AI07-12.

---

### DA-AI07-14 — Comprehensive Ambassador Benchmark: LoRA+Pose vs InstantID Baseline

**Assignee:** Tuấn (AI) & Ân (AI) | **Priority:** 🟡 High

**Goal:** Thực hiện bộ benchmark khoa học đối đầu trực tiếp giữa pipeline mới (SDXL + Identity LoRA + Pose ControlNet) và baseline cũ (InstantID) trên tập 20 ảnh thử nghiệm full-body và chân dung; xuất báo cáo định lượng bảo vệ đồ án.

**Acceptance Criteria:**

- [ ] Chuẩn bị tập 20 ảnh mẫu (10 nam, 10 nữ, đa sắc tộc, đa lứa tuổi 20-50)
- [ ] Đo đạc và đối sánh 4 chỉ số khoa học:
  1. *Identity Retention Rate*: Cosine Similarity của ArcFace vector trích xuất từ ảnh khuôn mặt được crop tự động (ngưỡng pass $\ge 0.85$)
  2. *Pose Accuracy / Keypoint Distance*: Khoảng cách sai lệch Euclidean giữa keypoints bộ xương gốc và keypoints bộ xương trên ảnh sinh ra
  3. *Peak VRAM*: Đo lường mức chiếm dụng VRAM tối đa trong quá trình suy luận
  4. *Full-Body Stability*: Đánh giá tỉ lệ lỗi bàn tay (hand deformities) và hiện tượng da nhựa sáp trên ảnh toàn thân
- [ ] Xuất báo cáo Markdown chi tiết kèm biểu đồ so sánh trực quan, tích hợp vào tài liệu `DA-AI11-01`

**Technical Notes:**

- Tạo script chạy song song 2 pipelines `tests/benchmark_lorapose_vs_instantid.py`, lưu kết quả JSON và render biểu đồ đối đầu.

**Dependencies:** Blocks: DA-AI07-15, DA-AI11-01. Blocked by: DA-AI07-04, DA-AI07-05.

---

### DA-AI07-15 — 5 Master Commercial Ambassador Templates & Operational Guide

**Assignee:** Ân (AI) | **Priority:** 🟢 Low

**Goal:** Đóng gói Top 5 Template thương phẩm sẵn sàng đưa lên giao diện người dùng và tài liệu hóa cẩm nang kỹ thuật chuyển giao.

**Acceptance Criteria:**

- [ ] Tạo file JSON `resources/ambassador_starter_templates.json` gồm 5 mẫu cấu hình chuẩn (Hero Banner 16:9, Beauty Portrait 1:1, Social Post 4:5, Story 9:16, Product Co-star)
- [ ] Hoàn thành tài liệu Markdown `docs/ai_models/DA-AI07_Virtual_Ambassador_Guide.md`:
  - Hướng dẫn cài đặt CUDA 12.x, PyTorch và nạp model weights
  - Bộ tham số vàng và các tips viết prompt đạt độ tương đồng cao
  - Cẩm nang xử lý sự cố (Troubleshooting: lỗi OOM, lỗi NoFace, lỗi mặt bị trôi)

**Technical Notes:**

- Phối hợp với Tuấn để hoàn thiện phần thông số GPU và CUDA trong tài liệu.

**Dependencies:** Blocks: None. Blocked by: DA-AI07-14.

---

### DA-AI07-16 — DWPose Keypoints Extraction & Control Image Normalization

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Xây dựng module trích xuất bộ xương tư thế DWPose chuẩn xác từ ảnh tham chiếu người mẫu và chuẩn hóa định dạng ảnh điều khiển (Control Image) cho SDXL Pose ControlNet.

**Acceptance Criteria:**

- [ ] Tích hợp mô hình DWPose Onnx (`yolox_l` + `dw-ll_ucoco_384`):
  - Trích xuất 18 điểm khung xương thân người chính
  - Trích xuất 42 điểm khớp bàn tay (21 điểm mỗi bàn tay)
  - Trích xuất 68 điểm khung viền mặt
- [ ] Thuật toán vẽ Skeleton Canvas: Tô màu các đoạn xương theo đúng quy chuẩn màu sắc của OpenPose/DWPose trên nền đen RGB `(0, 0, 0)`
- [ ] Chuẩn hóa kích thước & Padding: Tự động điều chỉnh tỉ lệ khung xương theo đúng độ phân giải đích ($1024 \times 1024$, $896 \times 1152$, v.v.), căn giữa và bù trừ padding đối xứng
- [ ] Tốc độ trích xuất keypoints đạt $< 350\text{ms}$ trên GPU / $< 1.2\text{s}$ trên CPU

**Technical Notes:**

- DWPose giải quyết triệt để vấn đề mất ngón hoặc bàn tay bị biến dạng khi người mẫu cầm sản phẩm.

**Dependencies:** Blocked by: DA-AI07-01. Blocks: DA-AI07-04.

---

### DA-AI08-01 — Implement background removal for product images (rembg + U2Net, output transparent PNG)

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Automatically remove product image backgrounds to produce clean transparent PNGs ready for composition onto marketing backgrounds.

**Acceptance Criteria:**

- [ ] `services/composition/bg_removal.py` function `remove_background(image_bytes: bytes) -> bytes` returns transparent PNG bytes
- [ ] Uses `rembg` with the U2Net model; model downloads on first use and is cached at `~/.u2net/`
- [ ] Unit test: input a product photo on white background → output PNG has transparent pixels where background was
- [ ] Processing time logged at INFO level; alert at WARN if >15 seconds (indicates model cache miss or CPU-only inference)

**Technical Notes:**

- Known failure cases to handle gracefully (return result with a warning header rather than error): transparent packaging, reflective surfaces, fine hair
- `rembg.remove(image_bytes)` is the simplest call; for batch processing use `rembg.remove(image_bytes, session=new_session('u2net'))` with a shared session to avoid reloading weights per call

**Dependencies:** Blocks: DA-AI08-03. Blocked by: DA-AI01-05, DA-AI01-06.

---

### DA-AI08-02 — Implement background removal for model/ambassador images

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Apply background removal to human model and ambassador images, which present harder edge cases (hair, skin tones) than product images.

**Acceptance Criteria:**

- [ ] Same `remove_background()` function from DA-AI08-01 is reused; this task validates it works acceptably for human subjects
- [ ] 10 model/ambassador test images processed; hair edge quality evaluated and documented
- [ ] If U2Net quality is insufficient for hair, evaluate `rembg` with `isnet-general-use` model as an alternative and document comparison

**Technical Notes:**

- Human subject removal is rembg's primary design target; quality should be better than product images with complex backgrounds
- Fine hair strands will always show some fringing — document the acceptable quality threshold so QA knows what to pass

**Dependencies:** Blocks: DA-AI08-03. Blocked by: DA-AI08-01.

---

### DA-AI08-03 — Build layer compositing service (product layer + model layer + background layer → Pillow composite)

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Combine the three image layers (product cutout, model cutout, background) into a single cohesive marketing image using Pillow.

**Acceptance Criteria:**

- [ ] `services/composition/compositor.py` function `composite_layers(product_png: bytes, model_png: bytes, background_jpg: bytes, layout: dict) -> bytes` returns a composed JPEG
- [ ] `layout` dict specifies: product position (x, y, scale), model position (x, y, scale), layer order (product in front of / behind model)
- [ ] Output image is 1080×1080 by default (Instagram square); output size is configurable via `layout.outputSize`
- [ ] If any layer is `None`, it is skipped gracefully (supports product-only or model-only compositions)

**Technical Notes:**

- Use `Image.paste(layer, position, mask=layer)` with the alpha channel as mask for transparent PNG layers
- Resize layers to fit within their bounding box defined in `layout` before pasting; maintain aspect ratio with `Image.LANCZOS` resampling

**Dependencies:** Blocks: DA-AI08-04, DA-AI08-05. Blocked by: DA-AI08-01, DA-AI08-02.

---

### DA-AI08-04 — Implement shadow + lighting adjustment for natural-looking merges

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Reduce the "cutout" appearance of composited elements by adding subtle shadow and brightness matching so subjects look photographically integrated.

**Acceptance Criteria:**

- [ ] `services/composition/effects.py` implements `add_drop_shadow(layer_png: bytes, opacity: int, blur_radius: int) -> bytes`
- [ ] `adjust_brightness_to_background(layer_png: bytes, background_jpg: bytes) -> bytes` shifts layer brightness to match background luminance
- [ ] Both effects are optional and activated by fields in the `layout` dict passed to DA-AI08-03 compositor
- [ ] Visual test: composited image with effects applied is rated more realistic than without by at least 3 of 5 reviewers

**Technical Notes:**

- Drop shadow: create a copy of the layer alpha mask, apply Gaussian blur (`ImageFilter.GaussianBlur(blur_radius)`), colorize black, paste behind layer at `opacity`
- Brightness matching: compute mean luminance of the background region behind the layer bounding box; adjust layer using `ImageEnhance.Brightness`

**Dependencies:** Blocks: DA-AI08-05. Blocked by: DA-AI08-03.

---

### DA-AI08-05 — Build POST /ai/compose endpoint

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Expose the full composition pipeline as a single API endpoint that accepts S3 keys and returns the composed image URL.

**Acceptance Criteria:**

- [ ] `POST /ai/compose` accepts `{productKey: str, modelKey: Optional[str], backgroundKey: str, clientId: str, layout: Optional[dict]}`
- [ ] Downloads all provided S3 keys, runs background removal on product and model layers, composites via DA-AI08-03, uploads result to S3
- [ ] Returns `{composedImageUrl: str, s3Key: str, processingTimeMs: int}`
- [ ] If an S3 key does not exist, returns `404` identifying the missing key

**Technical Notes:**

- Download all S3 assets concurrently using `asyncio.gather` to minimize latency before the CPU-bound composition step
- Composed image S3 key: `composed/{clientId}/{uuid}.jpg`

**Dependencies:** Blocks: DA-AI08-06. Blocked by: DA-AI08-03, DA-AI08-04, DA-AI02-03, DA-AI02-04.

---

### DA-AI08-06 — Test 20 product + model pairs, evaluate realism, document failure cases

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Validate composition quality across the range of product categories and model types that BrandHub clients will submit.

**Acceptance Criteria:**

- [ ] 20 pairs tested: at minimum 5 fashion, 5 beauty/cosmetics, 5 food/beverage, 5 lifestyle/accessory
- [ ] Each output rated: edge blending (1-5), shadow realism (1-5), lighting consistency (1-5), overall realism (1-5)
- [ ] Failure cases documented with root cause: transparent packaging, hair edges, reflective surfaces, extreme lighting mismatch
- [ ] Average realism score ≥ 3.5 across all 20 pairs; cases below 3 are logged as known limitations

**Dependencies:** Blocks: DA-AI11-03. Blocked by: DA-AI08-05.

---

### DA-AI08-07 — Write composition parameter guide (optimal image sizes, best practices per product category)

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Low

**Goal:** Give BrandHub clients clear guidance on how to prepare input images to get the best possible composition results.

**Acceptance Criteria:**

- [ ] Guide documents recommended input image specs: minimum resolution, preferred background (plain vs complex), lighting direction
- [ ] Per-category best practices: fashion (full-body vs half-body), beauty (macro product shots), food (top-down vs 45°), accessories
- [ ] Known failure cases listed with workarounds (e.g., "for glass bottles, manually remove background in Photoshop before uploading")

**Dependencies:** Blocks: None. Blocked by: DA-AI08-06.

---

### DA-AI08-08 — Virtual Try-On (VTON) Model Benchmark: IDM-VTON vs CatVTON & SKU Fidelity

**Assignee:** Tuấn (AI) & Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Triển khai thử nghiệm đối đầu định lượng giữa hai mô hình thử đồ ảo tiên tiến (IDM-VTON và CatVTON) trên tập sản phẩm thời trang mẫu; đánh giá độ trung thực của trang phục (SKU fidelity), nếp nhăn, logo thương hiệu và mức ngốn VRAM để chốt giải pháp production.

**Acceptance Criteria:**

- [ ] Triển khai cả hai mô hình trên môi trường GPU testbed:
  - IDM-VTON (Diffusion-based Virtual Try-on)
  - CatVTON (Lightweight Concatenation-based Try-on)
- [ ] Tập dữ liệu benchmark: 15 cặp sản phẩm thực tế (áo thun in họa tiết, áo sơ mi kẻ sọc, váy đầm dạ hội, áo khoác dày có khóa kéo)
- [ ] Đánh giá định lượng trên 4 tiêu chí khắt khe:
  1. *SKU Texture & Pattern Preservation*: Độ biến dạng của họa tiết kẻ sọc/hoa văn trên áo (đo SSIM và LPIPS)
  2. *Logo & Typography Fidelity*: Kiểm tra logo ngực áo có bị nhòe chữ hoặc méo mó không
  3. *Physical Creases & Draping*: Đánh giá mức độ tự nhiên của nếp gấp vải theo tư thế cử động của người mẫu
  4. *VRAM & Inference Latency*: So sánh thời gian chạy và mức đỉnh VRAM tiêu thụ
- [ ] Xuất báo cáo kỹ thuật chọn giải pháp chính thức cho BrandHub kèm phương án fallback

**Technical Notes:**

- CatVTON có ưu thế chạy nhanh và nhẹ VRAM (< 8GB); IDM-VTON có độ chi tiết nếp gấp cao hơn nhưng tốn VRAM hơn (~14GB).

**Dependencies:** Blocked by: GPU Environment Setup. Blocks: DA-AI08-10.

---

### DA-AI08-09 — Local Refinement & Face/Hand Detailer with Retry Limiter & Pre/Post QA

**Assignee:** Tuấn (AI) & Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Xây dựng module Inpainting/Refinement cục bộ chuyên sâu cho vùng khuôn mặt và bàn tay sau khi sinh ảnh tổng thể hoặc sau bước mặc đồ ảo (VTON); cài đặt giới hạn số lần retry tối đa 2 lần và kiểm định chất lượng QA trước và sau khi upscale.

**Acceptance Criteria:**

- [ ] Tự động phát hiện và crop bounding box vùng khuôn mặt (YOLO Face) và bàn tay (MediaPipe / DWPose)
- [ ] Thực hiện Local Inpainting với mức denoising nhẹ ($0.25 - 0.35$) để phục hồi chi tiết mắt, đồng tử, lỗ chân lông và móng tay mà không làm thay đổi đặc trưng danh tính
- [ ] Cài đặt **Retry Limiter (Tối đa 2 lần)**: Nếu điểm Cosine Similarity của khuôn mặt sau refine vẫn $< 0.85$ hoặc phát hiện bàn tay bị dị tật ngón, tự động re-sample seed mới (tối đa 2 lần) để tránh loop vô tận và bảo vệ SLA timeout
- [ ] Chốt chặn **QA Gate Pre/Post Upscale**:
  - *Pre-Upscale QA*: Kiểm tra độ nét và không có artifact cháy sáng trên ảnh gốc $1024 \times 1024$
  - *Post-Upscale QA (2K/4K qua Real-ESRGAN)*: Kiểm tra không bị hiện tượng gai nhọn hoặc răng cưa viền logo sản phẩm

**Technical Notes:**

- Tránh lãng phí tài nguyên GPU bằng cách fail-fast nếu sau 2 lần retry vẫn không đạt điểm QA.

**Dependencies:** Blocked by: DA-AI08-08, DA-AI07-04. Blocks: DA-AI08-10.

---

### DA-AI08-10 — Sequential Stage Runner, VRAM Lifecycle & Crash Recovery

**Assignee:** Lộc (AI Sub-lead) & Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Thiết kế tiến trình điều phối tuần tự (Stage Runner) kiểm soát bộ nhớ VRAM chặt chẽ qua từng chặng (Base SDXL -> Pose ControlNet -> VTON -> Detailer -> Upscaler), dọn sạch cache GPU giữa các stage, lưu trữ trạng thái trung gian (intermediate outputs) để debug và resume khi lỗi.

**Acceptance Criteria:**

- [ ] Thiết kế `PipelineStageRunner` thực thi tuần tự theo đồ thị:
  `Stage 1: SDXL + LoRA + Pose` ➔ `Stage 2: VTON` ➔ `Stage 3: Detailer` ➔ `Stage 4: Upscaler`
- [ ] Quản lý vòng đời VRAM: Sau mỗi stage, tự động gọi `torch.cuda.empty_cache()` và `gc.collect()`; nạp và giải phóng model xen kẽ, đảm bảo đỉnh VRAM cả quá trình không vượt quá **20GB** trên GPU RTX 4090 24GB
- [ ] Lưu trữ Intermediate Outputs: Lưu snapshot kết quả ảnh PNG của từng stage vào thư mục tạm/S3 kèm `job_id` và `stage_name`
- [ ] Cơ chế **Resume on Failure**: Nếu Stage 3 bị lỗi (do OOM hoặc timeout), hệ thống có khả năng retry trực tiếp từ kết quả của Stage 2 mà không phải render lại từ đầu Stage 1

**Technical Notes:**

- Áp dụng Stage Runner pattern tương tự như `trend_pipeline` đã triển khai thành công trong `brandhub-ai-service`.

**Dependencies:** Blocked by: DA-AI07-04, DA-AI08-08, DA-AI08-09. Blocks: DA-AI08-11.

---

### DA-AI08-11 — End-to-End Cloud Ambassador Pipeline & AI Service Contract Handoff

**Assignee:** Lộc (AI Sub-lead), Tuấn (AI) & Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Kết nối toàn bộ luồng xử lý từ tạo danh tính, huấn luyện LoRA, triển khai inference worker, sinh ảnh đại sứ kèm pose và sản phẩm; nghiệm thu end-to-end cloud pipeline và bàn giao API contract hoàn chỉnh cho `brandhub-ai-service`.

**Acceptance Criteria:**

- [ ] Kết nối thông suốt luồng E2E trên Cloud/Kaggle:
  `Client gửi Request` ➔ `Chọn Identity & Pose` ➔ `Nạp LoRA & DWPose` ➔ `Mặc đồ VTON` ➔ `Local Detailer` ➔ `QA Gate` ➔ `Upload S3`
- [ ] Đạt các chỉ số SLA kỹ thuật:
  - Tổng thời gian hoàn tất chuỗi (E2E Latency): $\le 30\text{ giây / ảnh thương phẩm hoàn thiện}$
  - Tỉ lệ thành công liên tục (Success Rate) $\ge 95\%$ trên 20 test runs liên tiếp
- [ ] Bàn giao API Contract hoàn chỉnh (Pydantic Schemas, OpenAPI docs, mã lỗi chuẩn hóa HTTP 422/503)
- [ ] Viết tài liệu hướng dẫn vận hành và kịch bản demo trực tiếp phục vụ buổi bảo vệ trước Mentor/Hội đồng

**Dependencies:** Blocked by: DA-AI08-10, DA-AI06-24. Blocks: DA-AI10-01.

---

### DA-AI09-01 — Pydantic Schemas & Async Video Job State Management in Redis

**Assignee:** Lộc (Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Định nghĩa toàn bộ Pydantic schemas (Request/Response) cho pipeline video bất đồng bộ và kiến trúc State Machine trong Redis để theo dõi trạng thái job (TTL 24h), loại bỏ hoàn toàn trường thumbnail bắt buộc.

**Acceptance Criteria:**

- [ ] Pydantic Schemas (`schemas/video.py`): `VideoGenerationRequest` (`prompt`, `movement_type`, `duration_seconds`, `aspect_ratio`, `fps`, `client_id`, `template_id`), `VideoJobResponse` (`job_id`, `status: PENDING`), `VideoJobStatusResponse` (`job_id`, `status: PENDING|PROCESSING|COMPLETED|FAILED`, `progress_percent`, `video_url`, `duration_seconds`, `error_message`, `created_at`, `updated_at`)
- [ ] Spec Zero Thumbnail: Tuyệt đối không chứa trường thumbnail bắt buộc trong Request/Response schema (tránh overhead sinh ảnh thumbnail)
- [ ] Redis State Manager (`services/video/state_manager.py`): Quản lý vòng đời job qua key `video:job:{job_id}` với TTL 24 giờ (86400s), tự động dọn dẹp bộ nhớ
- [ ] State transitions chuẩn: `PENDING` → `PROCESSING` → `COMPLETED` (hoặc `FAILED`)
- [ ] Helper methods atomic: `init_job(job_id, payload)`, `update_job_status(job_id, status, **kwargs)`, `get_job_status(job_id)` đảm bảo thread-safe và non-blocking
- [ ] Unit tests cho validation schema và serialization/deserialization trạng thái job trong Redis

**Technical Notes:**

- Tái sử dụng Singleton Redis client có sẵn từ `core/redis.py`; lưu payload dưới dạng JSON string để tối ưu hiệu năng đọc ghi
- Triết lý *ponytail*: Quản lý state thuần trên Redis O(1), không cần setup worker message broker phức tạp

**Dependencies:** Blocks: DA-AI09-04, DA-AI09-05, DA-AI09-10. Blocked by: DA-AI01-03.

---

### DA-AI09-02 — Google Veo API Client & Async Generation Engine

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Xây dựng module tích hợp Google Veo API trên Vertex AI, xử lý xác thực Google Cloud Service Account, dispatch job sinh video và vòng lặp async polling theo dõi tiến trình sinh video từ Google Cloud.

**Acceptance Criteria:**

- [ ] `services/video/veo_client.py` tích hợp Google GenAI SDK / Vertex AI API, xác thực qua Google Cloud Service Account credentials (`GOOGLE_APPLICATION_CREDENTIALS`)
- [ ] `dispatch_video_generation(prompt: str, parameters: dict) -> str`: gửi yêu cầu sinh video lên Veo API và nhận về `veo_operation_id`
- [ ] Vòng lặp Async Polling: `poll_operation_status(operation_id: str, timeout_seconds: int = 600) -> dict`: kiểm tra tiến độ mỗi 10 giây với cơ chế jitter & exponential backoff
- [ ] Cơ chế Timeout & Fallback: Giới hạn thời gian sinh tối đa 10 phút; nếu quá hạn tự động ngắt và ném `VideoGenerationTimeoutError`
- [ ] Error Handling chuyên sâu: Bắt và xử lý chuẩn các lỗi Google Cloud: 429 Quota Exceeded, 400 Safety Policy Violation, 503 Service Unavailable

**Technical Notes:**

- Sử dụng `httpx.AsyncClient` hoặc async SDK call để không block FastAPI event loop trong suốt quá trình polling
- Tự động refresh OAuth2 access token đảm bảo quá trình polling dài không bị gián đoạn do token expiration

**Dependencies:** Blocks: DA-AI09-04, DA-AI09-05. Blocked by: DA-AI01-03, DA-AI09-03.

---

### DA-AI09-03 — Movement Parameter Mapping & Camera Motion Translation Engine

**Assignee:** Tuấn (AI) | **Priority:** 🟡 High

**Goal:** Chuẩn hóa và ánh xạ các tùy chọn chuyển động camera thương mại (Pan, Tilt, Zoom, Dolly, Static) cùng các thông số kỹ thuật video sang payload tương thích với Google Veo API.

**Acceptance Criteria:**

- [ ] `utils/video_params.py` định nghĩa `CameraMotionType` enum: `STATIC`, `PAN_LEFT`, `PAN_RIGHT`, `TILT_UP`, `TILT_DOWN`, `ZOOM_IN`, `ZOOM_OUT`, `DOLLY`, `TRACKING_SHOT`
- [ ] `map_movement_to_veo_params(motion_type: str, motion_strength: float = 1.0) -> dict`: ánh xạ chính xác sang parameter schema của Google Veo
- [ ] Hỗ trợ đầy đủ các Aspect Ratios tiêu chuẩn: `16:9` (Landscape TV/Web), `9:16` (Portrait TikTok/Reels/Shorts), `1:1` (Square Instagram/Facebook)
- [ ] Cấu hình FPS (24fps cinematic, 30fps commercial standard) và thời lượng video (5s - 10s) theo hạn ngạch Google Veo
- [ ] Unit tests kiểm tra 100% các giá trị enum ánh xạ đúng, không trả về giá trị `None` hoặc tham số không hợp lệ

**Technical Notes:**

- Thiết kế dạng declarative config table (`dict`), cho phép dễ dàng cập nhật khi Google nâng cấp phiên bản Veo API mà không phải sửa logic xử lý

**Dependencies:** Blocks: DA-AI09-02, DA-AI09-06. Blocked by: DA-AI01-04.

---

### DA-AI09-04 — Direct S3 Video Streamer, FFprobe Duration Extractor & Presigned URL 7 Days (Zero Thumbnail)

**Assignee:** Lộc (Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Tải video trực tiếp từ Google Veo và stream thẳng lên AWS S3 không qua đĩa tạm, trích xuất thời lượng chính xác qua ffprobe, tạo presigned URL 7 ngày; triệt để loại bỏ trích xuất thumbnail ffmpeg nhằm tối đa tốc độ xử lý.

**Acceptance Criteria:**

- [ ] **Quy tắc Zero Thumbnail (*ponytail*):** Tuyệt đối KHÔNG trích xuất thumbnail bằng ffmpeg; loại bỏ toàn bộ overhead decode frame và render ảnh tĩnh, giảm ít nhất 3–5 giây độ trễ pipeline
- [ ] Direct Stream S3 Upload (`services/video/s3_streamer.py`): Đọc video stream từ Veo URL qua `httpx.stream()` và pipe trực tiếp vào S3 Multipart Upload / Streaming Body mà không ghi file tạm xuống ổ cứng local của container
- [ ] Trích xuất thời lượng bằng `ffprobe`: Sử dụng `ffprobe` đọc header video từ stream buffer để lấy chính xác `duration_seconds` (float) và metadata độ phân giải trong < 200ms
- [ ] S3 Key Naming Convention: `videos/{client_id}/{uuid}.mp4`, Content-Type: `video/mp4`
- [ ] S3 Presigned URL 7 ngày: Tạo URL xem video với thời hạn 7 ngày (`ExpiresIn=604800` giây), đảm bảo client phát video ổn định mà không cần refresh URL thường xuyên
- [ ] Cập nhật kết quả hoàn tất vào Redis: `{status: "COMPLETED", video_url: presigned_url, duration_seconds: duration, error_message: null}`

**Technical Notes:**

- Chỉ đóng gói binary `ffprobe` gọn nhẹ trong Docker container; không cài đặt các thư viện transcode ffmpeg cồng kềnh
- Presigned URL 7 ngày là mức tối đa của AWS Signature Version 4 với IAM User credentials

**Dependencies:** Blocks: DA-AI09-05, DA-AI09-10. Blocked by: DA-AI09-01, DA-AI09-02.

---

### DA-AI09-05 — FastAPI Video Endpoints (POST /ai/video/generate & GET /ai/video/{jobId}/status) & Async Polling

**Assignee:** Lộc (Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Xây dựng cặp REST API endpoints trong FastAPI phục vụ sinh video bất đồng bộ non-blocking, hỗ trợ polling trạng thái qua Redis, validate dữ liệu đầu vào và trả về Server-Timing / Request-ID.

**Acceptance Criteria:**

- [ ] `POST /ai/video/generate`: Nhận `VideoGenerationRequest`, validate dữ liệu đầu vào, sinh UUID `job_id`, khởi tạo state `PENDING` trong Redis, kích hoạt background pipeline và trả về ngay HTTP 202 Accepted `{job_id: str, status: "PENDING"}` (< 50ms)
- [ ] `GET /ai/video/{jobId}/status`: Tra cứu trực tiếp từ Redis O(1), trả về `VideoJobStatusResponse` gồm: `job_id`, `status`, `progress_percent`, `video_url`, `duration_seconds`, `error_message`. Hoàn toàn không có trường thumbnail bắt buộc
- [ ] Xử lý Job Not Found: Trả về HTTP 404 Not Found theo chuẩn RFC 7807 problem details nếu `job_id` không tồn tại hoặc đã hết hạn TTL
- [ ] Response Headers: Tự động đính kèm `X-Request-ID` và `Server-Timing` đo đạc thời gian tra cứu Redis
- [ ] Background Task Dispatcher: Điều phối luồng async tuần tự: prompt compilation → Veo dispatch → async polling → S3 streaming upload → Redis completion update
- [ ] Rate Limiting: Giới hạn tần suất gọi endpoint (10 requests/phút/client) phòng chống spam request sinh video tốn kém

**Technical Notes:**

- Polling endpoint chỉ đọc dữ liệu từ Redis cache, tuyệt đối không gọi trực tiếp sang Google Veo API để tiết kiệm chi phí và tránh cạn kiệt rate limit quota

**Dependencies:** Blocks: DA-AI09-10. Blocked by: DA-AI09-01, DA-AI09-02, DA-AI09-04, DA-AI09-06.

---

### DA-AI09-06 — Video Prompt Engineering Engine & Form-to-Prompt Converter

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Xây dựng engine tự động chuyển đổi thông tin form đầu vào đơn giản của người dùng (chủ đề, phong cách, camera motion, thời lượng, bối cảnh thương hiệu) thành prompt điện ảnh chất lượng cao tối ưu riêng cho Google Veo.

**Acceptance Criteria:**

- [ ] Module `services/video/prompt_builder.py`: hàm `build_veo_prompt(topic, tone, movement_type, duration_seconds, brand_context) -> str`
- [ ] Tích hợp bộ Cinematographic Modifiers: ánh sáng điện ảnh (volumetric lighting, cinematic lighting), độ sắc nét cao (4k photorealistic, pristine quality), chuyển động mượt mà (smooth motion, 35mm lens, commercial grade)
- [ ] Ghép nối chính xác các mô tả chuyển động camera tương ứng từ DA-AI09-03 vào prompt để Veo hiểu đúng ý đồ chuyển động
- [ ] Tích hợp ngữ cảnh thương hiệu (brand tone, brand guidelines) vào prompt nhằm đảm bảo video thể hiện đúng cá tính thương hiệu
- [ ] Unit tests với 10 trường hợp phong cách đa dạng đảm bảo cấu trúc prompt mạch lạc, không trùng lặp từ khóa, không vượt quá giới hạn token của Veo

**Technical Notes:**

- Áp dụng cấu trúc prompt phân đoạn: `[Subject & Action] + [Environment & Setting] + [Camera Motion] + [Cinematography & Lighting] + [Commercial Style]`

**Dependencies:** Blocks: DA-AI09-07, DA-AI09-05. Blocked by: DA-AI09-03.

---

### DA-AI09-07 — Master Marketing Video Prompt Library (10 Archetypes × 3 Motion Styles = 30 Templates)

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Xây dựng và kiểm định thư viện 30 prompt templates chuyên biệt cho video marketing thương mại (10 định dạng nội dung × 3 phong cách chuyển động), cho phép người dùng kích hoạt tạo video nhanh chóng với 1 cú click.

**Acceptance Criteria:**

- [ ] 10 dạng video marketing thương mại:
  1. Product Showcase (Giới thiệu chi tiết sản phẩm cao cấp)
  2. Brand Launching (Video công bố ra mắt thương hiệu mới)
  3. Seasonal Promo & Flash Sale (Khuyến mãi mùa vụ, Black Friday, Tết)
  4. Lifestyle & Outdoor (Sản phẩm trong đời sống thường nhật)
  5. How-To & Quick Tutorial (Hướng dẫn sử dụng sản phẩm nhanh)
  6. Customer Testimonial & Story (Câu chuyện khách hàng truyền cảm hứng)
  7. Luxury Unboxing (Trải nghiệm mở hộp sản phẩm tinh tế)
  8. Behind-The-Scenes (Hậu trường chế tác sản phẩm)
  9. Event & Teaser (Kích thích tò mò về sự kiện sắp diễn ra)
  10. Viral Social Trend (Video bắt trend dạng ngắn TikTok/Shorts)
- [ ] 3 phong cách chuyển động máy quay cho mỗi dạng: (A) Dynamic Tracking/Orbit, (B) Smooth Cinematic Pan/Zoom, (C) Fast-paced Commercial Dolly
- [ ] Đóng gói 30 templates trong `resources/video_templates.json` kèm các placeholders chuẩn hóa: `{product_name}`, `{brand_name}`, `{key_benefit}`, `{mood}`
- [ ] Thực nghiệm kiểm thử toàn bộ 30 templates trên Veo API, đạt tỷ lệ ít nhất 26/30 templates cho ra video đạt chuẩn thương mại
- [ ] Cung cấp hàm helper `get_video_template(template_id: str, context: dict) -> str`

**Technical Notes:**

- Định dạng file cấu hình JSON có trường metadata `version: "1.0.0"`, cho phép thêm bớt template mà không cần restart server

**Dependencies:** Blocks: DA-AI09-09, DA-AI09-10. Blocked by: DA-AI09-06.

---

### DA-AI09-08 — Content Safety Guardrails & Negative Motion Constraints for Video

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Xây dựng lớp bảo vệ đa tầng chống rủi ro nội dung độc hại (Brand Safety) và ngăn ngừa các lỗi chuyển động vật lý dị thường trong video do AI sinh ra (méo mó khung hình, giật lag hình ảnh, artifacts).

**Acceptance Criteria:**

- [ ] Module `services/video/guardrails.py` triển khai class `VideoSafetyGuard`
- [ ] Blacklist Keyword Filter: Quét và chặn ngay lập tức (Fail-fast HTTP 400/422) các prompt chứa từ khóa độc hại, bạo lực, nhạy cảm, vi phạm bản quyền hoặc vi phạm chính sách Google Cloud
- [ ] Negative Motion Constraints: Tự động tiêm các ràng buộc negative đặc thù cho video: `shaky camera, jitter, flickering, frame distortion, morphing objects, unnatural motion, blurry, low resolution, watermark, text artifacts`
- [ ] Motion Hallucination Defense: Phát hiện và cảnh báo các yêu cầu chuyển động trái quy luật vật lý gây lỗi biến dạng khung hình
- [ ] Bộ unit test kiểm thử 20 prompt nguy cơ cao đảm bảo hệ thống chặn thành công 100% các vi phạm

**Technical Notes:**

- Tối ưu hiệu năng theo triết lý *ponytail*: sử dụng regex compiled & in-memory hash set để kiểm tra từ khóa với độ trễ < 1ms

**Dependencies:** Blocks: DA-AI09-05, DA-AI09-10. Blocked by: DA-AI09-06.

---

### DA-AI09-09 — Empirical Quality & Cost Benchmark across 30 Video Templates

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Thực hiện benchmark thực nghiệm toàn diện trên 30 video templates để đo đạc thời gian sinh video, độ ổn định chuyển động, chất lượng hình ảnh và chi phí API thực tế của Google Veo.

**Acceptance Criteria:**

- [ ] Sinh 30 video mẫu thực tế tương ứng với 30 templates trong thư viện DA-AI09-07
- [ ] Đo lường ma trận 4 tiêu chí cho từng video: (1) Generation Time (giây), (2) Motion Stability Score (1-5 điểm), (3) Prompt Fidelity Score (1-5 điểm), (4) Chi phí API Google Cloud ($/video)
- [ ] Tổng hợp thống kê định lượng: Thời gian sinh trung bình, chi phí trung bình trên mỗi video, tỷ lệ thành công (%)
- [ ] Phân tích Top 5 Templates đạt chất lượng cao nhất và Top 3 Edge Cases bị lỗi chuyển động kèm giải pháp tinh chỉnh prompt
- [ ] Biên soạn báo cáo thực nghiệm chi tiết `docs/benchmarks/veo_30_templates_benchmark.md` đính kèm dữ liệu đo đạc

**Technical Notes:**

- Dữ liệu chi phí và latency thu được từ benchmark này sẽ là đầu vào trực tiếp cho báo cáo phân tích chi phí tổng thể DA-AI11-04

**Dependencies:** Blocks: DA-AI09-10, DA-AI11-02, DA-AI11-04. Blocked by: DA-AI09-04, DA-AI09-07.

---

### DA-AI09-10 — Video Generation Pipeline Integration, End-to-End Testing & Technical Report

**Assignee:** Lộc (Lead) & Tuấn, Ân | **Priority:** 🔴 Critical

**Goal:** Tích hợp hoàn chỉnh toàn bộ pipeline sinh video từ API gateway đến Google Veo, S3 presigned URL 7 ngày, thực hiện kiểm thử E2E, hoàn thiện Postman/Swagger và biên soạn Báo cáo Kỹ thuật Video Generation hoàn chỉnh.

**Acceptance Criteria:**

- [ ] E2E Testing Suite (`tests/test_video_e2e.py`): Kiểm thử tự động chu trình hoàn chỉnh: `POST /ai/video/generate` → nhận `job_id` → polling `GET /status` qua Redis → nhận `COMPLETED` với video URL S3 phát được trực tiếp trên trình duyệt HTML5
- [ ] Xác minh triệt để Zero Thumbnail: Kiểm tra response không chứa thumbnail key hoặc trả về `null`/omitted, đảm bảo không có ffmpeg thumbnail nào được sinh ra
- [ ] Bộ Postman Collection: Đóng gói request mẫu cho cả 2 endpoints (`/generate`, `/{jobId}/status`) kèm môi trường test và assert script tự động
- [ ] Swagger/OpenAPI Documentation: Cập nhật đầy đủ mô tả schema, mã lỗi 400, 404, 422, 500 tại `/docs`
- [ ] Báo cáo Kỹ thuật Hoàn chỉnh (`docs/research/Veo_Video_Generation_Technical_Report.md`): Tổng kết kiến trúc pipeline, bảng golden parameters, bảng phân tích chi phí thực tế và hướng dẫn viết prompt video
- [ ] Nghiệm thu chéo 3 bên: Lộc nghiệm thu Router & S3 streaming, Tuấn nghiệm thu Veo client & latency, Ân nghiệm thu Prompt library & tài liệu

**Technical Notes:**

- Tích hợp test suite vào pipeline CI/CD kiểm thử tự động trước khi merge code vào nhánh chính

**Dependencies:** Blocks: DA-AI10-01, DA-AI11-02. Blocked by: DA-AI09-04, DA-AI09-05, DA-AI09-07, DA-AI09-08, DA-AI09-09.

---

### DA-AI10-01 — Finalize all FastAPI endpoints

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Ensure every AI endpoint is production-ready with consistent request validation, error handling, and response shapes before integration testing.

**Acceptance Criteria:**

- [ ] All 7 endpoint groups are implemented and reachable: `/ai/content`, `/ai/image`, `/ai/video`, `/ai/ambassador`, `/ai/compose`, `/ai/rag/*`, `/ai/trends`
- [ ] Every endpoint returns consistent error shape: `{error: str, detail: Optional[str], requestId: str}`
- [ ] Pydantic validation errors return `422` with field-level error detail; unhandled exceptions return `500` (never expose stack traces to clients)
- [ ] `GET /health` and `GET /docs` (Swagger) are accessible without authentication

**Technical Notes:**

- Use FastAPI `exception_handler` decorators for `ValidationError`, `LLMUnavailableError`, `ImageGenerationError`, `VideoGenerationTimeoutError`, `NoFaceDetectedError`
- Add `requestId` (UUID) to every response via middleware so distributed traces can be correlated across services

**Dependencies:** Blocks: DA-AI10-03. Blocked by: DA-AI04-07, DA-AI06-07, DA-AI07-06, DA-AI08-05, DA-AI09-06, DA-AI05-16.

---

### DA-AI10-02 — Error handling & retry for external AI API calls (exponential backoff, fallback provider on rate limit)

**Assignee:** All (Team) | **Priority:** 🟡 High

**Goal:** Make ai-service resilient to transient failures from third-party APIs (Groq, Stability AI, Veo, Replicate) without requiring manual intervention.

**Acceptance Criteria:**

- [ ] `utils/retry.py` implements `retry_with_backoff(fn, max_attempts=3, base_delay=1.0, max_delay=30.0)` using exponential backoff with jitter
- [ ] All external API calls (Groq, Anthropic, Stability AI, Veo, Replicate) are wrapped with `retry_with_backoff`
- [ ] Rate limit errors (`429`) trigger immediate fallback-provider switch (Groq → Claude) without waiting for retry backoff
- [ ] Retry attempts are logged at DEBUG level with: attempt number, delay, exception type

**Technical Notes:**

- Use `tenacity` library rather than hand-rolling retry logic; `@retry(wait=wait_exponential(min=1, max=30), stop=stop_after_attempt(3), reraise=True)` covers most cases
- Distinguish `429 RateLimitError` (switch provider) from `500 ServerError` (retry same provider) in the exception handling logic

**Dependencies:** Blocks: DA-AI10-03. Blocked by: DA-AI04-03.

---

### DA-AI10-03 — Integration test with business-service (verify all AI calls from business-service reach ai-service correctly)

**Assignee:** All (Team) | **Priority:** 🔴 Critical

**Goal:** Validate the end-to-end integration between business-service and ai-service in the shared Docker environment before final demo.

**Acceptance Criteria:**

- [ ] All AI feature calls originating from business-service (caption generation, image generation, video trigger, composition) successfully reach ai-service endpoints
- [ ] `X-Internal-Key` header is correctly sent from business-service and validated by ai-service middleware
- [ ] At least one full user flow tested end-to-end: upload brand doc → generate caption using RAG → generate image → compose product + model
- [ ] All integration tests pass in `docker-compose` environment without requiring local Python or AI SDK installation

**Technical Notes:**

- Use `pytest` with `httpx.AsyncClient` pointed at `http://localhost:8082` for integration tests
- Test with a real (non-mocked) ChromaDB and Redis container to catch connection issues that unit tests miss

**Dependencies:** Blocks: DA-AI11-05. Blocked by: DA-AI02-05, DA-AI02-06, DA-AI10-01, DA-AI10-02.

---

### DA-AI10-04 — Write Postman collection for all AI endpoints with example requests and responses

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Give business-service developers and the mentor a ready-to-run set of API examples that work against the local Docker environment.

**Acceptance Criteria:**

- [ ] Postman collection covers all 7 endpoint groups with at least one example request per endpoint
- [ ] Collection uses environment variables for `BASE_URL`, `INTERNAL_API_KEY`, `CLIENT_ID` so it works in both local and staging environments
- [ ] Example responses match actual service responses (not fabricated); collection is exported as `ai_service.postman_collection.json` and committed to repo

**Dependencies:** Blocks: None. Blocked by: DA-AI10-01.

---

### DA-AI10-05 — Write Swagger/OpenAPI documentation for ai-service (auto-generated via FastAPI /docs)

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Ensure every endpoint has complete, accurate Swagger documentation that a developer can use without reading source code.

**Acceptance Criteria:**

- [ ] Every endpoint has: summary, description, request body schema with field descriptions, response schema with field descriptions, example values
- [ ] Error responses (400, 401, 404, 422, 500, 503) are documented on every endpoint using FastAPI `responses=` parameter
- [ ] `GET /docs` renders correctly in browser against the local Docker service

**Technical Notes:**

- Add `openapi_extra={"x-internal-only": True}` tag to all `/internal/*` endpoints to visually distinguish them from public endpoints in the Swagger UI

**Dependencies:** Blocks: None. Blocked by: DA-AI10-01.

---

### DA-AI11-01 — Write Virtual Ambassador Technical Report

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Produce a comprehensive technical record of the virtual ambassador feature development that satisfies mentor evaluation requirements.

**Acceptance Criteria:**

- [ ] Report covers: model comparison (InstantID vs IP-Adapter from DA-AI07-07), implementation architecture, face consistency test results (DA-AI07-04), sample gallery (≥10 before/after image pairs)
- [ ] Quantitative results included: face similarity score distribution, generation time statistics, cost per image
- [ ] Implementation decisions justified with reference to empirical test results, not opinions
- [ ] Report is ≥ 2000 words and includes all figures/tables from DA-AI07-04 and DA-AI07-07

**Dependencies:** Blocks: DA-AI11-05. Blocked by: DA-AI07-07, DA-AI07-04.

---

### DA-AI11-02 — Write Video Generation Research Report (full prompt library, movement guide, cost analysis)

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Document the complete video generation research and implementation in a format suitable for mentor review and team knowledge transfer.

**Acceptance Criteria:**

- [ ] Report includes: Veo API capability summary, full 30-template prompt library with quality ratings, movement parameter cheat sheet, benchmark results table
- [ ] Cost analysis section: cost per video × estimated monthly usage volume
- [ ] Report cross-references DA-AI09-08 research report; does not duplicate content but synthesizes decisions made

**Dependencies:** Blocks: DA-AI11-05. Blocked by: DA-AI09-07, DA-AI09-08.

---

### DA-AI11-03 — Write Image Composition Research Report

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Document the composition technique evaluation and implementation decisions for mentor review and future reference.

**Acceptance Criteria:**

- [ ] Report covers: technique comparison (DA-AI01-05/06 research), rembg + Pillow implementation rationale, quality test results (DA-AI08-06)
- [ ] Failure case gallery: ≥5 documented cases with root cause analysis and workaround recommendations
- [ ] Composition quality metrics summarized: average realism scores per product category

**Dependencies:** Blocks: DA-AI11-05. Blocked by: DA-AI08-06, DA-AI06-08, DA-AI06-16.

---

### DA-AI11-04 — Compile AI Cost Analysis (estimated cost per feature × average usage × 1000 users/month)

**Assignee:** All (Team) | **Priority:** 🟡 High

**Goal:** Provide the business-side cost model for the AI features so stakeholders can evaluate commercial viability before launch.

**Acceptance Criteria:**

- [ ] Cost table covers all 5 AI features: caption generation (Groq + Claude fallback), image generation (SDXL), video generation (Veo), ambassador generation (Replicate/InstantID), background removal (CPU cost)
- [ ] Assumptions documented: average uses per user per month per feature, data based on benchmark results from DA-AI06-05, DA-AI09-07, DA-AI07-04
- [ ] Total estimated AI infrastructure cost per 1000 monthly active users calculated and highlighted
- [ ] Sensitivity analysis: cost at 500, 1000, 5000 users to show scaling behavior

**Dependencies:** Blocks: DA-AI11-05. Blocked by: DA-AI09-07, DA-AI07-04, DA-AI06-05.

---

### DA-AI11-05 — Record AI feature demo video (showcase all 7 AI features working end-to-end)

**Assignee:** All (Team) | **Priority:** 🔴 Critical

**Goal:** Produce a polished demo video that demonstrates all AI capabilities working in the integrated BrandHub product for the mentor presentation.

**Acceptance Criteria:**

- [ ] Video demonstrates all 7 features in sequence: RAG document upload, caption generation, hashtag generation, image generation, virtual ambassador, image composition, video generation
- [ ] Each feature demo includes: user action → loading state → final result clearly visible on screen
- [ ] Video is ≤ 10 minutes total; each feature segment is labeled with a title card
- [ ] Demo uses real brand data (not lorem ipsum) to show production-realistic output quality

**Dependencies:** Blocks: DA-AI11-06. Blocked by: DA-AI10-03, DA-AI11-01, DA-AI11-02, DA-AI11-03, DA-AI11-04.

---

### DA-AI11-06 — Present AI results to mentor (live demo + Q&A, collect feedback for final report)

**Assignee:** All (Team) | **Priority:** 🔴 Critical

**Goal:** Deliver the AI track milestone presentation and capture mentor feedback to incorporate into the final project report.

**Acceptance Criteria:**

- [ ] All 7 AI features demonstrated live (not just via recorded video) against the running Docker environment
- [ ] Each team member presents the features they implemented; mentor can ask implementation questions to any member
- [ ] All mentor feedback is written down during the session and assigned as follow-up items within 24 hours
- [ ] Presentation deck includes: architecture diagram, benchmark results summary, cost analysis table, sample outputs gallery

**Dependencies:** Blocks: None. Blocked by: DA-AI11-05.

---

### DA-E21-01 — Initialize brandhub-publisher-service project (Spring Boot 3, RabbitMQ consumer bean setup)

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Create the canonical publisher-service project structure with RabbitMQ consumer infrastructure ready for adapter implementation.

**Acceptance Criteria:**

- [ ] Spring Boot 3 project created with dependencies: `spring-boot-starter-amqp`, `spring-boot-starter-data-redis`, `spring-boot-starter-web`, `spring-boot-starter-actuator`
- [ ] `RabbitMQ` consumer bean configured and connected to the `publish.jobs` queue (queue name from application properties, not hardcoded)
- [ ] `GET /actuator/health` returns `{"status": "UP"}` including RabbitMQ connectivity check
- [ ] Service starts cleanly on port 8083 via `docker-compose up publisher-service`

**Technical Notes:**

- Use `@RabbitListener(queues = "${rabbitmq.queue.publish-jobs}")` pattern for queue name externalization
- Configure `MessageConverter` bean with `Jackson2JsonMessageConverter` so `PublishJobMessage` is deserialized automatically

**Dependencies:** Blocks: DA-E21-02. Blocked by: None.

---

### DA-E21-02 — Implement RabbitMQ consumer: receive PublishJobMessage and route to correct platform adapter

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Build the message intake layer that deserializes incoming publish jobs and dispatches them to the correct social platform adapter.

**Acceptance Criteria:**

- [ ] `PublishJobMessage` POJO defined: `{postId, platform, content, mediaUrls: List<String>, scheduledAt, encryptedToken}`
- [ ] Consumer method deserializes message and routes to the correct adapter based on `platform` enum value: FACEBOOK, INSTAGRAM, TIKTOK, THREADS, ZALO
- [ ] Unknown platform values are caught and logged as errors; message is sent to Dead Letter Queue rather than crashing the consumer
- [ ] Exactly-once guard: check Redis `processingPostIds` set before processing; add `postId` at start, remove at end (or on DLQ)

**Technical Notes:**

- Use `SETNX` (via `RedisTemplate.opsForSet().add()`) to add postId to `processingPostIds` before processing; if SETNX returns 0, the message is already being processed — discard it
- Set a TTL on the Redis key (`processingPostIds:{postId}`, TTL 30 minutes) to auto-release stuck locks

**Dependencies:** Blocks: DA-E21-03, DA-E21-04, DA-E21-05, DA-E21-06, DA-E21-07. Blocked by: DA-E21-01.

---

### DA-E21-03 — Implement Facebook publish adapter (Graph API v19: /me/feed for text, /me/photos for image)

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Enable publishing text and image posts to Facebook Pages via the Graph API.

**Acceptance Criteria:**

- [ ] `FacebookAdapter.publish(PublishJobMessage)` posts to `POST /v19.0/me/feed` for text-only content
- [ ] For posts with `mediaUrls`, uploads image via `POST /v19.0/me/photos` with `published=true`
- [ ] Adapter decrypts `encryptedToken` using the shared decryption key (from env var) before use in API calls
- [ ] On success, returns `{platform: FACEBOOK, platformPostId: str, status: SUCCESS}`; on API error returns `{status: FAILED, errorCode, errorMessage}`

**Technical Notes:**

- Graph API v19 access token must be a Page Access Token (not User token) for `me/feed` posts; validate this during adapter testing
- `encryptedToken` decryption must use the same algorithm as business-service encryption; confirm with Trung (Leader) before implementing

**Dependencies:** Blocks: DA-E22-01. Blocked by: DA-E21-02.

---

### DA-E21-04 — Implement Instagram publish adapter (2-step: create container → publish)

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Enable image and carousel publishing to Instagram Business accounts via the Content Publishing API.

**Acceptance Criteria:**

- [ ] Step 1: `POST /{ig-user-id}/media` with `image_url` and `caption` to create a media container; receive `container_id`
- [ ] Step 2: `POST /{ig-user-id}/media_publish` with `creation_id={container_id}` to publish
- [ ] Adapter polls container status between steps; if container status is not `FINISHED` within 30 seconds, returns `FAILED`
- [ ] Caption is automatically truncated to 2200 characters if it exceeds the limit before submission

**Technical Notes:**

- Instagram Content Publishing API requires the image to be publicly accessible via URL; `mediaUrls` must be presigned S3 URLs with sufficient expiry (at least 1 hour from publish time)
- Reels publishing uses a different endpoint (`/reels` instead of `/media`); out of scope for this task — document explicitly

**Dependencies:** Blocks: DA-E22-01. Blocked by: DA-E21-02.

---

### DA-E21-05 — Implement TikTok publish adapter (Direct Post ≤60s, Creator Upload >60s)

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Enable video publishing to TikTok using the correct API path based on video duration.

**Acceptance Criteria:**

- [ ] Adapter checks video duration from `mediaUrls` metadata or content field; routes to Direct Post API for ≤60s, Creator Upload API for >60s
- [ ] Direct Post: `POST /v2/post/publish/video/init/` with video URL; receive `publish_id`; poll until `status.publish_type` is COMPLETE
- [ ] Creator Upload: initiates chunk upload flow, uploads video bytes, then triggers publish
- [ ] Caption truncated to 4000 characters before submission; returns `{status: SUCCESS, platformPostId}` on completion

**Technical Notes:**

- TikTok Content Posting API v2 requires `Content-Type: application/json; charset=UTF-8` and OAuth 2.0 access token (not API key)
- Creator Upload API for long videos involves multi-part chunk upload; implement as a separate `TikTokCreatorUploadService` to keep adapter clean

**Dependencies:** Blocks: DA-E22-01. Blocked by: DA-E21-02.

---

### DA-E21-06 — Implement Threads publish adapter (2-step: create container → publish, enforce max 500 chars)

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Enable publishing to Threads using Meta's 2-step container creation flow with enforced 500-character caption limit.

**Acceptance Criteria:**

- [ ] Step 1: `POST /{threads-user-id}/threads` with `media_type`, `text`, `image_url` (if applicable) to create container
- [ ] Step 2: `POST /{threads-user-id}/threads_publish` with `creation_id` to publish
- [ ] Caption is hard-truncated to 500 characters BEFORE submission; truncation at last complete word with `"..."` appended
- [ ] If caption exceeds 500 chars and truncation would leave fewer than 100 chars of content, returns `FAILED` with `{"error": "caption_too_short_after_truncation"}` rather than posting unintelligible content

**Technical Notes:**

- Threads API uses the same access token type as Instagram (Meta Graph API); token decryption logic is shared with the Facebook adapter
- Threads is text-first; image support is single-image only (no carousels); validate `mediaUrls.size() <= 1` and return `400` if violated

**Dependencies:** Blocks: DA-E22-01. Blocked by: DA-E21-02.

---

### ~~DA-E21-07 — Implement Zalo OA publish adapter~~

> **Loại khỏi scope** (2026-09-03) — không tích hợp Zalo. Task chưa từng tạo trên Jira.

---

### DA-E22-01 — Implement HTTP callback POST /internal/posts/{id}/publish-result to business-service

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Notify business-service of every publish attempt outcome so it can update post status and trigger user notifications.

**Acceptance Criteria:**

- [ ] After every publish attempt (success or failure), publisher-service calls `POST http://business-service/internal/posts/{postId}/publish-result`
- [ ] Request body: `{postId, platform, status: PUBLISHED|FAILED, platformPostId?, errorCode?, errorMessage?, publishedAt?}`
- [ ] `X-Internal-Key` header included on all callback requests
- [ ] Callback is retried up to 3 times with 2-second delay if business-service returns non-2xx; failures are logged but do not affect the publish retry logic

**Technical Notes:**

- Use `RestTemplate` or `WebClient` (prefer `WebClient` for non-blocking); configure a dedicated `HttpClient` bean with 10-second connection/read timeout
- Callback URL base is read from env var `BUSINESS_SERVICE_URL`; never hardcode `localhost`

**Dependencies:** Blocks: DA-E22-03. Blocked by: DA-E21-03, DA-E21-04, DA-E21-05, DA-E21-06, DA-E21-07.

---

### DA-E22-02 — Implement retry logic: immediate → +1min → +5min → +15min → Dead Letter Queue

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Ensure transient platform API failures (network blips, rate limits, temporary outages) are retried automatically without data loss.

**Acceptance Criteria:**

- [ ] On publish failure, message is re-queued with delay: attempt 1 = immediate, attempt 2 = 1 minute, attempt 3 = 5 minutes, attempt 4 = 15 minutes
- [ ] After 4 failed attempts, message is routed to Dead Letter Queue (`publish.jobs.dlq`); an alert is logged at ERROR level with full context
- [ ] Attempt count is tracked in message headers (`x-retry-count`); incremented on each re-queue
- [ ] Redis `processingPostIds` lock is released before re-queuing so the retried message is not blocked by the exactly-once guard

**Technical Notes:**

- Implement delayed retry using RabbitMQ `x-message-ttl` on a per-delay dead letter exchange chain (one exchange per delay level), or use RabbitMQ Delayed Message Plugin if available
- Do NOT use `Thread.sleep()` for delays in the consumer thread; this blocks the consumer and prevents other messages from being processed
- Non-retryable errors (e.g., invalid token, account suspended — HTTP 4xx from platform that is not 429) must go directly to DLQ without retry; maintain a list of non-retryable HTTP status codes per platform

**Dependencies:** Blocks: DA-E22-03. Blocked by: DA-E21-02, DA-E22-01.

---

### DA-E22-03 — Implement business-service handler for publish callback (update post status PUBLISHED/FAILED, create notification)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Complete the publish feedback loop by processing the callback from publisher-service and updating the post record and user notification state in business-service.

**Acceptance Criteria:**

- [ ] `POST /internal/posts/{id}/publish-result` endpoint in business-service is authenticated via `X-Internal-Key`
- [ ] On `status: PUBLISHED`: post record updated to `status=PUBLISHED`, `platformPostId` and `publishedAt` persisted
- [ ] On `status: FAILED`: post record updated to `status=FAILED`, `errorCode` and `errorMessage` persisted; user notification created with failure reason
- [ ] Endpoint is idempotent: duplicate callbacks with the same `postId` and `status` do not create duplicate notifications

**Technical Notes:**

- Use database-level unique constraint or `INSERT ... ON CONFLICT DO NOTHING` to enforce idempotency on notification creation
- Notification content for failure should be user-readable, not the raw API error message; map `errorCode` to a Vietnamese-language user message

**Dependencies:** Blocks: None. Blocked by: DA-E22-01, DA-E22-02.

---

## PHASE V2 — Media Package/Campaign & Task Workflow (E50/E51, thay thế E28-E31 cũ bên dưới)

> Chi tiết đầy đủ cho các task mới trong Phần 1.5 (E50 Media Package & Campaign, E51 Task & Content Workflow). Task E28-E31 gốc bên dưới (Phase 5-7) giữ nguyên để tham khảo lịch sử nhưng KHÔNG dùng làm nguồn công việc — xem ghi chú "archived" ở Phần 1.5.

### DA-E50-01 — Entity MediaPackage (Template + Custom, 1 bảng)

**Assignee:** Lộc | **Priority:** 🟡 High

**Goal:** Model both Admin-created template packages and Owner/Manager-created custom packages in a single `MediaPackage` table, distinguished by `is_template`, per the V2 DB design decision (avoids a polymorphic template/custom split).

**Acceptance Criteria:**

- [ ] `MediaPackage` table: `id`, `name`, `type`, `durationWeeks`, `budgetAmount`, `is_template` (boolean), `agencyId` (nullable — NULL for Admin templates, set for Agency-custom)
- [ ] `GET /api/v1/media-package-templates` returns all `is_template=true` records
- [ ] `POST /api/v1/agencies/{id}/media-package-custom` creates a `is_template=false` record scoped to the Agency

**Technical Notes:** BA spec originally proposed 2 separate tables (`MediaPackageTemplate`/`MediaPackageCustom`) — the V2 DB decision consolidated this into 1 table with `is_template`; follow `docs/database/schema-v2/database-strategy.md`, not the older 2-table sketch in the FR spec.

**Spec Reference:** `docs/feature/media-package-campaign/3-5-1-create-media-package/spec.md`, `docs/database/schema-v2/database-strategy.md`, `docs/ba/04-media-package-campaign.md`

**Dependencies:** Blocks: [DA-E50-02, DA-E50-03]. Blocked by: [DA-E16-05 (Agency must exist for `agencyId` scoping)].

---

### DA-E50-02 — Implement Media Package Selection Flow (post-Workspace-creation)

**Assignee:** Lộc | **Priority:** 🟡 High

**Goal:** Let Owner/Manager pick a template or create a custom package immediately after Workspace creation, before inviting a Client — per the confirmed business sequencing.

**Acceptance Criteria:**

- [ ] `POST /api/v1/workspaces/{id}/media-package` accepts `{packageRefId, packageRefType: template|custom}`, returns 201 with `workspaceMediaPackageId`
- [ ] If no package selected within X days of Workspace creation, a reminder notification is sent (does not block Workspace access)
- [ ] Package can be freely changed BEFORE the Client starts negotiating (DA-E50-04); once negotiation has started, switching to a different package entirely is blocked — only continued negotiation on the current package is allowed

**Spec Reference:** `docs/feature/media-package-campaign/3-5-1-create-media-package/spec.md`, `docs/ba/04-media-package-campaign.md` mục 1

**Dependencies:** Blocks: [DA-E50-04]. Blocked by: [DA-E50-01, DA-E15-01].

---

### DA-E50-03 — Entity WorkspaceMediaPackage

**Assignee:** Lộc | **Priority:** 🟡 High

**Goal:** Model the package instance actually applied to a specific Workspace, tracking its negotiation state independently from the source `MediaPackage` template/custom record.

**Acceptance Criteria:**

- [ ] `WorkspaceMediaPackage` table: `id`, `workspaceId`, `packageRefId`, `packageRefType`, `negotiationStatus`, `finalTerms` (jsonb), `approvedByAgencyAt`, `approvedByClientAt`

**Spec Reference:** `docs/ba/11-data-entities-glossary.md`, `docs/ba/12-state-machines.md` mục 2

**Dependencies:** Blocks: [DA-E50-04]. Blocked by: [DA-E50-01].

---

### DA-E50-04 — Implement Package Negotiation Loop (2-way, multi-round)

**Assignee:** Lộc | **Priority:** 🔴 Critical

**Goal:** Implement the back-and-forth negotiation between Client and Agency on package terms (price, duration, format), cycling through `CLIENT_REQUESTED_CHANGE ↔ AGENCY_COUNTERED` for as many rounds as needed, with no hard round limit.

**Acceptance Criteria:**

- [ ] `POST /api/v1/workspaces/{id}/media-package/request-change` (Client) accepts `{requestedTerms, note?}`, transitions to `CLIENT_REQUESTED_CHANGE`
- [ ] `POST /api/v1/workspaces/{id}/media-package/counter-offer` (Owner/Manager) accepts `{counterTerms, note?}`, transitions to `AGENCY_COUNTERED`
- [ ] Full negotiation history (all requests/counters) is persisted, not just the latest state
- [ ] Attempting to request a change on an already-`APPROVED` package returns 409 `PACKAGE_ALREADY_APPROVED`
- [ ] No maximum round limit enforced (per BA, "để tự nhiên theo thực tế thương lượng")

**Technical Notes:** This is the highest-complexity task in the entire re-scope — model negotiation history as an append-only log (e.g. a `PackageNegotiationEvent` sub-collection/table), not just overwriting `finalTerms` each time, so the UI thread view (DA-E50 frontend) can render the full back-and-forth.

**Spec Reference:** `docs/feature/media-package-campaign/3-5-3-request-media-package/spec.md`, `docs/ba/12-state-machines.md` mục 2 "Media Package (đàm phán)"

**Dependencies:** Blocks: [DA-E50-05]. Blocked by: [DA-E50-02, DA-E50-03].

---

### DA-E50-05 — Implement 2-Party Approve + Reset-on-Edit Rule

**Assignee:** Lộc | **Priority:** 🔴 Critical

**Goal:** Require BOTH Agency and Client to independently approve a package before it becomes `APPROVED`, and enforce that editing `finalTerms` after one party has approved resets that approval — this is the core ACID-sensitive rule flagged across all three audit passes.

**Acceptance Criteria:**

- [ ] `POST /api/v1/workspaces/{id}/media-package/approve` sets `approvedByAgencyAt` OR `approvedByClientAt` depending on caller's side; package only reaches `APPROVED` when BOTH are non-null
- [ ] One party approving does not auto-approve the other side
- [ ] If either party edits `finalTerms` (via a new negotiation round) AFTER approving, that same party's approval timestamp is reset to NULL in the SAME transaction as the terms edit — never leave a stale approval standing against changed terms
- [ ] A party can voluntarily un-approve their own approval to reopen negotiation before the other side has approved
- [ ] Approving in an invalid state (e.g. no proposal exists yet) returns 409 `INVALID_STATE_FOR_APPROVAL`

**Technical Notes:** This must be one atomic DB transaction (edit terms + reset opposing approval) — a partial failure here (terms changed but stale approval left standing) is exactly the risk flagged in `docs/plan/document-plan.md` R2 §1.3 as a top project risk ("reject-giữ-approval-cũ tính sai trong code").

**Spec Reference:** `docs/feature/media-package-campaign/3-5-4-approve-media-package/spec.md`, `docs/ba/12-state-machines.md` mục 2

**Dependencies:** Blocks: [DA-E50-06]. Blocked by: [DA-E50-04].

---

### DA-E50-06 — Entity MediaCampaign (immutable after approve)

**Assignee:** Lộc | **Priority:** 🟡 High

**Goal:** Let Owner/Manager create a detailed execution Campaign from an approved Package — a strategy/timeline document, explicitly NOT a contract, becoming immutable once approved.

**Acceptance Criteria:**

- [ ] `POST /api/v1/workspaces/{id}/campaigns` accepts `{name, strategyDetail, brandGuideline?, timeline?}`, only allowed when the Workspace's `MediaPackage.negotiationStatus = APPROVED`
- [ ] Initial Campaign status: `DRAFT`
- [ ] Attempting to create a Campaign against a non-approved package returns 409 `PACKAGE_NOT_APPROVED`
- [ ] A Workspace can have multiple Campaigns over time (no 1-Campaign-per-Workspace limit)

**Spec Reference:** `docs/feature/media-package-campaign/3-5-5-create-media-campaign/spec.md`, `docs/ba/12-state-machines.md` mục 3

**Dependencies:** Blocks: [DA-E50-07]. Blocked by: [DA-E50-05].

---

### DA-E50-07 — Implement Campaign Approve + Auto-generate Task Backlog

**Assignee:** Lộc | **Priority:** 🔴 Critical

**Goal:** Mirror the Package's 2-party approval mechanism for Campaigns, and on approval, automatically explode the Campaign's work items into a raw Task backlog in the Workspace.

**Acceptance Criteria:**

- [ ] `POST /api/v1/workspaces/{id}/campaigns/{campaignId}/approve` requires both sides, same semantics as DA-E50-05
- [ ] `POST /api/v1/workspaces/{id}/campaigns/{campaignId}/deploy` (available only once both approved) creates N Tasks in the backlog, one per Campaign work item
- [ ] Generated Tasks are minimal: name + deadline only — no assignee or detailed requirements yet (those come from Identify Task Detail, DA-E51-04-equivalent FR 3.6.1)
- [ ] Campaign transitions to `IN_PROGRESS` immediately after deploy
- [ ] Calling deploy twice (double-click) does not create duplicate Tasks — idempotency required

**Technical Notes:** This is the hand-off point into E51 (Task & Content Workflow) — the Task collection (DA-E51-01) must exist before this task's deploy logic can insert into it.

**Spec Reference:** `docs/feature/media-package-campaign/3-5-6-approve-media-campaign/spec.md`, `docs/ba/05-content-task-workflow.md`

**Dependencies:** Blocks: [DA-E51-04]. Blocked by: [DA-E50-06, DA-E51-01].

---

### DA-E50-08 — Entity ThirdPartyCollaborator (new domain)

**Assignee:** Lộc | **Priority:** 🟢 Medium

**Goal:** Model an Agency-level directory of external media partners (newspapers, banner ad networks, TV) that can be reused across multiple Campaigns — this is a brand-new domain with zero prior code.

**Acceptance Criteria:**

- [ ] `ThirdPartyCollaborator` table scoped to `agencyId`: `name`, `type` (newspaper/banner/TV/other), `contactInfo`
- [ ] Basic CRUD endpoints under `/api/v1/agencies/{id}/collaborators`

**Spec Reference:** `docs/ba/07-publishing-social-collaborator.md`, `docs/ba/12-state-machines.md` mục 6 "Third-party Collaborator"

**Dependencies:** Blocks: [DA-E50-09]. Blocked by: [DA-E16-05].

---

### DA-E50-09 — Entity CampaignCollaborator (N-N, per-Campaign status)

**Assignee:** Lộc | **Priority:** 🟡 High

**Goal:** Track a Third-party Collaborator's engagement status for a specific Campaign (contacted → negotiating → confirmed → live) — this tracking is manual, not an automated integration.

**Acceptance Criteria:**

- [ ] `CampaignCollaborator` junction table: `campaignId`, `collaboratorId`, `status` (contacted/negotiating/confirmed/live)
- [ ] Same `ThirdPartyCollaborator` can be linked to multiple Campaigns independently, each with its own status

**Spec Reference:** `docs/ba/12-state-machines.md` mục 6

**Dependencies:** Blocks: [None]. Blocked by: [DA-E50-06, DA-E50-08].

---

### DA-E50-10 — Implement Content Request (Client-initiated, FSM with terminal denied)

**Assignee:** Lộc | **Priority:** 🟡 High

**Goal:** Let a Client propose an ad-hoc content piece outside the approved Campaign plan, for Manager review before assignment.

**Acceptance Criteria:**

- [ ] `POST /api/v1/workspaces/{id}/content-requests` accepts `{title, description}` — CLIENT role only; Owner/Manager can view but not self-create (per BA confirmation 2026-09-14)
- [ ] Initial status `pending`
- [ ] FSM: `pending → in_progress → accepted/denied`; `denied` is terminal (cannot transition further)
- [ ] `PUT` update allowed only while `status=pending` (DA-E50 track-status/update, FR 3.5.8/3.5.9)
- [ ] `DELETE` (cancel) allowed only while `status=pending`; after Manager changes status, Client can no longer cancel — returns 409 `REQUEST_NOT_CANCELLABLE`
- [ ] Cancel is a soft-delete (`status=cancelled`), consistent with the soft-delete convention used elsewhere in V2
- [ ] Non-Client attempting to create, or non-owner-of-request attempting to cancel, returns 403

**Spec Reference:** `docs/feature/media-package-campaign/3-5-7-create-content-request/spec.md`, `docs/feature/media-package-campaign/3-5-8-track-request-status/spec.md`, `docs/feature/media-package-campaign/3-5-9-update-request/spec.md`, `docs/feature/media-package-campaign/3-5-10-cancel-request/spec.md`, `docs/ba/12-state-machines.md` mục 1 "Content Request"

**Dependencies:** Blocks: [None]. Blocked by: [DA-E15-01].

---

### DA-E51-01 — Collection `tasks` (generic, 3 types)

**Assignee:** Lộc | **Priority:** 🔴 Critical

**Goal:** Model a single generic `tasks` MongoDB collection covering all 3 task types (post/livestream/survey) via a `type` discriminator, instead of 3 separate collections — the V2 DB design decision.

**Acceptance Criteria:**

- [ ] `tasks` collection: `id`, `workspaceId`, `campaignId` (nullable — some Tasks come from Content Request, not Campaign), `type` (post/livestream/survey), `name`, `dueDate`, `status` (backlog/detail_identified/assigned/...), `assigneeId`, `qcAssigneeId`, `requiresClientApproval`, `description`, type-specific sub-fields
- [ ] Task starts in `backlog` status when auto-generated from Campaign deploy (DA-E50-07) or Content Request acceptance

**Spec Reference:** `docs/ba/05-content-task-workflow.md`, `docs/ba/11-data-entities-glossary.md`

**Dependencies:** Blocks: [DA-E51-02, DA-E51-03, DA-E51-04]. Blocked by: [None].

---

### DA-E51-02 — Collection `task_approvals` (separate from tasks, preserves history on reject)

**Assignee:** Lộc | **Priority:** 🔴 Critical

**Goal:** Track each approval-sequence step (QC/Manager/Client) as its own document in a separate collection, so that when a later step rejects, the approvals already passed at earlier steps are NOT lost — the single highest-risk data modeling decision in the whole re-scope.

**Acceptance Criteria:**

- [ ] `task_approvals` collection: `id`, `taskId`, `step` (qc/manager/client), `action` (approve/reject), `actorId`, `comment`, `createdAt`
- [ ] Approvals are append-only — a reject at step N does NOT delete or overwrite the approve record from step N-1
- [ ] Querying "current valid approvals for Task X" must correctly interpret the append-only log (e.g. latest action per step, ignoring records invalidated by an intervening reject-then-resubmit cycle) — see DA-E51-03 for exact semantics

**Technical Notes:** Do not model this as a single embedded array on the Task document that gets overwritten — that was the exact anti-pattern flagged as a top project risk in `docs/plan/document-plan.md` R2 §1.3 ("reject-giữ-approval-cũ tính sai trong code"). A separate, append-only collection makes "what got preserved" queryable and auditable.

**Spec Reference:** `docs/ba/12-state-machines.md` mục 4 "Task — Approval Sequence", `docs/ba/11-data-entities-glossary.md`

**Dependencies:** Blocks: [DA-E51-03]. Blocked by: [DA-E51-01].

---

### DA-E51-03 — Implement Approval Sequence State Machine (Creator → [QC] → Manager → [Client])

**Assignee:** Phước | **Priority:** 🔴 Critical

**Goal:** Implement the full approval chain with optional QC and optional Client steps, where a reject at ANY step always returns the Task to `ASSIGNED` for the Creator to fix, but resubmission skips back only to the step immediately AFTER the last-passed step — never redoing already-approved steps automatically.

**Acceptance Criteria:**

- [ ] Chain: `Creator submit → [QC review, optional] → Manager review → [Client review, optional if requiresClientApproval] → Completed`
- [ ] Whether QC runs is determined by `qcAssigneeId` being set at Assign time (DA-E51-04), not a separate toggle
- [ ] Reject at ANY step → Task returns to `ASSIGNED`; approvals from steps BEFORE the rejected step are preserved, NOT cleared
- [ ] Resubmission after reject skips directly to the step after the last-passed one (e.g. QC approved → Manager rejected → resubmit → goes straight to `MANAGER_REVIEW`, does NOT re-enter `QC_REVIEW`) — Manager may manually re-request QC if desired, but it is never automatic
- [ ] If QC rejects (the first step), there is no prior approval to preserve — resubmit re-enters `QC_REVIEW` normally
- [ ] If Client rejects (the last step), Manager's earlier approval is preserved — resubmit goes straight back to `CLIENT_REVIEW`, not `MANAGER_REVIEW`
- [ ] Full chain with no rejects → Task reaches `COMPLETED`
- [ ] Shortest possible chain (no QC, no Client approval): Creator submit → Manager approve → Completed (2 steps)
- [ ] Approve/reject called by the wrong actor for the current step returns 403 `WRONG_APPROVAL_STEP`
- [ ] Approve/reject called on a Task not yet submitted returns 409 `TASK_NOT_SUBMITTED`
- [ ] `GET /api/v1/workspaces/{id}/tasks/{taskId}/approvals` returns the full approval history log

**Technical Notes:** This is the single most complex state machine in the entire V2 re-scope — implement exactly per `docs/ba/12-state-machines.md` mục 4, write unit tests covering every branch (QC-reject, Manager-reject-with-prior-QC-pass, Client-reject-with-prior-Manager-pass, no-QC-no-Client shortest path) before considering this task done.

**Spec Reference:** `docs/feature/content-task-workflow/3-6-9-approval-sequence-creator-manager-client/spec.md`, `docs/ba/12-state-machines.md` mục 4

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-02, DA-E51-04].

---

### DA-E51-04 — Implement Task Backlog, Identify Detail + Assign to Creator

**Assignee:** Lộc | **Priority:** 🟡 High

**Goal:** Let Manager fill in full detail for a raw backlog Task (name + rough deadline only from Campaign deploy) and then assign it to a Creator, optionally with a QC reviewer and a Client-approval requirement.

**Acceptance Criteria:**

- [ ] `PATCH /api/v1/workspaces/{id}/tasks/{taskId}/detail` accepts `{description, dueDate, typeSpecificFields}`, only allowed while `status=backlog`; transitions to `DETAIL_IDENTIFIED`
- [ ] Calling detail-fill on a non-backlog Task returns 409 `TASK_NOT_IN_BACKLOG`
- [ ] `POST /api/v1/workspaces/{id}/tasks/{taskId}/assign` accepts `{assigneeId, qcAssigneeId?, requiresClientApproval}`, only allowed after `DETAIL_IDENTIFIED`; transitions to `ASSIGNED`
- [ ] `assigneeId` must be a Workspace Member with role MEMBER/CREATOR; invalid target returns 400 `INVALID_ASSIGNEE`
- [ ] `qcAssigneeId` cannot equal `assigneeId` — returns 400 `QC_CANNOT_BE_SAME_AS_ASSIGNEE`
- [ ] Assigning before detail is identified returns 409 `TASK_DETAIL_NOT_IDENTIFIED`
- [ ] Creator receives a notification upon assignment

**Spec Reference:** `docs/feature/content-task-workflow/3-6-1-identify-task-detail/spec.md`, `docs/feature/content-task-workflow/3-6-2-assign-task-to-creator/spec.md`

**Dependencies:** Blocks: [DA-E51-03]. Blocked by: [DA-E51-01, DA-E50-07].

---

### DA-E51-05 — Implement Task Views (List, Calendar, Gantt/Timeline, Kanban, Filter)

**Assignee:** Phước | **Priority:** 🟡 High

**Goal:** Provide the 4 task visualization modes plus filtering that Creator/Manager/Client use day-to-day — this is primarily backend query/aggregation work since the frontend UI for these views (`pages/calendar`, task views) already exists.

**Acceptance Criteria:**

- [ ] `GET /api/v1/workspaces/{id}/tasks` supports list view with pagination
- [ ] `GET /api/v1/workspaces/{id}/tasks/calendar?from=&to=` returns Tasks grouped by `dueDate` for calendar rendering
- [ ] `GET /api/v1/workspaces/{id}/tasks/gantt` returns Tasks with start/end for Gantt/Timeline rendering
- [ ] `GET /api/v1/workspaces/{id}/tasks/kanban` returns Tasks grouped by `status` for Kanban board columns
- [ ] Filter query params: `assigneeId`, `type`, `status`, `dueDateRange`

**Technical Notes:** Frontend `web-dashboard` already has a `calendar` page using `mockCalendarService.ts` — this backend work is what unblocks swapping the mock for a real service call, not new frontend work.

**Spec Reference:** `docs/feature/content-task-workflow/3-6-4-list-task-view/spec.md`, `3-6-5-calendar-task-view`, `3-6-6-grantt-timeline-task-view`, `3-6-7-kanban-board-task-view`, `3-6-8-view-task-filter` (cùng thư mục `docs/feature/content-task-workflow/`)

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-01].

---

### DA-E51-06 — Collection `material_repository` (raw vs retouched) + View Material (FR 3.6.11)

**Assignee:** Tuấn | **Priority:** 🟡 High

**Goal:** Provide a Workspace-scoped media library distinguishing Creator/photographer-produced material (raw vs retouched), plus the read/view endpoint — the foundation the other 5 Material Repository tasks (add/update/remove/watermark/download) build on.

**Acceptance Criteria:**

- [ ] `material_repository` collection: `id`, `workspaceId`, `url`, `type` (raw/retouched), `uploadedBy`, `uploadedAt`
- [ ] `GET /api/v1/workspaces/{id}/materials?type=raw|retouched` lists filtered by type
- [ ] Raw-type materials show a warning badge in the UI when referenced in a submitted Task (does not hard-block submission — Manager decides whether to reject)

**Spec Reference:** `docs/feature/content-task-workflow/3-6-11-view-material-repository/spec.md`

**Dependencies:** Blocks: [DA-E51-06b, DA-E51-06c, DA-E51-06d, DA-E51-06e, DA-E51-06f]. Blocked by: [DA-E15-01].

---

### DA-E51-06b — Add Material to Repository (FR 3.6.12)

**Assignee:** Tuấn | **Priority:** 🟡 High

**Goal:** Let the photographer/editor role upload new raw or retouched material into the Workspace repository.

**Acceptance Criteria:**

- [ ] `POST /api/v1/workspaces/{id}/materials` accepts file upload + `{type: raw|retouched}`, returns 201 with the new material record
- [ ] Uploader recorded as `uploadedBy`; `uploadedAt` set server-side
- [ ] Invalid/missing file returns 400 `VALIDATION_ERROR`

**Spec Reference:** `docs/feature/content-task-workflow/3-6-12-add-material-repository/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-06].

---

### DA-E51-06c — Update Material in Repository (FR 3.6.13)

**Assignee:** Tuấn | **Priority:** 🟢 Medium

**Goal:** Let the uploader (or Manager) correct metadata on an existing material entry (e.g. re-classify raw → retouched after editing).

**Acceptance Criteria:**

- [ ] `PATCH /api/v1/workspaces/{id}/materials/{materialId}` accepts `{type?}`, updates the record
- [ ] Only the original uploader or a Manager may update — others get 403
- [ ] Updating a non-existent material returns 404

**Spec Reference:** `docs/feature/content-task-workflow/3-6-13-update-material-repository/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-06].

---

### DA-E51-06d — Remove Material from Repository (FR 3.6.14)

**Assignee:** Tuấn | **Priority:** 🟢 Medium

**Goal:** Let the uploader/Manager remove a material entry (soft-delete, consistent with the V2 soft-delete convention).

**Acceptance Criteria:**

- [ ] `DELETE /api/v1/workspaces/{id}/materials/{materialId}` soft-deletes (does not hard-remove the file)
- [ ] Material already referenced by a submitted Task cannot be hard-deleted, only soft-deleted — Task still resolves the reference for history purposes
- [ ] Only the original uploader or a Manager may delete — others get 403

**Spec Reference:** `docs/feature/content-task-workflow/3-6-14-remove-material-repository/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-06].

---

### DA-E51-06e — Apply Watermark to Material (FR 3.6.15)

**Assignee:** Trung | **Priority:** 🟡 High

**Goal:** Let the Creator stamp a Client-supplied brand logo onto an edited image/asset as a watermark, similar to img2go's watermark tool, to mark ownership before publishing.

**Acceptance Criteria:**

- [ ] `POST /api/v1/workspaces/{id}/materials/{materialId}/watermark` accepts `{logoAssetId, position, opacity?}`, returns a new material record (the watermarked output), original untouched
- [ ] Logo must come from the Workspace's Brand Collection (Client-supplied) — an arbitrary uploaded logo is rejected with 400
- [ ] Unsupported image format returns 400 `UNSUPPORTED_FORMAT`

**Spec Reference:** `docs/feature/content-task-workflow/3-6-15-apply-watermark/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-06].

---

### DA-E51-06f — Download Material (FR 3.6.16)

**Assignee:** Tuấn | **Priority:** 🟢 Medium

**Goal:** Let any Workspace member download a material asset to their local machine for reuse or offline editing.

**Acceptance Criteria:**

- [ ] `GET /api/v1/workspaces/{id}/materials/{materialId}/download` streams/redirects to the file with correct `Content-Disposition`
- [ ] Downloading a soft-deleted material returns 404

**Spec Reference:** `docs/feature/content-task-workflow/3-6-16-download-material/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-06].

---

### DA-E51-06g — Entity/Endpoint `brand_collections` (Client-supplied reference assets)

**Assignee:** Tuấn | **Priority:** 🟡 High

**Goal:** Provide a separate Brand Collection concept for Client-supplied reference assets — distinct from `material_repository` (Creator/photographer output), with distinct upload permission (Client uploads, Creator only views).

**Acceptance Criteria:**

- [ ] `brand_collections` collection: `id`, `workspaceId`, `url`, `uploadedBy` (must be CLIENT role), `uploadedAt`
- [ ] `GET /api/v1/workspaces/{id}/brand-collection` lists all Client-supplied reference assets
- [ ] `POST /api/v1/workspaces/{id}/brand-collection` — CLIENT role only; Creator/Manager attempting to upload returns 403

**Spec Reference:** `docs/ba/05-content-task-workflow.md`, `docs/feature/content-task-workflow/3-6-11-view-material-repository/spec.md` (Brand Asset Upload for Reference note)

**Dependencies:** Blocks: [DA-E51-06e]. Blocked by: [DA-E15-01].

---

### DA-E51-07 — Apply Hashtag to Task (FR 3.6.17)

**Assignee:** Tuấn | **Priority:** 🟢 Medium

**Goal:** Let a Creator attach one or more hashtags (from the Workspace's Hashtag Collection, or free-typed) to a Post-type Task.

**Acceptance Criteria:**

- [ ] `PATCH /api/v1/workspaces/{id}/tasks/{taskId}/hashtags` attaches one or more hashtags to a Post-type Task
- [ ] A hashtag not yet in the Collection when applied is auto-created into the Collection (per BA edge case)
- [ ] Hashtag not belonging to this Workspace returns 400 `INVALID_HASHTAG`

**Spec Reference:** `docs/feature/content-task-workflow/3-6-17-apply-hastag/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-07b].

---

### DA-E51-07b — Collection `hashtag_collections` + View Collection (FR 3.6.18)

**Assignee:** Tuấn | **Priority:** 🟢 Medium

**Goal:** Provide the Workspace-scoped Hashtag Collection store and its read endpoint — Creator can browse existing tags, AI can later recommend from this pool.

**Acceptance Criteria:**

- [ ] `hashtag_collections` collection: `id`, `workspaceId`, `tag`, `usageCount`
- [ ] `GET /api/v1/workspaces/{id}/hashtag-collection` lists all tags with usage count

**Spec Reference:** `docs/feature/content-task-workflow/3-6-18-view-hastag-collection/spec.md`

**Dependencies:** Blocks: [DA-E51-07, DA-E51-07c, DA-E51-07d, DA-E51-07e]. Blocked by: [DA-E15-01].

---

### DA-E51-07c — Add Hashtag to Collection (FR 3.6.19)

**Assignee:** Tuấn | **Priority:** 🟢 Medium

**Goal:** Let Creator/Client explicitly add a new hashtag into the Collection with a classification of its purpose (per BA note: Client-added tags are event-specific and mandatory).

**Acceptance Criteria:**

- [ ] `POST /api/v1/workspaces/{id}/hashtag-collection` accepts `{tag, purpose?}`, returns 201
- [ ] Duplicate tag within the same Workspace returns 409 `HASHTAG_ALREADY_EXISTS`

**Spec Reference:** `docs/feature/content-task-workflow/3-6-19-add-hastag-collection/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-07b].

---

### DA-E51-07d — Update Hashtag in Collection (FR 3.6.20)

**Assignee:** Tuấn | **Priority:** 🟢 Medium

**Goal:** Let Creator/Manager correct a hashtag's text or purpose classification without losing its accumulated `usageCount`.

**Acceptance Criteria:**

- [ ] `PATCH /api/v1/workspaces/{id}/hashtag-collection/{id}` accepts `{tag?, purpose?}`, preserves `usageCount`
- [ ] Renaming to a tag that already exists returns 409 `HASHTAG_ALREADY_EXISTS`

**Spec Reference:** `docs/feature/content-task-workflow/3-6-20-update-hastag-collection/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-07b].

---

### DA-E51-07e — Remove Hashtag from Collection (FR 3.6.21)

**Assignee:** Tuấn | **Priority:** 🟢 Medium

**Goal:** Let Creator/Manager remove an obsolete hashtag from the Collection without breaking Tasks that already used it (soft-delete).

**Acceptance Criteria:**

- [ ] `DELETE /api/v1/workspaces/{id}/hashtag-collection/{id}` soft-deletes — removed tag no longer appears when browsing/adding, but Tasks that already applied it keep the reference
- [ ] Deleting a non-existent hashtag returns 404

**Spec Reference:** `docs/feature/content-task-workflow/3-6-21-remove-hastag-collection/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-07b].

---

### DA-E51-08 — Write Livestream Idea (FR 3.6.22)

**Assignee:** Phước | **Priority:** 🟡 High

**Goal:** For Task type=livestream, let Creator/Manager record the livestream idea and the goal it aims for, as the first step before scripting.

**Acceptance Criteria:**

- [ ] `PATCH /api/v1/workspaces/{id}/tasks/{taskId}/livestream/idea` accepts `{idea, goal}`, only for `type=livestream` Tasks — returns 400 `INVALID_TASK_TYPE` otherwise

**Spec Reference:** `docs/feature/content-task-workflow/3-6-22-write-livestream-idea/spec.md`

**Dependencies:** Blocks: [DA-E51-08b]. Blocked by: [DA-E51-04].

---

### DA-E51-08b — Write Livestream Script (FR 3.6.23)

**Assignee:** Phước | **Priority:** 🟡 High

**Goal:** Let Creator write the full script for a livestream session, separate from the idea/goal captured in DA-E51-08.

**Acceptance Criteria:**

- [ ] `PATCH /api/v1/workspaces/{id}/tasks/{taskId}/livestream/script` accepts `{script}`, only allowed after idea is recorded

**Spec Reference:** `docs/feature/content-task-workflow/3-6-23-write-livestream-script/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-08].

---

### DA-E51-08c — Track Livestream Status (FR 3.6.24)

**Assignee:** Phước | **Priority:** 🟡 High

**Goal:** Track and expose the livestream's sub-state (`PRE_LIVE → LIVE → POST_LIVE`), independent of the main Approval Sequence status.

**Acceptance Criteria:**

- [ ] Sub-state field on the Task tracks `PRE_LIVE → LIVE → POST_LIVE`
- [ ] `GET /api/v1/workspaces/{id}/tasks/{taskId}/livestream/status` returns current sub-state
- [ ] Transition out of order (e.g. `PRE_LIVE → POST_LIVE` skipping `LIVE`) returns 409 `INVALID_LIVESTREAM_TRANSITION`

**Spec Reference:** `docs/feature/content-task-workflow/3-6-24-track-livestream-status/spec.md`, `docs/ba/12-state-machines.md` mục 5 "Task loại Livestream"

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-08].

---

### DA-E51-08d — Generate Meeting Link (FR 3.6.27)

**Assignee:** Phước | **Priority:** 🟢 Medium

**Goal:** Auto-generate a Google Meet link for the livestream session so Creator/Manager don't need to create one manually.

**Acceptance Criteria:**

- [ ] `POST /api/v1/workspaces/{id}/tasks/{taskId}/livestream/meeting-link` generates/returns a meeting link, persisted on the Task
- [ ] Calling it again on the same Task returns the existing link rather than generating a duplicate

**Spec Reference:** `docs/feature/content-task-workflow/3-6-27-generate-meeting-link/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-08].

---

### DA-E51-09 — Create Survey (FR 3.6.25)

**Assignee:** Phước | **Priority:** 🟢 Medium

**Goal:** For Task type=survey, implement a form-builder for creating a workshop survey with time-slotted questions.

**Acceptance Criteria:**

- [ ] `POST /api/v1/workspaces/{id}/tasks/{taskId}/survey` accepts `{questions: [{type, label, timeSlot?}]}`, only for `type=survey` Tasks — 400 `INVALID_TASK_TYPE` otherwise
- [ ] Publishing a survey with zero questions returns 400 `SURVEY_MUST_HAVE_QUESTIONS`
- [ ] Returns a `publicLink` for participants to fill without authentication

**Spec Reference:** `docs/feature/content-task-workflow/3-6-25-create-survey/spec.md`

**Dependencies:** Blocks: [DA-E51-09b]. Blocked by: [DA-E51-04].

---

### DA-E51-09b — View Survey Analysis (FR 3.6.26)

**Assignee:** Phước | **Priority:** 🟢 Medium

**Goal:** Aggregate survey responses into a per-question analysis view so Creator/Manager/Client can review workshop outcomes.

**Acceptance Criteria:**

- [ ] `GET /api/v1/workspaces/{id}/tasks/{taskId}/survey/analysis` aggregates responses per question
- [ ] Survey with zero responses returns an empty aggregation, not an error

**Spec Reference:** `docs/feature/content-task-workflow/3-6-26-view-survey-analysis/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-09].

---

### DA-E51-10 — View Mail Template (FR 3.6.28)

**Assignee:** Trung | **Priority:** 🟢 Medium

**Goal:** Let Workspace Members browse existing mail templates (including Admin-provided base templates) before creating or sending — role scope is an [OPEN QUESTION] per BA (source FR CSV lists no confirmed role).

**Acceptance Criteria:**

- [ ] `GET /api/v1/workspaces/{id}/mail-templates` lists templates, including any Admin-provided base templates

**Technical Notes:** [OPEN QUESTION] Which role(s) may view/create/send mail templates is unconfirmed in the source FR CSV — flag this to Trung before finalizing the `@RequireRole` annotation on these endpoints; do not guess.

**Spec Reference:** `docs/feature/content-task-workflow/3-6-28-view-mail-template/spec.md`

**Dependencies:** Blocks: [DA-E51-10b, DA-E51-10c, DA-E51-10d, DA-E51-10e]. Blocked by: [DA-E15-01].

---

### DA-E51-10b — Create Mail Template (FR 3.6.29)

**Assignee:** Trung | **Priority:** 🟢 Medium

**Goal:** Let Creator create a new reusable email template, optionally cloned from an Admin-provided base template.

**Acceptance Criteria:**

- [ ] `POST /api/v1/workspaces/{id}/mail-templates` accepts `{name, subject, body}`, returns 201
- [ ] Empty `subject`/`body` returns 400 `VALIDATION_ERROR`

**Spec Reference:** `docs/feature/content-task-workflow/3-6-29-create-mail-template/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-10].

---

### DA-E51-10c — Update Mail Template (FR 3.6.30)

**Assignee:** Trung | **Priority:** 🟢 Medium

**Goal:** Let Creator edit a template they created, or edit their own copy of an Admin-provided base template.

**Acceptance Criteria:**

- [ ] `PATCH /api/v1/workspaces/{id}/mail-templates/{id}` accepts `{name?, subject?, body?}`
- [ ] Editing a non-existent template returns 404

**Spec Reference:** `docs/feature/content-task-workflow/3-6-30-update-mail-template/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-10].

---

### DA-E51-10d — Delete Mail Template (FR 3.6.31)

**Assignee:** Trung | **Priority:** 🟢 Medium

**Goal:** Let Creator remove a template they created (or their own copy of a base template) that is no longer needed.

**Acceptance Criteria:**

- [ ] `DELETE /api/v1/workspaces/{id}/mail-templates/{id}` soft-deletes, consistent with the V2 soft-delete convention
- [ ] Deleting a non-existent template returns 404

**Spec Reference:** `docs/feature/content-task-workflow/3-6-31-delete-mail-template/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-10].

---

### DA-E51-10e — Send Email via Template (FR 3.6.32)

**Assignee:** Trung | **Priority:** 🟢 Medium

**Goal:** Let Creator send an actual email using a saved template, filling in the recipient(s) at send time.

**Acceptance Criteria:**

- [ ] `POST /api/v1/workspaces/{id}/mail-templates/{id}/send` accepts `{recipients: []}`, sends the email using the template's subject/body
- [ ] Sending with an empty `recipients` list returns 400 `VALIDATION_ERROR`
- [ ] Email delivery failure returns 502 `EMAIL_SERVICE_UNAVAILABLE`, retryable

**Spec Reference:** `docs/feature/content-task-workflow/3-6-32-send-email-via-template/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-10].

---

### DA-E51-11 — Implement Content Compliance Check (3rd-party moderation)

**Assignee:** Tuấn | **Priority:** 🟡 High

**Goal:** Check Post-type Task content (text + images) for plagiarism, violence, or explicit imagery via a 3rd-party moderation API, surfacing a detailed violation breakdown so the Creator can self-correct before publishing.

**Acceptance Criteria:**

- [ ] `POST /api/v1/workspaces/{id}/tasks/{taskId}/compliance-check` runs moderation on the Task's text (plagiarism) and images (violence/explicit)
- [ ] Returns `{violations: [{type, excerpt, severity, suggestion}]}`; empty array when clean, with a "passed" badge shown
- [ ] Severe violations optionally auto-enqueue into the Admin Content Moderation Queue (DA-E53-06) for Admin review
- [ ] 3rd-party API timeout/failure returns 502 `COMPLIANCE_SERVICE_UNAVAILABLE`, retryable
- [ ] **[CONFIRMED 2026-09-15, Trung]** Renders into the same shared warning panel on the Creator's Task Detail screen as DA-E51-12 (Copyright check) — one unified risk-level display, not two separate widgets

**Technical Notes:** Requires selecting and provisioning a 3rd-party moderation API (not yet chosen) — flag as an external dependency to resolve before this task can start. Design the response `severity` scale so both this check and DA-E51-12 can feed the same panel component.

**Spec Reference:** `docs/feature/content-task-workflow/3-6-33-check-compliance-content/spec.md`, `docs/ba/09-admin-management.md` FR 3.10.4

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-04].

---

### DA-E51-12 — Implement Copyright Infringement Check

**Assignee:** Tuấn | **Priority:** 🟢 Medium

**Goal:** Check images (and any brand/logo elements within them) for copyright infringement risk before publishing, via a 3rd-party API, surfacing a severity-scored breakdown so the Creator can self-correct.

**Acceptance Criteria:**

- [ ] **[CONFIRMED 2026-09-15, Trung]** Uses a 3rd-party API to check content, which returns a JSON payload with risk levels across categories (violence, copyright, etc.) — this resolves the prior open question; source/vendor selection is a technical decision made when implementing, not a business-scope gap anymore
- [ ] `POST /api/v1/workspaces/{id}/tasks/{taskId}/copyright-check` calls the 3rd-party API, returns `{matches: [{sourceUrl, similarityScore, severity}]}`
- [ ] Result renders into the SAME shared warning panel as DA-E51-11 (Compliance check) on the Creator's Task Detail screen — one unified risk-level display for the Creator, not a separate disconnected widget
- [ ] No matches found → `matches: []`, panel shows a "no issues found" state
- [ ] 3rd-party API failure returns 502 `COPYRIGHT_SERVICE_UNAVAILABLE`, retryable

**Technical Notes:** Same 3rd-party provider selection dependency as DA-E51-11 — evaluate whether one vendor can cover both compliance (violence/explicit/plagiarism) and copyright checks in a single API integration, since Trung's direction treats them as one unified panel.

**Spec Reference:** `docs/feature/content-task-workflow/3-6-34-check-copyright-infringement/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-04].

---

### DA-E51-13 — Collection `content_versions` (Content History) + No-double-charge Reuse

**Assignee:** Tuấn | **Priority:** 🟡 High

**Goal:** Track content version history per Workspace, and ensure reusing a previously-generated AI asset (e.g. an already-generated image applied to a different Post) does NOT deduct AI credit a second time.

**Acceptance Criteria:**

- [ ] `content_versions` collection: `id`, `workspaceId`, `type`, `createdBy`, `createdAt`, `reusedCount`
- [ ] `GET /api/v1/workspaces/{id}/content-history` lists version history with filters by type/creator
- [ ] Reusing an existing content/asset increments `reusedCount` but does NOT trigger a new `AiCreditLedger` deduction — verified by asserting the ledger balance is unchanged on reuse
- [ ] Soft-deleted content that was previously reused still appears in reuse history (not hidden just because the source was deleted)

**Spec Reference:** `docs/feature/content-task-workflow/3-6-35-view-content-history/spec.md`, `docs/ba/08-subscription-billing.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E17-07 (AiCreditLedger must exist to verify no-double-charge)].

---

### DA-E51-14 — Collection `posts` (V2 meaning: only successfully-published content)

**Assignee:** Phước | **Priority:** 🟢 Medium

**Goal:** Redefine `posts` to hold ONLY content that has successfully published to a social platform — the result of a completed Task type=post, not a draft/working document (V1 `posts` conflated drafts and published content; V2 separates them: drafts live as `tasks`, only the publish result lands in `posts`).

**Acceptance Criteria:**

- [ ] `posts` collection entries are created ONLY as the output of a successful publish (from E52 publisher callback), never directly by a user action
- [ ] `posts` document links back to its originating `taskId` for traceability
- [ ] No `posts` document exists for a Task that has not yet published successfully

**Spec Reference:** `docs/ba/12-state-machines.md` mục 7 "Post — trạng thái Publish"

**Dependencies:** Blocks: [None]. Blocked by: [DA-E52-16 (publish callback must exist to create `posts` entries)].

---

### DA-E51-15 — Implement Realtime Chat (FR 3.6.36, task mới — chưa từng có trong plan)

**Assignee:** Lộc | **Priority:** 🟡 High

**Goal:** Give Creator/Client/Manager a realtime chat channel scoped to a Workspace (or a specific Task/Campaign, TBD at design time) for quick back-and-forth without leaving comments on every Task.

**Acceptance Criteria:**

- [ ] Realtime message delivery (WebSocket or equivalent) between Workspace members currently online
- [ ] Chat history persisted and retrievable on reconnect/page reload
- [ ] Message visibility scoped to Workspace members only — a user removed from the Workspace loses access to that Workspace's chat history going forward

**Technical Notes:** No prior implementation or spec detail exists for this FR (source CSV row has no elaboration beyond the title) — confirm real-time transport choice (WebSocket vs SSE vs 3rd-party like Pusher/Ably) and scope (Workspace-wide vs per-Task) with Trung before starting.

**Spec Reference:** `docs/Các FR của hệ thống  - Feature_Function Requirement.csv` FR 3.6.36 (chưa có `docs/feature/` spec riêng — cần viết trước khi code)

**Dependencies:** Blocks: [None]. Blocked by: [DA-E15-01].

---

## PHASE V2 — Publishing & Social (E52, đã audit `brandhub-publisher-service` trên `origin/develop`)

> Adapter FB/IG/TikTok/Threads + RabbitMQ consumer đã xong (xem Phần 1.5) — không lặp lại ở đây. Các task dưới đây là phần thật sự còn thiếu: OAuth, token refresh, callback, retry.

### DA-E52-01 — Implement Meta OAuth Flow (Facebook + Instagram)

**Assignee:** Phước | **Priority:** 🔴 Critical

**Goal:** Build the Facebook/Instagram OAuth consent → callback → token exchange flow that currently does not exist at all in `brandhub-publisher-service` — confirmed via code audit that today's only publish path uses a manually-pasted access token via `TestController`.

**Acceptance Criteria:**

- [ ] `GET /api/v1/social/facebook/connect` and `GET /api/v1/social/instagram/connect` redirect to Meta's OAuth consent screen with correct scopes
- [ ] `GET /api/v1/social/{platform}/callback?code=...` exchanges the code for an access token, creates/reactivates a `SocialAccount` record linked to the Client in the current Workspace
- [ ] OAuth failure or user cancellation redirects back to `/workspaces/:id/social-accounts` with an error message
- [ ] Reconnecting a previously-disconnected account reactivates the existing record (preserves old post history links) rather than creating a duplicate

**Technical Notes:** `CryptoUtils` (AES-256) already exists in `brandhub-publisher-service` — use it to encrypt the token before persisting; do not write new encryption code.

**Spec Reference:** `docs/feature/publishing-social/3-8-1-connect-social-account/spec.md`, `docs/feature/publishing-social/3-8-2-disconnect-account/spec.md`, `docs/ba/07-publishing-social-collaborator.md`

**Dependencies:** Blocks: [None]. Blocked by: [None].

---

### DA-E52-02 — Implement TikTok & Threads OAuth Flow + Token Status API

**Assignee:** Phước | **Priority:** 🔴 Critical

**Goal:** Same OAuth flow as DA-E52-01 but for TikTok for Business and Threads (via Meta Graph API), plus a dashboard endpoint showing each connected account's token status.

**Acceptance Criteria:**

- [ ] `GET /api/v1/social/tiktok/connect` + callback, using TikTok's Client Credentials-based OAuth flow
- [ ] `GET /api/v1/social/threads/connect` + callback, scope `threads_basic + threads_content_publish` via Meta Graph API
- [ ] `GET /api/v1/social/accounts/status` returns ACTIVE/EXPIRED/REVOKED for each connected account across all 4 platforms

**Spec Reference:** `docs/feature/publishing-social/3-8-1-connect-social-account/spec.md`, `docs/feature/publishing-social/3-8-2-disconnect-account/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E52-01 (shares token status endpoint pattern)].

---

### DA-E52-03 — Wire AES-256 Token Encryption into OAuth Flows

**Assignee:** Phước | **Priority:** 🟢 Medium

**Goal:** Confirm `CryptoUtils` (already implemented, confirmed via audit) is actually invoked on every token persisted by the new OAuth flows in DA-E52-01/02 — today it exists but nothing calls it, since OAuth itself doesn't exist yet.

**Acceptance Criteria:**

- [ ] Every access/refresh token written to the database passes through `CryptoUtils.encrypt()` before persisting
- [ ] Every token read for use in a publish call passes through `CryptoUtils.decrypt()`
- [ ] No plaintext token ever appears in logs (audit logging statements added during DA-E52-01/02 for this)

**Spec Reference:** `docs/ba/07-publishing-social-collaborator.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E52-01, DA-E52-02].

---

### DA-E52-04 — Implement Scheduled Token Refresh Job + Failure Alert

**Assignee:** Phước | **Priority:** 🟡 High

**Goal:** Add a `@Scheduled` job to proactively refresh tokens nearing expiry — confirmed via audit that no such scheduler exists anywhere in `brandhub-publisher-service` today.

**Acceptance Criteria:**

- [ ] Scheduled job runs daily, refreshes tokens expiring within the next 7 days
- [ ] On refresh success, token is re-encrypted and persisted, `status` remains ACTIVE
- [ ] On refresh failure, `status` transitions to EXPIRED and a notification is sent to the Workspace's Account Manager
- [ ] Manual refresh endpoint also available for on-demand triggering (Account Manager-initiated)

**Spec Reference:** `docs/ba/07-publishing-social-collaborator.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E52-01, DA-E52-02].

---

### DA-E52-05 — Implement Publish Callback Webhook (business-service ← publisher-service)

**Assignee:** Phước | **Priority:** 🔴 Critical

**Goal:** Add a real callback path so `business-service` learns the actual publish outcome from `publisher-service` — confirmed via audit that today only internal nack/DLQ routing exists, with no webhook/callback that updates a Post's status back in `business-service`.

**Acceptance Criteria:**

- [ ] `publisher-service` calls `POST /internal/posts/{id}/publish-result` on `business-service` after each publish attempt (success or failure), with `{status, platformPostId?, errorReason?}`
- [ ] `business-service` updates the corresponding `posts`/Task status per `docs/ba/12-state-machines.md` mục 7 (`PENDING → IN_PROGRESS → DONE` or `FAIL`)
- [ ] A successful callback creates the `posts` collection entry (DA-E51-14)
- [ ] Callback endpoint validated as internal-only (not public-facing) — same protection pattern as other `/internal/*` endpoints in E23

**Spec Reference:** `docs/feature/publishing-social/3-8-4-view-post-track-detail/spec.md`, `docs/feature/publishing-social/3-8-8-view-status-tracking/spec.md`, `docs/ba/12-state-machines.md` mục 7

**Dependencies:** Blocks: [DA-E51-14]. Blocked by: [None].

---

### DA-E52-06 — Implement Retry Logic with Exponential Backoff

**Assignee:** Phước | **Priority:** 🟡 High

**Goal:** Extend the existing nack→DLQ mechanism with actual retry attempts (not just a single nack-and-give-up), using exponential backoff, before a job is considered permanently failed.

**Acceptance Criteria:**

- [ ] Failed publish attempts are retried up to 3 times with exponential backoff (e.g. 30s, 60s, 120s — exact intervals per technical design)
- [ ] Only after exhausting retries does the message route to DLQ (current behavior stops after the first nack)
- [ ] Retry count is tracked per job and visible for debugging

**Technical Notes:** `PublishJobConsumer` already has the nack→DLQ mechanism (confirmed via audit) — this task adds a retry counter and delay logic in front of the existing DLQ routing, not a rewrite.

**Spec Reference:** `docs/architecture/rabbitmq-publisher-contract.html`

**Dependencies:** Blocks: [None]. Blocked by: [None].

---

### DA-E52-07 — Implement Dashboard Post View + Track Detail (reactions/comments/shares)

**Assignee:** Phước | **Priority:** 🟡 High

**Goal:** Let Members view published post performance (reaction/comment/share counts) and a dashboard listing of all published posts for a Workspace.

**Acceptance Criteria:**

- [ ] `GET /api/v1/workspaces/{id}/posts/{postId}` returns `{platformPostUrl, reactionCount, commentCount, shareCount}`
- [ ] Post not found / not yet published returns 404 `POST_NOT_FOUND`
- [ ] Platform API rate-limiting on real-time engagement fetch is handled by caching last-fetched numbers with a "last updated" timestamp
- [ ] Dashboard post list (FR 3.8.3), comment detail list (FR 3.8.5), schedule (3.8.7), preview (3.8.6) included in this task's scope

**Spec Reference:** `docs/feature/publishing-social/3-8-3-view-dashboard-post/spec.md`, `docs/feature/publishing-social/3-8-4-view-post-track-detail/spec.md`, `docs/feature/publishing-social/3-8-5-view-comment-detail-list/spec.md`, `docs/feature/publishing-social/3-8-6-preview-post/spec.md`, `docs/feature/publishing-social/3-8-7-schedule-platform-post/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E52-05].

---

### DA-E52-08 — Implement View Status Tracking (PENDING/IN_PROGRESS/DONE/FAIL)

**Assignee:** Phước | **Priority:** 🟢 Medium

**Goal:** Expose a simple status-tracking endpoint so Members can see at a glance whether a post succeeded, is in progress, or failed.

**Acceptance Criteria:**

- [ ] `GET /api/v1/workspaces/{id}/posts/{postId}/status` returns `{status, failReason?}`
- [ ] Status values exactly match `docs/ba/12-state-machines.md` mục 7: `PENDING → IN_PROGRESS → DONE` or `FAIL`
- [ ] `FAIL` status includes a human-readable `failReason`

**Spec Reference:** `docs/feature/publishing-social/3-8-8-view-status-tracking/spec.md`, `docs/ba/12-state-machines.md` mục 7

**Dependencies:** Blocks: [None]. Blocked by: [DA-E52-05].

---

## PHASE V2 — Analytics, Notification & Admin (E53, đã audit backend `business-service` + frontend `web-dashboard`, 2026-09-15)

> Xem cảnh báo mismatch Backend/Frontend ở Phần 1.5 — frontend UI cho các trang này đã dựng sẵn (mock service), việc thật là Backend API + đổi service layer.

### DA-E53-01 — Implement Analytics Aggregation API (FR 3.10.2, 3.10.11)

**Assignee:** Ân | **Priority:** 🔴 Critical

**Goal:** Aggregate data from Tasks/Posts/publish results into the platform statistics and revenue dashboards Admin needs — currently 0% backend, frontend `pages/analytics/` already renders against a mock service.

**Acceptance Criteria:**

- [ ] `GET /api/v1/admin/statistics/overview` returns user/agency/revenue counts and trend charts data
- [ ] `GET /api/v1/admin/revenue` returns revenue breakdown from Plan + Credit purchases (`docs/feature/admin-management/3-10-11-view-revenue-dasboard/spec.md`)
- [ ] Aggregation must read from the V2 Task/Post/Transaction collections (E51/E17), not the old V1 shape

**Technical Notes:** This depends on E50/E51/E17 having real data to aggregate — do not start until those write paths exist, or the aggregation will have nothing to query against.

**Spec Reference:** `docs/feature/admin-management/3-10-2-platform-statistics-overview/spec.md`, `docs/feature/admin-management/3-10-11-view-revenue-dasboard/spec.md`

**Dependencies:** Blocks: [DA-E53-03]. Blocked by: [DA-E51-01, DA-E17-06].

---

### DA-E53-02 — Implement Report Generation (PDF/Email, FR 3.10.12)

**Assignee:** Ân | **Priority:** 🟡 High

**Goal:** Export the User/Revenue/Analytics management pages as a PDF report, and optionally email it on a schedule.

**Acceptance Criteria:**

- [ ] `POST /api/v1/admin/reports/export` accepts `{reportType: users|revenue|analytics}`, returns a generated PDF file
- [ ] Empty dataset still generates a valid (empty-state) PDF, not an error

**Spec Reference:** `docs/feature/admin-management/3-10-12-export-report-file-pdf/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E53-01].

---

### DA-E53-03 — Frontend: Replace `mockAnalyticsService.ts` with Real API

**Assignee:** Ân | **Priority:** 🟢 Medium

**Goal:** Swap the existing `pages/analytics/` UI's mock data source for the real DA-E53-01/02 endpoints — no new UI work, per the audit finding that frontend is already built.

**Acceptance Criteria:**

- [ ] `mockAnalyticsService.ts` calls replaced with real HTTP calls to DA-E53-01/02 endpoints
- [ ] All existing analytics UI states (loading/empty/error) still render correctly against real API responses

**Spec Reference:** (theo cùng spec DA-E53-01/02)

**Dependencies:** Blocks: [None]. Blocked by: [DA-E53-01, DA-E53-02].

---

### DA-E53-04 — Implement Notification CRUD + Event-triggered Creation (FR 3.10.1)

**Assignee:** Ân | **Priority:** 🟡 High

**Goal:** Build the Notification backend — currently 0% code — that creates notifications when system events fire (post published, task assigned, invite sent, etc.) and lets Admin/Owner push system-wide announcements, segmented by user group.

**Acceptance Criteria:**

- [ ] `POST /api/v1/admin/notifications/broadcast` accepts `{title, body, targetSegment}` — ADMIN/OWNER only
- [ ] `GET /api/v1/notifications` (per-user) and `PUT /api/v1/notifications/{id}/read` exist for the notification bell UI
- [ ] Notification auto-created on at minimum: Task assigned (DA-E51-04), Package/Campaign approval needed (DA-E50-05/07), publish result (DA-E52-05)

**Technical Notes:** Frontend already has `notificationStore.ts` + bell UI wired to a mock — this task is purely the missing backend.

**Spec Reference:** `docs/feature/admin-management/3-10-1-push-notification/spec.md`

**Dependencies:** Blocks: [DA-E53-05]. Blocked by: [None].

---

### DA-E53-05 — Frontend: Replace `mockNotificationService.ts` with Real API

**Assignee:** Ân | **Priority:** 🟢 Medium

**Goal:** Swap the notification bell UI's mock data source for the real DA-E53-04 endpoints.

**Acceptance Criteria:**

- [ ] `mockNotificationService.ts` calls replaced with real HTTP/WebSocket calls to DA-E53-04 endpoints
- [ ] Unread badge count reflects real unread notifications, not mock data

**Spec Reference:** `docs/feature/admin-management/3-10-1-push-notification/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E53-04].

---

### DA-E53-06 — Implement System Health Monitoring (FR 3.10.3)

**Assignee:** Tuấn | **Priority:** 🟡 High

**Goal:** Give Admin a real-time view of each microservice's resource usage (%CPU, %RAM) and liveness — frontend `SystemHealthPanel.tsx` already exists, waiting on this backend.

**Acceptance Criteria:**

- [ ] `GET /api/v1/admin/system-health` returns per-service CPU%/RAM% and up/down status for business-service, ai-service, publisher-service, api-gateway
- [ ] A service that fails to respond within timeout is reported as `down`, not left hanging

**Spec Reference:** `docs/feature/admin-management/3-10-3-system-health-monitoring/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [None].

---

### DA-E53-07 — Implement Content Moderation Queue (FR 3.10.4)

**Assignee:** Ân | **Priority:** 🟡 High

**Goal:** Show Admin the Task content flagged by the system's moderation policy (DA-E51-11/12 compliance/copyright checks) so Admin can confirm or override the automated decision — frontend `ModerationQueueList.tsx` already exists.

**Acceptance Criteria:**

- [ ] `GET /api/v1/admin/moderation-queue` lists Tasks with severe compliance/copyright violations (per DA-E51-11's auto-enqueue rule)
- [ ] `POST /api/v1/admin/moderation-queue/{taskId}/resolve` accepts `{decision: confirm|override, note?}`

**Spec Reference:** `docs/feature/admin-management/3-10-4-content-moderation-queue/spec.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E51-11, DA-E51-12].

---

### DA-E53-08 — Implement User Management: View/Create/Update User (FR 3.10.6/7/8)

**Assignee:** Ân | **Priority:** 🟡 High

**Goal:** Extend `AdminController` (currently only `GET /users`, `PUT /users/{id}/ban`) with full user list/create/update endpoints.

**Acceptance Criteria:**

- [ ] `GET /api/v1/admin/users` lists all users with pagination/filter
- [ ] `POST /api/v1/admin/users` creates a new user directly (Admin-initiated, no signup flow)
- [ ] `PATCH /api/v1/admin/users/{id}` updates user profile fields

**Spec Reference:** `docs/feature/admin-management/3-10-6-view-user/spec.md`, `3-10-7-create-user`, `3-10-8-update-user`

**Dependencies:** Blocks: [None]. Blocked by: [None].

---

### DA-E53-09 — Implement User Verify/Disable/Deactivate (FR 3.10.5, 3.10.9)

**Assignee:** Ân | **Priority:** 🟡 High

**Goal:** Let Admin change a user's account state (verify/disable/deactivate) as one consolidated status-transition endpoint, per BA's explicit choice to avoid splitting this into many separate FRs.

**Acceptance Criteria:**

- [ ] `PATCH /api/v1/admin/users/{id}/status` accepts `{status: verified|disabled|deactivated}`
- [ ] Deactivating a user immediately revokes active sessions/tokens

**Technical Notes:** [OPEN QUESTION] Whether an Admin can deactivate another Admin (FR 3.10.9) is unconfirmed — resolve with Trung before finalizing the permission check, do not guess.

**Spec Reference:** `docs/feature/admin-management/3-10-5-user-management-verifydisabledelete/spec.md`, `docs/feature/admin-management/3-10-9-deactive-user/spec.md`, `docs/ba/09-admin-management.md`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E53-08].

---

### DA-E53-10 — Frontend: Replace `mockAdminService.ts` with Real API

**Assignee:** Ân | **Priority:** 🟢 Medium

**Goal:** Swap the Admin pages' mock data source for the real DA-E53-06/07/08/09 endpoints.

**Acceptance Criteria:**

- [ ] `mockAdminService.ts` calls replaced with real HTTP calls to the corresponding DA-E53-06/07/08/09 endpoints
- [ ] All existing Admin UI states (loading/empty/error/permission-denied) still render correctly against real API responses

**Spec Reference:** (theo cùng spec DA-E53-06/07/08/09)

**Dependencies:** Blocks: [None]. Blocked by: [DA-E53-06, DA-E53-07, DA-E53-08, DA-E53-09].

---

## Phase 5–7 — Content Workflow, Frontend, Mobile, Testing, Deployment (Sprints 10–16)

---

### DA-E28-01 — Implement POST /api/v1/content-requests

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow CLIENT to submit a new content request with topic, platform, tone, deadline, and clientId, creating the request in SUBMITTED status.

**Acceptance Criteria:**

- [ ] POST /api/v1/content-requests accepts `{topic, platform, tone, deadline, clientId}` and returns 201 with the created request body
- [ ] Request is persisted with status SUBMITTED and createdBy set to authenticated user's ID
- [ ] Returns 400 if required fields are missing or deadline is in the past
- [ ] Returns 403 if caller does not have CLIENT role
- [ ] clientId in payload is validated to match the authenticated user's associated client (no cross-client injection)

**Technical Notes:**

- Validate `platform` against enum (FB, IG, TIKTOK, THREADS, ZALO)
- `deadline` should be stored as UTC ISO-8601; reject if `deadline < now + 1h`
- Use `@PreAuthorize("hasRole('CLIENT')")` on the controller method

**Dependencies:** Blocks: [DA-E28-02, DA-E28-03, DA-E29-01]. Blocked by: [None].

---

### DA-E28-02 — Implement GET /api/v1/content-requests

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow MANAGER to list all content requests from their assigned clients with filtering by status and platform.

**Acceptance Criteria:**

- [ ] GET /api/v1/content-requests returns paginated list scoped to clients assigned to the authenticated MANAGER
- [ ] Supports query params `?status=&platform=&page=&size=` and returns correct filtered results
- [ ] Returns 200 with empty list (not 404) when no requests match filters
- [ ] CLIENT calling the same endpoint sees only their own clientId's requests
- [ ] Response includes `totalElements`, `totalPages`, `content[]` envelope

**Technical Notes:**

- Use MongoDB query with `$and` on `clientId IN [assignedClientIds]` + optional status/platform filters
- Pull assigned clientIds from workspace membership data; cache if needed to avoid N+1 lookups
- Paginate with Spring Data's `Pageable`

**Dependencies:** Blocks: [DA-E36-01]. Blocked by: [DA-E28-01].

---


### DA-E29-01 — Implement PUT /api/v1/content-requests/{id}/assign

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow MANAGER to assign a content request to a CREATOR and transition status to ASSIGNED.

**Acceptance Criteria:**

- [ ] PUT /api/v1/content-requests/{id}/assign with body `{assigneeId}` sets `assigneeId` on the request and transitions status SUBMITTED→ASSIGNED
- [ ] Returns 404 if content request ID does not exist
- [ ] Returns 400 if assigneeId does not correspond to a CREATOR in the same workspace
- [ ] Returns 403 if caller is not MANAGER
- [ ] A notification is created for the assigned CREATOR (event: task_assigned)

**Technical Notes:**

- Validate that `assigneeId` has role CREATOR and belongs to the same workspaceId as the request
- Trigger notification via `NotificationService.createTaskAssignedNotification(assigneeId, requestId)`
- Reuse state machine from DA-E28-03 to perform the SUBMITTED→ASSIGNED transition

**Dependencies:** Blocks: [DA-E29-02]. Blocked by: [DA-E28-03].

---

### DA-E29-02 — Implement GET /api/v1/content-requests/my-tasks

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow CREATOR to view all tasks assigned to them with optional filtering by status.

**Acceptance Criteria:**

- [ ] GET /api/v1/content-requests/my-tasks returns paginated list where `assigneeId` equals authenticated user's ID
- [ ] Supports `?status=&page=&size=` query params
- [ ] Returns 403 if caller is not CREATOR
- [ ] Each item includes `deadline`, `platform`, `topic`, `status`, `contentRequestId`
- [ ] Results are sorted by `deadline ASC` by default

**Technical Notes:**

- Filter by `assigneeId = currentUserId` at the repository layer; do not expose other users' tasks
- Add composite MongoDB index on `{assigneeId, status}` for query performance

**Dependencies:** Blocks: [DA-E36-01]. Blocked by: [DA-E29-01].

---

### DA-E29-03 — Implement deadline alert notification

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Automatically notify CREATOR when a task deadline is within 24 hours to prevent missed deadlines.

**Acceptance Criteria:**

- [ ] A scheduled job runs every 15 minutes and queries content requests with `deadline BETWEEN now AND now+24h` and status not in (APPROVED, REJECTED)
- [ ] A notification with event type `deadline_24h` is created for the assigned CREATOR if not already notified
- [ ] Each request triggers at most one `deadline_24h` notification (idempotent — check `notifiedDeadline24h` flag on the document)
- [ ] Notification message includes task topic and exact deadline datetime
- [ ] If FCM token exists for the user, a push notification is also sent

**Technical Notes:**

- Use `@Scheduled(fixedDelay = 900000)` in a `DeadlineAlertScheduler` component
- Store `notifiedDeadline24h: boolean` on ContentRequest document to prevent duplicate alerts
- Query: `deadline <= now+24h AND deadline >= now AND notifiedDeadline24h = false AND status NOT IN [APPROVED, REJECTED]`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E29-01, DA-E39-02].

---

### DA-E30-01 — Implement GET /api/v1/posts/calendar

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Provide a date-range query endpoint for posts so the calendar UI can efficiently load scheduled and published posts within a given window.

**Acceptance Criteria:**

- [ ] GET /api/v1/posts/calendar?startDate=&endDate=&platform=&status= returns all matching posts within the date range
- [ ] `startDate` and `endDate` are ISO-8601 dates; missing either returns 400
- [ ] Scoped to the authenticated user's workspaceId (MANAGER sees all workspace posts; CREATOR sees own assigned posts; CLIENT sees own clientId's posts)
- [ ] Response includes `postId`, `title`, `scheduledAt`, `platform`, `status`, `thumbnailUrl` per post
- [ ] Maximum date range is 90 days; request exceeding this returns 400

**Technical Notes:**

- MongoDB index on `{workspaceId, scheduledAt}` is required for performance
- Use `@DateTimeFormat(iso = ISO.DATE)` on query params and convert to `LocalDate` then to UTC range `[startOfDay, endOfDay]`

**Dependencies:** Blocks: [DA-E30-03]. Blocked by: [None].

---

### DA-E30-02 — Implement POST /api/v1/posts/{id}/schedule

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow MANAGER to set a publish time for an approved post and enqueue it to RabbitMQ for delayed delivery.

**Acceptance Criteria:**

- [ ] POST /api/v1/posts/{id}/schedule with body `{scheduledAt, targetPlatforms[]}` transitions post status to SCHEDULED
- [ ] Message is published to `delayed_message_exchange` with `x-delay` header set to `scheduledAt - now` in milliseconds
- [ ] Returns 400 if `scheduledAt` is in the past or `targetPlatforms` is empty
- [ ] Returns 409 if post status is not APPROVED (cannot schedule unapproved content)
- [ ] Post document is updated with `scheduledAt` and `targetPlatforms` fields

**Technical Notes:**

- Requires `rabbitmq_delayed_message_exchange` plugin enabled on the broker
- Declare exchange as `x-delayed-message` type with `x-delayed-type: direct`
- Message payload: `PublishJobMessage {postId, workspaceId, targetPlatforms, scheduledAt}`
- Store `scheduledAt` in UTC; convert from client's local time if `timezone` param provided

**Dependencies:** Blocks: [DA-E32-01]. Blocked by: [DA-E31-03].

---

### DA-E30-03 — Build ContentCalendar React component

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Deliver an interactive monthly/weekly content calendar that visually represents post schedules and allows drag-and-drop rescheduling.

**Acceptance Criteria:**

- [ ] Calendar renders in both monthly and weekly view modes with a toggle
- [ ] Each post appears as a colored chip on its `scheduledAt` date, color-coded by status (SCHEDULED=blue, PUBLISHED=green, FAILED=red, PENDING_REVIEW=yellow)
- [ ] Dragging a post chip to a new date calls PATCH /api/v1/posts/{id}/reschedule with the new datetime
- [ ] Clicking a post chip opens a detail side-panel with post preview and action buttons
- [ ] Supports platform filter (checkbox group: FB, IG, TikTok, Threads)
- [ ] Loading state shown while fetching; error toast on API failure

**Technical Notes:**

- Use `react-big-calendar` with `moment` or `date-fns` localizer, or `FullCalendar` with `@fullcalendar/react`
- Fetch posts via GET /api/v1/posts/calendar with visible date range as `startDate`/`endDate` params; refetch on view change
- Implement drag-and-drop via the calendar library's built-in `onEventDrop` callback

**Dependencies:** Blocks: [DA-E36-03]. Blocked by: [DA-E30-01].

---

### DA-E30-04 — Build PlatformPreview component

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Provide accurate per-platform post previews so creators and clients can visualize how a post will appear before publishing.

**Acceptance Criteria:**

- [ ] Facebook preview renders at 1200×630 aspect ratio with profile avatar, page name, caption, and image
- [ ] Instagram preview renders as 1080×1080 square card with username, square-cropped image, and caption
- [ ] TikTok preview renders in 9:16 vertical orientation with overlay username and caption at the bottom
- [ ] Threads preview renders as text-first layout with 500 character limit indicator
- [ ] Switching platform tab instantly updates the preview without re-fetching data
- [ ] Caption is truncated with "See more" at platform-appropriate character limits (FB: 63,206; IG: 2,200; TikTok: 2,200; Threads: 500)

**Technical Notes:**

- Implement as a tabbed modal: `<Tabs>` with one tab per platform
- Use CSS aspect-ratio property rather than fixed pixel dimensions to maintain responsiveness
- Character count warning at 80% and error styling at 100% of platform limit

**Dependencies:** Blocks: [DA-E36-04, DA-E37-03]. Blocked by: [None].

---

### DA-E31-01 — Implement POST /api/v1/posts/{id}/submit

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow CREATOR to submit a drafted post for internal review, triggering a MANAGER notification.

**Acceptance Criteria:**

- [ ] POST /api/v1/posts/{id}/submit transitions post status DRAFT→PENDING_REVIEW
- [ ] Returns 403 if caller is not the assigned CREATOR for this post
- [ ] Returns 409 if post status is not DRAFT
- [ ] A notification of type `post_submitted` is created for the MANAGER responsible for the linked content request
- [ ] Response returns updated post object with new status and `submittedAt` timestamp

**Technical Notes:**

- Resolve the responsible MANAGER via `ContentRequest.accountManagerId` linked to the post
- Set `submittedAt = now()` on the Post document upon successful transition

**Dependencies:** Blocks: [DA-E31-02]. Blocked by: [DA-E28-03].

---

### DA-E31-02 — Implement POST /api/v1/posts/{id}/account-review

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow MANAGER to approve a post for client review or reject it back to draft with a feedback note.

**Acceptance Criteria:**

- [ ] POST /api/v1/posts/{id}/account-review with body `{decision: "APPROVE"|"REJECT", note?: string}`
- [ ] APPROVE transitions status PENDING_REVIEW→SENT_TO_CLIENT and creates `post_sent_to_client` notification for CLIENT
- [ ] REJECT transitions status PENDING_REVIEW→DRAFT and stores `rejectionNote` on the post document
- [ ] Returns 403 if caller is not MANAGER in the same workspace
- [ ] Returns 409 if post status is not PENDING_REVIEW

**Technical Notes:**

- `note` is required when `decision = REJECT`; return 400 if missing
- Notification to CLIENT should include post title and a link to the approval page

**Dependencies:** Blocks: [DA-E31-03, DA-E31-04]. Blocked by: [DA-E31-01].

---

### DA-E31-03 — Implement POST /api/v1/posts/{id}/client-approve

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow CLIENT to approve a post for scheduling, which triggers the scheduling pipeline automatically.

**Acceptance Criteria:**

- [ ] POST /api/v1/posts/{id}/client-approve transitions status SENT_TO_CLIENT→SCHEDULED
- [ ] Returns 403 if caller's clientId does not match the post's clientId
- [ ] Returns 409 if post status is not SENT_TO_CLIENT
- [ ] Upon approval, if `scheduledAt` is already set, a `PublishJobMessage` is enqueued to RabbitMQ delayed exchange immediately
- [ ] If `scheduledAt` is not set, status becomes APPROVED (pending manual scheduling by MANAGER)
- [ ] Response includes updated post with `approvedAt` timestamp

**Technical Notes:**

- Reuse the same RabbitMQ enqueue logic from DA-E30-02 to avoid duplication
- Emit a `client_approved` internal event so MANAGER is notified

**Dependencies:** Blocks: [DA-E32-01]. Blocked by: [DA-E31-02].

---

### DA-E31-04 — Implement POST /api/v1/posts/{id}/client-reject

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow CLIENT to reject a post with written feedback, returning it to DRAFT status for revision.

**Acceptance Criteria:**

- [ ] POST /api/v1/posts/{id}/client-reject with body `{feedback: string}` transitions status SENT_TO_CLIENT→DRAFT
- [ ] `feedback` field is required; returns 400 if empty or missing
- [ ] Returns 403 if caller's clientId does not match the post's clientId
- [ ] Returns 409 if post status is not SENT_TO_CLIENT
- [ ] `clientFeedback` is stored on the post document and is visible to CREATOR in the editor
- [ ] A notification is created for MANAGER and CREATOR with the rejection feedback

**Technical Notes:**

- Store feedback in `post.clientFeedback: {text, rejectedAt, rejectedBy}`
- Display `clientFeedback` prominently at the top of the Content Editor page when present

**Dependencies:** Blocks: [None]. Blocked by: [DA-E31-02].

---

### DA-E32-01 — Implement Smart Ingestion (PublishJobMessage packaging)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Package a post's content, decrypted social token, and platform config into a `PublishJobMessage` and enqueue it to RabbitMQ for publisher-service consumption.

**Acceptance Criteria:**

- [ ] `PublishJobMessage` includes `{postId, workspaceId, platform, caption, mediaUrls[], decryptedAccessToken, platformConfig{pageId, accountId}, scheduledAt}`
- [ ] AES-256 token is decrypted using the workspace's encryption key before packaging (never stored decrypted)
- [ ] Message is published to `brandhub.publish.delayed` exchange with correct `x-delay` header
- [ ] If AES decryption fails (bad key/corrupted token), the post status is set to FAILED and an error notification is created
- [ ] A `publishJobId` UUID is stored on the post document for correlation with callback results

**Technical Notes:**

- AES key must be fetched from environment/Vault, never from the database
- Use `RabbitTemplate.convertAndSend(exchange, routingKey, message, m -> { m.getMessageProperties().setHeader("x-delay", delay); return m; })`
- Serialize `PublishJobMessage` as JSON; use `@JsonProperty` for all fields

**Dependencies:** Blocks: [DA-E32-02]. Blocked by: [DA-E30-02, DA-E31-03].

---

### DA-E32-02 — Implement RabbitMQ consumer in publisher-service

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Consume `PublishJobMessage` messages from RabbitMQ with FIFO ordering, exactly-once semantics via Redis, and manual acknowledgment.

**Acceptance Criteria:**

- [ ] Consumer uses `@RabbitListener` with `acknowledgeMode = MANUAL` and processes one message at a time (`prefetchCount = 1`)
- [ ] Before processing, checks Redis set `processingPostIds`; if postId already present, NACK and discard (duplicate detection)
- [ ] Adds postId to Redis with TTL of 24h at start of processing; removes on success or permanent failure
- [ ] Routes message to the correct platform adapter based on `platform` field
- [ ] On success, calls HTTP callback DA-E32-08; on failure, increments retry count and requeues or sends to DLQ

**Technical Notes:**

- Use `channel.basicAck(tag, false)` on success and `channel.basicNack(tag, false, false)` to send to DLQ after max retries
- Redis key: `publish:processing:{postId}` with `SETNX` for atomic check-and-set
- Consumer must be single-threaded per queue to guarantee FIFO; set `concurrency = 1` on listener container

**Dependencies:** Blocks: [DA-E32-03, DA-E32-04, DA-E32-05, DA-E32-06]. Blocked by: [DA-E32-01].

---

### DA-E32-03 — Implement Facebook adapter

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Publish text, image, and video (Reels) posts to Facebook via Graph API v19 using the workspace's connected page token.

**Acceptance Criteria:**

- [ ] Text-only posts use POST `/{pageId}/feed` with `{message, access_token}`
- [ ] Image posts use POST `/{pageId}/photos` with `{url, caption, access_token}`
- [ ] Video/Reels posts use the resumable upload flow: POST `/video/uploads` → upload chunks → POST `/{pageId}/videos` to publish
- [ ] On API success, returns `{platformPostId, postUrl}` to the consumer
- [ ] On API error, throws `PlatformPublishException` with the Graph API error code and message for retry logic

**Technical Notes:**

- Graph API version must be pinned to v19.0 in the base URL: `https://graph.facebook.com/v19.0`
- Handle token expiry (error code 190) as a non-retryable error; notify MANAGER to reconnect
- Use `RestTemplate` or `WebClient` with a 30s connect timeout and 60s read timeout

**Dependencies:** Blocks: [DA-E42-05]. Blocked by: [DA-E32-02].

---

### DA-E32-04 — Implement Instagram adapter

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Publish image and video posts to Instagram Business accounts via the two-step Content Publishing API.

**Acceptance Criteria:**

- [ ] Step 1: POST `/{igUserId}/media` with `{image_url|video_url, caption, media_type}` → returns `creationId`
- [ ] Step 2: POST `/{igUserId}/media_publish` with `{creation_id}` → returns `igMediaId`
- [ ] For videos, polls `GET /{creationId}?fields=status_code` until `FINISHED` before publishing (max 10 polls, 10s apart)
- [ ] On success, returns `{platformPostId: igMediaId, postUrl: "https://instagram.com/p/{shortcode}"}`
- [ ] Enforces 2,200 character caption limit; truncates with ellipsis if exceeded

**Technical Notes:**

- `media_type` values: `IMAGE`, `VIDEO`, `REELS`, `CAROUSEL`
- Video polling timeout after 100s total should be treated as a soft failure with requeue
- Instagram requires media to be publicly accessible via URL at the time of container creation; ensure S3 URLs are not pre-signed

**Dependencies:** Blocks: [DA-E42-05]. Blocked by: [DA-E32-02].

---

### DA-E32-05 — Implement TikTok adapter

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Publish videos to TikTok using Direct Post API for short videos and Creator Upload API for longer content.

**Acceptance Criteria:**

- [ ] Videos ≤60s use Direct Post API: POST `/v2/post/publish/video/init/` with `{post_info, source_info}` → upload → confirm
- [ ] Videos >60s use Creator Upload API: POST `/v2/post/publish/creator/inbox/` for draft upload flow
- [ ] Polls publish status via GET `/v2/post/publish/status/fetch/` until `PUBLISH_COMPLETE` or `FAILED`
- [ ] Returns `{platformPostId, shareUrl}` on success
- [ ] Enforces TikTok privacy settings from workspace config (`privacy_level`: PUBLIC_TO_EVERYONE, MUTUAL_FOLLOW_FRIENDS, etc.)

**Technical Notes:**

- TikTok API requires `Content-Type: video/mp4` chunked upload with chunk size 10MB
- Access token scope must include `video.upload` and `video.publish`
- Rate limit: 100 publish requests per day per app; track and surface this limit

**Dependencies:** Blocks: [DA-E42-05]. Blocked by: [DA-E32-02].

---

### DA-E32-06 — Implement Threads adapter

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Publish text and image posts to Threads via the two-step container/publish flow with 500 character caption enforcement.

**Acceptance Criteria:**

- [ ] Step 1: POST `/{userId}/threads` with `{media_type, text, image_url?}` → returns `containerId`
- [ ] Step 2: POST `/{userId}/threads_publish` with `{creation_id: containerId}` → returns `threadId`
- [ ] Returns 400 (non-retryable) if caption exceeds 500 characters; does not attempt publish
- [ ] Returns `{platformPostId: threadId}` on success
- [ ] `media_type` TEXT for text-only, IMAGE for image posts; VIDEO not yet supported — reject with clear error

**Technical Notes:**

- Threads API base URL: `https://graph.threads.net/v1.0`
- Threads API uses the same Facebook access token for connected Instagram/Threads accounts
- Minimum delay of 30s between container creation and publish recommended per API docs

**Dependencies:** Blocks: [DA-E42-05]. Blocked by: [DA-E32-02].

---

### ~~DA-E32-07 — Implement Zalo OA adapter~~

> **Loại khỏi scope** (2026-09-03) — không tích hợp Zalo. Task đã xóa khỏi Jira (DA-361).

**Dependencies:** Blocks: [DA-E42-05]. Blocked by: [DA-E32-02].

---

### DA-E32-08 — Implement HTTP callback POST /internal/posts/{id}/publish-result

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Allow publisher-service to report publish outcome back to business-service so post status and platform metadata are updated.

**Acceptance Criteria:**

- [ ] POST /internal/posts/{id}/publish-result accepts `{status: "SUCCESS"|"FAILED", platformPostId?, errorMessage?}`
- [ ] On SUCCESS: updates post status to PUBLISHED, stores `platformPostId`, `publishedAt`, creates `post_published` notification for MANAGER
- [ ] On FAILED: updates post status to FAILED, stores `errorMessage`, creates `post_failed` notification for MANAGER
- [ ] Endpoint is protected by internal service secret header `X-Internal-Secret`; returns 401 if missing or wrong
- [ ] Returns 404 if postId does not exist

**Technical Notes:**

- `X-Internal-Secret` value configured via `INTERNAL_SECRET` env var on both services
- This endpoint must NOT be exposed through the public nginx proxy; restrict at nginx level with `deny all` for `/internal/`
- Consider adding `publishJobId` to the callback for correlation verification

**Dependencies:** Blocks: [DA-E33-01]. Blocked by: [DA-E32-03, DA-E32-04, DA-E32-05, DA-E32-06].

---

### DA-E33-01 — Implement retry logic

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Automatically retry failed publish attempts with exponential backoff before routing permanently failed messages to the Dead Letter Queue.

**Acceptance Criteria:**

- [ ] Failed messages are retried up to 3 times with delays: immediate retry → +30s → +60s → +120s
- [ ] Retry count is tracked in message header `x-retry-count`; incremented on each NACK
- [ ] After 3 retries, message is routed to `brandhub.publish.dlq` Dead Letter Queue
- [ ] Retry delays are implemented via the `delayed_message_exchange` with updated `x-delay` headers
- [ ] Non-retryable errors (token expired, caption too long, permission denied) skip retries and go directly to DLQ

**Technical Notes:**

- Distinguish retryable errors (network timeout, 5xx from platform) from non-retryable errors (4xx platform errors, decryption failure)
- DLQ message includes original payload plus `{failureReason, failedAt, retryCount}`
- Use a separate `brandhub.publish.dlq` queue bound to a direct exchange for DLQ

**Dependencies:** Blocks: [DA-E33-02]. Blocked by: [DA-E32-08].

---

### DA-E33-02 — Implement Dead Letter Queue admin API

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Provide ADMIN users with visibility into and control over failed publish jobs in the Dead Letter Queue.

**Acceptance Criteria:**

- [ ] GET /api/v1/admin/dlq returns paginated list of DLQ entries with `{id, postId, platform, failureReason, failedAt, retryCount}`
- [ ] POST /api/v1/admin/dlq/{id}/retry re-publishes the message to the main exchange with reset retry count
- [ ] DELETE /api/v1/admin/dlq/{id} permanently discards the DLQ entry
- [ ] All three endpoints are restricted to ADMIN role; return 403 otherwise
- [ ] DLQ entries are persisted to MongoDB `dlq_entries` collection (not only in RabbitMQ queue) for queryability

**Technical Notes:**

- Mirror DLQ messages to MongoDB in a `DlqConsumer` that reads from `brandhub.publish.dlq` queue
- Retry operation re-enqueues via `RabbitTemplate` with `x-retry-count: 0` header reset
- RabbitMQ management port (15672) must NOT be publicly exposed; all DLQ operations go through this API

**Dependencies:** Blocks: [DA-E43-01]. Blocked by: [DA-E33-01].

---

### DA-E33-03 — Implement failure notification

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Notify MANAGER when a post fails all retries so they can take corrective action promptly.

**Acceptance Criteria:**

- [ ] When a message enters DLQ, a `post_failed` notification is created for the MANAGER of the workspace
- [ ] Notification includes post title, target platform, and the final error message
- [ ] If MANAGER has an FCM token, a push notification is also dispatched
- [ ] Post status is updated to FAILED in the business-service via the DA-E32-08 callback
- [ ] Duplicate failure notifications for the same post are suppressed (check if `post_failed` notification already exists for this postId)

**Technical Notes:**

- Trigger from the DLQ consumer in publisher-service by calling the /internal/posts/{id}/publish-result callback with `status: FAILED`
- business-service handles notification creation in the callback handler to keep publisher-service decoupled from notification logic

**Dependencies:** Blocks: [None]. Blocked by: [DA-E33-01, DA-E32-08].

---

### DA-E34-01 — Set up shadcn/ui + Tailwind CSS + design tokens

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Establish the design system foundation with consistent color tokens, typography scale, and spacing so all UI components share a unified visual language.

**Acceptance Criteria:**

- [ ] shadcn/ui initialized in `web-dashboard` with Vite + TypeScript; `components.json` committed to repo
- [ ] Tailwind CSS configured with custom design tokens: primary (#3B82F6), secondary (#8B5CF6), success (#10B981), warning (#F59E0B), danger (#EF4444)
- [ ] Typography scale defined: font-family Inter, sizes xs/sm/base/lg/xl/2xl/3xl
- [ ] Dark mode support via Tailwind's `class` strategy with `ThemeProvider` wrapper
- [ ] `tailwind.config.ts` and `globals.css` with CSS custom properties committed and documented

**Technical Notes:**

- Run `npx shadcn-ui@latest init` and select TypeScript, Tailwind CSS variables style
- CSS variables in `:root` and `.dark` selectors for theming; map to Tailwind via `extend.colors`
- Add `prettier-plugin-tailwindcss` for class sorting consistency

**Dependencies:** Blocks: [DA-E34-02, DA-E34-03]. Blocked by: [None].

---

### DA-E34-02 — Build common UI components

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Deliver a library of reusable, typed UI primitives that all feature pages can compose without duplicating UI code.

**Acceptance Criteria:**

- [ ] Button: variants (primary, secondary, outline, ghost, danger), sizes (sm, md, lg), loading state with spinner, disabled state
- [ ] Input: label, placeholder, error message, icon prefix/suffix, controlled and uncontrolled modes
- [ ] Modal: backdrop, close button, title, body slot, footer slot, `onClose` callback, focus trap
- [ ] Toast: success/error/warning/info variants, auto-dismiss after 4s, `useToast()` hook
- [ ] Table: sortable columns, pagination controls, loading skeleton, empty state
- [ ] Badge, Spinner, Dropdown: each with correct TypeScript props interface exported
- [ ] All components have at least one usage example in a `/components/examples` page

**Technical Notes:**

- Extend shadcn/ui primitives (Button, Dialog, etc.) rather than building from scratch
- Export all components from `src/components/ui/index.ts` for clean imports
- Use `cva` (class-variance-authority) for variant management on Button and Badge

**Dependencies:** Blocks: [DA-E34-03, DA-E35-01]. Blocked by: [DA-E34-01].

---

### DA-E34-03 — Build layout components

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Deliver the app shell (sidebar, navbar, page wrapper) and route-level auth guard so all authenticated pages share a consistent layout and enforce role-based access.

**Acceptance Criteria:**

- [ ] Sidebar: collapsible (icon-only mode at <1280px), nav links grouped by section, active link highlighted, workspace selector dropdown
- [ ] Navbar: breadcrumb, notification bell (DA-E39-03), user avatar dropdown (profile, logout)
- [ ] PageWrapper: centers content, sets max-width, adds page title via `<title>` and `<h1>`
- [ ] AuthGuard: reads role from `authStore`; redirects OWNER → /workspace, CLIENT → /portal, ADMIN → /admin; unauthenticated → /login
- [ ] Layout is fully responsive: sidebar collapses to bottom tab bar on mobile ≤768px

**Technical Notes:**

- Use React Router v6 `<Outlet>` with `<AuthGuard>` as a layout route wrapper
- Sidebar collapse state persisted to `localStorage` so it survives page refresh
- Tailwind `lg:block hidden` pattern for desktop/mobile sidebar/tab-bar swap

**Dependencies:** Blocks: [DA-E35-01]. Blocked by: [DA-E34-02].

---

### DA-E34-04 — Set up Axios instance with interceptors

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Configure a singleton Axios instance that automatically attaches auth tokens and handles token refresh transparently so all API calls in the app are authenticated without per-call boilerplate.

**Acceptance Criteria:**

- [ ] Request interceptor attaches `Authorization: Bearer {token}` from `authStore` to every outgoing request
- [ ] Response interceptor catches 401, calls POST /api/v1/auth/refresh with the stored refresh token, retries the original request once with the new access token
- [ ] If the refresh call itself returns 401 or fails, `authStore.logout()` is called and user is redirected to /login
- [ ] Concurrent 401 responses during refresh are queued (not each triggering a parallel refresh); resolved when refresh completes
- [ ] All API calls in the app import from `src/lib/axios.ts` (not from `axios` directly)

**Technical Notes:**

- Implement request queue with a `isRefreshing` flag and `failedRequestsQueue[]` to handle concurrent 401s
- Use `axios.interceptors.response.use(null, errorHandler)` pattern
- Refresh token stored in `httpOnly` cookie (preferred) or `localStorage` as fallback; align with backend DA-E28-01 auth design

**Dependencies:** Blocks: [DA-E35-01]. Blocked by: [DA-E34-01].

---

### DA-E34-05 — Set up Zustand stores

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Establish centralized client-side state management for authentication, workspace context, and notifications using Zustand so components share state without prop drilling.

**Acceptance Criteria:**

- [ ] `authStore`: holds `{user, accessToken, refreshToken}`, actions `setUser`, `setTokens`, `logout` (clears all state), persisted to `localStorage` via `zustand/middleware/persist`
- [ ] `workspaceStore`: holds `{currentWorkspace, workspaceList}`, actions `setCurrentWorkspace`, `fetchWorkspaces`
- [ ] `notificationStore`: holds `{notifications[], unreadCount}`, actions `addNotification`, `markRead`, `markAllRead`
- [ ] `authStore.logout()` clears both auth and workspace store state atomically
- [ ] All stores are typed with TypeScript interfaces; no `any` types

**Technical Notes:**

- Use `zustand` v4 with `immer` middleware for immutable state updates in notificationStore
- Persist only `authStore`; `workspaceStore` and `notificationStore` refetch on mount
- Expose stores via custom hooks: `useAuthStore()`, `useWorkspaceStore()`, `useNotificationStore()`

**Dependencies:** Blocks: [DA-E34-03, DA-E34-04]. Blocked by: [DA-E34-01].

---

### DA-E35-01 — Build Login and Register pages

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Deliver the entry points for user authentication with email/password and Google OAuth, implementing proper validation and error handling.

**Acceptance Criteria:**

- [ ] Login page: email + password fields, form validation (email format, password ≥8 chars), submit calls POST /api/v1/auth/login, stores tokens in authStore, redirects by role
- [ ] Register page: name, email, password, confirm password fields; calls POST /api/v1/auth/register; shows success toast then redirects to login
- [ ] Google OAuth button initiates OAuth flow; on callback, exchanges code for tokens and stores in authStore
- [ ] API errors (wrong password, email already exists) shown as inline form error messages (not just toasts)
- [ ] Both pages redirect authenticated users away (if already logged in, skip to role-based landing page)

**Technical Notes:**

- Use `react-hook-form` + `zod` for form validation
- Google OAuth: redirect to `/api/v1/auth/google` which handles the server-side OAuth flow; frontend just opens the URL
- Show loading spinner on the submit button during API call; disable button to prevent double-submit

**Dependencies:** Blocks: [DA-E35-02]. Blocked by: [DA-E34-02, DA-E34-03, DA-E34-04, DA-E34-05].

---

### DA-E35-02 — Build main Dashboard page

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Deliver the post-login landing page with KPI cards and activity feed so users immediately see the health of their content operations.

**Acceptance Criteria:**

- [ ] KPI cards display: total posts this month, published count, failed count, success rate percentage — fetched from GET /api/v1/analytics/overview
- [ ] Recent activity feed shows last 10 events (post published, task assigned, etc.) with timestamp and actor name
- [ ] Team stats section shows per-member post counts (OWNER/MANAGER view only)
- [ ] All data loads asynchronously with skeleton loaders; errors shown as inline error states (not blank page)
- [ ] Dashboard is responsive: KPI cards stack to 2-column on tablet, 1-column on mobile

**Technical Notes:**

- Fetch analytics via GET /api/v1/analytics/overview; poll every 5 min or use WebSocket if available
- Activity feed sourced from GET /api/v1/notifications?type=activity&page=0&size=10
- Use `React.Suspense` or manual loading states per card to avoid full-page blocking

**Dependencies:** Blocks: [DA-E35-03]. Blocked by: [DA-E35-01, DA-E38-01].

---

### DA-E35-03 — Build Workspace management pages

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Allow OWNER to create and configure their workspace and manage team members through a dedicated settings UI.

**Acceptance Criteria:**

- [ ] Create Workspace page: name, subdomain, logo upload fields; calls POST /api/v1/workspaces; redirects to workspace settings on success
- [ ] Workspace Settings panel: edit name/logo, view subscription plan, danger zone (delete workspace)
- [ ] Member list table: shows name, email, role, joined date; supports search by name/email
- [ ] Invite member flow: email input + role selector → POST /api/v1/workspaces/{id}/invite → success toast
- [ ] Remove member: confirmation modal → DELETE /api/v1/workspaces/{id}/members/{userId}

**Technical Notes:**

- Logo upload uses POST /api/v1/media/upload → returns S3 URL → stored as `workspace.logoUrl`
- Role selector options filtered by caller's role (OWNER cannot invite another OWNER)
- Invitation email is handled server-side; frontend only needs to show success/failure state

**Dependencies:** Blocks: [DA-E35-04]. Blocked by: [DA-E35-01].

---

### DA-E35-04 — Build Client management pages

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Provide MANAGER and OWNER with CRUD pages for managing clients and their service packages.

**Acceptance Criteria:**

- [ ] Client list page: searchable table with client name, assigned manager, active posts count, service package, status badge
- [ ] Create/Edit client form: name, logo, contact email, assigned manager, service package (starter/growth/enterprise)
- [ ] Client detail page: client info, linked social accounts, current content requests, analytics summary
- [ ] Service package settings: select package tier, set post quota per month, expiry date
- [ ] Delete client: confirmation modal with warning that all associated data will be archived

**Technical Notes:**

- Client list uses GET /api/v1/clients with `?workspaceId=&page=&size=` and debounced search
- Service package changes call PATCH /api/v1/clients/{id}/package
- Optimistic UI update on edit: update local state immediately, roll back on API error with error toast

**Dependencies:** Blocks: [DA-E36-01]. Blocked by: [DA-E35-03].

---

### DA-E36-01 — Build Content Request list page

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Provide MANAGER and CREATOR with a filterable, paginated view of all content requests relevant to their role.

**Acceptance Criteria:**

- [ ] Table columns: topic, platform (icon), client name, deadline, status badge, assignee, actions
- [ ] Filter bar: status multi-select, platform multi-select, deadline date range picker
- [ ] Pagination: 20 rows per page, page controls at bottom
- [ ] MANAGER sees "Assign" button per row; clicking opens an assignee picker modal
- [ ] CREATOR sees "View My Tasks" tab that calls GET /api/v1/content-requests/my-tasks
- [ ] Clicking any row navigates to Content Editor page for that request

**Technical Notes:**

- Filter state stored in URL query params (using `useSearchParams`) so the view is bookmarkable and shareable
- Debounce filter changes by 300ms before firing API calls
- Status badges use the `Badge` component with color mapped to status: SUBMITTED=gray, ASSIGNED=blue, IN_PROGRESS=yellow, PENDING_REVIEW=orange, SENT_TO_CLIENT=purple, APPROVED=green, REJECTED=red

**Dependencies:** Blocks: [DA-E36-02]. Blocked by: [DA-E28-02, DA-E29-02, DA-E35-04].

---

### DA-E36-02 — Build Content Editor page with AI Generate Panel

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Deliver the primary content creation interface where CREATOR writes or AI-generates captions, selects hashtags, attaches media, and submits for review.

**Acceptance Criteria:**

- [ ] Left panel: rich text editor for caption (character count per platform), media uploader (drag-drop + browse), hashtag input with suggestions
- [ ] Right panel: AI Generate Panel — trigger button calls POST /api/v1/ai/generate, shows streaming response with loading skeleton, allows regeneration
- [ ] AI result auto-populates caption and hashtag fields; user can edit before saving
- [ ] Platform Preview button opens DA-E30-04 modal showing per-platform preview
- [ ] Submit for Review button calls POST /api/v1/posts/{id}/submit; shows success toast and redirects to request list
- [ ] Auto-save draft every 30s via PATCH /api/v1/posts/{id}; unsaved changes indicator in page header

**Technical Notes:**

- Use `@tiptap/react` for the rich text editor (bold, italic, emoji, link support)
- AI generate endpoint may take 5–15s; show animated placeholder text during wait; do not block the editor
- Media upload via POST /api/v1/media/upload with `multipart/form-data`; show upload progress bar

**Dependencies:** Blocks: [DA-E36-03]. Blocked by: [DA-E36-01].

---

### DA-E36-03 — Build Content Calendar page

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Provide a visual, interactive calendar for scheduling and managing posts across all platforms with drag-and-drop rescheduling.

**Acceptance Criteria:**

- [ ] Monthly and weekly views with toggle; default to monthly view
- [ ] Posts displayed as color-coded event chips (by status); hovering shows tooltip with caption preview
- [ ] Drag-and-drop a chip to new date calls PATCH /api/v1/posts/{id}/reschedule; optimistic update with rollback on failure
- [ ] "Schedule Post" button on each day cell opens a scheduling modal to set time and target platforms
- [ ] Platform filter chips above calendar (FB, IG, TikTok, Threads); toggling hides/shows that platform's posts
- [ ] Navigating months/weeks fetches new date range from GET /api/v1/posts/calendar

**Technical Notes:**

- Prefer `FullCalendar` (`@fullcalendar/react` + `@fullcalendar/daygrid` + `@fullcalendar/interaction`) for drag-drop support
- Each event object: `{id, title, start: scheduledAt, backgroundColor: statusColor, extendedProps: {platform, status}}`
- On drag-drop, call reschedule API before committing the calendar state change

**Dependencies:** Blocks: [DA-E37-02]. Blocked by: [DA-E30-03, DA-E36-02].

---

### DA-E36-04 — Build Platform Preview modal

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Give creators and clients a realistic visual mockup of how each post will appear on each social platform before publishing.

**Acceptance Criteria:**

- [ ] Modal has tabs for each target platform in the post's `targetPlatforms` array
- [ ] Each tab renders the platform-specific preview component from DA-E30-04 using the post's actual caption, media, and metadata
- [ ] Character count displayed per platform with red highlight if over limit
- [ ] Image shown cropped to the correct aspect ratio per platform (1200×630 for FB, 1:1 square for IG, 9:16 for TikTok)
- [ ] "Copy Caption" button per tab copies the caption to clipboard

**Technical Notes:**

- Reuse `PlatformPreview` component from DA-E30-04; this task only wraps it in a modal with tab routing
- Image cropping preview implemented with CSS `object-fit: cover` and explicit container aspect ratios — no server-side cropping needed for preview

**Dependencies:** Blocks: [None]. Blocked by: [DA-E30-04].

---

### DA-E36-05 — Build Content Library page

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Provide a centralized media and content asset browser so teams can reuse uploaded images, saved hashtag groups, and approved content templates.

**Acceptance Criteria:**

- [ ] Media tab: grid view of S3-hosted images/videos for the workspace; supports search by filename, filter by type (image/video), sort by date
- [ ] Hashtag Groups tab: create/edit/delete named hashtag sets (e.g., "#fashion-may"), copy group to clipboard
- [ ] Templates tab: list of saved post templates (caption + hashtag group); "Use Template" pre-fills Content Editor
- [ ] Clicking a media file opens a detail panel with file metadata, copy URL button, and delete option
- [ ] Upload button in Media tab opens file picker; uploads via POST /api/v1/media/upload

**Technical Notes:**

- Media list from GET /api/v1/media?workspaceId=&type=&page= with infinite scroll (not pagination)
- Use `react-intersection-observer` to trigger next page load when last item is visible
- Hashtag groups stored client-side in workspaceStore and synced via GET/POST /api/v1/hashtag-groups

**Dependencies:** Blocks: [None]. Blocked by: [DA-E35-03].

---

### DA-E37-01 — Build Client Portal login

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Provide CLIENT users with a dedicated, isolated portal entry point that enforces role-based access and prevents cross-client data exposure.

**Acceptance Criteria:**

- [ ] All portal routes are under `/portal/*`; accessing without CLIENT role redirects to `/portal/login`
- [ ] Portal login page is visually distinct from agency login (different branding, no workspace selector)
- [ ] AuthGuard on portal routes verifies `user.role === CLIENT` and `user.clientId` is present; fails → redirect to /portal/login
- [ ] All API calls from portal pages include the user's `clientId` scope; backend enforces isolation server-side
- [ ] Logout from portal redirects to `/portal/login`, not `/login`

**Technical Notes:**

- Implement `PortalAuthGuard` as a separate component from the main `AuthGuard` to keep portal routing logic isolated
- Portal has its own `<RouterProvider>` subtree or nested route group under `/portal`
- Token and user state are shared with the main authStore; only routing guard differs

**Dependencies:** Blocks: [DA-E37-02, DA-E37-03, DA-E37-04]. Blocked by: [DA-E34-03, DA-E34-05].

---

### DA-E37-02 — Build Client Calendar

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Give CLIENT a read-only calendar view of their scheduled and published posts so they have visibility into their content plan without editing capabilities.

**Acceptance Criteria:**

- [ ] Calendar displays all posts for the authenticated client's `clientId` from GET /api/v1/posts/calendar
- [ ] Posts shown as color-coded chips: SCHEDULED=blue, PUBLISHING=orange, PUBLISHED=green, FAILED=red
- [ ] Clicking a post chip opens a read-only detail panel (no edit, schedule, or delete actions)
- [ ] Monthly and weekly view toggle available
- [ ] No drag-and-drop or scheduling controls present (read-only; edit actions are removed/hidden)

**Technical Notes:**

- Reuse the same `FullCalendar` setup from DA-E36-03 with `editable={false}` and `droppable={false}` props
- API call includes `clientId` filter which backend enforces; do not rely solely on frontend filtering

**Dependencies:** Blocks: [None]. Blocked by: [DA-E37-01, DA-E36-03].

---

### DA-E37-03 — Build Client Approval page

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Allow CLIENT to review posts sent for their approval, see platform previews, and approve or reject with written feedback.

**Acceptance Criteria:**

- [ ] List view shows all posts in SENT_TO_CLIENT status for the authenticated client; sorted by `sentToClientAt ASC`
- [ ] Each post card shows caption preview, target platforms, scheduled date, and a "Review" button
- [ ] Clicking "Review" opens a full-screen modal with platform preview tabs (DA-E30-04) and Approve / Reject buttons
- [ ] Reject flow: textarea for feedback (required), "Confirm Reject" button calls POST /api/v1/posts/{id}/client-reject
- [ ] Approve button calls POST /api/v1/posts/{id}/client-approve; on success, post disappears from the list
- [ ] Empty state shown when all posts are reviewed: "No posts awaiting your approval"

**Technical Notes:**

- Unread/new posts (not yet viewed by client) highlighted with a "New" badge; mark as viewed on modal open via PATCH /api/v1/posts/{id}/mark-viewed
- Poll for new posts every 60s or use SSE/WebSocket if implemented

**Dependencies:** Blocks: [None]. Blocked by: [DA-E37-01, DA-E30-04, DA-E31-03, DA-E31-04].

---

### DA-E37-04 — Build Client Analytics page

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Provide CLIENT with a self-service analytics view showing their campaign performance so they can assess ROI without requiring an agency report.

**Acceptance Criteria:**

- [ ] KPI cards: total posts published, success rate, total posts failed, posts pending
- [ ] Line chart: posts published per day over selected date range (default: last 30 days)
- [ ] Pie chart: breakdown by platform (FB, IG, TikTok, Threads)
- [ ] Bar chart: success rate per platform
- [ ] Date range picker (7d / 30d / 90d / custom) updates all charts simultaneously
- [ ] "Download PDF Report" button calls GET /api/v1/reports/latest?clientId= and downloads the S3 PDF

**Technical Notes:**

- Charts implemented with Recharts: `<LineChart>`, `<PieChart>`, `<BarChart>` with responsive containers
- All data from GET /api/v1/analytics/timeline?clientId=&startDate=&endDate=
- PDF download: fetch S3 pre-signed URL from the API, then `window.open(url)` in a new tab

**Dependencies:** Blocks: [None]. Blocked by: [DA-E37-01, DA-E38-01].

---

### DA-E38-01 — Implement analytics aggregation APIs

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Provide aggregated analytics endpoints that feed the dashboard and client portal charts with accurate publishing statistics.

**Acceptance Criteria:**

- [ ] GET /api/v1/analytics/overview returns `{totalPosts, publishedCount, failedCount, successRate, pendingCount}` scoped to workspaceId or clientId
- [ ] GET /api/v1/analytics/timeline?startDate=&endDate=&clientId?= returns `[{date, published, failed, platform}]` array grouped by day
- [ ] OWNER/MANAGER can query by workspaceId; CLIENT can only query their own clientId
- [ ] Both endpoints support `?platform=` filter for single-platform breakdown
- [ ] Response cached in Redis with TTL of 5 minutes; cache key includes `workspaceId:clientId:startDate:endDate:platform`

**Technical Notes:**

- Use MongoDB aggregation pipeline: `$match` → `$group by date` → `$project`
- Date grouping: `$dateToString: {format: "%Y-%m-%d", date: "$publishedAt"}`
- Cache with `@Cacheable("analytics")` or manual `RedisTemplate` for finer TTL control

**Dependencies:** Blocks: [DA-E35-02, DA-E37-04, DA-E38-04]. Blocked by: [DA-E32-08].

---

### DA-E38-02 — Implement automated PDF report generation

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Automatically generate branded PDF analytics reports for each client on a weekly and monthly schedule and store them in S3.

**Acceptance Criteria:**

- [ ] Weekly report generated every Monday at 8AM (cron: `0 8 * * MON`) for all active clients
- [ ] Monthly report generated on the 1st of each month at 8AM (cron: `0 8 1 * *`)
- [ ] PDF includes: client name, date range, KPI summary, platform breakdown table, charts rendered as images
- [ ] Stored at `s3://brandhub-reports/{workspaceId}/{clientId}/{year}-{month}.pdf`
- [ ] If generation fails for one client, logs error and continues to next client (no batch abort)

**Technical Notes:**

- Use `iTextPDF 7` (com.itextpdf:itext7-core) for PDF generation in Java
- Charts embedded as PNG images: generate server-side with `JFreeChart` or embed base64-encoded chart images
- Use `@Scheduled` with cron expressions; run in a separate `@Async` thread pool to avoid blocking
- S3 upload via AWS SDK v2 `S3Client.putObject()`

**Dependencies:** Blocks: [DA-E38-03]. Blocked by: [DA-E38-01].

---

### DA-E38-03 — Implement scheduled report email sending

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Automatically email PDF analytics reports to CLIENT contacts after report generation so clients receive insights without logging into the portal.

**Acceptance Criteria:**

- [ ] After each report is generated and uploaded to S3, an email is sent to the client's contact email
- [ ] Email includes: subject "Your BrandHub Report — {Month Year}", body with KPI summary text, PDF attached (fetched from S3)
- [ ] Email sent via Spring Mail (SMTP) or SendGrid API; configurable via `MAIL_PROVIDER` env var
- [ ] If email sending fails, logs the error and retries once after 5 minutes; does not block report generation
- [ ] Attachment size limit: if PDF > 10MB, send a download link instead of attachment

**Technical Notes:**

- Use `JavaMailSender` with `MimeMessageHelper.addAttachment()` for PDF attachment
- Fetch PDF from S3 as `InputStream` and pass directly to `addAttachment` to avoid full in-memory load
- For SendGrid: use `SendGrid Java SDK` with `Attachments` builder; encode PDF bytes as base64

**Dependencies:** Blocks: [None]. Blocked by: [DA-E38-02].

---

### DA-E38-04 — Build Analytics Dashboard

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Deliver the agency-facing analytics page with interactive charts giving OWNER and MANAGER a comprehensive view of content performance.

**Acceptance Criteria:**

- [ ] Line chart: posts published per day for selected date range using `<LineChart>` from Recharts
- [ ] Pie chart: post distribution by platform (5 slices: FB, IG, TikTok, Threads) using `<PieChart>`
- [ ] Bar chart: success rate per platform using `<BarChart>`
- [ ] KPI cards row: total published, total failed, overall success rate, most active platform
- [ ] Date range selector (7d / 30d / 90d / custom); updating range refetches and animates chart transitions
- [ ] Client filter dropdown (OWNER/MANAGER only): filter all charts to a specific client

**Technical Notes:**

- All charts wrapped in `<ResponsiveContainer width="100%" height={300}>` for responsive sizing
- Tooltips enabled on all charts showing exact values on hover
- Use `useMemo` to transform API response into Recharts-compatible data format without re-computing on every render

**Dependencies:** Blocks: [None]. Blocked by: [DA-E38-01].

---

### DA-E39-01 — Implement notification CRUD APIs

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Provide endpoints for the frontend to fetch, read, and bulk-read notifications so the Notification Center has a reliable data source.

**Acceptance Criteria:**

- [ ] GET /api/v1/notifications returns paginated notifications for the authenticated user, sorted by `createdAt DESC`; default page size 20
- [ ] PUT /api/v1/notifications/{id}/read sets `isRead = true` and `readAt = now()`; returns 404 if notification doesn't belong to user
- [ ] PUT /api/v1/notifications/read-all sets all unread notifications for the user to `isRead = true`
- [ ] GET /api/v1/notifications/unread-count returns `{count: N}` for badge display; cached 30s in Redis
- [ ] Notifications older than 90 days are purged by a nightly scheduled job

**Technical Notes:**

- MongoDB index on `{recipientId, isRead, createdAt}` for efficient unread queries
- `read-all` uses `updateMany({recipientId, isRead: false}, {$set: {isRead: true}})` — single DB operation
- Unread count cache key: `notification:unread:{userId}`; invalidate on any write operation

**Dependencies:** Blocks: [DA-E39-03]. Blocked by: [None].

---

### DA-E39-02 — Implement notification creation for 7 event types

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Ensure all key platform events automatically create notifications for the relevant user so no important action goes unnoticed.

**Acceptance Criteria:**

- [ ] `post_published`: recipient = MANAGER; message = "Post '{title}' published successfully on {platform}"
- [ ] `post_failed`: recipient = MANAGER; message = "Post '{title}' failed to publish on {platform}: {errorMessage}"
- [ ] `task_assigned`: recipient = CREATOR; message = "You have been assigned a new task: '{topic}'"
- [ ] `post_submitted`: recipient = MANAGER; message = "{creatorName} submitted '{title}' for review"
- [ ] `post_sent_to_client`: recipient = CLIENT; message = "A new post is ready for your approval"
- [ ] `token_expiring_3d`: recipient = OWNER; message = "{platform} access token for '{clientName}' expires in 3 days"
- [ ] `deadline_24h`: recipient = CREATOR; message = "Task '{topic}' deadline is in less than 24 hours"
- [ ] All 7 event types have corresponding unit tests verifying correct recipient and message content

**Technical Notes:**

- Implement `NotificationService.createNotification(type, recipientId, payload)` as the single creation method
- Use a `NotificationTemplate` enum or map to generate message strings from event payloads
- Token expiry check runs as a scheduled job every 6 hours: query `SocialAccount` where `tokenExpiresAt BETWEEN now AND now+3d AND notifiedExpiry = false`

**Dependencies:** Blocks: [DA-E29-03, DA-E39-03]. Blocked by: [DA-E39-01].

---

### DA-E39-03 — Build Notification Center UI

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Deliver an in-app notification center that keeps users aware of important events without requiring them to refresh or navigate away.

**Acceptance Criteria:**

- [ ] Bell icon in Navbar shows a red badge with unread count from GET /api/v1/notifications/unread-count; hides badge when count = 0
- [ ] Clicking bell opens a dropdown showing the last 20 notifications with message, relative timestamp ("2 min ago"), and read/unread indicator (blue dot)
- [ ] Clicking a notification calls PUT /{id}/read and navigates to the relevant page (post → Content Editor, task → My Tasks, etc.)
- [ ] "Mark all as read" button in dropdown header calls PUT /read-all and clears all blue dots
- [ ] Unread count badge auto-updates every 60s via polling (or WebSocket if available)

**Technical Notes:**

- Use `date-fns`'s `formatDistanceToNow` for relative timestamps
- Dropdown implemented with Radix UI `<Popover>` (via shadcn/ui) for accessibility (focus trap, keyboard navigation)
- Navigation mapping: `{post_published → /posts/{postId}, task_assigned → /requests/{requestId}, post_submitted → /posts/{postId}, ...}`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E39-01, DA-E39-02].

---

### DA-E40-01 — Set up React Native + Expo project

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Initialize the mobile app project with navigation structure, shared API client, and Expo configuration so all subsequent mobile screens can be built on a stable foundation.

**Acceptance Criteria:**

- [ ] Expo project created with TypeScript template; `app.json` configured with `bundleIdentifier` and `package` for iOS/Android
- [ ] React Navigation v6 configured: `AuthStack` (Login, Register, ForgotPassword) and `MainTabs` (5 tabs: Dashboard, Calendar, Approval, Notifications, Profile)
- [ ] Shared Axios instance configured with same interceptor logic as web (token attach, refresh, logout on 401)
- [ ] `authStore` implemented with Zustand + AsyncStorage persistence (same interface as web store)
- [ ] `app.json` includes required permissions: camera, photo library, notifications

**Technical Notes:**

- Use `expo-router` v3 for file-based routing OR `@react-navigation/native` with manual stack config — choose one and document
- Shared business logic (API calls, store) extracted to a `src/services/` and `src/stores/` layer; do NOT share components with web
- EAS Build configured (`eas.json`) with `development`, `preview`, and `production` profiles

**Dependencies:** Blocks: [DA-E40-02]. Blocked by: [None].

---

### DA-E40-02 — Build Auth screens (mobile)

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Deliver Login, Register, and Forgot Password screens for the mobile app with the same API integration as the web counterparts.

**Acceptance Criteria:**

- [ ] Login screen: email + password inputs, Login button, "Forgot Password?" link, Google Sign-In button
- [ ] Register screen: name, email, password, confirm password, Register button
- [ ] Forgot Password screen: email input, "Send Reset Link" button, success message state
- [ ] Form validation with inline error messages below each field
- [ ] Keyboard-aware layout (`KeyboardAvoidingView`) so inputs are not hidden by the soft keyboard
- [ ] Successful login stores tokens in AsyncStorage via authStore and navigates to MainTabs

**Technical Notes:**

- Use `react-native-paper` or custom styled components with StyleSheet (no Tailwind on mobile)
- Google Sign-In via `@react-native-google-signin/google-signin`; configure OAuth client IDs for iOS/Android in `app.json`
- Auto-focus next input on submit (email → password → Login) using `ref` and `onSubmitEditing`

**Dependencies:** Blocks: [DA-E40-03]. Blocked by: [DA-E40-01].

---

### DA-E40-03 — Build Dashboard screen (mobile)

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Deliver a simplified mobile dashboard showing KPI cards and recent activity so users get a quick status overview on their phone.

**Acceptance Criteria:**

- [ ] KPI cards in a 2-column grid: total posts, success rate, pending approvals, failed posts — fetched from GET /api/v1/analytics/overview
- [ ] Recent activity list (last 5 items) below KPI cards with activity icon, description, and relative timestamp
- [ ] Pull-to-refresh gesture triggers re-fetch of all dashboard data
- [ ] Loading skeleton shown during initial data fetch; error state with "Retry" button if fetch fails
- [ ] Tapping an activity item navigates to the relevant screen (e.g., pending approval → Approval screen)

**Technical Notes:**

- Use `FlatList` with `ListHeaderComponent` for the KPI cards + activity items in a single scrollable view
- `RefreshControl` component for pull-to-refresh behavior
- `react-native-skeleton-placeholder` for loading skeleton UI

**Dependencies:** Blocks: [DA-E40-04]. Blocked by: [DA-E40-02, DA-E38-01].

---

### DA-E40-04 — Build Calendar screen (mobile)

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Provide mobile users with a calendar view of their posts where they can tap a day to see what's scheduled or published.

**Acceptance Criteria:**

- [ ] Monthly calendar rendered with `react-native-calendars` showing colored dots on days with posts (green=published, blue=scheduled, red=failed)
- [ ] Tapping a day shows a post list below the calendar filtered to that date
- [ ] Tapping a post in the list opens a read-only post detail bottom sheet with caption, platforms, status, and scheduled time
- [ ] Navigation arrows advance to next/previous month; changing month fetches new date range from API
- [ ] Platform filter pills above the calendar (scrollable horizontal list); toggling hides that platform's dots

**Technical Notes:**

- `react-native-calendars` `markedDates` prop: `{"2025-06-15": {dots: [{color: "green"}, {color: "blue"}]}}` — multi-dot mode
- Bottom sheet via `@gorhom/bottom-sheet` with snap points [0, 50%, 90%]
- Fetch calendar data with GET /api/v1/posts/calendar?startDate=&endDate= on month change

**Dependencies:** Blocks: [None]. Blocked by: [DA-E40-03, DA-E30-01].

---

### DA-E40-05 — Build Approval screen (mobile)

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Allow CLIENT to approve or reject posts directly from their phone, making the approval workflow accessible without a desktop browser.

**Acceptance Criteria:**

- [ ] List of posts in SENT_TO_CLIENT status rendered as swipeable cards (one per post)
- [ ] Each card shows: post caption (truncated), target platforms (icon list), scheduled date, thumbnail if image post
- [ ] Tapping a card expands to full detail with scrollable caption and platform icon chips
- [ ] "Approve" (green) and "Reject" (red) buttons at bottom; reject shows a modal with a text input for feedback
- [ ] After approve/reject, card slides out of list with animation; success toast shown
- [ ] Empty state: "All posts reviewed — you're up to date!" with a checkmark illustration

**Technical Notes:**

- Swipeable cards via `react-native-gesture-handler` `Swipeable` component with right-action "Approve" quick action
- Feedback text input in a `Modal` with `KeyboardAvoidingView`; minimum 10 characters for reject feedback
- Optimistic removal from list on action; re-fetch if API call fails and restore the card

**Dependencies:** Blocks: [None]. Blocked by: [DA-E40-02, DA-E31-03, DA-E31-04].

---

### DA-E40-06 — Implement offline draft mode

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Allow CREATOR to save post drafts on mobile without internet connectivity and automatically sync them when connectivity is restored.

**Acceptance Criteria:**

- [ ] When offline, "Save Draft" in the content editor saves to AsyncStorage key `drafts:{userId}:{tempId}` with full post payload
- [ ] A "Drafts (offline)" badge appears in the navigation when unsync'd drafts exist
- [ ] `NetInfo.addEventListener` detects when network reconnects and automatically calls POST /api/v1/posts for each pending draft
- [ ] Successfully synced drafts are removed from AsyncStorage; failed syncs remain with an error indicator
- [ ] User can manually trigger sync from a "Sync Drafts" button in the Drafts screen

**Technical Notes:**

- Use `@react-native-community/netinfo` for connectivity detection
- AsyncStorage stores JSON-serialized draft: `{tempId, userId, topic, caption, platform, mediaUrls[], createdAt}`
- Sync is idempotent: check if a post with `tempId` already exists server-side before creating (use `X-Idempotency-Key: tempId` header)

**Dependencies:** Blocks: [None]. Blocked by: [DA-E40-02].

---

### DA-E41-01 — Integrate FCM push notifications (mobile)

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Enable the mobile app to receive push notifications from FCM so users are alerted of important events in real time.

**Acceptance Criteria:**

- [ ] `@react-native-firebase/messaging` initialized; `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) configured
- [ ] On first app launch (after login), `requestPermission()` is called; user is shown the system permission dialog
- [ ] If permission granted, `getToken()` fetches the FCM token and calls PUT /api/v1/users/me/fcm-token to register it
- [ ] FCM token is refreshed via `onTokenRefresh` listener and re-registered whenever it changes
- [ ] Foreground notifications displayed using `notifee` or `@react-native-firebase/messaging` foreground presenter
- [ ] Tapping a notification navigates to the relevant in-app screen (deep link routing)

**Technical Notes:**

- Background/quit state message handling via `messaging().setBackgroundMessageHandler()` registered in `index.js`
- Deep link routing: notification `data.screen` and `data.entityId` fields map to React Navigation routes
- FCM token stored in AsyncStorage as backup; re-registered on every app start if the stored token differs from server

**Dependencies:** Blocks: [DA-E41-03]. Blocked by: [DA-E40-01].

---

### DA-E41-02 — Set up FCM server-side in business-service

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Implement server-side FCM token storage and push notification dispatch so the backend can send targeted push notifications to mobile users.

**Acceptance Criteria:**

- [ ] PUT /api/v1/users/me/fcm-token with body `{fcmToken: string}` stores or updates `fcmToken` on the User document
- [ ] On each notification creation event, if recipient has a non-null `fcmToken`, dispatch an FCM push via FCM HTTP API v1
- [ ] FCM payload includes `{title, body, data: {screen, entityId}}` so mobile can deep link
- [ ] If FCM returns `UNREGISTERED` error, clear the `fcmToken` from the user document (token is invalid)
- [ ] FCM dispatch is asynchronous (`@Async`) so it does not slow down the primary notification creation path

**Technical Notes:**

- Use `google-auth-library` or Firebase Admin SDK (`firebase-admin`) for FCM HTTP API v1 authentication
- FCM API endpoint: `POST https://fcm.googleapis.com/v1/projects/{projectId}/messages:send`
- Service account key JSON configured via `FIREBASE_SERVICE_ACCOUNT_JSON` env var; never committed to repo

**Dependencies:** Blocks: [DA-E41-01]. Blocked by: [DA-E39-02].

---

### DA-E41-03 — Build Notification screen (mobile)

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Provide a dedicated mobile screen listing all notifications with deep-link navigation and read-state management.

**Acceptance Criteria:**

- [ ] `FlatList` of notifications sorted by `createdAt DESC`; unread items have a blue left border accent
- [ ] Tapping a notification calls PUT /{id}/read, marks it read locally (optimistic), and navigates to the relevant screen
- [ ] "Mark all as read" button in the screen header calls PUT /read-all and removes all blue accents
- [ ] Pull-to-refresh reloads notification list
- [ ] Infinite scroll loads next page when user reaches the bottom of the list
- [ ] Empty state: "No notifications yet" with bell illustration

**Technical Notes:**

- Use `FlatList`'s `onEndReached` with `onEndReachedThreshold={0.5}` for infinite scroll
- Optimistic read state: update local array immediately, revert on API error
- Navigation mapping same as web: derive target route from `notification.type` and `notification.entityId`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E41-01, DA-E39-01].

---

### DA-E41-04 — Integrate expo-image-picker and expo-camera

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Enable CREATOR to attach media from their phone gallery or camera to posts directly from the mobile app.

**Acceptance Criteria:**

- [ ] "Attach Media" button in the mobile content editor shows an action sheet: "Choose from Library" or "Take Photo/Video"
- [ ] Gallery picker (`expo-image-picker`) supports multi-select of up to 10 images or 1 video
- [ ] Camera capture (`expo-camera`) supports photo and video modes
- [ ] Selected media is uploaded via POST /api/v1/media/upload (multipart); upload progress shown per file
- [ ] On upload success, returned S3 URL is added to the post's `mediaUrls` array
- [ ] Permissions (camera, photo library) are requested before first use with explanation rationale

**Technical Notes:**

- `expo-image-picker` with `mediaTypes: ImagePicker.MediaTypeOptions.All`, `allowsMultipleSelection: true`, `quality: 0.8`
- Video compressed with `expo-av` or `react-native-compressor` before upload if size > 50MB
- Upload uses `FormData` with `axios.post('/api/v1/media/upload', formData, {onUploadProgress})`

**Dependencies:** Blocks: [None]. Blocked by: [DA-E40-02].

---

### DA-E42-01 — Write unit tests for business-service

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Achieve ≥70% unit test coverage for business-service core services to prevent regressions and validate business logic correctness.

**Acceptance Criteria:**

- [ ] `AuthServiceTest`: covers login (success, wrong password, user not found), register (success, duplicate email), refresh token (valid, expired, not found), logout (token invalidated)
- [ ] `WorkspaceServiceTest`: covers create workspace, invite member (success, already member, wrong role), remove member, workspace isolation (cannot access another workspace's data)
- [ ] `PostServiceTest`: covers submit (success, wrong status, wrong user), approve, reject, client-approve, client-reject, schedule
- [ ] All tests use JUnit 5 + Mockito; no Spring context loaded (pure unit tests with mocked dependencies)
- [ ] Coverage report generated with JaCoCo; fails build if overall coverage < 70%

**Technical Notes:**

- Add `jacoco-maven-plugin` to `pom.xml` with `<minimum>0.70</minimum>` rule on `check` goal
- Mock MongoDB repositories with `@Mock` and `Mockito.when(repo.findById(...)).thenReturn(...)`
- Test naming convention: `methodName_condition_expectedResult` (e.g., `login_wrongPassword_throwsUnauthorizedException`)

**Dependencies:** Blocks: [DA-E42-03]. Blocked by: [DA-E28-03, DA-E31-04].

---

### DA-E42-02 — Write unit tests for ai-service

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Validate ai-service business logic in isolation using mocks so that external AI API failures don't block testing and regressions are caught early.

**Acceptance Criteria:**

- [ ] Content generation tests: mock Groq API response, verify prompt construction includes brand context, verify output parsed correctly, verify error handling when Groq returns 429
- [ ] RAG pipeline tests: mock ChromaDB `query()`, verify top-k documents are retrieved and injected into prompt, verify empty retrieval fallback behavior
- [ ] Image generation tests: mock Stability AI response, verify payload construction, verify base64 decode and S3 upload call, verify error on NSFW rejection
- [ ] All tests use `pytest` with `unittest.mock.patch`; minimum 65% coverage measured by `pytest-cov`
- [ ] Tests runnable with `pytest tests/unit/` without any external service dependencies

**Technical Notes:**

- Use `@patch("app.services.groq_client.ChatCompletion.create")` pattern to mock Groq
- Fixture files in `tests/fixtures/` for mock API responses (valid generation, rate limit error, NSFW error)
- `pytest-cov` configured in `pytest.ini`: `addopts = --cov=app --cov-report=term-missing`

**Dependencies:** Blocks: [DA-E42-03]. Blocked by: [None].

---

### DA-E42-03 — Write integration tests for business-service

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Validate the full request lifecycle through real database and cache layers to catch integration bugs that unit tests cannot detect.

**Acceptance Criteria:**

- [ ] Full auth flow: POST /register → POST /login → GET /me → POST /refresh → POST /logout — all returning correct status codes and response shapes
- [ ] RBAC enforcement: CLIENT calling MANAGER endpoints returns 403; CREATOR calling admin endpoints returns 403
- [ ] Workspace isolation: User in Workspace A cannot read/modify resources in Workspace B (verified by attempting cross-workspace API calls)
- [ ] Tests use `@SpringBootTest(webEnvironment = RANDOM_PORT)` with `TestRestTemplate`
- [ ] Testcontainers spins up real MongoDB and Redis containers; no H2 or mocks for persistence layer

**Technical Notes:**

- Add `testcontainers-bom` to `pom.xml` and `MongoDBContainer`, `GenericContainer` (Redis) to test base class
- `@DirtiesContext(classMode = AFTER_EACH_TEST_CLASS)` to reset containers between test classes
- Use `@Sql` equivalent (MongoTemplate insert) to seed test data in `@BeforeEach`

**Dependencies:** Blocks: [DA-E42-04]. Blocked by: [DA-E42-01, DA-E42-02].

---

### DA-E42-04 — Performance test

**Assignee:** All (Team) | **Priority:** 🟡 High

**Goal:** Validate that the system meets latency SLAs under realistic concurrent load before production deployment.

**Acceptance Criteria:**

- [ ] k6 or JMeter test script covers: login, GET /posts/calendar, GET /content-requests, GET /analytics/overview, POST /posts/{id}/submit
- [ ] Load profile: 200 concurrent virtual users, 60s ramp-up, 5-minute sustained load, 30s ramp-down
- [ ] p95 latency < 500ms for all non-AI endpoints under the target load
- [ ] Error rate < 1% during sustained load phase
- [ ] Performance report (HTML or CSV) committed to repo under `/performance-tests/results/`

**Technical Notes:**

- If using k6: `options = {stages: [{duration: '60s', target: 200}, {duration: '5m', target: 200}, {duration: '30s', target: 0}]}`
- Run against staging environment (not production); use seeded test data (pre-created workspaces, posts)
- Monitor MongoDB and Redis metrics during test to identify bottlenecks (use `mongostat` and `redis-cli info`)

**Dependencies:** Blocks: [DA-E43-01]. Blocked by: [DA-E42-03].

---

### DA-E42-05 — E2E publishing test

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Verify the complete content workflow from request to live post on real platform sandbox accounts to confirm end-to-end system correctness.

**Acceptance Criteria:**

- [ ] Test flow executes in order: create ContentRequest → AI generate → save draft → submit → MANAGER approve → client approve → verify post appears as PUBLISHED in DB
- [ ] Test covers all 5 platforms: Facebook, Instagram, TikTok, Threads using developer sandbox/test accounts
- [ ] Each platform's `platformPostId` is stored in the Post document after successful publish
- [ ] Test verifies the post actually appears on the platform by calling the platform's read API to confirm existence
- [ ] Test is tagged `@E2E` and excluded from the default test run; only runs manually or in a dedicated CI stage

**Technical Notes:**

- Facebook/Instagram: use a Facebook Test User linked to a test Page in the Meta Developer App
- TikTok: use a sandbox account from TikTok Developer Portal
- Test credentials stored in GitHub Secrets / `.env.test` (never committed)
- E2E test runs against the deployed staging environment, not local

**Dependencies:** Blocks: [DA-E43-01]. Blocked by: [DA-E32-03, DA-E32-04, DA-E32-05, DA-E32-06, DA-E42-03].

---

### DA-E43-01 — Sprint retrospective and bug list compilation

**Assignee:** All (Team) | **Priority:** 🔴 Critical

**Goal:** Systematically catalog all defects discovered during testing phases into a prioritized bug list so the fix sprint is focused and nothing is overlooked.

**Acceptance Criteria:**

- [ ] All bugs found in DA-E42-01 through DA-E42-05 documented in a shared tracker (Jira/Notion/GitHub Issues) with: title, steps to reproduce, actual vs expected behavior, severity
- [ ] Bugs triaged into severity levels: P0 (system down/data loss), P1 (feature broken), P2 (degraded UX), P3 (cosmetic)
- [ ] All P0 and P1 bugs assigned to a team member with a fix deadline before the submission date
- [ ] Bug list reviewed by Trung (Leader) and signed off before fix sprint begins
- [ ] Retrospective meeting notes documented covering what went well, what to improve, action items

**Dependencies:** Blocks: [DA-E43-02, DA-E43-03]. Blocked by: [DA-E42-04, DA-E42-05].

---

### DA-E43-02 — UI responsive fixes

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Ensure all web UI pages are correctly displayed at all target breakpoints so the product is usable for agency staff on any screen size.

**Acceptance Criteria:**

- [ ] All pages tested at 1920px, 1440px, 1280px, and ≤768px using Chrome DevTools device emulation
- [ ] No horizontal scroll on any page at any breakpoint
- [ ] Tables degrade gracefully at ≤768px (either scroll horizontally within a container or collapse to card view)
- [ ] Modals and dropdowns do not overflow screen bounds on mobile
- [ ] Sidebar collapses to bottom tab bar at ≤768px (DA-E34-03) confirmed working

**Technical Notes:**

- Use Tailwind responsive prefixes: `sm:`, `md:`, `lg:`, `xl:`, `2xl:` for all layout-affecting utilities
- Test with both browser DevTools and physical device (or BrowserStack) for iOS Safari rendering quirks
- Priority fix order: P0 breaks → navigation issues → table overflow → modal/form usability

**Dependencies:** Blocks: [DA-E44-04]. Blocked by: [DA-E43-01].

---

### DA-E43-03 — Security audit

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Verify all 10 security checklist items are addressed before production deployment to prevent critical vulnerabilities from reaching live users.

**Acceptance Criteria:**

- [ ] SQL injection: all DB queries use parameterized MongoDB queries; no string concatenation in queries
- [ ] NoSQL injection: validate all `$`-prefixed keys are stripped from user input using a sanitizer middleware
- [ ] XSS: all user-generated content rendered via React (safe by default); any `dangerouslySetInnerHTML` usages reviewed and eliminated
- [ ] CSRF: stateless JWT auth (no session cookies); CSRF not applicable, but confirm no cookie-based session exists
- [ ] JWT security: tokens signed with RS256 or HS256 with ≥256-bit key; short expiry (15m access, 7d refresh)
- [ ] AES key: stored in env var or Vault, not in DB or source code; verified by `grep -r "AES_KEY"` in source
- [ ] S3 bucket: bucket policy is private; all objects accessed via pre-signed URLs with ≤1h TTL
- [ ] RabbitMQ management port (15672): blocked at security group / nginx level; not publicly accessible
- [ ] Admin endpoints: all `/api/v1/admin/*` routes gated by `hasRole('ADMIN')` annotation + integration test confirming 403 for non-admin
- [ ] Internal endpoints: all `/internal/*` routes blocked at nginx level; accessible only within Docker network

**Technical Notes:**

- Use OWASP dependency-check Maven plugin to scan for known CVEs in dependencies
- Document findings and mitigations in a `SECURITY_AUDIT.md` file committed to the repo
- For NoSQL injection: add a `MongoSanitizationFilter` that recursively removes keys starting with `$` from request bodies

**Dependencies:** Blocks: [DA-E44-01]. Blocked by: [DA-E43-01].

---

### DA-E44-01 — Provision EC2 and configure nginx

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Stand up the production server with Docker runtime and configure nginx as a reverse proxy so the platform is accessible via a custom domain with HTTPS.

**Acceptance Criteria:**

- [ ] EC2 t3.medium (Ubuntu 22.04 LTS) launched in the target region; security group allows 80, 443 inbound, 22 restricted to team IPs
- [ ] Docker Engine 24+ and Docker Compose v2 installed; verified with `docker --version` and `docker compose version`
- [ ] nginx configured as reverse proxy: `api.brandhub.com` → `127.0.0.1:8080`; all HTTP redirected to HTTPS
- [ ] nginx rate limiting configured: `limit_req_zone` at 100 req/s per IP with burst of 20
- [ ] Internal ports (8081, 5672, 15672, 27017, 6379) not exposed in EC2 security group; only Docker internal network

**Technical Notes:**

- nginx config: `proxy_pass http://127.0.0.1:8080; proxy_set_header X-Forwarded-For $remote_addr; proxy_read_timeout 120s`
- Block `/internal/` at nginx level: `location /internal/ { deny all; return 403; }`
- Allocate 20GB+ EBS volume to account for Docker images, logs, and MongoDB data

**Dependencies:** Blocks: [DA-E44-02]. Blocked by: [DA-E43-03].

---

### DA-E44-02 — Deploy all services via docker-compose.prod.yml

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Deploy all 7 BrandHub microservices to production with automatic restart, resource limits, and SSL so the full platform is live and stable.

**Acceptance Criteria:**

- [ ] `docker-compose.prod.yml` defines all 7 services (api-gateway, business-service, publisher-service, ai-service, MongoDB, Redis, RabbitMQ) with `image: ghcr.io/brandhub/{service}:latest`
- [ ] All services have `restart: always` and memory limits (`mem_limit: 512m` for Java services, `mem_limit: 1g` for ai-service)
- [ ] `.env.prod` file present on the server (not in repo) with all required secrets; `env_file: .env.prod` in compose
- [ ] SSL certificate obtained via `certbot --nginx -d api.brandhub.com`; auto-renewal cron configured
- [ ] All 7 services pass health check within 5 minutes of `docker compose up -d`

**Technical Notes:**

- Use GitHub Actions CD pipeline: on push to `main`, build Docker images, push to GHCR, SSH to EC2, run `docker compose pull && docker compose up -d`
- MongoDB volume: `volumes: [mongo_data:/data/db]` with named volume to survive container restarts
- RabbitMQ: enable `rabbitmq_delayed_message_exchange` plugin in the Dockerfile: `RUN rabbitmq-plugins enable rabbitmq_delayed_message_exchange`

**Dependencies:** Blocks: [DA-E44-03]. Blocked by: [DA-E44-01].

---

### DA-E44-03 — Set up UptimeRobot and disk/CPU alerts

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Establish uptime monitoring and resource alerts so the team is immediately notified of outages or server resource exhaustion.

**Acceptance Criteria:**

- [ ] UptimeRobot monitor configured for `https://api.brandhub.com/health` with 5-minute check interval
- [ ] Email alert sent to team email when monitor goes DOWN and again when it recovers (UP)
- [ ] Disk usage alert: cron job runs every 15 minutes, sends email if disk usage > 80% (`df -h` check)
- [ ] CPU alert: if CPU > 90% for 5 consecutive minutes, email sent (can use CloudWatch or a simple cron with `top`)
- [ ] UptimeRobot public status page created and URL shared with stakeholders

**Technical Notes:**

- Disk alert cron: `*/15 * * * * df -h / | awk 'NR==2{print $5}' | grep -q "^[89][0-9]%\|^100%" && mail -s "DISK ALERT" team@brandhub.com`
- Alternatively use AWS CloudWatch Alarms with SNS email subscription for CPU/disk metrics
- UptimeRobot free tier supports up to 50 monitors at 5-minute intervals

**Dependencies:** Blocks: [DA-E44-04]. Blocked by: [DA-E44-02].

---

### DA-E44-04 — Run production smoke test

**Assignee:** All (Team) | **Priority:** 🔴 Critical

**Goal:** Verify the end-to-end user journey works correctly on the production environment to confirm the deployment is fully functional before submission.

**Acceptance Criteria:**

- [ ] Register a new agency account → Login → Create workspace → Connect a social account → Create a content request
- [ ] CREATOR generates AI content → saves draft → submits for review
- [ ] MANAGER approves → sends to client
- [ ] CLIENT logs in to portal → approves the post
- [ ] Post is scheduled and published → verified as PUBLISHED status in the DB and visible on the platform
- [ ] All steps completed without errors; any issue found is logged and fixed before sign-off

**Technical Notes:**

- Use real (non-test) social accounts for the final smoke test to confirm real publishing works
- Document the smoke test run with screenshots at each step; commit to `/smoke-test/results/` folder
- If publishing to real platforms is risky, use a private/test Facebook Page with no followers

**Dependencies:** Blocks: [DA-E45-01]. Blocked by: [DA-E44-02, DA-E44-03, DA-E43-02].

---

### DA-E45-01 — Finalize Swagger/OpenAPI documentation

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Deliver complete, accurate API documentation for business-service so evaluators and future developers can understand and use the API without reading source code.

**Acceptance Criteria:**

- [ ] All endpoints documented with `@Operation`, `@ApiResponse`, `@RequestBody`, `@Parameter` annotations
- [ ] Each endpoint has at least one success example (200/201) and relevant error examples (400, 401, 403, 404, 409)
- [ ] Request and response schemas include field-level `@Schema(description=...)` annotations
- [ ] Swagger UI accessible at `https://api.brandhub.com/swagger-ui.html` (or `/api-docs`)
- [ ] OpenAPI 3.0 spec JSON exported and committed to `/docs/openapi.json`

**Technical Notes:**

- Use `springdoc-openapi-starter-webmvc-ui` dependency (not the deprecated springfox)
- Group endpoints by tag: `Auth`, `Workspace`, `Client`, `ContentRequest`, `Post`, `Analytics`, `Notification`, `Admin`
- Secure Swagger UI in production: require Basic Auth or restrict to internal IP via nginx

**Dependencies:** Blocks: [DA-E45-02]. Blocked by: [DA-E44-04].

---

### DA-E45-02 — Write User Manual

**Assignee:** All (Team) | **Priority:** 🟡 High

**Goal:** Provide a comprehensive user manual covering all 6 roles so that new users and evaluators can understand system capabilities without requiring a walkthrough.

**Acceptance Criteria:**

- [ ] Manual covers all 6 roles: ADMIN, OWNER, MANAGER, CREATOR, CLIENT, GUEST
- [ ] Each role section includes: role overview, available features, step-by-step instructions for key workflows, annotated screenshots
- [ ] Key workflows documented: onboarding, content request lifecycle, AI generation, approval process, publishing, analytics
- [ ] Manual formatted as PDF and Word (.docx); committed to `/docs/user-manual/`
- [ ] Total length: 30–60 pages with screenshots

**Technical Notes:**

- Screenshots taken from the production deployment after DA-E44-04 smoke test passes
- Use consistent screenshot annotations: numbered callouts, red rectangle highlights for UI elements
- GUEST role section covers public-facing pages only (if any exist) or the registration flow

**Dependencies:** Blocks: [DA-E45-04]. Blocked by: [DA-E45-01].

---

### DA-E45-03 — Write Deployment Guide

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Document the exact steps to deploy BrandHub from scratch so the system can be reproduced by evaluators or a new team member.

**Acceptance Criteria:**

- [ ] 7 steps documented: 1) Prerequisites (Docker, git, domain), 2) Clone repo, 3) Configure .env.prod, 4) docker-compose up, 5) Verify all service health endpoints, 6) Configure nginx + SSL (certbot), 7) Initialize DB (indexes, admin user seed)
- [ ] Each step includes the exact command(s) to run and expected output
- [ ] `.env.prod.example` file committed to repo with all required variable keys (values blank/placeholder)
- [ ] Troubleshooting section covers 5 common issues: port conflict, out-of-memory, MongoDB auth failure, RabbitMQ plugin missing, SSL cert renewal
- [ ] Guide tested by a team member not involved in deployment to verify accuracy

**Technical Notes:**

- Include `docker compose ps` and `curl https://api.brandhub.com/health` as verification commands after step 4
- Document RabbitMQ delayed message exchange plugin enablement as a required step
- Note minimum server specs: 2 vCPU, 4GB RAM, 20GB disk, Ubuntu 22.04

**Dependencies:** Blocks: [DA-E45-04]. Blocked by: [DA-E44-04].

---

### DA-E45-04 — Record demo video

**Assignee:** All (Team) | **Priority:** 🔴 Critical

**Goal:** Produce a polished 7-minute demo video showcasing all key system capabilities so evaluators can assess the product without a live demonstration.

**Acceptance Criteria:**

- [ ] Scene 1 (~30s): System overview — architecture diagram, tech stack summary
- [ ] Scene 2 (~60s): OWNER — create workspace, invite members, connect social account
- [ ] Scene 3 (~45s): CLIENT — submit content request
- [ ] Scene 4 (~90s): CREATOR — open request, trigger AI generate, edit caption, attach image, submit for review
- [ ] Scene 5 (~45s): MANAGER — review post, approve, send to client
- [ ] Scene 6 (~45s): CLIENT — log into portal, view preview, approve post
- [ ] Scene 7 (~30s): Publishing — show post moving to PUBLISHED status, show post live on platform
- [ ] Scene 8 (~45s): Analytics — dashboard charts, download PDF report
- [ ] Scene 9 (~30s): Mobile — show approval and notification on phone
- [ ] Video exported as MP4 1080p; uploaded to Google Drive/YouTube and link committed to `/docs/demo-link.txt`

**Technical Notes:**

- Record with OBS Studio (free) at 1920×1080; use screen capture + webcam overlay for presenter
- Narrate in Vietnamese (matching FPT submission language) with clear audio; add English subtitles if required
- Edit in DaVinci Resolve or CapCut; trim silences, add scene title cards, add background music at 20% volume

**Dependencies:** Blocks: [DA-E46-01]. Blocked by: [DA-E45-02, DA-E45-03].

---

### DA-E46-01 — Write Capstone report

**Assignee:** All (Team) | **Priority:** 🔴 Critical

**Goal:** Produce the formal capstone report following FPT's required template that documents the full project from conception to deployment.

**Acceptance Criteria:**

- [ ] Section 1 Introduction: problem statement, project scope, objectives, team members and roles
- [ ] Section 2 Literature Review: social media management tools comparison, AI content generation research, microservices vs monolith analysis
- [ ] Section 3 System Design: architecture diagram, database schema (MongoDB + PostgreSQL), API design principles, security design
- [ ] Section 4 Implementation: key technical decisions, code snippets for complex features (state machine, retry logic, RAG pipeline)
- [ ] Section 5 AI Research: RAG implementation details, InstantID integration, prompt engineering, hallucination mitigation
- [ ] Section 6 Testing: unit/integration/E2E/performance test results with metrics and charts
- [ ] Section 7 Deployment: infrastructure setup, CI/CD pipeline, monitoring
- [ ] Section 8 Conclusion: objectives achieved, limitations, future work
- [ ] Section 9 References: IEEE citation format, minimum 20 references
- [ ] Section 10 Appendix: full API endpoint list, DB schema diagrams, team contribution table
- [ ] Total length: 80–120 pages; follows FPT formatting template (font, margins, page numbering)

**Technical Notes:**

- Each team member writes their primary sections; Trung consolidates and ensures consistent terminology
- Include actual test metrics from DA-E42-04 performance test (p95 latency, error rate charts)
- AI section must include comparative analysis: with vs without RAG for content quality

**Dependencies:** Blocks: [DA-E46-02]. Blocked by: [DA-E45-04].

---

### DA-E46-02 — Consolidate and review entire report

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Ensure the final capstone report is internally consistent, properly formatted, and meets FPT submission requirements before the deadline.

**Acceptance Criteria:**

- [ ] All 10 sections reviewed for consistent terminology (e.g., "post" not sometimes "content", "workspace" not sometimes "organization")
- [ ] All diagrams are high resolution (≥150 DPI) and referenced in the text
- [ ] Table of contents, list of figures, and list of tables generated and accurate
- [ ] References section checked for completeness: all in-text citations have a corresponding reference entry
- [ ] Plagiarism check run (Turnitin or equivalent); similarity score < 25%
- [ ] Final PDF submitted to FPT portal by the official deadline; submission confirmation screenshot saved

**Technical Notes:**

- Use a shared Google Docs or Overleaf (LaTeX) for collaborative writing to avoid merge conflicts
- Final export as PDF/A for archival compatibility required by FPT
- Run spell check and grammar check (Grammarly or LanguageTool) on all sections before final export

**Dependencies:** Blocks: [DA-E46-03]. Blocked by: [DA-E46-01].

---

### DA-E46-03 — Prepare slide deck

**Assignee:** All (Team) | **Priority:** 🔴 Critical

**Goal:** Produce a clear 15-slide presentation deck that communicates the project's value, architecture, and results to the evaluation committee.

**Acceptance Criteria:**

- [ ] Slide 1: Title — project name, team members, date
- [ ] Slide 2: Problem — pain points of manual social media management (data/statistics)
- [ ] Slide 3: Solution — BrandHub overview, key differentiators
- [ ] Slide 4: Architecture — system architecture diagram (microservices + AI services)
- [ ] Slide 5: Tech Stack — categorized by layer (Backend, Frontend, Mobile, AI, Infra)
- [ ] Slides 6–9: 4 Key Features — content workflow, AI generation, multi-platform publishing, client portal
- [ ] Slide 10: Database Design — MongoDB collections + PostgreSQL schema overview
- [ ] Slide 11: AI Results — RAG quality metrics, InstantID sample outputs, generation time
- [ ] Slide 12: Testing Results — coverage %, p95 latency chart, E2E pass/fail summary
- [ ] Slide 13: Screenshots — 4 key UI screenshots (Dashboard, Content Editor, Calendar, Mobile)
- [ ] Slide 14: Challenges & Solutions — top 3 technical challenges and how they were resolved
- [ ] Slide 15: Conclusion & Future Work — what was achieved, what's next (monetization, more platforms)
- [ ] Slide deck exported as PDF and PPTX; both versions committed to `/docs/presentation/`

**Technical Notes:**

- Use Canva, Google Slides, or PowerPoint; consistent theme matching BrandHub brand colors
- Font size minimum 24pt for body text, 36pt for section headers
- Presentation rehearsed as a team; total talk time target 10–12 minutes + Q&A

**Dependencies:** Blocks: [DA-E46-04]. Blocked by: [DA-E46-02].

---

### DA-E46-04 — Q&A preparation

**Assignee:** All (Team) | **Priority:** 🟡 High

**Goal:** Prepare confident, technically accurate answers to the 7 most likely mentor questions so the team can handle the Q&A session without hesitation.

**Acceptance Criteria:**

- [ ] Q1 Polyrepo: explain why polyrepo was chosen over monorepo (independent deployment, team autonomy, CI separation) with trade-offs acknowledged
- [ ] Q2 MongoDB + PostgreSQL split: explain which data lives where and why (post/content in MongoDB for flexibility; relational billing/user data in PostgreSQL for ACID compliance)
- [ ] Q3 AI hallucination: explain mitigation strategy (RAG with brand context, temperature 0.7, output validation, human review step in workflow)
- [ ] Q4 Compute cost: present estimated monthly AWS cost breakdown (EC2 t3.medium ~$30, Groq API ~$X, Stability AI ~$Y, S3 ~$5) and scaling path
- [ ] Q5 InstantID: explain the face-consistency model, how it's integrated in the image generation pipeline, and its limitations
- [ ] Q6 Adapter pattern: explain how the platform adapter pattern allows adding new platforms (e.g., LinkedIn) without modifying existing code (Open/Closed principle)
- [ ] Q7 Security: walk through the full security model (JWT, AES token encryption, RBAC, workspace isolation, S3 private bucket, internal endpoint protection)
- [ ] Each answer prepared as a 2–3 minute verbal response; team members assigned primary responders per question

**Technical Notes:**

- Hold a mock Q&A session with the full team 2–3 days before presentation; record it for self-review
- Prepare a "backup slide" appendix (slides 16–22) with deeper technical diagrams for each question in case a visual aid is needed

**Dependencies:** Blocks: [None]. Blocked by: [DA-E46-03].

---

## EPIC E49 — Public Landing Page (Task Details)

### DA-E49-01 — Build Cinematic Hero section

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Deliver the hero section — a scroll-driven cinematic animation: 4 platform posts (IG, TT, FB, LI) → BrandHub dashboard on MacBook Air → Register/Login CTA.

**Acceptance Criteria:**

- [ ] GSAP ScrollTrigger timeline: IG(0-15%)→TT(15-35%)→FB(35-55%)→LI(55-75%)→BrandHub(75-90%)→CTA(90-100%), pin 3500px, scrub:1
- [ ] 4 platform post components: InstagramPost, TikTokPost, FacebookPost, LinkedInPost — realistic social cards
- [ ] MacBook Air M5 aluminum chassis + macOS Sonoma wallpaper + menubar + notch
- [ ] Safari browser: 4 interactive tabs (Overview/Content/Schedule/Analytics) with working navigation
- [ ] macOS Dock: 12 app icons as inline SVG glyphs
- [ ] Mini posts burst to 4 corners — staggered back.out easing, idle drift animation
- [ ] CTA buttons overlay after animation: Register + Login
- [ ] Locked forward-only — scroll-back does NOT reverse

**Technical Notes:**

- pin:true, anticipatePin:1. onComplete sets locked=true, onUpdate clamps progress(1).
- Platform posts ~100-160 lines each — realistic profile pics, content, engagement buttons, timestamps.
- Dashboard tabs use useState switching, remount on key change for GSAP enter animations.
- Mini post idle: gsap.to y:'+=6', yoyo:true, repeat:-1, out-of-phase delays.

**Dependencies:** Blocks: [None]. Blocked by: [DA-E34-02, DA-E34-03].

---

### DA-E49-02 — Build Features section

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Deliver 6-card feature grid: Planning (CalendarDays), Creation (FileEdit), Publishing (LayoutDashboard), Analytics (BarChart3), Collaboration (Users), Automation (Zap).

**Acceptance Criteria:**

- [ ] 6 cards responsive grid (1/2/3 cols): orange icon container, title, description from i18n
- [ ] Hover: border orange-200, bg orange-50/30, shadow-lg, icon container scale 110%
- [ ] Scroll: fade in + slide up y:32→0, staggered 80ms via framer-motion whileInView once:true
- [ ] Dark mode: border zinc-800, bg zinc-900/50

**Technical Notes:**

- Uses framer-motion, not GSAP. All text via i18n keys.

**Dependencies:** Blocks: [None]. Blocked by: [DA-E34-02].

---

### DA-E49-03 — Build How It Works section

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Deliver 4-step timeline: Plan→Create→Schedule→Publish — alternating left/right cards with connecting line.

**Acceptance Criteria:**

- [ ] 4 numbered orange circles connected by vertical line (desktop center, mobile left)
- [ ] Alternating layout: odd steps left, even steps right on desktop
- [ ] Each step: colored icon, title, description
- [ ] Scroll: cards slide in from left/right (x:±40→0), stagger 100ms

**Technical Notes:**

- Connecting line: absolute div w-0.5, hidden on mobile.

**Dependencies:** Blocks: [None]. Blocked by: [DA-E34-02].

---

### DA-E49-04 — Build Stats Counter + LogoWall sections

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Deliver animated counters (1.2M+ contents, 50K+ brands, 12 platforms, 99.9% uptime) + 12 brand logo names.

**Acceptance Criteria:**

- [ ] Stats: 4 counters on brand-orange bg, custom useCountUp hook (rAF + cubic ease-out, 2s)
- [ ] Vietnamese locale formatting, decimal support, suffix support
- [ ] LogoWall: 12 brands as bold text, staggered fade-in

**Technical Notes:**

- useCountUp: useEffect + rAF, cancelAnimationFrame cleanup. Returns formatted string.

**Dependencies:** Blocks: [None]. Blocked by: [DA-E34-02].

---

### DA-E49-05 — Build Templates + Testimonials sections

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Deliver Templates showcase (Social, Blog, Email) with gradient previews + Testimonials (3 quotes, 5-star ratings, avatars).

**Acceptance Criteria:**

- [ ] Templates: 3 cards with gradient-top preview, frosted icon circle, hover shadow-xl
- [ ] Testimonials: 3 cards with 5 gold stars, quoted text, avatar initials circle, name+role
- [ ] Responsive: 1 col mobile, 3 col desktop. Scroll fade-in + slide up.

**Technical Notes:**

- Avatar initials: name.split(' ').map(n=>n[0]).join('')

**Dependencies:** Blocks: [None]. Blocked by: [DA-E34-02].

---

### DA-E49-06 — Build Pricing section

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Deliver 3-tier pricing: Starter, Pro (highlighted), Enterprise — feature checklists, CTAs.

**Acceptance Criteria:**

- [ ] 3 plan cards responsive grid. Pro: ring-1 ring-brand-orange, shadow-xl, 'Pho bien nhat' badge
- [ ] Each: plan name, price (4xl bold), feature list with Check icons, CTA button
- [ ] Features from i18n (returnObjects:true). CTAs: Starter/Pro→/register, Enterprise→/contact

**Technical Notes:**

- Enterprise CTA uses /contact, no /thang suffix.

**Dependencies:** Blocks: [None]. Blocked by: [DA-E34-02, DA-E35-01].

---

### DA-E49-07 — Build FAQ + CTA + Footer sections

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Deliver 5-item FAQ accordion, full-width CTA banner, 5-column footer with social SVG icons.

**Acceptance Criteria:**

- [ ] FAQ: 5 items accordion — AnimatePresence height animation, ChevronDown rotates 180deg
- [ ] CTA: dark bg, heading+subtitle+2 buttons, orange glow blurs at corners
- [ ] Footer: 5-col grid — Brand + Product + Resources + Company + copyright
- [ ] Social icons: GitHub/Twitter/LinkedIn as inline SVG components

**Technical Notes:**

- FAQ open state: useState<string|null>. Social icons: hand-coded SVG paths.

**Dependencies:** Blocks: [None]. Blocked by: [DA-E34-02].

---

### DA-E49-08 — Set up i18n translation keys

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Define all landing.\* i18n keys so 11 sections are fully EN+VI translatable.

**Acceptance Criteria:**

- [ ] All user text uses t('landing.\*') — no hardcoded Vietnamese in JSX
- [ ] Namespaces: trustedBy, features._, stats._, howItWorks._, templates._, testimonials._, pricing._, faq._, cta._, footer.\*
- [ ] Hero CTA buttons use i18n keys
- [ ] CinematicHero hardcoded text moved to i18n
- [ ] Both EN and VI translation files have all keys

**Technical Notes:**

- Footer links + pricing features use returnObjects:true for array values.

**Dependencies:** Blocks: [DA-E49-01 through DA-E49-07]. Blocked by: [DA-E34-05].

---

### DA-E49-09 — Wire DashboardPage with auth-gating

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Integrate 11 landing sections into DashboardPage with auth-aware routing.

**Acceptance Criteria:**

- [ ] Guest: renders 11 sections (Hero→LogoWall→Features→Stats→HowItWorks→Templates→Testimonials→Pricing→FAQ→CTA→Footer)
- [ ] OWNER/MANAGER/CREATOR: navigate('/workspace', {replace:true})
- [ ] CLIENT: navigate('/portal', {replace:true}). ADMIN: navigate('/admin', {replace:true})
- [ ] Fallback roles: dashboard with welcome + KPI placeholder + task checklist
- [ ] useAuthStore() + useNavigate() with replace:true

**Technical Notes:**

- DashboardPage.tsx dual purpose: landing (guest) + dashboard (authenticated). No separate /landing route.
- Redirect on mount — no flash of landing page for authenticated users.

**Dependencies:** Blocks: [None]. Blocked by: [DA-E35-01, DA-E35-05, DA-E35-02, DA-E49-01 through DA-E49-08].

---
