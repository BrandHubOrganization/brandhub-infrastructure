> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.4.9: Accept Agency Invitation

> Implements [spec.md](./spec.md) for canonical roles `Owner, Manager, Creator, Client` enforcing `BR-17`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `JwtAuthFilterGatewayFilterFactory.java`, `InboundSecurityWebFilter.java`, `GatewayConfig.java` (`/api/v1/**`) |
| **Controller** | `brandhub-business-service` | `AgencyController.acceptInvitation(), WorkspaceController.acceptInvitation()` |
| **Service** | `brandhub-business-service` | `AgencyServiceImpl.acceptInvitation(), WorkspaceServiceImpl.acceptInvitation()` |
| **Repositories** | `brandhub-business-service` | AgencyInvitationRepository, WorkspaceInvitationRepository, AgencyMemberRepository, WorkspaceMemberRepository, ClientProfileRepository |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceIsolationHelper.java`, `WorkspaceAccessService.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/agency/accept.tsx`, `src/pages/agency/invitations.tsx`, `src/services/agencyService.ts` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/notifications/NotificationsScreen.tsx`, `src/services/agencyService.ts` |

## 2. Data Model, Schema & Indexes

- **Primary Stores:** PostgreSQL `agency_invitations`, `workspace_invitations`, `agency_members`, `workspace_members`, `client_profiles`.
- **Key Architectural Details:**
  - Validates `AcceptInvitationRequest(token, clientProfileId, newClientProfile)` against `PENDING` status, expiry boundary (`BR-17`), and case-insensitive invited email match, atomically transitioning status to `ACCEPTED` and creating `AgencyMember` and/or `WorkspaceMember` (linking or creating `ClientProfile` for `CLIENT` invites without adding external clients to internal `agency_members`).
  - **Multi-Tenant Indexing:** Foreign-key and composite lookup indexes on `agencies(owner_id, status)`, `agency_members(agency_id, user_id)`, `workspaces(agency_id, status)`, `workspace_members(workspace_id, user_id, is_active)`, and `workspace_invitations` / `agency_invitations(token, status, expires_at)` ensure single-digit millisecond ACL and listing queries.
  - **Canonical Timezone Source:** Workspace timezone reads/writes use `workspaces.timezone_config` (default `Asia/Ho_Chi_Minh`) mirrored cleanly in `WorkspaceResponse.settings.timezone`.

## 3. End-to-End Execution Flow

1. **Client Invocation:** Authorized actor (`Owner, Manager, Creator, Client`) initiates **Accept Agency Invitation** from `src/pages/agency/accept.tsx`, `src/pages/agency/invitations.tsx`, `src/services/agencyService.ts` (Web) or `src/screens/notifications/NotificationsScreen.tsx`, `src/services/agencyService.ts` (Mobile).
2. **Gateway & Principal Resolution:** `brandhub-api-gateway` validates Bearer JWT signature and Redis blacklist status (`jwt:blacklist:{jti}`), forwarding `X-Request-Id` and principal headers to `brandhub-business-service`.
3. **Authorization & Business Rule Validation:** `AgencyController.acceptInvitation(), WorkspaceController.acceptInvitation()` validates DTO constraints (`@Valid`) and delegates to `AgencyServiceImpl.acceptInvitation(), WorkspaceServiceImpl.acceptInvitation()`, which verifies live DB role/ownership (`Owner, Manager, Creator, Client`) and domain rules (`BR-17`).
4. **Atomic Persistence / Aggregation:** Executes `@Transactional` queries/updates across PostgreSQL `agency_invitations`, `workspace_invitations`, `agency_members`, `workspace_members`, `client_profiles`, mapping domain violations deterministically to `400 INVALID_INVITATION` / `CLIENT_PROFILE_REQUIRED_FOR_ACCEPT`, `409 ALREADY_AGENCY_MEMBER` / `MANAGER_ALREADY_ASSIGNED`.
5. **Client State Synchronization:** Returns `ApiResponse<T>`; frontend invalidates scoped TanStack Query keys (`agency` / `workspaces` / `dashboard`), updates Zustand active org/workspace context when applicable, and renders localized (`agency.invitations.accept.*`) feedback.

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
| **FR / Feature** | `FR 3.4.9` — Accept Agency Invitation |
| **HTTP / WS Endpoints** | `POST /api/v1/agencies/invitations/accept · POST /api/v1/workspaces/invitations/accept` |
| **Authorized Canonical Roles** | `Owner, Manager, Creator, Client` |
| **Controller -> Service** | `AgencyController.acceptInvitation(), WorkspaceController.acceptInvitation()` -> `AgencyServiceImpl.acceptInvitation(), WorkspaceServiceImpl.acceptInvitation()` |
| **Persistence / Cache Targets** | PostgreSQL `agency_invitations`, `workspace_invitations`, `agency_members`, `workspace_members`, `client_profiles` |
| **Business Rule Invariants** | `BR-17` |
| **Error Code Contract** | `400 INVALID_INVITATION` / `CLIENT_PROFILE_REQUIRED_FOR_ACCEPT`, `409 ALREADY_AGENCY_MEMBER` / `MANAGER_ALREADY_ASSIGNED` |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/agency/accept.tsx`, `src/pages/agency/invitations.tsx`, `src/services/agencyService.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/notifications/NotificationsScreen.tsx`, `src/services/agencyService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `agency.invitations.accept.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/03-agency-workspace.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
