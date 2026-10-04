**3.10.9 Deactive User (Tiered Sanctions: Flag / Deactivate)**

**Function Trigger**

Begins when an Administrator (ADMIN) clicks "Sanction / Deactivate" from a user profile view (/admin/users/:id).

**Function Description**

- **Actors / Roles**: ADMIN. Platform Administrator enforcing compliance sanctions against violating user accounts.
- **Purpose**: Apply a publishing flag or confirm a 30-day whole-account deactivation. Restore sanctioned accounts automatically after 30 days and send email.
- **Interface**: User Sanction & Deactivation Modal Dialog (SCR-ADM-09), displaying account summary, active strike counters, 2 sanction tier radio options, and mandatory justification input.
- **Data Processing**: RED/three active ORANGE creates a review request. Admin inspects evidence and confirms DEACTIVATE with justification; then set deactivatedAt/reactivateAt=deactivatedAt+30 days, revoke all sessions/tokens and block account access. An idempotent background job restores ACTIVE at expiry and sends email; no second Admin approval is required.

**Screen Layout**

Figure — User Sanction & Deactivation Modal Dialog (SCR-ADM-09):

- Left/Header: Modal title "Account Sanction & Deactivation", warning triangle icon (orange for Flag) or padlock icon (red for Deactivate), and target User ID display.
- Center: User summary, active YELLOW/ORANGE/RED counters, review request/evidence, FLAG or DEACTIVATE choice, reason and confirmation checkbox. Before locking a sole Owner, explain that members continue existing permissions while Owner-only operations wait. Show sanction start, automatic restoration time and review status.
- Buttons: Button "Cancel", Primary Action Button (Orange "Confirm Flag" or Red "Confirm Deactivate").
- Footer: Mandatory rule notice: "Administrators cannot self-sanction or sanction peer Administrators. All user posts and PayOS billing data remain 100% preserved in database."

**Function Details**

- **Data Specifications**
    - **Input required**: userId, sanctionType (FLAG/DEACTIVATE), reason; DEACTIVATE requires explicit Admin confirmation and review evidence.
    - **Input optional**: sanctionRequestId, linkedStrikeIds, evidence references.
    - **System data**: adminId, target systemRole/status, active strikes, review state, deactivatedAt, reactivateAt, restoredAt, email delivery status.
    - **Output**: Sanction result payload { userId, status: "FLAGGED" | "DEACTIVATED", activeStrikes } with HTTP 200 OK.

- **Business Rules**
    - **BR-63**: Only ADMIN confirms account deactivation. RED or three active ORANGE creates a pending review, not an automatic account lock. Revalidate evidence at confirmation; stale or duplicate requests do not duplicate sanctions.
    - **BR-94**: FLAGGED permits login but requires ADMIN review for new and already scheduled publications. DEACTIVATED blocks the entire account for 30 days from confirmed sanction.
    - **BR-06**: DEACTIVATED is enforced on login, refresh and authenticated operations; a previously issued token must not preserve access.
    - **BR-22**: Revoke every active session and access/refresh token at deactivation. Restoration requires a fresh login; revoked tokens do not become valid again.
    - **BR-23**: Sole Agency/Workspace Owners may receive profile edits, strikes, flags and confirmed 30-day account deactivation. Other members retain their existing permissions; Owner-only operations wait until restoration. Do not suspend the whole Agency or transfer ownership automatically. Agency ownership is separate from system role.
    - **BR-35**: Admin cannot self-sanction or sanction peer ADMIN accounts.
    - **BR-96**: At reactivateAt, automatically restore ACTIVE and send reopening email without Admin approval. Strike cleanup cannot unlock early. Preserve strike history; expired sanctions do not revive old strikes. Email failure is retried without undoing restoration. Never restore DELETED or unrelated legacy SUSPENDED records.
    - **BR-92**: Preserve all user, Agency, publication and billing data; no hard-delete.
    - **BR-16**: Audit review, confirmation, session revocation and automatic restoration with linked evidence and timestamps.

- **Validation**
    - Missing ADMIN, self-sanction or peer-admin sanction → MSG39.
    - Unknown user/request → MSG38; missing reason/confirmation → MSG02.
    - Sole Owner is allowed after impact notice and Admin confirmation; no MSG92 rejection solely for ownership.
    - Already resolved request or already deactivated account → conflict/idempotent existing result; do not restart the penalty accidentally.
    - Deactivation completed → MSG91.

**Functionalities**

- **Normal Flow**
    1. RED/three active ORANGE opens a review request; account is not automatically deactivated.
    2. Admin reviews strikes/evidence and chooses FLAG or confirms DEACTIVATE with reason.
    3. Validate self/peer protections and current state; show sole Owner impact when applicable.
    4. Apply the confirmed sanction once. For DEACTIVATE, store 30-day deadline and revoke all sessions/tokens; send sanction email and audit.
    5. At the deadline, background processing verifies the same sanction is due and restores ACTIVE automatically.
    6. Record restoration and send reopening email; the user logs in again with fresh credentials/session.

- **Abnormal Cases**
    - 2.a1: Admin does not confirm → request remains unresolved; no deactivation.
    - 3.a1: Self/peer-admin target → MSG39; ownership alone does not reject the sanction.
    - 4.a1: Repeated submission → existing result; no duplicate strike or restarted penalty.
    - 5.a1: Worker downtime → catch up due sanctions after recovery; never unlock before deadline.
    - 6.a1: Email failure → retry notification; account remains restored. A different current sanction or DELETED state is not overwritten.

**Post-Conditions**

- Confirmed FLAGGED users retain sessions with ADMIN publishing gate; confirmed DEACTIVATED users lose all account access.
- The 30-day sanction deadline is persisted and automatically restores ACTIVE when due, with email and audit.
- Agency members continue their permissions; no automatic ownership transfer or Agency-wide suspension occurs.
- All data and sanction/strike history remain intact.
