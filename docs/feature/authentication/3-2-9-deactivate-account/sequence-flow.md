# Sequence Flow — Deactivate Account

> Companion to `spec.md` (3.2.9). Lists each actor → action → system step in enough detail to draw the sequence diagram directly; the business description lives in `spec.md`. There are two flows, chosen from whether the account has a password.

## Actors

- **User** — wants to disable their own account.
- **Client** — the application the user interacts with, showing the Danger Zone on the profile screen.
- **System** — the application server.
- **Database** — persistent store holding accounts and agencies.
- **Token store** — short-lived state holding the confirmation code.
- **Mail** — outbound email used to deliver the confirmation code.

---

## Flow A — Account with a password

1. User → Client: on the profile screen, scrolls to the Danger Zone, activates "Deactivate" and enters the password in the confirmation dialog.
2. Client → System: submits the password carrying the access token.
3. System:
   a. Resolves the caller from the access token; a missing or malformed token → 401 INVALID_CREDENTIALS.
   b. Loads the account; missing → 404 USER_NOT_FOUND.
   c. The account has a password, so this is the password flow: the submitted password is compared with the stored password hash; a mismatch → 400 WRONG_CURRENT_PASSWORD.
   d. Checks the agencies owned by the account and keeps only the active ones; none are active.
   e. Marks the account as deactivated without removing anything.
4. System → Client: 200 with no data.
5. Client: clears the local session and returns to /login.
6. User tries to sign in again → the sign-in status check finds the account deactivated and answers 403 ACCOUNT_DEACTIVATED (3.2.2).

### Flow A' — Blocked because an active agency is owned

Same as steps 1–3c, diverging at 3d:

3d'. The account owns at least one active agency → 409 AGENCY_OWNERSHIP_ACTIVE and the account status is left unchanged.
4'. System → Client: 409 with the error code AGENCY_OWNERSHIP_ACTIVE.
5'. Client: shows the error and asks the user to transfer ownership of the agency before deactivating.

---

## Flow B — Account without a password

### B.1 — Sending the confirmation code

1. User → Client: on the profile screen, activates "Deactivate"; the client detects that the account has no password and shows the "Send confirmation code" step.
2. User → Client: activates "Send code".
3. Client → System: requests the code carrying the access token and no other data.
4. System:
   a. Resolves the caller from the access token; a missing or malformed token → 401 INVALID_CREDENTIALS.
   b. Loads the account; missing → 404 USER_NOT_FOUND.
   c. Generates a random six-digit code.
   d. Stores the code against the account with a 10-minute lifetime.
   e. Sends the code by email.
5. System → Client: 200 with no data.
6. Client: reports that the code has been sent and shows the code input in place of the password input.
7. User: reads the code from the email.

### B.2 — Confirming deactivation with the code

8. User → Client: enters the code and confirms.
9. Client → System: submits the code carrying the access token.
10. System:
    a. Resolves the caller from the access token; a missing or malformed token → 401 INVALID_CREDENTIALS.
    b. Loads the account; missing → 404 USER_NOT_FOUND.
    c. The account has no password, so this is the code flow: the stored code for the account is read.
    d. No stored code, an empty submitted code, or a mismatch → 400 OTP_INVALID.
    e. The code matches → the stored code is consumed so it cannot be reused.
    f. Checks the agencies owned by the account and keeps only the active ones; none are active.
    g. Marks the account as deactivated.
11. System → Client: 200 with no data.
12. Client: clears the local session and returns to /login.
13. User tries to sign in again → the sign-in status check finds the account deactivated and answers 403 ACCOUNT_DEACTIVATED.

### Flow B' — Blocked because an active agency is owned

Same as steps 8–10e, diverging at 10f:

10f'. The account owns at least one active agency → 409 AGENCY_OWNERSHIP_ACTIVE and the account status is left unchanged. Note that the code was already consumed at step 10e, so a new code must be requested before retrying after the ownership has been transferred.
11'. System → Client: 409 with the error code AGENCY_OWNERSHIP_ACTIVE.

### Flow B'' — Code wrong, missing, expired, or never requested

10d'. No stored code, either because none was requested or because the 10-minute lifetime has elapsed, or the submitted code is empty or does not match → 400 OTP_INVALID.
11''. System → Client: 400 with the error code OTP_INVALID.

---

## Error paths summary (for "alt"/"opt" fragments)

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| Send code, Deactivate | Missing or malformed access token | 401 | `INVALID_CREDENTIALS` |
| Send code, Deactivate | The account does not exist, even with a valid token | 404 | `USER_NOT_FOUND` |
| Deactivate, password flow | Wrong password | 400 | `WRONG_CURRENT_PASSWORD` |
| Deactivate, code flow | The code is wrong, missing, expired, or was never requested | 400 | `OTP_INVALID` |
| Deactivate, both flows | The account owns at least one active agency | 409 | `AGENCY_OWNERSHIP_ACTIVE` |

## Notes

- The flow is chosen by the account, not by the request: an account with a password is only confirmed by the password, and an account without one only by a code. The other field is ignored when it is supplied.
- Deactivation is a soft delete: the account is marked as deactivated and all related data is kept, so the user cannot sign in while the data remains available.
- Ownership of an active agency blocks deactivation in both flows, and the code is consumed before that check, so a fresh code is needed after transferring ownership.
