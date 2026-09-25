# 3.2.5 Change Password

| | |
|---|---|
| FR Code | 3.2.5 |
| Feature | Change Password |
| Domain | Authentication (FR 3.2) |
| Role | Any signed-in user, changing their own password |
| Version | 1.1 — 2026-09-25 — corrected success toast MSG code (see BA conflict below); confirmed against `AuthController`/`AuthServiceImpl` |
| Document status | Implemented |

## Function Trigger

Begins when a signed-in user opens the change-password section under `/settings` (Security tab) and submits the current password together with a new password and its confirmation.

## Function Description

- **Actors / Roles:** Any authenticated user (USER) changing their own password. Applies to any account that already has a password set.
- **Purpose:** Let a signed-in user change the password after proving knowledge of the current one, without ending the current session.
- **Interface:** A form on the Settings > Security page with three fields — Current Password, New Password, Confirm New Password — and a submit button.
- **Data Processing:** The system identifies the caller from the `Authorization: Bearer` access token, verifies the current password against the stored hash, refuses a new password identical to the current one, replaces the password hash, updates the last-password-change timestamp, and records an audit log event.

**Related/adjacent endpoint:** `POST /api/v1/auth/set-password` (`SetPasswordRequest{password}`) covers a different case — an OAuth-only account that has no password yet — and takes only a new password (no current password to verify). It is implemented in the same `AuthController`/`AuthServiceImpl` and is documented here only as context; its full behavior belongs to its own FR, not 3.2.5. It requires the same Bearer auth (`requireUserId` helper) and returns 400 `PASSWORD_ALREADY_SET` if the account already has a password hash.

**Out of scope:** Forgot/reset password (`POST /forgot-password`, `POST /reset-password`) is a separate flow — FR 3.2.4 — and is not covered here.

## Screen Layout

Figure — Change Password (Settings > Security):
- A card titled "Change Password" inside the Settings > Security tab (`/settings`, Security section).
- Three password inputs, top to bottom: Current Password, New Password, Confirm New Password (client-only confirmation field, not sent to the API).
- A single submit button ("Change Password" / arrow icon) that shows a loading state while the request is in flight.
- On success: a toast confirms the change and the user is navigated to the dashboard; the current session stays signed in.
- On failure: an inline/toast error message is shown and the form remains filled in for correction.

(Ground truth: `brandhub-web-dashboard/src/pages/change-password/index.tsx`, calling `authService.changePassword({ currentPassword, newPassword })` from `src/services/authService.ts`.)

## Function Details

### Data Specifications

