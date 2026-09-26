**3.2.7 Two-Factor Authentication (2FA, TOTP)**

**Function Trigger**

Begins when a signed-in user enables or disables 2FA from the Security settings page, or when a user who already has it enabled completes the password step or Google sign-in and is redirected to the code-entry screen.

**Function Description**

- **Actors / Roles**: USER — signed in when enabling, confirming, or disabling; holding only a short-lived two-factor token (no access token) when verifying at sign-in.
- **Purpose**: Add a second factor based on time-based one-time codes, so every sign-in method requires something the user holds in addition to the password.
- **Interface**: Security page — "Enable 2FA" revealing a QR code and a 6-digit code input to confirm; "Disable 2FA" requiring the current code; a single 6-digit code screen shown during sign-in when 2FA is enabled.
- **Data Processing**: Generates a TOTP secret and holds it pending in Redis until a correct code confirms it; only then is the secret persisted and 2FA marked enabled. Verifying a code always checks it against the TOTP algorithm, then always runs the attempt-lockout check: a wrong code increments a per-user counter (TTL 10 minutes), and the 5th wrong code within that window returns a lockout error instead of an invalid-code error; a correct code clears the counter.

**Screen Layout**

Figure — Two-Factor Authentication screens:

- Security page 2FA card: not enabled shows "Enable 2FA"; mid-setup shows a QR code plus a 6-digit code input with Confirm/Cancel; enabled shows a "Disable 2FA" button; confirming disable shows a 6-digit code input with Confirm/Cancel.
- Verify screen: 6 single-digit inputs, a Verify button, and a "Back to login" link. Reached only when a two-factor token is present; otherwise redirects to /login.

**Function Details**
- **Data Specifications**
    - **Input required**: code (6-digit) for confirm/disable/verify; twoFactorToken for verify. Setup takes no body.
    - **Input optional**: none.
    - **System data**: userId, totpSecret, twoFactorEnabled, the pending secret (Redis, TTL 10 min), the wrong-attempt counter (Redis, TTL 10 min), twoFactorToken, lastLoginAt, workspaceId.
    - **Output**: otpAuthUrl (setup); nothing (confirm/disable); access token, token type, expiry, and a refresh-token cookie (verify).

- **Business Rules**
    - **BR-15**: TOTP, 6-digit code, 30-second step, ±1-step tolerance. setup: 404 USER_NOT_FOUND if missing; 400 TWO_FA_ALREADY_ENABLED if already enabled. confirm: same checks plus 400 TWO_FA_NOT_ENABLED if no pending secret; 400 TWO_FA_CODE_INVALID on mismatch. disable: 400 TWO_FA_NOT_ENABLED if not enabled; 400 TWO_FA_CODE_INVALID on mismatch. No recovery-code mechanism exists; a lost authenticator requires an administrator to disable 2FA manually.
    - **BR-86**: Wrong 2FA code is limited to 5 attempts within a 10-minute window, shared across confirm/disable/verify for the same user. The 5th wrong code returns 429 TWO_FA_TOO_MANY_ATTEMPTS instead of 400 TWO_FA_CODE_INVALID; a correct code clears the counter immediately.
    - **BR-17**: Mandatory 2FA for higher roles is not implemented; 2FA is opt-in for every role today.
    - **BR-05**: Verify at sign-in requires the token to parse and carry the 2FA claim type, else 401 TWO_FA_TOKEN_INVALID; subject must resolve to an existing user, else the same generic error. Account status checked next: 403 ACCOUNT_SUSPENDED or 403 ACCOUNT_DEACTIVATED. If 2FA was disabled meanwhile -> 400 TWO_FA_NOT_ENABLED. On success, sign-in completes exactly as a normal login.

- **Validation**
    - code empty or not a 6-digit number -> Display: **MSG02**
    - code well-formed but does not match the current window -> 400 TWO_FA_CODE_INVALID, Display: **MSG20** (or 429 on the 5th wrong code within 10 minutes)

