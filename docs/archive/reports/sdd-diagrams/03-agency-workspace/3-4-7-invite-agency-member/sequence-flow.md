# Sequence Flow — Invite Agency Member → Accept Invitation

> Companion to `spec.md` (FR 3.4.7) and to `3-4-8-view-agency-invitation-status/spec.md` (FR 3.4.8). This file lists each actor → action → system step in enough detail to draw the sequence diagram directly. Business explanation lives in `spec.md`.
>
> Updated 2026-09-23, matching the system as built today.

## Actors

- **Owner** — owns the Agency and sends the invitation.
- **Invitee** — the person invited; may not have an account yet.
- **Client** — the BrandHub web application.
- **System** — the BrandHub service.
- **Database** — PostgreSQL (`agency_invitations`, `agency_members`, `workspace_members`, `client_profiles`).
- **Mail** — the outgoing email service; the invitation email is sent without holding up the answer to the client.

---

## Flow A — The Owner sends an invitation (role MANAGER or CREATOR, not CLIENT)

1. Owner → Client: opens the Member list of the Agency and fills in the form (email, optional invitee name, optional note, expiry between 1 and 30 days defaulting to 30, optional Workspace and role).
2. Client → System: submits the invitation (`POST /api/v1/agencies/{agencyId}/invitations`) with email, invitee name, note, Workspace, role and expiry period.
3. System — check and store:
   a. Confirms the caller is the Owner of the Agency — otherwise `403 NOT_AGENCY_OWNER`.
   b. Confirms the email is not already a Member of the Agency — otherwise `409 ALREADY_AGENCY_MEMBER`.
   c. Confirms the email holds no unexpired PENDING invitation for this Agency — otherwise `409 INVITATION_ALREADY_PENDING`.
   d. Confirms the Agency holds fewer than 20 PENDING invitations — otherwise `409 TOO_MANY_PENDING_INVITATIONS`.
   e. When a Workspace is sent: confirms it belongs to the same Agency — otherwise `400 WORKSPACE_NOT_IN_AGENCY`. With the role MANAGER, confirms the Workspace holds no active manager — otherwise `409 MANAGER_ALREADY_ASSIGNED`. With the role CLIENT, confirms a Workspace was sent — otherwise `400 WORKSPACE_REQUIRED_FOR_CLIENT_INVITE` (see Flow B).
   f. Stores the invitation as PENDING, with a random token, an expiry time computed from the expiry period, the note, the Workspace and the role.
      - At the Database level, the PENDING uniqueness is partial: it applies to rows in the PENDING status only, so an email whose earlier invitation was withdrawn or has lapsed can be invited again.
4. System → Mail: sends the invitation email, carrying an accept link with the token, without holding up the answer to the client.
5. System → Client: the stored invitation (identifier, Agency, invited email, sender, token, note, Workspace, role, status PENDING, expiry time, no acceptance time, creation time).
6. Client: shows a confirmation and adds the row to the PENDING invitation table.

## Flow B — The Owner sends an invitation with the role CLIENT

Same as Flow A steps 1–3, with two differences:

- A Workspace is mandatory from step 1; the Client blocks submission when the role CLIENT is selected without a Workspace.
- The System stores the role CLIENT together with the Workspace on the invitation, and creates no Workspace membership at this point — that happens only on acceptance (see Flow D).

---

## Flow C — The Invitee already has an account and opens the invitation link

1. Invitee → Client: opens the accept link from the email, landing on the invitation screen with the token.
2. Client: sees the Invitee is already signed in and lets them through, with no redirect.
3. Client → System: accepts the invitation with the token (`POST /api/v1/agencies/invitations/accept`).
4. System — accept:
   a. Finds the invitation by token — not found → `400 INVALID_INVITATION`.
   b. Confirms it is PENDING and not past its expiry time — otherwise `400 INVALID_INVITATION`.
   c. Confirms the invited email matches the email of the signed-in user — otherwise `400 INVALID_INVITATION`.
   d. When the role is CLIENT, branches to **Flow D** and returns early.
   e. Confirms the person is not already a Member of the Agency — otherwise `409 ALREADY_AGENCY_MEMBER`.
   f. Stores a member record for the Agency at the MEMBER role. The Agency level knows OWNER and MEMBER only; any finer role lives at the Workspace level.
   g. Marks the invitation ACCEPTED with the acceptance time.
5. System → Client: the new membership (Agency, person, name, email and the like).
6. Client: shows a confirmation and, after a short pause, takes the person back to the Agency landing area.

## Flow D — Accepting an invitation with the role CLIENT

Continues from Flow C step 4.d:

1. System: confirms the invitation carries a Workspace. Without one — corrupted data that Flow B prevents — it refuses with `400 WORKSPACE_REQUIRED_FOR_CLIENT_INVITE`.
2. System → Database: looks up the Client Profile for this person and Agency and creates it when missing.
3. System → Database: confirms the person holds no active Workspace membership in that Workspace, and creates one when missing, at the CLIENT role, linked to the Client Profile and recorded as added by the sender of the invitation.
   - At the Database level, the membership identity rule requires a Client Profile for a CLIENT membership, and a person identifier for every other role. A CLIENT membership carries both the person and the Client Profile, so a client can sign in themselves.
