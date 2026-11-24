# Platform Architecture, AI Pipeline & Mobile Feature Modules (26 Consolidated Modules)

> **Navigation:** [← Feature Master Index](../README.md) · [SRS 141 FRs](../srs/README.md) · **Platform & Mobile Modules** · [BA Baseline](../../ba/README.md) · [Workflow Rule](../../rule/feature-workflow.md) · [Archived Report Drafts](../../archive/reports/README.md)

This directory organizes **26 authoritative, deeply consolidated cross-cutting, infrastructure, AI pipeline, observability, and mobile engineering modules** (`104` lifecycle files across **8 domain categories**), complementing the [141 Canonical SRS Functional Requirements](../srs/README.md). Duplicate PR-level micro-specs for atomic CRUD features have been absorbed directly into their canonical SRS FR folders, eliminating fragmented 3-line stubs while preserving 100% of production architectural decisions, schemas, and test matrices.

Every module strictly enforces:
- **4-File Sequential Lifecycle:** `spec.md → plan.md → task.md → test.md` per [Feature Workflow](../../rule/feature-workflow.md).
- **6 Canonical System Roles:** `Guest`, `Owner`, `Manager`, `Creator`, `Client`, and `Admin`.
- **Key-Parallel Localization & Theme Parity:** `vi.json` + `en.json` parity (`tr()` on Mobile) and semantic Light/Dark mode tokens (`dark:` variants on Web, `useAppPreferences().palette` on Mobile).

## 1. Category Overview (8 Categories · 26 Modules · 104 Lifecycle Files)

| Category Directory | Domain Focus | Modules | Index |
| :--- | :--- | :---: | :--- |
| [`01-identity-gateway/`](./01-identity-gateway/README.md) | **Identity, API Gateway & Edge Security** | **2** | [Open Category Index →](./01-identity-gateway/README.md) |
| [`02-agency-studio-plans/`](./02-agency-studio-plans/README.md) | **Agency, Personal Studio, Dashboards & Realtime Notifications** | **3** | [Open Category Index →](./02-agency-studio-plans/README.md) |
| [`03-campaign-package-delivery/`](./03-campaign-package-delivery/README.md) | **Media Package Sharing, Campaign Timeline & Delivery Closure** | **2** | [Open Category Index →](./03-campaign-package-delivery/README.md) |
| [`04-task-chat-vault/`](./04-task-chat-vault/README.md) | **Task Workflow, Realtime Workspace Chat & Encrypted S3 Vault** | **3** | [Open Category Index →](./04-task-chat-vault/README.md) |
| [`05-ai-rag-and-crawler/`](./05-ai-rag-and-crawler/README.md) | **AI Trend Crawler, Neo4j Knowledge Graph & Brand RAG** | **3** | [Open Category Index →](./05-ai-rag-and-crawler/README.md) |
| [`06-ai-media-and-video-studio/`](./06-ai-media-and-video-studio/README.md) | **AI Commercial Image, Product Video & Conversational Video Studio** | **3** | [Open Category Index →](./06-ai-media-and-video-studio/README.md) |
| [`07-billing-publisher-and-observability/`](./07-billing-publisher-and-observability/README.md) | **Billing Verification, Publisher Resilience & System Health Observability** | **3** | [Open Category Index →](./07-billing-publisher-and-observability/README.md) |
| [`08-mobile-application/`](./08-mobile-application/README.md) | **BrandHub Mobile Application (Expo SDK 58 / React Native 0.88)** | **7** | [Open Category Index →](./08-mobile-application/README.md) |
| **Total** | **All 8 Consolidated Module Categories** | **26** | **104 Lifecycle Docs** |

## 2. Complete Consolidated Module Directory

### 2.1 [01-identity-gateway — Identity, API Gateway & Edge Security](./01-identity-gateway/README.md) (2)

Cross-cutting API Gateway JWT verification, inbound header sanitization, Redis rate limiting, and universal user avatar/banner S3 delivery.

