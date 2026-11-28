> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.7.17: Update Collaborator Profile (`UC-104`)

## 1. Architectural Scope & Touched Repositories

Implements **FR 3.7.17 — Update Collaborator Profile** ([spec.md](./spec.md)) for canonical roles `Owner, Manager` across the BrandHub polyrepo:

| Layer / Repository | Concrete Classes, Endpoints & Modules |
| :--- | :--- |
| **API Gateway (`brandhub-api-gateway`)** | `InboundSecurityWebFilter.java`, `JwtAuthFilterGatewayFilterFactory.java` (validates JWT, injects `X-User-Id` / `X-Request-Id`), `RateLimitGatewayFilterFactory.java` |
| **Business Service (`brandhub-business-service`)** | `DirectoryPartnerController.java` (`PATCH /api/v1/agencies/{agencyId}/collaborators/{id}`), `CollaboratorController.java` (`PUT /api/v1/collaborators/{collaboratorId}`), `DirectoryPartnerService.update()` |
| **AI Service (`brandhub-ai-service`)** | N/A (Optimistic concurrency `expectedVersion` + JSONB contact merge in `brandhub-business-service`) |
| **Data & Persistence Layer** | PostgreSQL `third_party_collaborators` (`version = version + 1`, preserving `agency_id`, `first_used_at`, `usage_history_verified`, and unknown legacy `contact_info` keys) |
| **Web Application (`brandhub-web`)** | `pages/collaborators/components/PartnerForm.tsx`, `PartnerDetails.tsx`, `PartnerContactFields.tsx` |
| **Mobile App (`brandhub-mobile-app`)** | `src/screens/agency/AgencyCollaboratorsScreen.tsx` (edit partner sheet) |
| **i18n Locale Bundles** | Web: `src/i18n/locales/{vi,en}/collaborators.json` (`collaborators.edit.*`, `collaborators.errors.versionConflict`); Mobile: `src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` (`tr()`) |

## 2. Database Schema, Vector/Graph State & Contracts

1. **Tenant & Role Boundary Enforcement:**
   - Every request resolves caller membership (`Owner, Manager`) against PostgreSQL `agencies`, `agency_members`, and `workspace_members` before executing any data read, AI dispatch, or mutation.
   - Internal `business-service -> ai-service` HTTP calls authenticate via `X-Internal-Api-Key` (`verify_internal_key` in `app/core/security.py`) and propagate `X-Request-Id` for distributed tracing.
2. **Persistence & Credit Accounting Invariants:**
   - Storage targets: PostgreSQL `third_party_collaborators` (`version = version + 1`, preserving `agency_id`, `first_used_at`, `usage_history_verified`, and unknown legacy `contact_info` keys).
   - Where AI inference incurs billable credits (`3.7.6`, `3.7.7`, `3.7.9`, `3.7.11`, `3.7.14`, `3.7.19`), `AiCreditGenerationService` executes the 3-phase `RESERVE -> SETTLE / RELEASE` ledger protocol over `agency_credit_wallets`, `workspace_credit_limits`, `ai_credit_reservations`, and `credit_operations` so upstream timeouts or validation errors release `100%` of reserved credits.
   - Read-only discovery/catalog operations (`3.7.1`, `3.7.2`, `3.7.3`, `3.7.8`, `3.7.10`, `3.7.12`, `3.7.15`) execute at `0` AI Credit cost.

## 3. End-to-End Execution Data Flow

1. **Client Invocation:** Authenticated actor (`Owner, Manager`) triggers `Update Collaborator Profile` from `brandhub-web` or `brandhub-mobile-app`; client disables duplicate-submit triggers and sends typed request with `Authorization: Bearer <token>`.
2. **Gateway & Security Filter:** `brandhub-api-gateway` verifies JWT signature/expiry, enforces per-route Redis token-bucket rate limits, and forwards identity headers to `brandhub-business-service`.
3. **Domain Validation & Authorization:** Controller validates `@Valid` DTO constraints and delegates to domain service to verify `Owner, Manager` scope, Agency/Workspace ownership, and entitlement/credit preconditions.
4. **Core Processing / AI Pipeline Dispatch:** Domain service executes atomic persistence and/or dispatches internal request to `brandhub-ai-service` with circuit-breaker timeout guards and structured error classification.
5. **UI Cache & State Reconciliation:** Standardized `ApiResponse<T>` returns to client; `TanStack Query` invalidates affected query keys and renders localized (`vi`/`en`) feedback in Light/Dark semantic tokens.

## 4. Sequential Build Order

1. **Step 1 — Schema & Contracts:** Verify PostgreSQL migrations (`init-postgres-v2.sql` + incremental `database/migrations/postgres/*.sql`), Pydantic schemas (`brandhub-ai-service/app/schemas/`), and Java request/response DTOs.
2. **Step 2 — AI / Domain Service Logic:** Implement and unit-test core Python/Java service methods, circuit breakers, normalization rules, and optimistic/pessimistic concurrency guards.
3. **Step 3 — REST Controllers & Internal Wiring:** Expose authenticated endpoints in `brandhub-business-service`, wire `RestClient` / `WebClient` internal calls, and map `ErrorCode` HTTP statuses.
4. **Step 4 — Web & Mobile UI Integration:** Build/wire React (`brandhub-web`) and React Native (`brandhub-mobile-app`) screens, `TanStack Query` hooks, loading/empty/error states, and keyboard accessibility.
5. **Step 5 — i18n (`vi.json` + `en.json`) & Light/Dark Theme Polish:** Register key-parallel translations in both locales and verify semantic CSS variables / `useAppPreferences().palette` contrast across Light and Dark modes.
6. **Step 6 — Automated Verification:** Run JUnit 5, `pytest`, TypeScript `tsc --noEmit`, Jest mobile tests, and Playwright UI suites defined in [test.md](./test.md).

## 5. Localization (`vi.json` + `en.json`), Theme Tokens & API Envelope Contract

- **Standardized `ApiResponse<T>` Contract:** All JSON endpoints return `{ "success": boolean, "data": T, "error": { "code", "message" } | null, "requestId": string }` with deterministic HTTP status mapping (`200/201/204` success; `400` validation; `401` unauthenticated; `402` insufficient credit; `403` role/tenant forbidden; `404` scoped not found; `409` version/idempotency conflict; `429` rate limit; `503` upstream unavailable).
- **Key-Parallel i18n Synchronization:** All UI strings are added simultaneously in `vi.json` and `en.json` on `brandhub-web` and mirrored via `tr()` (`src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json`) on `brandhub-mobile-app` — zero hardcoded Vietnamese or English text in JSX/TSX.
- **Semantic Light & Dark Mode Styling:** Web components use CSS custom properties and Tailwind `dark:` variants; Mobile screens use `useAppPreferences().palette` (`src/theme/tokens.ts`), maintaining WCAG AA contrast across Light and Dark modes.

## 6. Engineering Risks & Mitigations

- **Cross-Tenant Context Leakage:** Never accept `workspace_id`, `agency_id`, or candidate arrays blindly from client payloads; always derive or re-query server-side after authorization.
- **Upstream LLM / Worker Latency or Outage:** Enforce bounded timeouts, fallback model routing (`Groq <-> Gemini`), and automatic `RELEASE` of reserved AI credits on `502/503/504` failures.
- **Stale Concurrent Writes:** Enforce `@Version` optimistic locking (`expectedVersion`) and deterministic PostgreSQL row locking on shared directory and campaign records.
