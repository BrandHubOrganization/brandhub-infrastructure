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
- **BR-01:** The state value is single-use, stored for 10 minutes and removed on first use. A missing, mismatched or expired state → 400 OAUTH_STATE_INVALID and the browser is returned to the sign-in screen with a generic error.
- **BR-02:** A failed token exchange, or a Google profile without an email address or with an unverified email address → 400 OAUTH_CODE_INVALID and the browser is returned with a generic error.
- **BR-03:** On first use of a Google identity, a local account is created with no password and the email address already verified. An existing account matching the Google email address is reused and the Google identity is linked to it, so no duplicate account is created.
- **BR-04:** A suspended or deactivated account → 403 ACCOUNT_SUSPENDED and the browser is returned with a generic error.
- **BR-05:** When two-factor authentication is enabled, Google sign-in does not bypass it: no access token and no refresh token are issued, and a two-factor challenge token is returned so the user completes Two-Factor Authentication (3.2.7). This applies to every sign-in method.
- **BR-06:** The access token is carried in the fragment of the return address, never as a query parameter.

### Validation
- The user cancels consent or Google returns an error → the return carries no authorization code and the browser is sent back with a generic error, without any further call to Google.
- The Google profile has no email address, or the email address is not verified → the sign-in is rejected with a generic error.

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
9. The application reads the token, loads the profile and continues to the Dashboard / Agency list.

### Abnormal Cases
- The user cancels consent or Google returns an error → the browser is sent back with a generic error and no further call to Google is made.
- The state value is missing, already used or expired, or belongs to another provider → the browser is sent back with a generic error.
- The token exchange fails, or the Google profile has no email address or an unverified email address → the browser is sent back with a generic error.
- The account is suspended or deactivated → the browser is sent back with a generic error.
- Two-factor authentication is enabled → the browser is sent to the two-factor code screen (3.2.7) and no tokens are issued.

## Post-Conditions
- The Google identity is linked to a local account, created on first use with the email address already verified and with no password.
- The sign-in is recorded and the last sign-in time is updated, unless the user still has to complete two-factor verification.
- An access token and a refresh token cookie are issued, or a two-factor challenge token when two-factor authentication is enabled.
