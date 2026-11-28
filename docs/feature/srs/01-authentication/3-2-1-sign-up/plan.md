> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.2.1: Sign Up

> Implements [spec.md](./spec.md) — Guest email registration with case-insensitive normalization (`BR-01`), BCrypt cost-12 hashing (`BR-02`), and 6-digit single-use OTP verification (`BR-03`, `BR-04`).

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (public route `/api/v1/auth/register`, `/verify-otp`, `/resend-otp`), `RateLimitGatewayFilterFactory.java` |
| **Controller** | `brandhub-business-service` | `controller/auth/AuthController.java` (`register` -> `201 CREATED`, `verifyOtp` -> `200 OK`, `resendOtp` -> `200 OK`) |
| **Service** | `brandhub-business-service` | `service/impl/auth/AuthServiceImpl.java` (`register`, `verifyOtp`, `resendOtp`, `generateOtp`), `service/mail/MailService.java` |
| **DTOs & Errors** | `brandhub-business-service` | `RegisterRequest`, `RegisterResponse(userId)`, `VerifyOtpRequest`, `ForgotPasswordRequest`, `ErrorCode` (`EMAIL_ALREADY_EXISTS`, `OTP_INVALID`, `OTP_TOO_MANY_ATTEMPTS`, `RATE_LIMIT_EXCEEDED`) |
| **Persistence** | `brandhub-business-service` | `model/user/User.java`, `model/user/UserSystemRole.java`, `repository/user/UserRepository.java`, `UserSystemRoleRepository.java`, `StringRedisTemplate` |
| **Web Frontend** | `brandhub-web` | `src/pages/auth/RegisterPage.tsx`, `src/pages/auth/VerifyOtpPage.tsx`, `src/components/auth/{PasswordInput,PasswordStrengthMeter}.tsx`, `src/services/authService.ts` |
| **Mobile App** | `brandhub-mobile-app` | `app/(auth)/register.tsx`, `app/(auth)/verify-otp.tsx`, `src/services/authService.ts` |

## 2. Database & Redis Schema

- **PostgreSQL `users`:**
  - `id` (`UUID`, PK), `email` (`VARCHAR(255)`, `UNIQUE` storing normalized lowercase+trimmed email), `password_hash` (`VARCHAR(255)`, BCrypt cost 12), `full_name` (`VARCHAR(255)`), `status` (`UserStatus.ACTIVE`), `email_verified_at` (`TIMESTAMPTZ`, nullable until OTP verified), `otp_code` (`VARCHAR(6)`, nullable), `otp_expiry` (`TIMESTAMPTZ`, 10-minute TTL).
- **PostgreSQL `user_system_roles`:**
  - Assigns default `SystemRole.USER` (`fk_user_id -> users.id`) inside the same `@Transactional` boundary as user creation.
- **Redis Ephemeral Keys:**
  - `otp:attempt:<normalizedEmail>` — failed OTP verification counter (`INCR` + `EXPIRE 600s`; cleared on success or upon hitting 5 failures).
  - `otp:resend:<normalizedEmail>` — resend cooldown lock (`SETEX 60s` -> rejects concurrent resends with `429 RATE_LIMIT_EXCEEDED`).

## 3. End-to-End Execution Flow

1. **Registration (`POST /api/v1/auth/register`):**
   - Bean Validation checks `fullName` (`@NotBlank`), `email` (`@Email`), and `password` (`>= 8` chars + `>= 1` digit) -> `400 VALIDATION_ERROR` on failure.
   - `AuthServiceImpl.register()` normalizes `email = request.email().trim().toLowerCase(Locale.ROOT)` and trims `fullName`.
   - Hashes password with `PasswordEncoder` (BCrypt cost 12), generates 6-digit `SecureRandom` OTP (`100000..999999`) with `otpExpiry = Instant.now().plus(10, MINUTES)`, inserts `User` + `UserSystemRole(USER)` (catching `DataIntegrityViolationException` -> `409 EMAIL_ALREADY_EXISTS`), dispatches OTP email, and returns `201 RegisterResponse(userId)` without issuing any JWT session.
2. **OTP Verification (`POST /api/v1/auth/verify-otp`):**
   - Normalizes email, loads `User` (`404 USER_NOT_FOUND` if absent; idempotent `200 OK` if `emailVerifiedAt != null`).
   - Validates `otpCode != null && otpExpiry.isAfter(now)`; on mismatch increments `otp:attempt:<email>` (if `< 5` -> `400 OTP_INVALID`; on 5th failure -> nulls `otpCode`/`otpExpiry`, deletes counter, throws `400 OTP_TOO_MANY_ATTEMPTS`).
   - On match: sets `emailVerifiedAt = now`, clears `otpCode`/`otpExpiry`, deletes Redis counter, returns `200 ApiResponse<Void>`, and client navigates to `/login`.
3. **Resend OTP (`POST /api/v1/auth/resend-otp`):**
   - Checks `otp:resend:<email>` (`429 RATE_LIMIT_EXCEEDED` if active), generates fresh 6-digit OTP + 10-minute expiry, resets `otp:attempt:<email>`, sets 60s cooldown key, and sends verification email.

## 4. Security, Concurrency & Risks

- **Race-Safe Uniqueness (`BR-01`):** Relying on PostgreSQL's unique constraint on normalized `users.email` in addition to pre-checks guarantees zero duplicate accounts under concurrent sign-up requests.
- **Brute-Force Mitigation (`BR-03`, `BR-04`):** Strict 5-attempt OTP invalidation + 60-second Redis cooldown prevents automated enumeration of the 6-digit keyspace.
- **No Premature Session Issuance:** `RegisterResponse` intentionally omits JWT tokens and `otpSessionId` so unverified accounts cannot access protected routes before proving email ownership.

## Endpoint, Authorization & Error Mapping Matrix

| Aspect | Specification |
| :--- | :--- |
| **FR / Feature** | `FR 3.2.1` — Sign Up |
| **HTTP / WS Endpoints** | `POST /api/v1/auth/register · POST /api/v1/auth/verify-otp · POST /api/v1/auth/resend-otp` |
| **Authorized Canonical Roles** | `Guest` |
| **Controller -> Service** | `AuthController` -> `AuthServiceImpl, MailService` |
| **Persistence / Cache Targets** | PostgreSQL `users`, `user_system_roles`; Redis `otp:attempt:<email>`, `otp:resend:<email>` |
| **Business Rule Invariants** | `BR-01, BR-02, BR-03` |
| **Error Code Contract** | `400 VALIDATION_ERROR` / `OTP_INVALID` / `OTP_TOO_MANY_ATTEMPTS`, `409 EMAIL_ALREADY_EXISTS`, `429 RATE_LIMIT_EXCEEDED` |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/auth/RegisterPage.tsx`, `src/pages/auth/VerifyOtpPage.tsx`, `src/components/auth/{PasswordInput,PasswordStrengthMeter,AuthBrandPanel}.tsx`, `src/services/authService.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `app/(auth)/register.tsx`, `app/(auth)/verify-otp.tsx`, `src/services/authService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `auth.register.* / auth.verifyOtp.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/02-authentication-profile.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
