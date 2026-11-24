> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.2.6: OTP Verification

> Implements [spec.md](./spec.md) — Dual purpose-scoped 6-digit OTP verification flows: Guest Sign-Up Email OTP (`verify-otp` / `resend-otp`) and Authenticated Phone-Link OTP (`link/phone` / `verify-phone-otp`), enforcing 10-minute TTL (`BR-03`), 5-strike invalidation, and 60-second resend cooldown (`BR-04`).

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (public `/verify-otp`, `/resend-otp`; JWT-protected `/link/phone`, `/verify-phone-otp`) |
| **Controller** | `brandhub-business-service` | `controller/auth/AuthController.java` (`verifyOtp`, `resendOtp`, `linkPhone`, `verifyPhoneOtp`, `unlinkPhone`) |
| **Service** | `brandhub-business-service` | `service/impl/auth/AuthServiceImpl.java`, `service/mail/MailService.java` (`sendOtpEmail`) |
| **DTOs & Errors** | `brandhub-business-service` | `VerifyOtpRequest`, `ForgotPasswordRequest`, `LinkPhoneRequest`, `VerifyPhoneOtpRequest`, `ErrorCode` (`OTP_INVALID`, `OTP_TOO_MANY_ATTEMPTS`, `RATE_LIMIT_EXCEEDED`, `INVALID_PHONE`, `PHONE_ALREADY_IN_USE`) |
| **Persistence** | `brandhub-business-service` | `UserRepository.java` (`otp_code`, `otp_expiry`, `email_verified_at`, `phone`), `StringRedisTemplate` |
| **Web Frontend** | `brandhub-web` | `src/pages/auth/VerifyOtpPage.tsx`, `src/pages/profile/components/LinkPhoneModal.tsx`, `src/services/authService.ts` |
| **Mobile App** | `brandhub-mobile-app` | `app/(auth)/verify-otp.tsx`, `src/screens/settings/AccountSettingsScreen.tsx` |

## 2. Purpose-Scoped Architecture & Storage Model

Rather than a generic `otpSessionId` endpoint, BrandHub isolates OTP flows by security boundary so unauthenticated calls can never touch authenticated mutations:

1. **Flow A — Sign-Up Email OTP (Public):**
   - **PostgreSQL `users`:** Stores `otp_code` (6 digits) and `otp_expiry` (10-min TTL); stamps `email_verified_at = now` and clears OTP columns upon success.
   - **Redis Keys:** `otp:attempt:{email}` (TTL 10m, max 5 failed tries) and `otp:resend:{email}` (TTL 60s cooldown).
2. **Flow B — Phone Link OTP (Bearer Authenticated):**
   - **Redis Keys:** `phone:otp:{userId}` storing `"<6digitOtp>:<normalizedPhone>"` (TTL 10m), `phone:otp:attempt:{userId}` (TTL 10m, max 5 failed tries), and `phone:otp:resend:{userId}` (TTL 60s cooldown).
   - **Delivery Channel:** Dispatched to the user's verified account email via `mailService.sendOtpEmail` (confirming account owner consent before binding `users.phone`).
   - **PostgreSQL `users`:** Updates `users.phone` (`UNIQUE`) only after re-verifying phone uniqueness at the moment of `verifyPhoneOtp` to eliminate TOCTOU race conditions.

## 3. End-to-End Execution Flow

1. **Email OTP (`POST /api/v1/auth/verify-otp` & `/resend-otp`):**
   - Normalizes email; returns idempotent `200 OK` if already verified; checks `otpCode` & `otpExpiry`; tracks failures in `otp:attempt:{email}` (5th failure clears `otpCode`/`otpExpiry` and throws `400 OTP_TOO_MANY_ATTEMPTS`); sets `emailVerifiedAt = now` on match.
2. **Phone OTP (`POST /api/v1/auth/link/phone` & `/verify-phone-otp`):**
   - `linkPhone`: validates phone format (`400 INVALID_PHONE`), checks `userRepository.existsByPhone` (`409 PHONE_ALREADY_IN_USE`), checks `phone:otp:resend:{userId}` (`429 RATE_LIMIT_EXCEEDED`), stores `phone:otp:{userId}` + 60s cooldown, resets `phone:otp:attempt:{userId}`, and emails the 6-digit code.
   - `verifyPhoneOtp`: reads `phone:otp:{userId}` (`400 OTP_INVALID` if expired/absent), increments `phone:otp:attempt:{userId}` on mismatch (5th failure deletes OTP + counter -> `400 OTP_TOO_MANY_ATTEMPTS`), re-checks `existsByPhone` against concurrent claims (`409 PHONE_ALREADY_IN_USE`), saves `user.phone`, and deletes Redis OTP keys.

## 4. Security & Boundary Isolation

- **Strict Scope Separation:** 2FA uses RFC 6238 TOTP (`FR 3.2.7`), Password Reset uses Redis link tokens (`FR 3.2.4`), and Deactivate OTP (`otp:deactivate:{userId}`) is isolated in `FR 3.2.9` — codes from one flow can never satisfy another.

## Endpoint, Authorization & Error Mapping Matrix

| Aspect | Specification |
| :--- | :--- |
| **FR / Feature** | `FR 3.2.6` — OTP Verification |
| **HTTP / WS Endpoints** | `POST /api/v1/auth/verify-otp · POST /api/v1/auth/resend-otp · POST /api/v1/auth/link/phone · POST /api/v1/auth/verify-phone-otp` |
| **Authorized Canonical Roles** | `Guest, Owner, Manager, Creator, Client, Admin` |
| **Controller -> Service** | `AuthController` -> `AuthServiceImpl, MailService` |
| **Persistence / Cache Targets** | PostgreSQL `users`; Redis `otp:attempt:{email}`, `otp:resend:{email}`, `phone:otp:{userId}`, `phone:otp:attempt:{userId}`, `phone:otp:resend:{userId}` |
| **Business Rule Invariants** | `BR-03, BR-04` |
| **Error Code Contract** | `400 OTP_INVALID` / `OTP_TOO_MANY_ATTEMPTS` / `INVALID_PHONE`, `409 PHONE_ALREADY_IN_USE`, `429 RATE_LIMIT_EXCEEDED` |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/auth/VerifyOtpPage.tsx`, `src/pages/profile/components/LinkPhoneModal.tsx`, `src/services/authService.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `app/(auth)/verify-otp.tsx`, `src/screens/settings/AccountSettingsScreen.tsx`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `auth.verifyOtp.* / profile.linkPhone.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/02-authentication-profile.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