**Functionalities**
- **Normal Flow**
    1. Signed-in user opens Security settings and clicks "Enable 2FA".
    2. The system loads the account, confirms 2FA is not already enabled, generates a TOTP secret, stores it pending in Redis (TTL 10 min), and returns the QR provisioning URL.
    3. The client renders the QR code; the user scans it with an authenticator app.
    4. The user enters the 6-digit code shown by the app and submits.
    5. The system re-checks not-already-enabled, reads the pending secret, verifies the code; a wrong code goes through the attempt-lockout check; on match it clears the counter, persists the secret, sets 2FA enabled, and deletes the pending key. Toast **MSG24**.
    6. On a later sign-in, the login step sees 2FA enabled, issues a two-factor token, and returns it — no access/refresh token yet. The client redirects to the verify screen.
    7. The user enters the code from the app on the verify screen and submits.
    8. The system validates the token, loads the user, checks status, verifies the code (wrong code goes through the lockout check), and on match completes sign-in: clears the counter, issues access and refresh tokens, sets the refresh cookie.

- **Abnormal Cases**
    - 2.a1: Setup requested for an account that no longer exists -> 404 USER_NOT_FOUND.
    - 2.b1: Setup requested while 2FA is already enabled -> 400 TWO_FA_ALREADY_ENABLED. 2.b2: The user disables 2FA first, then starts setup again.
    - 5.a1: Confirm while already enabled (double submit) -> 400 TWO_FA_ALREADY_ENABLED.
    - 5.b1: Confirm with no pending secret, never called setup or TTL expired -> 400 TWO_FA_NOT_ENABLED. 5.b2: The user restarts setup for a fresh QR code.
    - 5.c1: Confirm with a wrong code -> 400 TWO_FA_CODE_INVALID, Display: **MSG20**; the pending secret is kept for retry. 5.c2: The user re-enters the code.
    - 5.d1: Confirm with the 5th wrong code within 10 minutes (BR-86) -> 429 TWO_FA_TOO_MANY_ATTEMPTS. 5.d2: The user waits for the window to lapse before retrying.
    - Disable.a1: Disable while 2FA is not enabled -> 400 TWO_FA_NOT_ENABLED.
    - Disable.b1: Disable with a wrong code -> 400 TWO_FA_CODE_INVALID, Display: **MSG20**. On success, toast **MSG25**.
    - Disable.c1: Disable with the 5th wrong code within 10 minutes -> 429 TWO_FA_TOO_MANY_ATTEMPTS.
    - 8.a1: Verify with an unparseable token, wrong claim, or unresolvable subject -> 401 TWO_FA_TOKEN_INVALID, toast **MSG22**. 8.a2: The user is returned to /login.
    - 8.b1: Verify against a suspended or deactivated account -> 403 ACCOUNT_SUSPENDED / 403 ACCOUNT_DEACTIVATED. 8.b2: The user contacts support.
    - 8.c1: 2FA was disabled between login and verify -> 400 TWO_FA_NOT_ENABLED. 8.c2: The user signs in normally.
    - 8.d1: Verify with a wrong code -> 400 TWO_FA_CODE_INVALID, Display: **MSG20**. 8.d2: The user re-enters the code.
    - 8.e1: Verify with the 5th wrong code within 10 minutes -> 429 TWO_FA_TOO_MANY_ATTEMPTS. 8.e2: The user waits for the window to lapse, then signs in again.

**Post-Conditions**

- On enabling: totpSecret is stored, twoFactorEnabled=true, the pending-setup key is deleted, and the attempt counter is cleared.
- On disabling: totpSecret is cleared and twoFactorEnabled=false; the attempt counter is cleared.
- On a successful verify at sign-in: sign-in completes as in normal login and the attempt counter is cleared.
- On a wrong code in any of the three flows: the attempt counter is incremented; on the 5th wrong code within 10 minutes it is deleted and further calls fail with 429 until success or the window naturally expires.
