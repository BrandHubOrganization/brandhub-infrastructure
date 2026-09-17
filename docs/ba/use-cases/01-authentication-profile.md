# UC 01 — Authentication & Profile (UC-01 → UC-12)

> [<< Về Overview](../00-overview.md) · Nguồn FR: [02-authentication-profile.md](../02-authentication-profile.md)
> Nguồn UC gốc: `Các FR của hệ thống - Use Case.csv`

## Bảng tổng hợp

| UC ID | Use Case | Actor(s) | Related FR |
|---|---|---|---|
| UC-01 | Sign Up | GUEST | 3.2.1, 3.2.6 |
| UC-02 | Sign In with Email | GUEST | 3.2.2 |
| UC-03 | Sign In with Google OAuth | GUEST | 3.2.3 |
| UC-04 | Forgot & Reset Password | GUEST/USER | 3.2.4 |
| UC-05 | Change Password | USER | 3.2.5 |
| UC-06 | Enable/Disable Two-Factor Authentication (2FA) | USER | 3.2.7 |
| UC-07 | Sign Out | USER | 3.2.8 |
| UC-08 | Deactivate Account | USER | 3.2.9 |
| UC-09 | View Personal Profile | USER | 3.3.1 |
| UC-10 | Update Personal Profile | USER | 3.3.2 |
| UC-11 | View Client Profile | USER (Client) | 3.3.3 |
| UC-12 | Update Client Profile | USER (Client) | 3.3.4 |

---

## UC-01 — Sign Up

- **Actor(s):** GUEST
- **Description:** User registers a new account with email; system sends an OTP to verify the email is real.
- **Precondition:** User is not authenticated. Email not already registered.
- **Main Flow:**
  1. GUEST opens Sign Up screen, enters email, password, full name.
  2. System normalizes email local-part case (`User@gmail.com` ≡ `user@gmail.com`) and checks for existing account.
  3. System creates account in `PENDING_VERIFICATION` state, sends OTP to email.
  4. User enters OTP on verification screen (UC shared with Reset Password, 2FA — see FR 3.2.6).
  5. System verifies OTP, activates account, redirects to Sign In.
- **Alternate Flow:**
  - A1. Email already registered (case-insensitive local-part match) → reject with duplicate-account error.
  - A2. OTP incorrect or expired → allow resend, max retry limit applies.
- **Postcondition:** Active user account created.

## UC-02 — Sign In with Email

- **Actor(s):** GUEST
- **Description:** Sign in directly with registered email/password, no OTP required.
- **Precondition:** Account exists and is verified/active.
- **Main Flow:**
  1. GUEST enters email + password.
  2. System validates credentials, issues session/JWT.
  3. Redirect to last-used context (Agency list or Dashboard).
- **Alternate Flow:**
  - A1. Wrong password → error, no OTP triggered (differs from Sign Up).
  - A2. Account deactivated → block login, show reactivation guidance.
  - A3. 2FA enabled (FR 3.2.7) → require OTP/TOTP step before session issued.

## UC-03 — Sign In with Google OAuth

- **Actor(s):** GUEST
- **Description:** Quick sign-in via a Google account.
- **Precondition:** None.
- **Main Flow:**
  1. GUEST clicks "Sign in with Google".
  2. Redirect to Google OAuth consent screen.
  3. On success, system matches/creates account by verified Google email, issues session.
- **Alternate Flow:**
  - A1. Google email matches an existing email/password account → link accounts (or block, per final decision — **[OPEN QUESTION]**, flow currently broken per `docs/ba/02` note).
- **Note:** Current implementation reported non-functional — treat as bug-fix-on-existing-flow, not pure new feature.

## UC-04 — Forgot & Reset Password

- **Actor(s):** GUEST/USER
- **Description:** Send a reset link or OTP for the user to confirm and set a new password when forgotten.
- **Precondition:** Account exists.
- **Main Flow:**
  1. User requests password reset by email.
  2. System sends reset link or OTP.
  3. User confirms via link/OTP, enters new password.
  4. System updates password, invalidates old sessions.
