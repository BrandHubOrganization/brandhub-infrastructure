> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.4.9 — Accept Agency Invitation

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.4.9` |
| **Use Case ID** | `UC-022` |
| **Feature** | Accept Agency Invitation |
| **Domain** | Agency & Workspace (`FR 3.4`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Business Rules** | `BR-17` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Scope

Chấp nhận lời mời tham gia Agency từ thông báo trong ứng dụng hoặc liên kết trong email (/invitations/:token). Hệ thống kiểm tra lời mời còn ở trạng thái PENDING và chưa quá hạn 30 ngày (BR-17), chuyển trạng thái lời mời sang ACCEPTED và thêm người dùng vào danh sách thành viên chính thức của Agency.

**Implementation Summary:** Validates `AcceptInvitationRequest(token, clientProfileId, newClientProfile)` against `PENDING` status, expiry boundary (`BR-17`), and case-insensitive invited email match, atomically transitioning status to `ACCEPTED` and creating `AgencyMember` and/or `WorkspaceMember` (linking or creating `ClientProfile` for `CLIENT` invites without adding external clients to internal `agency_members`).

## 2. User Story

As an authorized actor (`Owner, Manager, Creator, Client`), I want to execute **Accept Agency Invitation** with strict multi-tenant authorization and real-time state consistency, so that organizational governance and role-scoped workflows satisfy `BR-17` across Web and Mobile.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Gate:** Only authenticated users holding `Owner, Manager, Creator, Client` within the target Agency/Workspace scope may invoke `POST /api/v1/agencies/invitations/accept · POST /api/v1/workspaces/invitations/accept`; unauthorized callers are rejected (`401` / `403`).
2. **Business Rule Enforcement (`BR-17`):** Backend service logic (`AgencyServiceImpl.acceptInvitation(), WorkspaceServiceImpl.acceptInvitation()`) enforces all domain invariants, uniqueness constraints, and soft-delete / single-Manager / TTL rules before committing state changes.
3. **Standardized Envelope & Persistence:** Reads and mutations against PostgreSQL `agency_invitations`, `workspace_invitations`, `agency_members`, `workspace_members`, `client_profiles` return `ApiResponse<T>` with deterministic `ErrorCode` mappings (`400 INVALID_INVITATION` / `CLIENT_PROFILE_REQUIRED_FOR_ACCEPT`, `409 ALREADY_AGENCY_MEMBER` / `MANAGER_ALREADY_ASSIGNED`) and `X-Request-Id` correlation.
4. **Internationalization (`vi` / `en`):** All UI labels, empty states, dialogs, and toast notifications use parallel locale keys (`agency.invitations.accept.*`) in `vi` and `en` bundles — zero hardcoded strings in JSX/TSX.
5. **Semantic Light/Dark Theme:** All cards, tables, badges, drawers, and confirmation modals use semantic CSS variables / Tailwind `dark:` tokens (`brandhub-web`) and `useTheme()` tokens (`brandhub-mobile-app`) with WCAG-compliant contrast.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/agency/accept.tsx`, `src/pages/agency/invitations.tsx`, `src/services/agencyService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/notifications/NotificationsScreen.tsx`, `src/services/agencyService.ts`
- **Interactive States:**
  - **Loading:** Skeleton cards/rows and disabled in-flight submit buttons preventing duplicate requests.
  - **Empty State:** Contextual empty state with localized guidance and primary CTA where permitted by role.
  - **Success:** TanStack Query cache invalidation + localized confirmation toast without full-page reload.
  - **Error / Recovery:** Inline field validation or retryable `DataErrorState` banner mapped from backend `ErrorCode` — never silently falling back to mock data.

## 5. API Contract

- **Endpoints:** `POST /api/v1/agencies/invitations/accept · POST /api/v1/workspaces/invitations/accept`
- **Controller & Service (`brandhub-business-service`):** `AgencyController.acceptInvitation(), WorkspaceController.acceptInvitation()` -> `AgencyServiceImpl.acceptInvitation(), WorkspaceServiceImpl.acceptInvitation()`
- **Repositories & Stores:** AgencyInvitationRepository, WorkspaceInvitationRepository, AgencyMemberRepository, WorkspaceMemberRepository, ClientProfileRepository
- **Authentication:** `Authorization: Bearer <accessToken>` verified by `JwtAuthFilterGatewayFilterFactory` (`brandhub-api-gateway`) and `JwtAuthenticationFilter` / `@RequireRoleAspect` (`brandhub-business-service`).

## 6. Error Handling & Edge Cases

- **Error Codes:** `400 INVALID_INVITATION` / `CLIENT_PROFILE_REQUIRED_FOR_ACCEPT`, `409 ALREADY_AGENCY_MEMBER` / `MANAGER_ALREADY_ASSIGNED`.
- **Tenant Boundary Isolation:** Soft-deleted Agencies/Workspaces (`EntityStatus.SOFT_DELETED`) and deactivated memberships (`is_active = false`) are excluded from operational reads and rejected on mutations.
- **Concurrency & Idempotency:** Transactional persistence (`@Transactional`) and database unique constraints prevent duplicate memberships, duplicate active Managers, or partial writes under concurrent requests.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints and service logic verified against [test.md](./test.md), Web & Mobile UI wired to live APIs, `vi`/`en` locale parity verified, and Light/Dark mode verified.
- **Out of Scope:** Adjacent Agency/Workspace operations covered by sibling FRs in `3.4.1–3.4.26`.
- **Related Documentation:** [BA Agency & Workspace Spec](../../../../ba/03-agency-workspace.md) · [Organization Structure](../../../../ba/01-organization-structure.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
