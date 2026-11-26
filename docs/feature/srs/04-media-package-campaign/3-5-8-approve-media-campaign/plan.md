> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.5.8: Approve Media Campaign

> Implements [spec.md](./spec.md) for canonical roles `Owner, Manager, Client` enforcing `BR-29`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (JWT-protected `/api/v1/**` plus public guest share `/api/v1/public/media-packages/**`), `JwtAuthFilterGatewayFilterFactory.java` |
| **Controllers** | `brandhub-business-service` | `WorkspaceCampaignController.approve() / deploy() / deployment() / undeploy(), MediaCampaignController.approveCampaign()` |
| **Services** | `brandhub-business-service` | `MediaCampaignService, CampaignDeploymentService, CampaignDeploymentJob` |
| **Repositories / Stores** | `brandhub-business-service` | MediaCampaignRepository, CampaignDeploymentRepository, CampaignReviewEventRepository, TaskMongoRepository |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceAccessService.java`, `WorkspaceIsolationHelper.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/campaign/{index,page}.tsx`, `src/pages/campaign/approvalRequirements.ts`, `src/pages/campaign/deploymentErrors.ts` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/more/CampaignDetailScreen.tsx`, `src/services/campaignService.ts` |

## 2. Hybrid PostgreSQL & MongoDB Data Model

- **Data Stores:** PostgreSQL `media_campaigns` (`status`: `DRAFT` -> `APPROVED` -> `IN_PROGRESS`), `campaign_deployments`; MongoDB `tasks`.
- **Schema & Invariant Design:**
  - Validates Campaign readiness (`startDate`, `endDate`, strategy/brief, deliverable schedule completeness, `BR-29`), records version-matched approval, and deploys the Campaign (`POST /deploy` -> `CampaignStatus.IN_PROGRESS`, locking the Workspace Media Package and activating MongoDB `TaskDocument` execution idempotently via `campaign_deployments`).
  - **PostgreSQL Constraints & Indexes:**
    - `media_packages(agency_id, is_available)` + unique `share_token` index for Agency catalogue and O(1) public share resolution.
    - `workspace_media_packages`: `UNIQUE(workspace_id)` agreement row with `final_terms` JSONB snapshot and `terms_version`.
    - `package_negotiation_events`: append-only audit table with `UNIQUE(workspace_media_package_id, terms_version)` and DB immutability trigger.
    - `media_campaigns`: `UNIQUE(workspace_media_package_id)`, `work_items` JSONB, `content_version`, `campaign_versions`, `campaign_review_events`, `campaign_deployments`, and `campaign_collaborators` (`UNIQUE(media_campaign_id, collaborator_id)`).
  - **MongoDB Collections & Indexes (`tasks`, `content_requests`):**
    - `tasks`: scoped by `workspaceId`, indexed on `(workspaceId, campaignId)` and partial unique `(workspaceId, sourceType, sourceRefId)` so package sync and Content Request acceptance never create duplicate Tasks on retry.
    - `content_requests`: indexed on `(workspaceId, status, createdAt)` with atomic `version` field for CAS transitions.

## 3. End-to-End Execution Flow

1. **Client Action:** Actor (`Owner, Manager, Client`) triggers **Approve Media Campaign** on `src/pages/campaign/{index,page}.tsx`, `src/pages/campaign/approvalRequirements.ts`, `src/pages/campaign/deploymentErrors.ts` (Web) or `src/screens/more/CampaignDetailScreen.tsx`, `src/services/campaignService.ts` (Mobile), passing current entity version (`expectedTermsVersion` / `expectedVersion`) where mutating state.
2. **Gateway & Tenant Verification:** API Gateway validates JWT (except public guest share route in `3.5.2`); Business Service re-verifies active Agency ownership or Workspace membership in PostgreSQL.
3. **Rule & Concurrency Check:** `MediaCampaignService, CampaignDeploymentService, CampaignDeploymentJob` acquires agreement/row lock or evaluates MongoDB CAS filter, validates `BR-29` (state transition, deliverable schema, Workspace timezone deadline window), and rejects stale/illegal requests with `400 CAMPAIGN_PLAN_INCOMPLETE`, `403 FORBIDDEN`, `404 CAMPAIGN_NOT_FOUND`, `409 CAMPAIGN_VERSION_CONFLICT` / `DEPLOYMENT_IN_PROGRESS`.
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
| **FR / Feature** | `FR 3.5.8` — Approve Media Campaign |
| **HTTP / WS Endpoints** | `POST /api/v1/workspaces/{workspaceId}/campaigns/{campaignId}/approve · POST /deploy · GET /deployment · POST /undeploy` |
| **Authorized Canonical Roles** | `Owner, Manager, Client` |
| **Controller -> Service** | `WorkspaceCampaignController.approve() / deploy() / deployment() / undeploy(), MediaCampaignController.approveCampaign()` -> `MediaCampaignService, CampaignDeploymentService, CampaignDeploymentJob` |
| **Persistence / Cache Targets** | PostgreSQL `media_campaigns` (`status`: `DRAFT` -> `APPROVED` -> `IN_PROGRESS`), `campaign_deployments`; MongoDB `tasks` |
| **Business Rule Invariants** | `BR-29` |
| **Error Code Contract** | `400 CAMPAIGN_PLAN_INCOMPLETE`, `403 FORBIDDEN`, `404 CAMPAIGN_NOT_FOUND`, `409 CAMPAIGN_VERSION_CONFLICT` / `DEPLOYMENT_IN_PROGRESS` |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/campaign/{index,page}.tsx`, `src/pages/campaign/approvalRequirements.ts`, `src/pages/campaign/deploymentErrors.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/more/CampaignDetailScreen.tsx`, `src/services/campaignService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `campaign.approve.* / campaign.deploy.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/04-media-package-campaign.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
