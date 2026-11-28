> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.5.9 — Complete Media Campaign

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.5.9` |
| **Use Case ID** | `UC-048` |
| **Feature** | Complete Media Campaign |
| **Domain** | Media Package & Media Campaign (`FR 3.5`) |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Business Rules** | `BR-30` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Business Context

Nghiệm thu và hoàn tất Chiến dịch Truyền thông (Complete Media Campaign — /workspaces/:id/campaigns/:campaignId). Chuyển trạng thái chiến dịch từ ACTIVE sang COMPLETED sau khi hoàn thành bàn giao, đồng thời hệ thống tự động hủy (CANCELLED) toàn bộ các yêu cầu phát sinh (Content Requests) còn đang treo ở trạng thái PENDING thuộc chiến dịch đó (BR-30).

**Architectural & Workflow Alignment:** Runs a pre-closure audit (`GET /completion-check`) listing unfinished Tasks (`BACKLOG`, `TODO`, `IN_PROGRESS`, `IN_REVIEW`), lets `Owner`/`Manager` bulk-cancel unstarted/abandoned Tasks (`POST /tasks/cancel` cleaning `reviewStep`/`lastSubmission` via CAS), transitions the `IN_PROGRESS` Campaign to `COMPLETED` (`POST /complete`, `BR-30`), and automatically cancels remaining `PENDING` Content Requests with audit history.

## 2. User Story

As an authorized actor (`Owner, Manager`), I want to execute **Complete Media Campaign** with deterministic state validation, version-safe concurrency control, and strict Workspace/Agency isolation, so that commercial deliverables, Campaign schedules, and supplemental requests stay 100% synchronized (`BR-30`).

## 3. Acceptance Criteria

1. **Role & Scope Enforcement:** Only authenticated users holding `Owner, Manager` in the target Agency/Workspace (plus `Guest` solely on public share token view `/api/v1/public/media-packages/{token}` in `3.5.2`) may invoke `GET /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/completion-check · POST /tasks/cancel · POST /complete`; unauthorized requests receive `401` / `403`.
2. **Domain & State Machine Invariants (`BR-30`):** `CampaignDeploymentService, CampaignClosureStore, ContentRequestStore` enforces state transition guards, version matching (`expectedTermsVersion` / `expectedVersion`), date boundaries in canonical Workspace timezone (`Asia/Ho_Chi_Minh` default), and snapshot isolation between Agency templates, Workspace packages, Campaigns, and Tasks.
3. **Hybrid Persistence Consistency:** State changes across PostgreSQL `media_campaigns` (`status = COMPLETED`, `completed_at`); MongoDB `tasks`, `content_requests` return standardized `ApiResponse<T>` envelopes with explicit `ErrorCode` mappings (`403 FORBIDDEN`, `404 CAMPAIGN_NOT_FOUND`, `409 INVALID_CAMPAIGN_STATE` / `OPEN_TASKS_REMAINING` (`BR-30`)), leaving zero duplicate Campaigns or duplicate Tasks on retry.
4. **Internationalization (`vi` / `en`):** All labels, status badges, impact confirmation dialogs, empty states, and error messages use key-parallel entries (`campaign.complete.* / campaign.closure.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded strings.
5. **Semantic Light/Dark Theme & Responsive UX:** Web (`src/pages/campaign/{index,page}.tsx`) and Mobile (`src/screens/more/CampaignDetailScreen.tsx`, `src/services/campaignService.ts`) surfaces use semantic theme tokens (`dark:` variants / `useTheme()`) with full keyboard navigation and mobile usability.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/campaign/{index,page}.tsx`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/more/CampaignDetailScreen.tsx`, `src/services/campaignService.ts`
- **State Coverage:**
  - **Loading / In-Flight:** Skeleton placeholders and disabled action buttons while mutations execute.
  - **Empty / Unconfigured:** Role-specific guidance (e.g., guiding `Manager` to configure package/campaign or informing `Client` that preparation is underway) — never substituting synthetic mock data.
  - **Conflict (`409`):** Preserves unsaved user input/notes in the form/modal and prompts a clean reload of the latest version before re-submitting.
  - **Success:** Immediate TanStack Query invalidation across package, campaign, task, and request caches with localized toast feedback.

## 5. API Contract

- **Endpoints:** `GET /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/completion-check · POST /tasks/cancel · POST /complete`
- **Controllers (`brandhub-business-service`):** `CampaignClosureController.preview() / cancel(), WorkspaceCampaignController.complete()`
- **Services:** `CampaignDeploymentService, CampaignClosureStore, ContentRequestStore`
- **Repositories / Stores:** MediaCampaignRepository, TaskMongoRepository, ContentRequestStore

## 6. Error Handling & Edge Cases

- **Deterministic Domain Errors:** `403 FORBIDDEN`, `404 CAMPAIGN_NOT_FOUND`, `409 INVALID_CAMPAIGN_STATE` / `OPEN_TASKS_REMAINING` (`BR-30`).
- **Retry & Concurrency Safety:** Pessimistic row locks (`PESSIMISTIC_WRITE` on `workspace_media_packages` agreement lock) and optimistic version predicates (`terms_version`, `content_version`, MongoDB `version`) prevent lost updates or duplicate task generation when `Manager` and `Client` act simultaneously.
- **Historical Audit Preservation:** Negotiation events (`package_negotiation_events`), campaign versions (`campaign_versions`), review feedback (`campaign_review_events`), and cancelled/denied requests remain immutable in history views.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend controller/service logic verified by unit & integration tests ([test.md](./test.md)), Web and Mobile UI connected to live endpoints, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent lifecycle transitions handled by sibling FRs in `3.5.1–3.5.13` and Task execution/approval workflows in `3.6.1–3.6.10`.
- **Related Documentation:** [BA Media Package & Campaign Spec](../../../../ba/04-media-package-campaign.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
