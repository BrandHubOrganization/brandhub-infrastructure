> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.5.2 — View Template Media Package

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.5.2` |
| **Use Case ID** | `UC-041` |
| **Feature** | View Template Media Package |
| **Domain** | Media Package & Media Campaign (`FR 3.5`) |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Business Rules** | `BR-25` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Business Context

Xem danh sách và chi tiết các gói truyền thông mẫu (View Template Media Package — /workspaces/:id/packages). Giúp Client hình dung rõ quy mô triển khai, thời lượng thuê Agency, cơ cấu nhân sự và số lượng đầu mục công việc theo 3 nhóm hình thức: (1) Gói theo khung thời gian, (2) Gói theo ngân sách cố định, và (3) Gói ủy thác toàn diện theo KPI (BR-25).

**Architectural & Workflow Alignment:** Provides separated server-enforced read models: global templates & Agency catalogue for `Owner`/`Manager`, Workspace recorded package (`WorkspaceMediaPackageResponse` + `/media-package-fit` recommendations) for Workspace participants (`Owner, Manager, Client`), and isolated read-only public preview (`/api/v1/public/media-packages/{token}`) for `Guest` links without leaking internal Workspace data (`BR-25`).

## 2. User Story

As an authorized actor (`Owner, Manager, Client`), I want to execute **View Template Media Package** with deterministic state validation, version-safe concurrency control, and strict Workspace/Agency isolation, so that commercial deliverables, Campaign schedules, and supplemental requests stay 100% synchronized (`BR-25`).

## 3. Acceptance Criteria

1. **Role & Scope Enforcement:** Only authenticated users holding `Owner, Manager, Client` in the target Agency/Workspace (plus `Guest` solely on public share token view `/api/v1/public/media-packages/{token}` in `3.5.2`) may invoke `GET /api/v1/media-package-templates · GET /api/v1/agencies/{agencyId}/media-package-custom · GET /api/v1/workspaces/{workspaceId}/media-packages · GET /api/v1/workspaces/{workspaceId}/media-package · GET /api/v1/public/media-packages/{token}`; unauthorized requests receive `401` / `403`.
2. **Domain & State Machine Invariants (`BR-25`):** `MediaPackageService, MediaPackageShareService, PackageFit` enforces state transition guards, version matching (`expectedTermsVersion` / `expectedVersion`), date boundaries in canonical Workspace timezone (`Asia/Ho_Chi_Minh` default), and snapshot isolation between Agency templates, Workspace packages, Campaigns, and Tasks.
3. **Hybrid Persistence Consistency:** State changes across PostgreSQL `media_packages`, `workspace_media_packages` return standardized `ApiResponse<T>` envelopes with explicit `ErrorCode` mappings (`401 UNAUTHORIZED` (workspace endpoints), `403 FORBIDDEN`, `404 PACKAGE_NOT_SELECTED` / `SHARE_LINK_NOT_FOUND`), leaving zero duplicate Campaigns or duplicate Tasks on retry.
4. **Internationalization (`vi` / `en`):** All labels, status badges, impact confirmation dialogs, empty states, and error messages use key-parallel entries (`mediaPackage.catalog.* / mediaPackage.guest.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded strings.
5. **Semantic Light/Dark Theme & Responsive UX:** Web (`src/pages/media-package/{index,agency,guest}.tsx`, `src/pages/media-package/components/{MediaPackageCatalog,MediaPackageCard,MediaPackageDetail,WorkspacePackageOverview}.tsx`) and Mobile (`src/screens/more/MediaPackageScreen.tsx`, `src/services/mediaPackageService.ts`) surfaces use semantic theme tokens (`dark:` variants / `useTheme()`) with full keyboard navigation and mobile usability.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/media-package/{index,agency,guest}.tsx`, `src/pages/media-package/components/{MediaPackageCatalog,MediaPackageCard,MediaPackageDetail,WorkspacePackageOverview}.tsx`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/more/MediaPackageScreen.tsx`, `src/services/mediaPackageService.ts`
- **State Coverage:**
  - **Loading / In-Flight:** Skeleton placeholders and disabled action buttons while mutations execute.
  - **Empty / Unconfigured:** Role-specific guidance (e.g., guiding `Manager` to configure package/campaign or informing `Client` that preparation is underway) — never substituting synthetic mock data.
  - **Conflict (`409`):** Preserves unsaved user input/notes in the form/modal and prompts a clean reload of the latest version before re-submitting.
  - **Success:** Immediate TanStack Query invalidation across package, campaign, task, and request caches with localized toast feedback.

## 5. API Contract

- **Endpoints:** `GET /api/v1/media-package-templates · GET /api/v1/agencies/{agencyId}/media-package-custom · GET /api/v1/workspaces/{workspaceId}/media-packages · GET /api/v1/workspaces/{workspaceId}/media-package · GET /api/v1/public/media-packages/{token}`
- **Controllers (`brandhub-business-service`):** `MediaPackageController.listTemplates() / listAgencyCustomPackages() / listAvailablePackages() / getWorkspacePackage(), MediaPackageShareController.guest(), ProfileMatchingController.packageFit()`
- **Services:** `MediaPackageService, MediaPackageShareService, PackageFit`
- **Repositories / Stores:** MediaPackageRepository, WorkspaceMediaPackageRepository

## 6. Error Handling & Edge Cases

- **Deterministic Domain Errors:** `401 UNAUTHORIZED` (workspace endpoints), `403 FORBIDDEN`, `404 PACKAGE_NOT_SELECTED` / `SHARE_LINK_NOT_FOUND`.
- **Retry & Concurrency Safety:** Pessimistic row locks (`PESSIMISTIC_WRITE` on `workspace_media_packages` agreement lock) and optimistic version predicates (`terms_version`, `content_version`, MongoDB `version`) prevent lost updates or duplicate task generation when `Manager` and `Client` act simultaneously.
- **Historical Audit Preservation:** Negotiation events (`package_negotiation_events`), campaign versions (`campaign_versions`), review feedback (`campaign_review_events`), and cancelled/denied requests remain immutable in history views.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend controller/service logic verified by unit & integration tests ([test.md](./test.md)), Web and Mobile UI connected to live endpoints, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent lifecycle transitions handled by sibling FRs in `3.5.1–3.5.13` and Task execution/approval workflows in `3.6.1–3.6.10`.
- **Related Documentation:** [BA Media Package & Campaign Spec](../../../../ba/04-media-package-campaign.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
