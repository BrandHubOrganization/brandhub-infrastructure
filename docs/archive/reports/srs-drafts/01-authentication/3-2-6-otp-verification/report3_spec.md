**3.2.6 OTP Verification (Phone Linking)**

**Function Trigger**

Begins when a signed-in user opens "Link phone" on their profile, enters a phone number, and then enters the six-digit code they receive.

**Function Description**

- **Actors / Roles**: A signed-in user (Bearer token required) linking a phone number to their account.
- **Purpose**: Confirm ownership of a phone number with a short-lived one-time code before attaching it to the account.
- **Interface**: A "Link phone" modal on the Profile page, with two steps: a phone number input, then a six-digit code input.
- **Data Processing**: Normalizes the phone number, generates a 6-digit numeric code, stores the code with the phone in Redis with a 10-minute TTL, enforces a 60-second resend cooldown and a 5-attempt wrong-code limit, and on success sets user.phone. The code is delivered by email to the account's own address, not by SMS.

**Screen Layout**

Figure — Link Phone modal (Profile page):

- Step "phone": a phone number input plus Cancel / "Send OTP" buttons; disabled while empty or sending.
- Step "otp": a hint line plus a six-digit code input, plus Cancel / "Verify" buttons; disabled while empty or verifying.
- On send success: toast, advances to the "otp" step.
- On verify success: toast, closes and resets the modal.
- On any error: toast built from the error response.

**Function Details**
- **Data Specifications**
    - **Input required**: phone (link step); otpCode (verify step). Both endpoints require a valid Authorization Bearer header.
    - **Input optional**: none.
    - **System data**: userId (from the access token), pending code + phone stored in Redis (TTL 10 min), a resend-cooldown marker (TTL 60s), a wrong-attempt counter (TTL 10 min), user.phone.
    - **Output**: no payload, 200, on both endpoints.

- **Business Rules**
    - **BR-03**: Numeric OTP is 6 digits, TTL 10 minutes, single-use, cleared on success.
    - **BR-04**: Resend has a 60-second cooldown, scoped per userId.
    - **BR-07**: Phone must normalize to a valid E.164 number, else 400 INVALID_PHONE. Phone already used by a different user -> 409 PHONE_ALREADY_IN_USE. A repeat link call inside the cooldown -> 429 RATE_LIMIT_EXCEEDED, the pending code is not replaced. Wrong code increments the attempt counter; on the 5th wrong attempt both the code and the counter are deleted and the answer is 400 OTP_TOO_MANY_ATTEMPTS; below 5, 400 OTP_INVALID. Correct code deletes both keys, re-checks phone uniqueness (race guard), and sets user.phone.

- **Validation**
    - phone empty or invalid format -> Display: **MSG02**
    - otpCode empty -> Display: **MSG02**
    - otpCode invalid or expired -> Display: **MSG20**

**Functionalities**
- **Normal Flow**
    1. The signed-in user opens the "Link phone" modal and enters a phone number.
    2. The client calls the link-phone endpoint with the Bearer token.
    3. The system normalizes the phone number, checks it is not already used by another user, generates a 6-digit code, stores it with the phone in Redis (TTL 10 min), starts the 60s cooldown, and emails the code.
    4. The user enters the code in the modal's second step.
    5. The client calls the verify endpoint with the Bearer token.
    6. The system matches the code, clears the pending code and attempt counter, re-checks phone uniqueness, and sets user.phone.

- **Abnormal Cases**
    - 2.a1: phone fails normalization -> 400 INVALID_PHONE, Display: **MSG02**. 2.a2: The user corrects the phone number and resubmits.
    - 2.b1: Phone already used by another user -> 409 PHONE_ALREADY_IN_USE. 2.b2: The user enters a different phone number.
    - 2.c1: link-phone called again inside the 60s cooldown -> 429 RATE_LIMIT_EXCEEDED. 2.c2: The user waits for the cooldown to elapse.
    - 5.a1: No pending code (never requested or expired) -> 400 OTP_INVALID, Display: **MSG20**. 5.a2: The user requests a new code.
    - 5.b1: Wrong code, below 5 attempts -> 400 OTP_INVALID, Display: **MSG20**. 5.b2: The user re-enters the code.
    - 5.c1: 5th wrong attempt -> 400 OTP_TOO_MANY_ATTEMPTS; the pending code is discarded. 5.c2: The user must restart from step 1 for a new code.
    - 5.d1: Correct code, but the phone was taken by another user meanwhile -> 409 PHONE_ALREADY_IN_USE. 5.d2: The user enters a different phone number and restarts.
    - Missing/expired Bearer token on either call -> 401 INVALID_CREDENTIALS; user is redirected to sign in.

**Post-Conditions**

- On success: user.phone is set to the normalized number; the pending code and attempt counter are cleared.
- On failure: no change to user.phone; Redis state reflects the specific failure path.
