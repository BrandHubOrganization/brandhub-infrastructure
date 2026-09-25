# 3.2.9 Deactivate Account

| | |
|---|---|
| FR Code | 3.2.9 |
| Feature | Deactivate Account |
| Domain | Authentication (FR 3.2) |
| Role | Any signed-in USER, for their own account |
| Version | 3.0 — 2026-09-25 — re-verified against AuthController/AuthServiceImpl: BR-22 token blacklist is now real code (`accessToken`/`refreshToken` params added to `deactivate()`, both blacklisted via `JwtUtil` after status update); BR-23 confirmed satisfied by the existing `AGENCY_OWNERSHIP_ACTIVE` guard, which was not changed this session — only the appendix wording around it. OTP resend-cooldown gap (previous v2.0 note) still open, unchanged. |
| Document status | Implemented |

## Function Trigger

Begins when a signed-in user activates "Deactivate" in the Danger Zone of the profile screen (`/profile`) and confirms the dialog with their password, or, for an account with no password, with a one-time code sent to their email.

## Function Description

-  **Actors / Roles:** USER who is signed in, either with a password or as an OAuth-only account (`passwordHash == null`, e.g. created through Google) with no password.
-  **Purpose:** Let a user disable their own account (soft delete — no row is removed) after proving identity with the password or with a one-time email code, and immediately cut off their active sessions.
-  **Interface:** Danger Zone section on `/profile` with a confirmation dialog. Accounts with a password show a password field. Accounts without a password show a "Send code" button and, once sent, a six-digit code field.
-  **Data Processing:** `AuthController.deactivate` resolves the caller from the Bearer access token, reads the `refreshToken` cookie, and reads the raw access token from the `Authorization` header. `AuthServiceImpl.deactivate` loads the user, verifies identity via the password or OTP branch, checks the caller does not own any ACTIVE agency, sets `user.status = DEACTIVATED` and saves, then blacklists the caller's access token and refresh token (best-effort) so active sessions are cut off immediately.

## Screen Layout

Figure — Deactivate Account (`/profile`, Danger Zone), grounded in `brandhub-web-dashboard/src/pages/profile/index.tsx`:
-  A red-bordered "Danger Zone" card with a warning icon, a hint line, and a "Deactivate" button (`profile.danger.deactivateButton`) that opens the confirm dialog (`deactivateOpen`).
-  If the account has a password (`hasPassword`): the dialog shows a password `Input` (`deactivatePassword`).
-  If the account has no password: the dialog shows a "Send code" / "Resend code" `Button` (`handleSendDeactivateOtp`, loading state `sendingOtp`) followed by an OTP `Input` (`deactivateOtp`).
-  Cancel and a destructive "Confirm Deactivate" button (`handleDeactivate`); the confirm button is disabled until the relevant field (password or OTP) is non-empty, or while the request is in flight (`deactivating`).
-  On success the client clears the local session and returns to `/login`.

## Function Details

### Data Specifications

-  **Input required:** Bearer access token (`Authorization` header). Exactly one of `password` or `otpCode`, selected by the account's own state (`user.passwordHash == null`), not by which field the client sends.
-  **Input optional:** `DeactivateRequest(password, otpCode)` — both fields are optional at the DTO level (no `@Valid` constraint on either); the service enforces which one is actually required based on account type, and ignores the other. `refreshToken` cookie is optional (its absence just skips the refresh-token blacklist step).
-  **System data:** `userId` (from token), `user.passwordHash`, `user.status`, Redis key `otp:deactivate:{userId}` (OTP value, TTL 10 min), agencies owned by the user and their `status`, the caller's raw access token (from the `Authorization` header) and refresh token (from the `refreshToken` cookie).
-  **Output:** `ApiResponse<Void>` — no payload, 200 OK.

### Business Rules

