> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · **Task** · [Test](./test.md)

# Task Checklist — FR 3.7.4: Upload Brand Knowledge Document (`UC-091`)

> Sequential, verifiable implementation checklist mapped directly to [spec.md](./spec.md) and [plan.md](./plan.md) for canonical roles `Owner, Manager, Client`.

## 1. Schema, DTOs & Service Contracts (Plan §1–§2)

- [x] **T01 — Verify Data & Storage Schema:** Confirm schema parity and indexes across AWS S3 (`workspaces/{workspaceId}/knowledge/*`), ChromaDB (`brand_docs_{workspace_id}`), PostgreSQL `agency_storage_usage` in `database/init/init-postgres-v2.sql` and incremental migrations.
- [x] **T02 — Define Request/Response Contracts:** Implement and validate Java DTOs (`@Valid`, Jakarta Bean Validation) in `brandhub-business-service` and matching Pydantic v2 models in `brandhub-ai-service` (where applicable).
- [x] **T03 — Standardize Error Codes:** Register deterministic `ErrorCode` mappings (`400`, `402`, `403`, `404`, `409`, `422`, `503`) with trace-correlated `requestId` in `ApiResponse<T>`.

## 2. Backend & AI Pipeline Implementation (Plan §2–§3)

- [x] **T04 — Enforce Role & Tenant Guards:** Verify canonical role access (`Owner, Manager, Client`) and strict Workspace/Agency ownership inside Workspace Brand Knowledge upload handler in `brandhub-business-service` + S3 storage quota reservation (`agency_storage_usage`) (`403 FORBIDDEN` on unauthorized role or cross-tenant IDs).
- [x] **T05 — Implement Core Domain / AI Service Logic:** Deliver production logic in `app/api/v1/endpoints/rag.py` (`POST /ai/rag/documents`), `app/utils/extractor.py` (PDF/DOCX/TXT/MD parser), `app/services/vector_store_service.py` and Business domain services with bounded pagination/limits, input sanitization, and redaction of sensitive credentials in logs.
- [x] **T06 — Wire Transactional & Credit Safety:** Ensure `@Transactional` rollback integrity, optimistic/pessimistic locks where applicable, and `RESERVE -> SETTLE / RELEASE` credit accounting safety.

## 3. Frontend Web & Mobile Integration (Plan §4)

- [x] **T07 — Wire Typed API Client & TanStack Query:** Connect typed service methods and query/mutation cache invalidation for `pages/ai-studio/knowledge-base/index.tsx` (Multipart dropzone, progress indicator, `AiStudioErrorBanner.tsx`).
- [x] **T08 — Implement Complete UI Lifecycle States:** Build `Loading` (skeleton/disabled duplicate-submit), `Empty` (guided action state), `Success` (toast + live state update), and `Error` (retryable inline banner without mock fallback).
- [x] **T09 — Align Mobile Experience (`brandhub-mobile-app`):** Synchronize mobile screens/services (Read-only status visibility on `brandhub-mobile-app` (`AiHubScreen.tsx`)) under Expo SDK 58 / RN 0.88 navigation access rules (`withAccess.tsx`).

## 4. Internationalization (i18n) & Light/Dark Theme (Plan §5)

- [x] **T10 — Key-Parallel `vi.json` + `en.json` Updates:** Add all labels, placeholders, tooltips, confirmation modals, and error messages simultaneously in `src/i18n/locales/{vi,en}/aiStudio.json` (`aiStudio.knowledgeBase.upload.*`, `aiStudio.knowledgeBase.errors.*`) and mobile locale bundles (`en.json` + `vi/common.json`) — zero hardcoded text in JSX/TSX.
- [x] **T11 — Light & Dark Mode Verification:** Audit all surfaces, badges, inputs, modals, and charts in both Light and Dark themes using semantic CSS tokens / Tailwind `dark:` variants and `useAppPreferences().palette` (WCAG AA contrast, zero single-theme hex leaks).

## 5. Observability, Accessibility & Operational Readiness

- [x] **T10a — Trace Correlation & Log Redaction:** Verify `X-Request-Id` propagates across Gateway, Business, and downstream services while redacting JWTs, OAuth tokens, webhook secrets, and API keys from logs.
- [x] **T10b — Keyboard Navigation & Responsive Layout:** Verify `Tab` focus order, `Enter`/`Escape` dialog handling, focus restoration on drawer/modal close, and zero horizontal overflow at `375px`, `768px`, and `1440px`.
- [x] **T10c — Scoped Query Cache Hygiene:** Scope all `TanStack Query` cache keys by authenticated `userId` and active `agencyId` / `workspaceId` so switching tenants never flashes stale data.
- [x] **T10d — Schema & Seed Idempotency:** Confirm database migrations and seeders run idempotently (`ON CONFLICT DO NOTHING` / `IF NOT EXISTS`) without mutating unrelated historical records.
- [x] **T10e — Duplicate-Submit & Race-Condition Guard:** Confirm UI mutation buttons disable while in-flight and backend enforces optimistic version / idempotency locks (`409` on conflict).
- [x] **T10f — ErrorCode-to-i18n Mapping:** Confirm every domain `ErrorCode` maps to a localized user-facing toast/banner in both `vi` and `en` without exposing raw stack traces.
- [x] **T10g — API Gateway Route & Rate-Limit Alignment:** Confirm route matching, timeout budget, and rate-limit replenish thresholds in `brandhub-api-gateway`.
- [x] **T10h — Documentation & SRS Traceability Sync:** Confirm 1-to-1 alignment between `spec.md`, `plan.md`, `task.md`, `test.md`, and the canonical BA baseline.

## 5. Automated Testing & Regression Sign-Off (Plan §6)

- [x] **T12 — Backend & AI Unit/Integration Tests:** Execute JUnit 5 (`mvn test`) and `pytest` suites covering normal, boundary, authorization, and upstream-failure scenarios in [test.md](./test.md).
- [x] **T13 — Frontend Build, Lint & Browser/Mobile Verification:** Pass `tsc --noEmit`, ESLint, Jest (`i18nCoverage.test.ts`), and responsive `375px / 768px / 1440px` `VI`/`EN` + `Light`/`Dark` checks.

## 7. Lifecycle Artefact Traceability (`feature-workflow.md`)

| Workflow Stage | Artefact | Responsibility Verified |
| :--- | :--- | :--- |
| **Stage 1 — Business Specification** | [spec.md](./spec.md) | Canonical roles, acceptance criteria, API contract, i18n (`vi`/`en`) & Light/Dark rules |
| **Stage 2 — Technical Plan** | [plan.md](./plan.md) | Touched repositories/classes, schema invariants, data flow, build order & risks |
| **Stage 3 — Implementation Checklist** | `task.md` (this file) | Sequential backend, frontend, mobile, i18n, theme, and observability tasks |
| **Stage 4 — Verification Matrix** | [test.md](./test.md) | 16-case Normal/Boundary/Abnormal/Security/i18n/Theme suite & CLI commands |
