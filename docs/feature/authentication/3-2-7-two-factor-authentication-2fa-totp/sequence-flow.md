# Sequence Flow — Two-Factor Authentication (2FA, TOTP)

> Companion to `spec.md` (3.2.7). Lists each actor → action → system step in enough detail to draw the sequence diagram directly; the business description lives in `spec.md`.

## Actors

- **User** — signed in when enabling or disabling, partway signed in when verifying.
- **Client** — the application the user interacts with.
- **System** — the application server.
- **Database** — persistent store holding accounts, their secret and their two-factor flag.
- **Token store** — short-lived state holding the pending secret.
- **Authenticator app** — the user's own code generator, outside the system.

---

## Flow A — Enabling two-factor authentication for the first time

1. User → Client: on the security settings screen, activates "Enable 2FA".
2. Client → System: requests the setup, carrying the access token.
3. System: loads the account; missing → 404 USER_NOT_FOUND; already enabled → 400 TWO_FA_ALREADY_ENABLED.
4. System: generates a random secret and stores it as pending with a 10-minute lifetime. The secret is not stored permanently at this step; it lives only in the token store until it is confirmed.
5. System → Client: 200 with the provisioning address, in the form of an authenticator enrolment address. The raw secret is not returned.
6. Client: renders the QR code from the provisioning address.
7. User → Authenticator app: scans the QR code, after which the app generates a six-digit code on a 30-second cycle.
8. User → Client: enters the code shown by the app to confirm.
9. Client → System: submits the confirmation with the code.
10. System:
    a. Two-factor authentication is already enabled, from a double submission or a race → 400 TWO_FA_ALREADY_ENABLED.
    b. No pending secret, because it expired after 10 minutes or the setup was never started → 400 TWO_FA_NOT_ENABLED.
    c. The code does not match the pending secret → System (self-call `checkTwoFactorAttempt`): increments the wrong-attempt counter in the token store (10-minute lifetime, set on the first miss); below the limit → 400 TWO_FA_CODE_INVALID, and the pending secret is kept so the user can retry within its lifetime; at the 5th miss within the window → the counter is cleared and 429 TWO_FA_TOO_MANY_ATTEMPTS is returned instead (BR-86).
    d. The code matches → System (self-call `checkTwoFactorAttempt`): clears the wrong-attempt counter; the secret is stored permanently and two-factor authentication is enabled, and the pending secret is cleared.
11. System → Client: 200 with no data, or 429 if the BR-86 limit was hit.
12. Client: confirms that two-factor authentication is now enabled.

## Flow B — Disabling two-factor authentication

1. User → Client: on the security settings screen, activates "Disable 2FA" and enters the current code to confirm.
2. Client → System: submits the request with the code, carrying the access token.
3. System: two-factor authentication is not enabled, or no secret is stored → 400 TWO_FA_NOT_ENABLED; the code does not match → System (self-call `checkTwoFactorAttempt`, same wrong-attempt counter and 10-minute window as Flow A/C, keyed by user) → 400 TWO_FA_CODE_INVALID below the limit, or 429 TWO_FA_TOO_MANY_ATTEMPTS at the 5th miss within the window (BR-86).
4. System: on a correct code, `checkTwoFactorAttempt` clears the wrong-attempt counter; the system disables two-factor authentication and clears the stored secret.
5. System → Client: 200 with no data, or 429 if the BR-86 limit was hit.

## Flow C — Verifying two-factor authentication at sign-in, continuing from 3.2.2 or 3.2.3

