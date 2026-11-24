> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · **Task** · [Test](./test.md)

# Task Checklist — FR 3.10.10: View AI Credit Price List (`UC-137`)

> Sequential implementation checklist mapped from [spec.md](./spec.md) and [plan.md](./plan.md) for canonical roles `Owner, Admin`.

## 1. Schema, Contracts & Authorization (Plan §1–§2)

- [x] **T01 — Verify Database Schema & Indexes:** Confirm tables/collections and constraints in PostgreSQL `ai_credit_operation_prices` (immutable versioned operation catalog) match `init-postgres-v2.sql` and incremental migrations.
- [x] **T02 — Define Validated DTOs & Error Codes:** Implement `@Valid` request/response records (`BIGINT`-safe string/long serialization) and deterministic `ErrorCode` mappings (`MSG01, MSG03, MSG07`).
- [x] **T03 — Enforce Server-Side `Owner, Admin` Guards:** Verify live role/ownership checks (`AdminAccountService.requireAdmin` or Agency `Owner`/member checks) rejecting unauthorized and IDOR requests.

## 2. Core Service & Transactional Logic (Plan §2–§3)

- [x] **T04 — Implement Domain Rules (`BR-30, BR-65`):** Deliver core business rules, deterministic lock ordering, and `expectedRevision` / `Idempotency-Key` concurrency guards.
- [x] **T05 — Wire Audit & Side-Effect Isolation:** Persist structured audit entries (`audit_logs` / `billing_audit_events` / `admin_account_operations`) inside transactions while keeping external HTTP lookups outside DB transactions.

## 3. Web & Mobile UI Integration (Plan §4)

- [x] **T06 — Integrate Web Components (`brandhub-web`):** Connect typed API services and user/agency-scoped `TanStack Query` hooks to `pages/credit/prices.tsx` (`CreditPriceKpiRow.tsx`, `CreditCatalog.tsx`), `pages/credit/index.tsx` (read-only catalog card for `Owner`).
- [x] **T07 — Implement Complete UI States:** Deliver accessible Loading, Empty, Success, and `409`/Validation Error recovery states without mock fallbacks.
- [x] **T08 — Integrate Mobile Screens (`brandhub-mobile-app`):** Align `src/screens/admin/AdminCreditPricesScreen.tsx`, `src/screens/billing/AgencyCreditScreen.tsx` under Expo SDK 58 / RN 0.88 role-based navigation (`AppNavigator`).

## 4. Internationalization (i18n) & Light/Dark Theme (Plan §5)

- [x] **T09 — Synchronize `vi.json` + `en.json` Locales:** Add key-parallel translations (`credit.catalog.*`, `credit.unit.*`, `credit.operation.*`, `credit.csv.featurePricing` in `src/i18n/locales/{vi,en}/credit.json`) on Web and `en.json` + `vi/common.json` (`tr()`) on Mobile with zero hardcoded strings.
- [x] **T10 — Verify Light & Dark Mode Contrast:** Validate cards, tables, drawers, charts, and modals in both Light and Dark themes (`375px / 768px / 1440px`) using semantic tokens and `useAppPreferences().palette`.

## 5. Observability, Accessibility & Operational Readiness

- [x] **T10a — Trace Correlation & Log Redaction:** Verify `X-Request-Id` propagates across Gateway, Business, and downstream services while redacting JWTs, OAuth tokens, webhook secrets, and API keys from logs.
- [x] **T10b — Keyboard Navigation & Responsive Layout:** Verify `Tab` focus order, `Enter`/`Escape` dialog handling, focus restoration on drawer/modal close, and zero horizontal overflow at `375px`, `768px`, and `1440px`.
- [x] **T10c — Scoped Query Cache Hygiene:** Scope all `TanStack Query` cache keys by authenticated `userId` and active `agencyId` / `workspaceId` so switching tenants never flashes stale data.
- [x] **T10d — Schema & Seed Idempotency:** Confirm database migrations and seeders run idempotently (`ON CONFLICT DO NOTHING` / `IF NOT EXISTS`) without mutating unrelated historical records.
- [x] **T10e — Duplicate-Submit & Race-Condition Guard:** Confirm UI mutation buttons disable while in-flight and backend enforces optimistic version / idempotency locks (`409` on conflict).
- [x] **T10f — ErrorCode-to-i18n Mapping:** Confirm every domain `ErrorCode` maps to a localized user-facing toast/banner in both `vi` and `en` without exposing raw stack traces.
- [x] **T10g — API Gateway Route & Rate-Limit Alignment:** Confirm route matching, timeout budget, and rate-limit replenish thresholds in `brandhub-api-gateway`.
- [x] **T10h — Documentation & SRS Traceability Sync:** Confirm 1-to-1 alignment between `spec.md`, `plan.md`, `task.md`, `test.md`, and the canonical BA baseline.

## 5. Automated Verification (Plan §6)

- [x] **T11 — Backend Unit, Concurrency & Integration Tests:** Pass JUnit 5 + MockMvc + isolated DB tests covering all cases in [test.md](./test.md).
- [x] **T12 — Web & Mobile Regression Gates:** Pass `tsc --noEmit`, ESLint, Jest (`SubscriptionPlansScreen.test.tsx` / `AdminScreens.test.tsx` / `i18nCoverage.test.ts`), and Playwright E2E checks.

## 7. Lifecycle Artefact Traceability (`feature-workflow.md`)

| Workflow Stage | Artefact | Responsibility Verified |
| :--- | :--- | :--- |
| **Stage 1 — Business Specification** | [spec.md](./spec.md) | Canonical roles, acceptance criteria, API contract, i18n (`vi`/`en`) & Light/Dark rules |
| **Stage 2 — Technical Plan** | [plan.md](./plan.md) | Touched repositories/classes, schema invariants, data flow, build order & risks |
| **Stage 3 — Implementation Checklist** | `task.md` (this file) | Sequential backend, frontend, mobile, i18n, theme, and observability tasks |
| **Stage 4 — Verification Matrix** | [test.md](./test.md) | 16-case Normal/Boundary/Abnormal/Security/i18n/Theme suite & CLI commands |
