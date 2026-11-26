> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.5.12 — Update Request

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.5.12` |
| **Use Case ID** | `UC-051` |
| **Feature** | Update Request |
| **Domain** | Media Package & Media Campaign (`FR 3.5`) |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Business Rules** | `BR-32` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Business Context

Chỉnh sửa nội dung của Yêu cầu phát sinh (Update Request — /workspaces/:id/requests/:requestId). Người tạo chỉ được phép cập nhật tiêu đề, mô tả, hạn mong muốn hoặc tệp tham khảo khi yêu cầu đang ở trạng thái PENDING; một khi Agency đã chuyển sang IN_PROGRESS, ACCEPTED hoặc DENIED thì nội dung yêu cầu bị khóa không cho sửa (BR-32).

**Architectural & Workflow Alignment:** Permits the requesting creator to patch `title`, `description`, `type`, or `dueDate` strictly while `status == PENDING` using an atomic `(workspaceId, _id, requestedBy, status=PENDING, version=expectedVersion)` predicate (`BR-32`); once a `Manager` clicks `/receive` (`IN_PROGRESS`), all fields lock immediately (`409 REQUEST_NOT_EDITABLE`).

## 2. User Story

As an authorized actor (`Owner, Manager, Client`), I want to execute **Update Request** with deterministic state validation, version-safe concurrency control, and strict Workspace/Agency isolation, so that commercial deliverables, Campaign schedules, and supplemental requests stay 100% synchronized (`BR-32`).

## 3. Acceptance Criteria

1. **Role & Scope Enforcement:** Only authenticated users holding `Owner, Manager, Client` in the target Agency/Workspace (plus `Guest` solely on public share token view `/api/v1/public/media-packages/{token}` in `3.5.2`) may invoke `PATCH /api/v1/workspaces/{workspaceId}/content-requests/{requestId}`; unauthorized requests receive `401` / `403`.
2. **Domain & State Machine Invariants (`BR-32`):** `ContentRequestStore` enforces state transition guards, version matching (`expectedTermsVersion` / `expectedVersion`), date boundaries in canonical Workspace timezone (`Asia/Ho_Chi_Minh` default), and snapshot isolation between Agency templates, Workspace packages, Campaigns, and Tasks.
3. **Hybrid Persistence Consistency:** State changes across MongoDB `content_requests` (`title`, `description`, `type`, `dueDate`, `status`, `version`, `updatedAt`) return standardized `ApiResponse<T>` envelopes with explicit `ErrorCode` mappings (`400 VALIDATION_ERROR` / `EMPTY_PATCH`, `403 FORBIDDEN` (not requesting creator), `404 REQUEST_NOT_FOUND`, `409 REQUEST_NOT_EDITABLE` / `REQUEST_VERSION_CONFLICT` (`BR-32`)), leaving zero duplicate Campaigns or duplicate Tasks on retry.
4. **Internationalization (`vi` / `en`):** All labels, status badges, impact confirmation dialogs, empty states, and error messages use key-parallel entries (`requests.revise.* / requests.fields.* / requests.errors.conflict`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded strings.
5. **Semantic Light/Dark Theme & Responsive UX:** Web (`src/pages/requests/WorkspaceRequestPage.tsx`, `src/pages/requests/components/{WorkspaceRequestForm,ReviseRequestModal}.tsx`, `src/pages/requests/requestErrors.ts`) and Mobile (`src/screens/more/{ContentRequestDetailScreen,ContentRequestFormScreen}.tsx`, `src/services/contentRequestService.ts`) surfaces use semantic theme tokens (`dark:` variants / `useTheme()`) with full keyboard navigation and mobile usability.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/requests/WorkspaceRequestPage.tsx`, `src/pages/requests/components/{WorkspaceRequestForm,ReviseRequestModal}.tsx`, `src/pages/requests/requestErrors.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/more/{ContentRequestDetailScreen,ContentRequestFormScreen}.tsx`, `src/services/contentRequestService.ts`
- **State Coverage:**
  - **Loading / In-Flight:** Skeleton placeholders and disabled action buttons while mutations execute.
  - **Empty / Unconfigured:** Role-specific guidance (e.g., guiding `Manager` to configure package/campaign or informing `Client` that preparation is underway) — never substituting synthetic mock data.
  - **Conflict (`409`):** Preserves unsaved user input/notes in the form/modal and prompts a clean reload of the latest version before re-submitting.
  - **Success:** Immediate TanStack Query invalidation across package, campaign, task, and request caches with localized toast feedback.

## 5. API Contract

- **Endpoints:** `PATCH /api/v1/workspaces/{workspaceId}/content-requests/{requestId}`
- **Controllers (`brandhub-business-service`):** `ContentRequestController.update()`
- **Services:** `ContentRequestStore`
- **Repositories / Stores:** ContentRequestStore (MongoDB `content_requests`), MediaCampaignRepository

## 6. Error Handling & Edge Cases

- **Deterministic Domain Errors:** `400 VALIDATION_ERROR` / `EMPTY_PATCH`, `403 FORBIDDEN` (not requesting creator), `404 REQUEST_NOT_FOUND`, `409 REQUEST_NOT_EDITABLE` / `REQUEST_VERSION_CONFLICT` (`BR-32`).
- **Retry & Concurrency Safety:** Pessimistic row locks (`PESSIMISTIC_WRITE` on `workspace_media_packages` agreement lock) and optimistic version predicates (`terms_version`, `content_version`, MongoDB `version`) prevent lost updates or duplicate task generation when `Manager` and `Client` act simultaneously.
- **Historical Audit Preservation:** Negotiation events (`package_negotiation_events`), campaign versions (`campaign_versions`), review feedback (`campaign_review_events`), and cancelled/denied requests remain immutable in history views.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend controller/service logic verified by unit & integration tests ([test.md](./test.md)), Web and Mobile UI connected to live endpoints, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent lifecycle transitions handled by sibling FRs in `3.5.1–3.5.13` and Task execution/approval workflows in `3.6.1–3.6.10`.
- **Related Documentation:** [BA Media Package & Campaign Spec](../../../../ba/04-media-package-campaign.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
