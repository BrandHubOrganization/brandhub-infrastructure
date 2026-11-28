> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.5.10 — Create Content Request

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.5.10` |
| **Use Case ID** | `UC-049` |
| **Feature** | Create Content Request |
| **Domain** | Media Package & Media Campaign (`FR 3.5`) |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Business Rules** | `BR-31` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Business Context

Tạo yêu cầu nội dung bổ sung/phát sinh ngoài kế hoạch ban đầu (Create Content Request — /workspaces/:id/requests/new). Cho phép Client hoặc Manager gửi yêu cầu bài viết/sự kiện mới kèm tiêu đề, mô tả, nền tảng mong muốn, hạn chót và tệp đính kèm. Yêu cầu khởi tạo ở trạng thái PENDING để chờ Manager xem xét và ghi nhận làm căn cứ tính khối lượng công việc bổ sung (BR-31).

**Architectural & Workflow Alignment:** Allows an active Workspace `Client` (and authorized `Owner`/`Manager` per workspace policy) to submit supplemental out-of-package requests (`POST|SHORT_VIDEO|SURVEY|EVENT_PLAN|PRESS_RECOMMENDATION`) in `PENDING` state (`BR-31`), enforcing server-side that the Workspace has an `IN_PROGRESS` Campaign with `SUCCEEDED` deployment and `dueDate` within `[max(today_in_workspace_tz, campaign.startDate), campaign.endDate]`.

## 2. User Story

As an authorized actor (`Owner, Manager, Client`), I want to execute **Create Content Request** with deterministic state validation, version-safe concurrency control, and strict Workspace/Agency isolation, so that commercial deliverables, Campaign schedules, and supplemental requests stay 100% synchronized (`BR-31`).

## 3. Acceptance Criteria

1. **Role & Scope Enforcement:** Only authenticated users holding `Owner, Manager, Client` in the target Agency/Workspace (plus `Guest` solely on public share token view `/api/v1/public/media-packages/{token}` in `3.5.2`) may invoke `POST /api/v1/workspaces/{workspaceId}/content-requests`; unauthorized requests receive `401` / `403`.
2. **Domain & State Machine Invariants (`BR-31`):** `ContentRequestService / ContentRequestStore` enforces state transition guards, version matching (`expectedTermsVersion` / `expectedVersion`), date boundaries in canonical Workspace timezone (`Asia/Ho_Chi_Minh` default), and snapshot isolation between Agency templates, Workspace packages, Campaigns, and Tasks.
3. **Hybrid Persistence Consistency:** State changes across MongoDB `content_requests` (`ContentRequestDocument`); PostgreSQL `media_campaigns`, `campaign_deployments` return standardized `ApiResponse<T>` envelopes with explicit `ErrorCode` mappings (`400 VALIDATION_ERROR` / `INVALID_DUE_DATE`, `403 FORBIDDEN`, `409 CAMPAIGN_NOT_DEPLOYED` / `CAMPAIGN_COMPLETED` (`BR-31`)), leaving zero duplicate Campaigns or duplicate Tasks on retry.
4. **Internationalization (`vi` / `en`):** All labels, status badges, impact confirmation dialogs, empty states, and error messages use key-parallel entries (`requests.v2.* / requests.create.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded strings.
5. **Semantic Light/Dark Theme & Responsive UX:** Web (`src/pages/requests/{WorkspaceRequestPage,index}.tsx`, `src/pages/requests/components/{WorkspaceRequestForm,CreateRequestModal}.tsx`, `src/pages/requests/lib/requestDeadline.ts`, `src/pages/requests/services/workspaceRequestService.ts`) and Mobile (`src/screens/more/{ContentRequestsScreen,ContentRequestFormScreen}.tsx`, `src/services/contentRequestService.ts`) surfaces use semantic theme tokens (`dark:` variants / `useTheme()`) with full keyboard navigation and mobile usability.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/requests/{WorkspaceRequestPage,index}.tsx`, `src/pages/requests/components/{WorkspaceRequestForm,CreateRequestModal}.tsx`, `src/pages/requests/lib/requestDeadline.ts`, `src/pages/requests/services/workspaceRequestService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/more/{ContentRequestsScreen,ContentRequestFormScreen}.tsx`, `src/services/contentRequestService.ts`
- **State Coverage:**
  - **Loading / In-Flight:** Skeleton placeholders and disabled action buttons while mutations execute.
  - **Empty / Unconfigured:** Role-specific guidance (e.g., guiding `Manager` to configure package/campaign or informing `Client` that preparation is underway) — never substituting synthetic mock data.
  - **Conflict (`409`):** Preserves unsaved user input/notes in the form/modal and prompts a clean reload of the latest version before re-submitting.
  - **Success:** Immediate TanStack Query invalidation across package, campaign, task, and request caches with localized toast feedback.

## 5. API Contract

- **Endpoints:** `POST /api/v1/workspaces/{workspaceId}/content-requests`
- **Controllers (`brandhub-business-service`):** `ContentRequestController.create()`
- **Services:** `ContentRequestService / ContentRequestStore`
- **Repositories / Stores:** ContentRequestStore (MongoDB `content_requests`), MediaCampaignRepository, CampaignDeploymentRepository

## 6. Error Handling & Edge Cases

- **Deterministic Domain Errors:** `400 VALIDATION_ERROR` / `INVALID_DUE_DATE`, `403 FORBIDDEN`, `409 CAMPAIGN_NOT_DEPLOYED` / `CAMPAIGN_COMPLETED` (`BR-31`).
- **Retry & Concurrency Safety:** Pessimistic row locks (`PESSIMISTIC_WRITE` on `workspace_media_packages` agreement lock) and optimistic version predicates (`terms_version`, `content_version`, MongoDB `version`) prevent lost updates or duplicate task generation when `Manager` and `Client` act simultaneously.
- **Historical Audit Preservation:** Negotiation events (`package_negotiation_events`), campaign versions (`campaign_versions`), review feedback (`campaign_review_events`), and cancelled/denied requests remain immutable in history views.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend controller/service logic verified by unit & integration tests ([test.md](./test.md)), Web and Mobile UI connected to live endpoints, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent lifecycle transitions handled by sibling FRs in `3.5.1–3.5.13` and Task execution/approval workflows in `3.6.1–3.6.10`.
- **Related Documentation:** [BA Media Package & Campaign Spec](../../../../ba/04-media-package-campaign.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
