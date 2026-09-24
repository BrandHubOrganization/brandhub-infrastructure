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
- **BR-05:** Anti-enumeration — when no account matches the identifier, or the password does not match, or the account has no password (created through Google only), the same answer is returned: 401 INVALID_CREDENTIALS. The answer never reveals whether the email address or the phone number exists.
- **BR-06:** Suspended / inactive account → 403 ACCOUNT_SUSPENDED, checked before password comparison. A status of DEACTIVATED → 403 ACCOUNT_DEACTIVATED.
- **BR-07:** Login accepts an identifier field auto-detected as email (contains "@") or phone (E.164); the email part is matched case-insensitively, the phone part is normalized before lookup.
- **BR-08:** Access token is JWT RS256 with a 15-minute TTL; refresh token is an HttpOnly cookie only, 30-day TTL, never in the JSON body. When two-factor authentication is enabled no access token and no refresh token are issued at this step; a two-factor challenge token is returned instead and the refresh cookie is not set.
- **BR-12:** Refresh token `jti` is checked against a blacklist; a token issued before the most recent password change is rejected. A refresh is accepted only from the HTTP-only cookie, never from the request body. A missing cookie or an unusable/stale token → 401 REFRESH_TOKEN_INVALID. A blacklisted token → 401 REFRESH_TOKEN_BLACKLISTED. A successful refresh rotates the refresh token.

### Validation
- identifier empty → Display: MSG02
- password empty → Display: MSG02
- identifier neither a valid email format nor a valid phone number → Display: MSG04

## Functionalities
### Normal Flow
1. The Guest opens /login and enters the identifier and the password.
2. The system resolves the identifier to an account and checks that the account status allows sign-in.
3. The system compares the submitted password with the stored password hash.
4. With two-factor authentication disabled the system records the sign-in, resolves the active workspace and issues an access token and a refresh token.
5. The system returns the tokens and sets the refresh token cookie.
6. The screen stores the access token, loads the profile and navigates to the Dashboard / Agency list; toast MSG11.

### Abnormal Cases
- 2.a1: Unknown identifier, wrong password, or an account without a password (BR-05) → 401 INVALID_CREDENTIALS, toast MSG07; the identifier is never confirmed to exist. 2.a2: The Guest re-enters the credentials or uses "Forgot password" (3.2.4).
- 2.b1: The account status is anything other than ACTIVE or DEACTIVATED (BR-06) → 403 ACCOUNT_SUSPENDED, toast MSG09. 2.b2: The Guest contacts support to resolve the account status.
- 2.c1: The account status is DEACTIVATED (BR-06) → 403 ACCOUNT_DEACTIVATED, toast MSG09. 2.c2: The Guest reactivates the account (3.2.9) or contacts support.
- 4.a1: Two-factor authentication is enabled on the account (BR-08) → no access token and no refresh token are issued; a two-factor challenge token is returned instead. 4.a2: The screen continues on the two-factor code screen (3.2.7) for the Guest to complete sign-in.
- 5.a1: Refresh requested without the cookie, or with an unusable or stale token (BR-12) → 401 REFRESH_TOKEN_INVALID, toast MSG22. 5.a2: Refresh requested with a token invalidated by sign-out (BR-12) → 401 REFRESH_TOKEN_BLACKLISTED, toast MSG22; either way the screen redirects the Guest back to /login.

## Post-Conditions
- The sign-in is recorded and the last sign-in time is updated.
- An access token and a refresh token cookie are issued when two-factor authentication is disabled.
- A two-factor challenge token, and no tokens, is issued when two-factor authentication is enabled.
