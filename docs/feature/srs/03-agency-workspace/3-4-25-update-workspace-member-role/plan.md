> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.4.25: Update Workspace Member Role

> Implements [spec.md](./spec.md) for canonical roles `Owner, Manager` enforcing `BR-21`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `JwtAuthFilterGatewayFilterFactory.java`, `InboundSecurityWebFilter.java`, `GatewayConfig.java` (`/api/v1/**`) |
| **Controller** | `brandhub-business-service` | `WorkspaceController.updateMemberRole()` |
| **Service** | `brandhub-business-service` | `WorkspaceServiceImpl.updateMemberRole()` |
| **Repositories** | `brandhub-business-service` | WorkspaceMemberRepository, WorkspaceRepository, AgencyRepository |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceIsolationHelper.java`, `WorkspaceAccessService.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/workspace/members.tsx`, `src/pages/workspace/components/MembersTable.tsx`, `src/pages/workspace/hooks/useWorkspaceMembers.ts` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/workspace/WorkspaceMembersScreen.tsx`, `src/services/workspaceService.ts` |

## 2. Data Model, Schema & Indexes

- **Primary Stores:** PostgreSQL `workspace_members` (`role`).
- **Key Architectural Details:**
  - Transitions internal memberships between `MANAGER` and `CREATOR` while enforcing `BR-21` (at most one active `Manager`; sole active `Manager` cannot be demoted without replacement; `CLIENT` memberships cannot be converted into internal staff roles).
  - **Multi-Tenant Indexing:** Foreign-key and composite lookup indexes on `agencies(owner_id, status)`, `agency_members(agency_id, user_id)`, `workspaces(agency_id, status)`, `workspace_members(workspace_id, user_id, is_active)`, and `workspace_invitations` / `agency_invitations(token, status, expires_at)` ensure single-digit millisecond ACL and listing queries.
  - **Canonical Timezone Source:** Workspace timezone reads/writes use `workspaces.timezone_config` (default `Asia/Ho_Chi_Minh`) mirrored cleanly in `WorkspaceResponse.settings.timezone`.

## 3. End-to-End Execution Flow

1. **Client Invocation:** Authorized actor (`Owner, Manager`) initiates **Update Workspace Member Role** from `src/pages/workspace/members.tsx`, `src/pages/workspace/components/MembersTable.tsx`, `src/pages/workspace/hooks/useWorkspaceMembers.ts` (Web) or `src/screens/workspace/WorkspaceMembersScreen.tsx`, `src/services/workspaceService.ts` (Mobile).
2. **Gateway & Principal Resolution:** `brandhub-api-gateway` validates Bearer JWT signature and Redis blacklist status (`jwt:blacklist:{jti}`), forwarding `X-Request-Id` and principal headers to `brandhub-business-service`.
3. **Authorization & Business Rule Validation:** `WorkspaceController.updateMemberRole()` validates DTO constraints (`@Valid`) and delegates to `WorkspaceServiceImpl.updateMemberRole()`, which verifies live DB role/ownership (`Owner, Manager`) and domain rules (`BR-21`).
4. **Atomic Persistence / Aggregation:** Executes `@Transactional` queries/updates across PostgreSQL `workspace_members` (`role`), mapping domain violations deterministically to `400 INVALID_ROLE_TRANSITION` / `SOLE_MANAGER_CANNOT_DEMOTE`, `403 FORBIDDEN`, `404 MEMBER_NOT_FOUND`, `409 MANAGER_ALREADY_ASSIGNED`.
5. **Client State Synchronization:** Returns `ApiResponse<T>`; frontend invalidates scoped TanStack Query keys (`agency` / `workspaces` / `dashboard`), updates Zustand active org/workspace context when applicable, and renders localized (`workspace.members.role.*`) feedback.

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
| **FR / Feature** | `FR 3.4.25` — Update Workspace Member Role |
| **HTTP / WS Endpoints** | `PATCH /api/v1/workspaces/{workspaceId}/members/{memberId}/role` |
| **Authorized Canonical Roles** | `Owner, Manager` |
| **Controller -> Service** | `WorkspaceController.updateMemberRole()` -> `WorkspaceServiceImpl.updateMemberRole()` |
| **Persistence / Cache Targets** | PostgreSQL `workspace_members` (`role`) |
| **Business Rule Invariants** | `BR-21` |
| **Error Code Contract** | `400 INVALID_ROLE_TRANSITION` / `SOLE_MANAGER_CANNOT_DEMOTE`, `403 FORBIDDEN`, `404 MEMBER_NOT_FOUND`, `409 MANAGER_ALREADY_ASSIGNED` |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/workspace/members.tsx`, `src/pages/workspace/components/MembersTable.tsx`, `src/pages/workspace/hooks/useWorkspaceMembers.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/workspace/WorkspaceMembersScreen.tsx`, `src/services/workspaceService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `workspace.members.role.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/03-agency-workspace.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
