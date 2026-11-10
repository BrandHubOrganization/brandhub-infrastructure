# 3.2.6 OTP Verification

| | |
|---|---|
| FR Code | 3.2.6 |
| Feature | OTP Verification (phone-linking primitive) |
| Domain | Authentication (FR 3.2) |
| Role | Any signed-in user linking a phone number to their account |
| Version | 2.0 — 2026-09-25 — refocused on phone-linking OTP as the primary subject |
| Document status | Implemented |

## Function Trigger

Begins when a signed-in user opens "Link phone" on their profile, enters a phone number, and then enters the six-digit code they receive.

**Scope note:** OTP Verification is a general one-time-code mechanism reused by two concrete flows in the codebase: (1) email verification at sign-up (`POST /verify-otp` + `POST /resend-otp`, owned by FR 3.2.1 — the sibling flow, mentioned here only for contrast) and (2) **phone linking**, `POST /api/v1/auth/link/phone` + `POST /api/v1/auth/verify-phone-otp`, which is the primary subject of this FR because it is the other concrete OTP-code-driven endpoint pair in the codebase. FR 3.2.9 (Deactivate Account) also reuses this same numeric-OTP pattern via `POST /deactivate/send-otp`, noted briefly below as a third reuse site, not detailed here.

## Function Description

