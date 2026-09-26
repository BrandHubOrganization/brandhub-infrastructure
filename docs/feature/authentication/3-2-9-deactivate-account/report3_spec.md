**3.2.9 Deactivate Account**

**Function Trigger**

Begins when a signed-in user activates "Deactivate" in the Danger Zone of the profile screen and confirms the dialog with their password, or, for an account with no password, with a one-time code sent to their email.

**Function Description**

- **Actors / Roles**: USER who is signed in, either with a password or as an OAuth-only account with no password.
- **Purpose**: Let a user disable their own account (soft delete) after proving identity with the password or a one-time email code, and immediately cut off active sessions.
- **Interface**: Danger Zone section on the profile page with a confirmation dialog. Accounts with a password show a password field; accounts without one show a "Send code" button and, once sent, a six-digit code field.
- **Data Processing**: Resolves the caller from the Bearer access token, reads the refresh token cookie and the raw access token. Loads the user, verifies identity via the password or OTP branch, checks the caller does not own any ACTIVE agency, sets user.status = DEACTIVATED and saves, then blacklists the caller's access token and refresh token (best-effort) so active sessions are cut off immediately.

**Screen Layout**

Figure — Deactivate Account (Profile, Danger Zone):

- A red-bordered "Danger Zone" card with a "Deactivate" button that opens the confirm dialog.
- If the account has a password: the dialog shows a password input.
- If the account has no password: the dialog shows a "Send code"/"Resend code" button followed by an OTP input.
- Cancel and a destructive "Confirm Deactivate" button, disabled until the relevant field is non-empty or while the request is in flight.
- On success the client clears the local session and returns to /login.

**Function Details**
- **Data Specifications**
    - **Input required**: Bearer access token. Exactly one of password or otpCode, selected by the account's own state, not by which field the client sends.
    - **Input optional**: both password and otpCode are optional at the request level; the service enforces which one is actually required and ignores the other. The refresh token cookie is optional.
    - **System data**: userId (from token), user.passwordHash, user.status, deactivate OTP (Redis, TTL 10 min), agencies owned by the user and their status, the caller's raw access token and refresh token.
    - **Output**: no payload, 200.

- **Business Rules**
    - **BR-22**: Deactivation sets user.status = DEACTIVATED and blacklists outstanding tokens so active sessions are cut off. After the status update, the service blacklists the caller's access token and refresh token, each wrapped in a best-effort try/catch that ignores a malformed or absent token. A subsequent login or refresh is also rejected with 403 ACCOUNT_DEACTIVATED, but the blacklist call is what makes cut-off immediate rather than only on next refresh/expiry.
    - **BR-23**: The last active OWNER of an Agency cannot self-deactivate. After identity is confirmed, the system checks for any Agency owned by the caller with status ACTIVE; if one exists -> 409 AGENCY_OWNERSHIP_ACTIVE, account left unchanged.
    - Identity confirmation: no password on file -> OTP branch (missing, expired, or mismatched code -> 400 OTP_INVALID; a match deletes the key so it cannot be reused). Password on file -> password branch (mismatch -> 400 WRONG_CURRENT_PASSWORD). The field not used by the branch is ignored.
    - sendDeactivateOtp generates a 6-digit OTP (TTL 10 min) and emails it; there is no resend cooldown on this endpoint, unlike the analogous email-OTP and phone-OTP flows.

- **Validation**
    - Missing or malformed access token -> 401 INVALID_CREDENTIALS, toast **MSG22**
    - password empty (password branch) -> Display: **MSG02**
    - otpCode empty or malformed (OTP branch) -> Display: **MSG02**

**Functionalities**
- **Normal Flow**
    1. The user opens the Danger Zone on the profile page and activates "Deactivate".
    2. The client resolves whether the account has a password and shows the matching field.
    3. For an OAuth-only account, the user first clicks "Send code"; the system generates and emails a 6-digit OTP (TTL 10 min).
    4. The user supplies the password or the OTP and confirms, with the Bearer header and, if present, the refresh cookie sent automatically.
    5. The system resolves the caller and extracts the raw access token and refresh token.
    6. The system loads the user and verifies the password or the OTP depending on whether a password is set.
    7. The system checks for an ACTIVE agency owned by the user (BR-23); none found.
    8. The system sets user.status = DEACTIVATED and saves.
    9. The system blacklists the access token and, if present, the refresh token, ignoring failures on a malformed/absent token.
    10. 200 OK; the client clears the local session, redirects to /login, toast **MSG91**.

- **Abnormal Cases**
    - 5.a1: Missing or invalid access token -> 401 INVALID_CREDENTIALS, toast **MSG22**. 5.a2: The user signs in again.
    - 6.a1: Account referenced by the token no longer exists -> 404 USER_NOT_FOUND, toast **MSG38**. 6.a2: The user signs in again with a valid account.
    - 6.b1: Password branch, wrong password -> 400 WRONG_CURRENT_PASSWORD, Display: **MSG19**. 6.b2: The user re-enters the password.
    - 6.c1: OTP branch, code missing, expired, never requested, or mismatched -> 400 OTP_INVALID, Display: **MSG20**. 6.c2: The user requests a new code and re-enters it.
    - 7.a1: The user owns at least one ACTIVE agency (BR-23) -> 409 AGENCY_OWNERSHIP_ACTIVE, toast **MSG38**. 7.a2: The user transfers agency ownership first; if the OTP branch was used, a new code must be requested before retrying.
    - 9.a1: Access token malformed, expired, or absent at the blacklist step -> caught and ignored; deactivation still succeeds. 9.a2: Same handling for a malformed/absent refresh cookie.

**Post-Conditions**

- user.status = DEACTIVATED; all related rows (agencies, workspace memberships, etc.) are kept — this is a soft delete.
- The OTP, when the OTP branch was used, is consumed and cannot be reused.
- The caller's access token and refresh token (if present) are blacklisted, so the currently active session is cut off immediately.
- A subsequent login or refresh attempt is also rejected with 403 ACCOUNT_DEACTIVATED, independent of the blacklist.
