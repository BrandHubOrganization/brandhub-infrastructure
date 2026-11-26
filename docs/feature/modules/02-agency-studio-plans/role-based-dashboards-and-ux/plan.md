> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Technical Implementation Plan — Three-Tier Role-Based Dashboards, Workspace UX, Timezone Consistency & Duplicate Workspace (`role-based-dashboards-and-ux`)

## 1. System Components & Touched Repositories

Consolidates the technical architecture for `role-based-dashboards`, `dashboard-experience`, `agency-profile-presentation`, `agency-invitation-email-language`, `workspace-timezone-consistency`, `navigation-ux-linked-demo-data`, `landing-lab-replaced-apps`, `admin-ui-consistency`, `duplicate-workspace` as specified in [spec.md](./spec.md):

| Layer / Repository | Key Classes, Services, Schemas & Components |
| :--- | :--- |
| **API Gateway (`brandhub-api-gateway`)** | `GatewayConfig.java` (`/api/v1/analytics/**`, `/api/v1/agencies/**`, `/api/v1/workspaces/**`) |
| **Backend / Worker Services** | `DashboardAnalyticsController.java`, `AgencyController.java`, `WorkspaceController.java` |
| **Persistence, Cache & Brokers** | PostgreSQL `agencies`, `agency_invitations`, `workspaces`, `workspace_members`, `tasks`, `media_campaigns`; MongoDB `posts`, `content_requests`, `materials` |
| **Web Frontend (`brandhub-web`)** | `pages/dashboard/index.tsx`, `pages/agency/dashboard/index.tsx`, `pages/workspace/dashboard.tsx`, `components/dashboard/*`, `DuplicateWorkspaceDialog.tsx`, `AgencyDetailLivePreview.tsx`, `TimezoneSelect.tsx` |
| **Mobile App (`brandhub-mobile-app`)** | `src/screens/dashboard/HomeDashboardScreen.tsx`, `DashboardScreen.tsx`, `src/services/dashboardAnalyticsService.ts` |
| **i18n & Theme Assets** | `dashboard.*`, `agency.invite.emailLanguage`, `workspace.duplicate.*`, `landing.replacedApps.*` in `src/i18n/locales/{vi,en}/*.json`; Mobile `src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` & `src/theme/tokens.ts` |

## 2. Core Technical Design & Data Model Invariants

- **Unified Drill-Down Contract:** Web `DetailDrawer.tsx` and Mobile `BottomSheet` share identical `drill` filter codes (`overdue_tasks`, `pending_approvals`, `expiring_requests`, `failed_posts`) backed by `/items`.
- **Zero Mock Fallback Policy:** All live dashboard, workspace, and admin panels bind strictly to real backend APIs.

## 3. End-to-End Data & Control Flow

1. **Ingress & Identity Propagation:** Requests pass through `brandhub-api-gateway` (`InboundSecurityWebFilter` -> `JwtAuthFilterGatewayFilterFactory` -> `RateLimitGatewayFilterFactory`), stripping external header spoofing and injecting verified `X-User-Id`, `X-Request-Id`, and role claims.
2. **Authorization & Invariant Validation:** Downstream controllers and services re-verify canonical role permissions (`Guest, Owner, Manager, Creator, Client, Admin`) and Agency/Workspace tenant membership against authoritative database state before mutating data or dispatching async jobs.
3. **Atomic Persistence & Event Fan-Out:** State transitions commit atomically across PostgreSQL `agencies`, `agency_invitations`, `workspaces`, `workspace_members`, `tasks`, `media_campaigns`; MongoDB `posts`, `content_requests`, `materials` using optimistic (`@Version` / `expectedRevision`) or pessimistic locks, emitting outbox/WebSocket/`pg_notify` events after commit.
4. **Client State Reconciliation:** `brandhub-web` and `brandhub-mobile-app` consume typed `ApiResponse<T>` envelopes, update user/tenant-scoped `TanStack Query` caches, and render localized UI states in Light and Dark themes.

## 4. Sequential Implementation & Rollout Order

1. **Phase 1 — Database / Storage / Config Baseline:** Apply additive migrations in `database/init/init-postgres-v2.sql` and `database/migrations/postgres/*.sql` (plus MongoDB/Neo4j/Redis indexes) with repeat-run idempotency.
2. **Phase 2 — Domain Services & Security Guards:** Implement core service logic, cryptographic/concurrency helpers, and internal service-to-service contracts.
3. **Phase 3 — Public REST / WebSocket / Worker Endpoints:** Wire controllers, consumers, and exception handlers returning standardized `ErrorCode` payloads.
4. **Phase 4 — Web & Mobile UI Surfaces:** Deliver responsive components, accessibility/keyboard navigation, and state transitions without mock data fallbacks.
5. **Phase 5 — Key-Parallel i18n (`vi`/`en`) & Light/Dark Theme Audit:** Synchronize translation namespaces and verify semantic color tokens across Light and Dark modes.
6. **Phase 6 — Multi-Layer Verification:** Execute unit, integration, contract, and browser/mobile E2E suites documented in [test.md](./test.md).

## 5. Localization (`vi.json` + `en.json`), Theme Tokens & Observability Plan

- **Key-Parallel Locale Synchronization:** Every new or updated label in `dashboard.*`, `agency.invite.emailLanguage`, `workspace.duplicate.*`, `landing.replacedApps.*` in `src/i18n/locales/{vi,en}/*.json` is committed simultaneously in `vi` and `en` bundles on `brandhub-web` and mirrored in `brandhub-mobile-app/src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` (verified by `mobileI18nParity.test.ts` and `i18nCoverage.test.ts`).
- **Light & Dark Theme Architecture:** Web components rely exclusively on semantic CSS custom properties (`bg-background`, `bg-card`, `text-foreground`, `text-muted-foreground`, `border-border`) and paired `dark:` utility classes; Mobile components consume `useAppPreferences().palette` (`src/theme/tokens.ts`) verified by `tokens.test.ts`.
- **Structured Telemetry & Rollback Safety:** Every boundary logs `X-Request-Id`, latency, and classified `ErrorCode` while redacting tokens/PII. Additive schema migrations preserve backward-compatible rollback without dropping historical audit or ledger data.

## 6. Engineering Risks & Mitigations

- **Timezone Drift Between Browser and Server:** Mitigated by passing explicit IANA `timezone` and serializing ISO-8601 `OffsetDateTime` timestamps.
### Hiển thị việc cần xử lý trên Web

Tái sử dụng dữ liệu overview và mã drill của `components/dashboard`, dùng chung cache tại Sidebar và giữ cập nhật khi thao tác. Thay các thẻ Workspace tính từ danh sách xem trước bằng KpiStrip. Cập nhật nhãn phạm vi trong `src/i18n/locales/{vi,en}/dashboard.json`. Dùng lại tuyến và quyền hiện hành.
