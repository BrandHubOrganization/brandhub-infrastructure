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
| `AGENCY_OWNER`    | Creates workspace, manages team & clients, billing            |
| `ACCOUNT_MANAGER` | Manages assigned clients, reviews content, sends reports      |
| `CONTENT_CREATOR` | Creates AI content, manages knowledge base, schedules posts   |
| `BRAND_CLIENT`    | View-only client portal: approve/reject content, view reports |
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
| [DA-E03-01](#da-e03-01-list-and-group-all-60-use-cases-by-6-roles-admin-agency-owner-account-manager-content-creator-brand-client-guest) | List and group all 60 use cases by 6 roles (Admin, Agency Owner, Account Manager, Content Creator, Brand Client, Guest) | Phước (Publisher) | 🔴 Critical |
| [DA-E03-02](#da-e03-02-write-detailed-descriptions-for-uc-0120-admin-agency-owner-flows)                                                 | Write detailed descriptions for UC 01–20 (Admin + Agency Owner flows) — actor, description, main flow, alt flows        | Trung (Leader)    | 🔴 Critical |
| [DA-E03-03](#da-e03-03-write-detailed-descriptions-for-uc-2140-account-manager-content-creator-flows)                                    | Write detailed descriptions for UC 21–40 (Account Manager + Content Creator flows)                                      | Phước (Publisher) | 🔴 Critical |
| [DA-E03-04](#da-e03-04-write-detailed-descriptions-for-uc-4160-brand-client-social-publishing-flows)                                     | Write detailed descriptions for UC 41–60 (Brand Client + Social Publishing flows)                                       | Phước (Publisher) | 🟡 High     |
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
| [DA-E05-01](#da-e05-01-draw-system-architecture-overview-diagram-7-services-5-databases-rabbitmq-clients)                                           | Draw system architecture overview diagram (7 services + 5 databases + RabbitMQ + clients)                                          | Trung (Leader) | 🔴 Critical |
| [DA-E05-02](#da-e05-02-define-service-responsibilities-and-boundaries-what-each-of-the-7-services-does-and-does-not-do)                             | Define service responsibilities and boundaries (what each of the 7 services does and does NOT do)                                  | Trung (Leader) | 🔴 Critical |
| [DA-E05-03](#da-e05-03-draw-database-ownership-diagram-which-service-owns-which-db-cross-db-reference-strategy)                                     | Draw database ownership diagram (which service owns which DB, cross-DB reference strategy)                                         | Trung (Leader) | 🔴 Critical |
| [DA-E05-04](#da-e05-04-document-service-to-service-communication-rest-business-ai-rabbitmq-business-publisher-http-callback-publisher-business)     | Document service-to-service communication (REST: business-ai, RabbitMQ: business-publisher, HTTP callback: publisher-business)     | Trung (Leader) | 🔴 Critical |
| [DA-E05-05](#da-e05-05-write-architecture-decision-records-adrs-for-4-key-decisions-polyrepo-mongodbpostgresql-split-rabbitmq-spring-cloud-gateway) | Write Architecture Decision Records (ADRs) for 4 key decisions: polyrepo, MongoDB+PostgreSQL split, RabbitMQ, Spring Cloud Gateway | Trung (Leader) | 🔴 Critical |
| [DA-E05-06](#da-e05-06-draw-sequence-diagrams-for-4-core-flows-content-creation-approval-workflow-auto-publishing-oauth-token-refresh)              | Draw sequence diagrams for 4 core flows: content creation, approval workflow, auto-publishing, OAuth token refresh                 | Tuấn (AI)      | 🔴 Critical |
| [DA-E05-07](#da-e05-07-write-the-ai-architecture-section-in-the-technical-document-ai-service-internal-design-chromadb-schema-llm-routing-strategy) | Write the AI architecture section in the Technical Document (ai-service internal design, ChromaDB schema, LLM routing strategy)    | Tuấn (AI)      | 🟡 High     |
| [DA-E05-08](#da-e05-08-compile-full-technical-document-brandhubtechnicaldocumentmd)                                                                 | Compile full technical document (BrandHub_Technical_Document.md)                                                                   | Trung (Leader) | 🟡 High     |

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
| [DA-E06-08](#da-e06-08-write-database-access-rules-documentation-every-query-must-include-workspaceid-filter-brandclient-additionally-requires-clientid-filter) | Write database access rules documentation (every query must include workspaceId filter; BRAND_CLIENT additionally requires clientId filter) | Trung (Leader) | 🔴 Critical |

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
| [DA-E14-03](#da-e14-03-implement-client-isolation-for-brandclient-role) | Implement client isolation for BRAND_CLIENT (can only view data belonging to their own clientId) | Trung (Leader)    | 🔴 Critical |
| [DA-E14-04](#da-e14-04-write-permission-matrix-document)                | Write permission matrix document (6 roles x all endpoints = allowed/not allowed)                 | Phước (Publisher) | 🟢 Medium   |

> 🔀 **E14 đã dời sang Sprint 6** do Sprint 5 tập trung hoàn thành auth core (E12).

### EPIC E34 — Design System & Base Components 🔀

> Dời từ Sprint 12. Xem [Rebalance Log](Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4) trong Jira Audit.

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
| [DA-E14-03](#da-e14-03-implement-client-isolation-for-brandclient-role) | Implement client isolation for BRAND_CLIENT (can only view data belonging to their own clientId) | Trung (Leader)    | 🔴 Critical |
| [DA-E14-04](#da-e14-04-write-permission-matrix-document)                | Write permission matrix document (6 roles x all endpoints = allowed/not allowed)                 | Phước (Publisher) | 🟢 Medium   |

### EPIC E15 — Workspace Management

| Task ID                                                                 | Description                                                                    | Assignee       | Priority    |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------------------ | -------------- | ----------- |
| [DA-E15-01](#da-e15-01-implement-post-apiv1workspaces)                  | Implement POST /api/v1/workspaces (create new workspace, AGENCY_OWNER role)    | Trung (Leader) | 🔴 Critical |
| [DA-E15-02](#da-e15-02-implement-get-apiv1workspacesmine)               | Implement GET /api/v1/workspaces/mine (retrieve workspace of the current user) | Trung (Leader) | 🔴 Critical |
| [DA-E15-03](#da-e15-03-implement-post-apiv1workspacesidmembers)         | Implement POST /api/v1/workspaces/{id}/members (invite member via email)       | Trung (Leader) | 🔴 Critical |
| [DA-E15-04](#da-e15-04-implement-delete-apiv1workspacesidmembersuserid) | Implement DELETE /api/v1/workspaces/{id}/members/{userId} (remove a member)    | Trung (Leader) | 🟡 High     |
| [DA-E15-05](#da-e15-05-implement-workspace-settings)                    | Implement workspace settings (timezone, default platforms, report frequency)   | Trung (Leader) | 🟡 High     |

### EPIC E16 — Client & Agency Management

| Task ID                                                             | Description                                                                                | Assignee          | Priority    |
| ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | ----------------- | ----------- |
| [DA-E16-01](#da-e16-01-implement-post-apiv1clients)                 | Implement POST /api/v1/clients (AGENCY_OWNER creates a new brand client)                   | Phước (Publisher) | 🔴 Critical |
| [DA-E16-02](#da-e16-02-implement-put-apiv1clientsidassign)          | Implement PUT /api/v1/clients/{id}/assign (AGENCY_OWNER assigns an Account Manager)        | Phước (Publisher) | 🔴 Critical |
| [DA-E16-03](#da-e16-03-implement-put-apiv1clientsidservice-package) | Implement PUT /api/v1/clients/{id}/service-package (set monthly post limits and platforms) | Phước (Publisher) | 🟡 High     |
| [DA-E16-04](#da-e16-04-implement-get-apiv1clients)                  | Implement GET /api/v1/clients (AGENCY_OWNER and ACCOUNT_MANAGER view client list)          | Phước (Publisher) | 🔴 Critical |

> **EPIC E17 — Subscription & Billing đã dời sang Sprint 9** 🔀 (xem [Rebalance Log](Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4) trong Jira Audit).

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
| [DA-E20-02](#da-e20-02-implement-token-refresh-failure-alert) | Implement alert notification when token refresh fails (send notification to Account Manager)           | Trung (Leader)    | 🔴 Critical |
| [DA-E20-03](#da-e20-03-implement-manual-token-refresh-api)    | Implement manual token refresh API (Account Manager triggers refresh manually)                         | Phước (Publisher) | 🟡 High     |

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

> Dời từ Sprint 6. Xem [Rebalance Log](Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4) trong Jira Audit.

| Task ID                                                             | Description                                                                        | Assignee       | Priority    |
| ------------------------------------------------------------------- | ---------------------------------------------------------------------------------- | -------------- | ----------- |
| [DA-E17-01](#da-e17-01-implement-admin-crud-for-subscription-plans) | Implement Admin CRUD for subscription plans (Free/Basic/Pro/Enterprise)            | Trung (Leader) | 🔴 Critical |
| [DA-E17-02](#da-e17-02-implement-post-apiv1subscriptionssubscribe)  | Implement POST /api/v1/subscriptions/subscribe (AGENCY_OWNER subscribes to a plan) | Trung (Leader) | 🔴 Critical |
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

> **Mở rộng theo kiến trúc v2.0 (Self-Hosted Architecture):** Triển khai Self-Hosted SDXL + LoRA Serving Engine (SDXL-Lightning 4-step), Form-to-Prompt Engine (Core UX), Batch Concurrency, Brand Safety Guardrails, Benchmark 20 Prompts, Dataset Preparation, LoRA Fine-Tuning & Dynamic Loading. Toàn bộ hình ảnh thương mại được sinh độc lập trên cụm GPU riêng qua HTTP Adapter, loại bỏ hoàn toàn phụ thuộc vào Cloud API bên thứ 3 (Stability AI). Phân bổ nhân sự: Lộc (Backend/Client Adapter), Ân (Prompt/Safety/Dataset), Tuấn (GPU Serving/LoRA).

| Task ID | Description | Assignee | Priority |
| :--- | :--- | :--- | :--- |
| [DA-AI06-01](#da-ai06-01--self-hosted-sdxl-inference-client-adapter) | Self-Hosted SDXL Inference Client Adapter (HTTP to GPU Server, error handling) | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI06-02](#da-ai06-02--aspect-ratio--sdxl-pixel-bucketing-engine) | Aspect Ratio & SDXL Pixel Bucketing Engine (1:1, 4:3, 16:9, 9:16, 2:3, 21:9) | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI06-03](#da-ai06-03--visual-style-preset-mapping-engine) | Visual Style Preset Mapping Engine (Photographic, Luxury, Minimalist Studio, Flat-lay) | Ân (AI) | 🟡 High |
| [DA-AI06-04](#da-ai06-04--form-to-prompt-engine-core-ux-feature) | Form-to-Prompt Engine (Core UX: Fast Rule Synthesizer & LLM Commercial Expander) | Ân (AI) | 🔴 Critical |
| [DA-AI06-05](#da-ai06-05--pydantic-schemas--post-aiimagegenerate-route) | Pydantic Schemas & POST /ai/image/generate Route | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI06-06](#da-ai06-06--in-memory-streaming-s3-upload--presigned-urls) | In-Memory Streaming S3 Upload & Presigned URLs (24h expiry, zero disk I/O) | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI06-07](#da-ai06-07--latency-tracking-custom-headers--observability) | Latency Tracking, Custom Response Headers & Observability (P95 < 30s SLO) | Lộc (Sub-lead) | 🟡 High |
| [DA-AI06-08](#da-ai06-08--concurrent-generation-orchestration-via-asynciogather) | Concurrent Generation Orchestration via asyncio.gather (1-4 variations, default 3) | Lộc (Sub-lead) | 🟡 High |
| [DA-AI06-09](#da-ai06-09--seed-diversity--visual-variation-strategy) | Seed Diversity & Visual Variation Strategy (Angle & Lighting diversity) | Ân (AI) | 🟡 High |
| [DA-AI06-10](#da-ai06-10--partial-failure-handling--credit-safety) | Partial Failure Handling & Credit Safety Audit (Only bill successful images) | Lộc (Sub-lead) | 🟡 High |
| [DA-AI06-11](#da-ai06-11--multi-tier-safety-negative-prompt-injection) | Multi-tier Safety Negative Prompt Injection (Prepend BRAND_SAFETY_NEGATIVE_PROMPT) | Ân (AI) | 🔴 Critical |
| [DA-AI06-12](#da-ai06-12--input-sanitization--blacklist-guardrails) | Input Sanitization & Blacklist Guardrails (Regex & Prompt Injection Jailbreak Scanner) | Ân (AI) | 🔴 Critical |
| [DA-AI06-13](#da-ai06-13--20-commercial-product-prompts-dataset-across-5-categories) | 20 Commercial Product Prompts Dataset Across 5 Categories (Benchmark dataset) | Ân (AI) | 🟡 High |
| [DA-AI06-14](#da-ai06-14--automated-benchmark-runner--latencyquality-metrics) | Automated Benchmark Runner & Latency/Quality Metrics (Automated evaluation script) | Lộc (Sub-lead) | 🟡 High |
| [DA-AI06-15](#da-ai06-15--prompt-template-library--sdxl-failure-analysis-report) | Prompt Template Library & SDXL Failure Analysis Report (Top 10 templates, 5 failure modes) | Ân (AI) | 🟡 High |
| [DA-AI06-16](#da-ai06-16--local--server-sdxl-model-serving-diffuserscomfyui-engine) | Local / Server SDXL Model Serving (Diffusers/ComfyUI Engine, SDXL-Lightning 4-step) | Tuấn (AI) | 🟡 High |
| [DA-AI06-17](#da-ai06-17--training-dataset-collection--quality-curation) | Training Dataset Collection & Quality Curation (120-150 commercial images 1024x1024) | Ân (AI) | 🟡 High |
| [DA-AI06-18](#da-ai06-18--automated--manual-dataset-captioning-pipeline) | Automated & Manual Dataset Captioning Pipeline (WD14 Tagger / Vision LLM + Trigger word) | Ân (AI) | 🟡 High |
| [DA-AI06-19](#da-ai06-19--brand-visual-identity-lora-fine-tuning-execution) | Brand Visual Identity LoRA Fine-Tuning Execution (Kohya_ss / Diffusers, rank 32, alpha 16) | Tuấn (AI) | 🟡 High |
| [DA-AI06-20](#da-ai06-20--lora-dynamic-loading--multi-lora-inference-engine) | LoRA Dynamic Loading & Multi-LoRA Inference Engine (S3 caching, Diffusers adapter hot-swap) | Tuấn & Lộc | 🟡 High |

### EPIC AI-07 — Virtual Brand Ambassador (InstantID) 🔀

> **Mở rộng theo kiến trúc v2.0 (Self-Hosted RealVisXL + InstantID Serving Engine):** Phân rã toàn diện pipeline đại sứ thương hiệu ảo sang cụm GPU Server RTX 4090 (24GB VRAM). Tích hợp Base Model RealVisXL V4.0 (loại bỏ anime-bias/da tượng sáp), IdentityNet 5 điểm landmarks, IP-Adapter Image Projector, InsightFace buffalo_l in-memory preprocessing, bộ lọc 4 edge cases thị giác (Fail-fast HTTP 422), Pydantic Schemas & Server-Timing, Cosine Similarity Gating (≥ 0.85), S3 Gallery CRUD multi-tenant, bóc nền Singleton qua rembg U2Net, ghép phối sáng tự nhiên, 5 phong cách thương mại, model guardrails chống dị tật, kiểm thử 15 ảnh đa góc và benchmark đối đầu 20 ảnh với IP-Adapter FaceID-Plus v2. Phân bổ nhân sự cân bằng: Lộc (Backend/S3/Compositing - 5 tasks), Tuấn (GPU Serving/Model Engine/Benchmark - 4 tasks), Ân (Face Preprocess/Prompt UX/Testing - 6 tasks).

| Task ID | Description | Assignee | Priority |
| :--- | :--- | :--- | :--- |
| [DA-AI07-01](#da-ai07-01--model-weights--checkpoints-management-realvisxl-identitynet-ip-adapter-insightface) | Model Weights & Checkpoints Management (RealVisXL V4.0, IdentityNet, IP-Adapter, InsightFace) | Tuấn (AI) | 🔴 Critical |
| [DA-AI07-02](#da-ai07-02--in-memory-face-preprocessing--512-dim-embedding-extraction) | In-Memory Face Preprocessing & 512-dim Embedding Extraction (OpenCV, InsightFace buffalo_l) | Ân (AI) | 🔴 Critical |
| [DA-AI07-03](#da-ai07-03--4-edge-case-visual-input-defense--fail-fast-guardrails) | 4-Edge-Case Visual Input Defense & Fail-Fast Guardrails (NoFace, MultiFace, ExtremePose, Blurry) | Ân (AI) | 🟡 High |
| [DA-AI07-04](#da-ai07-04--instantid-serving-pipeline-deployment-on-rtx-4090--vram-optimization) | InstantID Serving Pipeline Deployment on RTX 4090 & VRAM Optimization (SDPA, VAE tiling, < 15s) | Tuấn (AI) | 🔴 Critical |
| [DA-AI07-05](#da-ai07-05--golden-parameter-calibration-strength-conditioning-scale-cfg-steps) | Golden Parameter Calibration (Strength 0.78, Scale 0.80, CFG 5.0, 30 steps) | Tuấn (AI) | 🟡 High |
| [DA-AI07-06](#da-ai07-06--pydantic-schemas--post-aiambassadorgenerate-route) | Pydantic Schemas & POST /ai/ambassador/generate Route (Multipart upload, Server-Timing) | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI07-07](#da-ai07-07--face-consistency-metric-engine--cosine-similarity-gating--085) | Face Consistency Metric Engine & Cosine Similarity Gating (PASS ≥ 0.85, WARN, FAIL) | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI07-08](#da-ai07-08--ambassador-s3-gallery-management-crud-presigned-urls-1h) | Ambassador S3 Gallery Management (CRUD, Presigned URLs 1h, Multi-tenant) | Lộc (Sub-lead) | 🟡 High |
| [DA-AI07-09](#da-ai07-09--ambassador-singleton-background-removal-via-rembg-u2net) | Ambassador Singleton Background Removal via rembg (U2Net, alpha matting, < 1.5s) | Lộc (Sub-lead) | 🟡 High |
| [DA-AI07-10](#da-ai07-10--ambassador-background-placement-post-aiambassadorapply--natural-relighting) | Ambassador Background Placement POST /ai/ambassador/apply & Natural Relighting (Drop shadow) | Lộc (Sub-lead) | 🔴 Critical |
| [DA-AI07-11](#da-ai07-11--5-commercial-ambassador-style--wardrobe-presets) | 5 Commercial Ambassador Style & Wardrobe Presets (Fashion, Business, Casual, Sport, Luxury) | Ân (AI) | 🟡 High |
| [DA-AI07-12](#da-ai07-12--multi-tier-model-guardrails--anti-plastic-negative-prompts) | Multi-tier Model Guardrails & Anti-Plastic Negative Prompts (Hands, eyes, skin texture) | Ân (AI) | 🔴 Critical |
| [DA-AI07-13](#da-ai07-13--multi-angle-face-consistency-benchmark-15-images--86-pass--085) | Multi-Angle Face Consistency Benchmark (15 Images, 5 angles x 3 outfits, ≥ 86% Pass ≥ 0.85) | Ân (AI) | 🔴 Critical |
| [DA-AI07-14](#da-ai07-14--empirical-benchmark-instantid-vs-ip-adapter-faceid-plus-v2-20-images) | Empirical Benchmark: InstantID vs IP-Adapter FaceID-Plus v2 (20 Images, 4 evaluation metrics) | Tuấn (AI) | 🟡 High |
| [DA-AI07-15](#da-ai07-15--5-master-commercial-ambassador-templates--operational-guide) | 5 Master Commercial Ambassador Templates & Operational Guide (Starter configs & GPU guide) | Ân (AI) | 🟢 Low |

### EPIC AI-08 — Image Composition Pipeline 🔀

> Chuyển từ Lộc. Xem [Rebalance Log](Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4) trong Jira Audit.

| Task ID                                                                                                               | Description                                                                                                       | Assignee  | Priority    |
| --------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------- | ----------- |
| [DA-AI08-01](#da-ai08-01-implement-background-removal-for-product-images-rembg-u2net-output-transparent-png)          | Implement background removal for product images (rembg library, U2Net model) → output transparent PNG             | Tuấn (AI) | 🔴 Critical |
| [DA-AI08-02](#da-ai08-02-implement-background-removal-for-modelambassador-images)                                     | Implement background removal for model/ambassador images                                                          | Tuấn (AI) | 🔴 Critical |
| [DA-AI08-03](#da-ai08-03-build-layer-compositing-service-product-layer-model-layer-background-layer-pillow-composite) | Build layer compositing service (product layer + model layer + background layer → single image using Pillow)      | Tuấn (AI) | 🔴 Critical |
| [DA-AI08-04](#da-ai08-04-implement-shadow-lighting-adjustment-for-natural-looking-merges)                             | Implement shadow + lighting adjustment for natural-looking merges                                                 | Tuấn (AI) | 🟡 High     |
| [DA-AI08-05](#da-ai08-05-build-post-aicompose-endpoint)                                                               | Build composition endpoint (POST /ai/compose: product S3 key + model S3 key + background S3 key → composed image) | Tuấn (AI) | 🔴 Critical |
| [DA-AI08-06](#da-ai08-06-test-20-product-model-pairs-evaluate-realism-document-failure-cases)                         | Test 20 product + model pairs, evaluate realism score, document failure cases                                     | Tuấn (AI) | 🟡 High     |
| [DA-AI08-07](#da-ai08-07-write-composition-parameter-guide-optimal-image-sizes-best-practices-per-product-category)   | Write composition parameter guide (optimal sizes, best practices per product type)                                | Tuấn (AI) | 🟢 Low      |

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

### EPIC E28 — Content Request Management

| Task ID                                                      | Description                                                                                                            | Assignee       | Priority    |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------- | -------------- | ----------- |
| [DA-E28-01](#da-e28-01-implement-post-apiv1content-requests) | Implement POST /api/v1/content-requests (BRAND_CLIENT submits request: topic, platform, tone, deadline)                | Trung (Leader) | 🔴 Critical |
| [DA-E28-02](#da-e28-02-implement-get-apiv1content-requests)  | Implement GET /api/v1/content-requests (ACCOUNT_MANAGER views list of requests from their assigned clients)            | Trung (Leader) | 🔴 Critical |
| [DA-E28-03](#da-e28-03-implement-status-transition-logic)    | Implement status tracking (SUBMITTED → ASSIGNED → IN_PROGRESS → PENDING_REVIEW → SENT_TO_CLIENT → APPROVED → REJECTED) | Trung (Leader) | 🔴 Critical |

### EPIC E29 — Task Assignment & Tracking

| Task ID                                                             | Description                                                                                          | Assignee       | Priority    |
| ------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- | -------------- | ----------- |
| [DA-E29-01](#da-e29-01-implement-put-apiv1content-requestsidassign) | Implement PUT /api/v1/content-requests/{id}/assign (ACCOUNT_MANAGER assigns task to CONTENT_CREATOR) | Trung (Leader) | 🔴 Critical |
| [DA-E29-02](#da-e29-02-implement-get-apiv1content-requestsmy-tasks) | Implement GET /api/v1/content-requests/my-tasks (CONTENT_CREATOR views their assigned tasks)         | Trung (Leader) | 🔴 Critical |
| [DA-E29-03](#da-e29-03-implement-deadline-alert-notification)       | Implement deadline management (alert when a task is approaching its deadline)                        | Ân (AI)        | 🟡 High     |

### EPIC E30 — Content Calendar & Scheduling

| Task ID                                                       | Description                                                                                               | Assignee          | Priority    |
| ------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E30-01](#da-e30-01-implement-get-apiv1postscalendar)      | Implement GET /api/v1/posts/calendar (retrieve posts by date range, filter by platform/status)            | Trung (Leader)    | 🔴 Critical |
| [DA-E30-02](#da-e30-02-implement-post-apiv1postsidschedule)   | Implement POST /api/v1/posts/{id}/schedule (ACCOUNT_MANAGER sets schedule: scheduledAt + targetPlatforms) | Trung (Leader)    | 🔴 Critical |
| [DA-E30-03](#da-e30-03-build-contentcalendar-react-component) | Build ContentCalendar React component (drag-drop rescheduling, color-coded status indicators)             | Lộc (AI Sub-lead) | 🔴 Critical |
| [DA-E30-04](#da-e30-04-build-platformpreview-component)       | Build PlatformPreview component (display preview in the correct format for FB, IG, TikTok, Threads)       | Lộc (AI Sub-lead) | 🟡 High     |

---

## Sprint 11 — Approval Workflow & Full Publishing (Weeks 21–22)

### EPIC E31 — Approval Workflow

| Task ID                                                           | Description                                                                                   | Assignee       | Priority    |
| ----------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | -------------- | ----------- |
| [DA-E31-01](#da-e31-01-implement-post-apiv1postsidsubmit)         | Implement POST /api/v1/posts/{id}/submit (CONTENT_CREATOR submits → PENDING_REVIEW)           | Trung (Leader) | 🔴 Critical |
| [DA-E31-02](#da-e31-02-implement-post-apiv1postsidaccount-review) | Implement POST /api/v1/posts/{id}/account-review (ACCOUNT_MANAGER approves or rejects + note) | Trung (Leader) | 🔴 Critical |
| [DA-E31-03](#da-e31-03-implement-post-apiv1postsidclient-approve) | Implement POST /api/v1/posts/{id}/client-approve (BRAND_CLIENT approves → SCHEDULED)          | Trung (Leader) | 🔴 Critical |
| [DA-E31-04](#da-e31-04-implement-post-apiv1postsidclient-reject)  | Implement POST /api/v1/posts/{id}/client-reject (BRAND_CLIENT rejects + feedback)             | Trung (Leader) | 🔴 Critical |

### EPIC E32 — Publishing System

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

### EPIC E33 — Publish Error Handling

| Task ID                                                       | Description                                                                                        | Assignee          | Priority    |
| ------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- | ----------------- | ----------- |
| [DA-E33-01](#da-e33-01-implement-retry-logic)                 | Implement retry logic (up to 3 attempts, exponential backoff: 30s, 60s, 120s)                      | Phước (Publisher) | 🔴 Critical |
| [DA-E33-02](#da-e33-02-implement-dead-letter-queue-admin-api) | Implement Dead Letter Queue handler (Admin can view and manually retry or discard failed posts)    | Trung (Leader)    | 🔴 Critical |
| [DA-E33-03](#da-e33-03-implement-failure-notification)        | Implement failure notification (send alert to Account Manager when a post fails after all retries) | Trung (Leader)    | 🔴 Critical |

---

## PHASE 6 — Frontend & Analytics

> **CHÍNH SÁCH MỚI (2026-09-03):** Từ giai đoạn tiếp theo trở đi, KHÔNG tách epic/task FE riêng nữa. FE tích hợp chung vào task BE tương ứng (1 task = làm API + build page/component đi kèm luôn) — team làm song song BE với FE trong cùng 1 task cho đơn giản, thay vì tách 2 task riêng (1 BE + 1 FE) như E35/E36 trước đây. Áp dụng từ Sprint 8 trở đi — E37 Client Portal là epic FE cuối cùng còn tách riêng, đã move vào Sprint 8.

---

## Sprint 12 — Core Pages (Weeks 23–24)

> **EPIC E34 — Design System đã dời lên Sprint 5** 🔀 (xem [Rebalance Log](Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4) trong Jira Audit).
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
| [DA-E38-03](#da-e38-03-implement-scheduled-report-email-sending)  | Implement report email sending (automatically send email to Brand Client on schedule)                 | Ân (AI)           | 🟡 High     |
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
| [DA-E40-05](#da-e40-05-build-approval-screen-mobile)     | Build Approval screen for BRAND_CLIENT (view preview, approve/reject)                         | Phước (Publisher) | 🔴 Critical |
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

## PHASE 8 — Sprint Reporting

---

## EPIC E47 — Sprint Reports & Documentation

> **Note:** Runs at the end of every sprint (Sprint 1–16). Each sprint has 7 tasks: 5 individual member reports, 1 team report review by Trung, 1 commit/finalize task.

### Sprint 1 Report

| Task ID                                                                                | Description                                                       | Assignee          | Priority  |
| -------------------------------------------------------------------------------------- | ----------------------------------------------------------------- | ----------------- | --------- |
| [DA-E47-01](#da-e47-01-write-individual-sprint-report-for-sprint-1-trung)              | Write individual sprint report for Sprint 1 — Trung               | Trung (Leader)    | 🟢 Medium |
| [DA-E47-02](#da-e47-02-write-individual-sprint-report-for-sprint-1-lộc)                | Write individual sprint report for Sprint 1 — Lộc                 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E47-03](#da-e47-03-write-individual-sprint-report-for-sprint-1-tuấn)               | Write individual sprint report for Sprint 1 — Tuấn                | Tuấn (AI)         | 🟢 Medium |
| [DA-E47-04](#da-e47-04-write-individual-sprint-report-for-sprint-1-ân)                 | Write individual sprint report for Sprint 1 — Ân                  | Ân (AI)           | 🟢 Medium |
| [DA-E47-05](#da-e47-05-write-individual-sprint-report-for-sprint-1-phước)              | Write individual sprint report for Sprint 1 — Phước               | Phước (Publisher) | 🟢 Medium |
| [DA-E47-06](#da-e47-06-review-all-member-reports-write-team-sprintreport-for-sprint-1) | Review all member reports + write team SPRINT_REPORT for Sprint 1 | Trung (Leader)    | 🟢 Medium |
| [DA-E47-07](#da-e47-07-finalize-and-commit-sprint-1-report-to-brandhub-infrastructure) | Finalize and commit Sprint 1 report to brandhub-infrastructure    | Trung (Leader)    | 🟢 Medium |

### Sprint 2 Report

| Task ID                                                                                | Description                                                       | Assignee          | Priority  |
| -------------------------------------------------------------------------------------- | ----------------------------------------------------------------- | ----------------- | --------- |
| [DA-E47-08](#da-e47-08-write-individual-sprint-report-for-sprint-2-trung)              | Write individual sprint report for Sprint 2 — Trung               | Trung (Leader)    | 🟢 Medium |
| [DA-E47-09](#da-e47-09-write-individual-sprint-report-for-sprint-2-lộc)                | Write individual sprint report for Sprint 2 — Lộc                 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E47-10](#da-e47-10-write-individual-sprint-report-for-sprint-2-tuấn)               | Write individual sprint report for Sprint 2 — Tuấn                | Tuấn (AI)         | 🟢 Medium |
| [DA-E47-11](#da-e47-11-write-individual-sprint-report-for-sprint-2-ân)                 | Write individual sprint report for Sprint 2 — Ân                  | Ân (AI)           | 🟢 Medium |
| [DA-E47-12](#da-e47-12-write-individual-sprint-report-for-sprint-2-phước)              | Write individual sprint report for Sprint 2 — Phước               | Phước (Publisher) | 🟢 Medium |
| [DA-E47-13](#da-e47-13-review-all-member-reports-write-team-sprintreport-for-sprint-2) | Review all member reports + write team SPRINT_REPORT for Sprint 2 | Trung (Leader)    | 🟢 Medium |
| [DA-E47-14](#da-e47-14-finalize-and-commit-sprint-2-report-to-brandhub-infrastructure) | Finalize and commit Sprint 2 report to brandhub-infrastructure    | Trung (Leader)    | 🟢 Medium |

### Sprint 3 Report

| Task ID                                                                                | Description                                                       | Assignee          | Priority  |
| -------------------------------------------------------------------------------------- | ----------------------------------------------------------------- | ----------------- | --------- |
| [DA-E47-15](#da-e47-15-write-individual-sprint-report-for-sprint-3-trung)              | Write individual sprint report for Sprint 3 — Trung               | Trung (Leader)    | 🟢 Medium |
| [DA-E47-16](#da-e47-16-write-individual-sprint-report-for-sprint-3-lộc)                | Write individual sprint report for Sprint 3 — Lộc                 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E47-17](#da-e47-17-write-individual-sprint-report-for-sprint-3-tuấn)               | Write individual sprint report for Sprint 3 — Tuấn                | Tuấn (AI)         | 🟢 Medium |
| [DA-E47-18](#da-e47-18-write-individual-sprint-report-for-sprint-3-ân)                 | Write individual sprint report for Sprint 3 — Ân                  | Ân (AI)           | 🟢 Medium |
| [DA-E47-19](#da-e47-19-write-individual-sprint-report-for-sprint-3-phước)              | Write individual sprint report for Sprint 3 — Phước               | Phước (Publisher) | 🟢 Medium |
| [DA-E47-20](#da-e47-20-review-all-member-reports-write-team-sprintreport-for-sprint-3) | Review all member reports + write team SPRINT_REPORT for Sprint 3 | Trung (Leader)    | 🟢 Medium |
| [DA-E47-21](#da-e47-21-finalize-and-commit-sprint-3-report-to-brandhub-infrastructure) | Finalize and commit Sprint 3 report to brandhub-infrastructure    | Trung (Leader)    | 🟢 Medium |

### Sprint 4 Report

| Task ID                                                                                | Description                                                       | Assignee          | Priority  |
| -------------------------------------------------------------------------------------- | ----------------------------------------------------------------- | ----------------- | --------- |
| [DA-E47-22](#da-e47-22-write-individual-sprint-report-for-sprint-4-trung)              | Write individual sprint report for Sprint 4 — Trung               | Trung (Leader)    | 🟢 Medium |
| [DA-E47-23](#da-e47-23-write-individual-sprint-report-for-sprint-4-lộc)                | Write individual sprint report for Sprint 4 — Lộc                 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E47-24](#da-e47-24-write-individual-sprint-report-for-sprint-4-tuấn)               | Write individual sprint report for Sprint 4 — Tuấn                | Tuấn (AI)         | 🟢 Medium |
| [DA-E47-25](#da-e47-25-write-individual-sprint-report-for-sprint-4-ân)                 | Write individual sprint report for Sprint 4 — Ân                  | Ân (AI)           | 🟢 Medium |
| [DA-E47-26](#da-e47-26-write-individual-sprint-report-for-sprint-4-phước)              | Write individual sprint report for Sprint 4 — Phước               | Phước (Publisher) | 🟢 Medium |
| [DA-E47-27](#da-e47-27-review-all-member-reports-write-team-sprintreport-for-sprint-4) | Review all member reports + write team SPRINT_REPORT for Sprint 4 | Trung (Leader)    | 🟢 Medium |
| [DA-E47-28](#da-e47-28-finalize-and-commit-sprint-4-report-to-brandhub-infrastructure) | Finalize and commit Sprint 4 report to brandhub-infrastructure    | Trung (Leader)    | 🟢 Medium |

### Sprint 5 Report

| Task ID                                                                                | Description                                                       | Assignee          | Priority  |
| -------------------------------------------------------------------------------------- | ----------------------------------------------------------------- | ----------------- | --------- |
| [DA-E47-29](#da-e47-29-write-individual-sprint-report-for-sprint-5-trung)              | Write individual sprint report for Sprint 5 — Trung               | Trung (Leader)    | 🟢 Medium |
| [DA-E47-30](#da-e47-30-write-individual-sprint-report-for-sprint-5-lộc)                | Write individual sprint report for Sprint 5 — Lộc                 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E47-31](#da-e47-31-write-individual-sprint-report-for-sprint-5-tuấn)               | Write individual sprint report for Sprint 5 — Tuấn                | Tuấn (AI)         | 🟢 Medium |
| [DA-E47-32](#da-e47-32-write-individual-sprint-report-for-sprint-5-ân)                 | Write individual sprint report for Sprint 5 — Ân                  | Ân (AI)           | 🟢 Medium |
| [DA-E47-33](#da-e47-33-write-individual-sprint-report-for-sprint-5-phước)              | Write individual sprint report for Sprint 5 — Phước               | Phước (Publisher) | 🟢 Medium |
| [DA-E47-34](#da-e47-34-review-all-member-reports-write-team-sprintreport-for-sprint-5) | Review all member reports + write team SPRINT_REPORT for Sprint 5 | Trung (Leader)    | 🟢 Medium |
| [DA-E47-35](#da-e47-35-finalize-and-commit-sprint-5-report-to-brandhub-infrastructure) | Finalize and commit Sprint 5 report to brandhub-infrastructure    | Trung (Leader)    | 🟢 Medium |

### Sprint 6 Report

| Task ID                                                                                | Description                                                       | Assignee          | Priority  |
| -------------------------------------------------------------------------------------- | ----------------------------------------------------------------- | ----------------- | --------- |
| [DA-E47-36](#da-e47-36-write-individual-sprint-report-for-sprint-6-trung)              | Write individual sprint report for Sprint 6 — Trung               | Trung (Leader)    | 🟢 Medium |
| [DA-E47-37](#da-e47-37-write-individual-sprint-report-for-sprint-6-lộc)                | Write individual sprint report for Sprint 6 — Lộc                 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E47-38](#da-e47-38-write-individual-sprint-report-for-sprint-6-tuấn)               | Write individual sprint report for Sprint 6 — Tuấn                | Tuấn (AI)         | 🟢 Medium |
| [DA-E47-39](#da-e47-39-write-individual-sprint-report-for-sprint-6-ân)                 | Write individual sprint report for Sprint 6 — Ân                  | Ân (AI)           | 🟢 Medium |
| [DA-E47-40](#da-e47-40-write-individual-sprint-report-for-sprint-6-phước)              | Write individual sprint report for Sprint 6 — Phước               | Phước (Publisher) | 🟢 Medium |
| [DA-E47-41](#da-e47-41-review-all-member-reports-write-team-sprintreport-for-sprint-6) | Review all member reports + write team SPRINT_REPORT for Sprint 6 | Trung (Leader)    | 🟢 Medium |
| [DA-E47-42](#da-e47-42-finalize-and-commit-sprint-6-report-to-brandhub-infrastructure) | Finalize and commit Sprint 6 report to brandhub-infrastructure    | Trung (Leader)    | 🟢 Medium |

### Sprint 7 Report

| Task ID                                                                                | Description                                                       | Assignee          | Priority  |
| -------------------------------------------------------------------------------------- | ----------------------------------------------------------------- | ----------------- | --------- |
| [DA-E47-43](#da-e47-43-write-individual-sprint-report-for-sprint-7-trung)              | Write individual sprint report for Sprint 7 — Trung               | Trung (Leader)    | 🟢 Medium |
| [DA-E47-44](#da-e47-44-write-individual-sprint-report-for-sprint-7-lộc)                | Write individual sprint report for Sprint 7 — Lộc                 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E47-45](#da-e47-45-write-individual-sprint-report-for-sprint-7-tuấn)               | Write individual sprint report for Sprint 7 — Tuấn                | Tuấn (AI)         | 🟢 Medium |
| [DA-E47-46](#da-e47-46-write-individual-sprint-report-for-sprint-7-ân)                 | Write individual sprint report for Sprint 7 — Ân                  | Ân (AI)           | 🟢 Medium |
| [DA-E47-47](#da-e47-47-write-individual-sprint-report-for-sprint-7-phước)              | Write individual sprint report for Sprint 7 — Phước               | Phước (Publisher) | 🟢 Medium |
| [DA-E47-48](#da-e47-48-review-all-member-reports-write-team-sprintreport-for-sprint-7) | Review all member reports + write team SPRINT_REPORT for Sprint 7 | Trung (Leader)    | 🟢 Medium |
| [DA-E47-49](#da-e47-49-finalize-and-commit-sprint-7-report-to-brandhub-infrastructure) | Finalize and commit Sprint 7 report to brandhub-infrastructure    | Trung (Leader)    | 🟢 Medium |

### Sprint 8 Report

| Task ID                                                                                | Description                                                       | Assignee          | Priority  |
| -------------------------------------------------------------------------------------- | ----------------------------------------------------------------- | ----------------- | --------- |
| [DA-E47-50](#da-e47-50-write-individual-sprint-report-for-sprint-8-trung)              | Write individual sprint report for Sprint 8 — Trung               | Trung (Leader)    | 🟢 Medium |
| [DA-E47-51](#da-e47-51-write-individual-sprint-report-for-sprint-8-lộc)                | Write individual sprint report for Sprint 8 — Lộc                 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E47-52](#da-e47-52-write-individual-sprint-report-for-sprint-8-tuấn)               | Write individual sprint report for Sprint 8 — Tuấn                | Tuấn (AI)         | 🟢 Medium |
| [DA-E47-53](#da-e47-53-write-individual-sprint-report-for-sprint-8-ân)                 | Write individual sprint report for Sprint 8 — Ân                  | Ân (AI)           | 🟢 Medium |
| [DA-E47-54](#da-e47-54-write-individual-sprint-report-for-sprint-8-phước)              | Write individual sprint report for Sprint 8 — Phước               | Phước (Publisher) | 🟢 Medium |
| [DA-E47-55](#da-e47-55-review-all-member-reports-write-team-sprintreport-for-sprint-8) | Review all member reports + write team SPRINT_REPORT for Sprint 8 | Trung (Leader)    | 🟢 Medium |
| [DA-E47-56](#da-e47-56-finalize-and-commit-sprint-8-report-to-brandhub-infrastructure) | Finalize and commit Sprint 8 report to brandhub-infrastructure    | Trung (Leader)    | 🟢 Medium |

### Sprint 9 Report

| Task ID                                                                                | Description                                                       | Assignee          | Priority  |
| -------------------------------------------------------------------------------------- | ----------------------------------------------------------------- | ----------------- | --------- |
| [DA-E47-57](#da-e47-57-write-individual-sprint-report-for-sprint-9-trung)              | Write individual sprint report for Sprint 9 — Trung               | Trung (Leader)    | 🟢 Medium |
| [DA-E47-58](#da-e47-58-write-individual-sprint-report-for-sprint-9-lộc)                | Write individual sprint report for Sprint 9 — Lộc                 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E47-59](#da-e47-59-write-individual-sprint-report-for-sprint-9-tuấn)               | Write individual sprint report for Sprint 9 — Tuấn                | Tuấn (AI)         | 🟢 Medium |
| [DA-E47-60](#da-e47-60-write-individual-sprint-report-for-sprint-9-ân)                 | Write individual sprint report for Sprint 9 — Ân                  | Ân (AI)           | 🟢 Medium |
| [DA-E47-61](#da-e47-61-write-individual-sprint-report-for-sprint-9-phước)              | Write individual sprint report for Sprint 9 — Phước               | Phước (Publisher) | 🟢 Medium |
| [DA-E47-62](#da-e47-62-review-all-member-reports-write-team-sprintreport-for-sprint-9) | Review all member reports + write team SPRINT_REPORT for Sprint 9 | Trung (Leader)    | 🟢 Medium |
| [DA-E47-63](#da-e47-63-finalize-and-commit-sprint-9-report-to-brandhub-infrastructure) | Finalize and commit Sprint 9 report to brandhub-infrastructure    | Trung (Leader)    | 🟢 Medium |

### Sprint 10 Report

| Task ID                                                                                 | Description                                                        | Assignee          | Priority  |
| --------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | ----------------- | --------- |
| [DA-E47-64](#da-e47-64-write-individual-sprint-report-for-sprint-10-trung)              | Write individual sprint report for Sprint 10 — Trung               | Trung (Leader)    | 🟢 Medium |
| [DA-E47-65](#da-e47-65-write-individual-sprint-report-for-sprint-10-lộc)                | Write individual sprint report for Sprint 10 — Lộc                 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E47-66](#da-e47-66-write-individual-sprint-report-for-sprint-10-tuấn)               | Write individual sprint report for Sprint 10 — Tuấn                | Tuấn (AI)         | 🟢 Medium |
| [DA-E47-67](#da-e47-67-write-individual-sprint-report-for-sprint-10-ân)                 | Write individual sprint report for Sprint 10 — Ân                  | Ân (AI)           | 🟢 Medium |
| [DA-E47-68](#da-e47-68-write-individual-sprint-report-for-sprint-10-phước)              | Write individual sprint report for Sprint 10 — Phước               | Phước (Publisher) | 🟢 Medium |
| [DA-E47-69](#da-e47-69-review-all-member-reports-write-team-sprintreport-for-sprint-10) | Review all member reports + write team SPRINT_REPORT for Sprint 10 | Trung (Leader)    | 🟢 Medium |
| [DA-E47-70](#da-e47-70-finalize-and-commit-sprint-10-report-to-brandhub-infrastructure) | Finalize and commit Sprint 10 report to brandhub-infrastructure    | Trung (Leader)    | 🟢 Medium |

### Sprint 11 Report

| Task ID                                                                                 | Description                                                        | Assignee          | Priority  |
| --------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | ----------------- | --------- |
| [DA-E47-71](#da-e47-71-write-individual-sprint-report-for-sprint-11-trung)              | Write individual sprint report for Sprint 11 — Trung               | Trung (Leader)    | 🟢 Medium |
| [DA-E47-72](#da-e47-72-write-individual-sprint-report-for-sprint-11-lộc)                | Write individual sprint report for Sprint 11 — Lộc                 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E47-73](#da-e47-73-write-individual-sprint-report-for-sprint-11-tuấn)               | Write individual sprint report for Sprint 11 — Tuấn                | Tuấn (AI)         | 🟢 Medium |
| [DA-E47-74](#da-e47-74-write-individual-sprint-report-for-sprint-11-ân)                 | Write individual sprint report for Sprint 11 — Ân                  | Ân (AI)           | 🟢 Medium |
| [DA-E47-75](#da-e47-75-write-individual-sprint-report-for-sprint-11-phước)              | Write individual sprint report for Sprint 11 — Phước               | Phước (Publisher) | 🟢 Medium |
| [DA-E47-76](#da-e47-76-review-all-member-reports-write-team-sprintreport-for-sprint-11) | Review all member reports + write team SPRINT_REPORT for Sprint 11 | Trung (Leader)    | 🟢 Medium |
| [DA-E47-77](#da-e47-77-finalize-and-commit-sprint-11-report-to-brandhub-infrastructure) | Finalize and commit Sprint 11 report to brandhub-infrastructure    | Trung (Leader)    | 🟢 Medium |

### Sprint 12 Report

| Task ID                                                                                 | Description                                                        | Assignee          | Priority  |
| --------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | ----------------- | --------- |
| [DA-E47-78](#da-e47-78-write-individual-sprint-report-for-sprint-12-trung)              | Write individual sprint report for Sprint 12 — Trung               | Trung (Leader)    | 🟢 Medium |
| [DA-E47-79](#da-e47-79-write-individual-sprint-report-for-sprint-12-lộc)                | Write individual sprint report for Sprint 12 — Lộc                 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E47-80](#da-e47-80-write-individual-sprint-report-for-sprint-12-tuấn)               | Write individual sprint report for Sprint 12 — Tuấn                | Tuấn (AI)         | 🟢 Medium |
| [DA-E47-81](#da-e47-81-write-individual-sprint-report-for-sprint-12-ân)                 | Write individual sprint report for Sprint 12 — Ân                  | Ân (AI)           | 🟢 Medium |
| [DA-E47-82](#da-e47-82-write-individual-sprint-report-for-sprint-12-phước)              | Write individual sprint report for Sprint 12 — Phước               | Phước (Publisher) | 🟢 Medium |
| [DA-E47-83](#da-e47-83-review-all-member-reports-write-team-sprintreport-for-sprint-12) | Review all member reports + write team SPRINT_REPORT for Sprint 12 | Trung (Leader)    | 🟢 Medium |
| [DA-E47-84](#da-e47-84-finalize-and-commit-sprint-12-report-to-brandhub-infrastructure) | Finalize and commit Sprint 12 report to brandhub-infrastructure    | Trung (Leader)    | 🟢 Medium |

### Sprint 13 Report

| Task ID                                                                                 | Description                                                        | Assignee          | Priority  |
| --------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | ----------------- | --------- |
| [DA-E47-85](#da-e47-85-write-individual-sprint-report-for-sprint-13-trung)              | Write individual sprint report for Sprint 13 — Trung               | Trung (Leader)    | 🟢 Medium |
| [DA-E47-86](#da-e47-86-write-individual-sprint-report-for-sprint-13-lộc)                | Write individual sprint report for Sprint 13 — Lộc                 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E47-87](#da-e47-87-write-individual-sprint-report-for-sprint-13-tuấn)               | Write individual sprint report for Sprint 13 — Tuấn                | Tuấn (AI)         | 🟢 Medium |
| [DA-E47-88](#da-e47-88-write-individual-sprint-report-for-sprint-13-ân)                 | Write individual sprint report for Sprint 13 — Ân                  | Ân (AI)           | 🟢 Medium |
| [DA-E47-89](#da-e47-89-write-individual-sprint-report-for-sprint-13-phước)              | Write individual sprint report for Sprint 13 — Phước               | Phước (Publisher) | 🟢 Medium |
| [DA-E47-90](#da-e47-90-review-all-member-reports-write-team-sprintreport-for-sprint-13) | Review all member reports + write team SPRINT_REPORT for Sprint 13 | Trung (Leader)    | 🟢 Medium |
| [DA-E47-91](#da-e47-91-finalize-and-commit-sprint-13-report-to-brandhub-infrastructure) | Finalize and commit Sprint 13 report to brandhub-infrastructure    | Trung (Leader)    | 🟢 Medium |

### Sprint 14 Report

| Task ID                                                                                 | Description                                                        | Assignee          | Priority  |
| --------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | ----------------- | --------- |
| [DA-E47-92](#da-e47-92-write-individual-sprint-report-for-sprint-14-trung)              | Write individual sprint report for Sprint 14 — Trung               | Trung (Leader)    | 🟢 Medium |
| [DA-E47-93](#da-e47-93-write-individual-sprint-report-for-sprint-14-lộc)                | Write individual sprint report for Sprint 14 — Lộc                 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E47-94](#da-e47-94-write-individual-sprint-report-for-sprint-14-tuấn)               | Write individual sprint report for Sprint 14 — Tuấn                | Tuấn (AI)         | 🟢 Medium |
| [DA-E47-95](#da-e47-95-write-individual-sprint-report-for-sprint-14-ân)                 | Write individual sprint report for Sprint 14 — Ân                  | Ân (AI)           | 🟢 Medium |
| [DA-E47-96](#da-e47-96-write-individual-sprint-report-for-sprint-14-phước)              | Write individual sprint report for Sprint 14 — Phước               | Phước (Publisher) | 🟢 Medium |
| [DA-E47-97](#da-e47-97-review-all-member-reports-write-team-sprintreport-for-sprint-14) | Review all member reports + write team SPRINT_REPORT for Sprint 14 | Trung (Leader)    | 🟢 Medium |
| [DA-E47-98](#da-e47-98-finalize-and-commit-sprint-14-report-to-brandhub-infrastructure) | Finalize and commit Sprint 14 report to brandhub-infrastructure    | Trung (Leader)    | 🟢 Medium |

### Sprint 15 Report

| Task ID                                                                                   | Description                                                        | Assignee          | Priority  |
| ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | ----------------- | --------- |
| [DA-E47-99](#da-e47-99-write-individual-sprint-report-for-sprint-15-trung)                | Write individual sprint report for Sprint 15 — Trung               | Trung (Leader)    | 🟢 Medium |
| [DA-E47-100](#da-e47-100-write-individual-sprint-report-for-sprint-15-lộc)                | Write individual sprint report for Sprint 15 — Lộc                 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E47-101](#da-e47-101-write-individual-sprint-report-for-sprint-15-tuấn)               | Write individual sprint report for Sprint 15 — Tuấn                | Tuấn (AI)         | 🟢 Medium |
| [DA-E47-102](#da-e47-102-write-individual-sprint-report-for-sprint-15-ân)                 | Write individual sprint report for Sprint 15 — Ân                  | Ân (AI)           | 🟢 Medium |
| [DA-E47-103](#da-e47-103-write-individual-sprint-report-for-sprint-15-phước)              | Write individual sprint report for Sprint 15 — Phước               | Phước (Publisher) | 🟢 Medium |
| [DA-E47-104](#da-e47-104-review-all-member-reports-write-team-sprintreport-for-sprint-15) | Review all member reports + write team SPRINT_REPORT for Sprint 15 | Trung (Leader)    | 🟢 Medium |
| [DA-E47-105](#da-e47-105-finalize-and-commit-sprint-15-report-to-brandhub-infrastructure) | Finalize and commit Sprint 15 report to brandhub-infrastructure    | Trung (Leader)    | 🟢 Medium |

### Sprint 16 Report

| Task ID                                                                                   | Description                                                        | Assignee          | Priority  |
| ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | ----------------- | --------- |
| [DA-E47-106](#da-e47-106-write-individual-sprint-report-for-sprint-16-trung)              | Write individual sprint report for Sprint 16 — Trung               | Trung (Leader)    | 🟢 Medium |
| [DA-E47-107](#da-e47-107-write-individual-sprint-report-for-sprint-16-lộc)                | Write individual sprint report for Sprint 16 — Lộc                 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E47-108](#da-e47-108-write-individual-sprint-report-for-sprint-16-tuấn)               | Write individual sprint report for Sprint 16 — Tuấn                | Tuấn (AI)         | 🟢 Medium |
| [DA-E47-109](#da-e47-109-write-individual-sprint-report-for-sprint-16-ân)                 | Write individual sprint report for Sprint 16 — Ân                  | Ân (AI)           | 🟢 Medium |
| [DA-E47-110](#da-e47-110-write-individual-sprint-report-for-sprint-16-phước)              | Write individual sprint report for Sprint 16 — Phước               | Phước (Publisher) | 🟢 Medium |
| [DA-E47-111](#da-e47-111-review-all-member-reports-write-team-sprintreport-for-sprint-16) | Review all member reports + write team SPRINT_REPORT for Sprint 16 | Trung (Leader)    | 🟢 Medium |
| [DA-E47-112](#da-e47-112-finalize-and-commit-sprint-16-report-to-brandhub-infrastructure) | Finalize and commit Sprint 16 report to brandhub-infrastructure    | Trung (Leader)    | 🟢 Medium |

---

## EPIC E48 — AI Track Reports & Documentation

> **Note:** Runs at the end of every AI Parallel Track iteration (Iteration 1–4). Each iteration has 5 tasks: 3 individual member reports (Tuấn, Ân, Lộc), 1 team report review by Lộc, 1 commit/finalize task. Mirrors E47's pattern but scoped to the AI track — Lộc plays the same aggregator role here that Trung plays in E47.

### Iteration 1 Report

| Task ID                                                                                      | Description                                                             | Assignee          | Priority  |
| -------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- | ----------------- | --------- |
| [DA-E48-01](#da-e48-01-write-individual-ai-iteration-report-for-iteration-1-tuấn)            | Write individual AI iteration report for Iteration 1 — Tuấn             | Tuấn (AI)         | 🟢 Medium |
| [DA-E48-02](#da-e48-02-write-individual-ai-iteration-report-for-iteration-1-ân)              | Write individual AI iteration report for Iteration 1 — Ân               | Ân (AI)           | 🟢 Medium |
| [DA-E48-03](#da-e48-03-write-individual-ai-iteration-report-for-iteration-1-lộc)             | Write individual AI iteration report for Iteration 1 — Lộc              | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E48-04](#da-e48-04-review-all-member-reports-write-team-iterationreport-for-iteration-1) | Review all member reports + write team ITERATION_REPORT for Iteration 1 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E48-05](#da-e48-05-finalize-and-commit-iteration-1-report-to-brandhub-infrastructure)    | Finalize and commit Iteration 1 report to brandhub-infrastructure       | Lộc (AI Sub-lead) | 🟢 Medium |

### Iteration 2 Report

| Task ID                                                                                      | Description                                                             | Assignee          | Priority  |
| -------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- | ----------------- | --------- |
| [DA-E48-06](#da-e48-06-write-individual-ai-iteration-report-for-iteration-2-tuấn)            | Write individual AI iteration report for Iteration 2 — Tuấn             | Tuấn (AI)         | 🟢 Medium |
| [DA-E48-07](#da-e48-07-write-individual-ai-iteration-report-for-iteration-2-ân)              | Write individual AI iteration report for Iteration 2 — Ân               | Ân (AI)           | 🟢 Medium |
| [DA-E48-08](#da-e48-08-write-individual-ai-iteration-report-for-iteration-2-lộc)             | Write individual AI iteration report for Iteration 2 — Lộc              | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E48-09](#da-e48-09-review-all-member-reports-write-team-iterationreport-for-iteration-2) | Review all member reports + write team ITERATION_REPORT for Iteration 2 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E48-10](#da-e48-10-finalize-and-commit-iteration-2-report-to-brandhub-infrastructure)    | Finalize and commit Iteration 2 report to brandhub-infrastructure       | Lộc (AI Sub-lead) | 🟢 Medium |

### Iteration 3 Report

| Task ID                                                                                      | Description                                                             | Assignee          | Priority  |
| -------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- | ----------------- | --------- |
| [DA-E48-11](#da-e48-11-write-individual-ai-iteration-report-for-iteration-3-tuấn)            | Write individual AI iteration report for Iteration 3 — Tuấn             | Tuấn (AI)         | 🟢 Medium |
| [DA-E48-12](#da-e48-12-write-individual-ai-iteration-report-for-iteration-3-ân)              | Write individual AI iteration report for Iteration 3 — Ân               | Ân (AI)           | 🟢 Medium |
| [DA-E48-13](#da-e48-13-write-individual-ai-iteration-report-for-iteration-3-lộc)             | Write individual AI iteration report for Iteration 3 — Lộc              | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E48-14](#da-e48-14-review-all-member-reports-write-team-iterationreport-for-iteration-3) | Review all member reports + write team ITERATION_REPORT for Iteration 3 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E48-15](#da-e48-15-finalize-and-commit-iteration-3-report-to-brandhub-infrastructure)    | Finalize and commit Iteration 3 report to brandhub-infrastructure       | Lộc (AI Sub-lead) | 🟢 Medium |

### Iteration 4 Report

| Task ID                                                                                      | Description                                                             | Assignee          | Priority  |
| -------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- | ----------------- | --------- |
| [DA-E48-16](#da-e48-16-write-individual-ai-iteration-report-for-iteration-4-tuấn)            | Write individual AI iteration report for Iteration 4 — Tuấn             | Tuấn (AI)         | 🟢 Medium |
| [DA-E48-17](#da-e48-17-write-individual-ai-iteration-report-for-iteration-4-ân)              | Write individual AI iteration report for Iteration 4 — Ân               | Ân (AI)           | 🟢 Medium |
| [DA-E48-18](#da-e48-18-write-individual-ai-iteration-report-for-iteration-4-lộc)             | Write individual AI iteration report for Iteration 4 — Lộc              | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E48-19](#da-e48-19-review-all-member-reports-write-team-iterationreport-for-iteration-4) | Review all member reports + write team ITERATION_REPORT for Iteration 4 | Lộc (AI Sub-lead) | 🟢 Medium |
| [DA-E48-20](#da-e48-20-finalize-and-commit-iteration-4-report-to-brandhub-infrastructure)    | Finalize and commit Iteration 4 report to brandhub-infrastructure       | Lộc (AI Sub-lead) | 🟢 Medium |

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
| Sprint 2  | 3–4   | Requirements   | 60 Use Cases documented, architecture diagrams, ADRs, Capstone form                  |
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

> **Cập nhật sau Sprint 4** 🔀 — bảng dưới phản ánh phân bổ **mới** sau khi tái cân bằng. Bảng gốc (trước rebalance) đã lưu trong [Rebalance Log](Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4) của `Jira_Status_Audit_2026-07-11.md` để đối chiếu.

| Member | Role                                    | Tasks (mới) | Key Responsibilities                                                                                                                                                          |
| ------ | --------------------------------------- | ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Trung  | Leader / Business Service               | ~64         | Project init, system architecture, API Gateway, Auth, RBAC, Workspace, Client, Subscription (dời S6→S9), Content workflow, Approval, Notification, Deployment, Final report   |
| Phước  | Publisher Engineer / Frontend+Mobile UI | ~52         | Use case docs, social platform API specs, RabbitMQ, permission matrix, publisher-service + 5 platform adapters, **toàn bộ Web Dashboard UI (E34–E39) + Mobile App (E40–E41)** |
| Lộc    | AI Sub-lead                             | ~35         | AI service infra setup, S3 helper, RAG pipeline hỗ trợ, AI endpoint finalize/docs — **không còn task Frontend/Mobile**                                                        |
| Tuấn   | AI Engineer                             | ~31         | Sequence diagrams, DB indexing, ChromaDB design, RAG embedding, InstantID Ambassador (AI-07), **Image Composition Pipeline (AI-08, nhận từ Lộc)**                             |
| Ân     | AI Engineer                             | ~41         | Non-functional AI reqs, Redis key doc, RAG chunking, LLM prompt system, trend crawler, video generation (Veo), **Image Generation Pipeline (AI-06, nhận từ Lộc)**             |

> **Total tasks:** 406 task gốc + 17 task phát sinh 🆕 + 7 task phân tích/thiết kế AI-4.99 🆕 = 430 task (tổng không đổi sau rebalance — chỉ đổi người và vị trí sprint). Xem [Phần 3 — Task phát sinh](#phần-3--tổng-hợp-task-phát-sinh-ngoài-plan-gốc) để biết lý do phát sinh từng task, và [Rebalance Log](Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4) trong Jira Audit để biết lý do tái phân bổ.

---

## NOTES

- English is the standard language for all task descriptions, documentation, and project artifacts to ensure consistency across tools such as Linear, GitHub Issues, and Excel.
- "All (Team)" assignee means the task requires participation from all members (e.g., meetings, joint reviews, E2E testing).
- AI Parallel Track epics run concurrently with main sprints; timelines are aligned by sprint week ranges.
- Priority 🔴 Critical tasks must be unblocked first in each sprint before 🟡 High tasks begin.
- Task IDs follow format: DA-{EPIC_ID}-{SEQ} (e.g., DA-E01-01, DA-AI07-03).

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
- [ ] MVP feature list maps to at least one use case per role (Admin, Agency Owner, Account Manager, Content Creator, Brand Client, Guest)

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

### DA-E03-01 — List and group all 60 use cases by 6 roles (Admin, Agency Owner, Account Manager, Content Creator, Brand Client, Guest)

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Produce a complete, numbered, role-grouped use case inventory that gives every team member a shared reference for what BrandHub must do before any detailed writing begins.

**Acceptance Criteria:**

- [ ] Exactly 60 use cases are listed, each with a unique ID (UC-01 through UC-60)
- [ ] Each use case is assigned to exactly one primary role (Admin, Agency Owner, Account Manager, Content Creator, Brand Client, or Guest)
- [ ] The list is stored in a shared document and accessible to the full team for review and comment

**Technical Notes:**

- Group use cases in blocks by role rather than interleaving to make the split for DA-E03-02, DA-E03-03, DA-E03-04 clean and non-overlapping

**Dependencies:** Blocks: DA-E03-02, DA-E03-03, DA-E03-04, DA-E03-06. Blocked by: DA-E01-01.

---

### DA-E03-02 — Write detailed descriptions for UC 01–20 (Admin + Agency Owner flows)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Produce fully described use cases for UC-01 through UC-20 so that Admin and Agency Owner feature requirements are unambiguous for backend developers implementing those flows.

**Acceptance Criteria:**

- [ ] Each of UC-01 to UC-20 includes: Actor, Preconditions, Main Flow (numbered steps), Alternative Flows, and Postconditions
- [ ] Admin use cases cover at minimum: user management, subscription management, platform configuration, audit log review
- [ ] Agency Owner use cases cover at minimum: workspace creation, member invitation, client onboarding, subscription tier management

**Technical Notes:**

- Reference the role enum values exactly as they appear in the JWT: ADMIN, AGENCY_OWNER — these must match any permission checks in business-service

**Dependencies:** Blocks: DA-E03-05, DA-E04-01. Blocked by: DA-E03-01.

---

### DA-E03-03 — Write detailed descriptions for UC 21–40 (Account Manager + Content Creator flows)

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Produce fully described use cases for UC-21 through UC-40 covering the core day-to-day content workflow so developers building content and approval features have precise requirements.

**Acceptance Criteria:**

- [ ] Each of UC-21 to UC-40 includes: Actor, Preconditions, Main Flow, Alternative Flows, and Postconditions
- [ ] Account Manager use cases cover at minimum: assigning content to creators, reviewing drafts, managing approval workflows, reporting to clients
- [ ] Content Creator use cases cover at minimum: AI content generation, image generation, draft editing, submitting for approval, scheduling posts

**Technical Notes:**

- The approval workflow use case must clearly distinguish between ACCOUNT_MANAGER approval and BRAND_CLIENT approval as separate states
- AI generation steps in creator flows must specify which ai-service endpoint is called (e.g., /ai/content, /ai/image)

**Dependencies:** Blocks: DA-E03-05, DA-E04-01. Blocked by: DA-E03-01.

---

### DA-E03-04 — Write detailed descriptions for UC 41–60 (Brand Client + Social Publishing flows)

**Assignee:** Phước (Publisher) | **Priority:** 🟡 High

**Goal:** Produce fully described use cases for UC-41 through UC-60 covering Brand Client portal interactions and automated social publishing so the publisher-service and client portal are built to spec.

**Acceptance Criteria:**

- [ ] Each of UC-41 to UC-60 includes: Actor, Preconditions, Main Flow, Alternative Flows, and Postconditions
- [ ] Brand Client use cases cover at minimum: viewing content calendar, approving/rejecting posts, viewing analytics
- [ ] Social publishing use cases cover at minimum: scheduling a post, RabbitMQ-triggered publish job, callback on success/failure, retry on failure

**Technical Notes:**

- Publishing flow use cases must reference the RabbitMQ message contract defined in DA-E07-03 once available; flag any assumptions made before that task completes
- Brand Client flows must note that all data access is scoped by both workspaceId and clientId per the access rules in DA-E06-08

**Dependencies:** Blocks: DA-E03-05, DA-E04-01. Blocked by: DA-E03-01.

---

### DA-E03-05 — Review UC list with mentor, update based on feedback

**Assignee:** All (Team) | **Priority:** 🟡 High

**Goal:** Validate the full 60-use-case set with the assigned mentor to catch scope, feasibility, or completeness issues before the team invests effort writing detailed requirements documents.

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
- [ ] All 60 use cases are present with no blank required fields
- [ ] File is uploaded to the shared project folder and linked from the project wiki

**Dependencies:** Blocks: None. Blocked by: DA-E03-05.

---

### DA-E04-01 — Write functional objectives per role (6 roles x features)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Translate the approved use cases into a concise functional requirements section organized by role so that each team member has a definitive feature checklist for their implementation work.

**Acceptance Criteria:**

- [ ] Functional objectives exist for all 6 roles: ADMIN, AGENCY_OWNER, ACCOUNT_MANAGER, CONTENT_CREATOR, BRAND_CLIENT, GUEST
- [ ] Each role section lists its features as testable "The system shall…" statements
- [ ] Every functional objective traces back to at least one UC ID from the approved use case list

**Technical Notes:**

- Use the exact role names from the JWT claim (ADMIN, AGENCY_OWNER, etc.) throughout to ensure naming consistency with the implementation

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
- [ ] Approval workflow sequence diagram covers: creator submits → account manager reviews → optional brand client approval → status transitions and notifications at each step
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

### DA-E06-08 — Write database access rules documentation (every query must include workspaceId filter; BRAND_CLIENT additionally requires clientId filter)

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Document mandatory data access rules as a non-negotiable implementation contract so that no developer accidentally builds a query that can leak data across workspaces or client accounts.

**Acceptance Criteria:**

- [ ] Rule 1 is documented: every MongoDB query on a multi-tenant collection must include `{ workspaceId: <value> }` as a filter condition — no exceptions
- [ ] Rule 2 is documented: all queries executed in the context of a BRAND_CLIENT role must additionally filter by `{ clientId: <value> }`
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
- [ ] Each wireframe shows the layout for both the primary user role and any role-specific variations (e.g., Content Editor view for CONTENT_CREATOR vs. review view for ACCOUNT_MANAGER)
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

**Goal:** Design the BRAND_CLIENT-facing portal screens so the team has a clear, minimal interface target for the client-facing features that differ significantly from the internal agency dashboard.

**Acceptance Criteria:**

- [ ] Read-only content calendar wireframe shows: monthly/weekly view, post status indicators, post detail preview panel (text + image, no edit controls)
- [ ] Approve/reject interaction is wireframed: approve button, reject with required comment field, confirmation state
- [ ] Analytics view wireframe shows: reach/impressions/engagement metrics per platform, date range selector, export button placeholder

**Technical Notes:**

- Client portal must be visually distinct from the agency dashboard — consider a stripped navigation (no workspace switcher, no AI tools) to reinforce the limited-access context for the BRAND_CLIENT role
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

**Goal:** Cập nhật lại các diagram/DBML/HTML mô tả database sau khi schema thay đổi (users, workspaces, workspace_members, clients chuyển từ MongoDB sang PostgreSQL — xem `DA-E06-01_Database_Strategy.md`), để tài liệu khớp với schema thật.

**Acceptance Criteria:**

- [ ] `brandhub_dbml.dbml` phản ánh đúng 11 bảng PostgreSQL + 8 collection MongoDB hiện tại
- [ ] `brandhub_db_ownership_diagram.html` và `brandhub_schema_diagram.html` cập nhật khớp DBML mới

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
- [ ] User document is saved with default role AGENCY_OWNER and isActive=true

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
- [ ] If Google email does not exist in MongoDB, a new User document is created (role=AGENCY_OWNER, no password field)
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

### DA-E11-14 — Add all JPA models from database schema for business-service + repository layer _(phát sinh, ngoài plan gốc — gắn sai epic trên Jira)_

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Tạo toàn bộ JPA entity classes cho 11 bảng PostgreSQL (theo `brandhub_dbml.dbml`) và Spring Data JPA repository tương ứng cho từng entity, làm nền tảng data layer cho business-service trước khi code Auth/RBAC/Workspace.

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

### DA-E14-01 — Write @RequireRole Annotation and AOP Aspect

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Implement a declarative, annotation-driven role enforcement mechanism for all controller endpoints using Spring AOP.

**Acceptance Criteria:**

- [ ] `@RequireRole({"AGENCY_OWNER", "ACCOUNT_MANAGER"})` annotation is defined and applicable at method and class level
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

### DA-E14-03 — Implement Client Isolation for BRAND_CLIENT Role

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Ensure users with the BRAND_CLIENT role can only access data belonging to their own clientId, enforced at the query layer.

**Acceptance Criteria:**

- [ ] All MongoDB queries executed in a BRAND_CLIENT session include both `workspaceId` and `clientId` filters
- [ ] A BRAND_CLIENT user attempting to access another client's data receives 403 Forbidden, not 404 or 200
- [ ] `clientId` is stored in the User document and included in the JWT payload for BRAND_CLIENT users
- [ ] Integration test verifies BRAND_CLIENT user cannot read posts, analytics, or reports of a sibling client in the same workspace
- [ ] AGENCY_OWNER and ACCOUNT_MANAGER roles are NOT subject to the clientId filter (they see all clients in their workspace)

**Technical Notes:**

- Extend the `WorkspaceContext` holder from DA-E14-02 to also carry an optional `clientId`
- In the repository layer, check if the calling role is BRAND_CLIENT and conditionally append the `clientId` filter — this can be done in a base repository method
- Consider a custom `@ClientScoped` annotation on repository methods that must enforce client isolation, making enforcement explicit and auditable

**Dependencies:** Blocks: [None]. Blocked by: [DA-E14-02].

---

### DA-E14-04 — Write Permission Matrix Document

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Document the complete access control matrix mapping all 6 roles to every API endpoint so the team has a single source of truth for RBAC decisions.

**Acceptance Criteria:**

- [ ] Document covers all 6 roles: ADMIN, AGENCY_OWNER, ACCOUNT_MANAGER, CONTENT_CREATOR, PUBLISHER, BRAND_CLIENT
- [ ] Every API endpoint from epics E12–E24 is listed with allowed roles marked
- [ ] Document is stored in the project wiki or Confluence and linked from the main README
- [ ] Document is reviewed and signed off by Trung (Leader) before Sprint 6 begins
- [ ] Any discrepancy found between the document and code annotations is treated as a bug

**Dependencies:** Blocks: [None]. Blocked by: [DA-E14-01].

---

### DA-E15-01 — Implement POST /api/v1/workspaces

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow AGENCY_OWNER users to create a new workspace, which becomes the top-level container for all their clients and team members.

**Acceptance Criteria:**

- [ ] POST /api/v1/workspaces accepts {name, timezone, defaultPlatforms} and returns 201 with the created workspace document
- [ ] Only users with role AGENCY_OWNER may call this endpoint; others receive 403
- [ ] A user who already has a workspace receives 409 Conflict (one workspace per AGENCY_OWNER)
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

- [ ] POST /api/v1/workspaces/{id}/members accepts {email, role} where role is one of ACCOUNT_MANAGER, CONTENT_CREATOR, PUBLISHER, BRAND_CLIENT
- [ ] Only AGENCY_OWNER of that workspace may call this endpoint; 403 otherwise
- [ ] If the email is already a registered user, they are added to the workspace and notified via email
- [ ] If the email is not yet registered, a pending invitation record is created and an invitation email with a signup link is sent
- [ ] Inviting an email already in the workspace returns 409 Conflict
- [ ] Member count on the workspace document is incremented atomically

**Technical Notes:**

- Invitation token stored in Redis: `workspace:invite:{token}` → {workspaceId, email, role}, TTL = 7 days
- Use MongoDB `$inc` operator to increment `memberCount` atomically
- Subscription plan client limits apply: check current client count against plan limits before adding a BRAND_CLIENT role member

**Dependencies:** Blocks: [DA-E15-04]. Blocked by: [DA-E15-01, DA-E17-01].

---

### DA-E15-04 — Implement DELETE /api/v1/workspaces/{id}/members/{userId}

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Allow workspace owners to remove a member from their workspace, revoking their access immediately.

**Acceptance Criteria:**

- [ ] DELETE /api/v1/workspaces/{id}/members/{userId} removes the member and returns 204 No Content
- [ ] Only AGENCY_OWNER of that specific workspace may perform this action; 403 otherwise
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
- [ ] Only AGENCY_OWNER of the workspace may update settings; 403 otherwise
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

**Goal:** Allow AGENCY_OWNER to create a new brand client record within their workspace, subject to the subscription plan's client limit.

**Acceptance Criteria:**

- [ ] POST /api/v1/clients accepts {brandName, industry, logoUrl, contactEmail, allowedPlatforms} and returns 201 with the created client record
- [ ] Only AGENCY_OWNER may create clients; 403 otherwise
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

**Goal:** Allow AGENCY_OWNER to assign an Account Manager to a client, establishing the primary relationship for that client's day-to-day management.

**Acceptance Criteria:**

- [ ] PUT /api/v1/clients/{id}/assign accepts {accountManagerId} and returns 200 with updated client document
- [ ] Only AGENCY_OWNER may perform assignment; 403 otherwise
- [ ] The target userId must exist in the same workspace and have role ACCOUNT_MANAGER; invalid targets return 400
- [ ] The client document must belong to the caller's workspaceId; mismatched workspaceId returns 404 (do not leak existence)
- [ ] Re-assigning an already-assigned client replaces the previous Account Manager without error

**Technical Notes:**

- Workspace isolation filter (DA-E14-02) must be active; the query for the client record will automatically include `workspaceId`
- After assignment, notify the new Account Manager by email with client brand name and a link to the client dashboard

**Dependencies:** Blocks: [None]. Blocked by: [DA-E16-01, DA-E14-02].

---

### DA-E16-03 — Implement PUT /api/v1/clients/{id}/service-package

**Assignee:** Trung (Leader) | **Priority:** 🟡 High

**Goal:** Allow AGENCY_OWNER to configure monthly post limits and permitted social platforms for each individual client.

**Acceptance Criteria:**

- [ ] PUT /api/v1/clients/{id}/service-package accepts {monthlyPostLimit, allowedPlatforms} and returns 200 with updated client record
- [ ] Only AGENCY_OWNER may update service packages; 403 otherwise
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

**Goal:** Provide AGENCY_OWNER and ACCOUNT_MANAGER roles with a filtered, paginated list of clients in their workspace.

**Acceptance Criteria:**

- [ ] GET /api/v1/clients returns paginated list of clients scoped to the JWT's workspaceId
- [ ] AGENCY_OWNER sees all clients in the workspace; ACCOUNT_MANAGER sees only clients assigned to them
- [ ] Supports query params: `page`, `size`, `search` (partial brandName match), `platform` (filter by allowedPlatforms)
- [ ] BRAND_CLIENT role receives 403 on this endpoint (they use a different profile endpoint)
- [ ] Default page size is 20; maximum 100

**Technical Notes:**

- ACCOUNT_MANAGER filter: add `assignedAccountManagerId = currentUserId` condition alongside `workspaceId` filter — handled in the service layer by inspecting the caller's role
- Use `MongoTemplate` with a dynamic `Criteria` chain for combining optional filters cleanly

**Dependencies:** Blocks: [None]. Blocked by: [DA-E16-01, DA-E14-02].

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

**Goal:** Allow AGENCY_OWNER to initiate a plan subscription by creating a Stripe Checkout session and recording the pending subscription intent.

**Acceptance Criteria:**

- [ ] POST /api/v1/subscriptions/subscribe accepts {planId} and returns 200 with {checkoutUrl} to redirect the user to Stripe
- [ ] Only AGENCY_OWNER may subscribe; 403 for other roles
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
- [ ] `invoice.payment_failed` event sets subscription status to PAST_DUE and notifies the AGENCY_OWNER by email
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

**Goal:** Provide AGENCY_OWNER with a billing history showing past invoices retrieved from Stripe for their workspace.

**Acceptance Criteria:**

- [ ] GET /api/v1/subscriptions/invoices returns paginated list of invoices for the current workspace's Stripe customer
- [ ] Each invoice includes {invoiceId, amountUsd, status, paidAt, invoicePdfUrl, periodStart, periodEnd}
- [ ] Only AGENCY_OWNER may access billing history; 403 for other roles
- [ ] Workspace with no Stripe customer (Free plan, never subscribed) returns empty list, not 404
- [ ] Supports `limit` and `startingAfter` cursor params (maps to Stripe's native pagination)

**Technical Notes:**

- Use Stripe SDK `Invoice.list(params)` with `customer = stripeCustomerId`; do not store invoice data in MongoDB (always fetch live from Stripe)
- Map Stripe's `amount_due` (in cents) to USD by dividing by 100
- Cache results in Redis for 5 minutes (`invoices:{workspaceId}`) to avoid hammering the Stripe API

**Dependencies:** Blocks: [None]. Blocked by: [DA-E17-03].

---

### DA-E18-01 — Implement Facebook Fanpage OAuth Flow

**Assignee:** Phước (Publisher) | **Priority:** 🔴 Critical

**Goal:** Enable Account Managers to connect a Facebook Fanpage to a client, obtaining a long-lived page access token via OAuth.

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

**Goal:** Allow Account Managers to disconnect a social account by revoking the token at Meta's Graph API and removing the record from MongoDB.

**Acceptance Criteria:**

- [ ] DELETE /api/v1/social/accounts/{accountId} revokes the token at Meta Graph API (`DELETE /{user-id}/permissions`) then deletes the SocialAccount document; returns 204
- [ ] Only AGENCY_OWNER and ACCOUNT_MANAGER assigned to the client may disconnect; 403 otherwise
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
- [ ] BRAND_CLIENT role receives only their own clientId's accounts (clientId filter applied from DA-E14-03)
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

**Goal:** Notify the assigned Account Manager immediately when a token refresh fails so they can re-authenticate the social account before publishing is disrupted.

**Acceptance Criteria:**

- [ ] When a refresh job fails for an account, `tokenStatus` is updated to EXPIRING_SOON (if token not yet expired) or EXPIRED
- [ ] An email notification is sent to the Account Manager assigned to that client with: platform name, account display name, error reason, and a deep link to reconnect
- [ ] If no Account Manager is assigned, the notification is sent to the workspace AGENCY_OWNER instead
- [ ] Notifications are not duplicated: if a token has already sent a failure alert within the last 24 hours, suppress subsequent alerts until the token is refreshed or re-authenticated
- [ ] Notification suppression state is stored in Redis: `alert:token_fail:{accountId}`, TTL = 24 hours

**Technical Notes:**

- Emit a Spring `ApplicationEvent` (e.g., `TokenRefreshFailedEvent`) from the refresh job and handle it in a separate `@EventListener` — keeps the job logic clean
- Email template should include a clear call-to-action button; use Thymeleaf templates if already used elsewhere in the project

**Dependencies:** Blocks: [None]. Blocked by: [DA-E20-01].

---

### DA-E20-03 — Implement Manual Token Refresh API

**Assignee:** Phước (Publisher) | **Priority:** 🟡 High

**Goal:** Allow Account Managers to manually trigger a token refresh for a specific social account outside of the scheduled job cycle.

**Acceptance Criteria:**

- [ ] POST /api/v1/social/accounts/{accountId}/refresh triggers an immediate token refresh for the specified account; returns 200 with updated {tokenStatus, expiresAt}
- [ ] Only AGENCY_OWNER and ACCOUNT_MANAGER assigned to the client may trigger manual refresh; 403 otherwise
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

**Goal:** Provide the primary entry point for brand knowledge ingestion so enterprise brand clients can upload internal brand guidelines, product manuals, and PR reports with multi-tenant isolation.

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

- Pipeline Step: T2 (NLP Preprocessing Layer - Thiết kế tham chiếu `docs/AI_Models/DA-570_Text_Normalization_Pipeline_Design.md`).
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

- Pipeline Step: T4 (BM25 Spike Detection Layer - Thiết kế tham chiếu `docs/AI_Models/DA-568_Trend_Prediction_BM25_Design.md`).
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

- Pipeline Step: T7 (Fusion & Trend Assembly Layer - Thiết kế tham chiếu `docs/AI_Models/DA-569_Graph_Virality_Score_Design.md`).
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

### DA-AI06-01 — Self-Hosted SDXL Inference Client Adapter

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Xây dựng module client bất đồng bộ (`app/services/sdxl_client.py`) kết nối trực tiếp đến GPU Inference Server (chạy Diffusers/ComfyUI Engine từ task DA-AI06-16) bằng `httpx.AsyncClient` theo chuẩn Ponytail/YAGNI, loại bỏ hoàn toàn phụ thuộc vào Cloud API bên thứ 3 và hỗ trợ truyền tham số LoRA động.

**Acceptance Criteria:**

- [ ] Module `SDXLInferenceClient` khởi tạo nhận cấu hình `base_url = settings.sdxl_engine_url` và `api_token = settings.sdxl_engine_token` (nếu có).
- [ ] Hàm `generate_raw(prompt, negative_prompt, width, height, style_preset=None, seed=None, steps=4, cfg_scale=1.5, lora_id=None, lora_scale=0.8) -> tuple[bytes, int, str]` gửi request `POST {base_url}/generate` đến GPU Server.
- [ ] Nhận dữ liệu stream raw bytes PNG trực tiếp từ GPU Server, chuyển thành `bytes` PNG chuẩn (zero temporary disk write).
- [ ] Xử lý ngoại lệ kết nối & lỗi GPU Server:
  - HTTP 400 / 422: Ném `InvalidGenerationPayloadError` kèm log chi tiết lỗi tham số
  - HTTP 503 / Timeout: GPU Server đang quá tải, cold start hoặc không phản hồi -> Ném `GPUEngineUnavailableError`
  - HTTP 500 (CUDA OOM): Ném `GPUOutOfMemoryError` báo hiệu engine hết VRAM để retry hoặc báo log
  - Timeout cấu hình: `httpx.AsyncClient(timeout=60.0)` phù hợp với thời gian sinh ảnh SDXL-Lightning
- [ ] Hỗ trợ kiểm tra sức khỏe node GPU: Hàm `health_check() -> bool` gọi `GET {base_url}/health` để xác định GPU Worker đang sẵn sàng.
- [ ] Đạt 100% unit test với `pytest-httpx` mô phỏng phản hồi sinh ảnh thành công và các kịch bản lỗi mạng/GPU.

**Technical Notes:**

- Chuẩn Ponytail/YAGNI: Không cài thêm SDK nặng nề; chỉ dùng `httpx` tiêu chuẩn của FastAPI.
- Payload gọn nhẹ: `{"prompt": prompt, "negative_prompt": negative_prompt, "width": width, "height": height, "steps": steps, "seed": seed, "lora_id": lora_id, "lora_scale": lora_scale}`.

**Dependencies:** Blocked by: DA-AI06-16 (GPU Serving Engine). Blocks: DA-AI06-02, DA-AI06-05.

---

### DA-AI06-02 — Aspect Ratio & SDXL Pixel Bucketing Engine

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Chuẩn hóa các kích thước ảnh đầu vào theo cơ chế Pixel Bucketing chuẩn của SDXL 1.0 (tổng diện tích ~1 Megapixel = 1,048,576 pixels, kích thước mỗi chiều là bội số của 64) nhằm triệt tiêu hiện tượng méo hình, duplicate chủ thể hoặc sinh thêm chi thể lỗi.

**Acceptance Criteria:**

- [ ] Tạo module `app/utils/image_dimensions.py` chứa enum `AspectRatioEnum` và bảng ánh xạ chuẩn SDXL:
  - `1:1` (Square - Feed): `1024 x 1024` (1,048,576 px)
  - `4:3` (Standard Landscape): `1152 x 896` (1,032,192 px)
  - `3:4` (Standard Portrait): `896 x 1152` (1,032,192 px)
  - `16:9` (Widescreen - Youtube/Banner): `1344 x 768` (1,032,192 px)
  - `9:16` (Vertical Story/Reels/TikTok): `768 x 1344` (1,032,192 px)
  - `2:3` (Editorial Poster/Pinterest): `832 x 1216` (1,011,712 px)
  - `3:2` (Classic Photography): `1216 x 832` (1,011,712 px)
  - `21:9` (Cinematic Ultrawide): `1536 x 640` (983,040 px)
- [ ] Hàm `get_dimensions_by_aspect_ratio(ratio: str) -> tuple[int, int]` trả về `(width, height)`. Ném `ValueError` nếu tỷ lệ không hợp lệ
- [ ] Hàm hỗ trợ `snap_to_sdxl_bucket(target_width: int, target_height: int) -> tuple[int, int]` tìm bucket có tỷ lệ co dãn gần nhất
- [ ] Unit test xác nhận 100% kích thước đầu ra đều chia hết cho 64

**Technical Notes:**

- SDXL được train đa tỷ lệ (multi-aspect ratio). Nếu đưa kích thước tùy tiện lệch khỏi tập bucket chuẩn, SDXL sẽ bị suy giảm chất lượng rõ rệt.

**Dependencies:** Blocks: DA-AI06-05. Blocked by: None.

---

### DA-AI06-03 — Visual Style Preset Mapping Engine

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Quản lý danh mục các phong cách mỹ thuật thị giác, ánh xạ giữa preset phía client của BrandHub sang visual styles SDXL chuẩn (Photographic, Cinematic, Digital Art...), đồng thời bổ sung các style tokens chuyên biệt cho thương mại quảng cáo.

**Acceptance Criteria:**

- [ ] Tạo module `app/utils/style_presets.py` định nghĩa `StylePresetEnum` hỗ trợ các SDXL visual style presets chuẩn: `photographic`, `digital-art`, `cinematic`, `3d-model`, `origami`, `anime`, `analog-film`, `neon-punk`, `isometric`, `low-poly`, `line-art`, `craft-clay`
- [ ] Hỗ trợ nhóm **BrandHub Extended Presets** phục vụ chụp ảnh sản phẩm chuyên nghiệp:
  - `commercial-luxury`: Ánh xạ `style_preset="photographic"` + bổ sung: `"commercial luxury product photography, Hasselblad H6D-100c, studio softbox, award-winning advertising, clean background"`
  - `minimalist-studio`: Ánh xạ `style_preset="photographic"` + bổ sung: `"minimalist clean studio aesthetic, soft natural shadows, matte pastel podium, Scandinavian design vibe"`
  - `flat-lay-editorial`: Ánh xạ `style_preset="photographic"` + bổ sung: `"overhead flat-lay tabletop photography, neatly arranged lifestyle props, knolling composition, sharp focus"`
- [ ] Hàm `resolve_style_preset(preset_id: str) -> tuple[Optional[str], str, str]` trả về `(style_preset, positive_tokens, negative_tokens)`
- [ ] Expose endpoint metadata `GET /ai/image/presets` để Frontend tự động load danh sách styles kèm hình thumbnail mẫu và mô tả ngắn

**Technical Notes:**

- Giữ danh mục style có thể mở rộng qua file cấu hình `resources/image_styles.json`.

**Dependencies:** Blocks: DA-AI06-04, DA-AI06-05. Blocked by: None.

---

### DA-AI06-04 — Form-to-Prompt Engine (Core UX Feature)

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Xây dựng cấu trúc dữ liệu form nhập liệu trực quan từ UI và engine tự động tổng hợp (kết hợp Rule-based Template & LLM Dynamic Expander) thành Master Prompt tiếng Anh chuẩn studio thương mại, giúp người dùng không cần kỹ năng viết prompt phức tạp vẫn sinh ra ảnh đỉnh cao.

**Acceptance Criteria:**

- [ ] Thiết kế Pydantic schema `FormToPromptInput`:
  - `product_category`: Ngành hàng (FMCG, Mỹ phẩm, Thời trang, Công nghệ, Nội thất...)
  - `primary_subject`: Tên và mô tả chi tiết vật thể/sản phẩm chính
  - `setting_background`: Bối cảnh/không gian studio hoặc ngoại cảnh
  - `lighting_type`: Studio Softbox, Golden Hour, Rim Light, Neon...
  - `camera_angle`: Cận cảnh Eye-level Macro, Chụp từ trên xuống Flat-lay, Hero shot...
  - `color_scheme`: Bảng màu chủ đạo (Luxury Black & Gold, Pastel, Vibrant...)
  - `mood`: Cảm xúc thị giác (Thanh khiết, Sang trọng, Năng động...)
  - `extra_details`: Chi tiết phụ trợ (giọt nước đọng, khói mờ, cánh hoa rơi...)
- [ ] **Tier 1 (Fast Rule-based Synthesizer - Latency < 1ms):** Ghép nối có trật tự trọng số:
  `[Style Preset Master Token], [Camera Angle & Shot Type] of [Primary Subject], situated in [Setting Background], with [Extra Details], [Lighting Type], [Color Scheme], [Mood Atmosphere], commercial advertising photography, 8k resolution, shot on 85mm lens, f/2.8 aperture, photorealistic, pristine product detailing, high-end commercial print quality.`
- [ ] **Tier 2 (LLM Prompt Enhancer - Latency < 1.2s qua Groq Llama 3.3/Gemini Flash):** Khi user bật toggle `enhance_with_llm=True`, LLM tự động dịch thuật và làm giàu ngôn ngữ nhiếp ảnh chuyên nghiệp từ mô tả tiếng Việt sơ sài của user
- [ ] Trả về đối tượng `GeneratedPromptPair` gồm `master_positive_prompt` (độ dài 50-90 từ) và `suggested_negative_prompt`
- [ ] Đạt 100% test case cho 5 ngành hàng lớn: Mỹ phẩm, Đồ uống, Thời trang, Đồ công nghệ và Nội thất

**Technical Notes:**

- Tích hợp logic tại `app/services/prompt_builder_image.py`. Loại bỏ các filler words thừa thãi ("ultra 10000k") gây loãng CLIP embedding.

**Dependencies:** Blocked by: DA-AI06-03. Blocks: DA-AI06-05.

---

### DA-AI06-05 — Pydantic Schemas & POST /ai/image/generate Route

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Xây dựng API router và Data Contract kiểm duyệt dữ liệu đầu vào / đầu ra cho endpoint sinh ảnh đơn `POST /ai/image/generate`.

**Acceptance Criteria:**

- [ ] Định nghĩa `ImageGenerateRequest`:
  - `prompt`: `Optional[str]` (bắt buộc nếu không có `form_data`)
  - `form_data`: `Optional[FormToPromptInput]` (nếu có, tự động kích hoạt Form-to-Prompt Engine)
  - `negative_prompt`: `Optional[str] = None`
  - `style_preset`: `Optional[str] = "photographic"`
  - `aspect_ratio`: `str = "1:1"`
  - `client_id`: `str` (ID định danh thương hiệu)
  - `seed`: `Optional[int] = None`
  - `enhance_prompt`: `bool = False`
- [ ] Định nghĩa `ImageGenerateResponse`:
  - `image_url`: Presigned S3 URL (24h expiry)
  - `s3_key`: Đường dẫn S3
  - `seed`: Seed thực tế được sử dụng
  - `final_prompt`: Master prompt cuối cùng sau khi build
  - `style_preset`, `aspect_ratio`, `generation_time_ms`
- [ ] Đăng ký router `app/api/v1/endpoints/image.py` và gán vào `app/api/v1/router.py`
- [ ] Xử lý validation: Trả về HTTP 422 nếu cả `prompt` và `form_data` đều bị bỏ trống

**Technical Notes:**

- Sử dụng Pydantic v2 validator. Đảm bảo clean architecture giữa route layer và service layer.

**Dependencies:** Blocked by: DA-AI06-01, DA-AI06-02, DA-AI06-04. Blocks: DA-AI06-06.

---

### DA-AI06-06 — In-Memory Streaming S3 Upload & Presigned URLs

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Tiếp nhận luồng bytes trực tiếp từ SDXL GPU Server response và streaming thẳng lên AWS S3 mà không lưu file trung gian ra ổ đĩa máy chủ (zero disk I/O), sau đó cấp phát Presigned URL thời hạn 24h.

**Acceptance Criteria:**

- [ ] Nhận `bytes` ảnh từ Subtask 01, bọc vào `io.BytesIO(raw_png_bytes)`
- [ ] Quy tắc đặt key chuẩn trên S3: `generated/{client_id}/{YYYY-MM}/{uuid4}.png`
- [ ] Upload lên S3 với `ContentType="image/png"`. Tuyệt đối không ghi file tạm ra đĩa cục bộ
- [ ] Tạo Presigned GET URL với thời hạn 24 giờ (`expires_in = 86400`)
- [ ] Tự động fallback sang `MockS3Client` khi biến môi trường `AWS_ACCESS_KEY_ID` chưa được cấu hình
- [ ] Unit test xác nhận tải ảnh lên S3/MockS3 thành công và trả về URL hợp lệ

**Technical Notes:**

- Tái sử dụng module S3 có sẵn tại `app/utils/s3.py`. Đảm bảo giải phóng bộ nhớ buffer sau khi upload.

**Dependencies:** Blocked by: DA-AI06-05. Blocks: DA-AI06-07, DA-AI06-08.

---

### DA-AI06-07 — Latency Tracking, Custom Headers & Observability

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Đo lường chi tiết thời gian thực thi của từng công đoạn (Form-to-Prompt, SDXL GPU Render, S3 Upload), trả về custom response headers và ghi log có cấu trúc để theo dõi SLO/SLA (P95 < 30s).

**Acceptance Criteria:**

- [ ] Đo đạc các mốc thời gian bằng `time.perf_counter()`: `prompt_time_ms`, `inference_time_ms`, `upload_time_ms`, `total_time_ms`
- [ ] Thêm HTTP response headers: `X-Generation-Time-Ms`, `X-AI-Model` (`sdxl-lightning-local`), `X-S3-Key`
- [ ] Ghi log có cấu trúc (Structured JSON Logging): `client_id`, `latency_ms`, `seed`, `aspect_ratio`
- [ ] Bắn log cảnh báo mức `WARN` nếu `total_time_ms > 30000` (vi phạm SLO 30 giây)

**Technical Notes:**

- Đóng gói thành decorator `@measure_execution_time`.

**Dependencies:** Blocked by: DA-AI06-06. Blocks: DA-AI06-08.

---

### DA-AI06-08 — Concurrent Generation Orchestration via asyncio.gather

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Xây dựng endpoint `POST /ai/image/generate/batch` cho phép tạo song song 2-4 biến thể ảnh (mặc định 3 biến thể) cùng lúc bằng `asyncio.gather`, đảm bảo tổng thời gian phản hồi xấp xỉ thời gian sinh 1 ảnh đơn.

**Acceptance Criteria:**

- [ ] Endpoint nhận payload tương tự single-generate kèm tham số `count: int = Field(default=3, ge=1, le=4)`
- [ ] Khởi tạo `count` coroutines chạy độc lập và kích hoạt đồng thời qua `asyncio.gather(*tasks, return_exceptions=True)`
- [ ] Tổng thời gian render 3 ảnh song song không vượt quá 1.35x thời gian sinh 1 ảnh đơn
- [ ] Thứ tự kết quả trả về khớp chính xác với index yêu cầu ban đầu (`0, 1, 2`)
- [ ] Sử dụng `asyncio.Semaphore(3)` giới hạn request đồng thời để tránh chạm rate limit

**Technical Notes:**

- Tích hợp tại `app/services/image_gen.py` trong hàm `generate_batch(...)`.

**Dependencies:** Blocked by: DA-AI06-06. Blocks: DA-AI06-09, DA-AI06-10.

---

### DA-AI06-09 — Seed Diversity & Visual Variation Strategy

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Đảm bảo các ảnh trong cùng 1 đợt batch sinh ra có sự đa dạng trực quan rõ rệt (không bị trùng lặp tư thế/bố cục) nhưng vẫn giữ tính nhất quán về chủ thể sản phẩm thương hiệu.

**Acceptance Criteria:**

- [ ] Cấp phát seed ngẫu nhiên độc lập bằng `secrets.randbelow(4294967295)` cho từng biến thể, tuyệt đối không trùng seed
- [ ] Hỗ trợ các chế độ biến thể:
  - `seed_diversity`: Giữ nguyên prompt, thay đổi seed
  - `angle_diversity`: Tự động phân bổ góc máy (Slot 0: chính diện, Slot 1: góc 45 độ, Slot 2: cận cảnh macro)
  - `lighting_diversity`: Tự động phân bổ ánh sáng (Slot 0: studio softbox, Slot 1: rim light kịch tính, Slot 2: nắng chiều ấm)
- [ ] Trả về thông tin `seed` và `applied_modifiers` của từng ảnh

**Technical Notes:**

- Tạo helper module `app/services/variation_engine.py` phân phối prompt modifiers.

**Dependencies:** Blocked by: DA-AI06-08. Blocks: DA-AI06-10.

---

### DA-AI06-10 — Partial Failure Handling & Credit Safety

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Xử lý sự cố từng phần trong batch: nếu 1 trong 3 biến thể gặp lỗi, các biến thể còn lại vẫn hoàn tất và trả về kết quả bình thường; đồng thời ghi nhận chính xác để hệ thống billing chỉ trừ đúng credit các ảnh thành công.

**Acceptance Criteria:**

- [ ] Phân loại kết quả từng slot:
  - Thành công: `{"index": 0, "status": "SUCCESS", "image_url": "...", "s3_key": "...", "seed": 12345}`
  - Thất bại: `{"index": 1, "status": "FAILED", "error_code": "GPU_ENGINE_ERROR", "error_message": "..."}`
- [ ] Response tổng thể chứa `total_requested`, `successful_count`, `failed_count`, `batch_time_ms`, `images`
- [ ] Nếu toàn bộ các biến thể đều thất bại: Ném HTTP 502 Bad Gateway
- [ ] Xuất log audit: `CREDIT_AUDIT: client_id={id} requested=3 successful=2 billed_credits=2`

**Technical Notes:**

- Tạo Pydantic model `BatchImageItem` hỗ trợ union `SuccessBatchItem` và `FailedBatchItem`.

**Dependencies:** Blocked by: DA-AI06-08, DA-AI06-09. Blocks: DA-AI06-13.

---

### DA-AI06-11 — Multi-tier Safety Negative Prompt Injection

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Ngăn chặn tuyệt đối mô hình sinh ra ảnh nhạy cảm, bạo lực, xúc phạm văn hóa, các lỗi dị tật giải phẫu cơ thể người hoặc watermark/chữ rác làm hỏng tính chuyên nghiệp của thương hiệu.

**Acceptance Criteria:**

- [ ] Xây dựng module `app/utils/brand_safety.py` định nghĩa `BRAND_SAFETY_NEGATIVE_PROMPT` gom 3 nhóm:
  - **Content Policy:** `nsfw, nudity, suggestive, violent, gore, blood, weapons, offensive, political, religious controversy, hate symbols`
  - **Commercial Quality:** `watermark, text, logo, signature, lowres, blurry, jpeg artifacts, pixelated, distorted proportions, bad anatomy, deformed fingers, extra limbs, amputee`
  - **Style Contamination:** `amateur photo, oversaturated, poor lighting, dirty surfaces`
- [ ] **Quy tắc tiêm:** BẮT BUỘC đặt chuỗi Safety Negative ở ĐẦU câu: `effective_negative = f"{BRAND_SAFETY_NEGATIVE_PROMPT}, {user_negative}" if user_negative else BRAND_SAFETY_NEGATIVE_PROMPT`
- [ ] Cho phép bổ sung từ khóa qua biến môi trường hoặc file `resources/safety_prompts.json` mà không cần sửa code
- [ ] Unit test xác nhận 100% request đều mang đầy đủ chuỗi safety negative kể cả khi user không nhập negative prompt

**Technical Notes:**

- Áp dụng trực tiếp vào pipeline gửi tới Self-Hosted SDXL Inference Engine.

**Dependencies:** Blocks: DA-AI06-05, DA-AI06-13. Blocked by: None.

---

### DA-AI06-12 — Input Sanitization & Blacklist Guardrails

**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Quét và chặn đứng các prompt độc hại (Jailbreak, Prompt Injection, nội dung bất hợp pháp, ngôn từ thù hận) ngay tại tầng API trước khi gửi sang GPU Inference Server nhằm bảo vệ tài nguyên GPU và an toàn pháp lý cho BrandHub.

**Acceptance Criteria:**

- [ ] **Layer 1: Fast Regex / Keyword Blacklist (< 2ms):** Quét song ngữ (Việt - Anh) từ khóa cấm và các pattern tấn công jailbreak (`"ignore all previous instructions"`, `"dan mode"`, `"bypass safety filter"`). Ném HTTP 400 nếu vi phạm
- [ ] **Layer 2: Lightweight LLM Guardrails Check:** Kiểm duyệt nhanh qua Groq Llama 3-8B (`temperature=0.0`) trả về `{is_safe: bool, reason: str}` đối với các prompt dài/phức tạp
- [ ] Ghi log vi phạm an toàn vào bảng audit log: `timestamp`, `client_id`, `offending_prompt`, `matched_rule`
- [ ] Đạt 100% test case (10 attack prompts bị chặn + 5 normal product prompts được thông qua an toàn)

**Technical Notes:**

- Mở rộng từ `app/utils/security_scanner.py`.

**Dependencies:** Blocks: DA-AI06-05, DA-AI06-13. Blocked by: None.

---

### DA-AI06-13 — 20 Commercial Product Prompts Dataset Across 5 Categories

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Thiết kế bộ dataset chuẩn gồm 20 prompts mô tả sản phẩm thương mại thực tế, phân bổ đều trên 5 nhóm ngành hàng trọng tâm của khách hàng BrandHub nhằm phục vụ đánh giá chất lượng toàn diện.

**Acceptance Criteria:**

- [ ] Tạo file cấu hình `tests/data/commercial_product_benchmark_20.json` gồm 20 kịch bản:
  - **FMCG & Beverage (4):** Lon nước tăng lực lạnh có giọt nước đọng, Chai rượu vang đỏ trên nền gỗ sồi, Ly cà phê sữa đá hiện đại, Hộp trà matcha hữu cơ
  - **Cosmetics & Skincare (4):** Lọ serum thủy tinh mờ vòi vàng trên bệ đá cẩm thạch, Thỏi son đỏ nhung cạnh hoa hồng, Hũ kem dưỡng ẩm thiên nhiên, Chai xịt khoáng tinh khiết
  - **Fashion & Accessories (4):** Giày sneaker streetwear trên khối bê tông, Đồng hồ cơ nam lộ máy dây da, Túi xách nữ da bò Ý, Kính râm phản chiếu hoàng hôn
  - **Tech & Gadgets (4):** Tai nghe không dây TWS mở nắp LED, Bàn phím cơ công thái học RGB bàn tối giản, Loa bluetooth bên bể bơi, Vòng đeo tay thông minh
  - **Home Decor & Living (4):** Ghế armchair phong cách Bắc Âu, Nến thơm đậu nành trong spa, Bộ bình gốm nghệ thuật, Chăn len thô dệt kim
- [ ] Mỗi prompt đi kèm cấu hình: `aspect_ratio`, `style_preset`, `form_data_equivalent`, `expected_attributes`

**Technical Notes:**

- Viết theo chuẩn nhiếp ảnh thương phẩm quốc tế mà Form-to-Prompt Engine đã thiết kế.

**Dependencies:** Blocked by: DA-AI06-03, DA-AI06-04. Blocks: DA-AI06-14.

---

### DA-AI06-14 — Automated Benchmark Runner & Latency/Quality Metrics

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟡 High

**Goal:** Xây dựng script tự động chạy qua toàn bộ 20 prompt, đo đạc latency, thu thập ảnh kết quả và tổng hợp thành bảng chỉ số định lượng.

**Acceptance Criteria:**

- [ ] Script `scripts/benchmark_image_pipeline.py` tự động gọi API `POST /ai/image/generate` cho 20 prompt, lưu ảnh về `tests/benchmark_outputs/{timestamp}/` và xuất `benchmark_summary.json`
- [ ] Đo đạc chỉ số: `Min/Max/Avg/P95 Latency`, `Success Rate (%)`, `S3 Upload Throughput`
- [ ] Đánh giá chất lượng chuyên gia (thang 1-5):
  - **Visual Quality (VQ):** Độ sắc nét, chi tiết vật liệu (thủy tinh, kim loại, chất lỏng)
  - **Brand Commercial Suitability (BCS):** Độ phù hợp đưa vào bài đăng quảng cáo
  - **Prompt Adherence (PA):** Thể hiện đúng và đủ các vật thể được yêu cầu
- [ ] Tiêu chuẩn nghiệm thu: Điểm trung bình VQ >= 4.2/5, BCS >= 4.0/5, Latency P95 <= 25 giây

**Technical Notes:**

- Hỗ trợ đánh giá sơ bộ tự động bằng VLM (Gemini Flash).

**Dependencies:** Blocked by: DA-AI06-07, DA-AI06-13. Blocks: DA-AI06-15.

---

### DA-AI06-15 — Prompt Template Library & SDXL Failure Analysis Report

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Biên soạn tài liệu phân tích chuyên sâu các lỗi cố hữu của mô hình SDXL trong sinh ảnh thương mại, các giải pháp khắc phục, và đóng gói Top 10 Master Templates sẵn sàng đưa vào sản phẩm cho người dùng cuối.

**Acceptance Criteria:**

- [ ] Hoàn thành tài liệu `docs/ai_models/DA-AI06-05_Image_Benchmark_Report.md`:
  - **Top 10 Starter Master Templates:** 10 cấu trúc form/prompt đạt điểm cao nhất (VQ & BCS >= 4.5/5), phân theo 5 ngành hàng
  - **Top 5 SDXL Failure Modes & Analysis:** Phân tích 5 lỗi kinh điển (Text/Logo méo, bàn tay người cầm sản phẩm biến dạng, vật liệu thủy tinh bị hòa tan nền, trùng lặp sản phẩm, nền bị rác)
  - **Mitigation Best Practices:** Hướng dẫn chi tiết cách dùng negative prompt, góc máy thay thế và điều chỉnh ánh sáng để loại bỏ lỗi
- [ ] Bàn giao file JSON `resources/starter_templates.json` cho Frontend team tích hợp dropdown giao diện

**Technical Notes:**

- Làm cơ sở chuyển giao kiến thức cho toàn bộ đội ngũ BrandHub.

**Dependencies:** Blocked by: DA-AI06-14. Blocks: DA-AI11-03.

---

### DA-AI06-16 — Local / Server SDXL Model Serving (Diffusers/ComfyUI Engine)

**Assignee:** Tuấn (AI) | **Priority:** 🟡 High

**Goal:** Thiết lập engine suy luận SDXL chạy offline/server (trên máy trạm local hoặc GPU server RunPod/Vast.ai); hỗ trợ SDXL-Lightning 4-step (sinh ảnh < 4s), phục vụ toàn bộ yêu cầu sinh ảnh thương mại cho BrandHub.

**Acceptance Criteria:**

- [ ] Cấu hình script khởi chạy engine hỗ trợ CUDA 12.x và FP16
- [ ] Bật các kỹ thuật tối ưu hóa VRAM: `sdpa` attention, `enable_model_cpu_offload()`, `enable_vae_tiling()`
- [ ] Tích hợp SDXL-Lightning: Thời gian sinh ảnh đạt **2.5 – 4 giây / ảnh 1024x1024**
- [ ] Tích hợp cấu hình endpoint GPU Inference Server trong file settings (`settings.sdxl_engine_url`) để hệ thống kết nối trực tiếp đến node GPU phục vụ sinh ảnh thương mại

**Technical Notes:**

- Khởi chạy dưới dạng container hoặc dedicated process độc lập với main FastAPI để tránh crash khi OOM.

**Dependencies:** GPU Workstation / Server. Blocks: DA-AI06-19, DA-AI06-20.

---

### DA-AI06-17 — Training Dataset Collection & Quality Curation

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Thu thập, tuyển chọn và chuẩn hóa bộ dữ liệu hình ảnh thương mại chất lượng cao (120 – 150 ảnh) phục vụ huấn luyện LoRA cho BrandHub.

**Acceptance Criteria:**

- [ ] Thu thập tối thiểu 120 ảnh thương mại chất lượng cao từ các nguồn mở (Unsplash Commercial, Behance, Pexels)
- [ ] Lọc sạch tạp âm: Loại bỏ ảnh vỡ hạt, mờ, sai nét, ảnh chứa watermark hoặc logo thương hiệu lớn có bản quyền
- [ ] Chuẩn hóa kích thước: Đưa toàn bộ ảnh về độ phân giải tối thiểu 1024x1024; phân loại theo tỷ lệ khung hình (1:1, 3:4, 16:9)
- [ ] Đóng gói tập dữ liệu thành cấu trúc thư mục chuẩn: `dataset/raw/` và `dataset/curated/` kèm báo cáo thống kê

**Dependencies:** None. Blocks: DA-AI06-18.

---

### DA-AI06-18 — Automated & Manual Dataset Captioning Pipeline

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Xây dựng pipeline tự động sinh mô tả chi tiết (captions) cho tập ảnh dataset kết hợp gán nhãn trigger word định danh.

**Acceptance Criteria:**

- [ ] Sử dụng công cụ gán nhãn tự động (WD14 Tagger hoặc JoyCaption / Llama-3.2-Vision script)
- [ ] Mỗi ảnh có 1 file text `.txt` đi kèm cùng tên, chứa đầy đủ: Trigger Word định danh (`brandhub_style`) và mô tả chi tiết chủ thể, góc máy, ánh sáng, màu sắc
- [ ] Rà soát thủ công (manual review): Loại bỏ các từ khóa thừa thãi gây over-fitting
- [ ] Xuất tập dataset hoàn chỉnh sẵn sàng nạp vào script training

**Dependencies:** Blocked by: DA-AI06-17. Blocks: DA-AI06-19.

---

### DA-AI06-19 — Brand Visual Identity LoRA Fine-Tuning Execution

**Assignee:** Tuấn (AI) | **Priority:** 🟡 High

**Goal:** Cấu hình và thực thi quá trình huấn luyện LoRA trên tập dữ liệu đã chuẩn bị bằng Kohya_ss hoặc Diffusers script.

**Acceptance Criteria:**

- [ ] Cấu hình siêu tham số tối ưu:
  - Base Model: `stabilityai/stable-diffusion-xl-base-1.0`
  - Network Rank (Dim): 32 | Alpha: 16 (tỉ lệ 1:2 chuẩn cho style/identity)
  - Learning Rate: UNet `1e-4`, Text Encoder `4e-5`. Optimizer: `AdamW8bit` hoặc `Prodigy`
  - Epochs: 15 – 20 epochs (~1,500 – 2,500 steps)
- [ ] Xuất file LoRA định dạng `.safetensors` với dung lượng nhỏ gọn (< 150MB)
- [ ] Kiểm thử nghiệm thu (Validation): Sinh ảnh đối chứng ở các epoch để chọn checkpoint tối ưu, không bị over-fitting
- [ ] Đẩy file checkpoint hoàn thiện lên AWS S3: `loras/brandhub_style_v1.safetensors`

**Dependencies:** Blocked by: DA-AI06-18, DA-AI06-16. Blocks: DA-AI06-20.

---

### DA-AI06-20 — LoRA Dynamic Loading & Multi-LoRA Inference Engine

**Assignee:** Tuấn (AI) & Lộc (Sub-lead) | **Priority:** 🟡 High

**Goal:** Tích hợp cơ chế nạp động LoRA từ S3 về local cache và inject vào pipeline suy luận mà không cần restart server.

**Acceptance Criteria:**

- [ ] Hỗ trợ tham số `lora_id` và `lora_weight` (mặc định 0.8) trong `POST /ai/image/generate`
- [ ] Tự động tải và cache file `.safetensors` từ S3 về thư mục `cache/loras/`
- [ ] Sử dụng `load_lora_weights` và `set_adapters` của Diffusers để nạp LoRA trong < 0.05 giây
- [ ] Hỗ trợ Multi-LoRA (ghép 1 LoRA sản phẩm + 1 LoRA phong cách) với trọng số cân bằng

**Dependencies:** Blocked by: DA-AI06-16, DA-AI06-19. Blocks: None.



---

### DA-AI07-01 — Model Weights & Checkpoints Management (RealVisXL, IdentityNet, IP-Adapter, InsightFace)

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Xây dựng module tự động tải, kiểm tra tính toàn vẹn (checksum) và nạp offline/online toàn bộ trọng số mô hình cho InstantID trên GPU Server; thay thế base model mặc định bằng RealVisXL V4.0 để loại bỏ hoàn toàn phong cách anime.

**Acceptance Criteria:**

- [ ] Module `ModelWeightsManager` quản lý cache tại `resources/models/`, hỗ trợ biến môi trường `MODELS_CACHE_DIR`
- [ ] Tải và xác thực checkpoint Base Model `SG161222/RealVisXL_V4.0` (FP16 `.safetensors`, ~6.6GB)
- [ ] Tải trọng số IdentityNet (`InstantX/InstantID/ControlNetModel`, ~2.5GB) và IP-Adapter Image Projector (`ip-adapter.bin`, ~0.6GB)
- [ ] Tải trọn bộ model InsightFace `buffalo_l` (`det_10g.onnx`, `w600k_r50.onnx`,...) dung lượng ~300MB
- [ ] Cơ chế tự động verify SHA256/kích thước file; nếu lỗi tự động re-download mà không làm gián đoạn service

**Technical Notes:**

- Đảm bảo quyền ghi vào thư mục cache; nạp qua `huggingface_hub.snapshot_download` hoặc `hf_hub_download` với resume capability.
- License note: InsightFace buffalo_l dùng cho mục đích nghiên cứu/đồ án tốt nghiệp; tài liệu hóa rõ ràng trong dependencies manifest.

**Dependencies:** Blocks: DA-AI07-02, DA-AI07-04. Blocked by: DA-AI06-16.

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

### DA-AI07-04 — InstantID Serving Pipeline Deployment on RTX 4090 & VRAM Optimization

**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Dựng pipeline suy luận hoàn chỉnh bằng `diffusers.StableDiffusionXLInstantIDPipeline` trên GPU Server RTX 4090 (24GB VRAM), áp dụng các kỹ thuật tối ưu bộ nhớ để đạt thời gian sinh ảnh < 15 giây.

**Acceptance Criteria:**

- [ ] Khởi tạo pipeline InstantID chạy FP16, tích hợp Base Model RealVisXL V4.0, IdentityNet và IP-Adapter
- [ ] Kích hoạt PyTorch 2.x Scaled Dot-Product Attention (SDPA) trên toàn bộ UNet và ControlNet blocks
- [ ] Bật `pipe.enable_vae_tiling()` và `pipe.enable_vae_slicing()` giải phóng đỉnh tải VRAM khi decode ảnh 1024x1024
- [ ] Vì chạy trên RTX 4090 (24GB VRAM), **tuyệt đối không bật CPU offload** để giữ tốc độ suy luận nhanh nhất (< 15s cho 30 diffusion steps); đỉnh VRAM duy trì trong khoảng 14GB - 17GB
- [ ] Tích hợp cơ chế Warmup tự động chạy 1 sample giả lập khi container khởi động để nạp sẵn CUDA kernels

**Technical Notes:**

- Tránh xung đột CUDA OOM bằng cách thiết lập `torch.cuda.set_per_process_memory_fraction(0.9)`.
- Đo lường VRAM thực tế qua `torch.cuda.max_memory_allocated()`.

**Dependencies:** Blocks: DA-AI07-05, DA-AI07-06. Blocked by: DA-AI07-01, DA-AI07-02.

---

### DA-AI07-05 — Golden Parameter Calibration (Strength, Conditioning Scale, CFG, Steps)

**Assignee:** Tuấn (AI) | **Priority:** 🟡 High

**Goal:** Thực nghiệm tinh chỉnh dải tham số tối ưu giữa độ giữ nét mặt (identity preservation) và độ tự nhiên của da (natural skin realism), tránh hiện tượng mặt bị đông cứng hoặc da sáp.

**Acceptance Criteria:**

- [ ] Tìm ra bộ thông số vàng chuẩn hóa:
  - `instantid_strength`: **0.78** (khoảng an toàn: 0.75 – 0.82)
  - `controlnet_conditioning_scale`: **0.80**
  - `guidance_scale (CFG)`: **5.0** (tránh cháy sáng viền)
  - `num_inference_steps`: **30 steps** với sampler `Euler a` hoặc `DPM++ 2M Karras`
- [ ] Đóng gói cấu hình mặc định vào `app/core/config.py` và cho phép override linh hoạt qua payload request

**Technical Notes:**

- Khi `instantid_strength` > 0.85, mặt sẽ có hiện tượng bết dính và mất biểu cảm tự nhiên. Khi < 0.70, độ tương đồng danh tính giảm sút rõ rệt.

**Dependencies:** Blocks: DA-AI07-06, DA-AI07-13. Blocked by: DA-AI07-04.

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

### DA-AI07-14 — Empirical Benchmark: InstantID vs IP-Adapter FaceID-Plus v2 (20 Images)

**Assignee:** Tuấn (AI) | **Priority:** 🟡 High

**Goal:** Chạy thực nghiệm đối đầu trên tập 20 ảnh mẫu chuẩn hóa để so sánh khoa học giữa InstantID và IP-Adapter FaceID-Plus v2, làm cơ sở bảo vệ đồ án trước Mentor.

**Acceptance Criteria:**

- [ ] Chuẩn bị tập 20 ảnh mẫu (10 nam, 10 nữ, đa sắc tộc, đa lứa tuổi 20-50)
- [ ] Đo đạc và lập bảng so sánh 4 chỉ số:
  1. *Cosine Similarity*: Đo bằng ArcFace embedding
  2. *Inference Latency*: Thời gian sinh trung bình (s) trên cùng GPU RTX 4090
  3. *Peak VRAM*: Mức ngốn VRAM tối đa (`torch.cuda.max_memory_allocated()`)
  4. *Subjective Realism*: Điểm đánh giá độ tự nhiên của da và thần thái (thang 1-5 sao)
- [ ] Xuất tài liệu kết luận định lượng chứng minh tại sao chọn InstantID cho BrandHub, liên kết chéo vào báo cáo DA-AI11-01

**Technical Notes:**

- Tạo script chạy song song 2 pipelines `tests/benchmark_instantid_vs_ipadapter.py`, lưu kết quả JSON và render biểu đồ so sánh.

**Dependencies:** Blocks: DA-AI07-15, DA-AI11-01. Blocked by: DA-AI07-13.

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

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Low

**Goal:** Give BrandHub clients clear guidance on how to prepare input images to get the best possible composition results.

**Acceptance Criteria:**

- [ ] Guide documents recommended input image specs: minimum resolution, preferred background (plain vs complex), lighting direction
- [ ] Per-category best practices: fashion (full-body vs half-body), beauty (macro product shots), food (top-down vs 45°), accessories
- [ ] Known failure cases listed with workarounds (e.g., "for glass bottles, manually remove background in Photoshop before uploading")

**Dependencies:** Blocks: None. Blocked by: DA-AI08-06.

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

**Dependencies:** Blocks: DA-AI10-03. Blocked by: DA-AI04-07, DA-AI06-04, DA-AI07-06, DA-AI08-05, DA-AI09-06, DA-AI05-16.

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

**Dependencies:** Blocks: DA-AI11-05. Blocked by: DA-AI08-06, DA-AI06-05.

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

## Phase 5–7 — Content Workflow, Frontend, Mobile, Testing, Deployment (Sprints 10–16)

---

### DA-E28-01 — Implement POST /api/v1/content-requests

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow BRAND_CLIENT to submit a new content request with topic, platform, tone, deadline, and clientId, creating the request in SUBMITTED status.

**Acceptance Criteria:**

- [ ] POST /api/v1/content-requests accepts `{topic, platform, tone, deadline, clientId}` and returns 201 with the created request body
- [ ] Request is persisted with status SUBMITTED and createdBy set to authenticated user's ID
- [ ] Returns 400 if required fields are missing or deadline is in the past
- [ ] Returns 403 if caller does not have BRAND_CLIENT role
- [ ] clientId in payload is validated to match the authenticated user's associated client (no cross-client injection)

**Technical Notes:**

- Validate `platform` against enum (FB, IG, TIKTOK, THREADS, ZALO)
- `deadline` should be stored as UTC ISO-8601; reject if `deadline < now + 1h`
- Use `@PreAuthorize("hasRole('BRAND_CLIENT')")` on the controller method

**Dependencies:** Blocks: [DA-E28-02, DA-E28-03, DA-E29-01]. Blocked by: [None].

---

### DA-E28-02 — Implement GET /api/v1/content-requests

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow ACCOUNT_MANAGER to list all content requests from their assigned clients with filtering by status and platform.

**Acceptance Criteria:**

- [ ] GET /api/v1/content-requests returns paginated list scoped to clients assigned to the authenticated ACCOUNT_MANAGER
- [ ] Supports query params `?status=&platform=&page=&size=` and returns correct filtered results
- [ ] Returns 200 with empty list (not 404) when no requests match filters
- [ ] BRAND_CLIENT calling the same endpoint sees only their own clientId's requests
- [ ] Response includes `totalElements`, `totalPages`, `content[]` envelope

**Technical Notes:**

- Use MongoDB query with `$and` on `clientId IN [assignedClientIds]` + optional status/platform filters
- Pull assigned clientIds from workspace membership data; cache if needed to avoid N+1 lookups
- Paginate with Spring Data's `Pageable`

**Dependencies:** Blocks: [DA-E36-01]. Blocked by: [DA-E28-01].

---

## Phase 8 — Sprint Reporting (All Sprints)

> Epic E47 runs at the end of every sprint. Each sprint has 7 tasks: 5 individual member reports, 1 team report compiled by Trung, 1 finalize + commit task.
>
> **Individual report format** (tasks DA-E47-{n} where n % 7 ∈ {1..5}): Each member fills their own `members/{handle}.md` file under the sprint folder. Report must cover: personal info, task list with Jira links + status, detailed work log per task (branch, commit hash, files changed, description, time spent), incomplete tasks with reason, bonus contributions, learnings, feedback & suggestions, and self-assessment score (out of 20).
>
> **Team report format** (tasks DA-E47-{n} where n % 7 = 6): Trung reads all 5 member reports, verifies against git history, then writes `SPRINT_REPORT.md` covering: sprint overview, completion rate, task breakdown table, deliverables list with evidence, retrospective (what went well / what didn't), workload distribution, and action items for next sprint.
>
> **Finalize task** (tasks DA-E47-{n} where n % 7 = 0): Commit all report files to `brandhub-infrastructure` repo under `docs/plan/sprints/sprint_{XX}/` on the `docs/sprint-{XX}-report` branch, then merge to `develop`.

---

### DA-E47-01 — Write individual sprint report for Sprint 1 — Trung

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Document Trung's personal contributions in Sprint 1 in `sprint_01/members/trungle.md`, covering all 9 tasks across E01 and E02 plus the Docker Compose scaffold bonus work.

**Acceptance Criteria:**

- [ ] All assigned tasks listed with Jira links and final status
- [ ] Each task has: branch name, commit hash, files changed, work description, time spent
- [ ] Bonus contributions (Docker Compose scaffold) documented with commit evidence
- [ ] Self-assessment table filled (score out of 20)
- [ ] File submitted before sprint review meeting

**Technical Notes:**

- Sprint 1 tasks: DA-E01-01/02/03/05, DA-E02-01/02/03/04 (all Done)
- Bonus: Docker Compose scaffold — commits `67fca93`, `4e42c2b` in brandhub-infrastructure
- Use git log `--author="trungle"` to verify commit hashes before writing

**Dependencies:** Blocks: [DA-E47-06]. Blocked by: Sprint 1 work completion.

---

### DA-E47-02 — Write individual sprint report for Sprint 1 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's personal contributions in Sprint 1 in `sprint_01/members/locnv.md`. Sprint 1 had no tasks assigned to Lộc, so this report confirms participation in team meetings and skill assessment only.

**Acceptance Criteria:**

- [ ] Personal info section filled
- [ ] Tasks section reflects no individual tasks assigned (DA-E01-01/04 were "All Team")
- [ ] Participation in team brainstorm (DA-E01-01) and skill assessment (DA-E01-04) documented
- [ ] Self-assessment filled

**Technical Notes:**

- DA-E01-01 (brainstorm) and DA-E01-04 (skill assessment) are "All (Team)" — Lộc participated but Trung owned them
- File: `sprint_01/members/locnv.md`

**Dependencies:** Blocks: [DA-E47-06]. Blocked by: Sprint 1 completion.

---

### DA-E47-03 — Write individual sprint report for Sprint 1 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's personal contributions in Sprint 1 in `sprint_01/members/tuannm.md`. Same as Lộc — no individual tasks, participation in team tasks only.

**Acceptance Criteria:**

- [ ] Personal info section filled
- [ ] Team task participation (DA-E01-01, DA-E01-04) documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_01/members/tuannm.md`

**Dependencies:** Blocks: [DA-E47-06]. Blocked by: Sprint 1 completion.

---

### DA-E47-04 — Write individual sprint report for Sprint 1 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's personal contributions in Sprint 1 in `sprint_01/members/anha.md`. Same as Lộc and Tuấn — no individual tasks, participation in team tasks only.

**Acceptance Criteria:**

- [ ] Personal info section filled
- [ ] Team task participation (DA-E01-01, DA-E01-04) documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_01/members/anha.md`

**Dependencies:** Blocks: [DA-E47-06]. Blocked by: Sprint 1 completion.

---

### DA-E47-05 — Write individual sprint report for Sprint 1 — Phước

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Document Phước's personal contributions in Sprint 1 in `sprint_01/members/phuocnc.md`. Same as Lộc — no individual tasks, participation in team tasks only.

**Acceptance Criteria:**

- [ ] Personal info section filled
- [ ] Team task participation (DA-E01-01, DA-E01-04) documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_01/members/phuocnc.md`

**Dependencies:** Blocks: [DA-E47-06]. Blocked by: Sprint 1 completion.

---

### DA-E47-06 — Review all member reports + write team SPRINT_REPORT for Sprint 1

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Read all 5 member reports for Sprint 1, verify claims against git history, then write the team-level `sprint_01/SPRINT_REPORT.md` covering overall sprint outcome, completion rate, and retrospective.

**Acceptance Criteria:**

- [ ] All 5 member report files exist and are non-empty before starting this task
- [ ] SPRINT_REPORT.md covers: sprint overview, completion rate (tasks done / total), deliverables table with evidence, retrospective (what went well / what didn't), workload table, action items for Sprint 2
- [ ] Completion rate and deliverables verified against git log
- [ ] Retrospective has at least 2 "went well" and 2 "to improve" items

**Technical Notes:**

- Sprint 1: 9 tasks total (E01: 5, E02: 4), expected 100% completion
- Main deliverables: GitHub Org + 7 repos, Linear workspace, branch protection, service accounts, Docker Compose scaffold (bonus)
- File: `sprint_01/SPRINT_REPORT.md`

**Dependencies:** Blocks: [DA-E47-07]. Blocked by: [DA-E47-01], [DA-E47-02], [DA-E47-03], [DA-E47-04], [DA-E47-05].

---

### DA-E47-07 — Finalize and commit Sprint 1 report to brandhub-infrastructure

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Commit all Sprint 1 report files (`SPRINT_REPORT.md` + all member `.md` files) to `brandhub-infrastructure` on the correct branch and merge to `develop`.

**Acceptance Criteria:**

- [ ] Branch `docs/sprint-01-report` created from `develop`
- [ ] All files under `docs/plan/sprints/sprint_01/` committed with conventional commit message: `docs(sprint-01): add sprint 1 team and member reports`
- [ ] PR opened, reviewed by at least 1 member, merged to `develop`
- [ ] No placeholder text remaining in any report file

**Technical Notes:**

- Target path: `docs/plan/sprints/sprint_01/`
- Conventional commit: `docs(sprint-01): add sprint 1 team and member reports`

**Dependencies:** Blocked by: [DA-E47-06].

---

### DA-E47-08 — Write individual sprint report for Sprint 2 — Trung

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Document Trung's personal contributions in Sprint 2 in `sprint_02/members/trungle.md`, covering 10 tasks across E03, E04, E05 plus bonus ADR work and architecture HTML diagrams.

**Acceptance Criteria:**

- [ ] All 10 assigned tasks listed with Jira links and final status
- [ ] Architecture HTML deliverables documented with commit hashes and file sizes
- [ ] Bonus tasks (DA-408 git convention, DA-409 VitePress HTML viewer, Sprint 10–16 plans) documented
- [ ] Self-assessment filled

**Technical Notes:**

- Tasks: DA-E03-02, DA-E04-01/02/05, DA-E05-01/02/03/04/05/08
- Architecture files: `brandhub_architecture.html` (commit `d74c885`), `brandhub_db_ownership_diagram.html` (commit `b5f66d3`), `brandhub_polyrepo_structure.html` (commit `bf70f70`)

**Dependencies:** Blocks: [DA-E47-13]. Blocked by: Sprint 2 completion.

---

### DA-E47-09 — Write individual sprint report for Sprint 2 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's personal contributions in Sprint 2 in `sprint_02/members/locnv.md`. Sprint 2 tasks for Lộc: DA-E04-04 (mobile non-functional requirements).

**Acceptance Criteria:**

- [ ] DA-E04-04 documented with deliverable description, Jira link, and status
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_02/members/locnv.md`

**Dependencies:** Blocks: [DA-E47-13]. Blocked by: Sprint 2 completion.

---

### DA-E47-10 — Write individual sprint report for Sprint 2 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's contributions in Sprint 2 in `sprint_02/members/tuannm.md`. Tasks: DA-E04-03 (AI non-functional requirements), DA-E05-06 (sequence diagrams), DA-E05-07 (AI architecture section).

**Acceptance Criteria:**

- [ ] All 3 tasks documented with Jira links, status, deliverable description
- [ ] Sequence diagram file paths and commit hashes included
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_02/members/tuannm.md`

**Dependencies:** Blocks: [DA-E47-13]. Blocked by: Sprint 2 completion.

---

### DA-E47-11 — Write individual sprint report for Sprint 2 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's contributions in Sprint 2 in `sprint_02/members/anha.md`. Task: DA-E04-03 shared with Tuấn context, participation in team reviews.

**Acceptance Criteria:**

- [ ] Assigned tasks listed with status
- [ ] Participation in DA-E03-05 (mentor review, All Team) documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_02/members/anha.md`

**Dependencies:** Blocks: [DA-E47-13]. Blocked by: Sprint 2 completion.

---

### DA-E47-12 — Write individual sprint report for Sprint 2 — Phước

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Document Phước's contributions in Sprint 2 in `sprint_02/members/phuocnc.md`. Tasks: DA-E03-01 (UC list), DA-E03-03 (UC 21–40), DA-E03-04 (UC 41–60), DA-E03-06 (UC Excel file).

**Acceptance Criteria:**

- [ ] All 4 tasks documented with Jira links, status, and deliverable description
- [ ] Use case file paths and commit evidence included
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_02/members/phuocnc.md`

**Dependencies:** Blocks: [DA-E47-13]. Blocked by: Sprint 2 completion.

---

### DA-E47-13 — Review all member reports + write team SPRINT_REPORT for Sprint 2

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Read all 5 member reports for Sprint 2, verify against git history, write `sprint_02/SPRINT_REPORT.md`.

**Acceptance Criteria:**

- [ ] All 5 member reports exist and non-empty
- [ ] SPRINT_REPORT covers: 19 tasks total (E03: 6, E04: 5, E05: 8), completion rate, 15 deliverables list, retrospective, workload table noting Trung's 10/19 task load
- [ ] Action items for Sprint 3 included

**Technical Notes:**

- Sprint 2: 19 tasks, expected ~95% (DA-E03-05 mentor review may carry over)
- File: `sprint_02/SPRINT_REPORT.md`

**Dependencies:** Blocks: [DA-E47-14]. Blocked by: [DA-E47-08] through [DA-E47-12].

---

### DA-E47-14 — Finalize and commit Sprint 2 report to brandhub-infrastructure

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Commit all Sprint 2 report files to `brandhub-infrastructure` on branch `docs/sprint-02-report` and merge to `develop`.

**Acceptance Criteria:**

- [ ] Branch `docs/sprint-02-report` created
- [ ] All files under `docs/plan/sprints/sprint_02/` committed: `docs(sprint-02): add sprint 2 team and member reports`
- [ ] PR merged to `develop`, no placeholder text remaining

**Dependencies:** Blocked by: [DA-E47-13].

---

### DA-E47-15 — Write individual sprint report for Sprint 3 — Trung

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Document Trung's contributions in Sprint 3 in `sprint_03/members/trungle.md`. Tasks: DA-E06-01/02/03/07/08 (database design), DA-E07-01/04/05 (API design for business-service).

**Acceptance Criteria:**

- [ ] All 8 tasks documented with Jira links, status, deliverable paths, commit hashes
- [ ] Database design files (DBML, init scripts) referenced with file sizes
- [ ] OpenAPI YAML spec file path and line count included
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_03/members/trungle.md`

**Dependencies:** Blocks: [DA-E47-20]. Blocked by: Sprint 3 completion.

---

### DA-E47-16 — Write individual sprint report for Sprint 3 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's contributions in Sprint 3 in `sprint_03/members/locnv.md`. Tasks: DA-E08-01/02/03/04 (Figma wireframes and component system).

**Acceptance Criteria:**

- [ ] All 4 wireframe tasks documented with Figma links or exported file paths
- [ ] Component system catalogue file path referenced
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_03/members/locnv.md`

**Dependencies:** Blocks: [DA-E47-20]. Blocked by: Sprint 3 completion.

---

### DA-E47-17 — Write individual sprint report for Sprint 3 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's contributions in Sprint 3 in `sprint_03/members/tuannm.md`. Tasks: DA-E06-04/05 (DB indexing + DBML), DA-E07-02/06 (AI service API endpoints + OpenAPI YAML).

**Acceptance Criteria:**

- [ ] All 4 tasks documented with deliverable paths, Jira links, and status
- [ ] DBML file path and dbdiagram.io link (if applicable) referenced
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_03/members/tuannm.md`

**Dependencies:** Blocks: [DA-E47-20]. Blocked by: Sprint 3 completion.

---

### DA-E47-18 — Write individual sprint report for Sprint 3 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's contributions in Sprint 3 in `sprint_03/members/anha.md`. Task: DA-E06-06 (Redis key patterns documentation).

**Acceptance Criteria:**

- [ ] DA-E06-06 documented with deliverable file path and content summary
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_03/members/anha.md`

**Dependencies:** Blocks: [DA-E47-20]. Blocked by: Sprint 3 completion.

---

### DA-E47-19 — Write individual sprint report for Sprint 3 — Phước

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Document Phước's contributions in Sprint 3 in `sprint_03/members/phuocnc.md`. Tasks: DA-E07-03/07 (RabbitMQ message format, social platform API specs).

**Acceptance Criteria:**

- [ ] Both tasks documented with deliverable file paths and content summary
- [ ] Social platform API specs: FB, TikTok, Threads versions and rate limits noted
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_03/members/phuocnc.md`

**Dependencies:** Blocks: [DA-E47-20]. Blocked by: Sprint 3 completion.

---

### DA-E47-20 — Review all member reports + write team SPRINT_REPORT for Sprint 3

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Read all 5 Sprint 3 member reports, verify against git history, write `sprint_03/SPRINT_REPORT.md`.

**Acceptance Criteria:**

- [ ] SPRINT_REPORT covers: E06 (8 tasks), E07 (7 tasks), E08 (4 tasks) = 19 tasks total
- [ ] Deliverables: MongoDB + PostgreSQL schema, DBML, init scripts, OpenAPI YAML specs, Figma wireframes, component system
- [ ] Retrospective + action items for Sprint 4

**Dependencies:** Blocks: [DA-E47-21]. Blocked by: [DA-E47-15] through [DA-E47-19].

---

### DA-E47-21 — Finalize and commit Sprint 3 report to brandhub-infrastructure

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Commit all Sprint 3 report files on branch `docs/sprint-03-report` and merge to `develop`.

**Acceptance Criteria:**

- [ ] Commit message: `docs(sprint-03): add sprint 3 team and member reports`
- [ ] PR merged, no placeholders remaining

**Dependencies:** Blocked by: [DA-E47-20].

---

### DA-E47-22 — Write individual sprint report for Sprint 4 — Trung

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Document Trung's contributions in Sprint 4 in `sprint_04/members/trungle.md`. Tasks: DA-E09-01/02/03/04 (Docker Compose, init scripts, .env.example, clone-all.sh), DA-E10-01/05 (CI/CD for business-service, branch protection), DA-E11-01/02/03/04/05 (full API Gateway implementation).

**Acceptance Criteria:**

- [ ] All 11 tasks documented with commit hashes, file paths, and status
- [ ] Docker Compose services list and health check configuration described
- [ ] API Gateway filters (JWT validation, rate limiting, routing) documented with key config values
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_04/members/trungle.md`

**Dependencies:** Blocks: [DA-E47-27]. Blocked by: Sprint 4 completion.

---

### DA-E47-23 — Write individual sprint report for Sprint 4 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's contributions in Sprint 4 in `sprint_04/members/locnv.md`. Tasks: DA-E10-04 (CI/CD for web-dashboard).

**Acceptance Criteria:**

- [ ] DA-E10-04 documented with GitHub Actions workflow file path and pipeline steps
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_04/members/locnv.md`

**Dependencies:** Blocks: [DA-E47-27]. Blocked by: Sprint 4 completion.

---

### DA-E47-24 — Write individual sprint report for Sprint 4 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's contributions in Sprint 4 in `sprint_04/members/tuannm.md`. Tasks: DA-E10-03 (CI/CD for ai-service), carry-over DA-E07-02 (ai-service endpoint definitions), DA-E07-06 (OpenAPI YAML for ai-service).

**Acceptance Criteria:**

- [ ] All tasks documented including carry-over items with reason for carry-over
- [ ] CI/CD workflow file path referenced
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_04/members/tuannm.md`

**Dependencies:** Blocks: [DA-E47-27]. Blocked by: Sprint 4 completion.

---

### DA-E47-25 — Write individual sprint report for Sprint 4 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's contributions in Sprint 4 in `sprint_04/members/anha.md`. Carry-over task: DA-E06-06 (Redis key patterns) if not completed in Sprint 3.

**Acceptance Criteria:**

- [ ] Carry-over tasks noted with original sprint and reason
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_04/members/anha.md`

**Dependencies:** Blocks: [DA-E47-27]. Blocked by: Sprint 4 completion.

---

### DA-E47-26 — Write individual sprint report for Sprint 4 — Phước

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Document Phước's contributions in Sprint 4 in `sprint_04/members/phuocnc.md`. Tasks: DA-E09-05 (infrastructure README), DA-E10-02 (CI/CD for publisher-service), carry-over DA-E07-03/07.

**Acceptance Criteria:**

- [ ] All tasks documented including carry-overs
- [ ] README content summary included
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_04/members/phuocnc.md`

**Dependencies:** Blocks: [DA-E47-27]. Blocked by: Sprint 4 completion.

---

### DA-E47-27 — Review all member reports + write team SPRINT_REPORT for Sprint 4

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Read all 5 Sprint 4 member reports, verify against git history, write `sprint_04/SPRINT_REPORT.md`.

**Acceptance Criteria:**

- [ ] SPRINT_REPORT covers: E09 (5 tasks), E10 (5 tasks), E11 (5 tasks) = 15 tasks total + carry-overs
- [ ] Deliverables: docker-compose.yml running all 5 infra services, GitHub Actions workflows, API Gateway with JWT/rate-limit/routing filters
- [ ] Carry-over tasks from Sprint 3 tracked
- [ ] Retrospective + action items for Sprint 5

**Dependencies:** Blocks: [DA-E47-28]. Blocked by: [DA-E47-22] through [DA-E47-26].

---

### DA-E47-28 — Finalize and commit Sprint 4 report to brandhub-infrastructure

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Commit all Sprint 4 report files on branch `docs/sprint-04-report` and merge to `develop`.

**Acceptance Criteria:**

- [ ] Commit message: `docs(sprint-04): add sprint 4 team and member reports`
- [ ] PR merged, no placeholders remaining

**Dependencies:** Blocked by: [DA-E47-27].

---

### DA-E47-29 — Write individual sprint report for Sprint 5 — Trung

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Document Trung's contributions in Sprint 5 in `sprint_05/members/trungle.md`. Tasks: DA-E12-01 through 06 (full Auth implementation), DA-E13-01/02 (user profile + avatar upload), DA-E14-01/02/03 (RBAC annotations and workspace/client isolation filters).

**Acceptance Criteria:**

- [ ] All 11 tasks documented with API endpoint paths, commit hashes, and status
- [ ] JWT config values documented (access token 15 min, refresh token 30 days, bcrypt cost=12)
- [ ] Redis blacklist key pattern documented
- [ ] S3 avatar upload flow described
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_05/members/trungle.md`

**Dependencies:** Blocks: [DA-E47-34]. Blocked by: Sprint 5 completion.

---

### DA-E47-30 — Write individual sprint report for Sprint 5 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's contributions in Sprint 5 in `sprint_05/members/locnv.md`. AI Iteration 1 tasks: DA-AI01-05/06 (image compositing research), DA-AI02-01/03/05 (ai-service project init, S3 helper, Dockerfile).

**Acceptance Criteria:**

- [ ] All 5 tasks documented with deliverable paths
- [ ] Compositing technique comparison table referenced
- [ ] ai-service folder structure described
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_05/members/locnv.md`

**Dependencies:** Blocks: [DA-E47-34]. Blocked by: Sprint 5 completion.

---

### DA-E47-31 — Write individual sprint report for Sprint 5 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's contributions in Sprint 5 in `sprint_05/members/tuannm.md`. Tasks: DA-AI01-01/02 (InstantID vs IP-Adapter research), DA-AI02-02/06/07 (API clients config, internal auth middleware, ChromaDB design).

**Acceptance Criteria:**

- [ ] Research comparison table (InstantID vs IP-Adapter) referenced
- [ ] ChromaDB collection design documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_05/members/tuannm.md`

**Dependencies:** Blocks: [DA-E47-34]. Blocked by: Sprint 5 completion.

---

### DA-E47-32 — Write individual sprint report for Sprint 5 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's contributions in Sprint 5 in `sprint_05/members/anha.md`. Tasks: DA-E13-03/04 (Admin user list + ban APIs), DA-AI01-03/04 (Veo API research + video prompt tests), DA-AI02-04/08 (Pydantic schemas, AI research summary).

**Acceptance Criteria:**

- [ ] Admin API endpoints documented
- [ ] Veo API research findings referenced (capabilities, pricing, rate limits)
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_05/members/anha.md`

**Dependencies:** Blocks: [DA-E47-34]. Blocked by: Sprint 5 completion.

---

### DA-E47-33 — Write individual sprint report for Sprint 5 — Phước

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Document Phước's contributions in Sprint 5 in `sprint_05/members/phuocnc.md`. Tasks: DA-E14-04 (permission matrix document), DA-AI01-07 (Llama 3 vs Claude comparison, All Team).

**Acceptance Criteria:**

- [ ] Permission matrix file path and summary included
- [ ] LLM comparison findings referenced
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_05/members/phuocnc.md`

**Dependencies:** Blocks: [DA-E47-34]. Blocked by: Sprint 5 completion.

---

### DA-E47-34 — Review all member reports + write team SPRINT_REPORT for Sprint 5

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Read all 5 Sprint 5 member reports, verify against git history, write `sprint_05/SPRINT_REPORT.md`.

**Acceptance Criteria:**

- [ ] Covers E12 (6), E13 (4), E14 (4), AI-01 (8), AI-02 (7) tasks
- [ ] Auth system deliverables verified: register/login/refresh/logout/OAuth endpoints working
- [ ] AI Iteration 1 research reports referenced
- [ ] Retrospective + action items for Sprint 6

**Dependencies:** Blocks: [DA-E47-35]. Blocked by: [DA-E47-29] through [DA-E47-33].

---

### DA-E47-35 — Finalize and commit Sprint 5 report to brandhub-infrastructure

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Commit all Sprint 5 report files on branch `docs/sprint-05-report` and merge to `develop`.

**Acceptance Criteria:**

- [ ] Commit message: `docs(sprint-05): add sprint 5 team and member reports`
- [ ] PR merged, no placeholders remaining

**Dependencies:** Blocked by: [DA-E47-34].

---

### DA-E47-36 — Write individual sprint report for Sprint 6 — Trung

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Document Trung's contributions in Sprint 6 in `sprint_06/members/trungle.md`. Tasks: DA-E14-01/02/03 (RBAC), DA-E15-01 through 05 (Workspace CRUD), DA-E35-01 (Login page), DA-E35-05/06 (Register + OAuth), DA-E35-03 (Create Workspace page), DA-E35-07/08 (Workspace Settings + Members).

**Acceptance Criteria:**

- [ ] All 14 tasks documented with API endpoints/UI pages, commit hashes, and status
- [ ] RBAC implementation documented (@RequireRole, workspace/client isolation)
- [ ] Workspace CRUD flow documented
- [ ] Auth pages documented (Login/Register/OAuth button)
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_06/members/trungle.md`

**Dependencies:** Blocks: [DA-E47-41]. Blocked by: Sprint 6 completion.

---

### DA-E47-37 — Write individual sprint report for Sprint 6 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's AI Iteration 1 carry-over or Sprint 6 parallel work in `sprint_06/members/locnv.md`.

**Acceptance Criteria:**

- [ ] Tasks assigned in this sprint documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_06/members/locnv.md`

**Dependencies:** Blocks: [DA-E47-41]. Blocked by: Sprint 6 completion.

---

### DA-E47-38 — Write individual sprint report for Sprint 6 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's contributions in Sprint 6 in `sprint_06/members/tuannm.md`. AI Iteration 2 tasks: DA-AI03-03/04 (RAG embedding pipeline + semantic search), DA-AI04-02/03 (Llama 3 + Claude API integration).

**Acceptance Criteria:**

- [ ] RAG pipeline architecture described (embedding model, ChromaDB metadata schema)
- [ ] LLM routing strategy documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_06/members/tuannm.md`

**Dependencies:** Blocks: [DA-E47-41]. Blocked by: Sprint 6 completion.

---

### DA-E47-39 — Write individual sprint report for Sprint 6 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's contributions in Sprint 6 in `sprint_06/members/anha.md`. Không có task nào trong Sprint 6 epics. Nếu có đóng góp ngoài (AI Iteration 1, hỗ trợ team) thì ghi nhận.

**Acceptance Criteria:**

- [ ] Contributions (if any) documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_06/members/anha.md`

**Dependencies:** Blocks: [DA-E47-41]. Blocked by: Sprint 6 completion.

---

### DA-E47-40 — Write individual sprint report for Sprint 6 — Phước

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Document Phước's contributions in Sprint 6 in `sprint_06/members/phuocnc.md`. Tasks: DA-E14-04 (Permission matrix), DA-E16-01 through 04 (Client APIs), DA-E35-02 (Dashboard), DA-E35-04/09/10/11 (Client pages), DA-E36-01/02/06/03/04/05/07/08 (Content pages).

**Acceptance Criteria:**

- [ ] All 18 tasks documented with API endpoints/UI pages, commit hashes, and status
- [ ] Permission matrix document referenced
- [ ] Client CRUD APIs documented
- [ ] Dashboard + Client management UI pages documented
- [ ] Content management UI pages documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_06/members/phuocnc.md`

**Dependencies:** Blocks: [DA-E47-41]. Blocked by: Sprint 6 completion.

---

### DA-E47-41 — Review all member reports + write team SPRINT_REPORT for Sprint 6

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Read all 5 Sprint 6 member reports, verify against git history, write `sprint_06/SPRINT_REPORT.md`.

**Acceptance Criteria:**

- [ ] Covers E14 (4), E15 (5), E16 (4), E35 (11), E36 (8) = 32 tasks
- [ ] Core business deliverables verified: RBAC + Workspace + Client APIs working
- [ ] Web-dashboard pages verified: Auth + Dashboard + Workspace + Client + Content
- [ ] Retrospective + action items for Sprint 7

**Dependencies:** Blocks: [DA-E47-42]. Blocked by: [DA-E47-36] through [DA-E47-40].

---

### DA-E47-42 — Finalize and commit Sprint 6 report to brandhub-infrastructure

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Commit all Sprint 6 report files on branch `docs/sprint-06-report` and merge to `develop`.

**Acceptance Criteria:**

- [ ] Commit message: `docs(sprint-06): add sprint 6 team and member reports`
- [ ] PR merged, no placeholders remaining

**Dependencies:** Blocked by: [DA-E47-41].

---

### DA-E47-43 — Write individual sprint report for Sprint 7 — Trung

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Document Trung's contributions in Sprint 7 in `sprint_07/members/trungle.md`. Tasks: DA-E18-03 (AES-256 token encryption), DA-E19-04 (token status dashboard), DA-E20-01/02 (scheduled token refresh job, alert on failure).

**Acceptance Criteria:**

- [ ] AES-256 encryption implementation described (key management, IV handling)
- [ ] Token refresh scheduler config documented (cron expression, 2AM daily)
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_07/members/trungle.md`

**Dependencies:** Blocks: [DA-E47-48]. Blocked by: Sprint 7 completion.

---

### DA-E47-44 — Write individual sprint report for Sprint 7 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's contributions in Sprint 7 in `sprint_07/members/locnv.md`. 🔀 _Nội dung gốc ghi nhầm AI-06/AI-08 (thực chất thuộc AI Iteration 3, song song Sprint 9–10, không phải Sprint 7) — đã sửa lại đúng vị trí, xem DA-E48-11/12/13. AI-06/AI-08 cũng đã chuyển sang Ân/Tuấn sau Sprint 4 rebalance (xem [Rebalance Log](Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4))._ Ghi các task AI-infra Lộc thực sự làm trong Sprint 7 nếu có.

**Acceptance Criteria:**

- [ ] All assigned tasks documented (có thể rỗng nếu không có task nào trong sprint này, ghi rõ "không có task")
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_07/members/locnv.md`

**Dependencies:** Blocks: [DA-E47-48]. Blocked by: Sprint 7 completion.

---

### DA-E47-45 — Write individual sprint report for Sprint 7 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's contributions in Sprint 7 in `sprint_07/members/tuannm.md`. Tasks: DA-E18 context + DA-AI07-01 through 08 (InstantID virtual ambassador pipeline).

**Acceptance Criteria:**

- [ ] InstantID pipeline described (InsightFace face encoder, ControlNet depth, model loading)
- [ ] Face consistency test results referenced (15 generated images, similarity score)
- [ ] Benchmark vs IP-Adapter documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_07/members/tuannm.md`

**Dependencies:** Blocks: [DA-E47-48]. Blocked by: Sprint 7 completion.

---

### DA-E47-46 — Write individual sprint report for Sprint 7 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's contributions in Sprint 7 in `sprint_07/members/anha.md`. Tasks relevant from AI Iter 3 or Sprint 7 business tasks.

**Acceptance Criteria:**

- [ ] All assigned tasks documented with status
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_07/members/anha.md`

**Dependencies:** Blocks: [DA-E47-48]. Blocked by: Sprint 7 completion.

---

### DA-E47-47 — Write individual sprint report for Sprint 7 — Phước

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Document Phước's contributions in Sprint 7 in `sprint_07/members/phuocnc.md`. Tasks: DA-E18-01/02/04 (Meta OAuth flows), DA-E19-01/02 (TikTok, Threads OAuth), DA-E20-03 (manual token refresh).

**Acceptance Criteria:**

- [ ] Each OAuth flow described: redirect URL, callback handling, token exchange
- [ ] Token storage approach noted (encrypted, MongoDB)
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_07/members/phuocnc.md`

**Dependencies:** Blocks: [DA-E47-48]. Blocked by: Sprint 7 completion.

---

### DA-E47-48 — Review all member reports + write team SPRINT_REPORT for Sprint 7

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Read all 5 Sprint 7 member reports, verify against git history, write `sprint_07/SPRINT_REPORT.md`.

**Acceptance Criteria:**

- [ ] Covers E18 (4), E19 (4), E20 (3), AI-06 (5), AI-07 (8), AI-08 (7) tasks
- [ ] Social OAuth deliverables verified: all 5 platforms OAuth flows working
- [ ] InstantID and image composition pipelines functional
- [ ] Retrospective + action items for Sprint 8

**Dependencies:** Blocks: [DA-E47-49]. Blocked by: [DA-E47-43] through [DA-E47-47].

---

### DA-E47-49 — Finalize and commit Sprint 7 report to brandhub-infrastructure

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Commit all Sprint 7 report files on branch `docs/sprint-07-report` and merge to `develop`.

**Acceptance Criteria:**

- [ ] Commit message: `docs(sprint-07): add sprint 7 team and member reports`
- [ ] PR merged, no placeholders remaining

**Dependencies:** Blocked by: [DA-E47-48].

---

### DA-E47-50 — Write individual sprint report for Sprint 8 — Trung

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Document Trung's contributions in Sprint 8 in `sprint_08/members/trungle.md`. Tasks: DA-E22-03 (publish callback handler in business-service).

**Acceptance Criteria:**

- [ ] Callback endpoint documented: POST /internal/posts/{id}/publish-result
- [ ] Status update logic described (PUBLISHED/FAILED + notification creation)
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_08/members/trungle.md`

**Dependencies:** Blocks: [DA-E47-55]. Blocked by: Sprint 8 completion.

---

### DA-E47-51 — Write individual sprint report for Sprint 8 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's contributions in Sprint 8 in `sprint_08/members/locnv.md`. AI Iteration 4 tasks: DA-AI10-01/04/05 (finalize all FastAPI endpoints, Postman collection, Swagger docs), DA-AI11-03 (Image Composition Research Report).

**Acceptance Criteria:**

- [ ] All finalized FastAPI endpoint paths listed
- [ ] Postman collection file path referenced
- [ ] Image Composition Research Report path and summary included
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_08/members/locnv.md`

**Dependencies:** Blocks: [DA-E47-55]. Blocked by: Sprint 8 completion.

---

### DA-E47-52 — Write individual sprint report for Sprint 8 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's contributions in Sprint 8 in `sprint_08/members/tuannm.md`. Tasks: DA-AI10-02/03 (error handling + retry, integration tests with business-service), DA-AI11-01 (Virtual Ambassador Technical Report).

**Acceptance Criteria:**

- [ ] Integration test results documented (all AI calls from business-service verified)
- [ ] Virtual Ambassador Technical Report path referenced
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_08/members/tuannm.md`

**Dependencies:** Blocks: [DA-E47-55]. Blocked by: Sprint 8 completion.

---

### DA-E47-53 — Write individual sprint report for Sprint 8 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's contributions in Sprint 8 in `sprint_08/members/anha.md`. Tasks: DA-AI09-01 through 08 (Veo video generation), DA-AI11-02 (Video Generation Research Report), DA-AI11-04/05/06 (AI cost analysis, demo video, mentor presentation).

**Acceptance Criteria:**

- [ ] Veo API integration documented: async polling flow, S3 upload, thumbnail extraction
- [ ] 30-prompt benchmark results referenced
- [ ] Cost analysis findings noted
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_08/members/anha.md`

**Dependencies:** Blocks: [DA-E47-55]. Blocked by: Sprint 8 completion.

---

### DA-E47-54 — Write individual sprint report for Sprint 8 — Phước

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Document Phước's contributions in Sprint 8 in `sprint_08/members/phuocnc.md`. Tasks: DA-E21-01 through 07 (publisher-service init + all 5 platform adapters), DA-E22-01/02 (HTTP callback, retry logic).

**Acceptance Criteria:**

- [ ] Publisher service architecture described (RabbitMQ consumer setup)
- [ ] Each platform adapter's API approach documented (Graph API, Content Posting API v2, etc.)
- [ ] Retry logic config noted (3 attempts, 1m/5m/15m backoff)
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_08/members/phuocnc.md`

**Dependencies:** Blocks: [DA-E47-55]. Blocked by: Sprint 8 completion.

---

### DA-E47-55 — Review all member reports + write team SPRINT_REPORT for Sprint 8

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Read all 5 Sprint 8 member reports, verify against git history, write `sprint_08/SPRINT_REPORT.md`.

**Acceptance Criteria:**

- [ ] Covers E21 (7), E22 (3), AI-09 (8), AI-10 (5), AI-11 (6) tasks
- [ ] Publisher service deliverables verified: all 5 platform adapters + retry + callback working
- [ ] AI Iteration 4 complete: all endpoints finalized, research reports written, demo recorded
- [ ] Retrospective + action items for Sprint 9

**Dependencies:** Blocks: [DA-E47-56]. Blocked by: [DA-E47-50] through [DA-E47-54].

---

### DA-E47-56 — Finalize and commit Sprint 8 report to brandhub-infrastructure

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Commit all Sprint 8 report files on branch `docs/sprint-08-report` and merge to `develop`.

**Acceptance Criteria:**

- [ ] Commit message: `docs(sprint-08): add sprint 8 team and member reports`
- [ ] PR merged, no placeholders remaining

**Dependencies:** Blocked by: [DA-E47-55].

---

### DA-E47-57 — Write individual sprint report for Sprint 9 — Trung

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Document Trung's contributions in Sprint 9 in `sprint_09/members/trungle.md`. Tasks: DA-E24-01/02/03 (AI content flow in business-service: ContentRequest → ai-service → draft Post, image/ambassador generation trigger, AI usage tracking).

**Acceptance Criteria:**

- [ ] ContentRequest → ai-service → Post draft flow documented
- [ ] AI credits tracking logic described (quota check against subscription plan)
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_09/members/trungle.md`

**Dependencies:** Blocks: [DA-E47-62]. Blocked by: Sprint 9 completion.

---

### DA-E47-58 — Write individual sprint report for Sprint 9 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's contributions in Sprint 9 in `sprint_09/members/locnv.md`. No Sprint 9 tasks assigned to Lộc in main plan — note any support work or prep for Sprint 10.

**Acceptance Criteria:**

- [ ] Any support contributions documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_09/members/locnv.md`

**Dependencies:** Blocks: [DA-E47-62]. Blocked by: Sprint 9 completion.

---

### DA-E47-59 — Write individual sprint report for Sprint 9 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's contributions in Sprint 9 in `sprint_09/members/tuannm.md`. Tasks: DA-E23-01/02/03 (expose /internal/ai/content, /internal/ai/image, /internal/ai/ambassador endpoints).

**Acceptance Criteria:**

- [ ] Each internal endpoint documented: request/response schema, auth method (X-Internal-Key)
- [ ] S3 URL return format for image/ambassador noted
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_09/members/tuannm.md`

**Dependencies:** Blocks: [DA-E47-62]. Blocked by: Sprint 9 completion.

---

### DA-E47-60 — Write individual sprint report for Sprint 9 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's contributions in Sprint 9 in `sprint_09/members/anha.md`. Tasks: DA-E23-04/05 (expose /internal/ai/video async endpoint with polling, /internal/ai/trends).

**Acceptance Criteria:**

- [ ] Video endpoint async pattern described (jobId → GET status polling)
- [ ] Trends endpoint response format documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_09/members/anha.md`

**Dependencies:** Blocks: [DA-E47-62]. Blocked by: Sprint 9 completion.

---

### DA-E47-61 — Write individual sprint report for Sprint 9 — Phước

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Document Phước's contributions in Sprint 9 in `sprint_09/members/phuocnc.md`. No Sprint 9 tasks assigned to Phước — note any support work or carry-over resolution.

**Acceptance Criteria:**

- [ ] Any carry-over or support work documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_09/members/phuocnc.md`

**Dependencies:** Blocks: [DA-E47-62]. Blocked by: Sprint 9 completion.

---

### DA-E47-62 — Review all member reports + write team SPRINT_REPORT for Sprint 9

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Read all 5 Sprint 9 member reports, verify against git history, write `sprint_09/SPRINT_REPORT.md`.

**Acceptance Criteria:**

- [ ] Covers E23 (5), E24 (3) tasks
- [ ] All 5 internal AI endpoints callable from business-service verified
- [ ] AI content generation flow end-to-end working
- [ ] Retrospective + action items for Sprint 10

**Dependencies:** Blocks: [DA-E47-63]. Blocked by: [DA-E47-57] through [DA-E47-61].

---

### DA-E47-63 — Finalize and commit Sprint 9 report to brandhub-infrastructure

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Commit all Sprint 9 report files on branch `docs/sprint-09-report` and merge to `develop`.

**Acceptance Criteria:**

- [ ] Commit message: `docs(sprint-09): add sprint 9 team and member reports`
- [ ] PR merged, no placeholders remaining

**Dependencies:** Blocked by: [DA-E47-62].

---

### DA-E47-64 — Write individual sprint report for Sprint 10 — Trung

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Document Trung's contributions in Sprint 10 in `sprint_10/members/trungle.md`. Tasks: DA-E28-01/02/03 (content request CRUD + status tracking), DA-E29-01/02 (task assignment + my-tasks endpoint), DA-E30-01/02 (calendar API + scheduling).

**Acceptance Criteria:**

- [ ] Content request status machine documented (7 states: SUBMITTED → APPROVED/REJECTED)
- [ ] All 7 API endpoints documented with paths and key logic
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_10/members/trungle.md`

**Dependencies:** Blocks: [DA-E47-69]. Blocked by: Sprint 10 completion.

---

### DA-E47-65 — Write individual sprint report for Sprint 10 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's contributions in Sprint 10 in `sprint_10/members/locnv.md`. Tasks: DA-E30-03/04 (ContentCalendar React component with drag-drop, PlatformPreview component).

**Acceptance Criteria:**

- [ ] ContentCalendar component documented: drag-drop library used, color-coded status logic
- [ ] PlatformPreview component: format differences per platform (FB/IG/TikTok/Threads) described
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_10/members/locnv.md`

**Dependencies:** Blocks: [DA-E47-69]. Blocked by: Sprint 10 completion.

---

### DA-E47-66 — Write individual sprint report for Sprint 10 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's contributions in Sprint 10 in `sprint_10/members/tuannm.md`. No Sprint 10 tasks assigned to Tuấn — note any support work or carry-over.

**Acceptance Criteria:**

- [ ] Any support or carry-over work documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_10/members/tuannm.md`

**Dependencies:** Blocks: [DA-E47-69]. Blocked by: Sprint 10 completion.

---

### DA-E47-67 — Write individual sprint report for Sprint 10 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's contributions in Sprint 10 in `sprint_10/members/anha.md`. Task: DA-E29-03 (deadline alert management).

**Acceptance Criteria:**

- [ ] Alert mechanism described (scheduler, notification trigger logic)
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_10/members/anha.md`

**Dependencies:** Blocks: [DA-E47-69]. Blocked by: Sprint 10 completion.

---

### DA-E47-68 — Write individual sprint report for Sprint 10 — Phước

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Document Phước's contributions in Sprint 10 in `sprint_10/members/phuocnc.md`. No Sprint 10 tasks assigned to Phước — note any support work.

**Acceptance Criteria:**

- [ ] Any support or carry-over work documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_10/members/phuocnc.md`

**Dependencies:** Blocks: [DA-E47-69]. Blocked by: Sprint 10 completion.

---

### DA-E47-69 — Review all member reports + write team SPRINT_REPORT for Sprint 10

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Read all 5 Sprint 10 member reports, verify against git history, write `sprint_10/SPRINT_REPORT.md`.

**Acceptance Criteria:**

- [ ] Covers E28 (3), E29 (3), E30 (4) tasks
- [ ] Content request lifecycle and calendar verified working end-to-end
- [ ] ContentCalendar and PlatformPreview components in web-dashboard
- [ ] Retrospective + action items for Sprint 11

**Dependencies:** Blocks: [DA-E47-70]. Blocked by: [DA-E47-64] through [DA-E47-68].

---

### DA-E47-70 — Finalize and commit Sprint 10 report to brandhub-infrastructure

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Commit all Sprint 10 report files on branch `docs/sprint-10-report` and merge to `develop`.

**Acceptance Criteria:**

- [ ] Commit message: `docs(sprint-10): add sprint 10 team and member reports`
- [ ] PR merged, no placeholders remaining

**Dependencies:** Blocked by: [DA-E47-69].

---

### DA-E47-71 — Write individual sprint report for Sprint 11 — Trung

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Document Trung's contributions in Sprint 11 in `sprint_11/members/trungle.md`. Tasks: DA-E31-01 through 04 (full approval workflow APIs), DA-E32-01 (Smart Ingestion to RabbitMQ), DA-E33-02/03 (DLQ handler, failure notification).

**Acceptance Criteria:**

- [ ] Approval state machine documented (submit → account review → client approve/reject)
- [ ] Smart Ingestion logic described: post + encrypted token + platform configs → RabbitMQ message
- [ ] DLQ handler Admin API endpoint documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_11/members/trungle.md`

**Dependencies:** Blocks: [DA-E47-76]. Blocked by: Sprint 11 completion.

---

### DA-E47-72 — Write individual sprint report for Sprint 11 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's contributions in Sprint 11 in `sprint_11/members/locnv.md`. No Sprint 11 tasks assigned to Lộc in main plan — note any support or prep work.

**Acceptance Criteria:**

- [ ] Any support work documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_11/members/locnv.md`

**Dependencies:** Blocks: [DA-E47-76]. Blocked by: Sprint 11 completion.

---

### DA-E47-73 — Write individual sprint report for Sprint 11 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's contributions in Sprint 11 in `sprint_11/members/tuannm.md`. No Sprint 11 tasks assigned to Tuấn — note any support work.

**Acceptance Criteria:**

- [ ] Any support work documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_11/members/tuannm.md`

**Dependencies:** Blocks: [DA-E47-76]. Blocked by: Sprint 11 completion.

---

### DA-E47-74 — Write individual sprint report for Sprint 11 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's contributions in Sprint 11 in `sprint_11/members/anha.md`. No Sprint 11 tasks assigned to Ân — note any support work.

**Acceptance Criteria:**

- [ ] Any support work documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_11/members/anha.md`

**Dependencies:** Blocks: [DA-E47-76]. Blocked by: Sprint 11 completion.

---

### DA-E47-75 — Write individual sprint report for Sprint 11 — Phước

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Document Phước's contributions in Sprint 11 in `sprint_11/members/phuocnc.md`. Tasks: DA-E32-02 through 08 (RabbitMQ consumer + all 5 platform adapters in publisher-service + HTTP callback), DA-E33-01 (retry logic).

**Acceptance Criteria:**

- [ ] Publisher service FIFO + exactly-once consumer described
- [ ] Each platform adapter's API version and key steps documented
- [ ] Retry config: 3 attempts, 30s/60s/120s backoff noted
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_11/members/phuocnc.md`

**Dependencies:** Blocks: [DA-E47-76]. Blocked by: Sprint 11 completion.

---

### DA-E47-76 — Review all member reports + write team SPRINT_REPORT for Sprint 11

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Read all 5 Sprint 11 member reports, verify against git history, write `sprint_11/SPRINT_REPORT.md`.

**Acceptance Criteria:**

- [ ] Covers E31 (4), E32 (8), E33 (3) tasks
- [ ] Full publish flow end-to-end verified: approve → enqueue → publish on all 5 platforms
- [ ] DLQ + retry + failure notification working
- [ ] Retrospective + action items for Sprint 12

**Dependencies:** Blocks: [DA-E47-77]. Blocked by: [DA-E47-71] through [DA-E47-75].

---

### DA-E47-77 — Finalize and commit Sprint 11 report to brandhub-infrastructure

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Commit all Sprint 11 report files on branch `docs/sprint-11-report` and merge to `develop`.

**Acceptance Criteria:**

- [ ] Commit message: `docs(sprint-11): add sprint 11 team and member reports`
- [ ] PR merged, no placeholders remaining

**Dependencies:** Blocked by: [DA-E47-76].

---

### DA-E47-78 — Write individual sprint report for Sprint 12 — Trung

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Document Trung's contributions in Sprint 12 in `sprint_12/members/trungle.md`. No Sprint 12 tasks assigned to Trung in main plan — note any support, code review, or unblocking work for Lộc's frontend tasks.

**Acceptance Criteria:**

- [ ] Any support or unblocking contributions documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_12/members/trungle.md`

**Dependencies:** Blocks: [DA-E47-83]. Blocked by: Sprint 12 completion.

---

### DA-E47-79 — Write individual sprint report for Sprint 12 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's contributions in Sprint 12 in `sprint_12/members/locnv.md`. 🔀 _E34/E35/E36 đã chuyển sang Phước sau Sprint 4 rebalance (xem [Rebalance Log](Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4)) — báo cáo tuỳ theo task AI Lộc đang làm song song trong sprint này._

**Acceptance Criteria:**

- [ ] All assigned tasks documented (có thể rỗng nếu không có task nào trong sprint này, ghi rõ "không có task")
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_12/members/locnv.md`

**Dependencies:** Blocks: [DA-E47-83]. Blocked by: Sprint 12 completion.

---

### DA-E47-80 — Write individual sprint report for Sprint 12 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's contributions in Sprint 12 in `sprint_12/members/tuannm.md`. No Sprint 12 tasks assigned to Tuấn — note any support work.

**Acceptance Criteria:**

- [ ] Any support work documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_12/members/tuannm.md`

**Dependencies:** Blocks: [DA-E47-83]. Blocked by: Sprint 12 completion.

---

### DA-E47-81 — Write individual sprint report for Sprint 12 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's contributions in Sprint 12 in `sprint_12/members/anha.md`. No Sprint 12 tasks assigned to Ân — note any support work.

**Acceptance Criteria:**

- [ ] Any support work documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_12/members/anha.md`

**Dependencies:** Blocks: [DA-E47-83]. Blocked by: Sprint 12 completion.

---

### DA-E47-82 — Write individual sprint report for Sprint 12 — Phước

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Document Phước's contributions in Sprint 12 in `sprint_12/members/phuocnc.md`. 🔀 _Nhận từ Lộc sau Sprint 4 rebalance (xem [Rebalance Log](Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4)):_ Tasks: DA-E35-01 through 04 (auth + dashboard + workspace + client pages), DA-E36-01 through 05 (content management pages).

**Acceptance Criteria:**

- [ ] All 9 tasks documented with component names, file paths, and status
- [ ] Login/Register page Google OAuth flow described
- [ ] Content Editor AI Generate Panel integration described
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_12/members/phuocnc.md`

**Dependencies:** Blocks: [DA-E47-83]. Blocked by: Sprint 12 completion.

---

### DA-E47-83 — Review all member reports + write team SPRINT_REPORT for Sprint 12

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Read all 5 Sprint 12 member reports, verify against git history, write `sprint_12/SPRINT_REPORT.md`.

**Acceptance Criteria:**

- [ ] Covers E34 (5), E35 (4), E36 (5) tasks — all 14 assigned to Lộc
- [ ] Web dashboard deliverables verified: design system, auth pages, dashboard, content management pages
- [ ] Note workload concentration on Lộc for this sprint
- [ ] Retrospective + action items for Sprint 13

**Dependencies:** Blocks: [DA-E47-84]. Blocked by: [DA-E47-78] through [DA-E47-82].

---

### DA-E47-84 — Finalize and commit Sprint 12 report to brandhub-infrastructure

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Commit all Sprint 12 report files on branch `docs/sprint-12-report` and merge to `develop`.

**Acceptance Criteria:**

- [ ] Commit message: `docs(sprint-12): add sprint 12 team and member reports`
- [ ] PR merged, no placeholders remaining

**Dependencies:** Blocked by: [DA-E47-83].

---

### DA-E47-85 — Write individual sprint report for Sprint 13 — Trung

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Document Trung's contributions in Sprint 13 in `sprint_13/members/trungle.md`. Tasks: DA-E38-01/02 (analytics aggregation APIs, automated PDF report), DA-E39-01/02 (notification CRUD, notification creation events).

**Acceptance Criteria:**

- [ ] Analytics aggregation query logic described (posts + publish_logs data sources)
- [ ] PDF report generation library and schedule documented
- [ ] Notification event triggers listed (post published, task assigned, token expiry, etc.)
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_13/members/trungle.md`

**Dependencies:** Blocks: [DA-E47-90]. Blocked by: Sprint 13 completion.

---

### DA-E47-86 — Write individual sprint report for Sprint 13 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's contributions in Sprint 13 in `sprint_13/members/locnv.md`. 🔀 _E37/E38-04/E39-03 đã chuyển sang Phước sau Sprint 4 rebalance (xem [Rebalance Log](Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4)) — báo cáo tuỳ theo task AI Lộc đang làm song song trong sprint này._

**Acceptance Criteria:**

- [ ] All assigned tasks documented (có thể rỗng nếu không có task nào trong sprint này, ghi rõ "không có task")
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_13/members/locnv.md`

**Dependencies:** Blocks: [DA-E47-90]. Blocked by: Sprint 13 completion.

---

### DA-E47-87 — Write individual sprint report for Sprint 13 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's contributions in Sprint 13 in `sprint_13/members/tuannm.md`. No Sprint 13 tasks assigned to Tuấn — note any support work.

**Acceptance Criteria:**

- [ ] Any support work documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_13/members/tuannm.md`

**Dependencies:** Blocks: [DA-E47-90]. Blocked by: Sprint 13 completion.

---

### DA-E47-88 — Write individual sprint report for Sprint 13 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's contributions in Sprint 13 in `sprint_13/members/anha.md`. Task: DA-E38-03 (report email sending — auto-send PDF to Brand Client on schedule).

**Acceptance Criteria:**

- [ ] Email sending mechanism documented (email library, schedule config)
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_13/members/anha.md`

**Dependencies:** Blocks: [DA-E47-90]. Blocked by: Sprint 13 completion.

---

### DA-E47-89 — Write individual sprint report for Sprint 13 — Phước

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Document Phước's contributions in Sprint 13 in `sprint_13/members/phuocnc.md`. 🔀 _Nhận từ Lộc sau Sprint 4 rebalance (xem [Rebalance Log](Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4)):_ Tasks: DA-E37-01 through 04 (Client Portal pages), DA-E38-04 (Analytics Dashboard), DA-E39-03 (Notification Center UI).

**Acceptance Criteria:**

- [ ] All 6 tasks documented with component names, file paths, and status
- [ ] Client Portal isolation described (no workspace sidebar, clientId-scoped data)
- [ ] Analytics charts documented (libraries used, chart types)
- [ ] Notification Center: bell icon, unread badge, mark-as-read
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_13/members/phuocnc.md`

**Dependencies:** Blocks: [DA-E47-90]. Blocked by: Sprint 13 completion.

---

### DA-E47-90 — Review all member reports + write team SPRINT_REPORT for Sprint 13

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Read all 5 Sprint 13 member reports, verify against git history, write `sprint_13/SPRINT_REPORT.md`.

**Acceptance Criteria:**

- [ ] Covers E37 (4), E38 (4), E39 (3) tasks
- [ ] Client Portal, Analytics Dashboard, Notification Center verified functional
- [ ] Automated PDF report generation and email sending working
- [ ] Retrospective + action items for Sprint 14

**Dependencies:** Blocks: [DA-E47-91]. Blocked by: [DA-E47-85] through [DA-E47-89].

---

### DA-E47-91 — Finalize and commit Sprint 13 report to brandhub-infrastructure

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Commit all Sprint 13 report files on branch `docs/sprint-13-report` and merge to `develop`.

**Acceptance Criteria:**

- [ ] Commit message: `docs(sprint-13): add sprint 13 team and member reports`
- [ ] PR merged, no placeholders remaining

**Dependencies:** Blocked by: [DA-E47-90].

---

### DA-E47-92 — Write individual sprint report for Sprint 14 — Trung

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Document Trung's contributions in Sprint 14 in `sprint_14/members/trungle.md`. Task: DA-E41-02 (FCM server-side setup in business-service).

**Acceptance Criteria:**

- [ ] FCM integration documented: event triggers, FCM HTTP API v1 call, payload format
- [ ] Deep link data payload structure noted
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_14/members/trungle.md`

**Dependencies:** Blocks: [DA-E47-97]. Blocked by: Sprint 14 completion.

---

### DA-E47-93 — Write individual sprint report for Sprint 14 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's contributions in Sprint 14 in `sprint_14/members/locnv.md`. 🔀 _E40/E41 đã chuyển sang Phước sau Sprint 4 rebalance (xem [Rebalance Log](Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4)) — báo cáo tuỳ theo task AI Lộc đang làm song song trong sprint này._

**Acceptance Criteria:**

- [ ] All assigned tasks documented (có thể rỗng nếu không có task nào trong sprint này, ghi rõ "không có task")
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_14/members/locnv.md`

**Dependencies:** Blocks: [DA-E47-97]. Blocked by: Sprint 14 completion.

---

### DA-E47-94 — Write individual sprint report for Sprint 14 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's contributions in Sprint 14 in `sprint_14/members/tuannm.md`. No Sprint 14 tasks assigned to Tuấn — note any support work.

**Acceptance Criteria:**

- [ ] Any support work documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_14/members/tuannm.md`

**Dependencies:** Blocks: [DA-E47-97]. Blocked by: Sprint 14 completion.

---

### DA-E47-95 — Write individual sprint report for Sprint 14 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's contributions in Sprint 14 in `sprint_14/members/anha.md`. No Sprint 14 tasks assigned to Ân — note any support work.

**Acceptance Criteria:**

- [ ] Any support work documented
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_14/members/anha.md`

**Dependencies:** Blocks: [DA-E47-97]. Blocked by: Sprint 14 completion.

---

### DA-E47-96 — Write individual sprint report for Sprint 14 — Phước

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Document Phước's contributions in Sprint 14 in `sprint_14/members/phuocnc.md`. 🔀 _Nhận từ Lộc sau Sprint 4 rebalance (xem [Rebalance Log](Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4)):_ Tasks: DA-E40-01 through 06 (full React Native app setup + all screens), DA-E41-01/03/04 (FCM client-side, Notification screen, camera/gallery upload).

**Acceptance Criteria:**

- [ ] All 9 tasks documented with screen names, navigation structure, and status
- [ ] Offline draft AsyncStorage key pattern documented
- [ ] FCM permission flow described (first launch request → token save → handler setup)
- [ ] Deep link navigation table included
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_14/members/phuocnc.md`

**Dependencies:** Blocks: [DA-E47-97]. Blocked by: Sprint 14 completion.

---

### DA-E47-97 — Review all member reports + write team SPRINT_REPORT for Sprint 14

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Read all 5 Sprint 14 member reports, verify against git history, write `sprint_14/SPRINT_REPORT.md`.

**Acceptance Criteria:**

- [ ] Covers E40 (6), E41 (4) tasks
- [ ] React Native app verified: runs on iOS + Android, auth screens, calendar, approval, FCM
- [ ] Offline draft + camera/gallery upload working
- [ ] Retrospective + action items for Sprint 15

**Dependencies:** Blocks: [DA-E47-98]. Blocked by: [DA-E47-92] through [DA-E47-96].

---

### DA-E47-98 — Finalize and commit Sprint 14 report to brandhub-infrastructure

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Commit all Sprint 14 report files on branch `docs/sprint-14-report` and merge to `develop`.

**Acceptance Criteria:**

- [ ] Commit message: `docs(sprint-14): add sprint 14 team and member reports`
- [ ] PR merged, no placeholders remaining

**Dependencies:** Blocked by: [DA-E47-97].

---

### DA-E47-99 — Write individual sprint report for Sprint 15 — Trung

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Document Trung's contributions in Sprint 15 in `sprint_15/members/trungle.md`. Tasks: DA-E42-01 (unit tests for AuthService, WorkspaceService, PostService), DA-E43-03 (security audit checklist).

**Acceptance Criteria:**

- [ ] Unit test coverage percentage reported for each service
- [ ] Security audit table completed: 10 checklist items with pass/fail result and evidence
- [ ] Any vulnerabilities found and fixed documented
- [ ] Self-assessment filled

**Technical Notes:**

- Unit test framework: JUnit 5 + Mockito
- Security audit covers: SQL injection, NoSQL injection, XSS, CSRF, JWT, AES key exposure, S3, RabbitMQ, Admin endpoints, internal endpoints
- File: `sprint_15/members/trungle.md`

**Dependencies:** Blocks: [DA-E47-104]. Blocked by: Sprint 15 completion.

---

### DA-E47-100 — Write individual sprint report for Sprint 15 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's contributions in Sprint 15 in `sprint_15/members/locnv.md`. Task: DA-E43-02 (UI responsive fixes across 4 breakpoints).

**Acceptance Criteria:**

- [ ] Responsive fixes documented per breakpoint (1920/1440/1280/mobile)
- [ ] Components/pages that needed fixing listed
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_15/members/locnv.md`

**Dependencies:** Blocks: [DA-E47-104]. Blocked by: Sprint 15 completion.

---

### DA-E47-101 — Write individual sprint report for Sprint 15 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's contributions in Sprint 15 in `sprint_15/members/tuannm.md`. Task: DA-E42-02 (unit tests for ai-service: content generation, RAG pipeline, image generation).

**Acceptance Criteria:**

- [ ] Test coverage per ai-service module reported
- [ ] Mocking strategy documented (Groq API mock, ChromaDB mock, Stability AI mock)
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_15/members/tuannm.md`

**Dependencies:** Blocks: [DA-E47-104]. Blocked by: Sprint 15 completion.

---

### DA-E47-102 — Write individual sprint report for Sprint 15 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's contributions in Sprint 15 in `sprint_15/members/anha.md`. Tasks: DA-E42-04 (performance testing — 200 concurrent users with JMeter/k6), DA-E43-01 (sprint retrospective + bug list compilation, All Team).

**Acceptance Criteria:**

- [ ] Load test results documented: p95 latency, error rate, RPS at 200 concurrent users
- [ ] Bug list from retrospective referenced (count and severity breakdown)
- [ ] Self-assessment filled

**Technical Notes:**

- Target: p95 < 500ms for non-AI endpoints, < 0.1% errors
- File: `sprint_15/members/anha.md`

**Dependencies:** Blocks: [DA-E47-104]. Blocked by: Sprint 15 completion.

---

### DA-E47-103 — Write individual sprint report for Sprint 15 — Phước

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Document Phước's contributions in Sprint 15 in `sprint_15/members/phuocnc.md`. Tasks: DA-E42-03 (integration tests for business-service with Testcontainers), DA-E42-05 (E2E publish test on sandbox accounts for all 5 platforms).

**Acceptance Criteria:**

- [ ] Integration test scenarios documented (auth flow, RBAC, workspace isolation)
- [ ] E2E publish test results per platform (pass/fail + any issues noted)
- [ ] Testcontainers setup described (MongoDB + Redis in Docker)
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_15/members/phuocnc.md`

**Dependencies:** Blocks: [DA-E47-104]. Blocked by: Sprint 15 completion.

---

### DA-E47-104 — Review all member reports + write team SPRINT_REPORT for Sprint 15

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Read all 5 Sprint 15 member reports, verify against git history, write `sprint_15/SPRINT_REPORT.md`.

**Acceptance Criteria:**

- [ ] Covers E42 (5), E43 (3) tasks
- [ ] Test results summary: unit coverage %, integration pass rate, p95 latency, E2E platform results
- [ ] Security audit: all 10 items verified
- [ ] All critical bugs from testing fixed
- [ ] Retrospective + action items for Sprint 16

**Dependencies:** Blocks: [DA-E47-105]. Blocked by: [DA-E47-99] through [DA-E47-103].

---

### DA-E47-105 — Finalize and commit Sprint 15 report to brandhub-infrastructure

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Commit all Sprint 15 report files on branch `docs/sprint-15-report` and merge to `develop`.

**Acceptance Criteria:**

- [ ] Commit message: `docs(sprint-15): add sprint 15 team and member reports`
- [ ] PR merged, no placeholders remaining

**Dependencies:** Blocked by: [DA-E47-104].

---

### DA-E47-106 — Write individual sprint report for Sprint 16 — Trung

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Document Trung's contributions in Sprint 16 in `sprint_16/members/trungle.md`. Tasks: DA-E44-01/02/03 (VPS/EC2 setup, docker-compose.prod.yml deployment, monitoring), DA-E45-01/03 (Swagger API docs, Deployment Guide), DA-E46-02 (report consolidation and review).

**Acceptance Criteria:**

- [ ] Production server specs documented (instance type, OS, nginx config, SSL setup)
- [ ] docker-compose.prod.yml differences from dev noted
- [ ] Monitoring setup documented (UptimeRobot, alert thresholds)
- [ ] Deployment Guide tested cold by a team member
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_16/members/trungle.md`

**Dependencies:** Blocks: [DA-E47-111]. Blocked by: Sprint 16 completion.

---

### DA-E47-107 — Write individual sprint report for Sprint 16 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's contributions in Sprint 16 in `sprint_16/members/locnv.md`. Tasks: DA-E44-04 (smoke test on production), DA-E45-02 (User Manual contribution), DA-E45-04 (demo video), DA-E46-01/03/04 (capstone report, slide deck, Q&A prep).

**Acceptance Criteria:**

- [ ] Smoke test flow documented: registration → login → workspace → social connect → AI generate → approve → publish
- [ ] Sections of User Manual authored by Lộc noted
- [ ] Demo video timestamp breakdown referenced
- [ ] Slide deck sections authored by Lộc noted
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_16/members/locnv.md`

**Dependencies:** Blocks: [DA-E47-111]. Blocked by: Sprint 16 completion.

---

### DA-E47-108 — Write individual sprint report for Sprint 16 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's contributions in Sprint 16 in `sprint_16/members/tuannm.md`. Tasks: DA-E44-04 (smoke test), DA-E45-02 (User Manual — AI features section), DA-E46-01/03/04 (capstone report AI section, slide deck AI slides, Q&A prep for AI questions).

**Acceptance Criteria:**

- [ ] AI section of capstone report described
- [ ] Anticipated Q&A answers prepared (InstantID technical, RAG anti-hallucination)
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_16/members/tuannm.md`

**Dependencies:** Blocks: [DA-E47-111]. Blocked by: Sprint 16 completion.

---

### DA-E47-109 — Write individual sprint report for Sprint 16 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's contributions in Sprint 16 in `sprint_16/members/anha.md`. Tasks: DA-E44-04 (smoke test), DA-E45-02 (User Manual), DA-E46-01/03/04 (capstone report video generation section, slides, Q&A prep for video/cost questions).

**Acceptance Criteria:**

- [ ] Video generation and cost analysis sections of capstone report described
- [ ] AI cost analysis results referenced (per feature × 1000 users/month)
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_16/members/anha.md`

**Dependencies:** Blocks: [DA-E47-111]. Blocked by: Sprint 16 completion.

---

### DA-E47-110 — Write individual sprint report for Sprint 16 — Phước

**Assignee:** Phước (Publisher) | **Priority:** 🟢 Medium

**Goal:** Document Phước's contributions in Sprint 16 in `sprint_16/members/phuocnc.md`. Tasks: DA-E44-04 (smoke test), DA-E45-02 (User Manual — publisher/social accounts section), DA-E46-01/03/04 (capstone report publisher section, slides, Q&A prep for publisher/platform questions).

**Acceptance Criteria:**

- [ ] Publisher service and social platform sections of capstone report described
- [ ] Anticipated Q&A prepared (adapter pattern, API version changes)
- [ ] Self-assessment filled

**Technical Notes:** File: `sprint_16/members/phuocnc.md`

**Dependencies:** Blocks: [DA-E47-111]. Blocked by: Sprint 16 completion.

---

### DA-E47-111 — Review all member reports + write team SPRINT_REPORT for Sprint 16

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Read all 5 Sprint 16 member reports, verify against production evidence, write `sprint_16/SPRINT_REPORT.md` — the final sprint report for the entire project.

**Acceptance Criteria:**

- [ ] Covers E44 (4), E45 (4), E46 (4) tasks
- [ ] Production deployment verified: all 7 services healthy, SSL active, smoke test passed
- [ ] All final documentation confirmed: Swagger, User Manual, Deployment Guide, Demo Video
- [ ] Capstone report submitted to FPT, presentation delivered
- [ ] Final retrospective: overall project reflection (16 sprints), what the team would do differently, key learnings

**Dependencies:** Blocks: [DA-E47-112]. Blocked by: [DA-E47-106] through [DA-E47-110].

---

### DA-E47-112 — Finalize and commit Sprint 16 report to brandhub-infrastructure

**Assignee:** Trung (Leader) | **Priority:** 🟢 Medium

**Goal:** Commit all Sprint 16 report files on branch `docs/sprint-16-report` and merge to `develop`. This is the final commit of the project documentation.

**Acceptance Criteria:**

- [ ] Commit message: `docs(sprint-16): add sprint 16 team and member reports`
- [ ] PR merged to `develop`, then `develop` merged to `main`
- [ ] No placeholder text in any file across all 16 sprint report folders
- [ ] `docs/plan/sprints/` directory structure complete: 16 sprint folders each with `PLAN.md`, `SPRINT_REPORT.md`, and `members/` subfolder

**Dependencies:** Blocked by: [DA-E47-111].

---

> **Individual report format** (tasks DA-E48-{n} where n % 5 ∈ {1..3}): Each AI track member (Tuấn, Ân, Lộc) fills their own `members/{handle}.md` file under the iteration folder. Same 8-section format as E47 individual reports: personal info, task list with Jira links + status, detailed work log per task, incomplete tasks, bonus contributions, learnings, feedback & suggestions, self-assessment (out of 20).
>
> **Team report format** (tasks DA-E48-{n} where n % 5 = 4): Lộc reads all 3 member reports, verifies against git history, then writes `ITERATION_REPORT.md` covering: iteration overview, completion rate, task breakdown table, deliverables list with evidence, retrospective, workload distribution, and action items for the next iteration. Lộc plays this aggregator role for the AI track the same way Trung does for sprints in E47.
>
> **Finalize task** (tasks DA-E48-{n} where n % 5 = 0): Commit all report files to `brandhub-infrastructure` under `docs/plan/iterations/iteration_{X}/` on branch `docs/ai-iteration-{X}-report`, then merge to `develop`.

---

### DA-E48-01 — Write individual AI iteration report for Iteration 1 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's personal contributions in AI Iteration 1 in `iterations/iteration_1/members/tuannm.md`, covering AI-01 ambassador-tool research/comparison work.

**Acceptance Criteria:**

- [ ] All assigned tasks (DA-AI01-01, DA-AI01-02) listed with Jira links and final status
- [ ] Each task has: branch name, commit hash, files changed, work description, time spent
- [ ] Self-assessment table filled (score out of 20)
- [ ] File submitted before iteration review meeting

**Technical Notes:**

- Iteration 1 tasks: DA-AI01-01 (InstantID vs IP-Adapter vs ControlNet research), DA-AI01-02 (comparison table on 5 sample images)
- File: `iterations/iteration_1/members/tuannm.md`

**Dependencies:** Blocks: [DA-E48-04]. Blocked by: AI Iteration 1 work completion.

---

### DA-E48-02 — Write individual AI iteration report for Iteration 1 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's personal contributions in AI Iteration 1 in `iterations/iteration_1/members/anha.md`, covering AI-01 video research and the consolidated AI Research Summary Document.

**Acceptance Criteria:**

- [ ] All assigned tasks (DA-AI01-03, DA-AI01-04, DA-AI01-08) listed with Jira links and final status
- [ ] Each task has: branch name, commit hash, files changed, work description, time spent
- [ ] AI Research Summary Document (DA-AI01-08) linked as deliverable evidence
- [ ] Self-assessment filled

**Technical Notes:**

- Iteration 1 tasks: DA-AI01-03 (Google Veo API research), DA-AI01-04 (20+ video prompt tests), DA-AI01-08 (research summary doc)
- File: `iterations/iteration_1/members/anha.md`

**Dependencies:** Blocks: [DA-E48-04]. Blocked by: AI Iteration 1 work completion.

---

### DA-E48-03 — Write individual AI iteration report for Iteration 1 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's personal contributions in AI Iteration 1 in `iterations/iteration_1/members/locnv.md`, covering AI-01 compositing research and AI-02 service scaffolding.

**Acceptance Criteria:**

- [ ] All assigned tasks (DA-AI01-05/06, DA-AI02-01/03/05) listed with Jira links and final status
- [ ] Each task has: branch name, commit hash, files changed, work description, time spent
- [ ] `brandhub-ai-service` scaffold and Dockerfile work documented with commit evidence
- [ ] Self-assessment filled

**Technical Notes:**

- Iteration 1 tasks: DA-AI01-05/06 (compositing research), DA-AI02-01 (ai-service init), DA-AI02-03 (S3 client), DA-AI02-05 (Dockerfile + docker-compose)
- File: `iterations/iteration_1/members/locnv.md`

**Dependencies:** Blocks: [DA-E48-04]. Blocked by: AI Iteration 1 work completion.

---

### DA-E48-04 — Review all member reports + write team ITERATION_REPORT for Iteration 1

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Read all 3 member reports for AI Iteration 1, verify claims against git history, then write the team-level `iterations/iteration_1/ITERATION_REPORT.md` covering overall iteration outcome, completion rate, and retrospective.

**Acceptance Criteria:**

- [ ] All 3 member report files exist and are non-empty before starting this task
- [ ] ITERATION_REPORT.md covers: iteration overview, completion rate, deliverables table with evidence, retrospective, workload table, action items for Iteration 2
- [ ] Completion rate and deliverables verified against git log
- [ ] Decisions required for downstream iterations (InstantID choice, LLM choice) explicitly recorded with rationale

**Technical Notes:**

- Iteration 1: 15 tasks total (AI-01: 8, AI-02: 7)
- Main deliverables: 3 comparison reports, AI Research Summary Document, `brandhub-ai-service` scaffolded and running
- File: `iterations/iteration_1/ITERATION_REPORT.md`

**Dependencies:** Blocks: [DA-E48-05]. Blocked by: [DA-E48-01], [DA-E48-02], [DA-E48-03].

---

### DA-E48-05 — Finalize and commit Iteration 1 report to brandhub-infrastructure

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Commit all AI Iteration 1 report files (`ITERATION_REPORT.md` + all member `.md` files) to `brandhub-infrastructure` on the correct branch and merge to `develop`.

**Acceptance Criteria:**

- [ ] Branch `docs/ai-iteration-1-report` created from `develop`
- [ ] All files under `docs/plan/iterations/iteration_1/` committed with conventional commit message: `docs(ai-iteration-1): add iteration 1 team and member reports`
- [ ] PR opened, reviewed by at least 1 member, merged to `develop`
- [ ] No placeholder text remaining in any report file

**Technical Notes:**

- Target path: `docs/plan/iterations/iteration_1/`
- Conventional commit: `docs(ai-iteration-1): add iteration 1 team and member reports`

**Dependencies:** Blocks: [DA-E48-06]. Blocked by: [DA-E48-04].

---

### DA-E48-06 — Write individual AI iteration report for Iteration 2 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's personal contributions in AI Iteration 2 in `iterations/iteration_2/members/tuannm.md`, covering ChromaDB/RAG infrastructure and LLM client work from AI-02/AI-03.

**Acceptance Criteria:**

- [ ] All assigned tasks listed with Jira links and final status
- [ ] Each task has: branch name, commit hash, files changed, work description, time spent
- [ ] Self-assessment filled

**Technical Notes:**

- Iteration 2 epics: AI-03 (RAG Knowledge Base Pipeline), AI-04 (LLM Content Generation), AI-05 (Trend Crawler Service) — see `iterations/AI_Iteration_2_RAG_LLM_Trends.md` for Tuấn's exact task assignments
- File: `iterations/iteration_2/members/tuannm.md`

**Dependencies:** Blocks: [DA-E48-09]. Blocked by: AI Iteration 2 work completion.

---

### DA-E48-07 — Write individual AI iteration report for Iteration 2 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's personal contributions in AI Iteration 2 in `iterations/iteration_2/members/anha.md`, covering RAG chunking/context builder, LLM prompt system, and trend crawler work.

**Acceptance Criteria:**

- [ ] All assigned tasks listed with Jira links and final status
- [ ] Each task has: branch name, commit hash, files changed, work description, time spent
- [ ] Self-assessment filled

**Technical Notes:**

- Iteration 2 epics: AI-03, AI-04, AI-05 — see `iterations/AI_Iteration_2_RAG_LLM_Trends.md` for Ân's exact task assignments
- File: `iterations/iteration_2/members/anha.md`

**Dependencies:** Blocks: [DA-E48-09]. Blocked by: AI Iteration 2 work completion.

---

### DA-E48-08 — Write individual AI iteration report for Iteration 2 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's personal contributions in AI Iteration 2 in `iterations/iteration_2/members/locnv.md`.

**Acceptance Criteria:**

- [ ] All assigned tasks listed with Jira links and final status
- [ ] Each task has: branch name, commit hash, files changed, work description, time spent
- [ ] Self-assessment filled

**Technical Notes:**

- Iteration 2 epics: AI-03, AI-04, AI-05 — see `iterations/AI_Iteration_2_RAG_LLM_Trends.md` for Lộc's exact task assignments
- File: `iterations/iteration_2/members/locnv.md`

**Dependencies:** Blocks: [DA-E48-09]. Blocked by: AI Iteration 2 work completion.

---

### DA-E48-09 — Review all member reports + write team ITERATION_REPORT for Iteration 2

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Read all 3 member reports for AI Iteration 2, verify claims against git history, then write `iterations/iteration_2/ITERATION_REPORT.md`.

**Acceptance Criteria:**

- [ ] All 3 member report files exist and are non-empty before starting this task
- [ ] ITERATION_REPORT.md covers: iteration overview, completion rate, deliverables table with evidence, retrospective, workload table, action items for Iteration 3
- [ ] Completion rate and deliverables verified against git log

**Technical Notes:**

- Main deliverables: RAG pipeline working, LLM content generation with anti-hallucination, trend crawler
- File: `iterations/iteration_2/ITERATION_REPORT.md`

**Dependencies:** Blocks: [DA-E48-10]. Blocked by: [DA-E48-06], [DA-E48-07], [DA-E48-08].

---

### DA-E48-10 — Finalize and commit Iteration 2 report to brandhub-infrastructure

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Commit all AI Iteration 2 report files to `brandhub-infrastructure` on the correct branch and merge to `develop`.

**Acceptance Criteria:**

- [ ] Branch `docs/ai-iteration-2-report` created from `develop`
- [ ] All files under `docs/plan/iterations/iteration_2/` committed with conventional commit message: `docs(ai-iteration-2): add iteration 2 team and member reports`
- [ ] PR opened, reviewed by at least 1 member, merged to `develop`
- [ ] No placeholder text remaining in any report file

**Technical Notes:** Conventional commit: `docs(ai-iteration-2): add iteration 2 team and member reports`

**Dependencies:** Blocks: [DA-E48-11]. Blocked by: [DA-E48-09].

---

### DA-E48-11 — Write individual AI iteration report for Iteration 3 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's personal contributions in AI Iteration 3 in `iterations/iteration_3/members/tuannm.md`, covering InstantID ambassador pipeline work.

**Acceptance Criteria:**

- [ ] All assigned tasks listed with Jira links and final status
- [ ] Each task has: branch name, commit hash, files changed, work description, time spent
- [ ] Self-assessment filled

**Technical Notes:**

- Iteration 3 epics: AI-07 (Virtual Brand Ambassador / InstantID) + **AI-08 (Image Composition Pipeline) 🔀 nhận từ Lộc sau Sprint 4 rebalance** — see `iterations/AI_Iteration_3_Image_Ambassador_Composition.md` for Tuấn's exact task assignments
- File: `iterations/iteration_3/members/tuannm.md`

**Dependencies:** Blocks: [DA-E48-14]. Blocked by: AI Iteration 3 work completion.

---

### DA-E48-12 — Write individual AI iteration report for Iteration 3 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's personal contributions in AI Iteration 3 in `iterations/iteration_3/members/anha.md`.

**Acceptance Criteria:**

- [ ] All assigned tasks listed with Jira links and final status
- [ ] Each task has: branch name, commit hash, files changed, work description, time spent
- [ ] Self-assessment filled

**Technical Notes:**

- **AI-06 (Image Generation Pipeline) 🔀 nhận từ Lộc sau Sprint 4 rebalance** — see `iterations/AI_Iteration_3_Image_Ambassador_Composition.md` for Ân's exact task assignments
- File: `iterations/iteration_3/members/anha.md`

**Dependencies:** Blocks: [DA-E48-14]. Blocked by: AI Iteration 3 work completion.

---

### DA-E48-13 — Write individual AI iteration report for Iteration 3 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's personal contributions in AI Iteration 3 in `iterations/iteration_3/members/locnv.md`. 🔀 _AI-06 và AI-08 đã chuyển sang Ân/Tuấn sau Sprint 4 rebalance (xem [Rebalance Log](Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4)) — nội dung report của Lộc trong iteration này còn lại tuỳ theo task infra/hỗ trợ khác Lộc nhận, nếu không có việc gì trong iteration thì ghi rõ "không có task" thay vì để trống._

**Acceptance Criteria:**

- [ ] All assigned tasks listed with Jira links and final status (có thể rỗng nếu không có task nào trong iteration này)
- [ ] Each task has: branch name, commit hash, files changed, work description, time spent
- [ ] Self-assessment filled

**Technical Notes:**

- Iteration 3 epics AI-06 (Image Generation) và AI-08 (Image Composition) đã chuyển sang Ân và Tuấn — xem DA-E48-11, DA-E48-12
- File: `iterations/iteration_3/members/locnv.md`

**Dependencies:** Blocks: [DA-E48-14]. Blocked by: AI Iteration 3 work completion.

---

### DA-E48-14 — Review all member reports + write team ITERATION_REPORT for Iteration 3

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Read all 3 member reports for AI Iteration 3, verify claims against git history, then write `iterations/iteration_3/ITERATION_REPORT.md`.

**Acceptance Criteria:**

- [ ] All 3 member report files exist and are non-empty before starting this task
- [ ] ITERATION_REPORT.md covers: iteration overview, completion rate, deliverables table with evidence, retrospective, workload table, action items for Iteration 4
- [ ] Completion rate and deliverables verified against git log

**Technical Notes:**

- Main deliverables: Image generation (SDXL), InstantID ambassador, image composition pipeline
- File: `iterations/iteration_3/ITERATION_REPORT.md`

**Dependencies:** Blocks: [DA-E48-15]. Blocked by: [DA-E48-11], [DA-E48-12], [DA-E48-13].

---

### DA-E48-15 — Finalize and commit Iteration 3 report to brandhub-infrastructure

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Commit all AI Iteration 3 report files to `brandhub-infrastructure` on the correct branch and merge to `develop`.

**Acceptance Criteria:**

- [ ] Branch `docs/ai-iteration-3-report` created from `develop`
- [ ] All files under `docs/plan/iterations/iteration_3/` committed with conventional commit message: `docs(ai-iteration-3): add iteration 3 team and member reports`
- [ ] PR opened, reviewed by at least 1 member, merged to `develop`
- [ ] No placeholder text remaining in any report file

**Technical Notes:** Conventional commit: `docs(ai-iteration-3): add iteration 3 team and member reports`

**Dependencies:** Blocks: [DA-E48-16]. Blocked by: [DA-E48-14].

---

### DA-E48-16 — Write individual AI iteration report for Iteration 4 — Tuấn

**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Document Tuấn's personal contributions in AI Iteration 4 in `iterations/iteration_4/members/tuannm.md`.

**Acceptance Criteria:**

- [ ] All assigned tasks listed with Jira links and final status
- [ ] Each task has: branch name, commit hash, files changed, work description, time spent
- [ ] Self-assessment filled

**Technical Notes:**

- Iteration 4 epics: AI-09 (AI Video Generation), AI-10 (AI Service Integration & API Finalize), AI-11 (AI Research Documentation & Demo) — see `iterations/AI_Iteration_4_Video_Integration_Documentation.md` for Tuấn's exact task assignments
- File: `iterations/iteration_4/members/tuannm.md`

**Dependencies:** Blocks: [DA-E48-19]. Blocked by: AI Iteration 4 work completion.

---

### DA-E48-17 — Write individual AI iteration report for Iteration 4 — Ân

**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Document Ân's personal contributions in AI Iteration 4 in `iterations/iteration_4/members/anha.md`, covering Veo video generation and AI research summaries.

**Acceptance Criteria:**

- [ ] All assigned tasks listed with Jira links and final status
- [ ] Each task has: branch name, commit hash, files changed, work description, time spent
- [ ] Self-assessment filled

**Technical Notes:**

- Iteration 4 epics: AI-09, AI-10, AI-11 — see `iterations/AI_Iteration_4_Video_Integration_Documentation.md` for Ân's exact task assignments
- File: `iterations/iteration_4/members/anha.md`

**Dependencies:** Blocks: [DA-E48-19]. Blocked by: AI Iteration 4 work completion.

---

### DA-E48-18 — Write individual AI iteration report for Iteration 4 — Lộc

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Document Lộc's personal contributions in AI Iteration 4 in `iterations/iteration_4/members/locnv.md`.

**Acceptance Criteria:**

- [ ] All assigned tasks listed with Jira links and final status
- [ ] Each task has: branch name, commit hash, files changed, work description, time spent
- [ ] Self-assessment filled

**Technical Notes:**

- Iteration 4 epics: AI-09, AI-10, AI-11 — see `iterations/AI_Iteration_4_Video_Integration_Documentation.md` for Lộc's exact task assignments
- File: `iterations/iteration_4/members/locnv.md`

**Dependencies:** Blocks: [DA-E48-19]. Blocked by: AI Iteration 4 work completion.

---

### DA-E48-19 — Review all member reports + write team ITERATION_REPORT for Iteration 4

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Read all 3 member reports for AI Iteration 4, verify claims against git history, then write `iterations/iteration_4/ITERATION_REPORT.md`. This is the final AI track report, consolidating the full 4-iteration AI track outcome.

**Acceptance Criteria:**

- [ ] All 3 member report files exist and are non-empty before starting this task
- [ ] ITERATION_REPORT.md covers: iteration overview, completion rate, deliverables table with evidence, retrospective, workload table
- [ ] Completion rate and deliverables verified against git log
- [ ] Final AI track retrospective: overall reflection across all 4 iterations, what the team would do differently, key learnings

**Technical Notes:**

- Main deliverables: Veo video generation, all AI endpoints finalized, integration tests, AI research reports
- File: `iterations/iteration_4/ITERATION_REPORT.md`

**Dependencies:** Blocks: [DA-E48-20]. Blocked by: [DA-E48-16], [DA-E48-17], [DA-E48-18].

---

### DA-E48-20 — Finalize and commit Iteration 4 report to brandhub-infrastructure

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🟢 Medium

**Goal:** Commit all AI Iteration 4 report files on branch `docs/ai-iteration-4-report` and merge to `develop`. This is the final commit of the AI track documentation.

**Acceptance Criteria:**

- [ ] Commit message: `docs(ai-iteration-4): add iteration 4 team and member reports`
- [ ] PR merged to `develop`, then `develop` merged to `main`
- [ ] No placeholder text in any file across all 4 iteration report folders
- [ ] `docs/plan/iterations/` directory structure complete: 4 iteration folders each with `ITERATION_REPORT.md` and `members/` subfolder

**Dependencies:** Blocked by: [DA-E48-19].

---

### DA-E28-03 — Implement status transition logic

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Enforce valid ContentRequest state machine transitions so that invalid status changes are rejected and audit trail is maintained.

**Acceptance Criteria:**

- [ ] Only allowed transitions execute: SUBMITTED→ASSIGNED, ASSIGNED→IN_PROGRESS, IN_PROGRESS→PENDING_REVIEW, PENDING_REVIEW→SENT_TO_CLIENT, SENT_TO_CLIENT→APPROVED, SENT_TO_CLIENT→REJECTED
- [ ] Attempt to perform an out-of-order transition returns 409 Conflict with descriptive message
- [ ] Each transition records `updatedAt` timestamp and `updatedBy` userId
- [ ] Status history is stored as an embedded array `statusHistory: [{status, changedAt, changedBy}]`
- [ ] Unit tests cover all valid and at least 5 invalid transitions

**Technical Notes:**

- Implement a `ContentRequestStateMachine` service class with a transition map `Map<Status, Set<Status>> allowedTransitions`
- Throw a custom `InvalidStatusTransitionException` mapped to 409 in `@ControllerAdvice`

**Dependencies:** Blocks: [DA-E29-01, DA-E31-01]. Blocked by: [DA-E28-01].

---

### DA-E29-01 — Implement PUT /api/v1/content-requests/{id}/assign

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow ACCOUNT_MANAGER to assign a content request to a CONTENT_CREATOR and transition status to ASSIGNED.

**Acceptance Criteria:**

- [ ] PUT /api/v1/content-requests/{id}/assign with body `{assigneeId}` sets `assigneeId` on the request and transitions status SUBMITTED→ASSIGNED
- [ ] Returns 404 if content request ID does not exist
- [ ] Returns 400 if assigneeId does not correspond to a CONTENT_CREATOR in the same workspace
- [ ] Returns 403 if caller is not ACCOUNT_MANAGER
- [ ] A notification is created for the assigned CONTENT_CREATOR (event: task_assigned)

**Technical Notes:**

- Validate that `assigneeId` has role CONTENT_CREATOR and belongs to the same workspaceId as the request
- Trigger notification via `NotificationService.createTaskAssignedNotification(assigneeId, requestId)`
- Reuse state machine from DA-E28-03 to perform the SUBMITTED→ASSIGNED transition

**Dependencies:** Blocks: [DA-E29-02]. Blocked by: [DA-E28-03].

---

### DA-E29-02 — Implement GET /api/v1/content-requests/my-tasks

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow CONTENT_CREATOR to view all tasks assigned to them with optional filtering by status.

**Acceptance Criteria:**

- [ ] GET /api/v1/content-requests/my-tasks returns paginated list where `assigneeId` equals authenticated user's ID
- [ ] Supports `?status=&page=&size=` query params
- [ ] Returns 403 if caller is not CONTENT_CREATOR
- [ ] Each item includes `deadline`, `platform`, `topic`, `status`, `contentRequestId`
- [ ] Results are sorted by `deadline ASC` by default

**Technical Notes:**

- Filter by `assigneeId = currentUserId` at the repository layer; do not expose other users' tasks
- Add composite MongoDB index on `{assigneeId, status}` for query performance

**Dependencies:** Blocks: [DA-E36-01]. Blocked by: [DA-E29-01].

---

### DA-E29-03 — Implement deadline alert notification

**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Automatically notify CONTENT_CREATOR when a task deadline is within 24 hours to prevent missed deadlines.

**Acceptance Criteria:**

- [ ] A scheduled job runs every 15 minutes and queries content requests with `deadline BETWEEN now AND now+24h` and status not in (APPROVED, REJECTED)
- [ ] A notification with event type `deadline_24h` is created for the assigned CONTENT_CREATOR if not already notified
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
- [ ] Scoped to the authenticated user's workspaceId (ACCOUNT_MANAGER sees all workspace posts; CONTENT_CREATOR sees own assigned posts; BRAND_CLIENT sees own clientId's posts)
- [ ] Response includes `postId`, `title`, `scheduledAt`, `platform`, `status`, `thumbnailUrl` per post
- [ ] Maximum date range is 90 days; request exceeding this returns 400

**Technical Notes:**

- MongoDB index on `{workspaceId, scheduledAt}` is required for performance
- Use `@DateTimeFormat(iso = ISO.DATE)` on query params and convert to `LocalDate` then to UTC range `[startOfDay, endOfDay]`

**Dependencies:** Blocks: [DA-E30-03]. Blocked by: [None].

---

### DA-E30-02 — Implement POST /api/v1/posts/{id}/schedule

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow ACCOUNT_MANAGER to set a publish time for an approved post and enqueue it to RabbitMQ for delayed delivery.

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

**Goal:** Provide accurate per-platform post previews so content creators and clients can visualize how a post will appear before publishing.

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

**Goal:** Allow CONTENT_CREATOR to submit a drafted post for internal review, triggering an ACCOUNT_MANAGER notification.

**Acceptance Criteria:**

- [ ] POST /api/v1/posts/{id}/submit transitions post status DRAFT→PENDING_REVIEW
- [ ] Returns 403 if caller is not the assigned CONTENT_CREATOR for this post
- [ ] Returns 409 if post status is not DRAFT
- [ ] A notification of type `post_submitted` is created for the ACCOUNT_MANAGER responsible for the linked content request
- [ ] Response returns updated post object with new status and `submittedAt` timestamp

**Technical Notes:**

- Resolve the responsible ACCOUNT_MANAGER via `ContentRequest.accountManagerId` linked to the post
- Set `submittedAt = now()` on the Post document upon successful transition

**Dependencies:** Blocks: [DA-E31-02]. Blocked by: [DA-E28-03].

---

### DA-E31-02 — Implement POST /api/v1/posts/{id}/account-review

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow ACCOUNT_MANAGER to approve a post for client review or reject it back to draft with a feedback note.

**Acceptance Criteria:**

- [ ] POST /api/v1/posts/{id}/account-review with body `{decision: "APPROVE"|"REJECT", note?: string}`
- [ ] APPROVE transitions status PENDING_REVIEW→SENT_TO_CLIENT and creates `post_sent_to_client` notification for BRAND_CLIENT
- [ ] REJECT transitions status PENDING_REVIEW→DRAFT and stores `rejectionNote` on the post document
- [ ] Returns 403 if caller is not ACCOUNT_MANAGER in the same workspace
- [ ] Returns 409 if post status is not PENDING_REVIEW

**Technical Notes:**

- `note` is required when `decision = REJECT`; return 400 if missing
- Notification to BRAND_CLIENT should include post title and a link to the approval page

**Dependencies:** Blocks: [DA-E31-03, DA-E31-04]. Blocked by: [DA-E31-01].

---

### DA-E31-03 — Implement POST /api/v1/posts/{id}/client-approve

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow BRAND_CLIENT to approve a post for scheduling, which triggers the scheduling pipeline automatically.

**Acceptance Criteria:**

- [ ] POST /api/v1/posts/{id}/client-approve transitions status SENT_TO_CLIENT→SCHEDULED
- [ ] Returns 403 if caller's clientId does not match the post's clientId
- [ ] Returns 409 if post status is not SENT_TO_CLIENT
- [ ] Upon approval, if `scheduledAt` is already set, a `PublishJobMessage` is enqueued to RabbitMQ delayed exchange immediately
- [ ] If `scheduledAt` is not set, status becomes APPROVED (pending manual scheduling by ACCOUNT_MANAGER)
- [ ] Response includes updated post with `approvedAt` timestamp

**Technical Notes:**

- Reuse the same RabbitMQ enqueue logic from DA-E30-02 to avoid duplication
- Emit a `client_approved` internal event so ACCOUNT_MANAGER is notified

**Dependencies:** Blocks: [DA-E32-01]. Blocked by: [DA-E31-02].

---

### DA-E31-04 — Implement POST /api/v1/posts/{id}/client-reject

**Assignee:** Trung (Leader) | **Priority:** 🔴 Critical

**Goal:** Allow BRAND_CLIENT to reject a post with written feedback, returning it to DRAFT status for revision.

**Acceptance Criteria:**

- [ ] POST /api/v1/posts/{id}/client-reject with body `{feedback: string}` transitions status SENT_TO_CLIENT→DRAFT
- [ ] `feedback` field is required; returns 400 if empty or missing
- [ ] Returns 403 if caller's clientId does not match the post's clientId
- [ ] Returns 409 if post status is not SENT_TO_CLIENT
- [ ] `clientFeedback` is stored on the post document and is visible to CONTENT_CREATOR in the editor
- [ ] A notification is created for ACCOUNT_MANAGER and CONTENT_CREATOR with the rejection feedback

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
- Handle token expiry (error code 190) as a non-retryable error; notify ACCOUNT_MANAGER to reconnect
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
- [ ] On SUCCESS: updates post status to PUBLISHED, stores `platformPostId`, `publishedAt`, creates `post_published` notification for ACCOUNT_MANAGER
- [ ] On FAILED: updates post status to FAILED, stores `errorMessage`, creates `post_failed` notification for ACCOUNT_MANAGER
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

**Goal:** Notify ACCOUNT_MANAGER when a post fails all retries so they can take corrective action promptly.

**Acceptance Criteria:**

- [ ] When a message enters DLQ, a `post_failed` notification is created for the ACCOUNT_MANAGER of the workspace
- [ ] Notification includes post title, target platform, and the final error message
- [ ] If ACCOUNT_MANAGER has an FCM token, a push notification is also dispatched
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
- [ ] AuthGuard: reads role from `authStore`; redirects AGENCY_OWNER → /workspace, BRAND_CLIENT → /portal, ADMIN → /admin; unauthenticated → /login
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
- [ ] Team stats section shows per-member post counts (AGENCY_OWNER/ACCOUNT_MANAGER view only)
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

**Goal:** Allow AGENCY_OWNER to create and configure their workspace and manage team members through a dedicated settings UI.

**Acceptance Criteria:**

- [ ] Create Workspace page: name, subdomain, logo upload fields; calls POST /api/v1/workspaces; redirects to workspace settings on success
- [ ] Workspace Settings panel: edit name/logo, view subscription plan, danger zone (delete workspace)
- [ ] Member list table: shows name, email, role, joined date; supports search by name/email
- [ ] Invite member flow: email input + role selector → POST /api/v1/workspaces/{id}/invite → success toast
- [ ] Remove member: confirmation modal → DELETE /api/v1/workspaces/{id}/members/{userId}

**Technical Notes:**

- Logo upload uses POST /api/v1/media/upload → returns S3 URL → stored as `workspace.logoUrl`
- Role selector options filtered by caller's role (AGENCY_OWNER cannot invite another AGENCY_OWNER)
- Invitation email is handled server-side; frontend only needs to show success/failure state

**Dependencies:** Blocks: [DA-E35-04]. Blocked by: [DA-E35-01].

---

### DA-E35-04 — Build Client management pages

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Provide ACCOUNT_MANAGER and AGENCY_OWNER with CRUD pages for managing brand clients and their service packages.

**Acceptance Criteria:**

- [ ] Client list page: searchable table with client name, assigned manager, active posts count, service package, status badge
- [ ] Create/Edit client form: name, logo, contact email, assigned account manager, service package (starter/growth/enterprise)
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

**Goal:** Provide ACCOUNT_MANAGER and CONTENT_CREATOR with a filterable, paginated view of all content requests relevant to their role.

**Acceptance Criteria:**

- [ ] Table columns: topic, platform (icon), client name, deadline, status badge, assignee, actions
- [ ] Filter bar: status multi-select, platform multi-select, deadline date range picker
- [ ] Pagination: 20 rows per page, page controls at bottom
- [ ] ACCOUNT_MANAGER sees "Assign" button per row; clicking opens an assignee picker modal
- [ ] CONTENT_CREATOR sees "View My Tasks" tab that calls GET /api/v1/content-requests/my-tasks
- [ ] Clicking any row navigates to Content Editor page for that request

**Technical Notes:**

- Filter state stored in URL query params (using `useSearchParams`) so the view is bookmarkable and shareable
- Debounce filter changes by 300ms before firing API calls
- Status badges use the `Badge` component with color mapped to status: SUBMITTED=gray, ASSIGNED=blue, IN_PROGRESS=yellow, PENDING_REVIEW=orange, SENT_TO_CLIENT=purple, APPROVED=green, REJECTED=red

**Dependencies:** Blocks: [DA-E36-02]. Blocked by: [DA-E28-02, DA-E29-02, DA-E35-04].

---

### DA-E36-02 — Build Content Editor page with AI Generate Panel

**Assignee:** Lộc (AI Sub-lead) | **Priority:** 🔴 Critical

**Goal:** Deliver the primary content creation interface where CONTENT_CREATOR writes or AI-generates captions, selects hashtags, attaches media, and submits for review.

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

**Goal:** Give content creators and clients a realistic visual mockup of how each post will appear on each social platform before publishing.

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

**Goal:** Provide BRAND_CLIENT users with a dedicated, isolated portal entry point that enforces role-based access and prevents cross-client data exposure.

**Acceptance Criteria:**

- [ ] All portal routes are under `/portal/*`; accessing without BRAND_CLIENT role redirects to `/portal/login`
- [ ] Portal login page is visually distinct from agency login (different branding, no workspace selector)
- [ ] AuthGuard on portal routes verifies `user.role === BRAND_CLIENT` and `user.clientId` is present; fails → redirect to /portal/login
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

**Goal:** Give BRAND_CLIENT a read-only calendar view of their scheduled and published posts so they have visibility into their content plan without editing capabilities.

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

**Goal:** Allow BRAND_CLIENT to review posts sent for their approval, see platform previews, and approve or reject with written feedback.

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

**Goal:** Provide BRAND_CLIENT with a self-service analytics view showing their campaign performance so they can assess ROI without requiring an agency report.

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
- [ ] AGENCY_OWNER/ACCOUNT_MANAGER can query by workspaceId; BRAND_CLIENT can only query their own clientId
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

**Goal:** Automatically email PDF analytics reports to BRAND_CLIENT contacts after report generation so clients receive insights without logging into the portal.

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

**Goal:** Deliver the agency-facing analytics page with interactive charts giving AGENCY_OWNER and ACCOUNT_MANAGER a comprehensive view of content performance.

**Acceptance Criteria:**

- [ ] Line chart: posts published per day for selected date range using `<LineChart>` from Recharts
- [ ] Pie chart: post distribution by platform (5 slices: FB, IG, TikTok, Threads) using `<PieChart>`
- [ ] Bar chart: success rate per platform using `<BarChart>`
- [ ] KPI cards row: total published, total failed, overall success rate, most active platform
- [ ] Date range selector (7d / 30d / 90d / custom); updating range refetches and animates chart transitions
- [ ] Client filter dropdown (AGENCY_OWNER/ACCOUNT_MANAGER only): filter all charts to a specific client

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

- [ ] `post_published`: recipient = ACCOUNT_MANAGER; message = "Post '{title}' published successfully on {platform}"
- [ ] `post_failed`: recipient = ACCOUNT_MANAGER; message = "Post '{title}' failed to publish on {platform}: {errorMessage}"
- [ ] `task_assigned`: recipient = CONTENT_CREATOR; message = "You have been assigned a new task: '{topic}'"
- [ ] `post_submitted`: recipient = ACCOUNT_MANAGER; message = "{creatorName} submitted '{title}' for review"
- [ ] `post_sent_to_client`: recipient = BRAND_CLIENT; message = "A new post is ready for your approval"
- [ ] `token_expiring_3d`: recipient = AGENCY_OWNER; message = "{platform} access token for '{clientName}' expires in 3 days"
- [ ] `deadline_24h`: recipient = CONTENT_CREATOR; message = "Task '{topic}' deadline is in less than 24 hours"
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

**Goal:** Allow BRAND_CLIENT to approve or reject posts directly from their phone, making the approval workflow accessible without a desktop browser.

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

**Goal:** Allow CONTENT_CREATOR to save post drafts on mobile without internet connectivity and automatically sync them when connectivity is restored.

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

**Goal:** Enable CONTENT_CREATOR to attach media from their phone gallery or camera to posts directly from the mobile app.

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
- [ ] RBAC enforcement: BRAND_CLIENT calling ACCOUNT_MANAGER endpoints returns 403; CONTENT_CREATOR calling admin endpoints returns 403
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

- [ ] Test flow executes in order: create ContentRequest → AI generate → save draft → submit → ACCOUNT_MANAGER approve → client approve → verify post appears as PUBLISHED in DB
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
- [ ] CONTENT_CREATOR generates AI content → saves draft → submits for review
- [ ] ACCOUNT_MANAGER approves → sends to client
- [ ] BRAND_CLIENT logs in to portal → approves the post
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

- [ ] Manual covers all 6 roles: ADMIN, AGENCY_OWNER, ACCOUNT_MANAGER, CONTENT_CREATOR, BRAND_CLIENT, GUEST
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
- [ ] Scene 2 (~60s): AGENCY_OWNER — create workspace, invite members, connect social account
- [ ] Scene 3 (~45s): BRAND_CLIENT — submit content request
- [ ] Scene 4 (~90s): CONTENT_CREATOR — open request, trigger AI generate, edit caption, attach image, submit for review
- [ ] Scene 5 (~45s): ACCOUNT_MANAGER — review post, approve, send to client
- [ ] Scene 6 (~45s): BRAND_CLIENT — log into portal, view preview, approve post
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
- [ ] AGENCY_OWNER/ACCOUNT_MANAGER/CONTENT_CREATOR: navigate('/workspace', {replace:true})
- [ ] BRAND_CLIENT: navigate('/portal', {replace:true}). ADMIN: navigate('/admin', {replace:true})
- [ ] Fallback roles: dashboard with welcome + KPI placeholder + task checklist
- [ ] useAuthStore() + useNavigate() with replace:true

**Technical Notes:**

- DashboardPage.tsx dual purpose: landing (guest) + dashboard (authenticated). No separate /landing route.
- Redirect on mount — no flash of landing page for authenticated users.

**Dependencies:** Blocks: [None]. Blocked by: [DA-E35-01, DA-E35-05, DA-E35-02, DA-E49-01 through DA-E49-08].

---
