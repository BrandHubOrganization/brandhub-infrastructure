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
- **BR-01:** The current password must match the stored password hash; otherwise 400 WRONG_CURRENT_PASSWORD. This check runs first.
- **BR-02:** The new password must differ from the current one; otherwise 400 SAME_AS_CURRENT_PASSWORD. This check runs only after the current password has been accepted.
- **BR-03:** The order of checks is: verify the current password, then compare the new password with the current one, and only then apply the change.
- **BR-04:** The change updates the last password change time, which makes every refresh token issued before that moment refused on its next use → 401 REFRESH_TOKEN_INVALID. The current access token keeps working, so the current session is not ended.

### Validation
- Empty current password or empty new password → error message.
- New password does not meet the policy, or the confirmation does not match → error message.
- New password fails the policy check on the server → 400 VALIDATION_ERROR.

## Functionalities
### Normal Flow
1. The user opens /settings/change-password and enters the current password, the new password and the confirmation.
2. The user confirms the change in the confirmation step.
3. The system identifies the caller from the access token and loads the account.
4. The system verifies the current password against the stored password hash.
5. The system refuses the request when the new password is identical to the current one.
6. The system replaces the password hash and updates the last password change time.
7. The system records the password change event and returns success; the session stays active.

### Abnormal Cases
- Missing or invalid access token → 401 INVALID_CREDENTIALS.
- The account referenced by the token no longer exists → 404 USER_NOT_FOUND.
- Wrong current password → 400 WRONG_CURRENT_PASSWORD.
- The new password is identical to the current one → 400 SAME_AS_CURRENT_PASSWORD; this is evaluated only after the current password has been accepted.
- New password fails the policy check → 400 VALIDATION_ERROR.

## Post-Conditions
- The password hash is replaced and the last password change time is updated.
- The password change event is recorded.
- The current session stays active, while refresh tokens issued before the change are refused on their next use.
