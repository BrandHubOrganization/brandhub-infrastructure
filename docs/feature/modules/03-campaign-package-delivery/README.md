# 03-campaign-package-delivery — Media Package Sharing, Campaign Timeline & Delivery Closure (2 Modules)

> **Navigation:** [← Feature Master Index](../../README.md) · [← Modules Master Index](../README.md) · [SRS 3.5 Package & Campaign](../../srs/04-media-package-campaign/README.md) · [BA Domain Spec](../../../ba/04-media-package-campaign.md) · [Workflow Rule](../../../rule/feature-workflow.md)

End-to-end commercial contract and campaign execution extensions bridging `Manager`-authored Media Packages, token-gated `Guest` / `Client` proposal sharing, deterministic Task generation, interactive Gantt scheduling, collaborator tracking, and guarded Campaign closure.

---

## 1. Production Codebase & Persistence Mapping

- **Primary Services:** `brandhub-business-service` (`MediaPackageController`, `MediaPackageShareController`, `WorkspacePackagePlanningController`, `WorkspaceCampaignController`, `CampaignTimelineController`, `CampaignCollaboratorController`, `CampaignClosureController`, `ContentRequestReviewController`) and `brandhub-web`.
- **Storage & Runtime State:**
  - **PostgreSQL 17:** `media_packages`, `workspace_media_packages`, `package_share_links`, `media_campaigns`, `campaign_work_items`, `campaign_collaborators`.
  - **MongoDB 7.0:** `package_negotiation_histories`, `content_requests`, and idempotent `tasks` (`TaskDocument`) seeded upon campaign deployment or content request acceptance.
- **Related Canonical SRS Domains:** [04-media-package-campaign (`3.5.1`–`3.5.13`)](../../srs/04-media-package-campaign/README.md) · [05-content-task-workflow (`3.6.1`–`3.6.8`)](../../srs/05-content-task-workflow/README.md) · [06-ai-features (`3.7.15`–`3.7.18`)](../../srs/06-ai-features/README.md).

---

## 2. Consolidated Modules (`2`)

| Module Slug | Scope & Engineering Title | Core Codebase Touchpoints | Lifecycle Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- | :--- |
| `manager-led-media-package-sharing` | **Manager-Led Media Package Offering Models, Public Guest Share Token & Task Seeding** | `/api/v1/public/media-packages/{token}` (`Guest` read + PDF/PNG export), `WorkspacePackagePlanningController` (`/impact`, `/preparation/retry`), deterministic `CampaignWorkItem -> Task` seeding | [Spec](./manager-led-media-package-sharing/spec.md) · [Plan](./manager-led-media-package-sharing/plan.md) · [Task](./manager-led-media-package-sharing/task.md) · [Test](./manager-led-media-package-sharing/test.md) |
| `campaign-timeline-and-closure` | **Interactive Campaign Gantt Timeline, Partner Cooperation, Request Validation & Campaign Closure** | `CampaignTimelineController` Gantt bars & milestone shifts, `trg_campaign_collaborator_mark_used` (`first_used_at`), `ContentRequest` completion guards & `CampaignClosureController` | [Spec](./campaign-timeline-and-closure/spec.md) · [Plan](./campaign-timeline-and-closure/plan.md) · [Task](./campaign-timeline-and-closure/task.md) · [Test](./campaign-timeline-and-closure/test.md) |

---

## 3. Architectural Invariants

1. At most one active `MediaCampaign` exists per `Workspace`, derived strictly from an `APPROVED` `WorkspaceMediaPackage` (`database/scripts/check-media-package-baseline.ps1`).
2. `Task` documents created from `CampaignWorkItem` vs standalone `ContentRequest` enforce mutually exclusive provenance (`campaignId` vs `contentRequestId`) with idempotent retry safety.
