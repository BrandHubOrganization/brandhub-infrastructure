# 3.2 Authentication & Authorization (9 FRs)

> **Navigation:** [← Feature Master Index](../../README.md) · [← SRS 141 FRs Index](../README.md) · [BA Domain Spec](../../../ba/02-authentication-profile.md) · [Use Cases](../../../ba/use-cases/01-authentication-profile.md) · [Module Specs Index](../../modules/README.md) · [Workflow Rule](../../../rule/feature-workflow.md)

Canonical specification, technical implementation plan, task breakdown, and unit/acceptance test verification suite for **3.2 Authentication & Authorization** (`3.2.1 – 3.2.9`, **9 Atomic CRUD Functional Requirements**).

---

## 1. Domain Architecture Overview

Authentication and session security in BrandHub span the edge API Gateway, the core Business Service, PostgreSQL identity tables, and Redis ephemeral security state:

- **Edge JWT Verification (`brandhub-api-gateway`):**
  - `JwtAuthFilterGatewayFilterFactory` and `InboundSecurityWebFilter` validate `Authorization: Bearer <accessToken>` signatures (`HS256`/`RS256` via `JwtUtil`), check Redis token revocation (`jwt:blacklist:{jti}`), inject verified identity claims (`X-User-Id`, `X-User-Email`, `X-System-Role`), and apply `RateLimitGatewayFilterFactory` throttling on public auth endpoints.
- **Core Identity & Credential Engine (`brandhub-business-service`):**
  - **Controllers:** `AuthController` (`/api/v1/auth/*`), `GoogleOAuthController` (`/api/v1/auth/oauth/google*`, `/login/oauth2/code/google`), `AccountActivationController` (`/api/v1/auth/activation/*`).
  - **Services & Utilities:** `AuthServiceImpl`, `GoogleOAuthService`, `AccountActivationService`, `TotpUtil` (RFC 6238 HMAC-SHA1 6-digit 30-second window ±1 step), `JwtUtil` (15-minute Access Token, 30-day Refresh Token rotated via `HttpOnly` cookie / secure storage, 5-minute `type=2fa` challenge token), and BCrypt password hashing (cost factor 12).
- **Persistence & Ephemeral State:**
  - **PostgreSQL:** `users`, `user_system_roles`, `user_refresh_tokens`, `user_oauth_providers`, `audit_logs` (capturing `ip_address` and `user_agent`).
  - **Redis:** `otp:attempt:{email}`, `otp:resend:{email}`, `phone:otp:{userId}`, `phone:otp:attempt:{userId}`, `phone:otp:resend:{userId}`, `pwd:reset:{token}`, `pwd:reset:user:{userId}`, `2fa:setup:{userId}`, `2fa:attempt:{userId}`, `oauth:state:{state}`, `otp:deactivate:{userId}`, and `jwt:blacklist:{jti}`.
- **Client Surfaces (`brandhub-web` & `brandhub-mobile-app`):**
  - **Web (`brandhub-web`):** `src/pages/auth/{RegisterPage,VerifyOtpPage,LoginPage,OAuthCallbackPage,ForgotPasswordPage,ResetPasswordPage,TwoFactorVerifyPage,ActivateAccountPage}.tsx`, `src/pages/security/index.tsx` (`ChangePasswordCard`, `ActiveSessionsCard`), `src/pages/profile/index.tsx` (Deactivate Account), `src/services/authService.ts`, `src/stores/authStore.ts`.
  - **Mobile (`brandhub-mobile-app`):** `app/(auth)/*`, `src/screens/settings/{SecuritySettingsScreen,AccountSettingsScreen}.tsx`, `src/services/authService.ts`, `src/store/authStore.ts` (`expo-secure-store` token persistence).

---

## 2. Functional Requirements Matrix

