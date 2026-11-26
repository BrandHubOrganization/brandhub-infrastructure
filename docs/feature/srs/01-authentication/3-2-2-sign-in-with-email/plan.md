> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.2.2: Sign In with Email

> Implements [spec.md](./spec.md) — Direct credential sign-in (`POST /api/v1/auth/login`), status & verification gates (`BR-02`, `BR-05`), conditional 2FA TOTP challenge handoff (`FR 3.2.7`), and JWT session issuance.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (`/api/v1/auth/login`, `/api/v1/auth/refresh`), `RateLimitGatewayFilterFactory.java` |
| **Controller** | `brandhub-business-service` | `controller/auth/AuthController.java` (`login`, `refresh`, `me`, `getSessions`, `revokeOtherSessions`) |
| **Service** | `brandhub-business-service` | `service/impl/auth/AuthServiceImpl.java` (`login`, `checkStatus`, `completeLogin`, `refresh`), `util/JwtUtil.java` |
| **DTOs & Errors** | `brandhub-business-service` | `LoginRequest`, `LoginResponse` (`accessToken`, `expiresIn`, `requireTwoFactor`, `twoFactorToken`), `ErrorCode` (`INVALID_CREDENTIALS`, `EMAIL_NOT_VERIFIED`, `ACCOUNT_DEACTIVATED`, `ACCOUNT_SUSPENDED`) |
| **Persistence** | `brandhub-business-service` | `UserRepository`, `UserRefreshTokenRepository`, `AuditLogRepository` |
| **Web Frontend** | `brandhub-web` | `src/pages/auth/LoginPage.tsx`, `src/components/auth/DevQuickLogin.tsx`, `src/services/authService.ts`, `src/stores/authStore.ts` |
| **Mobile App** | `brandhub-mobile-app` | `app/(auth)/login.tsx`, `src/services/authService.ts`, `src/store/authStore.ts` |

## 2. Database & Session Schema

- **PostgreSQL `users`:** Reads normalized `email` / `phone`, `password_hash`, `status` (`ACTIVE` / `DEACTIVATED` / `SUSPENDED`), `email_verified_at`, `two_factor_enabled`, `last_login_at`, `last_password_change`.
- **PostgreSQL `user_refresh_tokens`:** Persists hashed/tracked 30-day refresh session metadata (`user_id`, `token_hash` / `jti`, `device_info`, `ip_address`, `expires_at`, `revoked_at`) enabling active device listing (`/api/v1/auth/sessions`) and rotation.
- **PostgreSQL `audit_logs`:** Records `AuditAction.LOGIN` with `ip_address` and `user_agent`.

## 3. End-to-End Execution Flow

1. **Credential Normalization & Lookup:** `AuthServiceImpl.login()` normalizes `identifier` (lowercase + trim); if no `User` matches or `passwordHash == null` (Google OAuth-only account) or BCrypt verification fails -> returns uniform `401 INVALID_CREDENTIALS` (preventing account enumeration).
2. **Account Lifecycle & Verification Gate (`BR-05`):**
   - `checkStatus(user)` rejects `UserStatus.DEACTIVATED` -> `403 ACCOUNT_DEACTIVATED` and `UserStatus.SUSPENDED` -> `403 ACCOUNT_SUSPENDED`.
   - Rejects unverified email (`emailVerifiedAt == null`) -> `403 EMAIL_NOT_VERIFIED` so UI can route user to `/verify-otp`.
3. **2FA Challenge Branch vs Full Session Issuance:**
   - If `user.isTwoFactorEnabled()` is `true`: `JwtUtil.generateTwoFactorToken(userId)` issues a 5-minute `type=2fa` challenge token and returns `LoginResponse.twoFactorChallenge(twoFactorToken)` (`requireTwoFactor = true`, no `accessToken` or refresh cookie). Client navigates to `/2fa-verify`.
   - If `twoFactorEnabled` is `false`: `completeLogin()` mints a 15-minute `accessToken`, persists and sets the 30-day `HttpOnly` `refreshToken` cookie, updates `lastLoginAt`, writes `AuditLog(LOGIN)`, and returns `200 LoginResponse`.

## 4. Dev Quick Login Alignment (2026-10-04)

- `src/main/resources/seed/dev-quick-login.sql` idempotently provisions demo accounts in PostgreSQL with fixed UUIDs and `pgcrypto` BCrypt hashes without touching existing accounts.
- `brandhub-web/src/components/auth/DevQuickLogin.tsx` resolves post-login role routing dynamically via `workspaceService.list()` (`myRole`) for `Manager` and `Creator` accounts, preserving `Admin`, `Owner`, and `Client` landing routes and routing `requireTwoFactor` challenges to `/2fa-verify`.

## 5. Security & Anti-Enumeration Guards

- **Uniform Credential Error:** Wrong email, OAuth-only account without password, and wrong password all return identical `401 INVALID_CREDENTIALS` timing/status semantics.
- **Refresh Token Freshness (`BR-08`):** `AuthServiceImpl.refresh()` rejects any refresh token issued prior to `user.getLastPasswordChange()` or blacklisted in Redis.

## Endpoint, Authorization & Error Mapping Matrix

| Aspect | Specification |
| :--- | :--- |
| **FR / Feature** | `FR 3.2.2` — Sign In with Email |
| **HTTP / WS Endpoints** | `POST /api/v1/auth/login · POST /api/v1/auth/refresh` |
| **Authorized Canonical Roles** | `Guest, Owner, Manager, Creator, Client, Admin` |
| **Controller -> Service** | `AuthController` -> `AuthServiceImpl, JwtUtil` |
| **Persistence / Cache Targets** | PostgreSQL `users`, `user_refresh_tokens`, `audit_logs` |
| **Business Rule Invariants** | `BR-02, BR-05` |
| **Error Code Contract** | `401 INVALID_CREDENTIALS`, `403 EMAIL_NOT_VERIFIED` / `ACCOUNT_DEACTIVATED` / `ACCOUNT_SUSPENDED` |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/auth/LoginPage.tsx`, `src/components/auth/DevQuickLogin.tsx`, `src/services/authService.ts`, `src/stores/authStore.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `app/(auth)/login.tsx`, `src/services/authService.ts`, `src/store/authStore.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `auth.login.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/02-authentication-profile.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
