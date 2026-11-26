**3.2.2 Sign In with Email/Phone + Password**

**Function Trigger**

Begins when a Guest with an existing account visits /login and submits an identifier (email or phone number) together with a password.

**Function Description**

- **Actors / Roles**: GUEST holding an existing account.
- **Purpose**: Authenticate with an email or phone number and a password, and obtain an access token plus a refresh token, unless two-factor authentication is enabled.
- **Interface**: Sign-in form with an identifier input (email or phone), a Password input, and a "Forgot password" link to Reset Password. Same screen carries the Google sign-in entry point.
- **Data Processing**: Resolves the identifier, checks account status, compares the password against the stored hash, records the sign-in, resolves the active workspace, and issues an access token plus a rotating refresh token; when 2FA is enabled, issues a challenge token instead.

**Screen Layout**

Figure — Sign-in Screen:

- Identifier input (email or phone), Password input with reveal toggle, "Forgot password" link.
- Submit button "Sign in".
- Divider "Or continue with", Google sign-in button.
- On success: stores access token, loads profile, navigates to Dashboard; toast **MSG11**.
- When 2FA required: stores twoFactorToken in sessionStorage, navigates to /2fa-verify without storing any access token.

**Function Details**
- **Data Specifications**
    - **Input required**: identifier (email or phone), password.
    - **Input optional**: none.
    - **System data**: userId, role, status, twoFactorEnabled, lastLoginAt, workspaceId, accessToken, refreshToken.
    - **Output**: access token, token type, expiry, a flag for 2FA required, refresh token as HttpOnly cookie. When 2FA required: a two-factor challenge token instead of access/refresh tokens.

- **Business Rules**
    - **BR-05**: Anti-enumeration. Unknown identifier, wrong password, or account with no password all return the same 401 INVALID_CREDENTIALS.
    - **BR-06**: Suspended account -> 403 ACCOUNT_SUSPENDED. Deactivated account -> 403 ACCOUNT_DEACTIVATED. Checked before password comparison.
    - **BR-07**: Identifier auto-detected as email or phone; email matched case-insensitively, phone normalized before lookup.
    - **BR-08**: Access token JWT RS256, 15-minute TTL. Refresh token HttpOnly cookie only, 30-day TTL. When 2FA enabled, no access/refresh token issued at this step; a challenge token is returned instead.
    - **BR-12**: Refresh token jti checked against a blacklist; a token issued before the latest password change is rejected. Refresh accepted only via cookie. Missing/stale token -> 401 REFRESH_TOKEN_INVALID; blacklisted token -> 401 REFRESH_TOKEN_BLACKLISTED. Successful refresh rotates the token.

- **Validation**
    - identifier empty -> Display: **MSG02**
    - password empty -> Display: **MSG02**
    - identifier not a valid email or phone format -> Display: **MSG04**

**Functionalities**
- **Normal Flow**
    1. The Guest opens /login and enters the identifier and password.
    2. The system resolves the identifier to an account and checks the account status allows sign-in.
    3. The system compares the submitted password with the stored hash.
    4. With 2FA disabled, the system records the sign-in, resolves the active workspace, and issues an access token and a refresh token.
    5. The system returns the tokens and sets the refresh token cookie.
    6. The screen stores the access token, loads the profile, navigates to the Dashboard; toast **MSG11**.

- **Abnormal Cases**
    - 2.a1: Unknown identifier, wrong password, or no password (BR-05) -> 401 INVALID_CREDENTIALS, toast **MSG07**. 2.a2: The Guest retries or uses "Forgot password".
    - 2.b1: Account status not ACTIVE/DEACTIVATED (BR-06) -> 403 ACCOUNT_SUSPENDED, toast **MSG09**. 2.b2: The Guest contacts support.
    - 2.c1: Account DEACTIVATED (BR-06) -> 403 ACCOUNT_DEACTIVATED, toast **MSG09**. 2.c2: The Guest reactivates the account or contacts support.
    - 4.a1: 2FA enabled (BR-08) -> no access/refresh token issued; challenge token returned instead. 4.a2: The screen continues on the two-factor code screen.
    - 5.a1: Refresh without cookie, or unusable/stale token (BR-12) -> 401 REFRESH_TOKEN_INVALID, toast **MSG22**. 5.a2: Refresh with a blacklisted token (BR-12) -> 401 REFRESH_TOKEN_BLACKLISTED, toast **MSG22**; either way the screen redirects to /login.

**Post-Conditions**

- The sign-in is recorded and last sign-in time updated.
- An access token and refresh token cookie are issued when 2FA is disabled.
- A two-factor challenge token, and no tokens, is issued when 2FA is enabled.
