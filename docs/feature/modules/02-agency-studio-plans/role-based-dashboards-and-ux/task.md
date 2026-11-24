> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · **Task** · [Test](./test.md)

# Implementation Checklist — Three-Tier Role-Based Dashboards, Workspace UX, Timezone Consistency & Duplicate Workspace (`role-based-dashboards-and-ux`)

> Verifiable sequential task breakdown mapped to [spec.md](./spec.md) and [plan.md](./plan.md), consolidating `role-based-dashboards`, `dashboard-experience`, `agency-profile-presentation`, `agency-invitation-email-language`, `workspace-timezone-consistency`, `navigation-ux-linked-demo-data`, `landing-lab-replaced-apps`, `admin-ui-consistency`, `duplicate-workspace`.

## 1. Schema, Infrastructure & Contracts (Plan §1–§2)

- [x] **T01 — Finalize Schema & Indexes:** Verify DDL/collection definitions, foreign keys, and indexes across PostgreSQL `agencies`, `agency_invitations`, `workspaces`, `workspace_members`, `tasks`, `media_campaigns`; MongoDB `posts`, `content_requests`, `materials` for fresh init and incremental upgrades.
- [x] **T02 — Define Validated DTOs & Protocol Schemas:** Implement strict request/response models, enums, and `ErrorCode` mappings across `DashboardAnalyticsController.java`, `AgencyController.java`, `WorkspaceController.java`.
- [x] **T03 — Harden Gateway & Service Security:** Enforce JWT/internal-key authentication, header sanitization, rate limiting, and canonical role checks (`Guest, Owner, Manager, Creator, Client, Admin`).

## 2. Backend, Realtime & Worker Execution (Plan §2–§3)

- [x] **T04 — Implement Core Domain Logic:** Deliver transactional service workflows, concurrency locks (`expectedVersion` / `Idempotency-Key`), and tenant isolation guards.
- [x] **T05 — Wire Async / Streaming / External Integrations:** Configure bounded timeouts, retry/backoff policies, resource cleanup, and structured trace-correlated logging (with secret redaction).
- [x] **T06 — Ensure Backward & Cross-Client Compatibility:** Verify Web and Mobile clients share consistent API contracts without breaking existing persisted records.

## 3. Web & Mobile Frontend Delivery (Plan §4)

- [x] **T07 — Build & Connect Web UI (`brandhub-web`):** Implement `pages/dashboard/index.tsx`, `pages/agency/dashboard/index.tsx`, `pages/workspace/dashboard.tsx`, `components/dashboard/*`, `DuplicateWorkspaceDialog.tsx`, `AgencyDetailLivePreview.tsx`, `TimezoneSelect.tsx` wired to typed Axios/`TanStack Query` hooks with scoped `(userId, agencyId, workspaceId)` cache keys.
- [x] **T08 — Deliver Complete UX States & Accessibility:** Support Loading skeletons, Empty guidance, Success feedback, `409`/Error recovery, focus management, and `Escape` keyboard handling.
- [x] **T09 — Align Mobile Experience (`brandhub-mobile-app`):** Synchronize `src/screens/dashboard/HomeDashboardScreen.tsx`, `DashboardScreen.tsx`, `src/services/dashboardAnalyticsService.ts` under Expo SDK 58 / RN 0.88 role parity (`AppNavigator`, `withAccess.tsx`).

## 4. Internationalization (i18n) & Light/Dark Theme (Plan §5)

- [x] **T10 — Update `vi.json` + `en.json` in Parallel:** Populate all UI keys in `dashboard.*`, `agency.invite.emailLanguage`, `workspace.duplicate.*`, `landing.replacedApps.*` in `src/i18n/locales/{vi,en}/*.json` and mobile locale files (`en.json` + `vi/common.json`) with zero hardcoded strings.
- [x] **T11 — Audit Light & Dark Mode Tokens:** Verify contrast, borders, overlays, and charts across `375px`, `768px`, and `1440px` in Light and Dark themes (`dark:` variants & `useAppPreferences().palette`).

## 5. Observability, Security Hygiene & Rollout Readiness (Plan §5–§6)

- [x] **T12 — Verify `X-Request-Id` Correlation & Secret Redaction:** Confirm gateway, backend, and worker logs propagate `X-Request-Id` and never emit raw JWTs, OAuth tokens, internal keys, or unmasked credentials.
- [x] **T13 — Verify Migration Idempotency & Rollback Safety:** Confirm `init-postgres-v2.sql` and incremental migrations execute cleanly on fresh and existing isolated schemas without destructive column drops.
- [x] **T14 — Remove Stale Mock / Prototype Fallbacks:** Confirm `brandhub-web` and `brandhub-mobile-app` query authoritative backend endpoints with zero hardcoded mock arrays.
- [x] **T14a — Keyboard & Screen-Reader Accessibility:** Verify `Tab` focus rings, `Escape` modal dismissal, focus restoration, and ARIA labels across interactive controls.
- [x] **T14b — Responsive Breakpoint Audit:** Verify zero horizontal overflow and clean card/drawer stacking across `375px` (mobile), `768px` (tablet), and `1440px` (desktop).
- [x] **T14c — Cross-Tenant Cache Isolation:** Confirm `TanStack Query` and Zustand stores clear or re-scope cleanly upon switching `userId`, `agencyId`, or `workspaceId`.
- [x] **T14d — Rate-Limit & Timeout Resilience:** Verify bounded HTTP/WebSocket timeouts, graceful stream abort handling, and retryable UI error states.

## 6. Automated Verification & CI Sign-Off (Plan §6)

- [x] **T15 — Backend & Worker Test Suites:** Pass JUnit 5 (`mvn test`) and/or `pytest` suites covering normal, boundary, concurrency (`409`), and cross-tenant security (`401/403/404`) scenarios in [test.md](./test.md).
- [x] **T16 — Web Typecheck, Lint & Browser Verification:** Pass `npx tsc --noEmit`, ESLint, and Playwright responsive checks (`375px`, `768px`, `1440px`) in `VI`/`EN` and `Light`/`Dark` modes.
- [x] **T17 — Mobile Parity & Native Guard Suite:** Pass Jest (`npx jest`) including `i18nCoverage.test.ts`, `tokens.test.ts`, and screen/service unit suites.

## 7. Lifecycle Artefact Traceability (`feature-workflow.md`)

| Workflow Stage | Artefact | Responsibility Verified |
| :--- | :--- | :--- |
| **Stage 1 — Business Specification** | [spec.md](./spec.md) | Canonical roles, acceptance criteria, API contract, i18n (`vi`/`en`) & Light/Dark rules |
| **Stage 2 — Technical Plan** | [plan.md](./plan.md) | Touched repositories/classes, schema invariants, data flow, build order & risks |
| **Stage 3 — Implementation Checklist** | `task.md` (this file) | Sequential backend, frontend, mobile, i18n, theme, and observability tasks |
| **Stage 4 — Verification Matrix** | [test.md](./test.md) | 16-case Normal/Boundary/Abnormal/Security/i18n/Theme suite & CLI commands |
