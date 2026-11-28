> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.4.20 — View Workspace Templates

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.4.20` |
| **Use Case ID** | `UC-033` |
| **Feature** | View Workspace Templates |
| **Domain** | Agency & Workspace (`FR 3.4`) |
| **Canonical Actors / Roles** | `Owner` |
| **Business Rules** | `BR-24` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Scope

Xem danh sách và chi tiết các mẫu cấu hình Workspace (View Workspace Templates — /agency/:id/workspace-templates). Hiển thị cả các mẫu mặc định của hệ thống và các mẫu riêng do Agency đã lưu, bao gồm mô tả cấu trúc công việc, múi giờ và các thiết lập đi kèm (BR-24).

**Implementation Summary:** Returns both global system templates (`agency_id IS NULL`) and Agency-owned templates belonging to Agencies owned by the authenticated `Owner` (`BR-24`), with detailed configuration preview (`GET /api/v1/workspace-templates/{templateId}`).

## 2. User Story

As an authorized actor (`Owner`), I want to execute **View Workspace Templates** with strict multi-tenant authorization and real-time state consistency, so that organizational governance and role-scoped workflows satisfy `BR-24` across Web and Mobile.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Gate:** Only authenticated users holding `Owner` within the target Agency/Workspace scope may invoke `GET /api/v1/workspace-templates · GET /api/v1/workspace-templates/{templateId}`; unauthorized callers are rejected (`401` / `403`).
2. **Business Rule Enforcement (`BR-24`):** Backend service logic (`WorkspaceTemplateServiceImpl.listTemplates() / getTemplate()`) enforces all domain invariants, uniqueness constraints, and soft-delete / single-Manager / TTL rules before committing state changes.
3. **Standardized Envelope & Persistence:** Reads and mutations against PostgreSQL `workspace_templates` return `ApiResponse<T>` with deterministic `ErrorCode` mappings (`401 UNAUTHORIZED`, `403 FORBIDDEN`, `404 TEMPLATE_NOT_FOUND`) and `X-Request-Id` correlation.
4. **Internationalization (`vi` / `en`):** All UI labels, empty states, dialogs, and toast notifications use parallel locale keys (`workspace.templates.list.*`) in `vi` and `en` bundles — zero hardcoded strings in JSX/TSX.
5. **Semantic Light/Dark Theme:** All cards, tables, badges, drawers, and confirmation modals use semantic CSS variables / Tailwind `dark:` tokens (`brandhub-web`) and `useTheme()` tokens (`brandhub-mobile-app`) with WCAG-compliant contrast.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/workspace/templates.tsx`, `src/pages/workspace/components/TemplatePreviewDialog.tsx`, `src/services/workspaceTemplateService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/services/workspaceService.ts`
- **Interactive States:**
  - **Loading:** Skeleton cards/rows and disabled in-flight submit buttons preventing duplicate requests.
  - **Empty State:** Contextual empty state with localized guidance and primary CTA where permitted by role.
  - **Success:** TanStack Query cache invalidation + localized confirmation toast without full-page reload.
  - **Error / Recovery:** Inline field validation or retryable `DataErrorState` banner mapped from backend `ErrorCode` — never silently falling back to mock data.

## 5. API Contract

- **Endpoints:** `GET /api/v1/workspace-templates · GET /api/v1/workspace-templates/{templateId}`
- **Controller & Service (`brandhub-business-service`):** `WorkspaceTemplateController.listTemplates() / getTemplate()` -> `WorkspaceTemplateServiceImpl.listTemplates() / getTemplate()`
- **Repositories & Stores:** WorkspaceTemplateRepository, AgencyRepository
- **Authentication:** `Authorization: Bearer <accessToken>` verified by `JwtAuthFilterGatewayFilterFactory` (`brandhub-api-gateway`) and `JwtAuthenticationFilter` / `@RequireRoleAspect` (`brandhub-business-service`).

## 6. Error Handling & Edge Cases

- **Error Codes:** `401 UNAUTHORIZED`, `403 FORBIDDEN`, `404 TEMPLATE_NOT_FOUND`.
- **Tenant Boundary Isolation:** Soft-deleted Agencies/Workspaces (`EntityStatus.SOFT_DELETED`) and deactivated memberships (`is_active = false`) are excluded from operational reads and rejected on mutations.
- **Concurrency & Idempotency:** Transactional persistence (`@Transactional`) and database unique constraints prevent duplicate memberships, duplicate active Managers, or partial writes under concurrent requests.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints and service logic verified against [test.md](./test.md), Web & Mobile UI wired to live APIs, `vi`/`en` locale parity verified, and Light/Dark mode verified.
- **Out of Scope:** Adjacent Agency/Workspace operations covered by sibling FRs in `3.4.1–3.4.26`.
- **Related Documentation:** [BA Agency & Workspace Spec](../../../../ba/03-agency-workspace.md) · [Organization Structure](../../../../ba/01-organization-structure.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
