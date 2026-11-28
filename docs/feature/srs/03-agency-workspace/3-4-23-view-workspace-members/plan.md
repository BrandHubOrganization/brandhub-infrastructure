> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.4.23: View Workspace Members

> Implements [spec.md](./spec.md) for canonical roles `Owner, Manager, Creator, Client` enforcing `BR-15, BR-20`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `JwtAuthFilterGatewayFilterFactory.java`, `InboundSecurityWebFilter.java`, `GatewayConfig.java` (`/api/v1/**`) |
| **Controller** | `brandhub-business-service` | `WorkspaceController.listMembers()` |
| **Service** | `brandhub-business-service` | `WorkspaceServiceImpl.listMembers()` |
| **Repositories** | `brandhub-business-service` | WorkspaceMemberRepository, UserRepository, ClientProfileRepository |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceIsolationHelper.java`, `WorkspaceAccessService.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/workspace/members.tsx`, `src/pages/workspace/clients.tsx`, `src/pages/workspace/components/{InternalMembersSection,MembersTable,ClientsSection,ClientsTable}.tsx` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/workspace/WorkspaceMembersScreen.tsx`, `src/services/workspaceService.ts` |

## 2. Data Model, Schema & Indexes

- **Primary Stores:** PostgreSQL `workspace_members`, `users`, `client_profiles`.
- **Key Architectural Details:**
  - Enforces active Workspace membership (`BR-20`) and returns active `WorkspaceMember` records (`MANAGER`, `CREATOR`, `CLIENT`) enriched with `User` and `ClientProfile` display details, powering `/workspaces/:id/members` (internal staff) and `/workspaces/:id/clients` (Client collaborators).
  - **Multi-Tenant Indexing:** Foreign-key and composite lookup indexes on `agencies(owner_id, status)`, `agency_members(agency_id, user_id)`, `workspaces(agency_id, status)`, `workspace_members(workspace_id, user_id, is_active)`, and `workspace_invitations` / `agency_invitations(token, status, expires_at)` ensure single-digit millisecond ACL and listing queries.
  - **Canonical Timezone Source:** Workspace timezone reads/writes use `workspaces.timezone_config` (default `Asia/Ho_Chi_Minh`) mirrored cleanly in `WorkspaceResponse.settings.timezone`.

## 3. End-to-End Execution Flow

1. **Client Invocation:** Authorized actor (`Owner, Manager, Creator, Client`) initiates **View Workspace Members** from `src/pages/workspace/members.tsx`, `src/pages/workspace/clients.tsx`, `src/pages/workspace/components/{InternalMembersSection,MembersTable,ClientsSection,ClientsTable}.tsx` (Web) or `src/screens/workspace/WorkspaceMembersScreen.tsx`, `src/services/workspaceService.ts` (Mobile).
2. **Gateway & Principal Resolution:** `brandhub-api-gateway` validates Bearer JWT signature and Redis blacklist status (`jwt:blacklist:{jti}`), forwarding `X-Request-Id` and principal headers to `brandhub-business-service`.
3. **Authorization & Business Rule Validation:** `WorkspaceController.listMembers()` validates DTO constraints (`@Valid`) and delegates to `WorkspaceServiceImpl.listMembers()`, which verifies live DB role/ownership (`Owner, Manager, Creator, Client`) and domain rules (`BR-15, BR-20`).
4. **Atomic Persistence / Aggregation:** Executes `@Transactional` queries/updates across PostgreSQL `workspace_members`, `users`, `client_profiles`, mapping domain violations deterministically to `403 WORKSPACE_ACCESS_DENIED` / `FORBIDDEN`, `404 WORKSPACE_NOT_FOUND`.
5. **Client State Synchronization:** Returns `ApiResponse<T>`; frontend invalidates scoped TanStack Query keys (`agency` / `workspaces` / `dashboard`), updates Zustand active org/workspace context when applicable, and renders localized (`workspace.members.* / workspace.clients.*`) feedback.

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
| **FR / Feature** | `FR 3.4.23` — View Workspace Members |
| **HTTP / WS Endpoints** | `GET /api/v1/workspaces/{workspaceId}/members` |
| **Authorized Canonical Roles** | `Owner, Manager, Creator, Client` |
| **Controller -> Service** | `WorkspaceController.listMembers()` -> `WorkspaceServiceImpl.listMembers()` |
| **Persistence / Cache Targets** | PostgreSQL `workspace_members`, `users`, `client_profiles` |
| **Business Rule Invariants** | `BR-15, BR-20` |
| **Error Code Contract** | `403 WORKSPACE_ACCESS_DENIED` / `FORBIDDEN`, `404 WORKSPACE_NOT_FOUND` |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/workspace/members.tsx`, `src/pages/workspace/clients.tsx`, `src/pages/workspace/components/{InternalMembersSection,MembersTable,ClientsSection,ClientsTable}.tsx`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/workspace/WorkspaceMembersScreen.tsx`, `src/services/workspaceService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `workspace.members.* / workspace.clients.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/03-agency-workspace.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