-  **BR-22:** Account deactivation sets `user.status = UserStatus.DEACTIVATED` and blacklists outstanding tokens so active sessions are cut off; reversible unless decided otherwise (TBD). Implemented in `AuthServiceImpl.deactivate()`: after `user.setStatus(DEACTIVATED)` / `save(user)`, the method blacklists the caller's access token (from the `Authorization` header, passed through by `AuthController`) and refresh token (from the `refreshToken` cookie) via `jwtUtil.blacklistToken(...)`, each wrapped in a best-effort try/catch that ignores `JwtException` for a malformed or absent token. A subsequent login or refresh is also rejected by `checkStatus()` with 403 `ACCOUNT_DEACTIVATED`, but the blacklist call is what makes cut-off immediate rather than only on next refresh/expiry.
-  **BR-23:** The last active OWNER of an Agency cannot self-deactivate. `OWNER` is an Agency-level role only (workspace `MemberRole` has no `OWNER`), so the enforcement point is the Agency-ownership check: after identity is confirmed, `AuthServiceImpl.deactivate()` checks `agencyRepository.findByOwnerId(userId)` for any Agency with `status == ACTIVE`. If one exists → 409 `AGENCY_OWNERSHIP_ACTIVE`, account left unchanged; ownership must be transferred first. This guard existed prior to this session and is unchanged; what changed is only the shared understanding that it is BR-23's real enforcement (the appendix's own wording has already been corrected to say "Agency" rather than "workspace" and cites this same guard).
-  **Identity confirmation (implements BR-22's precondition):** the account itself selects the branch — `user.passwordHash == null` → OTP branch (Redis key `otp:deactivate:{userId}`; missing, expired, or mismatched code → 400 `OTP_INVALID`; a match deletes the key so it cannot be reused). `user.passwordHash != null` → password branch (`passwordEncoder.matches` mismatch → 400 `WRONG_CURRENT_PASSWORD`). Whichever field does not match the branch is ignored.
-  **`sendDeactivateOtp` (OTP delivery):** generates a 6-digit OTP, stores it in Redis (`otp:deactivate:{userId}`, TTL 10 min), sends it via `MailService.sendOtpEmail`.
   -  ⚠ **BA conflict (needs team decision):** `sendDeactivateOtp` has no resend cooldown/rate-limit check. This is asymmetric with the analogous email-OTP flow (`resendOtp`, 60s cooldown via Redis key `otp:resend:{email}`) and the phone-OTP flow (`linkPhone`, 60s cooldown via `phone:otp:resend:{userId}`), both of which do check a cooldown before issuing a new code. Likely an oversight rather than an intentional design difference. Unchanged this session.
-  Missing/malformed Bearer token → 401 `INVALID_CREDENTIALS` (via `requireUserId`).
-  Account referenced by the token no longer exists → 404 `USER_NOT_FOUND`.

### Validation

-  Missing or malformed access token → 401 `INVALID_CREDENTIALS`, toast MSG22.
-  `password` empty (password branch) → Display: **MSG02**.
-  `otpCode` empty or malformed (OTP branch) → Display: **MSG02**.

### Normal Flow

1. User opens the Danger Zone on `/profile` and activates "Deactivate".
2. Client resolves whether the account has a password (`hasPassword`) and shows the matching field.
3. For an OAuth-only account, the user first clicks "Send code" → `POST /api/v1/auth/deactivate/send-otp` → `sendDeactivateOtp` generates and emails a 6-digit OTP (Redis TTL 10 min).
4. The user supplies the password or the OTP and confirms → `POST /api/v1/auth/deactivate { password?, otpCode? }`, with the `Authorization: Bearer <accessToken>` header and (if present) the `refreshToken` cookie sent automatically by the browser.
5. `AuthController.deactivate` resolves the caller (`requireUserId`), extracts the raw access token from the header and the refresh token from the cookie.
6. `deactivate` loads the user (404 `USER_NOT_FOUND` if missing) and verifies the password or the OTP depending on `passwordHash`.
7. `deactivate` checks `agencyRepository.findByOwnerId(userId)` for an ACTIVE agency (BR-23); none found.
8. `deactivate` sets `user.status = DEACTIVATED` and saves.
9. `deactivate` blacklists the access token and, if present, the refresh token via `jwtUtil.blacklistToken(...)` (BR-22), ignoring failures on a malformed/absent token.
10. 200 OK, no payload; client clears the local session, redirects to `/login`, toast MSG91 ("Account deactivated successfully.").

### Abnormal Cases

-  5.a1: Missing or invalid access token → 401 `INVALID_CREDENTIALS`, toast MSG22. 5.a2: The user signs in again.
-  6.a1: Account referenced by the token no longer exists → 404 `USER_NOT_FOUND`, toast MSG38. 6.a2: The user signs in again with a valid account.
-  6.b1: Password branch, wrong password → 400 `WRONG_CURRENT_PASSWORD`, Display: **MSG19**. 6.b2: The user re-enters the password.
-  6.c1: OTP branch — code missing, expired (>10 min), never requested, or mismatched → 400 `OTP_INVALID`, Display: **MSG20**. 6.c2: The user requests a new code (no cooldown enforced — see BA conflict above) and re-enters it.
-  7.a1: The user owns at least one ACTIVE agency (BR-23) → 409 `AGENCY_OWNERSHIP_ACTIVE`, toast MSG38. 7.a2: The user transfers agency ownership first; if the OTP branch was used, the OTP has already been consumed, so a new code must be requested before retrying.
-  9.a1: Access token is malformed, expired, or absent when `deactivate()` reaches the blacklist step → `jwtUtil.blacklistToken` throws `JwtException`, caught and ignored; deactivation still succeeds (status is already saved at step 8). 9.a2: Same handling for a malformed/absent `refreshToken` cookie — no user-visible error either way, this is a best-effort cleanup step after the account state change already committed.

## Post-Conditions

-  `user.status = DEACTIVATED`; all related rows (agencies, workspace memberships, etc.) are kept — this is a soft delete.
-  The OTP, when the OTP branch was used, is consumed (Redis key deleted) and cannot be reused.
-  The caller's access token and refresh token (if present) are blacklisted via `JwtUtil`, so the currently active session is cut off immediately, not just on next refresh attempt.
-  A subsequent login or refresh attempt is also rejected with 403 `ACCOUNT_DEACTIVATED` (`checkStatus()`), independent of the blacklist.

## Out of Scope

-  Reactivating a deactivated account (no endpoint in `AuthController` for this; TBD per BR-22's "reversible unless decided otherwise").
-  Deleting the account's data (deactivation is a soft delete only).
-  OTP resend cooldown on `sendDeactivateOtp` (see BA conflict above).

## References

Section5_Requirement_Appendix.md (BR-22, BR-23, MSG02, MSG19, MSG20, MSG91) — read-only, not modified.