- **Actors / Roles:** A signed-in user (Bearer token required) linking a phone number to their account.
- **Purpose:** Confirm ownership of a phone number with a short-lived one-time code before attaching it to the account.
- **Interface:** A "Link phone" modal on the Profile page (`LinkPhoneModal.tsx`) — not a standalone screen — with two steps: a phone number input, then a six-digit code input.
- **Data Processing:** `AuthController.linkPhone` / `AuthController.verifyPhoneOtp` delegate to `AuthServiceImpl`. The service normalizes the phone number, generates a 6-digit numeric code, stores `code:phone` together in Redis with a 10-minute TTL, enforces a 60-second resend cooldown and a 5-attempt wrong-code limit, and on success sets `user.phone`.
- **⚠ BA conflict — delivery channel:** `AuthServiceImpl.linkPhone` sends the code via `mailService.sendOtpEmail` (the user's account **email**), not via SMS. Phone-ownership verification delivered by email rather than by a text message to the phone itself is an unusual pairing and likely a BA/code mismatch — flagged for BA review, not silently normalized away here.

## Screen Layout

Figure — Link Phone modal (Profile page, `LinkPhoneModal.tsx`):
- Rendered as a centered modal overlay on the Profile page (`fixed inset-0` dialog), not a dedicated route.
- Step `"phone"`: a phone number `Input` plus Cancel / "Send OTP" buttons; "Send OTP" is disabled while empty or sending.
- Step `"otp"`: a hint line plus a six-digit code `Input`, plus Cancel / "Verify" buttons; "Verify" is disabled while empty or verifying.
- On send success: toast `profile.linkPhone.otpSent`, advances to the `"otp"` step.
- On verify success: toast `profile.linkPhone.verifySuccess`, calls `onLinked(phone)`, closes and resets the modal.
- On any error: toast built from `extractErrorMessage`, falling back to `profile.linkPhone.sendError` / `profile.linkPhone.verifyError`.

## Function Details

### Data Specifications

- **Input required:** `phone` (link step, body `LinkPhoneRequest`); `otpCode` (verify step, body `VerifyPhoneOtpRequest`). Both endpoints additionally require a valid `Authorization: Bearer <accessToken>` header.
- **Input optional:** none.
- **System data:** `userId` (resolved from the access token), Redis key `phone:otp:{userId}` → value `"{otp}:{phone}"` (TTL 10 min), `phone:otp:resend:{userId}` (cooldown marker, TTL 60s), `phone:otp:attempt:{userId}` (wrong-attempt counter, TTL 10 min), `user.phone`.
- **Output:** `ApiResponse<Void>` — 200 with no data on both endpoints.

### Business Rules

- **BR-03** *(reused from the email-OTP primitive, FR 3.2.1):* numeric OTP is 6 digits, TTL 10 minutes, single-use, cleared on success — the same shape `AuthServiceImpl.linkPhone`/`verifyPhoneOtp` apply to the phone code, even though delivery here is by email rather than SMS.
- **BR-04** *(reused):* OTP resend/reissue has a 60-second cooldown, here scoped per `userId` (`phone:otp:resend:{userId}`) rather than per email address.
- **BR-07** *(phone-linking specific, built on BR-03/BR-04):*
  - `phone` fails `PhoneUtil.normalize` (not a valid E.164 number) → 400 `INVALID_PHONE`.
  - Caller's user record not found → 404 `USER_NOT_FOUND`.
  - `phone` already in use by a **different** user → 409 `PHONE_ALREADY_IN_USE`.
  - A repeat `link/phone` call while `phone:otp:resend:{userId}` is still set → 429 `RATE_LIMIT_EXCEEDED`; the pending code is **not** replaced.
  - On an accepted `link/phone` call: generates a new 6-digit code, writes `phone:otp:{userId}` = `"{otp}:{phone}"` (TTL 10 min), sets the 60s resend cooldown, clears `phone:otp:attempt:{userId}`, and sends the code by email.
  - `verify-phone-otp` with no `phone:otp:{userId}` key (never requested or expired) → 400 `OTP_INVALID`.
  - Wrong code → increments `phone:otp:attempt:{userId}` (TTL 10 min); on the 5th wrong attempt both `phone:otp:{userId}` and the attempt key are deleted and the answer is 400 `OTP_TOO_MANY_ATTEMPTS`; below 5 attempts, 400 `OTP_INVALID`.
  - Correct code: deletes both Redis keys, **re-checks** phone uniqueness (race-condition guard against a concurrent link by another user) → 409 `PHONE_ALREADY_IN_USE` if now taken; reloads the user (404 `USER_NOT_FOUND` if gone) and sets `user.phone`.
- Auth guard on both endpoints: missing/invalid Bearer token → 401 `INVALID_CREDENTIALS` (thrown by `requireUserId` in `AuthController`, before the service is even called).

### Validation

- `phone` empty or fails `PhoneUtil.normalize` → Display: MSG02.
- `otpCode` empty → Display: MSG02.
- `otpCode` invalid or expired → Display: MSG20.

## Functionalities

### Normal Flow

1. Signed-in user opens the "Link phone" modal from the Profile page and enters a phone number.
2. Client calls `POST /api/v1/auth/link/phone { phone }` with the Bearer token.
3. System normalizes the phone number, checks it is not already in use by another user, generates a 6-digit code, stores it with the phone number in Redis (TTL 10 min), starts the 60s resend cooldown, and emails the code. Toast `profile.linkPhone.otpSent`.
4. User enters the code in the modal's second step.
5. Client calls `POST /api/v1/auth/verify-phone-otp { otpCode }` with the Bearer token.
6. System matches the code, clears the pending code and attempt counter, re-checks phone uniqueness, and sets `user.phone`. Toast `profile.linkPhone.verifySuccess`; modal closes.

### Abnormal Cases

- 2.a1: `phone` fails normalization → 400 `INVALID_PHONE`, Display: MSG02. 2.a2: User corrects the phone number and resubmits.
- 2.b1: Phone already used by another user → 409 `PHONE_ALREADY_IN_USE`, toast `profile.linkPhone.sendError`. 2.b2: User enters a different phone number.
- 2.c1: `link/phone` called again inside the 60s cooldown → 429 `RATE_LIMIT_EXCEEDED`, toast `profile.linkPhone.sendError` (no dedicated MSG88 wiring observed on this endpoint's FE handler — see BA conflict below). 2.c2: User waits for the cooldown to elapse.
- 5.a1: No pending code (never requested or expired) → 400 `OTP_INVALID`, Display: MSG20. 5.a2: User goes back to step 1 and requests a new code.
- 5.b1: Wrong code, below 5 attempts → 400 `OTP_INVALID`, Display: MSG20. 5.b2: User re-enters the code.
- 5.c1: 5th wrong attempt → 400 `OTP_TOO_MANY_ATTEMPTS`, Display: MSG20; the pending code is discarded. 5.c2: User must restart from step 1 (`link/phone`) to get a new code.
- 5.d1: Correct code, but the phone was taken by another user in the meantime (race) → 409 `PHONE_ALREADY_IN_USE`, toast `profile.linkPhone.verifyError`. 5.d2: User enters a different phone number and restarts.
- 5.e1: User record disappears between link and verify → 404 `USER_NOT_FOUND`, toast `profile.linkPhone.verifyError`.
- Missing/expired Bearer token on either call → 401 `INVALID_CREDENTIALS`; user is redirected to sign in.

## Post-Conditions

- On success: `user.phone` is set to the normalized number; `phone:otp:{userId}` and `phone:otp:attempt:{userId}` are cleared.
- On failure: no change to `user.phone`; Redis state reflects the specific failure path (cooldown key persists on 429; both keys are deleted on the 5th wrong attempt).

## BA Conflicts Flagged

1. **Delivery channel mismatch:** phone-ownership verification is delivered by email (`mailService.sendOtpEmail`), not SMS. A phone number is never actually contacted during this flow — flag for BA to confirm this is intentional (e.g. cost/vendor reasons) rather than an oversight.
2. **No dedicated success message:** the appendix (Section5_Requirement_Appendix.md) has no MSG code for "phone linked successfully." MSG26 ("Profile updated successfully") is generic and not phone-specific; MSG21's copy is hardcoded to "...has been sent to {email_address}," which reads oddly if reused for a phone-linking resend confirmation. The FE modal instead uses local i18n keys (`profile.linkPhone.otpSent`, `profile.linkPhone.verifySuccess`) that are not backed by any MSGxx code in the appendix — recommend BA either register a new MSG or accept these as out-of-appendix UI copy.
3. **MSG88 (resend cooldown) wiring unconfirmed on this endpoint:** the appendix defines MSG88 for "resend OTP in cooldown," matching BR-04 semantics, but `LinkPhoneModal.tsx`'s error path uses a generic `extractErrorMessage` fallback (`profile.linkPhone.sendError`) rather than a specific MSG88 toast — worth confirming with FE whether the 429 response is mapped to MSG88 text anywhere upstream.

## Out of Scope

- Email OTP verification at sign-up (`verify-otp` / `resend-otp`) — owned by FR 3.2.1, mentioned above only as the sibling flow this mechanism is shared with.
- Deactivate-account OTP (`deactivate/send-otp`) — owned by FR 3.2.9; it reuses the same 6-digit/10-minute/60s-cooldown pattern but is not detailed here.
- Two-Factor Authentication (TOTP) — FR 3.2.7, a different mechanism entirely (no email/SMS code).
- Unlinking a phone number (`unlink/phone`) — no OTP involved, out of scope.

## References

[Section5_Requirement_Appendix.md](../../../../../FormReportDA/report_drafts/Section5_Requirement_Appendix.md)
