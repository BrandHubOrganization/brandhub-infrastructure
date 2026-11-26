> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.4.17 — Delete Workspace

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.4.17` |
| **Use Case ID** | `UC-030` |
| **Feature** | Delete Workspace |
| **Domain** | Agency & Workspace (`FR 3.4`) |
| **Canonical Actors / Roles** | `Owner` |
| **Business Rules** | `BR-16` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Scope

Xóa mềm Workspace (/workspaces/:id/settings). Chỉ duy nhất Owner mới có quyền xóa Workspace. Khi xóa, toàn bộ dữ liệu bên trong chuyển sang trạng thái INACTIVE, các thành viên không còn quyền truy cập, nhưng dữ liệu được bảo lưu và Owner có thể khôi phục lại hoàn toàn trong vòng 30 ngày (BR-16).

**Implementation Summary:** Strictly enforces parent Agency `Owner` authorization (`agency.ownerId == currentUser.id`), requires exact Workspace-name confirmation in `WorkspaceDangerZone.tsx`, soft-deletes the Workspace (`EntityStatus.SOFT_DELETED`, `deletedAt = now()`), hides it from active listings, and supports 30-day restoration (`WORKSPACE_RESTORE_WINDOW_DAYS = 30`, `BR-16`).

## 2. User Story

As an authorized actor (`Owner`), I want to execute **Delete Workspace** with strict multi-tenant authorization and real-time state consistency, so that organizational governance and role-scoped workflows satisfy `BR-16` across Web and Mobile.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Gate:** Only authenticated users holding `Owner` within the target Agency/Workspace scope may invoke `DELETE /api/v1/workspaces/{workspaceId} · POST /api/v1/workspaces/{workspaceId}/restore`; unauthorized callers are rejected (`401` / `403`).
2. **Business Rule Enforcement (`BR-16`):** Backend service logic (`WorkspaceServiceImpl.deleteWorkspace() / restoreWorkspace()`) enforces all domain invariants, uniqueness constraints, and soft-delete / single-Manager / TTL rules before committing state changes.
3. **Standardized Envelope & Persistence:** Reads and mutations against PostgreSQL `workspaces` (`status = SOFT_DELETED`, `deleted_at`), `agencies`, `audit_logs` return `ApiResponse<T>` with deterministic `ErrorCode` mappings (`403 FORBIDDEN` (`BR-15`), `404 WORKSPACE_NOT_FOUND`, `400 WORKSPACE_NOT_DELETED`, `410 RESTORE_WINDOW_EXPIRED` (`BR-16`)) and `X-Request-Id` correlation.
4. **Internationalization (`vi` / `en`):** All UI labels, empty states, dialogs, and toast notifications use parallel locale keys (`workspace.dangerZone.* / workspace.delete.*`) in `vi` and `en` bundles — zero hardcoded strings in JSX/TSX.
5. **Semantic Light/Dark Theme:** All cards, tables, badges, drawers, and confirmation modals use semantic CSS variables / Tailwind `dark:` tokens (`brandhub-web`) and `useTheme()` tokens (`brandhub-mobile-app`) with WCAG-compliant contrast.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/workspace/detail.tsx`, `src/pages/workspace/components/settings/WorkspaceDangerZone.tsx`, `src/pages/workspace/hooks/useClearStoragePreview.ts`, `src/pages/workspace/services/workspaceService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/settings/WorkspaceSettingsScreen.tsx`, `src/services/workspaceService.ts`
- **Interactive States:**
  - **Loading:** Skeleton cards/rows and disabled in-flight submit buttons preventing duplicate requests.
  - **Empty State:** Contextual empty state with localized guidance and primary CTA where permitted by role.
  - **Success:** TanStack Query cache invalidation + localized confirmation toast without full-page reload.
  - **Error / Recovery:** Inline field validation or retryable `DataErrorState` banner mapped from backend `ErrorCode` — never silently falling back to mock data.

## 5. API Contract

- **Endpoints:** `DELETE /api/v1/workspaces/{workspaceId} · POST /api/v1/workspaces/{workspaceId}/restore`
- **Controller & Service (`brandhub-business-service`):** `WorkspaceController.deleteWorkspace() / restoreWorkspace()` -> `WorkspaceServiceImpl.deleteWorkspace() / restoreWorkspace()`
- **Repositories & Stores:** WorkspaceRepository, AgencyRepository, AuditLogRepository
- **Authentication:** `Authorization: Bearer <accessToken>` verified by `JwtAuthFilterGatewayFilterFactory` (`brandhub-api-gateway`) and `JwtAuthenticationFilter` / `@RequireRoleAspect` (`brandhub-business-service`).

## 6. Error Handling & Edge Cases

- **Error Codes:** `403 FORBIDDEN` (`BR-15`), `404 WORKSPACE_NOT_FOUND`, `400 WORKSPACE_NOT_DELETED`, `410 RESTORE_WINDOW_EXPIRED` (`BR-16`).
- **Tenant Boundary Isolation:** Soft-deleted Agencies/Workspaces (`EntityStatus.SOFT_DELETED`) and deactivated memberships (`is_active = false`) are excluded from operational reads and rejected on mutations.
- **Concurrency & Idempotency:** Transactional persistence (`@Transactional`) and database unique constraints prevent duplicate memberships, duplicate active Managers, or partial writes under concurrent requests.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints and service logic verified against [test.md](./test.md), Web & Mobile UI wired to live APIs, `vi`/`en` locale parity verified, and Light/Dark mode verified.
- **Out of Scope:** Adjacent Agency/Workspace operations covered by sibling FRs in `3.4.1–3.4.26`.
- **Related Documentation:** [BA Agency & Workspace Spec](../../../../ba/03-agency-workspace.md) · [Organization Structure](../../../../ba/01-organization-structure.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
