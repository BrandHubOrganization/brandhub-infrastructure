> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.4.10 — Decline Agency Invitation

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.4.10` |
| **Use Case ID** | `UC-023` |
| **Feature** | Decline Agency Invitation |
| **Domain** | Agency & Workspace (`FR 3.4`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Business Rules** | `BR-17` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Scope

Từ chối lời mời tham gia Agency (/invitations/:token). Hệ thống kiểm tra lời mời đang ở trạng thái PENDING (BR-17), cập nhật trạng thái lời mời sang DECLINED và gửi thông báo phản hồi cho Owner.

**Implementation Summary:** Validates `DeclineInvitationRequest(token)` for a `PENDING`, non-expired invitation matching the authenticated user email (case-insensitive, `BR-17`), marks the invitation `DECLINED`, and creates zero `AgencyMember` or `WorkspaceMember` rows.

## 2. User Story

As an authorized actor (`Owner, Manager, Creator, Client`), I want to execute **Decline Agency Invitation** with strict multi-tenant authorization and real-time state consistency, so that organizational governance and role-scoped workflows satisfy `BR-17` across Web and Mobile.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Gate:** Only authenticated users holding `Owner, Manager, Creator, Client` within the target Agency/Workspace scope may invoke `POST /api/v1/agencies/invitations/decline · POST /api/v1/workspaces/invitations/decline`; unauthorized callers are rejected (`401` / `403`).
2. **Business Rule Enforcement (`BR-17`):** Backend service logic (`AgencyServiceImpl.declineInvitation(), WorkspaceServiceImpl.declineInvitation()`) enforces all domain invariants, uniqueness constraints, and soft-delete / single-Manager / TTL rules before committing state changes.
3. **Standardized Envelope & Persistence:** Reads and mutations against PostgreSQL `agency_invitations`, `workspace_invitations` return `ApiResponse<T>` with deterministic `ErrorCode` mappings (`400 INVALID_INVITATION`, `401 UNAUTHORIZED`, `403 FORBIDDEN`) and `X-Request-Id` correlation.
4. **Internationalization (`vi` / `en`):** All UI labels, empty states, dialogs, and toast notifications use parallel locale keys (`agency.invitations.decline.*`) in `vi` and `en` bundles — zero hardcoded strings in JSX/TSX.
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

- **Endpoints:** `POST /api/v1/agencies/invitations/decline · POST /api/v1/workspaces/invitations/decline`
- **Controller & Service (`brandhub-business-service`):** `AgencyController.declineInvitation(), WorkspaceController.declineInvitation()` -> `AgencyServiceImpl.declineInvitation(), WorkspaceServiceImpl.declineInvitation()`
- **Repositories & Stores:** AgencyInvitationRepository, WorkspaceInvitationRepository
- **Authentication:** `Authorization: Bearer <accessToken>` verified by `JwtAuthFilterGatewayFilterFactory` (`brandhub-api-gateway`) and `JwtAuthenticationFilter` / `@RequireRoleAspect` (`brandhub-business-service`).

## 6. Error Handling & Edge Cases

- **Error Codes:** `400 INVALID_INVITATION`, `401 UNAUTHORIZED`, `403 FORBIDDEN`.
- **Tenant Boundary Isolation:** Soft-deleted Agencies/Workspaces (`EntityStatus.SOFT_DELETED`) and deactivated memberships (`is_active = false`) are excluded from operational reads and rejected on mutations.
- **Concurrency & Idempotency:** Transactional persistence (`@Transactional`) and database unique constraints prevent duplicate memberships, duplicate active Managers, or partial writes under concurrent requests.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints and service logic verified against [test.md](./test.md), Web & Mobile UI wired to live APIs, `vi`/`en` locale parity verified, and Light/Dark mode verified.
- **Out of Scope:** Adjacent Agency/Workspace operations covered by sibling FRs in `3.4.1–3.4.26`.
- **Related Documentation:** [BA Agency & Workspace Spec](../../../../ba/03-agency-workspace.md) · [Organization Structure](../../../../ba/01-organization-structure.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
