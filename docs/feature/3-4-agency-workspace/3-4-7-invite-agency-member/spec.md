# 3.4.7 Invite Agency Member

> V2 (2026-10-02): added the inline auto-suggest lookup and the CLIENT-profile-selection step on accept — see the new subsections below. Inviting a CLIENT now also happens from the dedicated Workspace Client screen (`/workspaces/:id/clients`, FR 3.3.3) using the same underlying `WorkspaceService.inviteMember` / `AgencyInvitation` mechanism described here; this spec covers both entry points since the role-CLIENT rules (BR-27, mandatory Workspace, accept flow) are identical either way.

## Function Trigger
The Owner/Manager of an Agency opens the Member list of that Agency (`/agencies/:agencyId/members`) or a workspace's Client list (`/workspaces/:id/clients`) and submits the Invite form.

## Function Description
- **Actors / Roles:** Agency Owner (sender) and the invited person (who may not have an account yet).
- **Purpose:** Let the Owner bring another person into the Agency by email invitation, optionally pre-assigning that person to one Workspace with a role, so they can start working as soon as they accept.
- **Interface:** Member list page (`/agencies/:agencyId/members`) with an "Invite member" action — a form with a required email and optional invitee name, note, Workspace, role and expiry period. The person invited accepts through the link in the invitation email.
- **Data Processing:** The system confirms the caller is the Owner of the Agency, then checks the duplicate, pending-limit and Workspace rules, stores the invitation as PENDING with a unique token and an expiry time, and sends the invitation email with an accept link carrying that token. Accepting the invitation later turns the invited person into a Member of the Agency, and adds them to the chosen Workspace when one was pre-assigned.

## Screen Layout
Figure — Invite Member form:
- Email (required), invitee name, note, Workspace selector, role selector and expiry period (1–30 days, 30 by default).
- When the role CLIENT is selected, a Workspace must also be selected before the form can be submitted.
- On success a confirmation appears and the new PENDING invitation shows in the invitation table.

Figure — Invite Client dialog (`/workspaces/:id/clients`, "Add client"):
- Email input only (no role/Workspace selector — both are implicit: role is always CLIENT, Workspace is the current one), optional note.
- As the Owner/Manager types a valid email, two independent inline hints may appear, debounced:
  1. A generic "this user already has an account" hint (existing user-lookup, shared with the regular Invite Member form).
  2. A CLIENT-specific hint from `GET /api/v1/agencies/{agencyId}/invite-lookup?email=` — shown only when the email is already an active CLIENT in another workspace of the **same** Agency. It names that workspace and explains that sending the invite will reuse the existing Client Profile link rather than create a separate one. No hint is shown if the email is a CLIENT only in a *different* Agency (cross-Agency data is never surfaced here).
- Submitting still goes through the same `WorkspaceService.inviteMember` / `AgencyInvitation` mechanism as the regular Invite Member form — the hint is informational only, not a shortcut that skips the invite step.

## Function Details
### Data Specifications
- **Input required:** Email of the invited person.
- **Input optional:** inviteeName (shown in the invitation email), note (message carried with the invitation), workspaceId (the Workspace to pre-assign; mandatory when role = CLIENT), role (MemberRole: MANAGER, CREATOR, CLIENT), expiryDays (integer 1–30, 30 by default).
- **System data:** Agency Owner identifier, the Agency Member records of the Agency (duplicate check), the PENDING invitations of the Agency (count and duplicate check), the invitation record — id, agencyId, agencyName, invitedEmail, invitedBy, token, note, workspaceId, workspaceName, role (nullable), status (InvitationStatus: PENDING, ACCEPTED, EXPIRED, REVOKED), expiresAt, acceptedAt (nullable), createdAt — and the Workspace record when one is pre-assigned.
- **Output:** The stored invitation, PENDING, carrying its token and expiry time; the invitation email sent to the invited person. No in-app notification is produced.

