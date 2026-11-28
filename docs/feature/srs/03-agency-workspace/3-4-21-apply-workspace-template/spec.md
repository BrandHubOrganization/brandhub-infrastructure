> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.4.21 — Apply Workspace Template

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.4.21` |
| **Use Case ID** | `UC-034` |
| **Feature** | Apply Workspace Template |
| **Domain** | Agency & Workspace (`FR 3.4`) |
| **Canonical Actors / Roles** | `Owner` |
| **Business Rules** | `BR-24` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Scope

Áp dụng một mẫu cấu hình Workspace đã lưu vào Workspace mới hoặc hiện hành (Apply Workspace Template). Hệ thống tự động khởi tạo nhanh các thiết lập múi giờ, danh mục mẫu công việc, bộ hashtag và mẫu email từ Template vào Workspace đích mà không làm ảnh hưởng đến dữ liệu lịch sử (BR-24).

**Implementation Summary:** Applies non-null configuration attributes (`timezone_config`, `industry`, `settings` JSONB defaults) from a global or same-Agency `WorkspaceTemplate` onto target `workspaceId` (`BR-24`) using explicit `@PathVariable("templateId")` resolution so `@RequireRoleAspect` accurately gates `workspaceId`.

## 2. User Story

As an authorized actor (`Owner`), I want to execute **Apply Workspace Template** with strict multi-tenant authorization and real-time state consistency, so that organizational governance and role-scoped workflows satisfy `BR-24` across Web and Mobile.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Gate:** Only authenticated users holding `Owner` within the target Agency/Workspace scope may invoke `POST /api/v1/workspace-templates/{templateId}/apply/{workspaceId}`; unauthorized callers are rejected (`401` / `403`).
2. **Business Rule Enforcement (`BR-24`):** Backend service logic (`WorkspaceTemplateServiceImpl.applyTemplate()`) enforces all domain invariants, uniqueness constraints, and soft-delete / single-Manager / TTL rules before committing state changes.
3. **Standardized Envelope & Persistence:** Reads and mutations against PostgreSQL `workspace_templates`, `workspaces` return `ApiResponse<T>` with deterministic `ErrorCode` mappings (`403 FORBIDDEN`, `404 TEMPLATE_NOT_FOUND` / `WORKSPACE_NOT_FOUND`) and `X-Request-Id` correlation.
4. **Internationalization (`vi` / `en`):** All UI labels, empty states, dialogs, and toast notifications use parallel locale keys (`workspace.templates.apply.*`) in `vi` and `en` bundles — zero hardcoded strings in JSX/TSX.
5. **Semantic Light/Dark Theme:** All cards, tables, badges, drawers, and confirmation modals use semantic CSS variables / Tailwind `dark:` tokens (`brandhub-web`) and `useTheme()` tokens (`brandhub-mobile-app`) with WCAG-compliant contrast.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/workspace/templates.tsx`, `src/pages/workspace/create.tsx`, `src/pages/workspace/components/ApplyTemplateDialog.tsx`, `src/services/workspaceTemplateService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/services/workspaceService.ts`
- **Interactive States:**
  - **Loading:** Skeleton cards/rows and disabled in-flight submit buttons preventing duplicate requests.
  - **Empty State:** Contextual empty state with localized guidance and primary CTA where permitted by role.
  - **Success:** TanStack Query cache invalidation + localized confirmation toast without full-page reload.
  - **Error / Recovery:** Inline field validation or retryable `DataErrorState` banner mapped from backend `ErrorCode` — never silently falling back to mock data.

## 5. API Contract

- **Endpoints:** `POST /api/v1/workspace-templates/{templateId}/apply/{workspaceId}`
- **Controller & Service (`brandhub-business-service`):** `WorkspaceTemplateController.applyToWorkspace()` -> `WorkspaceTemplateServiceImpl.applyTemplate()`
- **Repositories & Stores:** WorkspaceTemplateRepository, WorkspaceRepository
- **Authentication:** `Authorization: Bearer <accessToken>` verified by `JwtAuthFilterGatewayFilterFactory` (`brandhub-api-gateway`) and `JwtAuthenticationFilter` / `@RequireRoleAspect` (`brandhub-business-service`).

## 6. Error Handling & Edge Cases

- **Error Codes:** `403 FORBIDDEN`, `404 TEMPLATE_NOT_FOUND` / `WORKSPACE_NOT_FOUND`.
- **Tenant Boundary Isolation:** Soft-deleted Agencies/Workspaces (`EntityStatus.SOFT_DELETED`) and deactivated memberships (`is_active = false`) are excluded from operational reads and rejected on mutations.
- **Concurrency & Idempotency:** Transactional persistence (`@Transactional`) and database unique constraints prevent duplicate memberships, duplicate active Managers, or partial writes under concurrent requests.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints and service logic verified against [test.md](./test.md), Web & Mobile UI wired to live APIs, `vi`/`en` locale parity verified, and Light/Dark mode verified.
- **Out of Scope:** Adjacent Agency/Workspace operations covered by sibling FRs in `3.4.1–3.4.26`.
- **Related Documentation:** [BA Agency & Workspace Spec](../../../../ba/03-agency-workspace.md) · [Organization Structure](../../../../ba/01-organization-structure.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
