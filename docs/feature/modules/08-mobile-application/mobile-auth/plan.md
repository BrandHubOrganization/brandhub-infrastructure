> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Technical Implementation Plan — Mobile Authentication, Deep-Link Google OAuth, 2FA Verify & Biometric App Lock (`mobile-auth`)

## 1. System Components & Touched Repositories

Consolidates the technical architecture for `mobile-auth`, `mobile-native-enhancements (Biometric AppLockGate & SecureStore)` as specified in [spec.md](./spec.md):

| Layer / Repository | Key Classes, Services, Schemas & Components |
| :--- | :--- |
| **API Gateway (`brandhub-api-gateway`)** | `GatewayConfig.java` (`/api/v1/auth/**` + rate limiting) |
| **Backend / Worker Services** | `AuthController.java`, `GoogleOAuthController.java`, `AccountActivationController.java` |
| **Persistence, Cache & Brokers** | Device `expo-secure-store` (tokens & lock timestamps); PostgreSQL `users`, `user_oauth_providers`, `user_refresh_tokens`, `account_activation_tokens` |
| **Web Frontend (`brandhub-web`)** | Parity with `pages/auth/{LoginPage,RegisterPage,VerifyOtpPage,TwoFactorVerifyPage,OAuthCallbackPage,ActivateAccountPage}.tsx` |
| **Mobile App (`brandhub-mobile-app`)** | `src/navigation/AuthNavigator.tsx`, `src/screens/auth/*`, `src/screens/settings/SecuritySettingsScreen.tsx`, `src/components/common/AppLockGate.tsx`, `src/store/{authStore,deviceFeaturesStore}.ts` |
| **i18n & Theme Assets** | `src/i18n/locales/en.json` & `src/i18n/locales/vi/common.json` (`auth.*`, `security.appLock.*`, `api-errors.vi.json` via `tr()`); Mobile `src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` & `src/theme/tokens.ts` |

## 2. Core Technical Design & Data Model Invariants

- **Overlay Gate Without Unmounting Navigation Tree (`AppLockGate`):** Renders above `AppNavigator` so unlocking returns to the exact in-progress editor draft or S3 multipart upload without state loss.
- **Deep-Link Prefix Registry:** `expo-linking` binds `brandhub://` custom scheme for OAuth callback, password reset, account activation, and invitation acceptance.

## 3. End-to-End Data & Control Flow

1. **Ingress & Identity Propagation:** Requests pass through `brandhub-api-gateway` (`InboundSecurityWebFilter` -> `JwtAuthFilterGatewayFilterFactory` -> `RateLimitGatewayFilterFactory`), stripping external header spoofing and injecting verified `X-User-Id`, `X-Request-Id`, and role claims.
2. **Authorization & Invariant Validation:** Downstream controllers and services re-verify canonical role permissions (`Guest, Owner, Manager, Creator, Client, Admin`) and Agency/Workspace tenant membership against authoritative database state before mutating data or dispatching async jobs.
3. **Atomic Persistence & Event Fan-Out:** State transitions commit atomically across Device `expo-secure-store` (tokens & lock timestamps); PostgreSQL `users`, `user_oauth_providers`, `user_refresh_tokens`, `account_activation_tokens` using optimistic (`@Version` / `expectedRevision`) or pessimistic locks, emitting outbox/WebSocket/`pg_notify` events after commit.
4. **Client State Reconciliation:** `brandhub-web` and `brandhub-mobile-app` consume typed `ApiResponse<T>` envelopes, update user/tenant-scoped `TanStack Query` caches, and render localized UI states in Light and Dark themes.

## 4. Sequential Implementation & Rollout Order

1. **Phase 1 — Database / Storage / Config Baseline:** Apply additive migrations in `database/init/init-postgres-v2.sql` and `database/migrations/postgres/*.sql` (plus MongoDB/Neo4j/Redis indexes) with repeat-run idempotency.
2. **Phase 2 — Domain Services & Security Guards:** Implement core service logic, cryptographic/concurrency helpers, and internal service-to-service contracts.
3. **Phase 3 — Public REST / WebSocket / Worker Endpoints:** Wire controllers, consumers, and exception handlers returning standardized `ErrorCode` payloads.
4. **Phase 4 — Web & Mobile UI Surfaces:** Deliver responsive components, accessibility/keyboard navigation, and state transitions without mock data fallbacks.
5. **Phase 5 — Key-Parallel i18n (`vi`/`en`) & Light/Dark Theme Audit:** Synchronize translation namespaces and verify semantic color tokens across Light and Dark modes.
6. **Phase 6 — Multi-Layer Verification:** Execute unit, integration, contract, and browser/mobile E2E suites documented in [test.md](./test.md).

## 5. Localization (`vi.json` + `en.json`), Theme Tokens & Observability Plan

- **Key-Parallel Locale Synchronization:** Every new or updated label in `src/i18n/locales/en.json` & `src/i18n/locales/vi/common.json` (`auth.*`, `security.appLock.*`, `api-errors.vi.json` via `tr()`) is committed simultaneously in `vi` and `en` bundles on `brandhub-web` and mirrored in `brandhub-mobile-app/src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` (verified by `mobileI18nParity.test.ts` and `i18nCoverage.test.ts`).
- **Light & Dark Theme Architecture:** Web components rely exclusively on semantic CSS custom properties (`bg-background`, `bg-card`, `text-foreground`, `text-muted-foreground`, `border-border`) and paired `dark:` utility classes; Mobile components consume `useAppPreferences().palette` (`src/theme/tokens.ts`) verified by `tokens.test.ts`.
- **Structured Telemetry & Rollback Safety:** Every boundary logs `X-Request-Id`, latency, and classified `ErrorCode` while redacting tokens/PII. Additive schema migrations preserve backward-compatible rollback without dropping historical audit or ledger data.

## 6. Engineering Risks & Mitigations

- **Cross-Account Notification Leakage on Shared Device:** Sign-out atomically cancels all `expo-notifications` local reminders (`taskReminders.ts`) and clears Zustand/Query stores.
