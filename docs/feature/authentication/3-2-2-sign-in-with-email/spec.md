# 3.2.2 Sign In With Email

| | |
|---|---|
| FR Code | 3.2.2 |
| Feature | Sign In with Email/Phone + Password |
| Domain | Authentication (FR 3.2) |
| Role | GUEST holding an existing account |
| Routes | `POST /api/v1/auth/login`, `POST /api/v1/auth/refresh` |
| Related FRs | 3.2.3 Google Sign-In, 3.2.4 Reset Password, 3.2.7 Two-Factor Verify, 3.2.8 Logout (separate FR, not covered here) |
| Document status | Implemented |

## Function Trigger
Begins when a Guest with an existing account visits /login and submits an identifier, either an email address or a phone number, together with a password.

## Function Description
- **Actors / Roles:** GUEST holding an existing account.
- **Purpose:** Authenticate with an email address or phone number and a password, and obtain an access token plus a refresh token, without a further one-time code unless two-factor authentication is enabled.
- **Interface:** Sign-in form with an identifier input (email address or phone number), a Password input and a "Forgot password" link leading to Reset Password (3.2.4). The same screen also carries the Google sign-in entry point (3.2.3).
- **Data Processing:** The system resolves the identifier, checks the account status, compares the password against the stored hash, records the sign-in, resolves the active workspace and issues an access token together with a rotating refresh token; when two-factor authentication is enabled it issues a challenge token instead of the tokens.

## Screen Layout
Figure — Sign-in Screen (`LoginPage.tsx`, route `/login`):
- Split layout: brand panel on the left (`AuthBrandPanel`), form on the right, with a mobile header shown on small screens.
- A "Sign in / Sign up" tab pair above the form; "Sign up" navigates to `/register`.
- Identifier input labelled "Email" with placeholder `hello@company.com / 0912 345 678` (single field, accepts either email or phone), and a password input (`PasswordInput`, masked with reveal toggle) with a "Forgot password" link next to its label leading to `/forgot-password` (Reset Password, 3.2.4).
- Submit button "Sign in" (loading state while the request is in flight).
- Divider "Or continue with", then a Google sign-in icon button linking to the OAuth entry point (3.2.3) via `oauthUrl("google")`.
- Terms of Service / Privacy Policy notice below the form; a `DevQuickLogin` helper is shown (dev/test builds only).
- On success: the client stores the access token, calls `GET /api/v1/users/me` to load the real profile, then navigates to the page the user was redirected from (or the Dashboard / Agency list) and shows toast MSG11.
- When two-factor authentication is required: the client stores the `twoFactorToken` in `sessionStorage` and navigates to `/2fa-verify` (3.2.7) without storing any access token.

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

## Out of Scope
- Verifying the two-factor code and completing sign-in after the challenge — see FR 3.2.7 Two-Factor Verify.
- Ending a session / clearing the refresh cookie — see FR 3.2.8 Logout.
- Google OAuth sign-in — see FR 3.2.3.

## References
[AuthController.java](../../../../../brandhub-business-service/src/main/java/com/brandhub/business/controller/AuthController.java), [AuthServiceImpl.java](../../../../../brandhub-business-service/src/main/java/com/brandhub/business/service/impl/AuthServiceImpl.java), Section5_Requirement_Appendix.md (BR-05, BR-06, BR-07, BR-08, BR-12; MSG02, MSG04, MSG07, MSG09, MSG11, MSG22)