| FR ID | UC ID | Function Name | Canonical Roles | Status | Feature Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `3.2.1` | `UC-001` | **Sign Up** | `Guest` | Implemented | [Spec](./3-2-1-sign-up/spec.md) · [Plan](./3-2-1-sign-up/plan.md) · [Task](./3-2-1-sign-up/task.md) · [Test](./3-2-1-sign-up/test.md) |
| `3.2.2` | `UC-002` | **Sign In with Email** | `Guest, Owner, Manager, Creator, Client, Admin` | Implemented | [Spec](./3-2-2-sign-in-with-email/spec.md) · [Plan](./3-2-2-sign-in-with-email/plan.md) · [Task](./3-2-2-sign-in-with-email/task.md) · [Test](./3-2-2-sign-in-with-email/test.md) |
| `3.2.3` | `UC-003` | **Sign In with Google OAuth** | `Guest, Owner, Manager, Creator, Client, Admin` | Implemented | [Spec](./3-2-3-sign-in-with-google-oauth/spec.md) · [Plan](./3-2-3-sign-in-with-google-oauth/plan.md) · [Task](./3-2-3-sign-in-with-google-oauth/task.md) · [Test](./3-2-3-sign-in-with-google-oauth/test.md) |
| `3.2.4` | `UC-004` | **Reset Password** | `Guest, Owner, Manager, Creator, Client, Admin` | Implemented | [Spec](./3-2-4-reset-password/spec.md) · [Plan](./3-2-4-reset-password/plan.md) · [Task](./3-2-4-reset-password/task.md) · [Test](./3-2-4-reset-password/test.md) |
| `3.2.5` | `UC-005` | **Change Password** | `Owner, Manager, Creator, Client, Admin` | Implemented | [Spec](./3-2-5-change-password/spec.md) · [Plan](./3-2-5-change-password/plan.md) · [Task](./3-2-5-change-password/task.md) · [Test](./3-2-5-change-password/test.md) |
| `3.2.6` | `UC-006` | **OTP Verification** | `Guest, Owner, Manager, Creator, Client, Admin` | Implemented | [Spec](./3-2-6-otp-verification/spec.md) · [Plan](./3-2-6-otp-verification/plan.md) · [Task](./3-2-6-otp-verification/task.md) · [Test](./3-2-6-otp-verification/test.md) |
| `3.2.7` | `UC-007` | **Two-Factor Authentication (2FA, TOTP)** | `Owner, Manager, Creator, Client, Admin` | Implemented | [Spec](./3-2-7-two-factor-authentication-2fa-totp/spec.md) · [Plan](./3-2-7-two-factor-authentication-2fa-totp/plan.md) · [Task](./3-2-7-two-factor-authentication-2fa-totp/task.md) · [Test](./3-2-7-two-factor-authentication-2fa-totp/test.md) |
| `3.2.8` | `UC-008` | **Logout** | `Owner, Manager, Creator, Client, Admin` | Implemented | [Spec](./3-2-8-logout/spec.md) · [Plan](./3-2-8-logout/plan.md) · [Task](./3-2-8-logout/task.md) · [Test](./3-2-8-logout/test.md) |
| `3.2.9` | `UC-009` | **Delete Account** | `Owner, Manager, Creator, Client, Admin` | Implemented | [Spec](./3-2-9-delete-account/spec.md) · [Plan](./3-2-9-delete-account/plan.md) · [Task](./3-2-9-delete-account/task.md) · [Test](./3-2-9-delete-account/test.md) |

---

## 3. Core Business Rules & Security Invariants

- **`BR-01` (Case-Insensitive Unique Email):** Every email input is normalized (`trim().toLowerCase(Locale.ROOT)`) prior to lookup, registration, OTP verification, or Google OAuth account linking.
- **`BR-02` (Password Policy & Hashing):** Minimum 8 characters with at least 1 numeric digit; hashed exclusively with BCrypt (cost 12); plaintext passwords are never persisted or logged.
- **`BR-03` & `BR-04` (Single-Use OTP & Brute-Force Guard):** 6-digit numeric OTP with 10-minute TTL, invalidated after 5 failed attempts (`OTP_TOO_MANY_ATTEMPTS`) with a 60-second resend cooldown (`RATE_LIMIT_EXCEEDED`).
- **`BR-05` (Account Lifecycle Gate):** Sign-in and token refresh require `emailVerifiedAt != null` and `status == ACTIVE`; `DEACTIVATED` or `SUSPENDED` accounts are blocked immediately.
- **`BR-08` (Session Invalidation on Password Mutation):** Resetting or changing a password stamps `users.last_password_change`, invalidating all refresh tokens issued prior to that timestamp.
- **`BR-09` (QR-Only TOTP 2FA):** RFC 6238 TOTP setup exposes only the `otpauth://` QR payload (no copyable plaintext secret key and no static backup codes) with 5-attempt lockout protection (`2fa:attempt:{userId}`).
- **`BR-10` & `BR-16` (Safe Soft Deactivation):** Account deletion soft-deactivates `users.status = DEACTIVATED`, revokes active tokens, and blocks execution (`409 AGENCY_OWNERSHIP_ACTIVE`) while the user owns any active Agency.

## 4. Cross-References

- **BA Domain Specification:** [02-authentication-profile.md](../../../ba/02-authentication-profile.md)
- **BA System Overview:** [BA Overview](../../../ba/README.md)
- **Consolidated Feature Modules:** [Module Specs Index](../../modules/README.md)
