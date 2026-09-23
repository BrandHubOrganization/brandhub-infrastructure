# Sequence Flow — Sign Out

> Companion to `spec.md` (3.2.8). Lists each actor → action → system step in enough detail to draw the sequence diagram directly; the business description lives in `spec.md`.

## Actors

- **User** — already signed in.
- **Client** — the application the user interacts with, which also keeps the last sign-in method.
- **System** — the application server.
- **Database** — persistent store holding the recorded sign-out events.
- **Token store** — short-lived state used to invalidate tokens that have been signed out.

---

## Flow A — Successful sign-out

1. User → Client: activates "Sign Out".
2. Client → System: submits the sign-out carrying the access token, the refresh cookie, the source address and the client description.
3. System: the access token is missing or malformed → 401 INVALID_CREDENTIALS, answered directly by the request handling rather than through the standard error path, because this endpoint does not require a resolved caller identity first.
4. System:
   a. Reads the access token and identifies the account, then invalidates the access token in the token store. An expired or unreadable token is caught and ignored, so the request continues as a success.
   b. When a refresh token is present in the cookie, invalidates it as well; an unreadable token is ignored in the same way.
   c. When a caller identity is available, records the sign-out event with the caller, the event kind, the source address taken from the forwarding header and the client description taken from the client header.
5. System → Client: 200 with no data, and clears the refresh cookie by setting it with an immediate expiry.
6. Client: clears the stored access token and records the sign-in method used last, either email or Google, entirely on the client, with no call to the system for this.
7. Client: returns to /login and reads the recorded method to highlight the matching button.

## Flow B — Sign-out with an expired or unusable access token

1–2. Same as Flow A, but the access token is expired or has been tampered with.
3. System: the header is still well formed, so the request is not rejected here.
4. System: reading the access token fails, the failure is caught and ignored, and no caller identity is available. The access token is left alone because it is already unusable, nothing is recorded because the account is unknown, and the refresh token is still invalidated when present.
5. System → Client: still 200 with no data. The sign-out is always treated as successful and never fails because of an unusable token.
6–7. Same as Flow A.

---

## Error paths summary (for "alt"/"opt" fragments)

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| Sign out | The access token is missing or malformed | 401 | `INVALID_CREDENTIALS` |
| Sign out | The access token is expired or unusable, but the header is well formed | 200 | — (idempotent, no error) |
| Sign out | The refresh token is expired or unusable | 200 | — (idempotent, no error) |

## Notes

- Sign-out never fails on account of an unusable token, so the client can always complete the local part of signing out.
- The last sign-in method is remembered locally, so it is not shared across devices.
- Only the tokens of the device that signed out are invalidated; sessions on other devices stay valid, unlike a password change which invalidates every refresh token.
