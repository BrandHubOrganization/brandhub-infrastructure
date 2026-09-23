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
- **BR-01:** An unknown account → 404 USER_NOT_FOUND. An account whose email address is already verified returns success immediately without checking the code again.
- **BR-02:** A code that is absent, never issued or expired → 400 OTP_INVALID.
- **BR-03:** A wrong code increases a wrong-attempt counter with a 10-minute window. On the fifth wrong attempt the stored code is discarded and the answer is 400 OTP_TOO_MANY_ATTEMPTS; below five attempts the answer is 400 OTP_INVALID.
- **BR-04:** A correct code clears the wrong-attempt counter and the stored code and marks the email address as verified.
- **BR-05:** A resend inside the 60-second cooldown → 429 RATE_LIMIT_EXCEEDED. An unknown account → 404 USER_NOT_FOUND. An already verified account returns success without sending anything.
- **BR-06:** An accepted resend issues a new six-digit code valid for 10 minutes, restarts the 60-second cooldown and clears the previous wrong-attempt counter.
- **BR-07:** An invalid phone number → 400 INVALID_PHONE. An unknown account → 404 USER_NOT_FOUND. A phone number already used by another account → 409 PHONE_ALREADY_IN_USE.
- **BR-08:** A repeat phone-linking request inside the 60-second cooldown → 429 RATE_LIMIT_EXCEEDED, and the pending code is not replaced.
- **BR-09:** An accepted phone-linking request issues a six-digit code valid for 10 minutes, restarts the cooldown, clears the previous wrong-attempt counter and sends the code by email, not by SMS.
- **BR-10:** A phone verification with no pending code, or with an expired one → 400 OTP_INVALID.
- **BR-11:** A wrong phone code increases a wrong-attempt counter with a 10-minute window. On the fifth wrong attempt the pending code is discarded and the answer is 400 OTP_TOO_MANY_ATTEMPTS; below five attempts the answer is 400 OTP_INVALID.
- **BR-12:** A correct phone code consumes the pending code, re-checks whether the phone number has been taken by another account in the meantime → 409 PHONE_ALREADY_IN_USE, and otherwise attaches the phone number to the account.

### Validation
- Empty code or empty phone number → error message.
- Phone number cannot be normalized into a valid number → 400 INVALID_PHONE.

## Functionalities
### Normal Flow
1. After signing up, the user opens the verification screen and enters the six-digit code received by email.
2. The system finds the account, checks the code and its expiry and compares them.
3. A correct code marks the email address as verified and clears the stored code.
4. The user continues to Sign In to start a session.
5. For phone linking, a signed-in user submits a phone number and receives a code by email.
6. The user enters the code; the system consumes it and attaches the phone number to the account.

### Abnormal Cases
- Unknown account → 404 USER_NOT_FOUND.
- Missing, expired or wrong code → 400 OTP_INVALID; the fifth wrong attempt → 400 OTP_TOO_MANY_ATTEMPTS and the current code is discarded, so a new code must be requested.
- A resend, or a repeated phone-linking request, inside the 60-second cooldown → 429 RATE_LIMIT_EXCEEDED, and the pending code is not replaced.
- Invalid phone number → 400 INVALID_PHONE.
- Phone number already used by another account, at linking or at verification → 409 PHONE_ALREADY_IN_USE.

## Post-Conditions
- Email verification marks the email address as verified and clears the code together with the wrong-attempt counter.
- Phone verification attaches the phone number to the account and clears the pending code together with the wrong-attempt counter.
- Email verification establishes no session; the user signs in separately afterwards.
