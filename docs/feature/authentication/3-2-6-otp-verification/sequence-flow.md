# Sequence Flow — OTP Verification

> Companion to `spec.md` (3.2.6). Lists each actor → action → system step in enough detail to draw the sequence diagram directly; the business description lives in `spec.md`. This feature covers two independent flows: email verification of an address at sign-up (3.2.1) and phone verification when a signed-in user links a phone number. Both deliver the code by email, so a phone code is not sent by SMS. Two-Factor Authentication has its own screen (3.2.7), Reset Password does not use a code (3.2.4), and the code used on the deactivation screen belongs to 3.2.9.

## Actors

- **User** — signing up and verifying an email address, or signed in and linking a phone number.
- **Client** — the application the user interacts with.
- **System** — the application server.
- **Database** — persistent store holding accounts, their verification state and their phone number.
- **Token store** — short-lived state holding the codes, their expiry, the wrong-attempt counters and the resend cooldowns.
- **Mail** — outbound email used to deliver every code.

---

## Flow A — Email code verified

1. User → Client: after signing up (3.2.1), enters the six-digit code received by email.
2. Client → System: submits the email address and the code.
3. System:
   a. Normalizes the email address and loads the account; missing → 404 USER_NOT_FOUND.
   b. The email address is already verified → returns immediately as a success, without checking the code again.
   c. The stored code is absent or expired → 400 OTP_INVALID.
   d. The code does not match → the wrong-attempt counter for the address is increased, with a 10-minute window started on the first increase. On the fifth wrong attempt the stored code is discarded, the counter is cleared and the answer is 400 OTP_TOO_MANY_ATTEMPTS; below five attempts the answer is 400 OTP_INVALID.
   e. The code matches → the counter is cleared, the stored code is discarded and the email address is marked as verified.
4. System → Client: 200 with no data.
5. Client: continues the sign-up journey and returns to /login so the user signs in.

## Flow B — Email code resent

1. User → Client: activates "Resend code", which stays disabled until the cooldown has elapsed.
2. Client → System: submits the resend request with the email address.
3. System:
   a. The resend cooldown for the address is still running → 429 RATE_LIMIT_EXCEEDED.
   b. The account is missing → 404 USER_NOT_FOUND.
   c. The email address is already verified → returns immediately without sending anything.
   d. Issues a new six-digit code valid for 10 minutes and updates the account.
   e. Starts a 60-second cooldown for the address and clears the previous wrong-attempt counter.
   f. Sends the new code by email.
4. System → Client: 200 with no data. No next-allowed time is returned; the countdown is kept by the client.

## Flow C — Email code wrong five times

1–2. Same as Flow A steps 1–2, repeated with a wrong code.
3. On the fifth attempt the system discards the stored code and returns 400 OTP_TOO_MANY_ATTEMPTS.
4. Client: shows the error and requires the user to request a new code through Flow B.

## Flow D — Phone linking, code issued

1. User → Client: signed in, opens the phone linking screen and enters the phone number.
2. Client → System: submits the phone number carrying the access token.
3. System:
   a. Normalizes the phone number; invalid → 400 INVALID_PHONE.
   b. Loads the account from the access token; missing → 404 USER_NOT_FOUND.
   c. The phone number is already used by another account → 409 PHONE_ALREADY_IN_USE.
   d. The resend cooldown for the account is still running → 429 RATE_LIMIT_EXCEEDED.
   e. Issues a six-digit code valid for 10 minutes and stores it together with the phone number.
   f. Starts a 60-second cooldown and clears the previous wrong-attempt counter.
   g. Sends the code by email to the account address, not by SMS.
4. System → Client: 200 with no data.
5. Client: moves to the code entry screen for the phone number.

## Flow E — Phone code verified

1. User → Client: enters the six-digit code received by email.
2. Client → System: submits the code carrying the access token.
3. System:
   a. No pending code for the account, because it expired or was never requested → 400 OTP_INVALID.
   b. The code does not match, or the stored value is malformed → the wrong-attempt counter for the account is increased, with a 10-minute window started on the first increase. On the fifth wrong attempt the pending code is discarded, the counter is cleared and the answer is 400 OTP_TOO_MANY_ATTEMPTS; below five attempts the answer is 400 OTP_INVALID.
   c. The code matches → the pending code and the counter are cleared.
   d. Re-checks whether the phone number has been taken by another account while the code was pending → 409 PHONE_ALREADY_IN_USE.
   e. Loads the account; missing → 404 USER_NOT_FOUND.
   f. Attaches the phone number to the account.
4. System → Client: 200 with no data.
5. Client: shows that the phone number has been linked.

---

## Error paths summary (for "alt"/"opt" fragments)

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| Verify email code | The account does not exist | 404 | `USER_NOT_FOUND` |
| Verify email code | The code expired or was never issued | 400 | `OTP_INVALID` |
| Verify email code | Wrong code, below five attempts | 400 | `OTP_INVALID` |
| Verify email code | Fifth wrong code | 400 | `OTP_TOO_MANY_ATTEMPTS` |
| Resend email code | The 60-second cooldown has not elapsed | 429 | `RATE_LIMIT_EXCEEDED` |
| Resend email code | The account does not exist | 404 | `USER_NOT_FOUND` |
| Link phone | The phone number is invalid | 400 | `INVALID_PHONE` |
| Link phone | The phone number is already used by another account | 409 | `PHONE_ALREADY_IN_USE` |
| Link phone | Repeated within the 60-second cooldown | 429 | `RATE_LIMIT_EXCEEDED` |
| Verify phone code | No pending code, because it expired or was discarded | 400 | `OTP_INVALID` |
| Verify phone code | Wrong code, below five attempts | 400 | `OTP_INVALID` |
| Verify phone code | Fifth wrong code | 400 | `OTP_TOO_MANY_ATTEMPTS` |
| Verify phone code | The phone number was taken by another account in the meantime | 409 | `PHONE_ALREADY_IN_USE` |

## Notes

- Every code, for both the email and the phone flow, is delivered by email; the phone flow is named for the value being verified, not for the delivery channel.
- The phone flow re-checks the phone number when the code is verified, because the number can be taken by another account while the code is pending.
- Both flows discard the pending code after five wrong attempts, so a new code has to be requested.
