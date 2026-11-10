**3.2.3 Sign In with Google OAuth**

**Function Trigger**

Begins when a Guest activates "Sign in with Google" on the sign-in or registration screen, sending the browser to GET /api/v1/auth/oauth/google.

**Function Description**

- **Actors / Roles**: GUEST. The same handshake also serves a signed-in user linking Google to an existing account, outside this feature.
- **Purpose**: Let a user sign in with Google, create a local account on first use, and honour two-factor authentication when enabled.
- **Interface**: "Sign in with Google" button on the sign-in and registration screens. A redirect handshake: the browser leaves for Google's consent screen and returns to the application's callback route.
- **Data Processing**: Issues and stores a single-use state value, redirects to Google; on callback, validates the state, exchanges the code for a Google access token, fetches the Google profile, links or creates the local account, checks account status, then issues tokens or a two-factor challenge.

**Screen Layout**

Figure — Google sign-in entry and return:

- Entry: "Sign in with Google" button on /login and /register.
- Return: browser lands on /oauth-callback; reads token from the URL fragment, stores it, loads the profile, navigates to Dashboard; toast **MSG11** on success.
- If callback carries error=ACCOUNT_SUSPENDED: dedicated toast (account suspended), navigates to /login.
- If callback carries any other error, or no token: clears partial auth state, shows a generic OAuth-failure toast **MSG12**, navigates to /login.
- When 2FA is enabled: browser lands on the two-factor code screen instead, carrying twoFactorToken as a query parameter.

**Function Details**
- **Data Specifications**
    - **Input required**: none entered by the user; Google supplies code and state (or error) on callback.
    - **Input optional**: none.
    - **System data**: providerId, email, emailVerifiedAt, passwordHash (absent for OAuth-only users), twoFactorEnabled, status, lastLoginAt, workspaceId, accessToken, refreshToken, twoFactorToken.
    - **Output**: on success, a redirect carrying the access token in the URL fragment plus a refresh token cookie. When 2FA enabled, a redirect to the two-factor screen with a challenge token and no cookie. On a suspended/inactive account, a redirect with error=ACCOUNT_SUSPENDED. On any other failure, a redirect with error=oauth_failed.

- **Business Rules**
    - **BR-09**: The state value is single-use, stored for 10 minutes, deleted on first read (CSRF protection). Missing/expired/unknown state -> 400 OAUTH_STATE_INVALID, generic error toast **MSG12**.
    - **BR-10**: Email is the linking anchor for OAuth; an existing account with the same email is reused and linked, no duplicate account created. Failed token exchange, or a Google profile without id/email or unverified email -> 400 OAUTH_CODE_INVALID, toast **MSG12**.
    - **BR-11**: One (provider, providerId) pair maps to exactly one user. First use creates a local account with email already verified and no password.
    - **BR-06**: Suspended or inactive account -> 403 ACCOUNT_SUSPENDED. Redirected distinctly to a dedicated error, separate from the generic OAuth-failure toast.
    - **BR-08**: When 2FA is enabled, no access/refresh token issued; a two-factor challenge token is returned instead, same as email sign-in.

- **Validation**
    - User cancels consent or Google returns an error -> no authorization code present -> generic error toast **MSG12**, no further call to Google.
    - Google profile has no id/email, or email not verified -> 400 OAUTH_CODE_INVALID, toast **MSG12**.
    - A network error calling Google -> treated as a generic login failure, toast **MSG12**.

**Functionalities**
- **Normal Flow**
    1. The Guest activates "Sign in with Google" on /login or /register.
    2. The system generates a single-use state value, stores it for 10 minutes, and redirects the browser to Google's consent screen.
    3. The user authenticates with Google and grants consent.
    4. Google redirects the browser back to the application's callback route with code and state.
    5. The system validates the authorization code is present, consumes the state, exchanges the code for a Google access token, and fetches the Google profile.
    6. The system links the Google identity to an existing account with the same email, or creates a new verified account with no password.
    7. The system checks the account status and, with 2FA disabled, records the sign-in, resolves the active workspace, and issues an access token and a refresh token.
    8. The system sets the refresh token cookie and redirects to the callback page carrying the access token.
    9. The screen reads the token, loads the profile, stores it, shows toast **MSG11**, and navigates to the Dashboard.

- **Abnormal Cases**
    - 4.a1: The user cancels consent or Google returns an error -> generic error toast **MSG12**, no further call to Google. 4.a2: The Guest retries "Sign in with Google".
    - 5.a1: The state is missing, already used/expired, or belongs to another provider (BR-09) -> 400 OAUTH_STATE_INVALID, toast **MSG12**. 5.a2: The Guest retries.
    - 5.b1: Token exchange fails, or the Google profile has no email or an unverified email (BR-10) -> 400 OAUTH_CODE_INVALID, toast **MSG12**. 5.b2: The Guest retries, or signs in with email/password instead.
    - 5.c1: A network error occurs while calling Google -> generic failure redirect, toast **MSG12**. 5.c2: The Guest retries.
    - 7.a1: The account is suspended or deactivated (BR-06) -> 403 ACCOUNT_SUSPENDED, dedicated suspended-account toast. 7.a2: The Guest contacts support.
    - 7.b1: 2FA is enabled on the account (BR-08) -> no access/refresh token issued; a challenge token is returned instead. 7.b2: The browser is sent to the two-factor code screen to complete sign-in.

**Post-Conditions**

- The Google identity is linked to a local account, created on first use with email already verified and no password.
- The sign-in is recorded, unless the user still has to complete two-factor verification.
- An access token and a refresh-token cookie are issued, or a two-factor challenge token when 2FA is enabled.
