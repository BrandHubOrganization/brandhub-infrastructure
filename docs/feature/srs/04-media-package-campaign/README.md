# 3.5 Media Package & Media Campaign (13 FRs)

> **Navigation:** [← Feature Master Index](../../README.md) · [← SRS 141 FRs Index](../README.md) · [BA Domain Spec](../../../ba/04-media-package-campaign.md) · [State Machines](../../../ba/12-state-machines.md) · [Use Cases](../../../ba/use-cases/03-media-package-campaign.md) · [Module Specs Index](../../modules/README.md) · [Workflow Rule](../../../rule/feature-workflow.md)

Canonical specification, technical implementation plan, task breakdown, and unit/acceptance test verification suite for **3.5 Media Package & Media Campaign** (`3.5.1 – 3.5.13`, **13 Atomic CRUD Functional Requirements**).

---

## 1. Domain Architecture Overview

Domain `3.5` bridges commercial service packaging (**Media Package**), structured campaign execution planning (**Media Campaign**), and supplemental post-deployment client requests (**Content Request**) across a coordinated PostgreSQL + MongoDB persistence boundary:

- **Media Package Catalogue, Guest Sharing & Manager-Led Workspace Preparation (`3.5.1` – `3.5.4`):**
  - **Controllers (`brandhub-business-service`):** `MediaPackageController`, `MediaPackageShareController`, `WorkspacePackagePlanningController`, `PackageNegotiationHistoryController`, `ProfileMatchingController` (`/media-package-fit`).
  - **Dual Capabilities:**
    1. **Agency Catalogue & Public Guest Sharing:** `Owner` creates Agency custom packages (`POST /api/v1/agencies/{agencyId}/media-package-custom` with `OfferingModel` deliverables, criteria, duration, budget), toggles availability, exports snapshots to PDF/PNG (`GET .../export`), and issues/revokes public read-only guest share links (`GET /api/v1/public/media-packages/{token}`).
    2. **Workspace Package Recording, Impact Sync & Negotiation History:** `Manager` / `Owner` records or updates the Workspace execution package (`PUT /api/v1/workspaces/{workspaceId}/media-package` with `POST .../impact` change-impact preview and `POST .../preparation/retry`), while retaining legacy/audit negotiation & approval endpoints (`selectPackage`, `negotiateTerms`, `approvePackage`, and immutable `package_negotiation_events` history).
- **Package-Driven Media Campaign Lifecycle, Timeline, Collaborators & Closure (`3.5.5` – `3.5.9`):**
  - **Controllers:** `WorkspaceCampaignController` (`/api/v1/workspaces/{workspaceId}/campaigns/*`), `MediaCampaignController`, `CampaignTimelineController`, `CampaignCollaboratorController`, `CampaignClosureController`, `CampaignSubtaskController`.
  - **Capabilities:** Enforces at most one `MediaCampaign` per Workspace (`DRAFT` -> `APPROVED` -> `IN_PROGRESS` via `CampaignDeploymentService` -> `COMPLETED`), versioned plan/brief updates (`campaign_versions`), structured Client feedback (`campaign_review_events`), interactive Gantt/timeline scheduling (`CampaignTimelineController`), third-party partner tracking (`campaign_collaborators`: `CONTACTED`, `NEGOTIATING`, `CONFIRMED`, `LIVE`), pre-closure deliverable verification (`/completion-check`), and atomic campaign completion (`/complete`).
- **Supplemental Client Content Requests (`3.5.10` – `3.5.13`):**
  - **Controllers:** `ContentRequestController` & `ContentRequestReviewController` (`/api/v1/workspaces/{workspaceId}/content-requests/*`) backed by MongoDB `content_requests` (`ContentRequestDocument`, `ContentRequestStore`, `ContentRequestReviewStore`).
  - **Lifecycle (`PENDING` -> `IN_PROGRESS` -> `ACCEPTED` | `DENIED`, or `PENDING` -> `CANCELLED`):** Requires an `IN_PROGRESS` deployed Campaign in the Workspace (`BR-31`). Explicit `Manager` receipt (`/receive`) locks `Client` edits/cancellations (`BR-32`), and `/accept` executes an idempotent MongoDB transaction creating exactly one linked `TaskDocument` (`sourceType = CONTENT_REQUEST`, `sourceRefId = requestId`).
- **Client Surfaces (`brandhub-web` & `brandhub-mobile-app`):**
  - **Web (`brandhub-web`):** `src/pages/media-package/{index,agency,guest}.tsx`, `src/pages/campaign/{index,page}.tsx`, `src/pages/requests/{index,WorkspaceRequestPage}.tsx`.
  - **Mobile (`brandhub-mobile-app`):** `src/screens/more/{MediaPackageScreen,CampaignsScreen,CampaignDetailScreen,ContentRequestsScreen,ContentRequestDetailScreen,ContentRequestFormScreen}.tsx`.

---

## 2. Functional Requirements Matrix

