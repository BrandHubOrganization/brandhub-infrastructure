# 3.2.3 Sign In With Google OAuth

## Function Trigger
Begins when a Guest activates the "Sign in with Google" button on the sign-in or registration screen, which sends the browser to the Google authorization entry point of the application.

## Function Description
- **Actors / Roles:** GUEST. The same mechanism also serves a signed-in user who links Google to an existing account from settings, which is outside this feature.
- **Purpose:** Let a user sign in with an existing Google account, create a local account on first use, and honour two-factor authentication when it is enabled.
- **Interface:** A "Sign in with Google" button on both the sign-in and the registration screen. The flow is a redirect handshake: the browser leaves the application for Google's consent screen and returns to the application, which then sends the browser back to the sign-in screen carrying the result.
- **Data Processing:** The system issues and stores a single-use state value, exchanges the authorization code for a Google access token, fetches the Google profile, links the Google identity to an existing account or creates a new verified one, checks the account status, and then issues tokens or a two-factor challenge.

## Screen Layout
Figure — Google sign-in entry and return:
- Entry: "Sign in with Google" button on /login and /register.
- Return: the browser lands on /oauth-callback, which reads the token from the address fragment, loads the profile and continues to the Dashboard / Agency list.
- When two-factor authentication is enabled the browser lands on the two-factor code screen (3.2.7) instead.

## Function Details
### Data Specifications
- **Input required:** nothing entered by the user; the authorization code and the state value returned by Google.
- **Input optional:** none.
- **System data:** providerId, email, emailVerifiedAt, passwordHash, twoFactorEnabled, status, lastLoginAt, workspaceId, accessToken, refreshToken.
- **Output:** on success the access token is carried in the return address and the refresh token is set as an HTTP-only cookie. When two-factor authentication is enabled a two-factor challenge token is carried instead and no cookie is set.

### Business Rules
- **BR-09:** The state value is single-use, stored for 10 minutes and removed on first use (CSRF protection). A missing, mismatched or expired state → 400 OAUTH_STATE_INVALID and the browser is returned to the sign-in screen with a generic error.
- **BR-10:** Email is the linking anchor for OAuth — an existing account matching the Google email address is reused and the Google identity is linked to it, so no duplicate account is created; no match creates a new account. A failed token exchange, or a Google profile without an email address or with an unverified email address → 400 OAUTH_CODE_INVALID and the browser is returned with a generic error.
- **BR-11:** One (provider, providerId) pair links to exactly one user; on first use of a Google identity, a local account is created with no password until `/set-password` and the email address already verified.
- **BR-06:** A suspended or deactivated account → 403 ACCOUNT_SUSPENDED and the browser is returned with a generic error.
- **BR-08:** When two-factor authentication is enabled, no access token and no refresh token are issued at this step; Google sign-in does not bypass it, and a two-factor challenge token is returned instead so the user completes Two-Factor Authentication (3.2.7). This applies to every sign-in method.

### Validation
- The user cancels consent or Google returns an error → the return carries no authorization code and the browser is sent back with a generic error (Toast MSG12), without any further call to Google.
- The Google profile has no email address, or the email address is not verified → the sign-in is rejected with a generic error (Toast MSG12).

## Functionalities
### Normal Flow
1. The Guest activates "Sign in with Google" on /login or /register.
2. The system issues a single-use state value valid for 10 minutes and sends the browser to Google's consent screen.
3. The user authenticates with Google and grants consent.
4. Google returns the browser to the application with an authorization code and the state value.
5. The system validates the state value, exchanges the code for a Google access token and fetches the Google profile.
6. The system links the Google identity to an existing account with the same email address, or creates a new verified account with no password.
7. The system checks the account status and, with two-factor authentication disabled, records the sign-in and issues an access token and a refresh token.
8. The system sends the browser back to the application with the access token and sets the refresh token cookie.
9. The application reads the token, loads the profile and continues to the Dashboard / Agency list; toast MSG11.

### Abnormal Cases
- 4.a1: The user cancels consent or Google returns an error → the return carries no authorization code; the browser is sent back with a generic error, toast MSG12, and no further call to Google is made. 4.a2: The Guest retries "Sign in with Google" from /login.
- 5.a1: The state value is missing, already used or expired, or belongs to another provider (BR-09) → 400 OAUTH_STATE_INVALID, browser sent back with toast MSG12. 5.a2: The Guest retries "Sign in with Google" from /login.
- 5.b1: The token exchange fails, or the Google profile has no email address or an unverified email address (BR-10) → 400 OAUTH_CODE_INVALID, browser sent back with toast MSG12. 5.b2: The Guest retries "Sign in with Google" from /login, or signs in with email/password instead.
- 7.a1: The account is suspended or deactivated (BR-06) → 403 ACCOUNT_SUSPENDED, browser sent back with toast MSG09. 7.a2: The Guest contacts support to resolve the account status.
- 7.b1: Two-factor authentication is enabled on the account (BR-08) → no access token and no refresh token are issued; a two-factor challenge token is returned instead. 7.b2: The browser is sent to the two-factor code screen (3.2.7) for the Guest to complete sign-in.

## Post-Conditions
- The Google identity is linked to a local account, created on first use with the email address already verified and with no password.
- The sign-in is recorded and the last sign-in time is updated, unless the user still has to complete two-factor verification.
- An access token and a refresh token cookie are issued, or a two-factor challenge token when two-factor authentication is enabled.
