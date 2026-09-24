# Sequence Flow — Reset Password

> Companion to `spec.md` (3.2.4). Lists each actor → action → system step in enough detail to draw the sequence diagram directly; the business description lives in `spec.md`.

## Actors

- **User** — has forgotten the password and cannot sign in.
- **Client** — the application the user interacts with.
- **System** — the application server.
- **Database** — persistent store holding accounts.
- **Token store** — short-lived state holding the reset token and the most recent token issued per account.
- **Mail** — outbound email used to deliver the reset link.

---

## Flow A — Forgot password → link received → reset successful

1. User → Client: opens /forgot-password and enters the email address.
2. Client → System: submits the password reset request.
3. System:
   a. Looks the account up by the normalized email address; when nothing matches it returns immediately and treats the request as successful, so the answer never reveals whether the account exists.
   b. When an account matches, reads the most recent reset token issued for it, if any.
   c. When an earlier token exists, invalidates it immediately.
   d. Generates a new single-use token with a limited lifetime.
   e. Stores the token against the account, and stores the token as the most recent one for that account, both with the same lifetime.
   f. Sends the email carrying the reset link with the token.
4. System → Client: 200 with no data, always, whether or not the email address exists.
5. Client: shows a generic message stating that a link will arrive if the address exists.
6. User → Client: opens the link from the email and lands on the reset screen with the token.
7. User: enters the new password and the confirmation, which the screen validates before submission.
8. Client → System: submits the reset with the token and the new password.
9. System:
   a. Reads the token: unknown or expired → 400 RESET_TOKEN_INVALID.
   b. Consumes the token atomically; when the token was already consumed by a concurrent request → 400 RESET_TOKEN_USED.
   c. Loads the account referenced by the token: missing → 400 RESET_TOKEN_INVALID.
   d. Clears the record of the most recent token for the account.
   e. Replaces the password hash and updates the last password change time.
   f. Records the password change event.
10. System → Client: 200 with no data.
11. Client: shows a success message and returns to /login.
    - Consequence: every refresh token issued before the last password change time is refused on its next use, because a refresh compares the issue time of the token with the last password change time of the account, giving 401 REFRESH_TOKEN_INVALID.

## Flow B — Repeated forgot-password requests supersede the earlier token

1. User → Client → System: submits the request a first time. The system issues a first token, stores it against the account and records it as the most recent token for that account, both with the same lifetime, and returns 200.
2. User → Client → System: submits the request a second time for the same address before the first token is used.
   a. The system reads the most recent token for the account, finds the first token and invalidates it immediately.
   b. The system issues a second token and records it as the most recent one, replacing the first, and returns 200.
3. User presents the first token, which has been invalidated → the token is unknown → 400 RESET_TOKEN_INVALID, even though its original lifetime has not elapsed.
4. User presents the second token → it is valid → the reset proceeds as Flow A step 9 and returns 200.

---

## Error paths summary (for "alt"/"opt" fragments)

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| Forgot password | The email address does not exist | 200 | — (silent, no error) |
| Reset password | The token is unknown, expired, or superseded by a newer request | 400 | `RESET_TOKEN_INVALID` |
| Reset password | The token was just consumed, including two simultaneous requests | 400 | `RESET_TOKEN_USED` |
| Reset password | The account referenced by the token no longer exists | 400 | `RESET_TOKEN_INVALID` |
| Reset password | The new password does not meet the policy | 400 | `VALIDATION_ERROR` |

## Notes

- Only the most recent reset token per account is accepted, so a newer request immediately disables an earlier link.
- The request step is deliberately silent: the same answer is returned for known and unknown addresses, which prevents discovering whether an account exists.
