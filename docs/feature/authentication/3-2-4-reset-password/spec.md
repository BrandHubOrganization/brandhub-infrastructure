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
- **BR-01:** An unknown email address produces the same response as a known one and sends nothing, so the response never reveals whether an account exists.
- **BR-02:** The reset token is single-use and is invalidated the moment a newer reset token is issued for the same account, so only the most recent token is accepted even if an earlier one has not yet expired.
- **BR-03:** A missing, expired or superseded token → 400 RESET_TOKEN_INVALID. A token that has already been used → 400 RESET_TOKEN_USED.
- **BR-04:** The new password follows the password policy and is stored as a BCrypt hash; the last password change time is updated.
- **BR-05:** After a successful reset, every refresh token issued before the latest password change is refused on its next use → 401 REFRESH_TOKEN_INVALID, so the user signs in again on every device.

### Validation
- Empty email address → error message.
- New password does not meet the policy, or the confirmation does not match → error message.
- New password fails the policy check on the server → 400 VALIDATION_ERROR.

## Functionalities
### Normal Flow
1. The user opens /forgot-password and submits the email address.
2. The system looks up the account; when no account matches it returns the same generic response without sending anything.
3. The system invalidates any earlier reset token for the account and issues a new single-use token with a limited lifetime.
4. The system sends the reset link carrying the token to the email address.
5. The user opens the link from the email and enters the new password and its confirmation.
6. The system consumes the token, replaces the password hash and records the password change.
7. The system returns success and the screen returns to /login.

### Abnormal Cases
- Unknown email address → the same generic response, and no email is sent.
- Missing, expired or superseded token → 400 RESET_TOKEN_INVALID.
- Token already used, including two simultaneous reset requests → 400 RESET_TOKEN_USED.
- The account referenced by the token no longer exists → 400 RESET_TOKEN_INVALID.
- New password fails the policy check → 400 VALIDATION_ERROR.

## Post-Conditions
- The password hash is replaced and the last password change time is updated.
- The reset token is consumed and the record of the most recent token for the account is cleared.
- Every refresh token issued before the change is refused on its next use, so all devices must sign in again.
