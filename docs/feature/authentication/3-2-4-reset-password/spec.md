# 3.2.4 Reset Password

| | |
|---|---|
| FR Code | 3.2.4 |
| Feature | Reset Password (forgot-password request + reset-password with token) |
| Domain | Authentication (FR 3.2) |
| Role | Any USER who cannot sign in because the password is forgotten (unauthenticated) |
| Version | 1.1 — 2026-09-25 — corrected BR-12 mechanism (issuedAt vs lastPasswordChange, not jti blacklist) |
| Document status | Implemented |

Note: this FR is the forgot/reset flow only. Changing a known password while logged in is FR 3.2.5 Change Password (`POST /api/v1/auth/change-password`), a separate FR.

## Function Trigger

Begins when a user who has forgotten the password opens `/forgot-password` and submits an email address.

## Function Description

- **Actors / Roles:** Unauthenticated USER who cannot sign in because the password is forgotten.
- **Purpose:** Restore access to the account by email through a single-use reset link, without ever revealing whether a given email is registered, and force sign-in again on every device once the password is changed.
- **Interface:** `/forgot-password` (email input, `ForgotPasswordPage.tsx`) and `/reset-password?token=...` (new password + confirm password, `ResetPasswordPage.tsx`).
- **Data Processing:** `POST /api/v1/auth/forgot-password` always returns 200 regardless of whether the email exists; if it exists, the system invalidates any earlier reset token for that account, generates a new single-use token, and emails it. `POST /api/v1/auth/reset-password` consumes the token atomically, hashes the new password, updates `lastPasswordChange`, and writes an audit log entry.

## Screen Layout

Figure — Forgot Password / Reset Password screens (`brandhub-web-dashboard/src/pages/auth/ForgotPasswordPage.tsx`, `ResetPasswordPage.tsx`):
- `/forgot-password`: brand panel + email `Input` (required) and an "orange" submit `Button`. On success the form is replaced by a confirmation panel (check-circle icon, heading, `successMessage` text interpolating the submitted email) with a "back to login" button — the UI does not say whether the email was actually found, matching BR-13.
- `/reset-password`: reads `token` from the URL query string; if absent, redirects to `/forgot-password` immediately (`useEffect` guard). Shows `PasswordInput` for the new password with a live `PasswordStrengthMeter`, a second `PasswordInput` for confirmation, and a submit button. Client-side validation before submit: new password required, length ≥ 8, at least one digit, and must equal the confirmation — mirroring BR-02/MSG05 and MSG06.
- Both screens share `AuthBrandPanel`, `AuthMobileHeader`, and a `BackToHomeLink`/"back to login" link.
- Toasts: MSG15 on forgot-password success (always shown, whether or not the email exists), MSG16/MSG17 on reset-password failure (invalid/expired vs. already-used token, surfaced via `extractErrorMessage` from the API error code), MSG18 on reset-password success, after which the user is redirected to `/login`.

## Function Details

### Data Specifications

- **Input required:** `email` (forgot-password step, `ForgotPasswordRequest`); `token`, `newPassword` (reset step, `ResetPasswordRequest`).
- **Input optional:** `confirmPassword` — validated on the client only (`ResetPasswordPage.tsx`), never sent to the API.
- **System data:** `User.id`, `User.email`, `User.passwordHash`, `User.lastPasswordChange`; Redis key `pwd:reset:{token}` → userId (TTL = `appProperties.passwordResetTtlSeconds`, default 3600s); reverse-index key `pwd:reset:user:{userId}` → the currently valid token (same TTL).
- **Output:** `ApiResponse<Void>`, 200, no payload, for both endpoints — the response body never distinguishes success/failure cases that must stay silent (BR-13).

### Business Rules

