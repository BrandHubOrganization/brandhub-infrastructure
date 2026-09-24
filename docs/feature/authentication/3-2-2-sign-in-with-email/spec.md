# 3.2.2 Sign In With Email

## Function Trigger
Begins when a Guest with an existing account visits /login and submits an identifier, either an email address or a phone number, together with a password.

## Function Description
- **Actors / Roles:** GUEST holding an existing account.
- **Purpose:** Authenticate with an email address or phone number and a password, and obtain an access token plus a refresh token, without a further one-time code unless two-factor authentication is enabled.
- **Interface:** Sign-in form with an identifier input (email address or phone number), a Password input and a "Forgot password" link leading to Reset Password (3.2.4). The same screen also carries the Google sign-in entry point (3.2.3).
- **Data Processing:** The system resolves the identifier, checks the account status, compares the password against the stored hash, records the sign-in, resolves the active workspace and issues an access token together with a rotating refresh token; when two-factor authentication is enabled it issues a challenge token instead of the tokens.

## Screen Layout
Figure — Sign-in Screen (/login):
- Center: identifier input (email address or phone number), password input.
- Links: "Forgot password" leading to Reset Password (3.2.4), and the Google sign-in entry point (3.2.3).
- On success the screen stores the access token, loads the profile and navigates to the Dashboard / Agency list.
- When two-factor authentication is enabled the screen moves to the two-factor code screen (3.2.7) instead.

## Function Details
### Data Specifications
- **Input required:** identifier (email address or phone number), password.
- **Input optional:** none.
- **System data:** userId, role, status, twoFactorEnabled, lastLoginAt, workspaceId, accessToken, refreshToken.
- **Output:** access token, token type, expiry in seconds, a flag stating whether two-factor verification is required, and a refresh token delivered as an HTTP-only cookie. When two-factor verification is required, a two-factor challenge token is returned instead of the access token and the refresh token.

### Business Rules
- **BR-01:** When no account matches the identifier, or the password does not match, or the account has no password (created through Google only), the same answer is returned: 401 INVALID_CREDENTIALS. The answer never reveals whether the email address or the phone number exists.
- **BR-02:** The email part of the identifier is matched case-insensitively; the phone part is normalized before lookup.
- **BR-03:** An inactive account, or any status other than ACTIVE or DEACTIVATED → 403 ACCOUNT_SUSPENDED. A status of DEACTIVATED → 403 ACCOUNT_DEACTIVATED.
- **BR-04:** When two-factor authentication is enabled no access token and no refresh token are issued at this step; a two-factor challenge token is returned instead and the refresh cookie is not set.
- **BR-05:** A refresh is accepted only from the HTTP-only cookie, never from the request body. A missing cookie or an unusable token → 401 REFRESH_TOKEN_INVALID. A token invalidated by sign-out → 401 REFRESH_TOKEN_BLACKLISTED. A token issued before the most recent password change → 401 REFRESH_TOKEN_INVALID. A successful refresh rotates the refresh token.

### Validation
- Empty identifier or empty password → error message.
- The identifier is neither a valid email format nor a valid phone number → error message.

## Functionalities
### Normal Flow
1. The Guest opens /login and enters the identifier and the password.
2. The system resolves the identifier to an account and checks that the account status allows sign-in.
3. The system compares the submitted password with the stored password hash.
4. With two-factor authentication disabled the system records the sign-in, resolves the active workspace and issues an access token and a refresh token.
5. The system returns the tokens and sets the refresh token cookie.
6. The screen stores the access token, loads the profile and navigates to the Dashboard / Agency list.

### Abnormal Cases
- Unknown identifier, wrong password, or an account without a password → 401 INVALID_CREDENTIALS, without revealing which identifier exists.
- Suspended account, or any status other than ACTIVE or DEACTIVATED → 403 ACCOUNT_SUSPENDED.
- Deactivated account → 403 ACCOUNT_DEACTIVATED.
- Two-factor authentication enabled → no tokens are issued and the screen continues on the two-factor code screen (3.2.7).
- Refresh requested without the cookie, or with an unusable, blacklisted or stale token → 401 REFRESH_TOKEN_INVALID or 401 REFRESH_TOKEN_BLACKLISTED.

## Post-Conditions
- The sign-in is recorded and the last sign-in time is updated.
- An access token and a refresh token cookie are issued when two-factor authentication is disabled.
- A two-factor challenge token, and no tokens, is issued when two-factor authentication is enabled.
