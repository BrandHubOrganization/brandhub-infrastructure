# BrandHub Feature Specifications Master Index

> **Navigation:** **Feature Master Index** · [SRS 141 FRs](./srs/README.md) · [Platform & Mobile Modules (27)](./modules/README.md) · [Workflow Rule](../rule/feature-workflow.md) · [BA Baseline](../ba/README.md) · [Archived Report Drafts](../archive/reports/README.md)

Single source of truth for all feature specifications, technical implementation plans, sequential task checklists, and verification test suites across the BrandHub polyrepo (`brandhub-api-gateway`, `brandhub-business-service`, `brandhub-ai-service`, `brandhub-publisher-service`, `brandhub-web`, `brandhub-mobile-app`).

## Directory Architecture

```text
docs/feature/
├── README.md          # Master Index (this document)
├── srs/               # 9 SRS Functional Domains · 141 Canonical Atomic CRUD FRs (UC-001..UC-141)
└── modules/           # 8 Domain Categories · 27 Authoritative Platform, AI Pipeline & Mobile Feature Modules
```

Every feature folder in both [`srs/`](./srs/README.md) and [`modules/`](./modules/README.md) contains the **4 mandatory lifecycle documents** defined in [`feature-workflow.md`](../rule/feature-workflow.md):
1. **`spec.md`** — Business specification, canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`), acceptance criteria, key-parallel i18n (`vi.json`/`en.json`) & Light/Dark mode rules, API contract, and edge cases.
2. **`plan.md`** — Technical architecture, touched services/files, schema updates, data flow, build order, and risks.
3. **`task.md`** — Sequential, verifiable implementation checklist mapped to `plan.md`.
4. **`test.md`** — Unit, boundary, concurrency, security, i18n, and Light/Dark theme verification matrix.

---

## 1. Official SRS Functional Domains ([`srs/`](./srs/README.md) — 141 FRs)

| Section | Domain Folder | FR Range | FR Count | BA Reference |
| :--- | :--- | :--- | :---: | :--- |
| `3.2` | [**Authentication & Authorization**](./srs/01-authentication/README.md) | `3.2.1 – 3.2.9` | **9** | [BA Spec](../ba/02-authentication-profile.md) |
| `3.3` | [**User & Client Profile**](./srs/02-profile/README.md) | `3.3.1 – 3.3.4` | **4** | [BA Spec](../ba/02-authentication-profile.md) |
| `3.4` | [**Agency & Workspace**](./srs/03-agency-workspace/README.md) | `3.4.1 – 3.4.26` | **26** | [BA Spec](../ba/03-agency-workspace.md) |
| `3.5` | [**Media Package & Media Campaign**](./srs/04-media-package-campaign/README.md) | `3.5.1 – 3.5.13` | **13** | [BA Spec](../ba/04-media-package-campaign.md) |
| `3.6` | [**Content & Workflow**](./srs/05-content-task-workflow/README.md) | `3.6.1 – 3.6.35` | **35** | [BA Spec](../ba/05-content-task-workflow.md) |
| `3.7` | [**AI Features**](./srs/06-ai-features/README.md) | `3.7.1 – 3.7.19` | **19** | [BA Spec](../ba/06-ai-features.md) |
| `3.8` | [**Publishing & Social**](./srs/07-publishing-social/README.md) | `3.8.1 – 3.8.15` | **15** | [BA Spec](../ba/07-publishing-social.md) |
| `3.9` | [**Subscription & Billing**](./srs/08-subscription-billing/README.md) | `3.9.1 – 3.9.6` | **6** | [BA Spec](../ba/08-subscription-billing.md) |
| `3.10` | [**Admin Functions**](./srs/09-admin-functions/README.md) | `3.10.1 – 3.10.14` | **14** | [BA Spec](../ba/09-admin-functions.md) |
| **Total** | [**All 9 SRS Domains**](./srs/README.md) | **`3.2.1 – 3.10.14`** | **141** | [`ba/README.md`](../ba/README.md) |

---

## 2. Consolidated Platform, AI Pipeline & Mobile Modules ([`modules/`](./modules/README.md) — 27 Modules across 8 Categories)

| Category Directory | Count | Consolidated Modules |
| :--- | :---: | :--- |
| [**Identity, API Gateway & Edge Security** (`01-identity-gateway/`)](./modules/01-identity-gateway/README.md) | **2** | [`gateway-jwt-and-rate-limiting`](./modules/01-identity-gateway/gateway-jwt-and-rate-limiting/spec.md), [`user-avatar-and-banner-presets`](./modules/01-identity-gateway/user-avatar-and-banner-presets/spec.md) |
| [**Agency, Personal Studio, Dashboards & Realtime Notifications** (`02-agency-studio-plans/`)](./modules/02-agency-studio-plans/README.md) | **3** | [`studio-and-agency-plan-catalog`](./modules/02-agency-studio-plans/studio-and-agency-plan-catalog/spec.md), [`role-based-dashboards-and-ux`](./modules/02-agency-studio-plans/role-based-dashboards-and-ux/spec.md), [`realtime-notification-center`](./modules/02-agency-studio-plans/realtime-notification-center/spec.md) |
| [**Media Package Sharing, Campaign Timeline & Closure** (`03-campaign-package-delivery/`)](./modules/03-campaign-package-delivery/README.md) | **2** | [`manager-led-media-package-sharing`](./modules/03-campaign-package-delivery/manager-led-media-package-sharing/spec.md), [`campaign-timeline-and-closure`](./modules/03-campaign-package-delivery/campaign-timeline-and-closure/spec.md) |
| [**Task Workflow, Realtime Chat, Reference Hub & Encrypted S3 Vault** (`04-task-chat-vault/`)](./modules/04-task-chat-vault/README.md) | **4** | [`task-subtask-and-inline-workflow`](./modules/04-task-chat-vault/task-subtask-and-inline-workflow/spec.md), [`reference-hub-and-algorithmic-curation`](./modules/04-task-chat-vault/reference-hub-and-algorithmic-curation/spec.md), [`workspace-chat-and-voice-calls`](./modules/04-task-chat-vault/workspace-chat-and-voice-calls/spec.md), [`s3-folder-vault-security`](./modules/04-task-chat-vault/s3-folder-vault-security/spec.md) |
| [**AI Trend Crawler, Neo4j Knowledge Graph & Brand RAG** (`05-ai-rag-and-crawler/`)](./modules/05-ai-rag-and-crawler/README.md) | **3** | [`multiplatform-trend-crawler-pipeline`](./modules/05-ai-rag-and-crawler/multiplatform-trend-crawler-pipeline/spec.md), [`neo4j-trend-knowledge-graph`](./modules/05-ai-rag-and-crawler/neo4j-trend-knowledge-graph/spec.md), [`rag-caption-moderation-and-humanizer`](./modules/05-ai-rag-and-crawler/rag-caption-moderation-and-humanizer/spec.md) |
| [**AI Commercial Image, Product Video & Video Space** (`06-ai-media-and-video-studio/`)](./modules/06-ai-media-and-video-studio/README.md) | **3** | [`commercial-image-and-qwen-ambassador`](./modules/06-ai-media-and-video-studio/commercial-image-and-qwen-ambassador/spec.md), [`wan-vace-product-video-pipeline`](./modules/06-ai-media-and-video-studio/wan-vace-product-video-pipeline/spec.md), [`video-space-and-claude-edit-worker`](./modules/06-ai-media-and-video-studio/video-space-and-claude-edit-worker/spec.md) |
| [**Billing Verification, Publisher Resilience & System Health** (`07-billing-publisher-and-observability/`)](./modules/07-billing-publisher-and-observability/README.md) | **3** | [`payment-java-runner`](./modules/07-billing-publisher-and-observability/payment-java-runner/spec.md), [`social-publisher-resilience`](./modules/07-billing-publisher-and-observability/social-publisher-resilience/spec.md), [`system-health-mongodb-refactor`](./modules/07-billing-publisher-and-observability/system-health-mongodb-refactor/spec.md) |
| [**BrandHub Mobile Application** (`08-mobile-application/`)](./modules/08-mobile-application/README.md) | **7** | [`mobile-auth`](./modules/08-mobile-application/mobile-auth/spec.md), [`mobile-creator-upload`](./modules/08-mobile-application/mobile-creator-upload/spec.md), [`mobile-agency-workspace`](./modules/08-mobile-application/mobile-agency-workspace/spec.md), [`mobile-package-campaign`](./modules/08-mobile-application/mobile-package-campaign/spec.md), [`mobile-task-workflow`](./modules/08-mobile-application/mobile-task-workflow/spec.md), [`mobile-ai-features`](./modules/08-mobile-application/mobile-ai-features/spec.md), [`mobile-subscription-billing`](./modules/08-mobile-application/mobile-subscription-billing/spec.md) |
| **Total** | **27** | [**Browse Complete Module Index →**](./modules/README.md) |

---

## 3. Historical Academic Report Drafts & Engineering Scratch Notes

Early-stage Report 3 (SRS) prose snippets, UI screenshots, Report 4 (SDD) PlantUML/Draw.io sequence & class diagrams, and superseded engineering prototypes are archived under [`docs/archive/reports/`](../archive/reports/README.md). Final academic deliverables reside in `brandhub-final_report`.
