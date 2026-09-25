# Sequence Flow — OTP Verification (Phone Linking)

> Companion to `spec.md` (3.2.6). Primary subject: phone-linking OTP (`link/phone` + `verify-phone-otp`), the umbrella FR's main concrete flow. Email-OTP at sign-up (`verify-otp`/`resend-otp`, FR 3.2.1) is the sibling flow using the same numeric-OTP shape and is not detailed here. Deactivate-account OTP (`deactivate/send-otp`, FR 3.2.9) reuses the same pattern, noted only in passing.

## Actors / Lifelines

- **User** — signed in, linking a phone number from their Profile page.
- **AuthController** — `POST /api/v1/auth/link/phone`, `POST /api/v1/auth/verify-phone-otp`; resolves `userId` from the Bearer token via `requireUserId` before calling the service.
- **AuthServiceImpl** — `linkPhone(userId, phone)`, `verifyPhoneOtp(userId, otpCode)`.
- **UserRepository** — loads/saves the `User` entity, including the uniqueness check on `phone`.
- **Redis** — holds `phone:otp:{userId}` (code+phone, TTL 10 min), `phone:otp:resend:{userId}` (cooldown, TTL 60s), `phone:otp:attempt:{userId}` (wrong-attempt counter, TTL 10 min).
- **MailService** — `sendOtpEmail`, delivers the code to the user's account email (not SMS — see BA conflict in `spec.md`).

---

## Flow A — Link phone, code issued

1. User → AuthController: `POST /link/phone { phone }` with `Authorization: Bearer <token>`.
2. AuthController: `requireUserId(authHeader)` resolves `userId`; missing/invalid token → 401 `INVALID_CREDENTIALS`, short-circuits before the service is called.
3. AuthController → AuthServiceImpl: `linkPhone(userId, phone)`.
4. AuthServiceImpl:
   a. `PhoneUtil.normalize(phone)` → null → 400 `INVALID_PHONE`.
   b. AuthServiceImpl → UserRepository: load user by `userId`; missing → 404 `USER_NOT_FOUND`.
   c. AuthServiceImpl → UserRepository: check phone not already used by another user → in use → 409 `PHONE_ALREADY_IN_USE`.
   d. AuthServiceImpl → Redis: check `phone:otp:resend:{userId}` → present → 429 `RATE_LIMIT_EXCEEDED` (pending code, if any, is untouched).
   e. AuthServiceImpl: generates a 6-digit code.
   f. AuthServiceImpl → Redis: `SET phone:otp:{userId} = "{otp}:{phone}"` TTL 10 min.
   g. AuthServiceImpl → Redis: `SET phone:otp:resend:{userId}` TTL 60s; `DEL phone:otp:attempt:{userId}`.
   h. AuthServiceImpl → MailService: `sendOtpEmail(user.email, otp)`.
5. AuthServiceImpl → AuthController → User: 200, `ApiResponse<Void>` (no data).
6. Client (LinkPhoneModal): toast `profile.linkPhone.otpSent`; advances to the OTP-entry step.

## Flow B — Verify phone code, success

1. User → AuthController: `POST /verify-phone-otp { otpCode }` with the Bearer token.
2. AuthController: `requireUserId` resolves `userId` (same 401 guard as Flow A step 2).
3. AuthController → AuthServiceImpl: `verifyPhoneOtp(userId, otpCode)`.
4. AuthServiceImpl → Redis: `GET phone:otp:{userId}` → value `"{otp}:{phone}"`.
   a. Key absent (expired or never requested) → 400 `OTP_INVALID`.
   b. Parses `otp:phone`; if `otpCode` matches:
      - AuthServiceImpl → Redis: `DEL phone:otp:{userId}`, `DEL phone:otp:attempt:{userId}`.
      - AuthServiceImpl → UserRepository: re-check phone uniqueness (race guard) → now taken by someone else → 409 `PHONE_ALREADY_IN_USE`.
      - AuthServiceImpl → UserRepository: reload user by `userId` → missing → 404 `USER_NOT_FOUND`.
      - AuthServiceImpl → UserRepository: `user.setPhone(phone)`, save.
5. AuthServiceImpl → AuthController → User: 200, `ApiResponse<Void>` (no data).
6. Client: toast `profile.linkPhone.verifySuccess`; modal closes, `onLinked(phone)` fires.

## Flow C — Verify phone code, wrong code / too many attempts

1–3. Same as Flow B steps 1–3, with a wrong `otpCode`.
4. AuthServiceImpl → Redis: `GET phone:otp:{userId}` succeeds but the parsed `otp` does not match:
   a. AuthServiceImpl → Redis: `INCR phone:otp:attempt:{userId}` (TTL 10 min on first increment).
   b. Attempt count `< 5` → 400 `OTP_INVALID`.
   c. Attempt count `>= 5` → AuthServiceImpl → Redis: `DEL phone:otp:{userId}`, `DEL phone:otp:attempt:{userId}` → 400 `OTP_TOO_MANY_ATTEMPTS`.
5. AuthController → User: 400 with the corresponding error code.
6. Client: toast `profile.linkPhone.verifyError`; on `OTP_TOO_MANY_ATTEMPTS` the user must restart from Flow A.

## Flow D — Link phone repeated inside cooldown

1–3. Same as Flow A steps 1–3.
4. AuthServiceImpl → Redis: `phone:otp:resend:{userId}` still present → 429 `RATE_LIMIT_EXCEEDED`; no new code is generated, the existing `phone:otp:{userId}` value is left untouched.
5. AuthController → User: 429.
6. Client: toast `profile.linkPhone.sendError`; user must wait out the 60s cooldown.

---

## Error paths summary

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| Auth guard (either endpoint) | Missing/invalid Bearer token | 401 | `INVALID_CREDENTIALS` |
| Link phone | Phone fails `PhoneUtil.normalize` | 400 | `INVALID_PHONE` |
| Link phone | Caller's user record not found | 404 | `USER_NOT_FOUND` |
| Link phone | Phone already used by another user | 409 | `PHONE_ALREADY_IN_USE` |
| Link phone | Repeated within 60s cooldown | 429 | `RATE_LIMIT_EXCEEDED` |
| Verify phone code | No pending code (expired/never requested) | 400 | `OTP_INVALID` |
| Verify phone code | Wrong code, attempts < 5 | 400 | `OTP_INVALID` |
| Verify phone code | Wrong code, 5th attempt | 400 | `OTP_TOO_MANY_ATTEMPTS` |
| Verify phone code | Phone taken by another user in the meantime (race) | 409 | `PHONE_ALREADY_IN_USE` |
| Verify phone code | User record gone between link and verify | 404 | `USER_NOT_FOUND` |

## Notes

- The code is delivered by `MailService.sendOtpEmail` to the account's email address, not by SMS to the phone being verified — flagged as a BA conflict in `spec.md`.
- `AuthServiceImpl` checks phone uniqueness twice: once at `linkPhone` and again at `verifyPhoneOtp`, closing the window where two users could race to claim the same number.
- Both the resend cooldown and the wrong-attempt counter are scoped per `userId` in Redis, not per phone number — a user cannot bypass the cooldown by trying a different number.
- Email OTP (sign-up, FR 3.2.1) and deactivate OTP (FR 3.2.9) share the same 6-digit/10-minute/60-second-cooldown/5-attempt shape but use different Redis key prefixes and, for email OTP, DB columns (`users.otp_code`/`otp_expiry`) instead of a pure-Redis value — see those FRs for their own sequence flows.
