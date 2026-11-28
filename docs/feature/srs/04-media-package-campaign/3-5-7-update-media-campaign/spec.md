> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.5.7 — Update Media Campaign

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.5.7` |
| **Use Case ID** | `UC-046` |
| **Feature** | Update Media Campaign |
| **Domain** | Media Package & Media Campaign (`FR 3.5`) |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Business Rules** | `BR-27` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Business Context

Cập nhật nội dung Kế hoạch Chiến dịch Truyền thông và gửi phản hồi điều chỉnh trước khi phê duyệt chính thức (Update Media Campaign — /workspaces/:id/campaigns/:campaignId). Cho phép Agency chỉnh sửa danh sách hạng mục bài viết, mốc thời gian, kênh phân phối theo góp ý của Client khi chiến dịch đang ở trạng thái DRAFT hoặc PENDING_APPROVAL (BR-27).

**Architectural & Workflow Alignment:** Enforces optimistic concurrency (`expectedVersion` -> `content_version + 1` with `CampaignVersion` snapshot on `Owner`/`Manager` plan & brief edits, `BR-27`), allows `Client` to submit structured review feedback (`POST /feedback` -> `CampaignReviewEvent`) without mutating package terms, and supports timeline task scheduling plus third-party partner status updates (`CONTACTED`, `NEGOTIATING`, `CONFIRMED`, `LIVE`).

## 2. User Story

As an authorized actor (`Owner, Manager, Client`), I want to execute **Update Media Campaign** with deterministic state validation, version-safe concurrency control, and strict Workspace/Agency isolation, so that commercial deliverables, Campaign schedules, and supplemental requests stay 100% synchronized (`BR-27`).

## 3. Acceptance Criteria

1. **Role & Scope Enforcement:** Only authenticated users holding `Owner, Manager, Client` in the target Agency/Workspace (plus `Guest` solely on public share token view `/api/v1/public/media-packages/{token}` in `3.5.2`) may invoke `PATCH /api/v1/workspaces/{workspaceId}/campaigns/{campaignId} · PATCH /brief · POST /feedback · PATCH /tasks/{taskId}/schedule · POST|PUT|DELETE /campaigns/{campaignId}/collaborators`; unauthorized requests receive `401` / `403`.
2. **Domain & State Machine Invariants (`BR-27`):** `MediaCampaignService, CampaignTimelineService, CampaignCollaboratorService` enforces state transition guards, version matching (`expectedTermsVersion` / `expectedVersion`), date boundaries in canonical Workspace timezone (`Asia/Ho_Chi_Minh` default), and snapshot isolation between Agency templates, Workspace packages, Campaigns, and Tasks.
3. **Hybrid Persistence Consistency:** State changes across PostgreSQL `media_campaigns` (`content_version`), `campaign_versions`, `campaign_review_events`, `campaign_collaborators`; MongoDB `tasks` return standardized `ApiResponse<T>` envelopes with explicit `ErrorCode` mappings (`400 VALIDATION_ERROR`, `403 FORBIDDEN`, `404 CAMPAIGN_NOT_FOUND`, `409 CAMPAIGN_VERSION_CONFLICT` / `CAMPAIGN_LOCKED`), leaving zero duplicate Campaigns or duplicate Tasks on retry.
4. **Internationalization (`vi` / `en`):** All labels, status badges, impact confirmation dialogs, empty states, and error messages use key-parallel entries (`campaign.edit.* / campaign.brief.* / campaign.feedback.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded strings.
5. **Semantic Light/Dark Theme & Responsive UX:** Web (`src/pages/campaign/{index,page}.tsx`, `src/pages/campaign/components/{CampaignBriefChipGroup,CampaignBriefFormatSections}.tsx`) and Mobile (`src/screens/more/CampaignDetailScreen.tsx`, `src/services/campaignService.ts`) surfaces use semantic theme tokens (`dark:` variants / `useTheme()`) with full keyboard navigation and mobile usability.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/campaign/{index,page}.tsx`, `src/pages/campaign/components/{CampaignBriefChipGroup,CampaignBriefFormatSections}.tsx`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/more/CampaignDetailScreen.tsx`, `src/services/campaignService.ts`
- **State Coverage:**
  - **Loading / In-Flight:** Skeleton placeholders and disabled action buttons while mutations execute.
  - **Empty / Unconfigured:** Role-specific guidance (e.g., guiding `Manager` to configure package/campaign or informing `Client` that preparation is underway) — never substituting synthetic mock data.
  - **Conflict (`409`):** Preserves unsaved user input/notes in the form/modal and prompts a clean reload of the latest version before re-submitting.
  - **Success:** Immediate TanStack Query invalidation across package, campaign, task, and request caches with localized toast feedback.

## 5. API Contract

- **Endpoints:** `PATCH /api/v1/workspaces/{workspaceId}/campaigns/{campaignId} · PATCH /brief · POST /feedback · PATCH /tasks/{taskId}/schedule · POST|PUT|DELETE /campaigns/{campaignId}/collaborators`
- **Controllers (`brandhub-business-service`):** `WorkspaceCampaignController.update() / updateBrief() / feedback(), CampaignTimelineController.schedule() / createOutOfScopeTask() / reorderTasks(), CampaignCollaboratorController.assign() / update() / unlink()`
- **Services:** `MediaCampaignService, CampaignTimelineService, CampaignCollaboratorService`
- **Repositories / Stores:** MediaCampaignRepository, CampaignVersionRepository, CampaignReviewEventRepository, CampaignCollaboratorRepository

## 6. Error Handling & Edge Cases

- **Deterministic Domain Errors:** `400 VALIDATION_ERROR`, `403 FORBIDDEN`, `404 CAMPAIGN_NOT_FOUND`, `409 CAMPAIGN_VERSION_CONFLICT` / `CAMPAIGN_LOCKED`.
- **Retry & Concurrency Safety:** Pessimistic row locks (`PESSIMISTIC_WRITE` on `workspace_media_packages` agreement lock) and optimistic version predicates (`terms_version`, `content_version`, MongoDB `version`) prevent lost updates or duplicate task generation when `Manager` and `Client` act simultaneously.
- **Historical Audit Preservation:** Negotiation events (`package_negotiation_events`), campaign versions (`campaign_versions`), review feedback (`campaign_review_events`), and cancelled/denied requests remain immutable in history views.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend controller/service logic verified by unit & integration tests ([test.md](./test.md)), Web and Mobile UI connected to live endpoints, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent lifecycle transitions handled by sibling FRs in `3.5.1–3.5.13` and Task execution/approval workflows in `3.6.1–3.6.10`.
- **Related Documentation:** [BA Media Package & Campaign Spec](../../../../ba/04-media-package-campaign.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
