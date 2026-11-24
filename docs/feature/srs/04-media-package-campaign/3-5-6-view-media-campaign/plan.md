> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.5.6: View Media Campaign

> Implements [spec.md](./spec.md) for canonical roles `Owner, Manager, Creator, Client` enforcing `BR-27`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (JWT-protected `/api/v1/**` plus public guest share `/api/v1/public/media-packages/**`), `JwtAuthFilterGatewayFilterFactory.java` |
| **Controllers** | `brandhub-business-service` | `WorkspaceCampaignController.list() / detail() / versions() / feedbackHistory() / tasks(), CampaignTimelineController.read(), CampaignCollaboratorController.list()` |
| **Services** | `brandhub-business-service` | `MediaCampaignService, CampaignTimelineService, CampaignCollaboratorService` |
| **Repositories / Stores** | `brandhub-business-service` | MediaCampaignRepository, CampaignVersionRepository, CampaignReviewEventRepository, CampaignCollaboratorRepository, TaskMongoRepository |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceAccessService.java`, `WorkspaceIsolationHelper.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/campaign/{index,page}.tsx`, `src/pages/workspace/components/WorkspaceCampaignSummary.tsx` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/more/{CampaignsScreen,CampaignDetailScreen}.tsx`, `src/services/campaignService.ts` |

## 2. Hybrid PostgreSQL & MongoDB Data Model

- **Data Stores:** PostgreSQL `media_campaigns`, `campaign_versions`, `campaign_review_events`, `campaign_collaborators`; MongoDB `tasks`.
- **Schema & Invariant Design:**
  - Exposes the complete Campaign operational hub to active Workspace members (`Owner, Manager, Creator, Client`): strategy/brief overview, deliverable allocations, interactive timeline view (`/timeline`), version history (`/versions`), Client review events (`/feedback`), and external campaign partner statuses (`/campaign-collaborators`).
  - **PostgreSQL Constraints & Indexes:**
    - `media_packages(agency_id, is_available)` + unique `share_token` index for Agency catalogue and O(1) public share resolution.
    - `workspace_media_packages`: `UNIQUE(workspace_id)` agreement row with `final_terms` JSONB snapshot and `terms_version`.
    - `package_negotiation_events`: append-only audit table with `UNIQUE(workspace_media_package_id, terms_version)` and DB immutability trigger.
    - `media_campaigns`: `UNIQUE(workspace_media_package_id)`, `work_items` JSONB, `content_version`, `campaign_versions`, `campaign_review_events`, `campaign_deployments`, and `campaign_collaborators` (`UNIQUE(media_campaign_id, collaborator_id)`).
  - **MongoDB Collections & Indexes (`tasks`, `content_requests`):**
    - `tasks`: scoped by `workspaceId`, indexed on `(workspaceId, campaignId)` and partial unique `(workspaceId, sourceType, sourceRefId)` so package sync and Content Request acceptance never create duplicate Tasks on retry.
    - `content_requests`: indexed on `(workspaceId, status, createdAt)` with atomic `version` field for CAS transitions.

## 3. End-to-End Execution Flow

1. **Client Action:** Actor (`Owner, Manager, Creator, Client`) triggers **View Media Campaign** on `src/pages/campaign/{index,page}.tsx`, `src/pages/workspace/components/WorkspaceCampaignSummary.tsx` (Web) or `src/screens/more/{CampaignsScreen,CampaignDetailScreen}.tsx`, `src/services/campaignService.ts` (Mobile), passing current entity version (`expectedTermsVersion` / `expectedVersion`) where mutating state.
2. **Gateway & Tenant Verification:** API Gateway validates JWT (except public guest share route in `3.5.2`); Business Service re-verifies active Agency ownership or Workspace membership in PostgreSQL.
3. **Rule & Concurrency Check:** `MediaCampaignService, CampaignTimelineService, CampaignCollaboratorService` acquires agreement/row lock or evaluates MongoDB CAS filter, validates `BR-27` (state transition, deliverable schema, Workspace timezone deadline window), and rejects stale/illegal requests with `401 UNAUTHORIZED`, `403 WORKSPACE_ACCESS_DENIED` / `FORBIDDEN`, `404 CAMPAIGN_NOT_FOUND`.
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
| **FR / Feature** | `FR 3.5.6` — View Media Campaign |
| **HTTP / WS Endpoints** | `GET /api/v1/workspaces/{workspaceId}/campaigns · GET /api/v1/workspaces/{workspaceId}/campaigns/{campaignId} · GET /timeline · GET /versions · GET /feedback · GET /campaign-collaborators` |
| **Authorized Canonical Roles** | `Owner, Manager, Creator, Client` |
| **Controller -> Service** | `WorkspaceCampaignController.list() / detail() / versions() / feedbackHistory() / tasks(), CampaignTimelineController.read(), CampaignCollaboratorController.list()` -> `MediaCampaignService, CampaignTimelineService, CampaignCollaboratorService` |
| **Persistence / Cache Targets** | PostgreSQL `media_campaigns`, `campaign_versions`, `campaign_review_events`, `campaign_collaborators`; MongoDB `tasks` |
| **Business Rule Invariants** | `BR-27` |
| **Error Code Contract** | `401 UNAUTHORIZED`, `403 WORKSPACE_ACCESS_DENIED` / `FORBIDDEN`, `404 CAMPAIGN_NOT_FOUND` |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/campaign/{index,page}.tsx`, `src/pages/workspace/components/WorkspaceCampaignSummary.tsx`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/more/{CampaignsScreen,CampaignDetailScreen}.tsx`, `src/services/campaignService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `campaign.detail.* / campaign.timeline.* / campaign.partners.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/04-media-package-campaign.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