### Business Rules
- **BR-27:** Invite: only Owner/Manager-equivalent (here, the Agency Owner) may invite; an already-active member cannot be re-invited; a second invite is blocked while a pending, unexpired invitation exists for the same email; invitation token is a random UUID with an expiry window. Anybody other than the Owner is refused with `403 NOT_AGENCY_OWNER`.
- The invited email must not already be a Member of the Agency; otherwise `409 ALREADY_AGENCY_MEMBER` (BR-27).
- The invited email must not already hold a PENDING invitation for this Agency; otherwise `409 INVITATION_ALREADY_PENDING` (BR-27).
- An Agency may hold at most 20 PENDING invitations that have not expired; beyond that, `409 TOO_MANY_PENDING_INVITATIONS`.
- A Workspace sent with the invitation must belong to the same Agency; otherwise `400 WORKSPACE_NOT_IN_AGENCY`.
- With the role MANAGER, the chosen Workspace must not already have an active manager, since a Workspace holds one manager only; otherwise `409 MANAGER_ALREADY_ASSIGNED`.
- With the role CLIENT, a Workspace is mandatory from the moment of invitation; otherwise `400 WORKSPACE_REQUIRED_FOR_CLIENT_INVITE`. A Client does not become an Agency Member and needs a Workspace so that a Client Profile and a Workspace membership can be assigned on acceptance.
- **(V2) Internal member cannot be invited as CLIENT:** the "already a Member of the Agency" check (BR-27 above, `409 ALREADY_AGENCY_MEMBER`) applies uniformly to every role, including CLIENT — a person already on the Agency's internal roster (OWNER/MANAGER/MEMBER) cannot also be invited as that Agency's own client. No separate error code exists for this case; it is the same `ALREADY_AGENCY_MEMBER` check.
- **(V2) Auto-suggest hint, not a hard rule:** `GET /api/v1/agencies/{agencyId}/invite-lookup?email=` is read-only and advisory — it never blocks or auto-fills the submit. It returns `{ userExists, isAlreadyClientInAgency, existingWorkspaces[] }`, computed by resolving the email to a User, finding every `ClientProfile` they own, and checking whether any is linked (`workspace_members.client_profile_id`) to an active CLIENT membership in a workspace whose `agencyId` matches the current Agency. Workspaces of other Agencies are never included.
- **(V2) Client Profile selection on accept:** when accepting a CLIENT invitation, the invited person must choose — from `GET /api/v1/client-profile/mine` — one of the Client Profiles they already own, or submit a `newClientProfile` payload to create one inline. If they own none and submit neither, the accept is rejected with `400 CLIENT_PROFILE_REQUIRED_FOR_ACCEPT`. A profile chosen this way is not required to be new or Agency-specific — reusing a profile already linked to a workspace of a different Agency is allowed (Client Profiles are never Agency-scoped, FR 3.3.3 V2).
- The expiry period is settable between 1 and 30 days and defaults to 30 days; a value outside that range is brought back inside it (BR-27, "invitation token is a random UUID with an expiry window").
  - **⚠ BA conflict (needs team decision):** `docs/ba/03-agency-workspace-management.md` states a fixed 3-day expiry with no configurability. The current code (`AgencyServiceImpl.INVITATION_EXPIRY_DAYS`) implements 30 days, adjustable 1–30. This spec documents the code's actual behavior; the 3-day BA figure and the 30-day code figure disagree and have not been reconciled — do not change either side without a team decision on which number is authoritative.
- The invitation reaches the invited person by email only. No in-app notification is produced, because the system has no shared notification module yet.
- On acceptance, an invited person with no role or a role other than CLIENT becomes an Agency Member at the MEMBER role — the Agency level knows only OWNER and MEMBER. When the invitation carried a Workspace and a role of MANAGER or CREATOR, the matching Workspace membership is created automatically at the same time.
- On acceptance, an invited person with role CLIENT never becomes an Agency Member — they instead select or create a Client Profile (see the V2 bullet above) and are added directly to the pre-assigned Workspace as a CLIENT member linking that profile.
- There is no automatic acceptance when somebody registers with the invited email address. The invited person must open the link, or accept with the token, themselves.

### Validation
- Email empty or malformed → Display: MSG02 / MSG04
- Caller is not the Agency Owner → Display: MSG39
- Email already a Member of the Agency → Display: MSG34
- Email already holds a PENDING invitation for this Agency → Display: MSG35
- Agency already holds 20 PENDING invitations → Display: MSG38 (closest fit — no dedicated MSG code for a pending-invitation cap)
- Workspace does not exist → Display: MSG38
- Workspace does not belong to this Agency → Display: MSG38 (closest fit — no dedicated MSG code for this case)
- Role MANAGER but the Workspace already has an active manager → Display: MSG38 (closest fit — no dedicated MSG code for this case)
- Role CLIENT without a Workspace → Display: MSG02 (closest fit — no dedicated MSG code for this case)

