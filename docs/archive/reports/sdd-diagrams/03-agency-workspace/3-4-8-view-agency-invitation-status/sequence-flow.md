# Sequence Flow — View Agency Invitation Status

> Companion to `spec.md` (FR 3.4.8). This file lists each actor → action → system step in enough detail to draw the sequence diagram directly. Business explanation lives in `spec.md`.
>
> Updated 2026-09-23, matching the system as built today.

## Actors

- **Owner** — owns the Agency.
- **Invitee** — the person invited.
- **Client** — the BrandHub web application.
- **System** — the BrandHub service.
- **Database** — PostgreSQL (`agency_invitations`).

---

## Flow A — The Owner views every invitation of the Agency

1. Owner → Client: opens the pending-invitation tab in the Member list of the Agency.
2. Client → System: requests the invitations of the Agency (`GET /api/v1/agencies/{agencyId}/invitations`).
3. System — list:
   a. Confirms the caller is the Owner of the Agency — otherwise `403 NOT_AGENCY_OWNER`.
   b. Reads every invitation of the Agency, whatever its status, including PENDING ones already past their expiry time.
   c. Derives expiry as it maps the answer: an invitation that is PENDING but past its expiry time is reported as EXPIRED, without that change being written back to storage.
4. System → Client: the invitations with their reported statuses.
5. Client: renders the list with the reported statuses — PENDING, EXPIRED, ACCEPTED and REVOKED.

## Flow B — The Owner cancels an open invitation

1. Owner → Client: selects Cancel on an invitation row.
2. Client → System: submits the cancellation (`DELETE /api/v1/agencies/{agencyId}/invitations/{invitationId}`).
3. System — cancel:
   a. Confirms the caller is the Owner of the Agency — otherwise `403 NOT_AGENCY_OWNER`.
   b. Finds the invitation by identifier inside that Agency — not found → `404 INVITATION_NOT_FOUND`.
   c. Confirms the invitation is still PENDING in storage — anything else → `400 INVALID_INVITATION`.
   d. Marks the invitation REVOKED.
4. System → Client: no data, the cancellation is done.
5. Client: drops the row from the open list, or marks it as withdrawn.

## Flow C — The Invitee views their own open invitations

1. Invitee → Client: opens the section listing their own invitations.
2. Client → System: requests their invitations (`GET /api/v1/agencies/invitations/my-pending`).
3. System — list:
   a. Reads the invitations addressed to the email of the signed-in user.
   b. Drops every invitation that is no longer PENDING or has passed its expiry time. Unlike Flow A, the Invitee sees nothing beyond the invitations that are genuinely still open.
4. System → Client: the still-valid invitations.
5. Client: renders them, each with an accept action (3.4.7) and a decline action.

## Flow D — The Invitee declines an invitation

1. Invitee → Client: selects Decline on an invitation.
2. Client → System: submits the decline with the token (`POST /api/v1/agencies/invitations/decline`).
3. System: finds the invitation by token and marks it REVOKED. The status model has no separate value for a declined invitation, so it shares the withdrawn state.
4. System → Client: no data, the decline is done.
5. Client: drops the item from the Invitee's list.

---

## Error paths

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| List (Owner) | Caller is not the Owner | 403 | `NOT_AGENCY_OWNER` |
| Cancel | Caller is not the Owner | 403 | `NOT_AGENCY_OWNER` |
| Cancel | Invitation does not exist or belongs to another Agency | 404 | `INVITATION_NOT_FOUND` |
| Cancel | Invitation is no longer PENDING | 400 | `INVALID_INVITATION` |
| Accept | Invitation lapsed or already handled at the moment of acceptance | 400 | `INVALID_INVITATION` |

## Notes

- No divergence from `spec.md`: expiry is derived when the list is read rather than by a scheduled job, it defaults to 30 days and is settable between 1 and 30 days, and the Invitee's own list is addressed by their email rather than by a general account route.
- This file details the decline path as a flow of its own, which `spec.md` describes among the interfaces of the feature. That is added detail, not a correction.
