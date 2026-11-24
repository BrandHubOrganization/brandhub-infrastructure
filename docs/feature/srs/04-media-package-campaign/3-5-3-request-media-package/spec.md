> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.5.3 — Request Media Package

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.5.3` |
| **Use Case ID** | `UC-042` |
| **Feature** | Request Media Package |
| **Domain** | Media Package & Media Campaign (`FR 3.5`) |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Business Rules** | `BR-26` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Business Context

Đề xuất và đàm phán điều chỉnh gói truyền thông (Request Media Package — /workspaces/:id/packages/:packageId). Từ gói mẫu ban đầu, Client và Agency (Owner/Manager) trao đổi, đề xuất chỉnh sửa về mức giá, thời gian triển khai, số lượng bài đăng, sự kiện hoặc hình thức truyền thông qua từng vòng đàm phán cho đến khi hai bên thống nhất phương án cuối cùng (BR-26).

**Architectural & Workflow Alignment:** Supports Manager-led Workspace package recording & pre-deployment deliverable updates (`PUT /workspaces/{workspaceId}/media-package` with safe Campaign/Task impact preview via `/impact` and idempotent `/preparation/retry`) while preserving optimistic-locked negotiation history (`expectedTermsVersion`, immutable `package_negotiation_events`, `BR-26`).

## 2. User Story

As an authorized actor (`Owner, Manager, Client`), I want to execute **Request Media Package** with deterministic state validation, version-safe concurrency control, and strict Workspace/Agency isolation, so that commercial deliverables, Campaign schedules, and supplemental requests stay 100% synchronized (`BR-26`).

## 3. Acceptance Criteria

1. **Role & Scope Enforcement:** Only authenticated users holding `Owner, Manager, Client` in the target Agency/Workspace (plus `Guest` solely on public share token view `/api/v1/public/media-packages/{token}` in `3.5.2`) may invoke `PUT /api/v1/workspaces/{workspaceId}/media-package · POST /api/v1/workspaces/{workspaceId}/media-package/impact · POST /api/v1/workspaces/{workspaceId}/media-package · PATCH /api/v1/workspaces/{workspaceId}/media-package/negotiate · GET /api/v1/workspaces/{workspaceId}/media-package/history`; unauthorized requests receive `401` / `403`.
2. **Domain & State Machine Invariants (`BR-26`):** `WorkspacePackagePlanningService, MediaPackageService, PackageNegotiationHistoryService, PackageNegotiationWriter` enforces state transition guards, version matching (`expectedTermsVersion` / `expectedVersion`), date boundaries in canonical Workspace timezone (`Asia/Ho_Chi_Minh` default), and snapshot isolation between Agency templates, Workspace packages, Campaigns, and Tasks.
3. **Hybrid Persistence Consistency:** State changes across PostgreSQL `workspace_media_packages` (`final_terms` JSONB, `terms_version`), `package_negotiation_events` (append-only); MongoDB `tasks` return standardized `ApiResponse<T>` envelopes with explicit `ErrorCode` mappings (`400 VALIDATION_ERROR`, `403 FORBIDDEN`, `404 PACKAGE_NOT_FOUND`, `409 TERMS_VERSION_CONFLICT` / `PACKAGE_LOCKED_AFTER_DEPLOY`), leaving zero duplicate Campaigns or duplicate Tasks on retry.
4. **Internationalization (`vi` / `en`):** All labels, status badges, impact confirmation dialogs, empty states, and error messages use key-parallel entries (`mediaPackage.planning.* / mediaPackage.negotiate.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded strings.
5. **Semantic Light/Dark Theme & Responsive UX:** Web (`src/pages/media-package/index.tsx`, `src/pages/media-package/components/{NegotiateTermsForm,PackageImpactDialog,PackageNegotiationHistory,PackageTermsDiff,SelectedMediaPackage}.tsx`) and Mobile (`src/screens/more/MediaPackageScreen.tsx`, `src/services/mediaPackageService.ts`) surfaces use semantic theme tokens (`dark:` variants / `useTheme()`) with full keyboard navigation and mobile usability.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/media-package/index.tsx`, `src/pages/media-package/components/{NegotiateTermsForm,PackageImpactDialog,PackageNegotiationHistory,PackageTermsDiff,SelectedMediaPackage}.tsx`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/more/MediaPackageScreen.tsx`, `src/services/mediaPackageService.ts`
- **State Coverage:**
  - **Loading / In-Flight:** Skeleton placeholders and disabled action buttons while mutations execute.
  - **Empty / Unconfigured:** Role-specific guidance (e.g., guiding `Manager` to configure package/campaign or informing `Client` that preparation is underway) — never substituting synthetic mock data.
  - **Conflict (`409`):** Preserves unsaved user input/notes in the form/modal and prompts a clean reload of the latest version before re-submitting.
  - **Success:** Immediate TanStack Query invalidation across package, campaign, task, and request caches with localized toast feedback.

## 5. API Contract

- **Endpoints:** `PUT /api/v1/workspaces/{workspaceId}/media-package · POST /api/v1/workspaces/{workspaceId}/media-package/impact · POST /api/v1/workspaces/{workspaceId}/media-package · PATCH /api/v1/workspaces/{workspaceId}/media-package/negotiate · GET /api/v1/workspaces/{workspaceId}/media-package/history`
- **Controllers (`brandhub-business-service`):** `WorkspacePackagePlanningController.save() / impact() / status() / retry(), MediaPackageController.selectPackage() / negotiateTerms(), PackageNegotiationHistoryController.list()`
- **Services:** `WorkspacePackagePlanningService, MediaPackageService, PackageNegotiationHistoryService, PackageNegotiationWriter`
- **Repositories / Stores:** WorkspaceMediaPackageRepository, MediaPackageRepository, PackageNegotiationEventRepository, MediaCampaignRepository, TaskMongoRepository

## 6. Error Handling & Edge Cases

- **Deterministic Domain Errors:** `400 VALIDATION_ERROR`, `403 FORBIDDEN`, `404 PACKAGE_NOT_FOUND`, `409 TERMS_VERSION_CONFLICT` / `PACKAGE_LOCKED_AFTER_DEPLOY`.
- **Retry & Concurrency Safety:** Pessimistic row locks (`PESSIMISTIC_WRITE` on `workspace_media_packages` agreement lock) and optimistic version predicates (`terms_version`, `content_version`, MongoDB `version`) prevent lost updates or duplicate task generation when `Manager` and `Client` act simultaneously.
- **Historical Audit Preservation:** Negotiation events (`package_negotiation_events`), campaign versions (`campaign_versions`), review feedback (`campaign_review_events`), and cancelled/denied requests remain immutable in history views.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend controller/service logic verified by unit & integration tests ([test.md](./test.md)), Web and Mobile UI connected to live endpoints, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent lifecycle transitions handled by sibling FRs in `3.5.1–3.5.13` and Task execution/approval workflows in `3.6.1–3.6.10`.
- **Related Documentation:** [BA Media Package & Campaign Spec](../../../../ba/04-media-package-campaign.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