- **Input required:** `currentPassword`, `newPassword` (request body `ChangePasswordRequest`); `Authorization: Bearer <accessToken>` header.
- **Input optional:** `confirmNewPassword` — client-side only, never sent to the API; checked for equality with `newPassword` before submit.
- **System data:** `userId` (parsed from the access token's JWT subject), `user.passwordHash`, `user.lastPasswordChange`, the audit log entry.
- **Output:** `ApiResponse<Void>`, HTTP 200, no data payload.

### Business Rules

- **BR-02:** Password policy — minimum 8 characters and at least 1 digit; the accepted password is hashed with BCrypt at cost factor 12; the password value is never logged or returned in any response.
- Check order in `AuthServiceImpl.changePassword`: (1) verify `currentPassword` against `user.passwordHash` — mismatch → 400 `WRONG_CURRENT_PASSWORD`; (2) only once (1) passes, compare `newPassword` against the same stored hash — a match → 400 `SAME_AS_CURRENT_PASSWORD`; (3) only then hash and persist the new password.
- **BR-12:** Changing the password sets `lastPasswordChange = now()`. A refresh token whose `jti` was issued before this timestamp is rejected on its next use (`REFRESH_TOKEN_INVALID`) — i.e., changing the password invalidates every outstanding refresh token, on every device, even though the current access token and current session remain valid until it expires.
- The same `AuditAction.PASSWORD_RESET` audit action is reused for both Reset Password (3.2.4) and Change Password — the code does not have a distinct "password changed" audit action.

### Validation

- `currentPassword` or `newPassword` empty → Display: MSG02.
- `newPassword` fewer than 8 characters or missing a digit (BR-02) → 400 `VALIDATION_ERROR`, Display: MSG05.
- `confirmNewPassword` does not match `newPassword` (client-side only) → Display: MSG06.
- Missing or malformed `Authorization: Bearer` header → 401 `INVALID_CREDENTIALS` (checked in `AuthController.changePassword` before the service is called).

## Functionalities

### Normal Flow

1. The user opens Settings > Security and enters the current password, the new password, and the confirmation.
2. The client checks that the confirmation matches the new password; on submit it calls `POST /api/v1/auth/change-password` with `{currentPassword, newPassword}` and the Bearer access token.
3. The system parses the access token's JWT subject to resolve the caller's `userId` and loads the account.
4. The system verifies `currentPassword` against the stored `passwordHash`.
5. The system compares `newPassword` against the same stored hash and rejects it if identical.
6. The system replaces `passwordHash` with the BCrypt hash of `newPassword`, sets `lastPasswordChange = now()`, saves the user, and writes an audit log entry (`AuditAction.PASSWORD_RESET`).
7. The system returns 200 with no data. The client shows a success toast and navigates to the dashboard; the current session stays signed in, while every outstanding refresh token is invalidated (BR-12).

### Abnormal Cases

- 2.a1: Missing or malformed `Authorization: Bearer` header → 401 `INVALID_CREDENTIALS`. 2.a2: The user is signed out and returned to login.
- 3.a1: The account referenced by the token no longer exists → 404 `USER_NOT_FOUND`. 3.a2: The user is signed out and must sign in again with a valid account.
- 4.a1: `currentPassword` does not match the stored hash (BR-02 check order, evaluated first) → 400 `WRONG_CURRENT_PASSWORD`, Display: MSG19 ("Current password is incorrect."). 4.a2: The user re-enters the current password.
- 5.a1: `newPassword` is identical to `currentPassword`, evaluated only after step 4 has passed → 400 `SAME_AS_CURRENT_PASSWORD`. 5.a2: The user enters a different new password.
- 1.a1: `newPassword` fails the policy check (BR-02) → 400 `VALIDATION_ERROR`, Display: MSG05. 1.a2: The user corrects the password and resubmits.
- 1.b1: `currentPassword` or `newPassword` empty → Display: MSG02. 1.b2: The user fills in the missing field and resubmits.
- Both `currentPassword` is wrong and `newPassword` happens to equal the real current password → `WRONG_CURRENT_PASSWORD` is returned (check order puts it first), never `SAME_AS_CURRENT_PASSWORD`.

## Post-Conditions

- `user.passwordHash` is replaced with the new BCrypt hash and `user.lastPasswordChange` is updated to the change time.
- An audit log entry (`AuditAction.PASSWORD_RESET`) is recorded for the user.
- The current session (current access token) remains valid and signed in.
- Every refresh token issued before the change — on this device or any other — is rejected on its next use (401 `REFRESH_TOKEN_INVALID`), per BR-12; the user must sign in again on those other sessions.

## Out of Scope

- Forgot/Reset Password (FR 3.2.4) — the unauthenticated "forgot password" email-token flow. Not covered here.
- Set Password for OAuth-only accounts (`POST /api/v1/auth/set-password`) — mentioned above as a related endpoint only; its own FR owns the full spec.

## BA / Code Conflicts

- ⚠ **BA conflict (needs team decision): no dedicated MSG code exists for change-password success.** The BA appendix (`Section5_Requirement_Appendix.md`) has no MSG entry named for "password changed" — the closest analogous code is **MSG18** ("Password updated successfully.", currently labelled for Reset Password) and MSG26 is "Profile updated successfully." (a different feature — profile update, not password). The previous version of this spec cited MSG26, which is incorrect for this flow; this version references **MSG18** as the nearest analogous code pending a BA decision on whether a distinct MSG (e.g. MSG-changepw) should be added.

## References

Ground truth: `AuthController.java` (`changePassword`, `setPassword`, `requireUserId`), `AuthServiceImpl.java` (`changePassword`, `setPassword`), `ErrorCode.java`. Frontend: `brandhub-web-dashboard/src/pages/change-password/index.tsx`, `src/services/authService.ts`. BA: `Section5_Requirement_Appendix.md` (BR-02, BR-12, MSG02, MSG05, MSG06, MSG18, MSG19) — read-only, not modified.