| Module Slug | Consolidated Engineering Scope | Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- |
| `gateway-jwt-and-rate-limiting` | API Gateway JWT Verification, Header Sanitization & Rate Limiting | [Spec](./01-identity-gateway/gateway-jwt-and-rate-limiting/spec.md) · [Plan](./01-identity-gateway/gateway-jwt-and-rate-limiting/plan.md) · [Task](./01-identity-gateway/gateway-jwt-and-rate-limiting/task.md) · [Test](./01-identity-gateway/gateway-jwt-and-rate-limiting/test.md) |
| `user-avatar-and-banner-presets` | Unified People Avatars, Banner Presets & S3 Image Upload Pipeline | [Spec](./01-identity-gateway/user-avatar-and-banner-presets/spec.md) · [Plan](./01-identity-gateway/user-avatar-and-banner-presets/plan.md) · [Task](./01-identity-gateway/user-avatar-and-banner-presets/task.md) · [Test](./01-identity-gateway/user-avatar-and-banner-presets/test.md) |
### 2.2 [02-agency-studio-plans — Agency, Personal Studio, Dashboards & Realtime Notifications](./02-agency-studio-plans/README.md) (3)

Dual-line subscription catalog (`STUDIO_FREE/PLUS/PRO` + `BASIC/PLUS/ENTERPRISE` + `/admin?view=plans`), 3-tier Role-Based Dashboards, Workspace UX & Duplicate Workspace, and PostgreSQL `LISTEN/NOTIFY` realtime notifications.

| Module Slug | Consolidated Engineering Scope | Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- |
| `studio-and-agency-plan-catalog` | Dual-Line Subscription Catalog (Personal Studio & Business Agency Plans) & Admin Plan Editor | [Spec](./02-agency-studio-plans/studio-and-agency-plan-catalog/spec.md) · [Plan](./02-agency-studio-plans/studio-and-agency-plan-catalog/plan.md) · [Task](./02-agency-studio-plans/studio-and-agency-plan-catalog/task.md) · [Test](./02-agency-studio-plans/studio-and-agency-plan-catalog/test.md) |
| `role-based-dashboards-and-ux` | Three-Tier Role-Based Dashboards, Workspace UX, Timezone Consistency & Duplicate Workspace | [Spec](./02-agency-studio-plans/role-based-dashboards-and-ux/spec.md) · [Plan](./02-agency-studio-plans/role-based-dashboards-and-ux/plan.md) · [Task](./02-agency-studio-plans/role-based-dashboards-and-ux/task.md) · [Test](./02-agency-studio-plans/role-based-dashboards-and-ux/test.md) |
| `realtime-notification-center` | Realtime In-App Notification Center (PostgreSQL LISTEN/NOTIFY + WebSocket/SSE) | [Spec](./02-agency-studio-plans/realtime-notification-center/spec.md) · [Plan](./02-agency-studio-plans/realtime-notification-center/plan.md) · [Task](./02-agency-studio-plans/realtime-notification-center/task.md) · [Test](./02-agency-studio-plans/realtime-notification-center/test.md) |
### 2.3 [03-campaign-package-delivery — Media Package Sharing, Campaign Timeline & Delivery Closure](./03-campaign-package-delivery/README.md) (2)

Manager-led Media Package offering models, token-gated `Guest` sharing, deterministic Task seeding, interactive Campaign Gantt timeline, partner cooperation tracking, and Campaign closure validation.

| Module Slug | Consolidated Engineering Scope | Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- |
| `manager-led-media-package-sharing` | Manager-Led Media Package Offering Models, Public Guest Share Token & Task Seeding | [Spec](./03-campaign-package-delivery/manager-led-media-package-sharing/spec.md) · [Plan](./03-campaign-package-delivery/manager-led-media-package-sharing/plan.md) · [Task](./03-campaign-package-delivery/manager-led-media-package-sharing/task.md) · [Test](./03-campaign-package-delivery/manager-led-media-package-sharing/test.md) |
| `campaign-timeline-and-closure` | Interactive Campaign Gantt Timeline, Partner Cooperation, Request Validation & Campaign Closure | [Spec](./03-campaign-package-delivery/campaign-timeline-and-closure/spec.md) · [Plan](./03-campaign-package-delivery/campaign-timeline-and-closure/plan.md) · [Task](./03-campaign-package-delivery/campaign-timeline-and-closure/task.md) · [Test](./03-campaign-package-delivery/campaign-timeline-and-closure/test.md) |
### 2.4 [04-task-chat-vault — Task Workflow, Realtime Workspace Chat & Encrypted S3 Vault](./04-task-chat-vault/README.md) (3)

