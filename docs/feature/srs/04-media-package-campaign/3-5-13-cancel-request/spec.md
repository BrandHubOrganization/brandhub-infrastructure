> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.5.13 — Cancel Request

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.5.13` |
| **Use Case ID** | `UC-052` |
| **Feature** | Cancel Request |
| **Domain** | Media Package & Media Campaign (`FR 3.5`) |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Business Rules** | `BR-32` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Business Context

Hủy yêu cầu nội dung phát sinh (Cancel Request — /workspaces/:id/requests/:requestId). Chỉ cho phép hủy yêu cầu khi đang ở trạng thái PENDING (chuyển trạng thái sang CANCELLED); các yêu cầu đã chuyển sang xử lý hoặc đã duyệt không được phép xóa/hủy (BR-32).

**Architectural & Workflow Alignment:** Transitions a `PENDING` Content Request to terminal `CANCELLED` status (retaining audit/history visibility rather than hard-deleting) via an atomic status/version CAS predicate that safely races against `Manager` `/receive` (`BR-32`) and never creates or mutates any `TaskDocument`.

## 2. User Story

As an authorized actor (`Owner, Manager, Client`), I want to execute **Cancel Request** with deterministic state validation, version-safe concurrency control, and strict Workspace/Agency isolation, so that commercial deliverables, Campaign schedules, and supplemental requests stay 100% synchronized (`BR-32`).

## 3. Acceptance Criteria

1. **Role & Scope Enforcement:** Only authenticated users holding `Owner, Manager, Client` in the target Agency/Workspace (plus `Guest` solely on public share token view `/api/v1/public/media-packages/{token}` in `3.5.2`) may invoke `DELETE /api/v1/workspaces/{workspaceId}/content-requests/{requestId}`; unauthorized requests receive `401` / `403`.
2. **Domain & State Machine Invariants (`BR-32`):** `ContentRequestStore` enforces state transition guards, version matching (`expectedTermsVersion` / `expectedVersion`), date boundaries in canonical Workspace timezone (`Asia/Ho_Chi_Minh` default), and snapshot isolation between Agency templates, Workspace packages, Campaigns, and Tasks.
3. **Hybrid Persistence Consistency:** State changes across MongoDB `content_requests` (`status = CANCELLED`, `cancelledAt`, `version`) return standardized `ApiResponse<T>` envelopes with explicit `ErrorCode` mappings (`403 FORBIDDEN` (non-creator), `404 REQUEST_NOT_FOUND`, `409 REQUEST_NOT_CANCELLABLE` (`BR-32`)), leaving zero duplicate Campaigns or duplicate Tasks on retry.
4. **Internationalization (`vi` / `en`):** All labels, status badges, impact confirmation dialogs, empty states, and error messages use key-parallel entries (`requests.cancelDialog.* / requests.status.cancelled`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded strings.
5. **Semantic Light/Dark Theme & Responsive UX:** Web (`src/pages/requests/WorkspaceRequestPage.tsx`, `src/pages/requests/components/{WorkspaceRequestCancel,CancelRequestDialog}.tsx`) and Mobile (`src/screens/more/ContentRequestDetailScreen.tsx`, `src/services/contentRequestService.ts`) surfaces use semantic theme tokens (`dark:` variants / `useTheme()`) with full keyboard navigation and mobile usability.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/requests/WorkspaceRequestPage.tsx`, `src/pages/requests/components/{WorkspaceRequestCancel,CancelRequestDialog}.tsx`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/more/ContentRequestDetailScreen.tsx`, `src/services/contentRequestService.ts`
- **State Coverage:**
  - **Loading / In-Flight:** Skeleton placeholders and disabled action buttons while mutations execute.
  - **Empty / Unconfigured:** Role-specific guidance (e.g., guiding `Manager` to configure package/campaign or informing `Client` that preparation is underway) — never substituting synthetic mock data.
  - **Conflict (`409`):** Preserves unsaved user input/notes in the form/modal and prompts a clean reload of the latest version before re-submitting.
  - **Success:** Immediate TanStack Query invalidation across package, campaign, task, and request caches with localized toast feedback.

## 5. API Contract

- **Endpoints:** `DELETE /api/v1/workspaces/{workspaceId}/content-requests/{requestId}`
- **Controllers (`brandhub-business-service`):** `ContentRequestController.cancel()`
- **Services:** `ContentRequestStore`
- **Repositories / Stores:** ContentRequestStore (MongoDB `content_requests`)

## 6. Error Handling & Edge Cases

- **Deterministic Domain Errors:** `403 FORBIDDEN` (non-creator), `404 REQUEST_NOT_FOUND`, `409 REQUEST_NOT_CANCELLABLE` (`BR-32`).
- **Retry & Concurrency Safety:** Pessimistic row locks (`PESSIMISTIC_WRITE` on `workspace_media_packages` agreement lock) and optimistic version predicates (`terms_version`, `content_version`, MongoDB `version`) prevent lost updates or duplicate task generation when `Manager` and `Client` act simultaneously.
- **Historical Audit Preservation:** Negotiation events (`package_negotiation_events`), campaign versions (`campaign_versions`), review feedback (`campaign_review_events`), and cancelled/denied requests remain immutable in history views.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend controller/service logic verified by unit & integration tests ([test.md](./test.md)), Web and Mobile UI connected to live endpoints, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent lifecycle transitions handled by sibling FRs in `3.5.1–3.5.13` and Task execution/approval workflows in `3.6.1–3.6.10`.
- **Related Documentation:** [BA Media Package & Campaign Spec](../../../../ba/04-media-package-campaign.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
