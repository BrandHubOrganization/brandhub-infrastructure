> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.5.8 — Approve Media Campaign

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.5.8` |
| **Use Case ID** | `UC-047` |
| **Feature** | Approve Media Campaign |
| **Domain** | Media Package & Media Campaign (`FR 3.5`) |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Business Rules** | `BR-29` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Business Context

Phê duyệt và kích hoạt triển khai Chiến dịch Truyền thông (Approve Media Campaign — /workspaces/:id/campaigns/:campaignId). Ngay khi cả hai bên đồng ý phê duyệt chiến lược, hệ thống chuyển trạng thái chiến dịch sang ACTIVE và tự động đẩy toàn bộ các hạng mục công việc trong Media Campaign vào bảng Task Backlog của Workspace (tương tự Jira Backlog) với tiêu đề và khung thời gian dự kiến để Manager tiếp tục phân rã chi tiết (BR-29).

**Architectural & Workflow Alignment:** Validates Campaign readiness (`startDate`, `endDate`, strategy/brief, deliverable schedule completeness, `BR-29`), records version-matched approval, and deploys the Campaign (`POST /deploy` -> `CampaignStatus.IN_PROGRESS`, locking the Workspace Media Package and activating MongoDB `TaskDocument` execution idempotently via `campaign_deployments`).

## 2. User Story

As an authorized actor (`Owner, Manager, Client`), I want to execute **Approve Media Campaign** with deterministic state validation, version-safe concurrency control, and strict Workspace/Agency isolation, so that commercial deliverables, Campaign schedules, and supplemental requests stay 100% synchronized (`BR-29`).

## 3. Acceptance Criteria

1. **Role & Scope Enforcement:** Only authenticated users holding `Owner, Manager, Client` in the target Agency/Workspace (plus `Guest` solely on public share token view `/api/v1/public/media-packages/{token}` in `3.5.2`) may invoke `POST /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/approve · POST /deploy · GET /deployment · POST /undeploy`; unauthorized requests receive `401` / `403`.
2. **Domain & State Machine Invariants (`BR-29`):** `MediaCampaignService, CampaignDeploymentService, CampaignDeploymentJob` enforces state transition guards, version matching (`expectedTermsVersion` / `expectedVersion`), date boundaries in canonical Workspace timezone (`Asia/Ho_Chi_Minh` default), and snapshot isolation between Agency templates, Workspace packages, Campaigns, and Tasks.
3. **Hybrid Persistence Consistency:** State changes across PostgreSQL `media_campaigns` (`status`: `DRAFT` -> `APPROVED` -> `IN_PROGRESS`), `campaign_deployments`; MongoDB `tasks` return standardized `ApiResponse<T>` envelopes with explicit `ErrorCode` mappings (`400 CAMPAIGN_PLAN_INCOMPLETE`, `403 FORBIDDEN`, `404 CAMPAIGN_NOT_FOUND`, `409 CAMPAIGN_VERSION_CONFLICT` / `DEPLOYMENT_IN_PROGRESS`), leaving zero duplicate Campaigns or duplicate Tasks on retry.
4. **Internationalization (`vi` / `en`):** All labels, status badges, impact confirmation dialogs, empty states, and error messages use key-parallel entries (`campaign.approve.* / campaign.deploy.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded strings.
5. **Semantic Light/Dark Theme & Responsive UX:** Web (`src/pages/campaign/{index,page}.tsx`, `src/pages/campaign/approvalRequirements.ts`, `src/pages/campaign/deploymentErrors.ts`) and Mobile (`src/screens/more/CampaignDetailScreen.tsx`, `src/services/campaignService.ts`) surfaces use semantic theme tokens (`dark:` variants / `useTheme()`) with full keyboard navigation and mobile usability.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/campaign/{index,page}.tsx`, `src/pages/campaign/approvalRequirements.ts`, `src/pages/campaign/deploymentErrors.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/more/CampaignDetailScreen.tsx`, `src/services/campaignService.ts`
- **State Coverage:**
  - **Loading / In-Flight:** Skeleton placeholders and disabled action buttons while mutations execute.
  - **Empty / Unconfigured:** Role-specific guidance (e.g., guiding `Manager` to configure package/campaign or informing `Client` that preparation is underway) — never substituting synthetic mock data.
  - **Conflict (`409`):** Preserves unsaved user input/notes in the form/modal and prompts a clean reload of the latest version before re-submitting.
  - **Success:** Immediate TanStack Query invalidation across package, campaign, task, and request caches with localized toast feedback.

## 5. API Contract

- **Endpoints:** `POST /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/approve · POST /deploy · GET /deployment · POST /undeploy`
- **Controllers (`brandhub-business-service`):** `WorkspaceCampaignController.approve() / deploy() / deployment() / undeploy(), MediaCampaignController.approveCampaign()`
- **Services:** `MediaCampaignService, CampaignDeploymentService, CampaignDeploymentJob`
- **Repositories / Stores:** MediaCampaignRepository, CampaignDeploymentRepository, CampaignReviewEventRepository, TaskMongoRepository

## 6. Error Handling & Edge Cases

- **Deterministic Domain Errors:** `400 CAMPAIGN_PLAN_INCOMPLETE`, `403 FORBIDDEN`, `404 CAMPAIGN_NOT_FOUND`, `409 CAMPAIGN_VERSION_CONFLICT` / `DEPLOYMENT_IN_PROGRESS`.
- **Retry & Concurrency Safety:** Pessimistic row locks (`PESSIMISTIC_WRITE` on `workspace_media_packages` agreement lock) and optimistic version predicates (`terms_version`, `content_version`, MongoDB `version`) prevent lost updates or duplicate task generation when `Manager` and `Client` act simultaneously.
- **Historical Audit Preservation:** Negotiation events (`package_negotiation_events`), campaign versions (`campaign_versions`), review feedback (`campaign_review_events`), and cancelled/denied requests remain immutable in history views.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend controller/service logic verified by unit & integration tests ([test.md](./test.md)), Web and Mobile UI connected to live endpoints, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent lifecycle transitions handled by sibling FRs in `3.5.1–3.5.13` and Task execution/approval workflows in `3.6.1–3.6.10`.
- **Related Documentation:** [BA Media Package & Campaign Spec](../../../../ba/04-media-package-campaign.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
