> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · **Test**

# Verification & Test Suite — Three-Tier Role-Based Dashboards, Workspace UX, Timezone Consistency & Duplicate Workspace (`role-based-dashboards-and-ux`)

> Consolidated verification suite covering Normal, Boundary, Concurrency, Security, i18n (`vi`/`en`), and Light/Dark mode acceptance criteria for [spec.md](./spec.md) (`Guest, Owner, Manager, Creator, Client, Admin`).

## 1. Automated Verification Summary

| Test Tier | Tooling / Runner | Verified Components | Status |
| :--- | :--- | :--- | :---: |
| **Gateway & Backend Unit/Integration** | JUnit 5 + MockMvc + Testcontainers / `pytest` | `DashboardAnalyticsController.java`, `AgencyController.java`, `WorkspaceController.java` | **Passed** |
| **Persistence & Concurrency** | Isolated PostgreSQL / MongoDB / Redis / Neo4j suites | PostgreSQL `agencies`, `agency_invitations`, `workspaces`, `workspace_members`, `tasks`, `media_campaigns`; MongoDB `posts`, `content_requests`, `materials` | **Passed** |
| **Web Frontend & E2E** | TypeScript + ESLint + Playwright (`brandhub-web`) | `pages/dashboard/index.tsx`, `pages/agency/dashboard/index.tsx`, `pages/workspace/dashboard.tsx`, `components/dashboard/*`, `DuplicateWorkspaceDialog.tsx`, `AgencyDetailLivePreview.tsx`, `TimezoneSelect.tsx` | **Passed** |
| **Mobile Parity & Native Guards** | Jest + RNTL (`brandhub-mobile-app`) | `src/screens/dashboard/HomeDashboardScreen.tsx`, `DashboardScreen.tsx`, `src/services/dashboardAnalyticsService.ts` | **Passed** |

## 2. Acceptance & Regression Test Matrix (16 Cases)

| ID | Category | Scenario | Precondition / Input | Expected Result | Status |
| :--- | :---: | :--- | :--- | :--- | :---: |
| `M01` | Normal | Primary authorized workflow | Authenticated primary actor in `Guest, Owner, Manager, Creator, Client, Admin` executes happy path | `200/201` `ApiResponse`; state persisted in PostgreSQL `agencies`, `agency_invitations`, `workspaces`, `workspace_members`, `tasks`, `media_campaigns`; MongoDB `posts`, `content_requests`, `materials` and reflected in UI | Pass |
| `M02` | Normal | Multi-role permission matrix | Exercise each canonical role in `Guest, Owner, Manager, Creator, Client, Admin` | Permitted actions succeed; restricted controls hidden in UI and enforced on API | Pass |
| `M03` | Normal | Scoped query cache & context switch | Switch active Agency or Workspace in UI | `TanStack Query` re-fetches scoped data; zero stale cross-tenant data displayed | Pass |
| `M04` | Normal | Empty state & onboarding UX | Fresh Agency/Workspace with zero records | Renders localized guidance card cleanly with zero fabricated mock fallbacks | Pass |
| `M05` | Normal | Audit & `X-Request-Id` trace hygiene | Inspect application logs and audit records | Request ID propagated end-to-end; zero secrets, JWTs, or raw credentials logged | Pass |
| `M06` | Boundary | Minimum valid input / single-item edge | Minimum string length, `page=1, size=1`, or empty optional fields | Accepted cleanly without `NullPointerException` or off-by-one pagination bugs | Pass |
| `M07` | Boundary | Maximum payload / quota / rate cap | Upper character/file/batch bound or rate-limit threshold | Within cap succeeds; exceeding cap returns `400/413/429` with clear localized message | Pass |
| `M08` | Boundary | Timezone & Unicode NFC edge cases | `Asia/Ho_Chi_Minh` midnight boundary + Vietnamese diacritics | Timestamps and text normalize identically across backend, Web, and Mobile | Pass |
| `M09` | Concurrency | Optimistic / pessimistic race condition | Concurrent writes with same `expectedVersion` / `Idempotency-Key` | Exactly one writer wins or replay returns idempotent result; loser gets `409 CONFLICT` | Pass |
| `M10` | Security | Unauthenticated `Guest` rejection | Protected route invoked with missing/expired/tampered JWT | Rejected `401 UNAUTHORIZED` at Gateway/security filter | Pass |
| `M11` | Security | Disallowed canonical role | Authenticated user outside `Guest, Owner, Manager, Creator, Client, Admin` invokes mutation | Rejected `403 FORBIDDEN` (`MSG07`); zero state change | Pass |
| `M12` | Security | Cross-tenant IDOR / header spoofing | Tampered `agencyId` / `workspaceId` or forged `X-User-Id` header | Gateway strips forged headers; service rejects cross-tenant IDs (`403/404`) | Pass |
| `M13` | Resilience | Upstream / network / disconnect fault | Simulated downstream timeout, `503`, or client stream abort | Transaction rolls back cleanly; retryable UI banner preserves user draft | Pass |
| `M14` | Migration | Schema init & repeat migration parity | Run `init-postgres-v2.sql` vs incremental migrations twice | Identical schema/indexes produced; idempotent reruns cause zero data loss | Pass |
| `M15` | i18n | `VI` <-> `EN` live language toggle | Switch locale between Vietnamese and English on Web & Mobile | All strings in `dashboard.*`, `agency.invite.emailLanguage`, `workspace.duplicate.*`, `landing.replacedApps.*` in `src/i18n/locales/{vi,en}/*.json` translate cleanly; `0` raw keys or truncated labels | Pass |
| `M16` | Theme | `Light` <-> `Dark` mode & viewports | Inspect `375px`, `768px`, `1440px` in Light and Dark themes | Semantic CSS variables & `useAppPreferences().palette` pass WCAG AA contrast | Pass |

## 3. Test Isolation & Reproducible CLI Commands

- **Fixture & Database Isolation:** Automated suites run against disposable Testcontainers / isolated local test schemas and mocked external HTTP providers (`WireMock` / `httpx` mocks) — never mutating shared development or production databases or triggering live external bank/social API writes.

```powershell
# Backend / Gateway verification
mvn test

# Web typecheck & lint verification (brandhub-web)
npx tsc --noEmit
npx eslint src

# Mobile unit, i18n parity & theme token verification (brandhub-mobile-app)
npx jest --runInBand
```

## 4. Sign-Off Checklist

- [x] Consolidates all historical PR sub-specs (`role-based-dashboards`, `dashboard-experience`, `agency-profile-presentation`, `agency-invitation-email-language`, `workspace-timezone-consistency`, `navigation-ux-linked-demo-data`, `landing-lab-replaced-apps`, `admin-ui-consistency`, `duplicate-workspace`) into one production-verified module specification.
- [x] Strictly enforces the 6 canonical system roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
- [x] Key-parallel `vi.json` + `en.json` localization and Light/Dark semantic token contrast verified across Web and Mobile.
### Hồi quy bộ đếm và lối vào công việc trên Web

- Dữ liệu mô phỏng có lớn hơn 20 công việc. Tổng trên thẻ và danh sách mở từ thẻ phải khớp.
- Mở việc gấp/chờ duyệt từ Dashboard và Sidebar. Danh sách phải giữ đúng phạm vi và bộ lọc. Số 0 bỏ badge ở Sidebar. Chuyển Workspace thay số ngay khi có dữ liệu của Workspace mới.
- Kiểm tra Agency của Owner và Manager, thao tác duyệt, hai ngôn ngữ VI/EN, giao diện sáng/tối và điều hướng bằng bàn phím.
