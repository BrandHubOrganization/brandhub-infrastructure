# 3.2.7 Two-Factor Authentication (2FA, TOTP)

| | |
|---|---|
| FR Code | 3.2.7 |
| Feature | Two-Factor Authentication (2FA, TOTP) |
| Domain | Authentication (FR 3.2) |
| Role | Any signed-in USER (setup/confirm/disable); partway-signed-in USER holding a 2FA challenge token (verify) |
| Version | 2.5 — 2026-09-25 — BR-86 lockout (5 wrong TOTP codes / 10-min window → 429 `TWO_FA_TOO_MANY_ATTEMPTS`) implemented in `AuthServiceImpl.checkTwoFactorAttempt`, shared by confirm/disable/verify; BR-86 conflict resolved (code now matches appendix). BR-17 still open. |
| Document status | Implemented |

## Function Trigger

Begins when a signed-in user enables or disables two-factor authentication from `/security` (Security settings page), or when a user who already has it enabled completes the password step (3.2.2) or Google sign-in (3.2.3) and is redirected to `/2fa-verify` to enter a code from their authenticator app.

## Function Description

- **Actors / Roles:** USER — signed in (Bearer access token) when enabling, confirming, or disabling; holding only a short-lived `twoFactorToken` (no access token) when verifying at sign-in.
- **Purpose:** Add a second factor based on RFC 6238 time-based one-time codes, so every sign-in method (password or Google OAuth) requires something the user holds in addition to the password.
- **Interface:** `/security` page — "Enable 2FA" action revealing a QR code (rendered client-side from `otpAuthUrl`) and a 6-digit code input to confirm; "Disable 2FA" action requiring the current code; `/2fa-verify` page — a single 6-digit code screen shown during sign-in when the account has 2FA enabled.
- **Data Processing:** The system generates a TOTP secret and holds it *pending* in Redis (not persisted to the user record) until a correct code confirms it; only then is the secret written to `users.totp_secret` and `users.two_factor_enabled` set. Verifying a code (confirm/disable/login-verify) always checks it via `TotpUtil.verify`, RFC 6238 semantics (30s step, ±1-step tolerance), then always calls `AuthServiceImpl.checkTwoFactorAttempt(userId, codeValid)` (BR-86): a wrong code increments a Redis counter at `2fa:attempt:{userId}` (TTL 10 minutes, set on the first increment), and the 5th wrong code within that window deletes the counter and throws 429 `TWO_FA_TOO_MANY_ATTEMPTS` instead of 400 `TWO_FA_CODE_INVALID`; a correct code deletes the counter. The same counter and key are shared across `confirmTwoFactor`, `disableTwoFactor`, and `verifyTwoFactor` for a given user.

## Routes / DTOs (ground truth: `AuthController.java`, `AuthServiceImpl.java`)

| Route | Auth | Request body | Response | Notes |
|---|---|---|---|---|
| `POST /api/v1/auth/2fa/setup` | Bearer required | none | `ApiResponse<TwoFactorSetupResponse>` 200 — `{ otpAuthUrl }` | `otpAuthUrl` is an `otpauth://` provisioning URI for the QR code; the raw secret is never returned. |
| `POST /api/v1/auth/2fa/confirm` | Bearer required | `TwoFactorConfirmRequest { code }` | `ApiResponse<Void>` 200 | Persists `totpSecret` + `twoFactorEnabled=true`, deletes the pending Redis key. |
| `POST /api/v1/auth/2fa/disable` | Bearer required | `TwoFactorConfirmRequest { code }` | `ApiResponse<Void>` 200 | Clears `twoFactorEnabled` and `totpSecret`. |
| `POST /api/v1/auth/2fa/verify` | **None** (uses `twoFactorToken` in body instead) | `TwoFactorVerifyRequest { twoFactorToken, code }` | `ApiResponse<LoginResponse>` 200 | On success sets the `refreshToken` HTTP-only cookie exactly like `/login`, and returns `LoginResponse` (access token, type, expiry). |

`login()` handoff (FR 3.2.2/3.2.3, for context): if `user.isTwoFactorEnabled()`, login generates a short-lived `twoFactorToken` (JWT claim `type=2fa`) and returns it via `LoginResponse.twoFactorChallenge` — **no access/refresh token is issued at this step.** The client then calls `/2fa/verify` to complete sign-in.

