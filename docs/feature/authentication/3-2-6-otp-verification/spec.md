# 3.2.6 OTP Verification

## Function Trigger
Begins when a user who has just signed up opens the verification screen and enters the six-digit code received by email, or when a signed-in user links a phone number and enters the code received by email.

## Function Description
- **Actors / Roles:** USER verifying an email address after sign-up, or a signed-in user verifying a phone number.
- **Purpose:** Confirm ownership of an email address or of a phone number with a short-lived one-time code, and limit how often a code may be requested or retried.
- **Interface:** Email verification screen with a six-digit code input and a resend action guarded by a countdown; phone linking screen with a phone number input followed by a code input.
- **Data Processing:** The system generates a six-digit code, stores it with a limited lifetime, counts wrong attempts, replaces the code on an accepted resend, and delivers every code by email. Both flows share this mechanism, and a phone code is delivered by email rather than by SMS.

## Screen Layout
Figure — OTP Verification screens:
- Email verification: six-digit code input and a "Resend code" action that stays disabled until the cooldown has elapsed.
- Phone linking: phone number input, then a six-digit code input.
- Both screens report the remaining attempts and discard the current code once too many wrong codes have been entered.

## Function Details
### Data Specifications
- **Input required:** email and code for email verification; phone for linking; code for phone verification.
- **Input optional:** none.
- **System data:** userId, code, code expiry, wrong-attempt counter, resend cooldown, emailVerifiedAt, phone.
- **Output:** no data; a success response on both flows.

### Business Rules
- **BR-03:** Email OTP is 6 digits, TTL 10 minutes, single-use; cleared on successful verification. An unknown account → 404 USER_NOT_FOUND. An account whose email address is already verified returns success immediately without checking the code again. A code that is absent, never issued or expired → 400 OTP_INVALID. A wrong code increases a wrong-attempt counter with a 10-minute window; on the fifth wrong attempt the stored code is discarded and the answer is 400 OTP_TOO_MANY_ATTEMPTS, below five attempts the answer is 400 OTP_INVALID. A correct code clears the wrong-attempt counter and the stored code and marks the email address as verified.
- **BR-04:** OTP resend has a 60-second cooldown per email (Redis-backed) → 429 RATE_LIMIT_EXCEEDED inside the cooldown. An unknown account → 404 USER_NOT_FOUND. An already verified account returns success without sending anything. An accepted resend issues a new six-digit code valid for 10 minutes, restarts the 60-second cooldown and clears the previous wrong-attempt counter.
- **BR-07** *(phone linking, reuses the OTP mechanism of BR-03/BR-04):* An invalid phone number → 400 INVALID_PHONE. An unknown account → 404 USER_NOT_FOUND. A phone number already used by another account → 409 PHONE_ALREADY_IN_USE. A repeat phone-linking request inside the 60-second cooldown → 429 RATE_LIMIT_EXCEEDED, and the pending code is not replaced. An accepted phone-linking request issues a six-digit code valid for 10 minutes, restarts the cooldown, clears the previous wrong-attempt counter and sends the code by email, not by SMS. A phone verification with no pending code, or with an expired one → 400 OTP_INVALID. A wrong phone code increases a wrong-attempt counter with a 10-minute window; on the fifth wrong attempt the pending code is discarded and the answer is 400 OTP_TOO_MANY_ATTEMPTS, below five attempts the answer is 400 OTP_INVALID. A correct phone code consumes the pending code, re-checks whether the phone number has been taken by another account in the meantime → 409 PHONE_ALREADY_IN_USE, and otherwise attaches the phone number to the account.

### Validation
- code empty or phone empty → Display: MSG02
- phone number cannot be normalized into a valid number → Display: MSG02 (treated as an invalid required field)
- code invalid or expired → Display: MSG20

## Functionalities
### Normal Flow
1. After signing up, the user opens the verification screen and enters the six-digit code received by email.
2. The system finds the account, checks the code and its expiry and compares them.
3. A correct code marks the email address as verified and clears the stored code.
4. The user continues to Sign In to start a session.
5. For phone linking, a signed-in user submits a phone number and receives a code by email.
6. The user enters the code; the system consumes it and attaches the phone number to the account; toast MSG26 (profile updated with the new phone).

### Abnormal Cases
- 2.a1: Unknown account (BR-03/BR-07) → 404 USER_NOT_FOUND, toast MSG38. 2.a2: The user restarts sign-up or signs in with a valid account.
- 2.b1: Missing, expired or wrong code (BR-03/BR-10/BR-11) → 400 OTP_INVALID, Display: MSG20. 2.b2: The user re-enters the code, or the fifth wrong attempt discards it (BR-03/BR-11) → 400 OTP_TOO_MANY_ATTEMPTS, Display: MSG20, and a new code must be requested via resend.
- 5.a1: A resend, or a repeated phone-linking request, inside the 60-second cooldown (BR-04/BR-08) → 429 RATE_LIMIT_EXCEEDED, toast MSG88, and the pending code is not replaced. 5.a2: The user waits for the cooldown to elapse before requesting again.
- 5.b1: Invalid phone number (BR-07) → 400 INVALID_PHONE, Display: MSG02. 5.b2: The user enters a valid phone number.
- 6.a1: Phone number already used by another account, at linking or at verification (BR-07/BR-12) → 409 PHONE_ALREADY_IN_USE, toast MSG38. 6.a2: The user enters a different phone number.

## Post-Conditions
- Email verification marks the email address as verified and clears the code together with the wrong-attempt counter.
- Phone verification attaches the phone number to the account and clears the pending code together with the wrong-attempt counter.
- Email verification establishes no session; the user signs in separately afterwards.
