# Official SRS Functional Requirements (141 Atomic CRUD FRs)

> **Navigation:** [← Feature Master Index](../README.md) · **SRS 141 FRs** · [Platform & Mobile Modules (26)](../modules/README.md) · [BA Baseline](../../ba/README.md) · [Workflow Rule](../../rule/feature-workflow.md) · [Archived Report Drafts](../../archive/reports/README.md)

This directory contains the 1-to-1 engineering specification, technical implementation plan, sequential task breakdown, and verification test suite (`spec.md → plan.md → task.md → test.md`) for all **141 canonical Functional Requirements (`3.2.1` to `3.10.14`)** and **141 Use Cases (`UC-001` to `UC-141`)** of the BrandHub platform.

## 1. Domain Summary (9 Domains · 141 FRs)

| Section | Functional Domain | FR Range | FR Count | Business Analysis Reference |
| :--- | :--- | :--- | :---: | :--- |
| `3.2` | [**Authentication & Authorization**](./01-authentication/README.md) | `3.2.1 – 3.2.9` | **9** | [BA Spec](../../ba/02-authentication-profile.md) |
| `3.3` | [**User & Client Profile**](./02-profile/README.md) | `3.3.1 – 3.3.4` | **4** | [BA Spec](../../ba/02-authentication-profile.md) |
| `3.4` | [**Agency & Workspace**](./03-agency-workspace/README.md) | `3.4.1 – 3.4.26` | **26** | [BA Spec](../../ba/03-agency-workspace.md) |
| `3.5` | [**Media Package & Media Campaign**](./04-media-package-campaign/README.md) | `3.5.1 – 3.5.13` | **13** | [BA Spec](../../ba/04-media-package-campaign.md) |
| `3.6` | [**Content & Workflow**](./05-content-task-workflow/README.md) | `3.6.1 – 3.6.35` | **35** | [BA Spec](../../ba/05-content-task-workflow.md) |
| `3.7` | [**AI Features**](./06-ai-features/README.md) | `3.7.1 – 3.7.19` | **19** | [BA Spec](../../ba/06-ai-features.md) |
| `3.8` | [**Publishing & Social**](./07-publishing-social/README.md) | `3.8.1 – 3.8.15` | **15** | [BA Spec](../../ba/07-publishing-social.md) |
| `3.9` | [**Subscription & Billing**](./08-subscription-billing/README.md) | `3.9.1 – 3.9.6` | **6** | [BA Spec](../../ba/08-subscription-billing.md) |
| `3.10` | [**Admin Functions**](./09-admin-functions/README.md) | `3.10.1 – 3.10.14` | **14** | [BA Spec](../../ba/09-admin-functions.md) |
| **Total** | **9 Functional Domains** | **`3.2.1 – 3.10.14`** | **141** | [`ba/README.md`](../../ba/README.md) |

## 2. Mandatory Governance & Canonical Standards

- **6 Canonical System Roles:** Every specification strictly uses `Guest`, `Owner`, `Manager`, `Creator`, `Client`, and `Admin` (see [Roles & Permissions Matrix](../../ba/10-roles-permissions-matrix.md)).
- **Zero-"Manage" Atomic Action Rule:** Every FR and Use Case represents a single, verifiable atomic action (`View`, `Create`, `Update`, `Delete/Remove`, `Approve`, `Publish`, etc.) without umbrella `"Manage ..."` titles.
- **4-Document Sequential Workflow:** Every FR folder maintains `spec.md`, `plan.md`, `task.md`, and `test.md` per [Feature Workflow](../../rule/feature-workflow.md), enforcing key-parallel `vi.json` / `en.json` i18n keys and Light/Dark theme compliance.
- **Scope Baseline:** Strictly aligned with the **4 supported social platforms** (**Facebook, Instagram, TikTok, Threads**) and **SePay (VietQR)** payment gateway (with no subscription downgrade flow, no livestream tasks, and no plagiarism scanning).

---

## 3. Codebase & API Cross-References

- **Backend REST & WebSocket Contracts:** [business-service-endpoints.md](../../api/business-service-endpoints.md) (`brandhub-business-service` + `brandhub-publisher-service`) and [openapi-spec-ai-service.md](../../api/openapi-spec-ai-service.md) (`brandhub-ai-service`).
- **Polyglot Persistence & Schema Baseline:** [database/README.md](../../database/README.md) (`97` PostgreSQL 17 tables, `52` MongoDB 7.0 collections, Redis 7.2 key patterns, ChromaDB 1.5.9, and Neo4j 5.26).
- **UI Screenshots & Wireframe Mapping:** [screenshots/README.md](../../screenshots/README.md) (`Figure 1`–`Figure 150` SRS screen traceability) and [wireframe/README.md](../../wireframe/README.md).