## Screen Layout

Figure — Two-Factor Authentication screens (grounded in `pages/security/index.tsx` and `pages/auth/TwoFactorVerifyPage.tsx`):
- `/security` — 2FA card with a `ShieldCheck` icon:
  - Not enabled: "Enable 2FA" button.
  - Mid-setup: QR code (`QRCodeSVG` rendered from `otpAuthUrl`) plus a 6-digit code input, "Confirm" and "Cancel" actions. No secret text is offered for copying and no recovery codes are shown.
  - Enabled: hint text plus a "Disable 2FA" button.
  - Confirming disable: 6-digit code input, "Confirm Disable" and "Cancel" actions.
- `/2fa-verify` — 6 separate single-digit inputs (auto-advance, paste-fill), a "Verify" submit button, and a "Back to login" link that clears the stored `twoFactorToken` and returns to `/login`. Reached only when a `twoFactorToken` is present (in the URL query or `sessionStorage`); otherwise the page redirects to `/login`.

## Function Details

### Data Specifications

- **Input required:** `code` (6-digit string) for confirm/disable/verify; `twoFactorToken` for verify. Setup takes no body — the pending secret is generated entirely by the system.
- **Input optional:** none.
- **System data:** `userId`, `totpSecret`, `twoFactorEnabled`, the pending secret stored in Redis key `2fa:setup:{userId}` with a 10-minute TTL, the wrong-attempt counter stored in Redis key `2fa:attempt:{userId}` with a 10-minute TTL (BR-86), `twoFactorToken` (JWT, claim `type=2fa`), `lastLoginAt`, `workspaceId` (resolved for the access token on successful verify).
- **Output:** `otpAuthUrl` (setup); nothing (confirm/disable); `LoginResponse` — access token, token type, expiry, and a `refreshToken` cookie (verify).

### Business Rules

