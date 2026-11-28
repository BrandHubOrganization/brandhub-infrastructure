> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.5.6 — View Media Campaign

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.5.6` |
| **Use Case ID** | `UC-045` |
| **Feature** | View Media Campaign |
| **Domain** | Media Package & Media Campaign (`FR 3.5`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Business Rules** | `BR-27` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Business Context

Xem chi tiết Kế hoạch Chiến dịch Truyền thông (View Media Campaign — /workspaces/:id/campaigns/:campaignId). Hiển thị thông tin tổng quan chiến dịch, gói truyền thông gốc, danh sách toàn bộ các hạng mục công việc dự kiến, lịch sử các phiên bản chỉnh sửa và luồng phản hồi giữa Agency với Client (BR-27).

**Architectural & Workflow Alignment:** Exposes the complete Campaign operational hub to active Workspace members (`Owner, Manager, Creator, Client`): strategy/brief overview, deliverable allocations, interactive timeline view (`/timeline`), version history (`/versions`), Client review events (`/feedback`), and external campaign partner statuses (`/campaign-collaborators`).

## 2. User Story

As an authorized actor (`Owner, Manager, Creator, Client`), I want to execute **View Media Campaign** with deterministic state validation, version-safe concurrency control, and strict Workspace/Agency isolation, so that commercial deliverables, Campaign schedules, and supplemental requests stay 100% synchronized (`BR-27`).

## 3. Acceptance Criteria

1. **Role & Scope Enforcement:** Only authenticated users holding `Owner, Manager, Creator, Client` in the target Agency/Workspace (plus `Guest` solely on public share token view `/api/v1/public/media-packages/{token}` in `3.5.2`) may invoke `GET /api/v1/workspaces/{workspaceId}/campaigns · GET /api/v1/workspaces/{workspaceId}/campaigns/{campaignId} · GET /timeline · GET /versions · GET /feedback · GET /campaign-collaborators`; unauthorized requests receive `401` / `403`.
2. **Domain & State Machine Invariants (`BR-27`):** `MediaCampaignService, CampaignTimelineService, CampaignCollaboratorService` enforces state transition guards, version matching (`expectedTermsVersion` / `expectedVersion`), date boundaries in canonical Workspace timezone (`Asia/Ho_Chi_Minh` default), and snapshot isolation between Agency templates, Workspace packages, Campaigns, and Tasks.
3. **Hybrid Persistence Consistency:** State changes across PostgreSQL `media_campaigns`, `campaign_versions`, `campaign_review_events`, `campaign_collaborators`; MongoDB `tasks` return standardized `ApiResponse<T>` envelopes with explicit `ErrorCode` mappings (`401 UNAUTHORIZED`, `403 WORKSPACE_ACCESS_DENIED` / `FORBIDDEN`, `404 CAMPAIGN_NOT_FOUND`), leaving zero duplicate Campaigns or duplicate Tasks on retry.
4. **Internationalization (`vi` / `en`):** All labels, status badges, impact confirmation dialogs, empty states, and error messages use key-parallel entries (`campaign.detail.* / campaign.timeline.* / campaign.partners.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded strings.
5. **Semantic Light/Dark Theme & Responsive UX:** Web (`src/pages/campaign/{index,page}.tsx`, `src/pages/workspace/components/WorkspaceCampaignSummary.tsx`) and Mobile (`src/screens/more/{CampaignsScreen,CampaignDetailScreen}.tsx`, `src/services/campaignService.ts`) surfaces use semantic theme tokens (`dark:` variants / `useTheme()`) with full keyboard navigation and mobile usability.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/campaign/{index,page}.tsx`, `src/pages/workspace/components/WorkspaceCampaignSummary.tsx`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/more/{CampaignsScreen,CampaignDetailScreen}.tsx`, `src/services/campaignService.ts`
- **State Coverage:**
  - **Loading / In-Flight:** Skeleton placeholders and disabled action buttons while mutations execute.
  - **Empty / Unconfigured:** Role-specific guidance (e.g., guiding `Manager` to configure package/campaign or informing `Client` that preparation is underway) — never substituting synthetic mock data.
  - **Conflict (`409`):** Preserves unsaved user input/notes in the form/modal and prompts a clean reload of the latest version before re-submitting.
  - **Success:** Immediate TanStack Query invalidation across package, campaign, task, and request caches with localized toast feedback.

## 5. API Contract

- **Endpoints:** `GET /api/v1/workspaces/{workspaceId}/campaigns · GET /api/v1/workspaces/{workspaceId}/campaigns/{campaignId} · GET /timeline · GET /versions · GET /feedback · GET /campaign-collaborators`
- **Controllers (`brandhub-business-service`):** `WorkspaceCampaignController.list() / detail() / versions() / feedbackHistory() / tasks(), CampaignTimelineController.read(), CampaignCollaboratorController.list()`
- **Services:** `MediaCampaignService, CampaignTimelineService, CampaignCollaboratorService`
- **Repositories / Stores:** MediaCampaignRepository, CampaignVersionRepository, CampaignReviewEventRepository, CampaignCollaboratorRepository, TaskMongoRepository

## 6. Error Handling & Edge Cases

- **Deterministic Domain Errors:** `401 UNAUTHORIZED`, `403 WORKSPACE_ACCESS_DENIED` / `FORBIDDEN`, `404 CAMPAIGN_NOT_FOUND`.
- **Retry & Concurrency Safety:** Pessimistic row locks (`PESSIMISTIC_WRITE` on `workspace_media_packages` agreement lock) and optimistic version predicates (`terms_version`, `content_version`, MongoDB `version`) prevent lost updates or duplicate task generation when `Manager` and `Client` act simultaneously.
- **Historical Audit Preservation:** Negotiation events (`package_negotiation_events`), campaign versions (`campaign_versions`), review feedback (`campaign_review_events`), and cancelled/denied requests remain immutable in history views.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend controller/service logic verified by unit & integration tests ([test.md](./test.md)), Web and Mobile UI connected to live endpoints, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent lifecycle transitions handled by sibling FRs in `3.5.1–3.5.13` and Task execution/approval workflows in `3.6.1–3.6.10`.
- **Related Documentation:** [BA Media Package & Campaign Spec](../../../../ba/04-media-package-campaign.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
