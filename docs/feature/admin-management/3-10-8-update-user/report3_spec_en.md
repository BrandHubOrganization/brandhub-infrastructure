**3.10.8 Update User (Administrative Profile & System Role Modification)**

**Function Trigger**

Begins when an Administrator (ADMIN) selects "Edit Profile" on a user record from /admin/users or navigates to /admin/users/:id/edit.

**Function Description**

- **Actors / Roles**: ADMIN. Platform Administrator with authority to update user profiles, subscription plans, and system roles.
- **Purpose**: Enables Administrators to adjust user account details, assign new system roles, or modify subscription tiers while strictly safeguarding immutable fields.
- **Interface**: Edit User Profile Screen (SCR-ADM-08), displaying account profile form, immutable email indicator, role selector, and audit notes.
- **Data Processing**: Validate ADMIN, immutable email, system role and audit justification. Update permitted profile fields; keep Agency ownership separate. Store a requested plan change for the next billing cycle with payment required. Do not immediately change quota, issue a paid receipt or recognize revenue.

**Screen Layout**

Figure — Edit User Profile Screen (SCR-ADM-08):

- Left/Header: Admin sidebar; Header with breadcrumbs "Users / Edit Profile", target User ID, and registration date.
- Center: Editable name/phone/bio/avatar, read-only email; ADMIN/USER system role; Agency roles read-only context. Show current plan, requested catalog plan, next-cycle effective date and payment-required notice. Mandatory justification.
- Buttons: Button "Save Changes" (primary button), Button "Cancel / Return".
- Footer: Security audit compliance note: "Email address is immutable after creation (BR-19). Role changes take effect on subsequent token refresh. All modifications are tracked in audit_logs."

**Function Details**

- **Data Specifications**
    - **Input required**: userId, fullName (2–100 chars), role (ADMIN/USER), justification.
    - **Input optional**: phoneNumber, bio, avatarUrl, requestedPlanId (existing catalog).
    - **System data**: adminId, immutable email, currentRole, currentPlan, nextBillingAt, pendingPlanChange and payment state, updatedAt.
    - **Output**: Updated user profile object with HTTP 200 OK.

- **Business Rules**
    - **BR-19**: Email remains read-only; reject email mutation through the API.
    - **BR-82**: System roles are ADMIN and USER only. Agency/Workspace membership roles are managed separately. Subscription plan identifiers come from the existing catalog (currently BASIC, PRO, ENTERPRISE), not a second hardcoded catalog.
    - **BR-83**: Agency/Workspace ownership changes use their own membership flow. This screen cannot remove the last Owner through a system-role edit; editing the sole Owner profile is allowed.
    - **BR-23**: Sole Agency/Workspace Owners may receive profile edits, strikes, flags and confirmed 30-day account deactivation. Other members retain their existing permissions; Owner-only operations wait until restoration. Do not suspend the whole Agency or transfer ownership automatically. Agency ownership is separate from system role.
    - **BR-35**: Admin may not demote or alter the system role of a peer Admin; preserve existing self/peer role safeguards.
    - **BR-60**: Admin plan change is scheduled for the next billing cycle and still requires customer payment under the existing subscription flow. Current entitlement remains until the cycle boundary. Unpaid change grants no paid entitlement; change action alone creates no revenue or paid invoice.
    - **BR-16**: Audit profile diffs, role changes, requested plan, effective date and justification separately from actual payment events.

- **Validation**
    - Missing ADMIN → MSG39; target not found → MSG38; missing fields/justification → MSG02.
    - Email mutation, unsupported system role or unknown catalog plan → reject.
    - Peer-admin role alteration or Agency ownership mutation through this form → reject.
    - Valid sole Owner profile edit → allowed; successful update → MSG26.

**Functionalities**

- **Normal Flow**
    1. Load user profile, separate Agency roles, current plan and next billing date.
    2. Admin edits permitted profile fields/system role or selects a next-cycle plan and enters justification.
    3. Validate immutability, role safeguards and catalog values.
    4. Save profile changes and pending plan change; do not alter current-cycle entitlement.
    5. Audit changes and show current versus pending plan with effective date and payment requirement.
    6. Existing subscription billing applies the paid change at the next cycle only after required payment succeeds.

- **Abnormal Cases**
    - 1.a1: Missing user → MSG38; missing ADMIN → MSG39.
    - 3.a1: Missing justification or protected field/role mutation → reject without partial update.
    - 6.a1: Payment fails at renewal → use existing subscription failure policy; no free entitlement or false revenue.
    - 6.a2: No determinable next billing cycle → route through existing subscription enrollment; do not invent an immediate free upgrade.

**Post-Conditions**

- Allowed profile fields are updated; email and Agency ownership remain unchanged by this form.
- Pending plan change records next-cycle date and payment requirement; current quota remains until effective change.
- Audit captures changes; revenue updates only on actual financial events.
