# Sequence Flow — Sign Up (Email)

> Companion to `spec.md` (3.2.1). Lists each actor → action → system step in enough detail to draw the sequence diagram directly; the business description lives in `spec.md`.

## Actors

- **Guest** — unauthenticated visitor creating a new account.
- **Client** — the application the user interacts with.
- **System** — the application server.
- **Database** — persistent store holding accounts and their role assignments.
- **Mail** — outbound email used to deliver the verification code.

---

## Flow A — Successful registration

1. Guest → Client: opens /register and fills in the email address, password, confirm password and full name.
2. Client → System: submits the registration with the email address, password and full name.
3. System:
   a. Normalizes the email address to lower case and trims it.
   b. Generates a six-digit one-time code valid for 10 minutes.
   c. Creates the account with the hashed password and the pending code; a duplicate email address violates the uniqueness constraint and is translated into 409 EMAIL_ALREADY_EXISTS.
   d. Assigns the default role USER.
4. System → Mail (synchronous, inside the same transaction): sends the code to the registered email address.
5. System → Client: 201, returning the identifier of the new account.
6. Client: renders the OTP Verification screen (3.2.6) and carries the email address forward.
7. Continues in OTP Verification (3.2.6): a correct code marks the email address as verified. The registration does not sign the user in; the user signs in separately afterwards.

## Flow B — Registration repeated with a different letter case while the earlier address is still unverified

1–2. Same as Flow A.
3. System: normalizes the email address, the duplicate violates the uniqueness constraint and is translated into 409 EMAIL_ALREADY_EXISTS.
   - No branch re-sends a code to the existing account; only the duplicate error is returned. A new code must be requested through the resend action (3.2.6).

---

## Error paths summary (for "alt"/"opt" fragments)

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| Register | The email address already exists, including a different letter case | 409 | `EMAIL_ALREADY_EXISTS` |
| Register | The email address or the password fails validation | 400 | `VALIDATION_ERROR` |
| Verify OTP (3.2.6) | The code is wrong or expired | 400 | `OTP_INVALID` |
| Verify OTP (3.2.6) | Five wrong codes in a row | 400 | `OTP_TOO_MANY_ATTEMPTS` |

## Notes

- The verification email is sent synchronously inside the registration transaction rather than in the background, so a mail failure rolls the registration back.
- The account exists from registration onwards, before the email address is verified.