- **BR-15:** TOTP 2FA (RFC 6238): 6-digit code, 30-second step, ±1-step clock tolerance (`TotpUtil.verify`). Secret is expected to be encrypted at rest and regenerated on disable/re-enable per BA intent; the pending-2FA secret (setup) and the `twoFactorToken` (login) are both short-lived and effectively single-use (the pending secret is deleted on confirm, the token is not reusable once `completeLogin` issues real tokens). Recovery codes for a lost device are **(TBD: mechanism)** — not implemented; a user who loses their authenticator app must ask an administrator to disable 2FA on their behalf. `setupTwoFactor`: 404 `USER_NOT_FOUND` if the account is missing; 400 `TWO_FA_ALREADY_ENABLED` if already enabled. `confirmTwoFactor`: 404 `USER_NOT_FOUND`; 400 `TWO_FA_ALREADY_ENABLED` if already enabled; 400 `TWO_FA_NOT_ENABLED` if no pending secret exists in Redis (missing or expired); 400 `TWO_FA_CODE_INVALID` on mismatch (pending secret is kept, so the user may retry within the 10-minute window, subject to the BR-86 lockout below). `disableTwoFactor`: 404 `USER_NOT_FOUND`; 400 `TWO_FA_NOT_ENABLED` if not enabled or no stored secret; 400 `TWO_FA_CODE_INVALID` on mismatch (subject to BR-86).
- **BR-86:** Wrong 2FA code is limited to a small number of retries (5 within a 10-minute window, matching the OTP lockout pattern) before further attempts return `TWO_FA_TOO_MANY_ATTEMPTS`; enforced in `AuthServiceImpl.checkTwoFactorAttempt`, shared by `confirmTwoFactor`, `disableTwoFactor`, and `verifyTwoFactor`. Mechanics confirmed against code: Redis key `2fa:attempt:{userId}` (constant `TWO_FA_ATTEMPT_PREFIX = "2fa:attempt:"`), TTL 10 minutes (set on the first wrong attempt), max attempts `OTP_MAX_ATTEMPTS = 5` (the same constant used by email/phone OTP lockout). On the 5th wrong code the counter is deleted and the call throws 429 `TWO_FA_TOO_MANY_ATTEMPTS` instead of 400 `TWO_FA_CODE_INVALID`. Any correct code deletes the counter immediately, resetting the window. This is a per-user counter, not per-request-flow — a wrong attempt on `/2fa/confirm` and a wrong attempt on `/2fa/verify` for the same user share the same 5-attempt budget.
- **BR-17:** Whether 2FA is mandatory for OWNER/MANAGER roles is **(TBD: team decision)** — not implemented; today 2FA is opt-in for every role and `AuthServiceImpl` has no role-based enforcement anywhere in the setup/confirm/disable/login flow.
- **BR-05 / verify at sign-in:** `verifyTwoFactor(twoFactorToken, code)` — the token must parse as a valid JWT and carry claim `type=2fa`, else 401 `TWO_FA_TOKEN_INVALID`; the subject must resolve to an existing user, else 401 `TWO_FA_TOKEN_INVALID` (anti-enumeration, mirrors normal login's generic failure). Account status is checked next (`checkStatus`): 403 `ACCOUNT_SUSPENDED` or 403 `ACCOUNT_DEACTIVATED`. If 2FA was disabled or the secret cleared in the meantime → 400 `TWO_FA_NOT_ENABLED`. Wrong code → 400 `TWO_FA_CODE_INVALID`, or 429 `TWO_FA_TOO_MANY_ATTEMPTS` on the 5th wrong code within 10 minutes (BR-86). On success, `completeLogin` runs exactly as in normal login: `lastLoginAt` updated, `AuditAction.LOGIN` recorded, access + refresh tokens issued, refresh cookie set.

### Validation

- `code` empty or not a 6-digit number → Display: MSG02 (client-side).
- `code` well-formed but does not match the current time window (±1 step) → 400 `TWO_FA_CODE_INVALID`, Display: MSG20 (or 429 `TWO_FA_TOO_MANY_ATTEMPTS` if it is the 5th wrong code within 10 minutes for that user — BR-86).

## Functionalities

### Normal Flow

1. Signed-in user opens `/security` and clicks "Enable 2FA".
2. `POST /2fa/setup` — system loads the account, confirms 2FA is not already enabled, generates a TOTP secret via `TotpUtil.generateSecret()`, stores it pending in Redis (`2fa:setup:{userId}`, TTL 10 min), and returns `otpAuthUrl`.
3. Client renders the QR code from `otpAuthUrl`; user scans it with an authenticator app.
4. User enters the 6-digit code shown by the app and submits.
5. `POST /2fa/confirm { code }` — system re-checks not-already-enabled, reads the pending secret from Redis, verifies the code via `TotpUtil.verify`; a wrong code is passed to `checkTwoFactorAttempt` (BR-86: increments `2fa:attempt:{userId}`, 429 `TWO_FA_TOO_MANY_ATTEMPTS` on the 5th within 10 minutes); on match it clears the attempt counter, persists `totpSecret` + `twoFactorEnabled=true`, and deletes the pending-setup Redis key. Toast MSG24.
6. On a later sign-in (password 3.2.2 or Google 3.2.3), `login()` sees `user.isTwoFactorEnabled()==true`, issues a `twoFactorToken` (claim `type=2fa`), and returns it via `LoginResponse.twoFactorChallenge` — **no access/refresh token yet.** Client redirects to `/2fa-verify`.
7. User enters the code from the app on `/2fa-verify` and submits.
8. `POST /2fa/verify { twoFactorToken, code }` (no Bearer header) — system validates the token, loads the user, checks status, verifies the code (wrong code → `checkTwoFactorAttempt`, BR-86 lockout after 5 within 10 minutes), and on match calls `completeLogin`: clears the attempt counter, issues access token + refresh token, sets the refresh cookie, records `AuditAction.LOGIN`. Toast (auth.twoFactor.successToast).

### Abnormal Cases

- 2.a1: Setup requested for an account that no longer exists → 404 `USER_NOT_FOUND`. 2.a2: Should not occur for a valid session; treated as a generic error toast.
- 2.b1: Setup requested while 2FA is already enabled (BR-15) → 400 `TWO_FA_ALREADY_ENABLED`. 2.b2: User disables 2FA first (Normal Flow of the disable case) before starting setup again.
- 5.a1: Confirm while already enabled (double submit / race) → 400 `TWO_FA_ALREADY_ENABLED`. 5.a2: No action needed; 2FA is already on.
- 5.b1: Confirm with no pending secret — never called setup, or the 10-minute TTL expired → 400 `TWO_FA_NOT_ENABLED`. 5.b2: User restarts setup to get a fresh QR code.
- 5.c1: Confirm with a wrong code (BR-15) → 400 `TWO_FA_CODE_INVALID`, Display: MSG20; the pending secret is kept so the user can retry within the remaining TTL. 5.c2: User re-enters the code.
- 5.d1: Confirm with the 5th wrong code within 10 minutes for the same user (BR-86) → 429 `TWO_FA_TOO_MANY_ATTEMPTS`; the attempt counter resets. 5.d2: User waits for the 10-minute window to lapse (or a correct code on a later attempt after the window resets the counter) before retrying.
- Disable.a1: Disable while 2FA is not enabled, or no secret stored → 400 `TWO_FA_NOT_ENABLED`. Disable.a2: No action needed; 2FA already off.
- Disable.b1: Disable with a wrong code → 400 `TWO_FA_CODE_INVALID`, Display: MSG20. Disable.b2: User re-enters the code. On success, toast MSG25.
- Disable.c1: Disable with the 5th wrong code within 10 minutes for the same user (BR-86) → 429 `TWO_FA_TOO_MANY_ATTEMPTS`. Disable.c2: User waits for the window to lapse before retrying.
- 8.a1: Verify with an unparseable token, a token missing/mismatching `type=2fa`, or whose subject no longer resolves to a user (BR-05) → 401 `TWO_FA_TOKEN_INVALID`, toast MSG22. 8.a2: User is returned to `/login` to sign in again (client clears the stored `twoFactorToken`).
- 8.b1: Verify against a suspended or deactivated account → 403 `ACCOUNT_SUSPENDED` / 403 `ACCOUNT_DEACTIVATED`. 8.b2: User contacts support.
- 8.c1: 2FA was disabled between the login step and the verify step → 400 `TWO_FA_NOT_ENABLED`. 8.c2: The account no longer requires a second factor; user is directed back to sign in normally.
- 8.d1: Verify with a wrong code (BR-15) → 400 `TWO_FA_CODE_INVALID`, Display: MSG20. 8.d2: User re-enters the code from the app.
- 8.e1: Verify with the 5th wrong code within 10 minutes for the same user (BR-86) → 429 `TWO_FA_TOO_MANY_ATTEMPTS`, even though the `twoFactorToken` itself is still within its own 5-minute JWT expiry. 8.e2: User waits for the 10-minute attempt window to lapse, then signs in again (the `twoFactorToken` may have expired by then, requiring a fresh password/Google sign-in step).
- Lost authenticator app: no self-service recovery exists (BR-15 TBD). An administrator must disable 2FA on the user's behalf via direct data access; no dedicated admin endpoint for this exists in `AuthController`.

## Post-Conditions

- On enabling: `totpSecret` is stored, `twoFactorEnabled=true`, and the Redis pending-setup key is deleted; the BR-86 attempt counter is cleared.
- On disabling: `totpSecret` is cleared and `twoFactorEnabled=false`; the BR-86 attempt counter is cleared.
- On a successful verify at sign-in: `lastLoginAt` is updated, an `AuditAction.LOGIN` row is written, an access token plus refresh token (cookie) are issued — identical to a normal `/login` completion — and the BR-86 attempt counter is cleared.
- On a wrong code (any of the three flows): the BR-86 attempt counter for that user is incremented; on the 5th wrong code within 10 minutes it is deleted and further calls fail with 429 until the user succeeds or the window naturally expires.

## Out of Scope

- Recovery-code mechanism for lost devices (BR-15, TBD).
- Mandatory 2FA enforcement for OWNER/MANAGER roles (BR-17, TBD).
- Admin-initiated 2FA disable on behalf of a locked-out user (no endpoint exists today).

## References

Ground truth: `AuthController.java`, `AuthServiceImpl.java` (brandhub-business-service, incl. `checkTwoFactorAttempt` BR-86 lockout added this session); `Section5_Requirement_Appendix.md` BR-15, BR-17, BR-86, MSG20/22/24/25; `pages/security/index.tsx`, `pages/auth/TwoFactorVerifyPage.tsx`, `services/authService.ts` (brandhub-web-dashboard).