- **BR-13:** `POST /forgot-password` always returns 200 OK whether or not the email exists (`AuthServiceImpl.forgotPassword`: if `userRepository.findByEmail` finds nothing, the method returns silently — no error, no email — still 200). When the email exists: any existing token for that user (read via the `pwd:reset:user:{userId}` reverse-index) is deleted first, then a new 32-byte `SecureRandom` hex token is generated and stored at `pwd:reset:{token}` → userId with TTL = `appProperties.getPasswordResetTtlSeconds()` (≤ 1h per BR), and the reverse-index is refreshed with the same TTL. Only the most recently issued token is ever valid — an earlier link is invalidated the instant a new one is requested. `resetPassword` reads `pwd:reset:{token}`; missing/expired/superseded → 400 `RESET_TOKEN_INVALID`. The key is then deleted atomically (`redis.delete` returning a boolean); if the delete reports the key was already gone (concurrent reuse) → 400 `RESET_TOKEN_USED`. If the token decodes to a user id that no longer exists → 400 `RESET_TOKEN_INVALID`.
- **BR-02 (password policy, referenced):** the new password must satisfy the platform password policy (min 8 characters + at least 1 digit, enforced client-side in `ResetPasswordPage.tsx`'s `validate()`; server-side, malformed/empty `newPassword` fails bean validation on `ResetPasswordRequest` → 400 `VALIDATION_ERROR`). The accepted password is stored as a BCrypt hash.
- **BR-12 (side effect, cross-FR):** after a successful reset, every refresh token issued before the change is rejected on its next use, forcing sign-in again on every device. This is enforced in `AuthServiceImpl.refresh()`, not in `resetPassword` itself: `refresh()` compares the refresh token's `issuedAt` claim against `user.getLastPasswordChange()` and throws `REFRESH_TOKEN_INVALID` (401) when the token predates the change. `resetPassword` only sets `lastPasswordChange = now`; it does not touch any token blacklist. (The separate jti-blacklist check inside `refresh()` exists for tokens already consumed by `logout`/a prior `refresh` call — a different mechanism, not password-reset invalidation.)
- `resetPassword` also deletes the `pwd:reset:user:{userId}` reverse-index once the token is consumed, and writes an `AuditLog` row with `action = PASSWORD_RESET`.

### Validation

- `email` empty/blank on `/forgot-password` → client blocks submit, Display: MSG02.
- `email` not a valid format → bean validation on `ForgotPasswordRequest` → 400 `VALIDATION_ERROR`, Display: MSG04.
- `newPassword` missing, under 8 characters, or missing a digit on `/reset-password` → client blocks submit, Display: MSG05; if it reaches the server anyway → 400 `VALIDATION_ERROR`.
- `confirmPassword` ≠ `newPassword` → client blocks submit, Display: MSG06 (never sent to the API).
- `token` missing from the URL → client redirects to `/forgot-password` before rendering the form (no server call).

## Functionalities

### Normal Flow

1. User opens `/forgot-password` and submits the email address.
2. `AuthController.forgotPassword` calls `AuthServiceImpl.forgotPassword(email)`. The system looks up the account by normalized (lowercased, trimmed) email.
3. If found: the system deletes any earlier reset token for the account, generates a new 32-byte random hex token, stores it in Redis with TTL ≤ 1h, refreshes the reverse-index, and sends the reset email via `MailService.sendPasswordResetEmail`.
4. The endpoint returns 200 with no body regardless of whether the account was found. Toast MSG15 ("If the email is registered, a password reset link has been sent to {email_address}.").
5. User opens the reset link from the email, landing on `/reset-password?token=...`; enters the new password and confirmation (validated on the client).
6. `AuthController.resetPassword` calls `AuthServiceImpl.resetPassword(token, newPassword)`. The system resolves and atomically deletes the Redis token, loads the user, clears the reverse-index, hashes and saves the new password, sets `lastPasswordChange = now`, and writes an audit log entry.
7. The endpoint returns 200 with no body. Toast MSG18 ("Password updated successfully."); the user is redirected to `/login`.
8. Side effect (BR-12): the next time any refresh token issued before this reset is presented to `POST /refresh`, it is rejected with 401 `REFRESH_TOKEN_INVALID`, forcing sign-in again on that device.

### Abnormal Cases

- 1.a1: `email` empty → Display: MSG02 (client-blocked, no request sent). 1.a2: The user fills in the field and resubmits.
- 1.b1: `email` not a valid format → 400 `VALIDATION_ERROR`, Display: MSG04. 1.b2: The user corrects the format and resubmits.
- 2.a1: Email does not match any account (BR-13) → still 200, toast MSG15, no email sent. 2.a2: The user checks the inbox; the response never confirms whether the account exists.
- 6.a1: Token missing, expired, or superseded by a newer forgot-password request (BR-13) → 400 `RESET_TOKEN_INVALID`, toast MSG16. 6.a2: The user requests a new reset link from `/forgot-password`.
- 6.b1: Token already consumed, including two near-simultaneous reset submissions racing on the same token (BR-13) → 400 `RESET_TOKEN_USED`, toast MSG17. 6.b2: The user requests a new reset link.
- 6.c1: Token decodes to a user id that no longer exists (deleted account) → 400 `RESET_TOKEN_INVALID`, toast MSG16. 6.c2: The user requests a new reset link.
- 6.d1: `newPassword` fails the password policy (BR-02) → client-blocked, Display: MSG05; if bypassed, server returns 400 `VALIDATION_ERROR`. 6.d2: The user corrects the password and resubmits.
- 6.e1: `confirmPassword` mismatch on the client → Display: MSG06, submit blocked (no API call). 6.e2: The user re-types the confirmation.
- No `token` in the URL when opening `/reset-password` → the client redirects to `/forgot-password` before any form is shown.

## Post-Conditions

- On a successful reset: `User.passwordHash` is replaced and `User.lastPasswordChange` is set to the reset time; an `AuditLog` row (`PASSWORD_RESET`) exists; the consumed Redis token and its reverse-index entry are both deleted.
- On any `/forgot-password` call: exactly one valid reset token exists per account at a time (the newest one); the HTTP response is 200 in every case and never reveals account existence.
- Refresh tokens issued before the reset are rejected on their next use (BR-12), independent of any explicit logout.

## Out of Scope

- Changing a known password while authenticated — FR 3.2.5 Change Password (`POST /api/v1/auth/change-password`, `ChangePasswordRequest`), a separate FR and separate error/message set (`WRONG_CURRENT_PASSWORD`, `SAME_AS_CURRENT_PASSWORD`).
- OTP-based reset — the codebase's OTP flow (`otp:*` Redis keys, `verify-otp`/`resend-otp`) is used for email verification at registration, not for password reset; reset uses a link/token only.

## References

[Section5_Requirement_Appendix.md](../../../BA/Section5_Requirement_Appendix.md) (BR-13, BR-12, BR-02; MSG02, MSG04, MSG05, MSG06, MSG15–MSG18)