| FR ID | UC ID | Function Name | Canonical Roles | Status | Feature Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `3.5.1` | `UC-040` | **Create Media Package** | `Owner` | Implemented | [Spec](./3-5-1-create-media-package/spec.md) · [Plan](./3-5-1-create-media-package/plan.md) · [Task](./3-5-1-create-media-package/task.md) · [Test](./3-5-1-create-media-package/test.md) |
| `3.5.2` | `UC-041` | **View Template Media Package** | `Owner, Manager, Client` | Implemented | [Spec](./3-5-2-view-template-media-package/spec.md) · [Plan](./3-5-2-view-template-media-package/plan.md) · [Task](./3-5-2-view-template-media-package/task.md) · [Test](./3-5-2-view-template-media-package/test.md) |
| `3.5.3` | `UC-042` | **Request Media Package** | `Owner, Manager, Client` | Implemented | [Spec](./3-5-3-request-media-package/spec.md) · [Plan](./3-5-3-request-media-package/plan.md) · [Task](./3-5-3-request-media-package/task.md) · [Test](./3-5-3-request-media-package/test.md) |
| `3.5.4` | `UC-043` | **Approve Media Package** | `Owner, Manager, Client` | Implemented | [Spec](./3-5-4-approve-media-package/spec.md) · [Plan](./3-5-4-approve-media-package/plan.md) · [Task](./3-5-4-approve-media-package/task.md) · [Test](./3-5-4-approve-media-package/test.md) |
| `3.5.5` | `UC-044` | **Create Media Campaign** | `Owner, Manager` | Implemented | [Spec](./3-5-5-create-media-campaign/spec.md) · [Plan](./3-5-5-create-media-campaign/plan.md) · [Task](./3-5-5-create-media-campaign/task.md) · [Test](./3-5-5-create-media-campaign/test.md) |
| `3.5.6` | `UC-045` | **View Media Campaign** | `Owner, Manager, Creator, Client` | Implemented | [Spec](./3-5-6-view-media-campaign/spec.md) · [Plan](./3-5-6-view-media-campaign/plan.md) · [Task](./3-5-6-view-media-campaign/task.md) · [Test](./3-5-6-view-media-campaign/test.md) |
| `3.5.7` | `UC-046` | **Update Media Campaign** | `Owner, Manager, Client` | Implemented | [Spec](./3-5-7-update-media-campaign/spec.md) · [Plan](./3-5-7-update-media-campaign/plan.md) · [Task](./3-5-7-update-media-campaign/task.md) · [Test](./3-5-7-update-media-campaign/test.md) |
| `3.5.8` | `UC-047` | **Approve Media Campaign** | `Owner, Manager, Client` | Implemented | [Spec](./3-5-8-approve-media-campaign/spec.md) · [Plan](./3-5-8-approve-media-campaign/plan.md) · [Task](./3-5-8-approve-media-campaign/task.md) · [Test](./3-5-8-approve-media-campaign/test.md) |
| `3.5.9` | `UC-048` | **Complete Media Campaign** | `Owner, Manager` | Implemented | [Spec](./3-5-9-complete-media-campaign/spec.md) · [Plan](./3-5-9-complete-media-campaign/plan.md) · [Task](./3-5-9-complete-media-campaign/task.md) · [Test](./3-5-9-complete-media-campaign/test.md) |
| `3.5.10` | `UC-049` | **Create Content Request** | `Owner, Manager, Client` | Implemented | [Spec](./3-5-10-create-content-request/spec.md) · [Plan](./3-5-10-create-content-request/plan.md) · [Task](./3-5-10-create-content-request/task.md) · [Test](./3-5-10-create-content-request/test.md) |
| `3.5.11` | `UC-050` | **Track Request Status** | `Owner, Manager, Client` | Implemented | [Spec](./3-5-11-track-request-status/spec.md) · [Plan](./3-5-11-track-request-status/plan.md) · [Task](./3-5-11-track-request-status/task.md) · [Test](./3-5-11-track-request-status/test.md) |
| `3.5.12` | `UC-051` | **Update Request** | `Owner, Manager, Client` | Implemented | [Spec](./3-5-12-update-request/spec.md) · [Plan](./3-5-12-update-request/plan.md) · [Task](./3-5-12-update-request/task.md) · [Test](./3-5-12-update-request/test.md) |
| `3.5.13` | `UC-052` | **Cancel Request** | `Owner, Manager, Client` | Implemented | [Spec](./3-5-13-cancel-request/spec.md) · [Plan](./3-5-13-cancel-request/plan.md) · [Task](./3-5-13-cancel-request/task.md) · [Test](./3-5-13-cancel-request/test.md) |

---

## 3. Core Business Rules & Hybrid Persistence Invariants

- **`BR-25` & `BR-26` (Snapshot Isolation & Append-Only Package Terms):** Workspace packages snapshot `final_terms` independently of Agency catalogue templates so editing an Agency package never mutates existing Workspace agreements or deployed Campaigns. Append-only `package_negotiation_events` preserve audit history.
- **`BR-27`–`BR-29` (Single Campaign per Workspace & Version-Locked Deployment):** Each Workspace holds at most one `MediaCampaign` (`UNIQUE(workspace_media_package_id)`). Deployment (`POST .../deploy`) locks package deliverables and materializes MongoDB `TaskDocument` items idempotently (`campaign_deployments`).
- **`BR-30` (Verified Campaign Closure):** Completing a Campaign (`/completion-check` + `/complete`) validates open tasks, automatically cancels remaining `PENDING` Content Requests with audit provenance, and locks post-completion task/request creation.
- **`BR-31` & `BR-32` (Deployed Campaign Gate & Receipt Lock on Content Requests):** Creating a Content Request requires an `IN_PROGRESS` Campaign with `SUCCEEDED` deployment and a `dueDate` within `[max(today, startDate), endDate]`. Explicit `Manager` receipt (`PENDING -> IN_PROGRESS`) atomically locks `Client` edit and cancel actions.

## 4. Cross-References

- **BA Domain Specification:** [04-media-package-campaign.md](../../../ba/04-media-package-campaign.md) · [12-state-machines.md](../../../ba/12-state-machines.md)
- **BA System Overview:** [BA Overview](../../../ba/README.md)
- **Consolidated Feature Modules:** [Module Specs Index](../../modules/README.md)
