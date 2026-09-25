**3.2.1 Sign Up (Email + OTP Verification)**

**Function Trigger**

Begins when an unauthenticated Guest visits /register or /verify-otp after submitting the registration form.

**Function Description**

- **Actors / Roles**: GUEST. Creates a new user account with default role USER.
- **Purpose**: Register a new account, verify email ownership via a one-time code, and hand the user to Sign In.
- **Interface**: Registration form with Full Name, Email, Password, Confirm Password; OTP Verification screen with a 6-digit code input and a Resend link.
- **Data Processing**: business-service validates email format and password policy, checks database uniqueness (BR-01), hashes password via BCrypt cost=12 (BR-02), creates user record, generates a 6-digit OTP with 10-minute expiry (BR-03), and dispatches the OTP email.

**Screen Layout**

Figure — Registration Screen:

- Center: Text input for Full Name, Text input for Email, Password input with strength indicator, Confirm Password input.
- Buttons: Primary button "Create Account"; Divider "or"; Button "Sign up with Google".
- Footer: Text link "Already have an account? Log in".

Figure — OTP Verification Screen:

- Center: 6 single-digit inputs for the OTP code, Verify button, Resend link with cooldown countdown.

**Function Details**
- **Data Specifications**
    - **Input required (register)**: email, password, fullName.
    - **Input required (verify-otp)**: email, otpCode.
    - **Input optional**: confirmPassword (client-side check only, never sent to the server).
    - **System data**: userId (UUID), defaultRole (USER), status (ACTIVE), otpCode, otpExpiry, createdAt (timestamp).
    - **Output (register)**: userId.
    - **Output (verify-otp)**: no payload body.

- **Business Rules**
    - **BR-01**: Email is unique, case-insensitive. Duplicate -> 409 EMAIL_ALREADY_EXISTS.
    - **BR-02**: Password policy: minimum 8 characters + at least 1 digit; hashed with BCrypt cost=12; password is never logged or returned.
    - **BR-03**: OTP is 6 digits, TTL 10 minutes, single-use; cleared after 5 failed attempts.
    - **BR-04**: Resend OTP has a 60-second cooldown per email.

- **Validation**
    - Empty required fields -> Display: **MSG02**
    - Invalid email format -> Display: **MSG04**
    - Password does not meet policy -> Display: **MSG05**
    - Passwords do not match -> Display: **MSG06**
    - Email already registered -> Display: **MSG08**
    - OTP wrong or expired -> Display: **MSG20**

**Functionalities**
- **Normal Flow**
    1. The user navigates to /register and fills in Full Name, Email, Password, and Confirm Password.
    2. The user clicks "Create Account".
    3. The system validates inputs and checks that email is unique in the database.
    4. The system hashes the password with BCrypt cost=12 and creates a new user record.
    5. The system generates a 6-digit OTP with a 10-minute expiry and sends it by email.
    6. The system displays **MSG10** and redirects the user to the OTP Verification screen.
    7. The user enters the OTP code and clicks Verify.
    8. The system marks the email verified and redirects the user to Sign In.

- **Abnormal Cases**
    - 3.a1: If the email is already registered, the system displays **MSG08**. 3.a2: The user switches to login or inputs another email.
    - 3.b1: If password does not meet policy, the system displays **MSG05**. 3.b2: The user enters a valid password.
    - 7.a1: If the OTP is wrong or expired, the system displays **MSG20**. 7.a2: The user retries or requests Resend.

**Post-Conditions**

- User record created in users collection with status = ACTIVE and role = USER.
- OTP recorded with a 10-minute expiry until verified.
- Email marked verified after successful OTP check.