- **Alternate Flow:**
  - A1. Email not registered → generic success message (no account enumeration).
  - A2. Reset link/OTP expired → user must request again.

## UC-05 — Change Password

- **Actor(s):** USER
- **Description:** Change the current password, requiring re-confirmation before saving.
- **Precondition:** User authenticated.
- **Main Flow:**
  1. User enters current password + new password (typed twice, or confirm modal).
  2. System validates current password.
  3. System saves new password hash, invalidates other active sessions.
- **Alternate Flow:**
  - A1. Current password incorrect → reject.
  - A2. New password fails confirm-match → reject before submit.

## UC-06 — Enable/Disable Two-Factor Authentication (2FA)

- **Actor(s):** USER
- **Description:** Enable or disable 2FA via QR scan (TOTP) or OTP code.
- **Precondition:** User authenticated.
- **Main Flow:**
  1. User opens Security settings, selects Enable 2FA.
  2. System shows QR code for Authenticator app scan.
  3. User enters generated TOTP code to confirm.
  4. System enables 2FA flag on account.
- **Alternate Flow:**
  - A1. Disable 2FA → require current password/OTP re-confirm before turning off.
- **Note:** Backup codes and secret-key copy removed from scope (simplified for reduced attack surface).

## UC-07 — Sign Out

- **Actor(s):** USER
- **Description:** Sign out of the system, saving the last-used platform for easier future sign-in.
- **Precondition:** User authenticated.
- **Main Flow:**
  1. User triggers Sign Out.
  2. System invalidates current session/refresh token.
  3. System persists "last used login platform" (email vs Google OAuth) for next login UX.

## UC-08 — Deactivate Account

- **Actor(s):** USER
- **Description:** Soft-delete the user's account upon request.
- **Precondition:** User authenticated.
- **Main Flow:**
  1. User requests account deactivation, confirms via modal.
  2. System marks account `INACTIVE`/soft-deleted, invalidates sessions.
- **Postcondition:** Account inactive, data retained (soft delete).

## UC-09 — View Personal Profile

- **Actor(s):** USER
- **Description:** View the user's personal profile information.
- **Precondition:** User authenticated.
- **Main Flow:**
  1. User opens Profile screen.
  2. System displays profile fields (full name, email, avatar, etc.).
- **Note:** Exact field list is an **[OPEN QUESTION]** pending DB schema design (see `docs/ba/02` §3.3.1).

## UC-10 — Update Personal Profile

- **Actor(s):** USER
- **Description:** Update the user's personal profile information.
- **Precondition:** User authenticated.
- **Main Flow:**
  1. User edits profile fields, submits.
  2. System validates and persists changes.
- **Note:** View and Update are a single combined FR (3.3.2) per BA decision — not separated at the FR-naming level.

## UC-11 — View Client Profile

- **Actor(s):** USER (Client)
- **Description:** View the dedicated profile used when joining a workspace in the Client role.
- **Precondition:** User has been added to at least one Workspace as CLIENT.
- **Main Flow:**
  1. Client opens Client Profile screen (separate from personal User Profile).
  2. System displays Client Profile fields, reused across any Agency/Workspace the same email joins.
- **Business Rule:** Client Profile is agency-independent — same profile reused across multiple Agencies/Workspaces (see [01-organization-structure.md](../01-organization-structure.md) §5).

## UC-12 — Update Client Profile

- **Actor(s):** USER (Client)
- **Description:** Update the Client profile (email field cannot be edited).
- **Precondition:** User has a Client Profile.
- **Main Flow:**
  1. Client edits allowed fields (name, contact phone, etc.).
  2. System rejects any attempt to change email (email is the cross-Agency identity key).
- **Alternate Flow:**
  - A1. Attempt to edit email field → blocked/read-only at UI and API level.
