**3.10.5 User Management (Account Status and Strike Management)**

**Function Trigger**

Begins when an authenticated Administrator (ADMIN) selects "Manage Status & Violations" from the user directory (/admin/users).

**Function Description**

- **Actors / Roles**: ADMIN manages compliance. Users verify their own email through the activation flow.
- **Purpose**: Manage YELLOW/ORANGE/RED strikes and account flags. PENDING_VERIFICATION means unverified email; this function does not recover a lost authenticator.
- **Interface**: User Status & Violation Sanction Modal Dialog (SCR-ADM-05), featuring account overview, 3-tier strike counters, habit detection banner, and administrative action forms.
- **Data Processing**: Validate ADMIN and target, persist the strike event and audit, consume each eligible yellow batch only once, update clean-period deadline and account publishing restrictions, and create one pending sanction request for RED/three active ORANGE. Pardon references an exact strikeId and does not cascade.

**Screen Layout**

Figure — User Status & Violation Sanction Modal Dialog (SCR-ADM-05):

- Left/Header: Modal title "Manage Status & Violation Sanctions", security shield icon, and current status badge (ACTIVE green, FLAGGED orange, PENDING_VERIFICATION yellow).
- Center: Profile, status and email verification state; YELLOW x/3 unconverted counter, ORANGE x/3 active counter, RED indicator, converted/expired/pardoned history and clean-period deadline. Actions: add strike, pardon exact strike, unflag after clearing active sanctions. Show pending sanction review link; no Verify 2FA action.
- Buttons: Cancel, Confirm Strike / Pardon / Remove Flag, Open Sanction Review.
- Footer: Audit compliance notice: "All strike additions and pardon actions are permanently recorded in the Audit Log with executing Admin ID and mandatory justification. Hard-deletion of user accounts is strictly prohibited by system architecture."

**Function Details**

- **Data Specifications**
    - **Input required**: userId, action (add_strike, remove_strike, unflag), reason; add_strike requires violationLevel (YELLOW/ORANGE/RED) and violationCategory; remove_strike requires strikeId.
    - **Input optional**: postId, contentVersionId, evidence references.
    - **System data**: adminId, status, emailVerifiedAt, requirePasswordReset, lastViolationAt, cleanPeriodEndsAt, strike states and conversion links, active counters, pendingSanctionRequestId.
    - **Output**: User profile update confirmation payload with HTTP 200 OK.

- **Business Rules**
    - **BR-63**: Only ADMIN records/pardons strikes and manages flags, with mandatory reasons and immutable audit.
    - **BR-92**: Admin cannot hard-delete users; preserve related data and historical strikes. Self-service deletion is a separate flow.
    - **BR-15**: PENDING_VERIFICATION is unverified email. The user completes email verification; Admin does not bypass it or reset TOTP here. Re-enrolling 2FA is not required by email verification.
    - **BR-94**: YELLOW is a warning. An active ORANGE strike sets FLAGGED and requires ADMIN approval for publishing; login remains available. RED or three active ORANGE strikes creates a sanction review request under FR 3.10.9; only Admin confirmation deactivates the account.
    - **BR-95**: Three active, unconverted YELLOW strikes of any violation category produce one independent ORANGE strike. Mark all three source strikes converted and retain their linkage. A fourth YELLOW starts the next batch; six qualifying YELLOW strikes produce two ORANGE strikes. A direct ORANGE can also be recorded. Pardoning a source YELLOW does not pardon the derived ORANGE.
    - **BR-96**: Each new violation restarts the account clean period of 30 consecutive days without violations. Still-active strikes expire after that clean period, not individually 30 days after creation. Expired or pardoned strikes are not revived; conversion does not count as a second violation. Expiration and pardon preserve immutable history. Removing the last active ORANGE restores publishing eligibility only if no deactivation or activation restriction remains.
    - **BR-23**: Sole Agency/Workspace Owners may receive profile edits, strikes, flags and confirmed 30-day account deactivation. Other members retain their existing permissions; Owner-only operations wait until restoration. Do not suspend the whole Agency or transfer ownership automatically. Agency ownership is separate from system role.
    - **BR-15**: Unflag requires offending active strikes to be pardoned/expired first, especially all active ORANGE. It cannot unlock DEACTIVATED accounts; FR 3.10.9 governs the separate 30-day sanction.
    - **BR-35**: Admin cannot self-sanction or sanction peer ADMIN accounts.

- **Validation**
    - Missing ADMIN authority or self/peer-admin sanction → MSG39.
    - Unknown user or strike → MSG38; missing justification → MSG02.
    - Unflag while an active offending strike remains, or target is DEACTIVATED → reject transition.
    - Duplicate request/conversion → return existing outcome; do not duplicate strikes or sanctions.
    - Valid sole Owner operation is allowed; show Agency impact before deactivation.
    - Successful strike/status update → MSG26.

**Functionalities**

- **Normal Flow**
    1. Admin opens the status/strike modal for a user and reviews active and historical strikes.
    2. Select add, pardon by strikeId or unflag and enter justification.
    3. Validate permissions, target state and applicable transition conditions atomically.
    4. Record the violation; reset the clean period for still-active strikes. Convert eligible yellow batches once, or pardon only the selected strike.
    5. Recompute FLAGGED and active counters; RED/three ORANGE opens sanction review without deactivation.
    6. Save audit and refresh UI. A background job expires strikes after 30 clean days; it never bypasses an active account sanction.

- **Abnormal Cases**
    - 2.a1: Missing justification → MSG02.
    - 3.a1: Self/peer-admin sanction or missing ADMIN → MSG39.
    - 3.a2: Pending email verification must use the user activation flow; no administrative verify-2FA bypass.
    - 3.a3: Stale revision/concurrent pardon or conversion → reload consistent state; retain one audit outcome per action.

**Post-Conditions**

- Strike lifecycle and source-conversion links are persisted; history is retained.
- FLAGGED users retain login but require ADMIN publishing approval, including scheduled posts.
- RED/three ORANGE leaves a review request awaiting Admin confirmation.
- Email activation and DEACTIVATED sanction clocks remain independent of unflag/strike cleanup.
