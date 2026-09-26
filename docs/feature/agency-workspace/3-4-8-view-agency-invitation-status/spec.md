# 3.4.8 View Agency Invitation Status

## Function Trigger
An Owner opens the pending-invitation tab of an Agency to review, cancel or follow up its invitations; or an invited person opens their own pending invitations to see what is still open and to accept or decline.

## Function Description
- **Actors / Roles:** Agency Owner (invitations of their Agency) and invited person (their own invitations).
- **Purpose:** Let both sides see where an invitation stands, so they know whether it is still open, has lapsed, has been accepted or has been withdrawn.
- **Interface:** For the Owner, a pending-invitation tab in the Member list of the Agency (`/agencies/:agencyId/members`), listing every invitation with its status and a cancel action on the open ones. For the invited person, a "My invitations" section listing the invitations still valid, each with an accept and a decline action.
- **Data Processing:** The system returns the invitations of an Agency for its Owner, deriving the lapsed ones at read time, and returns the still-valid invitations addressed to the signed-in email for an invited person. Cancelling an open invitation withdraws it, and declining an invitation does the same from the invited person's side.

## Screen Layout
Figure — Invitation list:
- Owner view: one row per invitation with the invited email, the pre-assigned Workspace and role if any, the expiry time, the derived status and a cancel action on the open ones.
- Invited person view: one row per still-valid invitation with the Agency name, the expiry time, an accept action and a decline action.
- Statuses shown as badges: PENDING, EXPIRED, ACCEPTED, REVOKED.

## Function Details
### Data Specifications
- **Input required:** For the Owner view, the Agency identifier (`agencyId`); for the invited-person view, the signed-in session. Cancelling needs the invitation identifier; declining needs the invitation token.
- **Input optional:** None.
- **System data:** The invitations of the Agency — id, agencyId, agencyName, invitedEmail, invitedBy, token, note, workspaceId, workspaceName, role (nullable), status (InvitationStatus: PENDING, ACCEPTED, EXPIRED, REVOKED), expiresAt, acceptedAt (nullable), createdAt (full field list at 3.4.7) — and the email of the signed-in user.
- **Output:** For the Owner, every invitation of the Agency whatever its status, with lapsed ones shown as expired. For the invited person, only the invitations addressed to their email that are still open. Cancelling and declining return no data.

### Business Rules
- **BR-27:** Only the Owner of the Agency may list or cancel its invitations, per the same Invite rule (BR-27, "only OWNER/MANAGER" adapted to the Agency's single-Owner model). Anybody else is refused with `403 NOT_AGENCY_OWNER`.
- An invitation is valid for the period set when it was sent — 30 days by default, settable between 1 and 30 days (BR-27, 3.4.7).
  - **⚠ BA conflict (needs team decision):** see the same note in `3-4-7-invite-agency-member/spec.md` — `docs/ba/03-agency-workspace-management.md` states a fixed 3-day expiry, while the code implements 30 days adjustable 1–30. Not yet reconciled.
- Expiry is derived when the list is read, not by a scheduled job: after the expiry time passes the stored record keeps its PENDING status, and the system reports it as EXPIRED without writing that back to storage. Two reads taken either side of the expiry time may therefore report different statuses for the same record.
- The Owner sees lapsed invitations reported as expired. The invited person does not: their list drops anything that is no longer PENDING or has passed its expiry time, so it holds valid invitations only.
- The Owner may cancel an invitation while it is still PENDING, which moves it to REVOKED. An invitation that has already been accepted, lapsed or withdrawn cannot be cancelled.
- The invited person may decline an invitation with its token, which also moves it to REVOKED — the status model has no separate value for a declined invitation.
- There is no renewal or resend of an existing invitation. Sending a new invitation is the way forward, and the old one can only be withdrawn.

### Validation
- Caller is not the Agency Owner → Display: MSG39
- The invitation does not exist, or does not belong to the Agency → Display: MSG38
- Cancelling an invitation that is no longer PENDING → Display: MSG38 (closest fit — no dedicated MSG code for an invalid-state invitation)
- Accepting an invitation that is not PENDING or has passed its expiry time → Display: MSG38 (closest fit — no dedicated MSG code for an expired/invalid invitation)

## Functionalities
### Normal Flow
1. The Owner opens the pending-invitation tab of an Agency.
2. The client requests the invitations of the Agency with the signed-in session.
3. The system confirms the caller is the Owner of the Agency.
4. The system reads every invitation of the Agency and reports the lapsed ones as EXPIRED at read time, without writing the change back.
5. The client renders the list with the reported statuses.
6. The invited person opens their own invitation list.
7. The system returns the invitations addressed to the signed-in email that are still PENDING and unexpired.
8. The client renders them with an accept and a decline action on each.
9. When the Owner selects cancel on an open invitation, the system moves it to REVOKED and the client drops the row; toast MSG36 (closest fit — reused from "member removed"; no dedicated MSG code for a cancelled invitation).
10. When the invited person selects decline, the system moves the invitation to REVOKED and the client drops the row.

### Abnormal Cases
- 3.a1: Caller is not the Agency Owner (BR-27) → `403 NOT_AGENCY_OWNER`, toast MSG39; no list is returned. 3.a2: The caller returns to the Agency list and opens an Agency they own.
- 9.a1: Cancelling an invitation that does not exist or belongs to another Agency → `404 INVITATION_NOT_FOUND`, toast MSG38. 9.a2: The Owner refreshes the invitation list.
- 9.b1: Cancelling an invitation that has already been accepted, lapsed or withdrawn → `400 INVALID_INVITATION`, toast MSG38 (closest fit). 9.b2: The Owner refreshes the list to see its current status.
- 10.a1: The invitation lapses exactly as the invited person accepts it → the system re-checks the PENDING status and the expiry time at acceptance and refuses with `400 INVALID_INVITATION`, toast MSG38 (closest fit); creating no Agency membership. 10.a2: The invited person asks the Owner to send a new invitation.
- 4.a1: Because expiry is derived at read time, two reads taken either side of the expiry time may report different statuses for the same stored record — this is the intended behaviour, not an error; no toast. 4.a2: The user re-reads the list if the status looks stale.

## Post-Conditions
- The Owner sees every invitation of the Agency with its current status, lapsed ones included.
- The invited person sees only the invitations that are still valid for their email.
- After a cancel or a decline, the invitation carries the REVOKED status.
- No Agency membership is created while an invitation is not accepted.