1. The user has completed the password step (3.2.2) or the Google sign-in (3.2.3) on an account with two-factor authentication enabled and has received a challenge token, which is not an access token.
2. User → Client: on the two-factor screen, enters the code shown by the authenticator app.
3. Client → System: submits the challenge token and the code. No access token is carried, because the challenge token itself is the proof that the first step succeeded.
4. System:
   a. The challenge token cannot be read, or is not of the expected kind → 401 TWO_FA_TOKEN_INVALID.
   b. No account matches the subject of the challenge token → 401 TWO_FA_TOKEN_INVALID.
   c. The account status check → 403 ACCOUNT_SUSPENDED or 403 ACCOUNT_DEACTIVATED.
   d. Two-factor authentication was disabled in the meantime, or no secret is stored → 400 TWO_FA_NOT_ENABLED.
   e. The code does not match → System (self-call `checkTwoFactorAttempt`, same wrong-attempt counter/window as Flow A/B, keyed by user, shared across all three flows) → below the limit, 400 TWO_FA_CODE_INVALID; at the 5th miss within 10 minutes, the counter is cleared and 429 TWO_FA_TOO_MANY_ATTEMPTS is returned instead — even though the challenge token itself may still be within its own 5-minute lifetime (BR-86).
   f. The code matches → `checkTwoFactorAttempt` clears the wrong-attempt counter, then the sign-in is completed: the sign-in time and event are recorded and an access token together with a refresh token are issued, exactly as in a normal sign-in.
5. System → Client: 200 with the access token, its type and its expiry, and sets the refresh token as an HTTP-only cookie (or 429 if the BR-86 limit was hit).
6. Client: stores the token, loads the profile and navigates to the Dashboard / Agency list.

---

## Error paths summary (for "alt"/"opt" fragments)

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| Setup | The account does not exist | 404 | `USER_NOT_FOUND` |
| Setup | Two-factor authentication is already enabled | 400 | `TWO_FA_ALREADY_ENABLED` |
| Confirm | Two-factor authentication is already enabled | 400 | `TWO_FA_ALREADY_ENABLED` |
| Confirm | No pending secret, because it expired or the setup was never started | 400 | `TWO_FA_NOT_ENABLED` |
| Confirm | Wrong code | 400 | `TWO_FA_CODE_INVALID` |
| Confirm | 5th wrong code within 10 minutes (BR-86) | 429 | `TWO_FA_TOO_MANY_ATTEMPTS` |
| Disable | Two-factor authentication is not enabled | 400 | `TWO_FA_NOT_ENABLED` |
| Disable | Wrong code | 400 | `TWO_FA_CODE_INVALID` |
| Disable | 5th wrong code within 10 minutes (BR-86) | 429 | `TWO_FA_TOO_MANY_ATTEMPTS` |
| Verify at sign-in | The challenge token cannot be read or is of the wrong kind | 401 | `TWO_FA_TOKEN_INVALID` |
| Verify at sign-in | No account matches the challenge token | 401 | `TWO_FA_TOKEN_INVALID` |
| Verify at sign-in | The account is suspended | 403 | `ACCOUNT_SUSPENDED` |
| Verify at sign-in | The account is deactivated | 403 | `ACCOUNT_DEACTIVATED` |
| Verify at sign-in | Two-factor authentication was disabled in the meantime | 400 | `TWO_FA_NOT_ENABLED` |
| Verify at sign-in | Wrong code | 400 | `TWO_FA_CODE_INVALID` |
| Verify at sign-in | 5th wrong code within 10 minutes (BR-86) | 429 | `TWO_FA_TOO_MANY_ATTEMPTS` |

## Notes

- A wrong code at confirmation keeps the pending secret, so the user can retry within the 10-minute window (subject to the BR-86 attempt limit below); a wrong code at disabling or at sign-in changes nothing except the shared attempt counter.
- The secret is stored permanently only after a correct code confirms it.
- Two-factor authentication applies to every sign-in method and is never bypassed by Google sign-in (3.2.3).
- No recovery codes are offered, so a user who loses the authenticator app needs an administrator to disable two-factor authentication.
- **BR-86 (implemented):** `AuthServiceImpl.checkTwoFactorAttempt(userId, codeValid)` is called by all three flows (confirm, disable, verify) whenever a TOTP code is checked. It keeps a per-user wrong-attempt counter in the token store, keyed by the user id (not by the challenge token or pending-setup secret), with a 10-minute lifetime starting on the first wrong attempt. A correct code clears the counter immediately. The 5th wrong code within the 10-minute window clears the counter and returns 429 `TWO_FA_TOO_MANY_ATTEMPTS` instead of 400 `TWO_FA_CODE_INVALID` — this can happen even while the challenge token or pending-setup secret is itself still within its own (shorter or longer) natural expiry. This mirrors the existing OTP-attempt pattern used for email/phone OTP (same shared max-attempts constant).