Five-state inline Task workflow, role-scoped Subtasks & sectioned specialized editors, full Workspace realtime STOMP Chat + 1:1 Voice Calls, and KMS envelope-encrypted S3 Vault + Client Vault + Google Drive sync.

| Module Slug | Consolidated Engineering Scope | Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- |
| `task-subtask-and-inline-workflow` | Five-State Inline Task Editing, Role-Scoped Subtasks & Sectioned Specialized Editors | [Spec](./04-task-chat-vault/task-subtask-and-inline-workflow/spec.md) · [Plan](./04-task-chat-vault/task-subtask-and-inline-workflow/plan.md) · [Task](./04-task-chat-vault/task-subtask-and-inline-workflow/task.md) · [Test](./04-task-chat-vault/task-subtask-and-inline-workflow/test.md) |
| `workspace-chat-and-voice-calls` | Workspace Realtime Chat Channels, Threads, Mentions, Slash References, Scheduled Messages & 1:1 Voice Calls | [Spec](./04-task-chat-vault/workspace-chat-and-voice-calls/spec.md) · [Plan](./04-task-chat-vault/workspace-chat-and-voice-calls/plan.md) · [Task](./04-task-chat-vault/workspace-chat-and-voice-calls/task.md) · [Test](./04-task-chat-vault/workspace-chat-and-voice-calls/test.md) |
| `s3-folder-vault-security` | Encrypted S3 Material Repository, Storage Add-Ons, Client Folder Vault & Google Drive Sync | [Spec](./04-task-chat-vault/s3-folder-vault-security/spec.md) · [Plan](./04-task-chat-vault/s3-folder-vault-security/plan.md) · [Task](./04-task-chat-vault/s3-folder-vault-security/task.md) · [Test](./04-task-chat-vault/s3-folder-vault-security/test.md) |
### 2.5 [05-ai-rag-and-crawler — AI Trend Crawler, Neo4j Knowledge Graph & Brand RAG](./05-ai-rag-and-crawler/README.md) (3)

Multi-platform `T0 -> T7` trend crawler pipeline with S3 daily replay, Neo4j Trend Knowledge Graph & Brand-Fit matching, and ChromaDB/Neo4j grounded captions + Content Humanizer + Text Moderation.

| Module Slug | Consolidated Engineering Scope | Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- |
| `multiplatform-trend-crawler-pipeline` | Multi-Platform Trend Crawler Pipeline, Proxy Rotation, S3 Cold Storage & Daily Replay | [Spec](./05-ai-rag-and-crawler/multiplatform-trend-crawler-pipeline/spec.md) · [Plan](./05-ai-rag-and-crawler/multiplatform-trend-crawler-pipeline/plan.md) · [Task](./05-ai-rag-and-crawler/multiplatform-trend-crawler-pipeline/task.md) · [Test](./05-ai-rag-and-crawler/multiplatform-trend-crawler-pipeline/test.md) |
| `neo4j-trend-knowledge-graph` | Neo4j Trend Knowledge Graph Core, Workspace Trend Explorer & Brand-Fit Matching | [Spec](./05-ai-rag-and-crawler/neo4j-trend-knowledge-graph/spec.md) · [Plan](./05-ai-rag-and-crawler/neo4j-trend-knowledge-graph/plan.md) · [Task](./05-ai-rag-and-crawler/neo4j-trend-knowledge-graph/task.md) · [Test](./05-ai-rag-and-crawler/neo4j-trend-knowledge-graph/test.md) |
| `rag-caption-moderation-and-humanizer` | Brand-Grounded RAG Captions, Editor AI Popover, Content Humanizer & Text Safety Moderation | [Spec](./05-ai-rag-and-crawler/rag-caption-moderation-and-humanizer/spec.md) · [Plan](./05-ai-rag-and-crawler/rag-caption-moderation-and-humanizer/plan.md) · [Task](./05-ai-rag-and-crawler/rag-caption-moderation-and-humanizer/task.md) · [Test](./05-ai-rag-and-crawler/rag-caption-moderation-and-humanizer/test.md) |
### 2.6 [06-ai-media-and-video-studio — AI Commercial Image, Product Video & Conversational Video Studio](./06-ai-media-and-video-studio/README.md) (3)

