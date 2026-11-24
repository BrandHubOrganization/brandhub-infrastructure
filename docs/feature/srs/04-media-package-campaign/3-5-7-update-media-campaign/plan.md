> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.5.7: Update Media Campaign

> Implements [spec.md](./spec.md) for canonical roles `Owner, Manager, Client` enforcing `BR-27`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (JWT-protected `/api/v1/**` plus public guest share `/api/v1/public/media-packages/**`), `JwtAuthFilterGatewayFilterFactory.java` |
| **Controllers** | `brandhub-business-service` | `WorkspaceCampaignController.update() / updateBrief() / feedback(), CampaignTimelineController.schedule() / createOutOfScopeTask() / reorderTasks(), CampaignCollaboratorController.assign() / update() / unlink()` |
| **Services** | `brandhub-business-service` | `MediaCampaignService, CampaignTimelineService, CampaignCollaboratorService` |
| **Repositories / Stores** | `brandhub-business-service` | MediaCampaignRepository, CampaignVersionRepository, CampaignReviewEventRepository, CampaignCollaboratorRepository |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceAccessService.java`, `WorkspaceIsolationHelper.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/campaign/{index,page}.tsx`, `src/pages/campaign/components/{CampaignBriefChipGroup,CampaignBriefFormatSections}.tsx` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/more/CampaignDetailScreen.tsx`, `src/services/campaignService.ts` |

## 2. Hybrid PostgreSQL & MongoDB Data Model

- **Data Stores:** PostgreSQL `media_campaigns` (`content_version`), `campaign_versions`, `campaign_review_events`, `campaign_collaborators`; MongoDB `tasks`.
- **Schema & Invariant Design:**
  - Enforces optimistic concurrency (`expectedVersion` -> `content_version + 1` with `CampaignVersion` snapshot on `Owner`/`Manager` plan & brief edits, `BR-27`), allows `Client` to submit structured review feedback (`POST /feedback` -> `CampaignReviewEvent`) without mutating package terms, and supports timeline task scheduling plus third-party partner status updates (`CONTACTED`, `NEGOTIATING`, `CONFIRMED`, `LIVE`).
  - **PostgreSQL Constraints & Indexes:**
    - `media_packages(agency_id, is_available)` + unique `share_token` index for Agency catalogue and O(1) public share resolution.
    - `workspace_media_packages`: `UNIQUE(workspace_id)` agreement row with `final_terms` JSONB snapshot and `terms_version`.
    - `package_negotiation_events`: append-only audit table with `UNIQUE(workspace_media_package_id, terms_version)` and DB immutability trigger.
    - `media_campaigns`: `UNIQUE(workspace_media_package_id)`, `work_items` JSONB, `content_version`, `campaign_versions`, `campaign_review_events`, `campaign_deployments`, and `campaign_collaborators` (`UNIQUE(media_campaign_id, collaborator_id)`).
  - **MongoDB Collections & Indexes (`tasks`, `content_requests`):**
    - `tasks`: scoped by `workspaceId`, indexed on `(workspaceId, campaignId)` and partial unique `(workspaceId, sourceType, sourceRefId)` so package sync and Content Request acceptance never create duplicate Tasks on retry.
    - `content_requests`: indexed on `(workspaceId, status, createdAt)` with atomic `version` field for CAS transitions.

## 3. End-to-End Execution Flow

