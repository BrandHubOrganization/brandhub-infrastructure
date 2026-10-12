**3.10.7 Create User (Administrative User Provisioning)**

**Function Trigger**

Begins when an Administrator (ADMIN) clicks "+ Provision New User" from the user directory (/admin/users).

**Function Description**

- **Actors / Roles**: ADMIN. Platform Administrator creating accounts directly for enterprise onboarding or technical support.
- **Purpose**: Provision ADMIN/USER accounts that must verify email and replace the initial password before normal access.
- **Interface**: Provision New User Modal (SCR-ADM-07), with profile, system role, catalog plan and mandatory activation notice.
- **Data Processing**: Validate ADMIN, unique email, profile and password policy; hash temporary password using the existing auth policy. Create PENDING_VERIFICATION with emailVerifiedAt=null, requirePasswordReset=true and zero strikes. Queue a mandatory activation email and audit creation; failed email delivery keeps the account pending.

**Screen Layout**

Figure — Provision New User Modal Dialog (SCR-ADM-07):

- Left/Header: Modal title "Provision New User Account", user-plus icon, and administrative guideline banner.
- Center: Full Name, Email, temporary password/generation control, System Role ADMIN/USER and plan selector from existing subscription catalog. Activation email and initial password replacement are mandatory, with no opt-out checkboxes.
- Buttons: Button "Provision Account" (primary button), Button "Cancel".
- Footer: Account starts PENDING_VERIFICATION with zero strikes. Until email verification and password replacement complete, only activation, password setup, logout and support are available.

**Function Details**

- **Data Specifications**
    - **Input required**: fullName (2–100 chars), email (valid format), role (ADMIN/USER); temporary password if not generated: minimum 8 characters, at least one digit and one special character.
    - **Input optional**: phoneNumber, requestedPlanId from subscription catalog; account creation itself grants no unpaid paid-plan entitlement.
    - **System data**: adminId, createdAt, initialStatus=PENDING_VERIFICATION, emailVerifiedAt=null, requirePasswordReset=true, initialStrikes=0, activation email delivery state.
    - **Output**: Created user record { id, email, fullName, role, status } with HTTP 201 Created.

- **Business Rules**
    - **BR-01**: Email is unique across the platform, using existing normalization rules.
    - **BR-02**: Temporary/new passwords require at least 8 characters, one digit and one special character, with BCrypt cost 12 as specified in the source FR. Reuse the auth validation/hashing flow and reconcile any mismatch in the technical plan; never log passwords or activation tokens.
    - **BR-82**: System roles are ADMIN and USER only. Agency/Workspace membership roles are managed separately. Subscription plan identifiers come from the existing catalog (currently BASIC, PRO, ENTERPRISE), not a second hardcoded catalog.
    - **BR-63**: Only ADMIN provisions accounts. Mandatory activation email verifies email ownership; creation does not mark email verified.
    - **BR-15**: Before both email verification and initial password replacement, allow only activation/email verification, password setup, logout and support. Block dashboard, Agency data, AI, publishing and billing operations on both UI and API.
    - **BR-15**: On completion set emailVerifiedAt, clear requirePasswordReset and activate the account if no separate sanction/deletion applies. Email verification does not require Admin approval or 2FA re-enrollment.
    - **BR-60**: Paid-plan entitlements follow the existing subscription/payment flow; provisioning alone is not a payment, invoice or revenue event.
    - **BR-16**: Audit provisioning and activation outcomes without storing secrets.

- **Validation**
    - Executing user lacks ADMIN role → Display: MSG39
    - Mandatory fields left blank → Display: MSG02
    - Email format is invalid → Display: MSG04
    - Password does not satisfy complexity requirements → Display: MSG05
    - Email already exists in database → Display: MSG08
    - Account provisioned successfully → Display: MSG10

**Functionalities**

- **Normal Flow**
    1. Admin opens SCR-ADM-07 and enters profile, ADMIN/USER role and an optional catalog plan request.
    2. System validates uniqueness and existing auth/password rules.
    3. Create the pending account with zero strikes and both activation requirements enforced.
    4. Queue the mandatory activation email, record audit and show pending delivery/activation status.
    5. User follows the activation flow, verifies email and sets a private new password.
    6. Once both requirements pass, activate eligible account and allow normal access; paid plans still follow payment rules.

- **Abnormal Cases**
    - 1.a1: Missing ADMIN → MSG39; required fields/invalid email/password/duplicate email → existing MSG02/04/05/08.
    - 4.a1: Email failure → retain PENDING_VERIFICATION, expose retry/resend status; do not create another account.
    - 5.a1: Expired/used activation token → follow existing resend/verification policy; never grant application access.
    - 6.a1: Only one prerequisite completed → retain restricted activation access; sanction/deletion cannot be bypassed.

**Post-Conditions**

- New account remains PENDING_VERIFICATION until mandatory activation prerequisites complete.
- System role is ADMIN/USER; Agency roles and paid-plan entitlements remain separate.
- Activation email delivery and audit are recorded; no password/token is logged.
