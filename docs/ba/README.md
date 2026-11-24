# Business Analysis & Functional Baseline (`docs/ba/`)

> Navigation: [← Knowledge Base Hub](../index.md) · [← Database Architecture](../database/README.md) · [Use Cases (`UC-001`–`UC-141`)](./use-cases/README.md) · [Feature Specifications (`srs/` & `modules/`) →](../feature/README.md)

This directory is the **Single Source of Truth** for BrandHub's business domain model, organizational hierarchy, **6 Canonical System Roles** (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`), **141 Atomic Functional Requirements (`3.2.1`–`3.10.14`)**, and **141 Use Cases (`UC-001`–`UC-141`)**, synchronized 1-to-1 with `Các FR của hệ thống  - Feature_Function Requirement.csv` and `brandhub-final_report/report3/report3_official.docx`.

---

## 1. Product Vision, Two Product Lines & Hybrid Operating Modes

**BrandHub** is an AI-powered multi-channel media campaign and content operations platform operating on a **Hybrid Multi-Tenant Architecture** across **2 product lines (6 subscription plans)**:

| Workspace Mode (`workspaceMode`) | Canonical Plan Line | Target Audience | Core Operational Workflow |
| :--- | :--- | :--- | :--- |
| **`AGENCY` (B2B Media Agency Suite)** | `BASIC`, `PLUS`, `ENTERPRISE` | Marketing/PR agencies managing multiple external brand clients (`Client`) with specialized creative & account teams. | Structured 3-stage commercial governance: **`1. Media Package → 2. Media Campaign → 3. Multi-Role Task & Section Execution`**, dedicated `Client Portal`, `Content Request` intake, and strict 3-tier approval (`Creator -> Manager -> Client`). |
| **`PERSONAL` (AI Studio for Solo & Small Teams)** | `STUDIO_FREE`, `STUDIO_PLUS`, `STUDIO_PRO` | Independent creators, freelancers, Marketing/Communications student project teams, and solo brand owners. | One-click **Personal Studio Bootstrap** (backed by a hidden `Personal Hub Agency`). **Bypasses `Media Package` negotiation and requires no `Client`**: supports free-form personal campaigns or standalone tasks across all 8 `TaskType`s, 1-click **`Self-Approve`**, teammate `Creator` invitations, and lossless scale-up to `AGENCY` mode at any time. |

---

## 2. Six Canonical System Roles (Mandatory Naming Standard)

Across all code, API contracts, database seeders, UML diagrams, and SRS/SDD reports, BrandHub strictly enforces **exact 6 short role names**:

| Canonical Role | Enum Constant | Scope | Core Responsibilities |
| :--- | :---: | :--- | :--- |
| **`Guest`** | `GUEST` | Public (Unauthenticated) | Browse landing pages, register (`3.2.1`), sign in (`3.2.2`, `3.2.3`), reset password (`3.2.4`), verify OTP (`3.2.6`), submit public surveys, and view public `ShareLink` deliverables (`/s/:token`). |
| **`Owner`** | `OWNER` | `Agency` (incl. `Personal Hub`) | Owns an `Agency` (`agencies.owner_id`). Governs agency profile, members, workspace templates, **SePay (VietQR)** plan upgrades (`3.9.1`–`3.9.2`), `agency_credit_wallets`, per-workspace AI credit caps (`3.9.6 Set Credit`), workspaces, and template `MediaPackage`s. |
| **`Manager`** | `MANAGER` | `Workspace` | Leads day-to-day execution of a `Workspace` (every active Workspace has ≥1 `Manager`): negotiates/approves packages & campaigns, manages workspace members, defines & assigns tasks/subtasks, performs intermediate review (`Creator -> Manager -> Client`) or 1-click `Self-Approve` in `PERSONAL` mode, connects social channels, and coordinates mail/library assets. |
| **`Creator`** | `CREATOR` | `Workspace` | Executes creative production across **8 `TaskType`s** and role-scoped `TaskSection`s, writes Unicode-styled copy, applies watermarks & hashtags, uses AI Studio (Caption, Image, Video, Virtual Ambassador), runs safety compliance checks (`3.6.33`), and schedules/publishes approved posts. |
| **`Client`** | `CLIENT` | `Workspace` (`AGENCY` mode) | External brand representative backed by a reusable cross-agency `ClientProfile`: negotiates/approves `WorkspaceMediaPackage`s & `MediaCampaign`s, submits `Content Request`s, uploads Brand Guideline RAG documents, connects official brand social accounts, and executes final `Client` approval. |
| **`Admin`** | `ADMIN` | Platform-wide (`SystemRole`) | Broadcasts system notifications, monitors platform KPIs & 5-host microservice health (`3.10.3`), adjudicates the `Content Moderation Queue` (`3.10.4`), manages user accounts & violation strikes, configures AI trend crawler schedules (`3.7.13`), governs AI Credit pricing (`3.10.10`–`3.10.12`), tracks SePay revenue, and exports PDF reports. |

