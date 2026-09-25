# Sequence Flow — Sign Up (Email + OTP Verification)

> Companion to `spec.md` (3.2.1). Lists each actor → action → system step in enough detail to draw the sequence diagram directly; the business description lives in `spec.md`.

## Actors

- **User/Browser** — unauthenticated Guest and the SPA (RegisterPage / VerifyOtpPage).
- **AuthController** — `POST /api/v1/auth/register`, `/verify-otp`, `/resend-otp`.
- **AuthServiceImpl** — `register()`, `verifyOtp()`, `resendOtp()`, `generateOtp()`.
- **UserRepository** — persistence for the `User` entity (email unique constraint).
- **MailService** — `sendOtpEmail(email, otp)`.
- **Redis** — attempt counter (`otp:attempt:<email>`, TTL 10 min) and resend cooldown (`otp:resend:<email>`, TTL 60s).

---

## Flow A — Register

1. User/Browser → AuthController: `POST /register` `{email, password, fullName}`.
2. AuthController → AuthServiceImpl: `register(request)`.
3. AuthServiceImpl: generates OTP (`generateOtp()`, 6-digit numeric 100000–999999) and `otpExpiry = now + 10min`.
4. AuthServiceImpl → UserRepository: `saveAndFlush(User{email=lower+trim, passwordHash=BCrypt(password), fullName=trim, otpCode, otpExpiry})`.
   - alt: duplicate email → `DataIntegrityViolationException` → AuthServiceImpl throws `BusinessException(EMAIL_ALREADY_EXISTS)` → AuthController → User/Browser: 409.
5. AuthServiceImpl → UserSystemRoleRepository: `save(UserSystemRole{userId, systemRole=USER})`.
6. AuthServiceImpl → MailService: `sendOtpEmail(email, otp)` (synchronous, same transaction).
7. AuthServiceImpl → AuthController: `RegisterResponse{userId}`.
8. AuthController → User/Browser: 201 CREATED, `RegisterResponse{userId}`.
9. User/Browser: toasts MSG10, navigates to OTP Verification screen with `email` in the query string.

## Flow B — Verify OTP

1. User/Browser → AuthController: `POST /verify-otp` `{email, otpCode}`.
2. AuthController → AuthServiceImpl: `verifyOtp(email, otpCode)`.
3. AuthServiceImpl → UserRepository: `findByEmail(normalizedEmail)`.
   - alt: not found → throws `BusinessException(USER_NOT_FOUND)` → 404.
4. alt: `user.emailVerifiedAt != null` → return immediately (idempotent, 200 no-op).
5. alt: `otpExpiry == null` or `otpCode == null` or `now.isAfter(otpExpiry)` → throws `BusinessException(OTP_INVALID)` → 400.
6. alt: `otpCode` mismatch:
   a. AuthServiceImpl → Redis: `INCR otp:attempt:<email>` (sets TTL 10 min on first increment).
   b. If attempts >= 5: clears `user.otpCode`/`otpExpiry`, saves, `DEL otp:attempt:<email>`, throws `BusinessException(OTP_TOO_MANY_ATTEMPTS)` → 400.
   c. Else: throws `BusinessException(OTP_INVALID)` → 400.
7. Else (match): AuthServiceImpl → Redis: `DEL otp:attempt:<email>`; clears `otpCode`/`otpExpiry`; sets `emailVerifiedAt = now`; UserRepository.save(user).
8. AuthController → User/Browser: 200, `ApiResponse<Void>`.
9. User/Browser: toasts success, navigates to `/login`. No token is issued by this flow.

## Flow C — Resend OTP

1. User/Browser → AuthController: `POST /resend-otp` `{email}`.
2. AuthController → AuthServiceImpl: `resendOtp(email)`.
3. AuthServiceImpl → Redis: `GET otp:resend:<email>`.
   - alt: key present → throws `BusinessException(RATE_LIMIT_EXCEEDED)` → 429.
4. AuthServiceImpl → UserRepository: `findByEmail(normalizedEmail)`.
   - alt: not found → throws `BusinessException(USER_NOT_FOUND)` → 404.
5. alt: `user.emailVerifiedAt != null` → return immediately (idempotent, 200 no-op, no email sent).
6. AuthServiceImpl: generates a new OTP + `otpExpiry = now + 10min`; UserRepository.save(user).
7. AuthServiceImpl → Redis: `SETEX otp:resend:<email> 60 "1"`; `DEL otp:attempt:<email>`.
8. AuthServiceImpl → MailService: `sendOtpEmail(email, newOtp)`.
9. AuthController → User/Browser: 200, `ApiResponse<Void>`.
10. User/Browser: toasts MSG21, starts a 60-second cooldown on the Resend link.

---

## Error paths summary (for "alt"/"opt" fragments)

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| Register | Duplicate email (case-insensitive) | 409 | `EMAIL_ALREADY_EXISTS` |
| Register | email/password/fullName fails validation | 400 | `VALIDATION_ERROR` |
| Verify OTP | Email has no account | 404 | `USER_NOT_FOUND` |
| Verify OTP | Code null/expired or now after expiry | 400 | `OTP_INVALID` |
| Verify OTP | Code mismatch (attempts < 5) | 400 | `OTP_INVALID` |
| Verify OTP | Code mismatch on 5th attempt | 400 | `OTP_TOO_MANY_ATTEMPTS` |
| Resend OTP | Called within 60s of previous resend | 429 | `RATE_LIMIT_EXCEEDED` |
| Resend OTP | Email has no account | 404 | `USER_NOT_FOUND` |

## Notes

- The verification email is sent synchronously inside the `register`/`resendOtp` transaction, so a mail failure rolls back the OTP generation.
- `verifyOtp` and `resendOtp` are both idempotent no-ops (200, no side effect) once `emailVerifiedAt` is set.
- No JWT/session is issued anywhere in this FR; sign-in happens afterwards via the separate Login FR.
