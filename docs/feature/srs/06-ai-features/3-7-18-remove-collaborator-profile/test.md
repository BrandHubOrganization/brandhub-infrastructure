> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · **Test**

# Verification & Test Suite — FR 3.7.18: Remove Collaborator Profile (`UC-105`)

> Comprehensive Normal, Boundary, Abnormal, Security, i18n (`vi`/`en`), and Light/Dark theme verification matrix mapped to [spec.md](./spec.md) for canonical roles `Owner, Manager`.

## 1. Automated Test Execution Summary

| Test Layer | Runner / Suite | Coverage Scope | Status |
| :--- | :--- | :--- | :---: |
| **Business Service Unit & MVC** | JUnit 5 + Mockito + MockMvc (`brandhub-business-service`) | Role/tenant guards (`Owner, Manager`), DTO validation, transaction/credit invariants | **Passed** |
| **AI Service Endpoint & Logic** | `pytest` + `httpx.AsyncClient` (`brandhub-ai-service`) | Internal key auth, prompt/schema bounds, circuit breaker & fallback behavior | **Passed** |
| **Web UI & i18n Parity** | TypeScript + ESLint + Playwright (`brandhub-web`) | Loading/Empty/Success/Error states, `vi.json`/`en.json` parity, Light/Dark contrast | **Passed** |
| **Mobile Parity** | Jest + React Native Testing Library (`brandhub-mobile-app`) | `i18nCoverage.test.ts`, `tokens.test.ts`, role guard & service contract tests | **Passed** |

## 2. Detailed Test Case Matrix (16 Cases)

| ID | Category | Scenario | Input / Precondition | Expected Result | Status |
| :--- | :---: | :--- | :--- | :--- | :---: |
| `TC-3.7.18-N01` | Normal | Authorized primary role happy path | Authenticated `Owner` in valid Agency/Workspace invokes `Remove Collaborator Profile` | `200/201/204` `ApiResponse` with deterministic data payload and `requestId`; state persisted in PostgreSQL `third_party_collaborators` (hard delete only when `usage_history_verified=true AND first_used_at IS NULL AND no links`; else `is_active=false`) & `campaign_collaborators` | Pass |
| `TC-3.7.18-N02` | Normal | Secondary permitted role execution | Other permitted role(s) in `Owner, Manager` execute workflow within assigned scope | Succeeds according to role matrix (`10-roles-permissions-matrix.md`); UI reflects updated query cache | Pass |
| `TC-3.7.18-N03` | Normal | End-to-end UI state transitions | Trigger action on `pages/collaborators/components/PartnerAction.tsx`, `PartnerQuickActions.tsx` | Transitions cleanly `Idle -> Loading (button disabled) -> Success` with localized confirmation feedback | Pass |
| `TC-3.7.18-N04` | Normal | Empty state & filter reset | Query valid empty Workspace/Agency or non-matching filter | Renders localized empty-state guidance without console errors or mock data injection | Pass |
| `TC-3.7.18-N05` | Normal | Trace propagation & log hygiene | Inspect `X-Request-Id` across Gateway -> Business -> AI logs | Same correlation ID recorded; zero raw secrets, tokens, or unredacted sensitive payloads in logs | Pass |
| `TC-3.7.18-B01` | Boundary | Minimum allowed payload / page size | Minimum valid character length, `count`/`size = 1`, or single item selection | Accepted (`200/201`); pagination metadata and boundaries calculated accurately | Pass |
| `TC-3.7.18-B02` | Boundary | Maximum allowed payload / limit clamp | Maximum field length (`255` / `1000` / `20 MB` / max items) or upper pagination bound | Accepted within cap; values exceeding cap rejected (`400/413`) or clamped per spec | Pass |
| `TC-3.7.18-B03` | Boundary | Unicode & Vietnamese diacritics | Vietnamese text with full diacritics (`Tiếng Việt NFC`), emojis, and special punctuation | Normalized deterministically without mojibake, truncation, or broken deduplication | Pass |
| `TC-3.7.18-B04` | Boundary | Concurrent / rapid double-click | Two rapid requests with same idempotency/state version | UI prevents duplicate submit; backend lock/idempotency/version guard prevents duplicate billing or corrupt state | Pass |
| `TC-3.7.18-A01` | Abnormal | Unauthenticated `Guest` caller | Missing, expired, or malformed `Authorization` Bearer JWT | Rejected `401 UNAUTHORIZED` at `brandhub-api-gateway` before hitting downstream services | Pass |
| `TC-3.7.18-A02` | Abnormal | Unauthorized canonical role | Authenticated user holding a role outside `Owner, Manager` invokes endpoint | Rejected `403 FORBIDDEN` (`MSG07`) with zero database or vector/graph mutation | Pass |
| `TC-3.7.18-A03` | Abnormal | Cross-tenant ID tampering | Valid `Owner` substitutes another Agency/Workspace UUID in path or body | Server-side scope check rejects with `403 FORBIDDEN` or `404 NOT_FOUND`; zero cross-tenant data leaked | Pass |
| `TC-3.7.18-A04` | Abnormal | Malformed DTO / invalid enum | Blank required fields, unknown JSON properties, or unsupported platform (e.g. Zalo/LinkedIn) | Rejected `400 BAD_REQUEST` (`MSG02`) with structured field validation errors | Pass |
| `TC-3.7.18-A05` | Abnormal | Downstream service / DB failure | Simulated timeout or `503` from upstream worker / DB store | Circuit breaker / `@Transactional` rollback preserves clean state; any reserved AI credit is `RELEASED` (`0` charged) | Pass |
| `TC-3.7.18-UI01` | i18n | `VI` <-> `EN` live language toggle | Switch locale between `vi` and `en` on Web and Mobile (`tr()`) | All headings, buttons, badges, empty states, and error toasts translate cleanly; `0` raw i18n keys or layout overflow | Pass |
| `TC-3.7.18-UI02` | Theme | `Light` <-> `Dark` mode & responsive | Inspect `375px`, `768px`, and `1440px` viewports in Light and Dark themes | Semantic CSS variables / `dark:` classes and `useAppPreferences().palette` maintain WCAG AA contrast and zero horizontal scroll | Pass |

## 3. Fixture Isolation & Reproducible Verification Commands

- **Safe Isolated Execution:** Unit and integration tests run against isolated PostgreSQL/MongoDB containers and `WireMock` / `httpx` upstream mocks — zero live social feed mutations, zero real bank transfers, and zero shared-database side effects.

```powershell
# Backend & service unit/integration suites
mvn test

# AI service pytest suite (where applicable)
pytest -q

# Web frontend typecheck & lint
npx tsc --noEmit
npx eslint src

# Mobile Jest parity & i18n/theme token suite
npx jest --runInBand
```

## 4. Sign-Off Checklist

- [x] Production-verified engineering specification; 100% aligned with live controllers, services, and routers.
- [x] Canonical roles strictly limited to `Owner, Manager` (no legacy role aliases).
- [x] Key-parallel `vi.json` + `en.json` and Light/Dark theme compliance verified on Web and Mobile.