---

## 3. Master Domain Map — 141 Atomic FRs & 141 Use Cases

| # | SRS Sec. | Functional Domain | FR Range | FRs | UC Range | BA Specification | Use Cases | SRS Feature Folder |
| :-: | :-: | :--- | :-: | :-: | :-: | :--- | :--- | :--- |
| — | — | **Organization Structure & Hybrid Tenancy** | — | — | — | [01-organization-structure.md](./01-organization-structure.md) | — | — |
| 1 | `3.2` | **Authentication & Authorization** | `3.2.1`–`3.2.9` | **9** | `UC-001`–`UC-009` | [02-authentication-profile.md](./02-authentication-profile.md) | [01-authentication-profile.md](./use-cases/01-authentication-profile.md) | [01-authentication](../feature/srs/01-authentication/README.md) |
| 2 | `3.3` | **User & Client Profile** | `3.3.1`–`3.3.4` | **4** | `UC-010`–`UC-013` | [02-authentication-profile.md](./02-authentication-profile.md) | [01-authentication-profile.md](./use-cases/01-authentication-profile.md) | [02-profile](../feature/srs/02-profile/README.md) |
| 3 | `3.4` | **Agency & Workspace** | `3.4.1`–`3.4.26` | **26** | `UC-014`–`UC-039` | [03-agency-workspace.md](./03-agency-workspace.md) | [02-agency-workspace.md](./use-cases/02-agency-workspace.md) | [03-agency-workspace](../feature/srs/03-agency-workspace/README.md) |
| 4 | `3.5` | **Media Package & Media Campaign** | `3.5.1`–`3.5.13` | **13** | `UC-040`–`UC-052` | [04-media-package-campaign.md](./04-media-package-campaign.md) | [03-media-package-campaign.md](./use-cases/03-media-package-campaign.md) | [04-media-package-campaign](../feature/srs/04-media-package-campaign/README.md) |
| 5 | `3.6` | **Content & Workflow** | `3.6.1`–`3.6.35` | **35** | `UC-053`–`UC-087` | [05-content-task-workflow.md](./05-content-task-workflow.md) | [04-content-task-workflow.md](./use-cases/04-content-task-workflow.md) | [05-content-task-workflow](../feature/srs/05-content-task-workflow/README.md) |
| 6 | `3.7` | **AI Features** | `3.7.1`–`3.7.19` | **19** | `UC-088`–`UC-106` | [06-ai-features.md](./06-ai-features.md) | [05-ai-features.md](./use-cases/05-ai-features.md) | [06-ai-features](../feature/srs/06-ai-features/README.md) |
| 7 | `3.8` | **Publishing & Social** | `3.8.1`–`3.8.15` | **15** | `UC-107`–`UC-121` | [07-publishing-social.md](./07-publishing-social.md) | [06-publishing-social.md](./use-cases/06-publishing-social.md) | [07-publishing-social](../feature/srs/07-publishing-social/README.md) |
| 8 | `3.9` | **Subscription & Billing** | `3.9.1`–`3.9.6` | **6** | `UC-122`–`UC-127` | [08-subscription-billing.md](./08-subscription-billing.md) | [07-subscription.md](./use-cases/07-subscription.md) | [08-subscription-billing](../feature/srs/08-subscription-billing/README.md) |
| 9 | `3.10` | **Admin Functions** | `3.10.1`–`3.10.14` | **14** | `UC-128`–`UC-141` | [09-admin-functions.md](./09-admin-functions.md) | [08-admin-functions.md](./use-cases/08-admin-functions.md) | [09-admin-functions](../feature/srs/09-admin-functions/README.md) |
| **Total** | | **9 Canonical Domains** | **`3.2.1`–`3.10.14`** | **141** | **`UC-001`–`UC-141`** | | [Use Case Hub](./use-cases/README.md) | [Feature Hub](../feature/README.md) |

