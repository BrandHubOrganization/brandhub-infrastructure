# 3.2.1 Sign Up (Email + OTP Verification)

| | |
|---|---|
| FR Code | 3.2.1 |
| Feature | Sign Up |
| Domain | Authentication (FR 3.2) |
| Role | GUEST (unauthenticated) |
| Version | 2.0 — 2026-09-25 — rewritten against real code (register, verify-otp, resend-otp) |
| Document status | Implemented |

## Function Trigger

Begins when an unauthenticated Guest opens the Sign Up screen and submits Full Name, Email and Password; continues through the OTP Verification screen, which submits the 6-digit code and can trigger a Resend.

## Function Description

- **Actors / Roles:** GUEST. Creates a new account with the default system role USER.
- **Purpose:** Register a new account, prove ownership of the email address with a one-time code (OTP), and hand the user to Sign In. No session is created by this FR.
- **Interface:**
  - Registration form: Full Name, Email, Password (with strength meter), Confirm Password (client-side only).
  - OTP Verification screen: 6 single-digit inputs, Verify button, Resend link with cooldown countdown.
- **Data Processing:** `AuthController.register` → `AuthServiceImpl.register` normalizes the email (lowercase + trim), BCrypt-hashes the password, generates a 6-digit numeric OTP (100000–999999) with a 10-minute expiry, persists the User row, assigns `UserSystemRole(SystemRole.USER)`, and sends the OTP email. `verifyOtp` and `resendOtp` are handled by the same controller/service and are part of this FR's completion flow.

## Screen Layout

Figure — Sign Up Screen:
- Full Name input, Email input, Password input (show/hide toggle + real-time strength meter: min 8 chars, at least 1 digit), Confirm Password input (client-side match check only, never sent to the server).
- Submit button ("Create account"); tab toggle to switch to the Sign In screen; Google OAuth button; footer link to Sign In.
- On success, the app toasts MSG10 and navigates to `/verify-otp?email=<email>`.

Figure — OTP Verification Screen:
- Six single-digit numeric inputs (auto-advance on entry, backspace/arrow navigation, paste support), Verify button (disabled until all 6 digits entered).
- "Didn't receive a code? Resend" link, disabled while a resend cooldown is active (countdown in seconds) or while a resend request is in flight.
- Back-to-Sign-In link.

## Function Details

### Data Specifications

- **Input required (register):** email, password, fullName — `RegisterRequest{email, password, fullName}`.
- **Input required (verify-otp):** email, otpCode — `VerifyOtpRequest{email, otpCode}`.
- **Input required (resend-otp):** email — reuses `ForgotPasswordRequest{email}` (only its `email` field is used).
- **Input optional:** confirmPassword is verified client-side only and is never submitted to the API.
- **System data:** userId, systemRole (USER), passwordHash (BCrypt), otpCode, otpExpiry, emailVerifiedAt, Redis keys `otp:attempt:<email>` (failed-attempt counter, TTL 10 min) and `otp:resend:<email>` (resend cooldown, TTL 60s).
- **Output (register):** `RegisterResponse{userId}` — no email/otpSessionId is returned.
- **Output (verify-otp / resend-otp):** `ApiResponse<Void>` — no payload body.

### Business Rules

- **BR-01:** Email is unique and compared case-insensitively; the service always lowercases + trims before storing and before the uniqueness check (`User@x.com` and `user@x.com` collide). A duplicate → `DataIntegrityViolationException` → 409 `EMAIL_ALREADY_EXISTS`.
- **BR-02:** Password policy — minimum 8 characters, at least 1 digit (enforced by request validation, `VALIDATION_ERROR` on failure); hashed with BCrypt cost 12; the plaintext password is never logged, stored, or returned.
- **BR-03:** Email OTP is 6 digits (numeric, 100000–999999), TTL 10 minutes, single-use — cleared (`otpCode`/`otpExpiry` set to null) as soon as it is consumed successfully or after 5 failed attempts.
- **BR-04:** Resend OTP has a 60-second cooldown per email, enforced via the Redis key `otp:resend:<email>` (`SETEX ... 60`). A resend request while the key still exists → 429 `RATE_LIMIT_EXCEEDED`.

### Validation

- email, fullName, or password empty → Display: MSG02.
- email invalid format → Display: MSG04.
- password fewer than 8 characters or missing a digit → Display: MSG05.
- confirmPassword mismatch (client-side only) → Display: MSG06.
- duplicate email on register → Display: MSG08 (toast), HTTP 409 `EMAIL_ALREADY_EXISTS`.
- OTP wrong or expired → Display: MSG20 (inline on the OTP screen), HTTP 400 `OTP_INVALID`.