1. **Client Action:** Actor (`Owner, Manager, Client`) triggers **Update Media Campaign** on `src/pages/campaign/{index,page}.tsx`, `src/pages/campaign/components/{CampaignBriefChipGroup,CampaignBriefFormatSections}.tsx` (Web) or `src/screens/more/CampaignDetailScreen.tsx`, `src/services/campaignService.ts` (Mobile), passing current entity version (`expectedTermsVersion` / `expectedVersion`) where mutating state.
2. **Gateway & Tenant Verification:** API Gateway validates JWT (except public guest share route in `3.5.2`); Business Service re-verifies active Agency ownership or Workspace membership in PostgreSQL.
3. **Rule & Concurrency Check:** `MediaCampaignService, CampaignTimelineService, CampaignCollaboratorService` acquires agreement/row lock or evaluates MongoDB CAS filter, validates `BR-27` (state transition, deliverable schema, Workspace timezone deadline window), and rejects stale/illegal requests with `400 VALIDATION_ERROR`, `403 FORBIDDEN`, `404 CAMPAIGN_NOT_FOUND`, `409 CAMPAIGN_VERSION_CONFLICT` / `CAMPAIGN_LOCKED`.
4. **Persistence & Cross-Store Coordination:** Commits PostgreSQL/MongoDB state updates atomically per store boundary (using explicit deployment/preparation status tracking and idempotent retry keys where PostgreSQL Campaign plans materialize MongoDB Tasks).
5. **UI Refresh:** Returns `ApiResponse<T>`; client invalidates relevant query keys (`media-package`, `campaigns`, `tasks`, `content-requests`) and updates UI without losing unsaved draft text on `409`.

## 4. Security, Concurrency & Failure Recovery

- **Strict Public vs Internal Separation:** Guest package share links (`GET /api/v1/public/media-packages/{token}`) project only sanitized `PublicMediaPackageResponse` fields and never expose `workspaceId`, `ClientProfile`, Campaign tasks, or comments.
- **Idempotent Retry Semantics:** Package preparation (`/media-package/preparation/retry`), Campaign deployment (`/deploy`), and Content Request acceptance (`/accept`) use deterministic source keys so network retries converge to the exact same Campaign/Task records.
- **Conflict Safety:** `409` responses never auto-retry over newer versions; the user inspects updated terms/plan before confirming again.

## 5. Cross-References

- **Lifecycle Artefacts:** [spec.md](./spec.md) · [task.md](./task.md) · [test.md](./test.md)
- **BA & Module References:** [04-media-package-campaign.md](../../../../ba/04-media-package-campaign.md) · [12-state-machines.md](../../../../ba/12-state-machines.md) · [Module Specs Index](../../../modules/README.md)

## Endpoint, Authorization & Error Mapping Matrix

| Aspect | Specification |
| :--- | :--- |
| **FR / Feature** | `FR 3.5.7` — Update Media Campaign |
| **HTTP / WS Endpoints** | `PATCH /api/v1/workspaces/{workspaceId}/campaigns/{campaignId} · PATCH /brief · POST /feedback · PATCH /tasks/{taskId}/schedule · POST|PUT|DELETE /campaigns/{campaignId}/collaborators` |
| **Authorized Canonical Roles** | `Owner, Manager, Client` |
| **Controller -> Service** | `WorkspaceCampaignController.update() / updateBrief() / feedback(), CampaignTimelineController.schedule() / createOutOfScopeTask() / reorderTasks(), CampaignCollaboratorController.assign() / update() / unlink()` -> `MediaCampaignService, CampaignTimelineService, CampaignCollaboratorService` |
| **Persistence / Cache Targets** | PostgreSQL `media_campaigns` (`content_version`), `campaign_versions`, `campaign_review_events`, `campaign_collaborators`; MongoDB `tasks` |
| **Business Rule Invariants** | `BR-27` |
| **Error Code Contract** | `400 VALIDATION_ERROR`, `403 FORBIDDEN`, `404 CAMPAIGN_NOT_FOUND`, `409 CAMPAIGN_VERSION_CONFLICT` / `CAMPAIGN_LOCKED` |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/campaign/{index,page}.tsx`, `src/pages/campaign/components/{CampaignBriefChipGroup,CampaignBriefFormatSections}.tsx`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/more/CampaignDetailScreen.tsx`, `src/services/campaignService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `campaign.edit.* / campaign.brief.* / campaign.feedback.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/04-media-package-campaign.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