4. System: marks the invitation ACCEPTED with the acceptance time.
5. System → Client: the new membership, using the same shape as the non-CLIENT branch.
6. Client: behaves as in Flow C step 6.

---

## Flow E — The Invitee has no account yet and opens the invitation link

This is the branch corrected on 2026-09-23: the invitation destination used to be lost somewhere between registration, verification and sign-in.

1. Invitee → Client: opens the accept link from the email, landing on the invitation screen with the token.
2. Client: sees the Invitee is not signed in and redirects to the sign-in screen, keeping the invitation destination (screen and token) as the place to come back to.
3. Client: records that destination before the Invitee leaves the sign-in screen.
4. Invitee switches to Register — the Client keeps the recorded destination; nothing has to be carried across by hand.
5. Client: the registration screen also records the destination when it arrives there directly, for the case where the redirect lands there in one step.
6. Invitee submits the registration form → Client → System: registers the account. The System creates the person as not yet active and sends a verification code by email.
7. Client: moves to the verification screen. The recorded destination stays in place, untouched by this step.
8. Invitee enters the code → Client → System: verifies it. On success the Client moves to the sign-in screen.
9. Invitee signs in → Client → System: signs in.
   - **Sub-branch — the account has two-factor authentication enabled:** the System answers with a two-factor challenge, and the Client takes the Invitee through the verification screen before the sign-in completes. The recorded destination is untouched by this detour, because it stays within the same tab of the Client.
10. On success the Client stores the session, loads the person's own profile, and returns to the recorded destination — the invitation screen with the token, recorded back at step 3. When nothing was recorded, it falls back to the general landing screen.
11. The Client resumes **Flow C from step 3**: the Invitee is now signed in, so the invitation is accepted with the token.

### Sub-branch — signing in with Google, with no account yet

Steps 6 to 10 are replaced by:

6'. Invitee selects the Google option on the sign-in screen. The link leaves the application entirely and the browser goes to the sign-in provider.
   - The recorded destination was stored at step 3, before leaving the screen, and survives the trip outside the application because it belongs to the browser tab.
7'. System: handles the sign-in with the provider and returns to the Client.
   - **Sub-branch — the account has two-factor authentication enabled:** the System sends the Client to the two-factor screen with its challenge in the address, instead of step 8'. The Client reads the challenge from the address first and falls back to the stored one. After verification it continues to step 10', with the recorded destination still in place from step 6'.
   - Without two-factor authentication: the System sends the Client straight to the callback screen with the session token in the address fragment.
8'. Client: reads the session token from the address, loads the person's own profile and stores the session.
9'. Client: returns to the recorded destination, the invitation screen with the token.
10'. The Client resumes **Flow C from step 3**.

---

## Error paths

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| Invite (Flow A/B) | Caller is not the Owner | 403 | `NOT_AGENCY_OWNER` |
| Invite | Email is already a Member of the Agency | 409 | `ALREADY_AGENCY_MEMBER` |
| Invite | Email already holds a PENDING invitation | 409 | `INVITATION_ALREADY_PENDING` |
| Invite | The Agency already holds 20 PENDING invitations | 409 | `TOO_MANY_PENDING_INVITATIONS` |
| Invite | Workspace does not exist | 404 | `WORKSPACE_NOT_FOUND` |
| Invite | Workspace does not belong to this Agency | 400 | `WORKSPACE_NOT_IN_AGENCY` |
| Invite | Role MANAGER but the Workspace already has an active manager | 409 | `MANAGER_ALREADY_ASSIGNED` |
| Invite | Role CLIENT without a Workspace | 400 | `WORKSPACE_REQUIRED_FOR_CLIENT_INVITE` |
| Accept | The token does not exist | 400 | `INVALID_INVITATION` |
| Accept | The invitation is not PENDING or has passed its expiry time | 400 | `INVALID_INVITATION` |
| Accept | The signed-in email differs from the invited email | 400 | `INVALID_INVITATION` |
| Accept (non-CLIENT) | The person is already a Member of the Agency | 409 | `ALREADY_AGENCY_MEMBER` |
| Accept (CLIENT) | The invitation carries no Workspace | 400 | `WORKSPACE_REQUIRED_FOR_CLIENT_INVITE` |

## Notes

- **Correction applied:** an earlier revision of `spec.md` (3.4.7) stated that registering with the invited email address accepts the invitation automatically. That is wrong for the system as built. There is no automatic acceptance: the invitation is accepted only when the link is opened or the token is submitted after the account exists (Flow E step 11).
- **Correction applied:** an earlier revision recorded an in-app notification alongside the email. Only the email is sent; the system has no shared notification module yet.
- **Correction applied:** an earlier revision recorded the invitation as returning a created-resource answer. The answer is a plain success (HTTP 200), not a created-resource answer.
- **Correction applied:** an earlier revision recorded a fixed 3-day expiry. The expiry now defaults to 30 days and is settable between 1 and 30 days.
- **Correction applied:** an earlier revision listed a direct Workspace-and-role invitation as out of scope. It is in place: the invitation carries a Workspace and a role, and the matching Workspace membership is added on acceptance.
