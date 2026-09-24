# 3.2.5 Change Password

## Function Trigger
Begins when a signed-in user opens /settings/change-password and submits the current password together with a new password.

## Function Description
- **Actors / Roles:** USER who is already signed in.
- **Purpose:** Let a signed-in user change the password after proving knowledge of the current one, without ending the current session.
- **Interface:** Change Password form with Current Password, New Password and Confirm New Password inputs, plus a confirmation step before the change is applied.
- **Data Processing:** The system identifies the caller from the access token, verifies the current password, refuses a new password identical to the current one, replaces the password hash, updates the last password change time and records the event.

## Screen Layout
Figure — Change Password Screen (/settings/change-password):
- Center: Current Password input, New Password input, Confirm New Password input.
- A confirmation step, either a dialog or a separate step, is required before the change is applied.
- A success message is shown afterwards and the user stays signed in.

## Function Details
### Data Specifications
- **Input required:** currentPassword, newPassword.
- **Input optional:** confirmNewPassword, validated on the client only.
- **System data:** userId, passwordHash, lastPasswordChange, the recorded event.
- **Output:** no data.

### Business Rules
- **BR-02:** Password policy: minimum 8 characters + at least 1 digit, hashed with BCrypt cost=12; the current password must match the stored password hash, checked first, otherwise 400 WRONG_CURRENT_PASSWORD. The new password must differ from the current one; otherwise 400 SAME_AS_CURRENT_PASSWORD, evaluated only after the current password has been accepted. The order of checks is: verify the current password, then compare the new password with the current one, and only then apply the change.
- **BR-12:** The change updates the last password change time, so a refresh token `jti` issued before that moment is rejected on its next use → 401 REFRESH_TOKEN_INVALID (password change invalidates all outstanding refresh tokens). The current access token keeps working, so the current session is not ended.

### Validation
- current password empty or new password empty → Display: MSG02
- new password does not meet the policy → Display: MSG05
- confirmation does not match → Display: MSG06

## Functionalities
### Normal Flow
1. The user opens /settings/change-password and enters the current password, the new password and the confirmation.
2. The user confirms the change in the confirmation step.
3. The system identifies the caller from the access token and loads the account.
4. The system verifies the current password against the stored password hash.
5. The system refuses the request when the new password is identical to the current one.
6. The system replaces the password hash and updates the last password change time.
7. The system records the password change event and returns success; the session stays active; toast MSG26.

### Abnormal Cases
- 3.a1: Missing or invalid access token → 401 INVALID_CREDENTIALS, toast MSG22. 3.a2: The user signs in again.
- 3.b1: The account referenced by the token no longer exists → 404 USER_NOT_FOUND, toast MSG38. 3.b2: The user signs in again with a valid account.
- 4.a1: Wrong current password (BR-02) → 400 WRONG_CURRENT_PASSWORD, Display: MSG19. 4.a2: The user re-enters the current password.
- 5.a1: The new password is identical to the current one (BR-02), evaluated only after the current password has been accepted → 400 SAME_AS_CURRENT_PASSWORD, Display: MSG06. 5.a2: The user enters a different new password.
- 1.a1: New password fails the policy check (BR-02) → 400 VALIDATION_ERROR, Display: MSG05. 1.a2: The user corrects the password and resubmits.

## Post-Conditions
- The password hash is replaced and the last password change time is updated.
- The password change event is recorded.
- The current session stays active, while refresh tokens issued before the change are refused on their next use.
