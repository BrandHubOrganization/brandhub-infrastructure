> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.5.10: Create Content Request

> Implements [spec.md](./spec.md) for canonical roles `Owner, Manager, Client` enforcing `BR-31`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (JWT-protected `/api/v1/**` plus public guest share `/api/v1/public/media-packages/**`), `JwtAuthFilterGatewayFilterFactory.java` |
| **Controllers** | `brandhub-business-service` | `ContentRequestController.create()` |
| **Services** | `brandhub-business-service` | `ContentRequestService / ContentRequestStore` |
| **Repositories / Stores** | `brandhub-business-service` | ContentRequestStore (MongoDB `content_requests`), MediaCampaignRepository, CampaignDeploymentRepository |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceAccessService.java`, `WorkspaceIsolationHelper.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/requests/{WorkspaceRequestPage,index}.tsx`, `src/pages/requests/components/{WorkspaceRequestForm,CreateRequestModal}.tsx`, `src/pages/requests/lib/requestDeadline.ts`, `src/pages/requests/services/workspaceRequestService.ts` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/more/{ContentRequestsScreen,ContentRequestFormScreen}.tsx`, `src/services/contentRequestService.ts` |

## 2. Hybrid PostgreSQL & MongoDB Data Model

- **Data Stores:** MongoDB `content_requests` (`ContentRequestDocument`); PostgreSQL `media_campaigns`, `campaign_deployments`.
- **Schema & Invariant Design:**
  - Allows an active Workspace `Client` (and authorized `Owner`/`Manager` per workspace policy) to submit supplemental out-of-package requests (`POST|SHORT_VIDEO|SURVEY|EVENT_PLAN|PRESS_RECOMMENDATION`) in `PENDING` state (`BR-31`), enforcing server-side that the Workspace has an `IN_PROGRESS` Campaign with `SUCCEEDED` deployment and `dueDate` within `[max(today_in_workspace_tz, campaign.startDate), campaign.endDate]`.
  - **PostgreSQL Constraints & Indexes:**
    - `media_packages(agency_id, is_available)` + unique `share_token` index for Agency catalogue and O(1) public share resolution.
    - `workspace_media_packages`: `UNIQUE(workspace_id)` agreement row with `final_terms` JSONB snapshot and `terms_version`.
    - `package_negotiation_events`: append-only audit table with `UNIQUE(workspace_media_package_id, terms_version)` and DB immutability trigger.
    - `media_campaigns`: `UNIQUE(workspace_media_package_id)`, `work_items` JSONB, `content_version`, `campaign_versions`, `campaign_review_events`, `campaign_deployments`, and `campaign_collaborators` (`UNIQUE(media_campaign_id, collaborator_id)`).
  - **MongoDB Collections & Indexes (`tasks`, `content_requests`):**
    - `tasks`: scoped by `workspaceId`, indexed on `(workspaceId, campaignId)` and partial unique `(workspaceId, sourceType, sourceRefId)` so package sync and Content Request acceptance never create duplicate Tasks on retry.
    - `content_requests`: indexed on `(workspaceId, status, createdAt)` with atomic `version` field for CAS transitions.

## 3. End-to-End Execution Flow

1. **Client Action:** Actor (`Owner, Manager, Client`) triggers **Create Content Request** on `src/pages/requests/{WorkspaceRequestPage,index}.tsx`, `src/pages/requests/components/{WorkspaceRequestForm,CreateRequestModal}.tsx`, `src/pages/requests/lib/requestDeadline.ts`, `src/pages/requests/services/workspaceRequestService.ts` (Web) or `src/screens/more/{ContentRequestsScreen,ContentRequestFormScreen}.tsx`, `src/services/contentRequestService.ts` (Mobile), passing current entity version (`expectedTermsVersion` / `expectedVersion`) where mutating state.
2. **Gateway & Tenant Verification:** API Gateway validates JWT (except public guest share route in `3.5.2`); Business Service re-verifies active Agency ownership or Workspace membership in PostgreSQL.
3. **Rule & Concurrency Check:** `ContentRequestService / ContentRequestStore` acquires agreement/row lock or evaluates MongoDB CAS filter, validates `BR-31` (state transition, deliverable schema, Workspace timezone deadline window), and rejects stale/illegal requests with `400 VALIDATION_ERROR` / `INVALID_DUE_DATE`, `403 FORBIDDEN`, `409 CAMPAIGN_NOT_DEPLOYED` / `CAMPAIGN_COMPLETED` (`BR-31`).
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
| **FR / Feature** | `FR 3.5.10` — Create Content Request |
| **HTTP / WS Endpoints** | `POST /api/v1/workspaces/{workspaceId}/content-requests` |
| **Authorized Canonical Roles** | `Owner, Manager, Client` |
| **Controller -> Service** | `ContentRequestController.create()` -> `ContentRequestService / ContentRequestStore` |
| **Persistence / Cache Targets** | MongoDB `content_requests` (`ContentRequestDocument`); PostgreSQL `media_campaigns`, `campaign_deployments` |
| **Business Rule Invariants** | `BR-31` |
| **Error Code Contract** | `400 VALIDATION_ERROR` / `INVALID_DUE_DATE`, `403 FORBIDDEN`, `409 CAMPAIGN_NOT_DEPLOYED` / `CAMPAIGN_COMPLETED` (`BR-31`) |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/requests/{WorkspaceRequestPage,index}.tsx`, `src/pages/requests/components/{WorkspaceRequestForm,CreateRequestModal}.tsx`, `src/pages/requests/lib/requestDeadline.ts`, `src/pages/requests/services/workspaceRequestService.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/more/{ContentRequestsScreen,ContentRequestFormScreen}.tsx`, `src/services/contentRequestService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `requests.v2.* / requests.create.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/04-media-package-campaign.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
