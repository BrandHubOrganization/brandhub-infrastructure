# Sequence Flow — Sign In With Email

> Companion to `spec.md` (3.2.2). Lists each actor → action → system step in enough detail to draw the sequence diagram directly; the business description lives in `spec.md`.

## Actors

- **User** — holds an existing account.
- **Client** — the application the user interacts with.
- **System** — the application server.
- **Database** — persistent store holding accounts and their role assignments, plus workspace memberships.
- **Token store** — short-lived state used to invalidate tokens that have been signed out.

---

## Flow A — Successful sign-in without two-factor authentication

1. User → Client: opens /login and enters the identifier, which may be an email address or a phone number, together with the password.
2. Client → System: submits the credentials.
3. System:
   a. Resolves the identifier: a value containing "@" is matched as an email address in lower case, anything else is normalized as a phone number and matched as a phone. No match → 401 INVALID_CREDENTIALS.
   b. Checks the account status: inactive → 403 ACCOUNT_SUSPENDED; deactivated → 403 ACCOUNT_DEACTIVATED; any other status → 403 ACCOUNT_SUSPENDED.
   c. Compares the submitted password with the stored password hash; a mismatch, or an account without a password, → 401 INVALID_CREDENTIALS.
   d. With two-factor authentication disabled, completes the sign-in: records the sign-in time and the sign-in event, resolves the active workspace and issues an access token together with a refresh token.
4. System → Database: persists the last sign-in time, the event record and the resolved workspace reference.
5. System → Client: 200 with the access token, its type and its expiry, and sets the refresh token as an HTTP-only cookie scoped to the authentication area.
6. Client: stores the access token, loads the profile and navigates to the Dashboard / Agency list.

## Flow B — Sign-in on an account with two-factor authentication enabled

Same as Flow A steps 1–3c, diverging from step 3d:

1. System: two-factor authentication is enabled, so it issues a two-factor challenge token instead of the tokens — no access token and no refresh token are produced at this step.
2. System → Client: 200 carrying the challenge flag and the challenge token; no refresh cookie is set.
3. Client: stores the challenge token and navigates to the two-factor code screen (3.2.7).
4. Continues in Two-Factor Authentication (3.2.7): a correct code returns the real access token and sets the refresh cookie, after which the client resumes Flow A step 6.

---

## Error paths summary (for "alt"/"opt" fragments)

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| Sign in | No account matches the identifier | 401 | `INVALID_CREDENTIALS` |
| Sign in | Wrong password, or an account without a password | 401 | `INVALID_CREDENTIALS` |
| Sign in | Inactive account, or a status other than ACTIVE or DEACTIVATED | 403 | `ACCOUNT_SUSPENDED` |
| Sign in | Status DEACTIVATED | 403 | `ACCOUNT_DEACTIVATED` |
| Sign in | Two-factor authentication enabled, awaiting the separate verification | 200 | no error — the challenge flag is set |
| Refresh | Missing cookie, unusable token, or a token issued before the latest password change | 401 | `REFRESH_TOKEN_INVALID` |
| Refresh | Token invalidated by sign-out | 401 | `REFRESH_TOKEN_BLACKLISTED` |

## Notes

- The identifier field accepts both an email address and a phone number, which is why the same wrong-credential answer covers both.
- The refresh token travels only as an HTTP-only cookie and is rotated on every successful refresh.
