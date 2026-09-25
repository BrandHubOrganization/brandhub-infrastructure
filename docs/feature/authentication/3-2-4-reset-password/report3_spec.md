**3.2.4 Reset Password**

**Function Trigger**

Begins when a user who forgot the password opens /forgot-password and submits an email address.

**Function Description**

- **Actors / Roles**: Unauthenticated USER who cannot sign in because the password is forgotten.
- **Purpose**: Restore access to the account by email through a single-use reset link, without revealing whether a given email is registered, and force sign-in again on every device once the password is changed.
- **Interface**: /forgot-password (email input) and /reset-password?token=... (new password + confirm password).
- **Data Processing**: forgot-password always returns 200 regardless of whether the email exists; if it exists, invalidates any earlier reset token, generates a new single-use token, and emails it. reset-password consumes the token atomically, hashes the new password, updates the last-password-change time, and writes an audit log entry.

**Screen Layout**

Figure — Forgot Password / Reset Password screens:

- /forgot-password: email input, submit button. On success the form is replaced by a confirmation panel; the UI never says whether the email was actually found.
- /reset-password: reads token from the URL; if absent, redirects to /forgot-password. New password input with strength meter, confirmation input, submit button.
- Toasts: **MSG15** on forgot-password success (always), **MSG16**/**MSG17** on reset-password failure (invalid/expired vs. already-used token), **MSG18** on reset-password success, then redirected to /login.

**Function Details**
- **Data Specifications**
    - **Input required**: email (forgot-password step); token, newPassword (reset step).
    - **Input optional**: confirmPassword — client-side check only, never sent to the server.
    - **System data**: userId, email, passwordHash, lastPasswordChange, reset token (TTL up to 1 hour), reverse-index of the currently valid token per user.
    - **Output**: no payload, 200, for both endpoints; the response never distinguishes success/failure cases that must stay silent.

- **Business Rules**
    - **BR-13**: forgot-password always returns 200 whether or not the email exists. When it exists, any earlier token for that user is deleted first, then a new single-use token is generated with TTL up to 1 hour; only the most recently issued token is ever valid. reset-password with a missing/expired/superseded token -> 400 RESET_TOKEN_INVALID; a token already consumed -> 400 RESET_TOKEN_USED; a token for a deleted user -> 400 RESET_TOKEN_INVALID.
    - **BR-02**: New password must meet policy (min 8 characters, at least 1 digit); stored as a BCrypt hash.
    - **BR-12**: After a successful reset, every refresh token issued before the change is rejected on its next use, forcing sign-in again on every device.

- **Validation**
    - email empty on /forgot-password -> Display: **MSG02**
    - email invalid format -> Display: **MSG04**
    - newPassword missing, under 8 characters, or missing a digit -> Display: **MSG05**
    - confirmPassword mismatch -> Display: **MSG06**
    - token missing from URL -> client redirects to /forgot-password, no server call

**Functionalities**
- **Normal Flow**
    1. The user opens /forgot-password and submits the email address.
    2. The system looks up the account by normalized email.
    3. If found, the system deletes any earlier reset token, generates a new single-use token, stores it with TTL up to 1 hour, and sends the reset email.
    4. The endpoint returns 200 regardless of whether the account was found. Toast **MSG15**.
    5. The user opens the reset link, lands on /reset-password?token=..., and enters the new password and confirmation.
    6. The system resolves and atomically deletes the reset token, hashes and saves the new password, and writes an audit log entry.
    7. The endpoint returns 200. Toast **MSG18**; the user is redirected to /login.
    8. Every refresh token issued before this reset is rejected on its next use, forcing sign-in again on that device.

- **Abnormal Cases**
    - 1.a1: email empty -> Display: **MSG02**. 1.a2: The user fills in the field and resubmits.
    - 1.b1: email invalid format -> Display: **MSG04**. 1.b2: The user corrects the format and resubmits.
    - 2.a1: Email does not match any account (BR-13) -> still 200, toast **MSG15**, no email sent. 2.a2: The user checks the inbox.
    - 6.a1: Token missing, expired, or superseded (BR-13) -> 400 RESET_TOKEN_INVALID, toast **MSG16**. 6.a2: The user requests a new reset link.
    - 6.b1: Token already consumed (BR-13) -> 400 RESET_TOKEN_USED, toast **MSG17**. 6.b2: The user requests a new reset link.
    - 6.c1: Token decodes to a deleted account -> 400 RESET_TOKEN_INVALID, toast **MSG16**. 6.c2: The user requests a new reset link.
    - 6.d1: newPassword fails the policy (BR-02) -> Display: **MSG05**. 6.d2: The user corrects the password and resubmits.
    - 6.e1: confirmPassword mismatch -> Display: **MSG06**, submit blocked. 6.e2: The user re-types the confirmation.

**Post-Conditions**

- On a successful reset, passwordHash is replaced and lastPasswordChange is set; an audit log row exists; the consumed token and its reverse-index are deleted.
- On any forgot-password call, exactly one valid reset token exists per account at a time; the response is always 200.
- Refresh tokens issued before the reset are rejected on their next use (BR-12), independent of any explicit logout.
