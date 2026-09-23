# Sequence Flow — Change Password

> Companion to `spec.md` (3.2.5). Lists each actor → action → system step in enough detail to draw the sequence diagram directly; the business description lives in `spec.md`.

## Actors

- **User** — already signed in.
- **Client** — the application the user interacts with.
- **System** — the application server.
- **Database** — persistent store holding accounts and the recorded events.

---

## Flow A — Successful password change

1. User → Client: opens /settings/change-password and enters the current password, the new password and the confirmation. The screen validates that the confirmation matches and requires a confirmation step before submission.
2. Client → System: submits the current password and the new password, carrying the access token.
3. System: checks that the request carries a usable access token; a missing or malformed one → 401 INVALID_CREDENTIALS, answered before any account lookup.
4. System:
   a. Identifies the caller from the access token.
   b. Loads the account: missing, even with a valid token, → 404 USER_NOT_FOUND.
   c. Compares the current password with the stored password hash; a mismatch → 400 WRONG_CURRENT_PASSWORD.
   d. Compares the new password with the stored password hash; when they are the same → 400 SAME_AS_CURRENT_PASSWORD. This check runs only after step (c) has been accepted.
   e. Replaces the password hash and updates the last password change time.
   f. Records the password change event, using the same event as Reset Password (3.2.4) rather than a separate one.
5. System → Client: 200 with no data.
6. Client: shows a success message and keeps the session. The access token stays valid, so the current session is not ended, unlike Reset Password. Every refresh token issued before the change is refused on its next use, giving 401 REFRESH_TOKEN_INVALID.

---

## Error paths summary (for "alt"/"opt" fragments)

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| Change password | Missing or malformed access token | 401 | `INVALID_CREDENTIALS` |
| Change password | The account no longer exists, even with a valid token | 404 | `USER_NOT_FOUND` |
| Change password | Wrong current password | 400 | `WRONG_CURRENT_PASSWORD` |
| Change password | The new password equals the current one, evaluated only after the current password has been accepted | 400 | `SAME_AS_CURRENT_PASSWORD` |
| Change password | The new password does not meet the policy | 400 | `VALIDATION_ERROR` |

## Notes

- The order of the checks matters: the current password is verified first, and the comparison between the new and the current password is only reached once it has been accepted.
- The session stays active on the device that made the change, while sessions on other devices lose their refresh token on the next refresh.