### Cross-Cutting BA Reference Specifications
- [10-roles-permissions-matrix.md](./10-roles-permissions-matrix.md) — Complete `6-Role × 141-FR` authorization matrix + `SectionPolicy` subtask matrix.
- [11-data-entities-glossary.md](./11-data-entities-glossary.md) — Domain entity dictionary across PostgreSQL (`97` tables), MongoDB (`52` collections), ChromaDB, Neo4j, and Redis.
- [12-state-machines.md](./12-state-machines.md) — Formal lifecycle state machines for Workspaces, Packages, Campaigns, Content Requests, Tasks, `TaskSection`s, Social Posts, Mail Batches, SePay Invoices, Credit Reservations, and Moderation.
- Financial & unit-economics workbook in this folder: `docs/ba/brandhub-pricing-model.xlsx` (models `STUDIO_FREE/PLUS/PRO` + `BASIC/PLUS/ENTERPRISE` pricing & AI Credit margins).

---

## 4. Eight Canonical Task Types (`TaskType`) & Multi-Section Editor (`TaskSection`)

Every work item in BrandHub belongs to **1 of 8 canonical `TaskType`s**, decomposed into role-specific `TaskSection` blocks (Internal `I` vs. Client-facing Output `O`):
1. **`POST`** — Social media post (`POST.BRIEF`, `POST.CAPTION`, `POST.MEDIA`, `POST.CHANNELS`).
2. **`SHORT_VIDEO`** — Vertical short-form video for TikTok / Reels (`VIDEO.SCRIPT`, `VIDEO.SHOOT`, `VIDEO.EDIT`, `VIDEO.CAPTION`, `VIDEO.CHANNELS`).
3. **`SURVEY`** — Public interactive survey (`SURVEY.FORM`, `SURVEY.DISTRIBUTION`, `SURVEY.REPORT`).
4. **`EVENT_PLAN`** — Offline/hybrid event plan (`EVENT.AGENDA`, `EVENT.LOGISTICS`, `EVENT.PROMOTION`, `EVENT.RUNSHEET`, `EVENT.REPORT`).
5. **`PRESS_RECOMMENDATION`** — PR media list & press release (`PRESS.MEDIA_LIST`, `PRESS.RELEASE`, `PRESS.CONTACT_LOG`, `PRESS.COVERAGE`).
6. **`KOL_BOOKING`** — Influencer / KOL collaboration (`KOL.SHORTLIST`, `KOL.DEAL`, `KOL.BRIEF`, `KOL.DRAFT`, `KOL.REPORT`).
7. **`WORKSHOP`** — Workshop / seminar program (`WORKSHOP.PROGRAM`, `WORKSHOP.SPEAKERS`, `WORKSHOP.LOGISTICS`, `WORKSHOP.REGISTRATION`, `WORKSHOP.REPORT`).
8. **`EMAIL_NEWSLETTER`** — Real SMTP newsletter batch (`EMAIL.CONTENT`, `EMAIL.DESIGN`, `EMAIL.AUDIENCE`, `EMAIL.REPORT`).

---

## 5. Non-Negotiable Scope Guardrails & De-Scoped Features

1. **No Livestream Features**: No `LIVESTREAM` task type, livestream scripts, or AI livestream assistants.
2. **No Plan Downgrade Flow**: Upgrade-only subscription lifecycle (`3.9.1 Upgrade Plan`).
3. **No Plagiarism / Copyright Check FR**: Retain only community safety compliance (`3.6.33 Check Compliance Content`) and Admin moderation (`3.10.4 Content Moderation Queue`).
4. **Strictly 4 Social Publishing Platforms**: **Facebook, Instagram, TikTok, and Threads** (no Zalo OA, no YouTube).
5. **Strictly SePay (VietQR) Payment Gateway**: No PayOS, VNPay, or Stripe.
6. **Zero `"Manage"` Rule**: Every FR and Use Case title uses an atomic verb (`View`, `Create`, `Update`, `Delete/Remove`, `Approve`, `Publish`, etc.)—never `"Manage ..."` or `"... Management"`.