Commercial advertising image presets + Qwen Image 2.1 ComfyUI Virtual Ambassador worker, multi-scene Wan 2.2 VACE / LTX Product Video pipeline + CapCut export, and Video Space + containerized Claude FFmpeg worker.

| Module Slug | Consolidated Engineering Scope | Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- |
| `commercial-image-and-qwen-ambassador` | Commercial Advertising Image Presets & Qwen Image 2.1 ComfyUI Virtual Ambassador Pipeline | [Spec](./06-ai-media-and-video-studio/commercial-image-and-qwen-ambassador/spec.md) · [Plan](./06-ai-media-and-video-studio/commercial-image-and-qwen-ambassador/plan.md) · [Task](./06-ai-media-and-video-studio/commercial-image-and-qwen-ambassador/task.md) · [Test](./06-ai-media-and-video-studio/commercial-image-and-qwen-ambassador/test.md) |
| `wan-vace-product-video-pipeline` | Multi-Scene Product Video Production Pipeline (LTX Director, Wan 2.2 VACE / I2V Workers & CapCut Export) | [Spec](./06-ai-media-and-video-studio/wan-vace-product-video-pipeline/spec.md) · [Plan](./06-ai-media-and-video-studio/wan-vace-product-video-pipeline/plan.md) · [Task](./06-ai-media-and-video-studio/wan-vace-product-video-pipeline/task.md) · [Test](./06-ai-media-and-video-studio/wan-vace-product-video-pipeline/test.md) |
| `video-space-and-claude-edit-worker` | Video Space Nonlinear Editor, Conversational Auto-Edit Agent & Containerized Claude FFmpeg Worker | [Spec](./06-ai-media-and-video-studio/video-space-and-claude-edit-worker/spec.md) · [Plan](./06-ai-media-and-video-studio/video-space-and-claude-edit-worker/plan.md) · [Task](./06-ai-media-and-video-studio/video-space-and-claude-edit-worker/task.md) · [Test](./06-ai-media-and-video-studio/video-space-and-claude-edit-worker/test.md) |
### 2.7 [07-billing-publisher-and-observability — Billing Verification, Publisher Resilience & System Health Observability](./07-billing-publisher-and-observability/README.md) (3)

Java SePay ACID/load runner & subscription production observability, RabbitMQ `PublishJobMessage` compatibility & media stream disconnect handling, and System Health MongoDB persistence.

| Module Slug | Consolidated Engineering Scope | Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- |
| `payment-java-runner` | SePay Payment ACID Verification Suite, Java Benchmark Runner & Subscription Production Observability | [Spec](./07-billing-publisher-and-observability/payment-java-runner/spec.md) · [Plan](./07-billing-publisher-and-observability/payment-java-runner/plan.md) · [Task](./07-billing-publisher-and-observability/payment-java-runner/task.md) · [Test](./07-billing-publisher-and-observability/payment-java-runner/test.md) |
| `social-publisher-resilience` | RabbitMQ Publisher Message Type Compatibility & Graceful Media Stream Disconnect Handling | [Spec](./07-billing-publisher-and-observability/social-publisher-resilience/spec.md) · [Plan](./07-billing-publisher-and-observability/social-publisher-resilience/plan.md) · [Task](./07-billing-publisher-and-observability/social-publisher-resilience/task.md) · [Test](./07-billing-publisher-and-observability/social-publisher-resilience/test.md) |
| `system-health-mongodb-refactor` | System Health MongoDB Persistence Refactor & BOM-Safe Monitoring Catalog Startup | [Spec](./07-billing-publisher-and-observability/system-health-mongodb-refactor/spec.md) · [Plan](./07-billing-publisher-and-observability/system-health-mongodb-refactor/plan.md) · [Task](./07-billing-publisher-and-observability/system-health-mongodb-refactor/task.md) · [Test](./07-billing-publisher-and-observability/system-health-mongodb-refactor/test.md) |
### 2.8 [08-mobile-application — BrandHub Mobile Application (Expo SDK 58 / React Native 0.88)](./08-mobile-application/README.md) (7)