## Functionalities
### Normal Flow
1. The Owner opens the Member list of an Agency and fills in the Invite Member form, with the email and any optional values.
2. The client submits the invitation.
3. The system confirms the caller is the Owner of the Agency.
4. The system rejects the invitation if the email already belongs to a Member, already holds a PENDING invitation, or the Agency has reached 20 PENDING invitations.
5. When a Workspace is sent, the system confirms it belongs to the Agency and that it holds no active manager if the role is MANAGER; when the role is CLIENT, the system confirms a Workspace was sent.
6. The system stores the invitation as PENDING with a unique token and the computed expiry time.
7. The system sends the invitation email, with an accept link carrying the token, without holding up the answer to the client.
8. The system returns the stored invitation and the client shows a confirmation and adds the row to the PENDING table; toast MSG33.
9. The invited person opens the accept link. When they have no account yet, they register and sign in first; the invitation is never accepted automatically.
10. The system confirms the token, the PENDING status, the unexpired expiry time and that the signed-in email matches the invited email, then records the person as an Agency Member at the MEMBER role, and adds the matching Workspace membership when the invitation carried a Workspace and a role of MANAGER or CREATOR.
11. The system marks the invitation ACCEPTED with the acceptance time and adds the person to the Agency.

### Abnormal Cases
- 3.a1: Caller is not the Agency Owner (BR-27) → `403 NOT_AGENCY_OWNER`, toast MSG39; no invitation is stored. 3.a2: The caller returns to the Agency list and opens an Agency they own.
- 4.a1: Email already a Member of the Agency (BR-27) → `409 ALREADY_AGENCY_MEMBER`, toast MSG34. 4.a2: The Owner picks a different email or reviews the existing member.
- 4.b1: Email already holds a PENDING invitation for this Agency (BR-27) → `409 INVITATION_ALREADY_PENDING`, toast MSG35. 4.b2: The Owner waits for that invitation to resolve or cancels it (3.4.8) before re-inviting.
- 4.c1: Agency already holds 20 PENDING invitations → `409 TOO_MANY_PENDING_INVITATIONS`, toast MSG38 (closest fit). 4.c2: The Owner cancels stale invitations (3.4.8) to free a slot, then resubmits.
- 5.a1: Workspace sent does not belong to this Agency → `400 WORKSPACE_NOT_IN_AGENCY`, toast MSG38 (closest fit). 5.a2: The Owner selects a Workspace that belongs to this Agency.
- 5.b1: Role MANAGER but the Workspace already has an active manager (BR-27, one-manager-per-workspace) → `409 MANAGER_ALREADY_ASSIGNED`, toast MSG38 (closest fit). 5.b2: The Owner chooses a different Workspace or role.
- 5.c1: Role CLIENT without a Workspace → `400 WORKSPACE_REQUIRED_FOR_CLIENT_INVITE`, Display: MSG02 (closest fit). 5.c2: The Owner selects a Workspace before submitting.
- 9.a1: The invited email has no account in the system yet → the invitation is still sent; no error. 9.a2: The person must register, sign in and accept the invitation themselves.
- 10.a1: The invitation expires before it is accepted → `400 INVALID_INVITATION` on acceptance, toast MSG38 (closest fit — no dedicated MSG code for an expired invitation); no Agency membership is created. 10.a2: The invited person asks the Owner to send a new invitation.
- 10.b1 (V2, CLIENT only): The invited person owns no Client Profile and submits neither `clientProfileId` nor `newClientProfile` → `400 CLIENT_PROFILE_REQUIRED_FOR_ACCEPT`, no Workspace membership is created. 10.b2: The accept screen requires them to pick an existing profile or fill the inline create-profile form before retrying.
- 10.c1 (V2, CLIENT only): `clientProfileId` is submitted but belongs to a different user → `403 CLIENT_PROFILE_NOT_OWNED`. 10.c2: The accept screen re-lists only the profiles the signed-in user actually owns.

## Post-Conditions
- A PENDING invitation exists for the Agency, carrying its token, its expiry time and any pre-assigned Workspace and role, and the invitation email has been sent.
- After acceptance: an Agency Member record at the MEMBER role exists for the invited person, and the invitation is ACCEPTED with its acceptance time; when the invitation carried a Workspace with the role MANAGER or CREATOR, the matching Workspace membership also exists.
- After acceptance of a CLIENT invitation: no Agency Member record is created; a CLIENT `workspace_members` row exists in the pre-assigned Workspace, linking the Client Profile the invited person selected or created — the same profile they can keep reusing across any other Workspace/Agency.
- No in-app notification is produced at any point.
