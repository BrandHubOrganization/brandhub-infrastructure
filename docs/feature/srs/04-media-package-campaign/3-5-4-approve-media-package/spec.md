> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.5.4 — Approve Media Package

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.5.4` |
| **Use Case ID** | `UC-043` |
| **Feature** | Approve Media Package |
| **Domain** | Media Package & Media Campaign (`FR 3.5`) |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Business Rules** | `BR-26` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Business Context

Phê duyệt chốt gói truyền thông (Approve Media Package — /workspaces/:id/packages/:packageId). Khi cả hai bên (Agency và Client) đồng thuận xác nhận toàn bộ các điều khoản, chi phí và hạng mục bàn giao của gói truyền thông, hệ thống khóa phiên bản gói ở trạng thái APPROVED làm căn cứ lập chiến dịch truyền thông chi tiết (BR-26).

**Architectural & Workflow Alignment:** Finalizes the Workspace `WorkspaceMediaPackage` snapshot (`BR-26`): in the Manager-led workflow, saving a valid Workspace package (`PUT /media-package`) immediately finalizes `APPROVED` workspace terms and provisions the `DRAFT` Campaign without blocking on a separate Client button click, while `POST /media-package/approve` (`PESSIMISTIC_WRITE` + `expectedTermsVersion`) remains supported and backward-compatible for two-party versioned confirmation and audit history.

## 2. User Story

As an authorized actor (`Owner, Manager, Client`), I want to execute **Approve Media Package** with deterministic state validation, version-safe concurrency control, and strict Workspace/Agency isolation, so that commercial deliverables, Campaign schedules, and supplemental requests stay 100% synchronized (`BR-26`).

## 3. Acceptance Criteria

1. **Role & Scope Enforcement:** Only authenticated users holding `Owner, Manager, Client` in the target Agency/Workspace (plus `Guest` solely on public share token view `/api/v1/public/media-packages/{token}` in `3.5.2`) may invoke `POST /api/v1/workspaces/{workspaceId}/media-package/approve · PUT /api/v1/workspaces/{workspaceId}/media-package · GET /api/v1/workspaces/{workspaceId}/media-package/preparation`; unauthorized requests receive `401` / `403`.
2. **Domain & State Machine Invariants (`BR-26`):** `MediaPackageService.approvePackage(), WorkspacePackagePlanningService` enforces state transition guards, version matching (`expectedTermsVersion` / `expectedVersion`), date boundaries in canonical Workspace timezone (`Asia/Ho_Chi_Minh` default), and snapshot isolation between Agency templates, Workspace packages, Campaigns, and Tasks.
3. **Hybrid Persistence Consistency:** State changes across PostgreSQL `workspace_media_packages` (`negotiation_status`, `terms_version`, `agency_approved_at`, `client_approved_at`, `final_terms`), `package_negotiation_events` return standardized `ApiResponse<T>` envelopes with explicit `ErrorCode` mappings (`400 VALIDATION_ERROR`, `403 FORBIDDEN`, `404 PACKAGE_NOT_SELECTED`, `409 TERMS_VERSION_CONFLICT`), leaving zero duplicate Campaigns or duplicate Tasks on retry.
4. **Internationalization (`vi` / `en`):** All labels, status badges, impact confirmation dialogs, empty states, and error messages use key-parallel entries (`mediaPackage.approve.* / mediaPackage.status.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded strings.
5. **Semantic Light/Dark Theme & Responsive UX:** Web (`src/pages/media-package/index.tsx`, `src/pages/media-package/components/{SelectedMediaPackage,WorkspacePackageOverview,CampaignDraftPanel}.tsx`) and Mobile (`src/screens/more/MediaPackageScreen.tsx`, `src/services/mediaPackageService.ts`) surfaces use semantic theme tokens (`dark:` variants / `useTheme()`) with full keyboard navigation and mobile usability.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/media-package/index.tsx`, `src/pages/media-package/components/{SelectedMediaPackage,WorkspacePackageOverview,CampaignDraftPanel}.tsx`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/more/MediaPackageScreen.tsx`, `src/services/mediaPackageService.ts`
- **State Coverage:**
  - **Loading / In-Flight:** Skeleton placeholders and disabled action buttons while mutations execute.
  - **Empty / Unconfigured:** Role-specific guidance (e.g., guiding `Manager` to configure package/campaign or informing `Client` that preparation is underway) — never substituting synthetic mock data.
  - **Conflict (`409`):** Preserves unsaved user input/notes in the form/modal and prompts a clean reload of the latest version before re-submitting.
  - **Success:** Immediate TanStack Query invalidation across package, campaign, task, and request caches with localized toast feedback.

## 5. API Contract

- **Endpoints:** `POST /api/v1/workspaces/{workspaceId}/media-package/approve · PUT /api/v1/workspaces/{workspaceId}/media-package · GET /api/v1/workspaces/{workspaceId}/media-package/preparation`
- **Controllers (`brandhub-business-service`):** `MediaPackageController.approvePackage(), WorkspacePackagePlanningController.save() / status()`
- **Services:** `MediaPackageService.approvePackage(), WorkspacePackagePlanningService`
- **Repositories / Stores:** WorkspaceMediaPackageRepository, PackageNegotiationEventRepository, MediaCampaignRepository

## 6. Error Handling & Edge Cases

- **Deterministic Domain Errors:** `400 VALIDATION_ERROR`, `403 FORBIDDEN`, `404 PACKAGE_NOT_SELECTED`, `409 TERMS_VERSION_CONFLICT`.
- **Retry & Concurrency Safety:** Pessimistic row locks (`PESSIMISTIC_WRITE` on `workspace_media_packages` agreement lock) and optimistic version predicates (`terms_version`, `content_version`, MongoDB `version`) prevent lost updates or duplicate task generation when `Manager` and `Client` act simultaneously.
- **Historical Audit Preservation:** Negotiation events (`package_negotiation_events`), campaign versions (`campaign_versions`), review feedback (`campaign_review_events`), and cancelled/denied requests remain immutable in history views.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend controller/service logic verified by unit & integration tests ([test.md](./test.md)), Web and Mobile UI connected to live endpoints, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent lifecycle transitions handled by sibling FRs in `3.5.1–3.5.13` and Task execution/approval workflows in `3.6.1–3.6.10`.
- **Related Documentation:** [BA Media Package & Campaign Spec](../../../../ba/04-media-package-campaign.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