Complete 7-domain engineering specification for `brandhub-mobile-app` (Auth & AppLock, Pro VisionCamera & Offline S3 Sync, Role Nav & 3-Tier Dashboards, Package/Campaign/Requests, Task/Approval/Reminders/Chat, AI Hub, and SePay Subscription/Credits).

| Module Slug | Consolidated Engineering Scope | Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- |
| `mobile-auth` | Mobile Authentication, Deep-Link Google OAuth, 2FA Verify & Biometric App Lock | [Spec](./08-mobile-application/mobile-auth/spec.md) · [Plan](./08-mobile-application/mobile-auth/plan.md) · [Task](./08-mobile-application/mobile-auth/task.md) · [Test](./08-mobile-application/mobile-auth/test.md) |
| `mobile-creator-upload` | Mobile Pro VisionCamera Capture, Offline-Resilient S3 Multipart Sync & Task Take Promotion | [Spec](./08-mobile-application/mobile-creator-upload/spec.md) · [Plan](./08-mobile-application/mobile-creator-upload/plan.md) · [Task](./08-mobile-application/mobile-creator-upload/task.md) · [Test](./08-mobile-application/mobile-creator-upload/test.md) |
| `mobile-agency-workspace` | Mobile Role-Based Navigation Parity, Three-Tier Dashboards & Agency/Workspace Directory | [Spec](./08-mobile-application/mobile-agency-workspace/spec.md) · [Plan](./08-mobile-application/mobile-agency-workspace/plan.md) · [Task](./08-mobile-application/mobile-agency-workspace/task.md) · [Test](./08-mobile-application/mobile-agency-workspace/test.md) |
| `mobile-package-campaign` | Mobile Media Package Review, Campaign Tracking & Client Content Request Workflows | [Spec](./08-mobile-application/mobile-package-campaign/spec.md) · [Plan](./08-mobile-application/mobile-package-campaign/plan.md) · [Task](./08-mobile-application/mobile-package-campaign/task.md) · [Test](./08-mobile-application/mobile-package-campaign/test.md) |
| `mobile-task-workflow` | Mobile Task List/Kanban/Calendar, Rich Content Editor, 3-Tier Approvals, Local Reminders & Chat | [Spec](./08-mobile-application/mobile-task-workflow/spec.md) · [Plan](./08-mobile-application/mobile-task-workflow/plan.md) · [Task](./08-mobile-application/mobile-task-workflow/task.md) · [Test](./08-mobile-application/mobile-task-workflow/test.md) |
| `mobile-ai-features` | Mobile AI Hub: Grounded Captions, Hashtag Suggestions, Ambassadors, Ad Images, Video & Quick Reel Studio | [Spec](./08-mobile-application/mobile-ai-features/spec.md) · [Plan](./08-mobile-application/mobile-ai-features/plan.md) · [Task](./08-mobile-application/mobile-ai-features/task.md) · [Test](./08-mobile-application/mobile-ai-features/test.md) |
| `mobile-subscription-billing` | Mobile Studio & Agency Subscription Plans, SePay VietQR Checkout, AI Credit Caps & Invoice History | [Spec](./08-mobile-application/mobile-subscription-billing/spec.md) · [Plan](./08-mobile-application/mobile-subscription-billing/plan.md) · [Task](./08-mobile-application/mobile-subscription-billing/task.md) · [Test](./08-mobile-application/mobile-subscription-billing/test.md) |
