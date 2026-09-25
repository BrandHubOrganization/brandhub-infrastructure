**3.2.5 Change Password**

**Function Trigger**

Begins when a signed-in user opens the change-password section under Settings > Security and submits the current password together with a new password and its confirmation.

**Function Description**

- **Actors / Roles**: Any authenticated USER changing their own password. Applies to any account that already has a password set.
- **Purpose**: Let a signed-in user change the password after proving knowledge of the current one, without ending the current session.
- **Interface**: A form on Settings > Security with three fields — Current Password, New Password, Confirm New Password — and a submit button.
- **Data Processing**: Identifies the caller from the access token, verifies the current password against the stored hash, refuses a new password identical to the current one, replaces the password hash, updates the last-password-change time, and records an audit log event.

**Screen Layout**

Figure — Change Password (Settings > Security):

- A card titled "Change Password" with three password inputs: Current Password, New Password, Confirm New Password (client-only confirmation, not sent to the server).
- A single submit button, loading state while in flight.
- On success: a toast confirms the change and the user is navigated to the dashboard; the current session stays signed in.
- On failure: an error message is shown and the form remains filled in for correction.

**Function Details**
- **Data Specifications**
    - **Input required**: currentPassword, newPassword; Authorization Bearer header.
    - **Input optional**: confirmNewPassword — client-side only, never sent to the server.
    - **System data**: userId (from the access token), user.passwordHash, user.lastPasswordChange, the audit log entry.
    - **Output**: no payload, 200.

- **Business Rules**
    - **BR-02**: Password policy — minimum 8 characters and at least 1 digit; hashed with BCrypt cost=12; never logged or returned.
    - Check order: (1) verify currentPassword against the stored hash — mismatch -> 400 WRONG_CURRENT_PASSWORD; (2) only then compare newPassword to the same hash — a match -> 400 SAME_AS_CURRENT_PASSWORD; (3) only then hash and persist the new password.
    - **BR-12**: Changing the password sets lastPasswordChange = now. A refresh token issued before this timestamp is rejected on its next use, invalidating every outstanding refresh token on every device, even though the current session remains valid.
    - The same audit action is reused for both Reset Password and Change Password; there is no distinct "password changed" action.

- **Validation**
    - currentPassword or newPassword empty -> Display: **MSG02**
    - newPassword under 8 characters or missing a digit -> Display: **MSG05**
    - confirmNewPassword mismatch -> Display: **MSG06**
    - Missing or malformed Authorization header -> 401 INVALID_CREDENTIALS

**Functionalities**
- **Normal Flow**
    1. The user opens Settings > Security and enters the current password, the new password, and the confirmation.
    2. The client checks the confirmation matches the new password, then submits.
    3. The system resolves the caller's userId from the access token and loads the account.
    4. The system verifies currentPassword against the stored hash.
    5. The system compares newPassword against the same hash and rejects it if identical.
    6. The system replaces passwordHash with the BCrypt hash of newPassword, sets lastPasswordChange = now, and writes an audit log entry.
    7. The system returns 200. The client shows a success toast and navigates to the dashboard; the current session stays signed in, while every outstanding refresh token is invalidated.

- **Abnormal Cases**
    - 2.a1: Missing or malformed Authorization header -> 401 INVALID_CREDENTIALS. 2.a2: The user is signed out and returned to login.
    - 3.a1: The account referenced by the token no longer exists -> 404 USER_NOT_FOUND. 3.a2: The user is signed out and must sign in again.
    - 4.a1: currentPassword does not match the stored hash, checked first -> 400 WRONG_CURRENT_PASSWORD, Display: **MSG19**. 4.a2: The user re-enters the current password.
    - 5.a1: newPassword is identical to currentPassword, checked only after step 4 passes -> 400 SAME_AS_CURRENT_PASSWORD. 5.a2: The user enters a different new password.
    - 1.a1: newPassword fails the policy check -> Display: **MSG05**. 1.a2: The user corrects the password and resubmits.
    - 1.b1: currentPassword or newPassword empty -> Display: **MSG02**. 1.b2: The user fills in the missing field and resubmits.

**Post-Conditions**

- user.passwordHash is replaced and user.lastPasswordChange is updated to the change time.
- An audit log entry is recorded for the user.
- The current session remains valid and signed in.
- Every refresh token issued before the change, on this device or any other, is rejected on its next use; the user must sign in again on those other sessions.
