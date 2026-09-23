# Sequence Flow — Sign In With Google OAuth

> Companion to `spec.md` (3.2.3). Lists each actor → action → system step in enough detail to draw the sequence diagram directly; the business description lives in `spec.md`. The flow is server-driven: the browser navigates straight to the application, which performs the handshake with Google.

## Actors

- **Guest** — signs in with an existing Google account.
- **Browser / Client** — the application, which resumes control once the browser returns.
- **System** — the application server.
- **Google** — the Google authorization and profile service.
- **Database** — persistent store holding accounts, their linked external identities and their role assignments.
- **Token store** — short-lived state used to protect the handshake against replay.

---

## Flow A — Successful Google sign-in, first-time user

1. Guest → Client: on /login, activates "Sign in with Google", which sends the browser straight to the application and leaves the single-page application.
2. Client → System: requests the Google authorization entry point.
3. System: generates a random single-use state value, stores it with a 10-minute lifetime and records that it belongs to a sign-in attempt rather than an account link.
4. System → Browser: redirects to the Google consent screen with the client identifier, the return address, the requested scopes and the state value.
5. Guest → Google: authenticates and grants consent.
6. Google → System: returns the browser to the callback address with an authorization code and the state value.
7. System:
   a. Consumes the state value: a missing or unknown value → 400 OAUTH_STATE_INVALID; a value recorded for another provider → the same error.
   b. Exchanges the authorization code with Google for a Google access token; a missing token → 400 OAUTH_CODE_INVALID.
   c. Reads the Google profile; a missing email address, or an unverified one, → 400 OAUTH_CODE_INVALID.
   d. Looks up the linked external identity: not found, so it looks the account up by email address. With no matching account it creates one with the email address already verified and no password, assigns the default role, and then links the external identity to it.
   e. Checks the account status: inactive → 403 ACCOUNT_SUSPENDED.
   f. With two-factor authentication disabled, records the sign-in time and event, resolves the active workspace and issues an access token together with a refresh token.
8. System → Database: applies the account, role, identity-link and sign-in writes inside one transaction.
9. System → Browser: sets the refresh token as an HTTP-only cookie and redirects to the return address of the application carrying the access token in the address fragment.
10. Client: reads the access token from the address fragment, loads the profile, records the session and continues to the Dashboard / Agency list, honouring any pending destination.

## Flow B — Existing email/password account signing in with Google for the first time

Same as Flow A steps 1–7c, diverging at 7d:

7d'. The external identity is not linked yet, and the account lookup by email address finds an account created earlier through Sign Up, so that account is reused and the external identity is linked to it. No duplicate account is created.
7e–10. Continue as Flow A: the existing account signs in, and no data is merged because there was only one account from the start.

## Flow C — Account with two-factor authentication enabled

Same as Flow A or Flow B up to step 7d, diverging from 7e:

7e. The account status check passes.
7f'. Two-factor authentication is enabled, so a two-factor challenge token is issued and the sign-in time, the event record and the access token are all left untouched.
9'. System → Browser: redirects to the two-factor code screen (3.2.7) carrying the challenge token as a query parameter, and sets no refresh cookie.
10'. Client: reads the challenge token from the address and continues in Two-Factor Authentication (3.2.7). A correct code returns the real access token and sets the refresh cookie, after which the client resumes Flow A step 10.

## Sub-flow — Error or consent cancelled

- Google reports an error, or the user cancels on the consent screen, so the callback carries no authorization code → the browser is sent back to the sign-in area with a generic error and no further call to Google is made.
- Any other handled failure while processing the callback, other than the account-linking errors, produces the same generic error.
- A network failure while calling Google is logged without the request or response content, since it may carry credentials, and the browser is sent back with a generic error.

---

## Error paths summary (for "alt"/"opt" fragments)

| Step | Failure condition | Behaviour | Error code |
|---|---|---|---|
| Callback | The state value is unknown or belongs to another provider | Redirect back with a generic error | `OAUTH_STATE_INVALID` |
| Callback | Google returns no token | Redirect back with a generic error | `OAUTH_CODE_INVALID` |
| Callback | The email address is missing or unverified | Redirect back with a generic error | `OAUTH_CODE_INVALID` |
| Callback | The account is suspended | Redirect back with a generic error | `ACCOUNT_SUSPENDED` |
| Callback | Google returns no authorization code, meaning the user cancelled | Redirect back with a generic error | — |
| Callback | The call to Google fails at the network level | Redirect back with a generic error | — |

## Notes

- The access token is carried in the address fragment, never as a query parameter, so it is not sent to the server and does not appear in server logs.
- Linking Google to an account that is already signed in is a separate settings flow and is not part of this feature.
