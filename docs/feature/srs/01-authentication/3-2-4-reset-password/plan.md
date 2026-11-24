> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.2.4: Reset Password

> Implements [spec.md](./spec.md) — Anti-enumeration password reset token issuance (`POST /api/v1/auth/forgot-password`), single-use Redis token consumption (`POST /api/v1/auth/reset-password`), BCrypt hashing (`BR-02`), and prior session invalidation (`BR-08`).

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (public routes `/api/v1/auth/forgot-password`, `/api/v1/auth/reset-password`), `RateLimitGatewayFilterFactory.java` |
| **Controller** | `brandhub-business-service` | `controller/auth/AuthController.java` (`forgotPassword`, `resetPassword`) |
| **Service** | `brandhub-business-service` | `service/impl/auth/AuthServiceImpl.java` (`forgotPassword`, `resetPassword`), `service/mail/MailService.java` |
| **DTOs & Errors** | `brandhub-business-service` | `ForgotPasswordRequest`, `ResetPasswordRequest`, `ErrorCode` (`RESET_TOKEN_INVALID`, `RESET_TOKEN_USED`, `VALIDATION_ERROR`) |
| **Persistence** | `brandhub-business-service` | `UserRepository.java`, `UserRefreshTokenRepository.java`, `AuditLogRepository.java`, `StringRedisTemplate` |
| **Web Frontend** | `brandhub-web` | `src/pages/auth/ForgotPasswordPage.tsx`, `src/pages/auth/ResetPasswordPage.tsx`, `src/components/auth/{PasswordInput,PasswordStrengthMeter}.tsx` |
| **Mobile App** | `brandhub-mobile-app` | `app/(auth)/forgot-password.tsx`, `app/(auth)/reset-password.tsx`, `src/services/authService.ts` |

## 2. Architectural Mechanism & Redis Reverse-Index Design

- **Email Link Token Mechanism:** Uses a high-entropy single-use reset token sent via email link (`/reset-password?token=<token>`) backed by dual Redis keys with TTL = `appProperties.passwordResetTtlSeconds` (10 minutes):
  - `pwd:reset:{token}` -> `userId` (primary lookup consumed atomically during `resetPassword`).
  - `pwd:reset:user:{userId}` -> `token` (reverse index allowing a subsequent `forgot-password` request to immediately delete any previously issued `oldToken` rather than leaving multiple active reset tokens).
- **Session Invalidation (`BR-08`):** Setting `users.last_password_change = Instant.now()` (and revoking active `user_refresh_tokens`) immediately invalidates all refresh tokens issued prior to the password reset.

## 3. End-to-End Execution Flow

1. **Request Reset (`POST /api/v1/auth/forgot-password`):**
   - Validates email format (`400 VALIDATION_ERROR` if malformed) and normalizes `email` (`lowercase + trim`).
   - Looks up `User`: if absent or non-active, returns `200 OK` silently without sending email (preventing email enumeration and mail spam).
   - If `User` exists: reads `pwd:reset:user:{userId}`, deletes `pwd:reset:{oldToken}` if present, generates new token, stores both `pwd:reset:{token}` and `pwd:reset:user:{userId}` with matching TTL, dispatches reset link email, and returns `200 OK`.
2. **Confirm New Password (`POST /api/v1/auth/reset-password`):**
   - Validates `newPassword` against `BR-02` (min 8 chars, >= 1 digit).
   - Resolves `userId` from `pwd:reset:{token}` (`400 RESET_TOKEN_INVALID` if missing/expired) and atomically deletes `pwd:reset:{token}` (`400 RESET_TOKEN_USED` if a concurrent request consumed it first) + deletes `pwd:reset:user:{userId}`.
   - Updates `user.passwordHash` (BCrypt cost 12), stamps `user.lastPasswordChange = now`, writes `AuditLog(PASSWORD_RESET)`, and returns `200 OK`.

## 4. Security & Concurrency Guards

- **Zero Account Enumeration:** Both registered and unregistered emails receive identical `200 ApiResponse<Void>` payloads on `/forgot-password`.
- **Single-Active-Token Guarantee:** Requesting `/forgot-password` twice immediately invalidates the first token via the `pwd:reset:user:{userId}` reverse index.
- **OAuth-Only Account Recovery:** Allows an OAuth-provisioned user (`passwordHash == null`) to establish a password via email verification proof while keeping their Google link intact.

## Endpoint, Authorization & Error Mapping Matrix

| Aspect | Specification |
| :--- | :--- |
| **FR / Feature** | `FR 3.2.4` — Reset Password |
| **HTTP / WS Endpoints** | `POST /api/v1/auth/forgot-password · POST /api/v1/auth/reset-password` |
| **Authorized Canonical Roles** | `Guest, Owner, Manager, Creator, Client, Admin` |
| **Controller -> Service** | `AuthController` -> `AuthServiceImpl, MailService` |
| **Persistence / Cache Targets** | PostgreSQL `users` (`password_hash`, `last_password_change`), `audit_logs`; Redis `pwd:reset:{token}`, `pwd:reset:user:{userId}` |
| **Business Rule Invariants** | `BR-02, BR-03, BR-04, BR-08` |
| **Error Code Contract** | `400 VALIDATION_ERROR` / `RESET_TOKEN_INVALID` / `RESET_TOKEN_USED` |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/auth/ForgotPasswordPage.tsx`, `src/pages/auth/ResetPasswordPage.tsx`, `src/services/authService.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `app/(auth)/forgot-password.tsx`, `app/(auth)/reset-password.tsx`, `src/services/authService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `auth.forgotPassword.* / auth.resetPassword.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/02-authentication-profile.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
