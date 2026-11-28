> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.5.5 — Create Media Campaign

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.5.5` |
| **Use Case ID** | `UC-044` |
| **Feature** | Create Media Campaign |
| **Domain** | Media Package & Media Campaign (`FR 3.5`) |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Business Rules** | `BR-27` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Business Context

Khởi tạo Kế hoạch Chiến dịch Truyền thông chi tiết dựa trên Media Package đã được phê duyệt (Create Media Campaign — /workspaces/:id/campaigns/new). Đóng vai trò là bản chiến lược thực thi chi tiết phù hợp với thương hiệu của Client: xác định mục tiêu chiến dịch, lộ trình thời gian (Start/End Date), danh sách các đầu mục bài viết dự kiến (tiêu đề, nền tảng đăng tải, định dạng, lịch dự kiến) (BR-27).

**Architectural & Workflow Alignment:** Enforces strictly one `MediaCampaign` per Workspace (`BR-27`, `BR-28`): automatically provisions the `DRAFT` Campaign and package-driven deliverable Tasks (`TaskDocument` in `BACKLOG`) upon valid Workspace package save, preserving stable task IDs across retries and pre-deployment edits.

## 2. User Story

As an authorized actor (`Owner, Manager`), I want to execute **Create Media Campaign** with deterministic state validation, version-safe concurrency control, and strict Workspace/Agency isolation, so that commercial deliverables, Campaign schedules, and supplemental requests stay 100% synchronized (`BR-27`).

## 3. Acceptance Criteria

1. **Role & Scope Enforcement:** Only authenticated users holding `Owner, Manager` in the target Agency/Workspace (plus `Guest` solely on public share token view `/api/v1/public/media-packages/{token}` in `3.5.2`) may invoke `PUT /api/v1/workspaces/{workspaceId}/media-package · GET /api/v1/workspaces/{workspaceId}/campaigns · PATCH /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}`; unauthorized requests receive `401` / `403`.
2. **Domain & State Machine Invariants (`BR-27`):** `WorkspacePackagePlanningService, MediaCampaignService` enforces state transition guards, version matching (`expectedTermsVersion` / `expectedVersion`), date boundaries in canonical Workspace timezone (`Asia/Ho_Chi_Minh` default), and snapshot isolation between Agency templates, Workspace packages, Campaigns, and Tasks.
3. **Hybrid Persistence Consistency:** State changes across PostgreSQL `media_campaigns` (`UNIQUE(workspace_media_package_id)`, `status = DRAFT`, `work_items` JSONB, `content_version`), `campaign_versions`; MongoDB `tasks` return standardized `ApiResponse<T>` envelopes with explicit `ErrorCode` mappings (`400 VALIDATION_ERROR`, `403 FORBIDDEN`, `409 CAMPAIGN_ALREADY_EXISTS` / `CAMPAIGN_VERSION_CONFLICT`), leaving zero duplicate Campaigns or duplicate Tasks on retry.
4. **Internationalization (`vi` / `en`):** All labels, status badges, impact confirmation dialogs, empty states, and error messages use key-parallel entries (`campaign.create.* / campaign.plan.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded strings.
5. **Semantic Light/Dark Theme & Responsive UX:** Web (`src/pages/campaign/{index,page}.tsx`, `src/pages/media-package/components/CampaignDraftPanel.tsx`, `src/services/campaignService.ts`) and Mobile (`src/screens/more/{CampaignsScreen,CampaignDetailScreen}.tsx`, `src/services/campaignService.ts`) surfaces use semantic theme tokens (`dark:` variants / `useTheme()`) with full keyboard navigation and mobile usability.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/campaign/{index,page}.tsx`, `src/pages/media-package/components/CampaignDraftPanel.tsx`, `src/services/campaignService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/more/{CampaignsScreen,CampaignDetailScreen}.tsx`, `src/services/campaignService.ts`
- **State Coverage:**
  - **Loading / In-Flight:** Skeleton placeholders and disabled action buttons while mutations execute.
  - **Empty / Unconfigured:** Role-specific guidance (e.g., guiding `Manager` to configure package/campaign or informing `Client` that preparation is underway) — never substituting synthetic mock data.
  - **Conflict (`409`):** Preserves unsaved user input/notes in the form/modal and prompts a clean reload of the latest version before re-submitting.
  - **Success:** Immediate TanStack Query invalidation across package, campaign, task, and request caches with localized toast feedback.

## 5. API Contract

- **Endpoints:** `PUT /api/v1/workspaces/{workspaceId}/media-package · GET /api/v1/workspaces/{workspaceId}/campaigns · PATCH /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}`
- **Controllers (`brandhub-business-service`):** `WorkspacePackagePlanningController.save() / retry(), WorkspaceCampaignController.list() / detail() / update()`
- **Services:** `WorkspacePackagePlanningService, MediaCampaignService`
- **Repositories / Stores:** MediaCampaignRepository, WorkspaceMediaPackageRepository, CampaignVersionRepository, TaskMongoRepository

## 6. Error Handling & Edge Cases

- **Deterministic Domain Errors:** `400 VALIDATION_ERROR`, `403 FORBIDDEN`, `409 CAMPAIGN_ALREADY_EXISTS` / `CAMPAIGN_VERSION_CONFLICT`.
- **Retry & Concurrency Safety:** Pessimistic row locks (`PESSIMISTIC_WRITE` on `workspace_media_packages` agreement lock) and optimistic version predicates (`terms_version`, `content_version`, MongoDB `version`) prevent lost updates or duplicate task generation when `Manager` and `Client` act simultaneously.
- **Historical Audit Preservation:** Negotiation events (`package_negotiation_events`), campaign versions (`campaign_versions`), review feedback (`campaign_review_events`), and cancelled/denied requests remain immutable in history views.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend controller/service logic verified by unit & integration tests ([test.md](./test.md)), Web and Mobile UI connected to live endpoints, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent lifecycle transitions handled by sibling FRs in `3.5.1–3.5.13` and Task execution/approval workflows in `3.6.1–3.6.10`.
- **Related Documentation:** [BA Media Package & Campaign Spec](../../../../ba/04-media-package-campaign.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