## Functionalities

### Normal Flow — Register

1. Guest opens the Sign Up screen and fills in Full Name, Email, Password, Confirm Password.
2. Client validates fields locally (required, email format, password policy, confirm match) and submits `{email, password, fullName}` to `POST /api/v1/auth/register`.
3. `AuthServiceImpl.register`: lowercases+trims the email, BCrypt-hashes the password, trims fullName, generates a 6-digit OTP with a 10-minute expiry, saves the User, saves `UserSystemRole(USER)`, sends the OTP email.
4. On success: 201 CREATED, body `RegisterResponse{userId}`. Toast MSG10 ("Account created. A verification code has been sent to {email_address}."). Client navigates to `/verify-otp?email=<email>`.

### Normal Flow — Verify OTP

1. Guest enters the 6-digit code on the OTP Verification screen and submits `{email, otpCode}` to `POST /api/v1/auth/verify-otp`.
2. `AuthServiceImpl.verifyOtp`: looks up the user by (normalized) email; if the code matches and has not expired, clears the Redis attempt counter, clears `otpCode`/`otpExpiry`, and sets `emailVerifiedAt = now`.
3. On success: 200, `ApiResponse<Void>`. Client toasts success and navigates to `/login`. No session/token is issued — the user signs in separately.

### Normal Flow — Resend OTP

1. Guest clicks Resend on the OTP Verification screen; client submits `{email}` to `POST /api/v1/auth/resend-otp`.
2. `AuthServiceImpl.resendOtp`: checks the Redis cooldown key; if absent, looks up the user, generates a new OTP + 10-minute expiry, saves it, sets the 60-second cooldown key, clears the attempt counter, and sends the new OTP email.
3. On success: 200, `ApiResponse<Void>`. Toast MSG21. Client starts a 60-second cooldown on the Resend link.

### Abnormal Cases

- 2.a1: Email already registered (case-insensitive, BR-01) → 409 `EMAIL_ALREADY_EXISTS`, toast MSG08. 2.a2: The existing account is not modified; no OTP is re-sent automatically; the Guest switches to Sign In or requests Resend after verifying identity separately.
- 2.b1: email/fullName/password fails validation (BR-02) → 400 `VALIDATION_ERROR`, Display MSG02/MSG04/MSG05 under the offending field. 2.b2: Guest corrects the field and resubmits.
- V.a1: `verifyOtp` called with an email that has no account → 404 `USER_NOT_FOUND`.
- V.b1: User's email is already verified → idempotent 200 no-op (no error, no OTP re-check) — repeated verification calls are safe.
- V.c1: `otpExpiry`/`otpCode` is null, or the code has expired → 400 `OTP_INVALID`, Display MSG20.
- V.d1: Submitted code does not match → increments the Redis attempt counter (`otp:attempt:<email>`, TTL 10 min); if attempts < 5 → 400 `OTP_INVALID`, Display MSG20. V.d2: On the 5th failed attempt → the OTP fields are cleared and the attempt key deleted → 400 `OTP_TOO_MANY_ATTEMPTS`; the Guest must use Resend to get a new code.
- R.a1: Resend requested within 60 seconds of the previous resend → 429 `RATE_LIMIT_EXCEEDED`, toast MSG88.
- R.b1: Resend requested for an email with no account → 404 `USER_NOT_FOUND`.
- R.c1: Resend requested for an already-verified email → idempotent 200 no-op; no new OTP is generated or sent.

## Post-Conditions

- After register: a User row exists with the default role USER, `emailVerifiedAt` null, a pending OTP (6 digits, 10-minute TTL) stored, and the OTP email sent. No session is established.
- After a successful verify-otp: `emailVerifiedAt` is set, `otpCode`/`otpExpiry` are cleared, and the Redis attempt counter for that email is deleted. The user is not signed in; sign-in is a separate step.
- After a successful resend-otp: a new OTP + 10-minute expiry replaces the previous one, the 60-second Redis cooldown key is set, and the previous attempt counter is cleared.

## Out of Scope

- Sign In (separate FR) — verification does not issue any token.
- OAuth-based sign-up (Google button shown on the screen but out of scope for this FR).

## References

Ground truth: `AuthController.java`, `AuthServiceImpl.java` (`register`, `verifyOtp`, `resendOtp`, `generateOtp`), `ErrorCode.java`. BA: Section5_Requirement_Appendix.md (BR-01..BR-04, MSG02/04/05/06/08/10/20/21/88) — read-only, not modified.
