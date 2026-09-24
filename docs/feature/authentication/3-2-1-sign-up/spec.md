# 3.2.1 Sign Up (Email)

## Function Trigger
Begins when an unauthenticated Guest visits /register and submits the sign-up form with an email address, a password and a full name.

## Function Description
- **Actors / Roles:** GUEST. Creates a new account with the default role USER.
- **Purpose:** Register a new account with an email address and a password, prove ownership of the email address with a one-time code, and hand the user over to Sign In.
- **Interface:** Registration form with Full Name, Email, Password and Confirm Password inputs. After a successful submission the screen moves to OTP Verification (3.2.6), reusing the shared code entry component.
- **Data Processing:** The system normalizes the email address, hashes the password, generates a six-digit one-time code valid for 10 minutes, creates the account with the default role, and dispatches the verification email synchronously inside the same transaction.

## Screen Layout
Figure — Registration Screen (/register):
- Center: Full Name input, Email input, Password input with a show/hide toggle, Confirm Password input.
- Password strength is validated in real time (at least 8 characters, at least one digit).
- After a successful submission the screen switches to OTP Verification (3.2.6) with a resend countdown.
- Footer: a link to Sign In for users who already have an account.

## Function Details
### Data Specifications
- **Input required:** email, password, fullName.
- **Input optional:** confirmPassword is verified on the client only and is never submitted.
- **System data:** userId, role (USER), status, emailVerifiedAt, otpCode, otpExpiry, passwordHash, createdAt.
- **Output:** userId of the newly created account.

### Business Rules
- **BR-01:** The email address is normalized to lower case and trimmed before it is stored and before the uniqueness check, so "User@gmail.com" and "user@gmail.com" are the same account. A duplicate returns 409 EMAIL_ALREADY_EXISTS.
- **BR-02:** Password policy: at least 8 characters and at least one digit, hashed with BCrypt; the plain password is never stored, logged or returned.
- **BR-03:** The account is created immediately at registration with emailVerifiedAt empty and only becomes verified once the correct one-time code is submitted (3.2.6). Verification does not sign the user in; the user signs in separately afterwards.
- **BR-04:** The one-time code is six digits, valid for 10 minutes, delivered by email.

### Validation
- Empty required field → error message.
- Invalid email format → 400 VALIDATION_ERROR.
- Password does not meet the policy (fewer than 8 characters, or no digit) → 400 VALIDATION_ERROR.

## Functionalities
### Normal Flow
1. The Guest opens /register and fills in the email address, password, confirm password and full name.
2. The Guest submits the form.
3. The system normalizes the email address and checks that it is not already registered.
4. The system hashes the password, creates the account with the default role and generates a six-digit one-time code valid for 10 minutes.
5. The system sends the code to the registered email address.
6. The system returns the new userId and the screen moves to OTP Verification (3.2.6).

### Abnormal Cases
- The email address is already registered, including a different letter case such as USER@gmail.com while user@gmail.com exists and is still unverified → 409 EMAIL_ALREADY_EXISTS. The existing account is not modified and no code is re-sent automatically; a new code must be requested explicitly (3.2.6).
- The email address or the password fails validation → 400 VALIDATION_ERROR.
- The one-time code expires before it is entered → the account is kept and a new code can be requested through the resend action, rate-limited to one request every 60 seconds (3.2.6).

## Post-Conditions
- An account record exists with the default role USER and emailVerifiedAt empty.
- A one-time code valid for 10 minutes is stored and the verification email has been dispatched.
- No session is established; the user is not signed in.
