> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.4.5: Update Agency Profile

> Implements [spec.md](./spec.md) for canonical roles `Owner` enforcing `BR-15`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `JwtAuthFilterGatewayFilterFactory.java`, `InboundSecurityWebFilter.java`, `GatewayConfig.java` (`/api/v1/**`) |
| **Controller** | `brandhub-business-service` | `AgencyController.updateAgency() / uploadLogo() / uploadBanner()` |
| **Service** | `brandhub-business-service` | `AgencyServiceImpl.updateAgency() / uploadLogo() / uploadBanner(), S3FileStorageServiceImpl` |
| **Repositories** | `brandhub-business-service` | AgencyRepository, AuditLogRepository |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceIsolationHelper.java`, `WorkspaceAccessService.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/agency/detail.tsx`, `src/pages/agency/components/{AgencyDetailEditForm,AgencyDetailLivePreview,AgencyBrandingSection}.tsx`, `src/components/shared/BannerUploader.tsx` |
| **Mobile App** | `brandhub-mobile-app` | `src/services/agencyService.ts` |

## 2. Data Model, Schema & Indexes

- **Primary Stores:** PostgreSQL `agencies`, `audit_logs`; AWS S3 (`agencies/logos/`, `agencies/banners/`).
- **Key Architectural Details:**
  - Strictly enforces `agency.ownerId.equals(currentUser.id)` (`BR-15`), updates metadata fields (`name`, `description`, `website`, `industry`, `companyType`, `companySize`, `taxCode`, `address`, `phone`, `contactEmail`), and handles validated S3 logo/banner uploads.
  - **Multi-Tenant Indexing:** Foreign-key and composite lookup indexes on `agencies(owner_id, status)`, `agency_members(agency_id, user_id)`, `workspaces(agency_id, status)`, `workspace_members(workspace_id, user_id, is_active)`, and `workspace_invitations` / `agency_invitations(token, status, expires_at)` ensure single-digit millisecond ACL and listing queries.
  - **Canonical Timezone Source:** Workspace timezone reads/writes use `workspaces.timezone_config` (default `Asia/Ho_Chi_Minh`) mirrored cleanly in `WorkspaceResponse.settings.timezone`.

## 3. End-to-End Execution Flow

1. **Client Invocation:** Authorized actor (`Owner`) initiates **Update Agency Profile** from `src/pages/agency/detail.tsx`, `src/pages/agency/components/{AgencyDetailEditForm,AgencyDetailLivePreview,AgencyBrandingSection}.tsx`, `src/components/shared/BannerUploader.tsx` (Web) or `src/services/agencyService.ts` (Mobile).
2. **Gateway & Principal Resolution:** `brandhub-api-gateway` validates Bearer JWT signature and Redis blacklist status (`jwt:blacklist:{jti}`), forwarding `X-Request-Id` and principal headers to `brandhub-business-service`.
3. **Authorization & Business Rule Validation:** `AgencyController.updateAgency() / uploadLogo() / uploadBanner()` validates DTO constraints (`@Valid`) and delegates to `AgencyServiceImpl.updateAgency() / uploadLogo() / uploadBanner(), S3FileStorageServiceImpl`, which verifies live DB role/ownership (`Owner`) and domain rules (`BR-15`).
4. **Atomic Persistence / Aggregation:** Executes `@Transactional` queries/updates across PostgreSQL `agencies`, `audit_logs`; AWS S3 (`agencies/logos/`, `agencies/banners/`), mapping domain violations deterministically to `400 VALIDATION_ERROR` / `INVALID_FILE_TYPE` / `FILE_TOO_LARGE`, `403 FORBIDDEN` (`BR-15`), `404 AGENCY_NOT_FOUND`.
5. **Client State Synchronization:** Returns `ApiResponse<T>`; frontend invalidates scoped TanStack Query keys (`agency` / `workspaces` / `dashboard`), updates Zustand active org/workspace context when applicable, and renders localized (`agency.detail.* / agency.edit.*`) feedback.

## 4. Security, Concurrency & Operational Guards

- **Zero Client-Trusted Role Claims:** Every Workspace/Agency check re-queries PostgreSQL (`agency.ownerId` or active `workspace_members` row via `@RequireRoleAspect` / `WorkspaceAccessService`) so revoked members lose access immediately without waiting for JWT expiry.
- **Race-Condition Protection:** Database uniqueness constraints (`UNIQUE(agency_id, user_id)`, active single-Manager check, idempotent `duplication_request_id`, and atomic invitation status transitions) prevent duplicate records on double-clicks or concurrent admin actions.
- **No Mock Fallback in Production:** Empty lists and backend errors render explicit localized empty/retry states rather than synthetic placeholder rows.

## 5. Cross-References

- **Specification & Test Suite:** [spec.md](./spec.md) · [task.md](./task.md) · [test.md](./test.md)
- **BA & Architecture Docs:** [03-agency-workspace.md](../../../../ba/03-agency-workspace.md) · [Module Specs Index](../../../modules/README.md)

## Endpoint, Authorization & Error Mapping Matrix

| Aspect | Specification |
| :--- | :--- |
| **FR / Feature** | `FR 3.4.5` — Update Agency Profile |
| **HTTP / WS Endpoints** | `PUT /api/v1/agencies/{agencyId} · POST /api/v1/agencies/{agencyId}/logo · POST /api/v1/agencies/{agencyId}/banner` |
| **Authorized Canonical Roles** | `Owner` |
| **Controller -> Service** | `AgencyController.updateAgency() / uploadLogo() / uploadBanner()` -> `AgencyServiceImpl.updateAgency() / uploadLogo() / uploadBanner(), S3FileStorageServiceImpl` |
| **Persistence / Cache Targets** | PostgreSQL `agencies`, `audit_logs`; AWS S3 (`agencies/logos/`, `agencies/banners/`) |
| **Business Rule Invariants** | `BR-15` |
| **Error Code Contract** | `400 VALIDATION_ERROR` / `INVALID_FILE_TYPE` / `FILE_TOO_LARGE`, `403 FORBIDDEN` (`BR-15`), `404 AGENCY_NOT_FOUND` |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/agency/detail.tsx`, `src/pages/agency/components/{AgencyDetailEditForm,AgencyDetailLivePreview,AgencyBrandingSection}.tsx`, `src/components/shared/BannerUploader.tsx`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/services/agencyService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `agency.detail.* / agency.edit.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/03-agency-workspace.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
