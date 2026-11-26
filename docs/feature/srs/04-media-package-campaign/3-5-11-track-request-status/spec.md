> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.5.11 — Track Request Status

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.5.11` |
| **Use Case ID** | `UC-050` |
| **Feature** | Track Request Status |
| **Domain** | Media Package & Media Campaign (`FR 3.5`) |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Business Rules** | `BR-31` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Business Context

Theo dõi và điều phối trạng thái của Yêu cầu nội dung (Track Request Status — /workspaces/:id/requests). Gồm 4 trạng thái chuẩn: PENDING -> IN_PROGRESS -> ACCEPTED (hoặc DENIED). Chỉ phía Agency (Manager/Owner) mới có quyền chuyển trạng thái xét duyệt; khi chuyển sang ACCEPTED, hệ thống tự động sinh một Task tương ứng đẩy vào danh sách Task Backlog của Workspace để phân công thực hiện (BR-31).

**Architectural & Workflow Alignment:** Tracks and executes the deterministic state machine (`PENDING` -> explicit `/receive` -> `IN_PROGRESS` -> `/accept` -> `ACCEPTED` or `/deny` -> `DENIED`, `BR-31`). Opening list/detail is strictly read-only; `/accept` runs an atomic MongoDB transaction creating at most one `BACKLOG` `TaskDocument` (`unique(workspaceId, sourceType, sourceRefId)`) without mutating approved Package quantities.

## 2. User Story

As an authorized actor (`Owner, Manager, Client`), I want to execute **Track Request Status** with deterministic state validation, version-safe concurrency control, and strict Workspace/Agency isolation, so that commercial deliverables, Campaign schedules, and supplemental requests stay 100% synchronized (`BR-31`).

## 3. Acceptance Criteria

1. **Role & Scope Enforcement:** Only authenticated users holding `Owner, Manager, Client` in the target Agency/Workspace (plus `Guest` solely on public share token view `/api/v1/public/media-packages/{token}` in `3.5.2`) may invoke `GET /api/v1/workspaces/{workspaceId}/content-requests · GET /{requestId} · POST /{requestId}/receive · POST /{requestId}/accept · POST /{requestId}/deny · GET /{requestId}/task`; unauthorized requests receive `401` / `403`.
2. **Domain & State Machine Invariants (`BR-31`):** `ContentRequestReviewStore, ContentRequestStore, TaskMongoRepository` enforces state transition guards, version matching (`expectedTermsVersion` / `expectedVersion`), date boundaries in canonical Workspace timezone (`Asia/Ho_Chi_Minh` default), and snapshot isolation between Agency templates, Workspace packages, Campaigns, and Tasks.
3. **Hybrid Persistence Consistency:** State changes across MongoDB `content_requests` (`status`, `reviewedBy`, `reviewedAt`, `denialNote`, `generatedTaskId`, `version`), `tasks` (`sourceType = CONTENT_REQUEST`, `sourceRefId`) return standardized `ApiResponse<T>` envelopes with explicit `ErrorCode` mappings (`403 FORBIDDEN`, `404 REQUEST_NOT_FOUND`, `409 INVALID_REQUEST_TRANSITION` / `REQUEST_VERSION_CONFLICT`), leaving zero duplicate Campaigns or duplicate Tasks on retry.
4. **Internationalization (`vi` / `en`):** All labels, status badges, impact confirmation dialogs, empty states, and error messages use key-parallel entries (`requests.v2.status.* / requests.v2.review.* / requests.v2.generatedTask`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded strings.
5. **Semantic Light/Dark Theme & Responsive UX:** Web (`src/pages/requests/WorkspaceRequestPage.tsx`, `src/pages/requests/components/{WorkspaceRequestList,WorkspaceRequestDetail,WorkspaceRequestReview,WorkspaceRequestTask,WorkspaceRequestFilterBar}.tsx`) and Mobile (`src/screens/more/{ContentRequestsScreen,ContentRequestDetailScreen}.tsx`, `src/services/contentRequestService.ts`) surfaces use semantic theme tokens (`dark:` variants / `useTheme()`) with full keyboard navigation and mobile usability.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/requests/WorkspaceRequestPage.tsx`, `src/pages/requests/components/{WorkspaceRequestList,WorkspaceRequestDetail,WorkspaceRequestReview,WorkspaceRequestTask,WorkspaceRequestFilterBar}.tsx`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/more/{ContentRequestsScreen,ContentRequestDetailScreen}.tsx`, `src/services/contentRequestService.ts`
- **State Coverage:**
  - **Loading / In-Flight:** Skeleton placeholders and disabled action buttons while mutations execute.
  - **Empty / Unconfigured:** Role-specific guidance (e.g., guiding `Manager` to configure package/campaign or informing `Client` that preparation is underway) — never substituting synthetic mock data.
  - **Conflict (`409`):** Preserves unsaved user input/notes in the form/modal and prompts a clean reload of the latest version before re-submitting.
  - **Success:** Immediate TanStack Query invalidation across package, campaign, task, and request caches with localized toast feedback.

## 5. API Contract

- **Endpoints:** `GET /api/v1/workspaces/{workspaceId}/content-requests · GET /{requestId} · POST /{requestId}/receive · POST /{requestId}/accept · POST /{requestId}/deny · GET /{requestId}/task`
- **Controllers (`brandhub-business-service`):** `ContentRequestController.list() / detail(), ContentRequestReviewController.receive() / accept() / deny() / task()`
- **Services:** `ContentRequestReviewStore, ContentRequestStore, TaskMongoRepository`
- **Repositories / Stores:** ContentRequestStore, ContentRequestReviewStore, TaskMongoRepository

## 6. Error Handling & Edge Cases

- **Deterministic Domain Errors:** `403 FORBIDDEN`, `404 REQUEST_NOT_FOUND`, `409 INVALID_REQUEST_TRANSITION` / `REQUEST_VERSION_CONFLICT`.
- **Retry & Concurrency Safety:** Pessimistic row locks (`PESSIMISTIC_WRITE` on `workspace_media_packages` agreement lock) and optimistic version predicates (`terms_version`, `content_version`, MongoDB `version`) prevent lost updates or duplicate task generation when `Manager` and `Client` act simultaneously.
- **Historical Audit Preservation:** Negotiation events (`package_negotiation_events`), campaign versions (`campaign_versions`), review feedback (`campaign_review_events`), and cancelled/denied requests remain immutable in history views.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend controller/service logic verified by unit & integration tests ([test.md](./test.md)), Web and Mobile UI connected to live endpoints, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent lifecycle transitions handled by sibling FRs in `3.5.1–3.5.13` and Task execution/approval workflows in `3.6.1–3.6.10`.
- **Related Documentation:** [BA Media Package & Campaign Spec](../../../../ba/04-media-package-campaign.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
