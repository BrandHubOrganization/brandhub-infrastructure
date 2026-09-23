# 3.2.9 Deactivate Account

## Function Trigger
Begins when a signed-in user activates Deactivate in the Danger Zone of the profile screen and confirms the dialog.

## Function Description
- **Actors / Roles:** USER who is signed in, either with a password or as an account created through Google and therefore without a password.
- **Purpose:** Let a user disable their own account as a soft delete that keeps all related data, after proving identity with the password or with a one-time code.
- **Interface:** Danger Zone section on /profile with a confirmation dialog carrying a clear warning. The dialog asks for the password, or, for an account without a password, offers to send a one-time code and then asks for the six-digit code received by email.
- **Data Processing:** The system identifies the caller from the access token, verifies identity with the password or with a one-time code, checks whether the user still owns an active agency, and only then marks the account as deactivated.

## Screen Layout
Figure — Deactivate Account (/profile, Danger Zone):
- The section shows a clear warning before confirmation.
- Accounts with a password: the confirmation dialog asks for the password.
- Accounts without a password: the dialog first offers sending a confirmation code, then asks for the six-digit code received by email.
- On success the screen clears the local session and returns to /login.

## Function Details
### Data Specifications
- **Input required:** password for accounts that have one; a one-time code for accounts that do not, after a code has been requested.
- **Input optional:** none; only the field matching the account type is used, and the other is ignored when supplied.
- **System data:** userId, passwordHash, status, one-time code with a 10-minute lifetime, owned agencies and their status.
- **Output:** no data.

### Business Rules
- **BR-01:** A missing or invalid access token → 401 INVALID_CREDENTIALS. An account referenced by the token that no longer exists → 404 USER_NOT_FOUND.
- **BR-02:** The flow is chosen from the account itself. An account with a password must confirm with the password and any submitted code is ignored; an account without a password must confirm with a one-time code and any submitted password is ignored.
- **BR-03:** A wrong password → 400 WRONG_CURRENT_PASSWORD. A missing, expired, already used or wrong one-time code → 400 OTP_INVALID.
- **BR-04:** The one-time code is six digits, valid for 10 minutes and single-use; requesting a code again replaces the previous one and restarts its lifetime. Requesting a code does not require the account to be without a password.
- **BR-05:** After identity is confirmed, if the user owns at least one active agency the deactivation is refused with 409 AGENCY_OWNERSHIP_ACTIVE and the account status is left unchanged; ownership must be transferred first.
- **BR-06:** Deactivation is a soft delete: the account is marked as deactivated, no account or related data is removed, and a later sign-in attempt is refused with 403 ACCOUNT_DEACTIVATED.

### Validation
- Missing or malformed access token → 401 INVALID_CREDENTIALS.
- Empty password, or an empty or malformed code → error message.

## Functionalities
### Normal Flow
1. The user activates Deactivate in the Danger Zone and confirms in the dialog.
2. The system identifies the account and selects the flow from whether the account has a password.
3. For an account without a password, the user first requests a code and receives it by email.
4. The user supplies the password, or the code, and the system verifies it.
5. The system checks that the user does not own any active agency.
6. The system marks the account as deactivated.
7. The system returns success and the screen clears the local session and returns to /login.

### Abnormal Cases
- Missing or invalid access token → 401 INVALID_CREDENTIALS.
- The account referenced by the token no longer exists → 404 USER_NOT_FOUND.
- Wrong password → 400 WRONG_CURRENT_PASSWORD.
- Code missing, expired, already used or wrong, including a code submitted before any code was requested → 400 OTP_INVALID.
- The user still owns at least one active agency → 409 AGENCY_OWNERSHIP_ACTIVE and the account status is unchanged. In the code-based flow the code has already been consumed, so a new code must be requested before retrying.
- A user with a password submits a code instead of the password → 400 WRONG_CURRENT_PASSWORD, because the password flow applies and the code is ignored.

## Post-Conditions
- The account is marked as deactivated and can no longer sign in.
- All related data, including agencies and memberships, is kept.
- The confirmation code, when one was used, is consumed and cannot be reused.
