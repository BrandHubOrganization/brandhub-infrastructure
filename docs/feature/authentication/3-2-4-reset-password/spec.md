# 3.2.4 Reset Password

## Function Trigger
Begins when a user who has forgotten the password submits the email address on /forgot-password.

## Function Description
- **Actors / Roles:** USER who cannot sign in because the password is forgotten.
- **Purpose:** Restore access to the account by email through a single-use reset link, and invalidate existing sessions afterwards so only the account owner keeps access.
- **Interface:** /forgot-password collects the email address; the reset screen /reset-password receives the token and collects the new password together with its confirmation.
- **Data Processing:** The system looks up the account, invalidates any earlier reset token, issues a new single-use token with a limited lifetime, sends it by email, and on completion replaces the password hash, records the change and invalidates older sessions.

## Screen Layout
Figure — Reset Password screens:
- /forgot-password: email input and a submit button.
- /reset-password: new password input and confirm password input, with the confirmation validated before submission.
- A generic message is shown after the request; a success message and a return to /login follow the reset.

## Function Details
### Data Specifications
- **Input required:** email (request step); token and newPassword (reset step).
- **Input optional:** confirmPassword, validated on the client only.
- **System data:** userId, passwordHash, lastPasswordChange, reset token with its lifetime, last issued token per account.
- **Output:** no data; a generic success response in both cases.

### Business Rules
- **BR-13:** Forgot-password always returns 200 OK whether or not the email exists, so the response never reveals whether an account exists; reset token is 32-byte random hex stored only in Redis, TTL ≤ 1h, single-use (deleted atomically on use). The reset token is invalidated the moment a newer reset token is issued for the same account, so only the most recent token is accepted even if an earlier one has not yet expired. A missing, expired or superseded token → 400 RESET_TOKEN_INVALID. A token that has already been used → 400 RESET_TOKEN_USED.
- **BR-02:** The new password follows the password policy (minimum 8 characters + at least 1 digit) and is stored as a BCrypt hash cost=12; the last password change time is updated.
- **BR-12:** After a successful reset, every refresh token issued before the latest password change is rejected (jti checked against blacklist) on its next use → 401 REFRESH_TOKEN_INVALID, so the user signs in again on every device.

### Validation
- email empty → Display: MSG02
- new password does not meet the policy → Display: MSG05
- confirmation does not match → Display: MSG06

## Functionalities
### Normal Flow
1. The user opens /forgot-password and submits the email address.
2. The system looks up the account; when no account matches it returns the same generic response without sending anything.
3. The system invalidates any earlier reset token for the account and issues a new single-use token with a limited lifetime.
4. The system sends the reset link carrying the token to the email address.
5. The user opens the link from the email and enters the new password and its confirmation.
6. The system consumes the token, replaces the password hash and records the password change.
7. The system returns success and the screen returns to /login; toast MSG18.

### Abnormal Cases
- 2.a1: Unknown email address (BR-13) → the same generic response, toast MSG15, and no email is sent. 2.a2: The user checks the inbox or requests again; the response never confirms whether the account exists.
- 6.a1: Missing, expired or superseded token (BR-13) → 400 RESET_TOKEN_INVALID, toast MSG16. 6.a2: The user requests a new reset link from /forgot-password.
- 6.b1: Token already used, including two simultaneous reset requests, or the account referenced by the token no longer exists (BR-13) → 400 RESET_TOKEN_USED, toast MSG17. 6.b2: The user requests a new reset link from /forgot-password.
- 6.c1: New password fails the policy check (BR-02) → 400 VALIDATION_ERROR, Display: MSG05. 6.c2: The user corrects the password and resubmits.

## Post-Conditions
- The password hash is replaced and the last password change time is updated.
- The reset token is consumed and the record of the most recent token for the account is cleared.
- Every refresh token issued before the change is refused on its next use, so all devices must sign in again.
