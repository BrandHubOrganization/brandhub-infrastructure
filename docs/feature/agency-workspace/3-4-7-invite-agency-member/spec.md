# 3.4.7 Invite Agency Member

## Function Trigger
The Owner of an Agency opens the Member list of that Agency (`/agencies/:agencyId/members`) and submits the Invite Member form.

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

## Function Details
### Data Specifications
- **Input required:** Email of the invited person.
- **Input optional:** inviteeName (shown in the invitation email), note (message carried with the invitation), workspaceId (the Workspace to pre-assign; mandatory when role = CLIENT), role (MemberRole: MANAGER, CREATOR, CLIENT), expiryDays (integer 1–30, 30 by default).
- **System data:** Agency Owner identifier, the Agency Member records of the Agency (duplicate check), the PENDING invitations of the Agency (count and duplicate check), the invitation record — id, agencyId, agencyName, invitedEmail, invitedBy, token, note, workspaceId, workspaceName, role (nullable), status (InvitationStatus: PENDING, ACCEPTED, EXPIRED, REVOKED), expiresAt, acceptedAt (nullable), createdAt — and the Workspace record when one is pre-assigned.
- **Output:** The stored invitation, PENDING, carrying its token and expiry time; the invitation email sent to the invited person. No in-app notification is produced.

### Business Rules
- **BR-01:** Only the Owner of the Agency may send invitations. Anybody else is refused with `403 NOT_AGENCY_OWNER`.
- **BR-02:** The invited email must not already be a Member of the Agency; otherwise `409 ALREADY_AGENCY_MEMBER`.
- **BR-03:** The invited email must not already hold a PENDING invitation for this Agency; otherwise `409 INVITATION_ALREADY_PENDING`.
- **BR-04:** An Agency may hold at most 20 PENDING invitations that have not expired; beyond that, `409 TOO_MANY_PENDING_INVITATIONS`.
- **BR-05:** A Workspace sent with the invitation must belong to the same Agency; otherwise `400 WORKSPACE_NOT_IN_AGENCY`.
- **BR-06:** With the role MANAGER, the chosen Workspace must not already have an active manager, since a Workspace holds one manager only; otherwise `409 MANAGER_ALREADY_ASSIGNED`.
- **BR-07:** With the role CLIENT, a Workspace is mandatory from the moment of invitation; otherwise `400 WORKSPACE_REQUIRED_FOR_CLIENT_INVITE`. A Client does not become an Agency Member and needs a Workspace so that a Client Profile and a Workspace membership can be assigned on acceptance.
- **BR-08:** The expiry period is settable between 1 and 30 days and defaults to 30 days; a value outside that range is brought back inside it.
- **BR-09:** The invitation reaches the invited person by email only. No in-app notification is produced, because the system has no shared notification module yet.
- **BR-10:** On acceptance, an invited person with no role or a role other than CLIENT becomes an Agency Member at the MEMBER role — the Agency level knows only OWNER and MEMBER. When the invitation carried a Workspace and a role of MANAGER or CREATOR, the matching Workspace membership is created automatically at the same time.
- **BR-11:** There is no automatic acceptance when somebody registers with the invited email address. The invited person must open the link, or accept with the token, themselves.

### Validation
- Email empty or malformed → `400 VALIDATION_ERROR`.
- Caller is not the Agency Owner → `403 NOT_AGENCY_OWNER`.
- Email already a Member of the Agency → `409 ALREADY_AGENCY_MEMBER`.
- Email already holds a PENDING invitation for this Agency → `409 INVITATION_ALREADY_PENDING`.
- Agency already holds 20 PENDING invitations → `409 TOO_MANY_PENDING_INVITATIONS`.
- Workspace does not exist → `404 WORKSPACE_NOT_FOUND`.
- Workspace does not belong to this Agency → `400 WORKSPACE_NOT_IN_AGENCY`.
- Role MANAGER but the Workspace already has an active manager → `409 MANAGER_ALREADY_ASSIGNED`.
- Role CLIENT without a Workspace → `400 WORKSPACE_REQUIRED_FOR_CLIENT_INVITE`.

## Functionalities
### Normal Flow
1. The Owner opens the Member list of an Agency and fills in the Invite Member form, with the email and any optional values.
2. The client submits the invitation.
3. The system confirms the caller is the Owner of the Agency.
4. The system rejects the invitation if the email already belongs to a Member, already holds a PENDING invitation, or the Agency has reached 20 PENDING invitations.
5. When a Workspace is sent, the system confirms it belongs to the Agency and that it holds no active manager if the role is MANAGER; when the role is CLIENT, the system confirms a Workspace was sent.
6. The system stores the invitation as PENDING with a unique token and the computed expiry time.
7. The system sends the invitation email, with an accept link carrying the token, without holding up the answer to the client.
8. The system returns the stored invitation and the client shows a confirmation and adds the row to the PENDING table.
9. The invited person opens the accept link. When they have no account yet, they register and sign in first; the invitation is never accepted automatically.
10. The system confirms the token, the PENDING status, the unexpired expiry time and that the signed-in email matches the invited email, then records the person as an Agency Member at the MEMBER role, and adds the matching Workspace membership when the invitation carried a Workspace and a role of MANAGER or CREATOR.
11. The system marks the invitation ACCEPTED with the acceptance time and adds the person to the Agency.

### Abnormal Cases
- Caller is not the Agency Owner → `403 NOT_AGENCY_OWNER`, no invitation is stored.
- Email already a Member of the Agency → `409 ALREADY_AGENCY_MEMBER`.
- Email already holds a PENDING invitation for this Agency → `409 INVITATION_ALREADY_PENDING`.
- Agency already holds 20 PENDING invitations → `409 TOO_MANY_PENDING_INVITATIONS`.
- Workspace sent does not belong to this Agency → `400 WORKSPACE_NOT_IN_AGENCY`.
- Role MANAGER but the Workspace already has an active manager → `409 MANAGER_ALREADY_ASSIGNED`.
- Role CLIENT without a Workspace → `400 WORKSPACE_REQUIRED_FOR_CLIENT_INVITE`.
- The invited email has no account in the system yet → the invitation is still sent; the person must register, sign in and accept the invitation themselves.
- The invitation expires before it is accepted → `400 INVALID_INVITATION` on acceptance, and no Agency membership is created.

## Post-Conditions
- A PENDING invitation exists for the Agency, carrying its token, its expiry time and any pre-assigned Workspace and role, and the invitation email has been sent.
- After acceptance: an Agency Member record at the MEMBER role exists for the invited person, and the invitation is ACCEPTED with its acceptance time; when the invitation carried a Workspace with the role MANAGER or CREATOR, the matching Workspace membership also exists.
- No in-app notification is produced at any point.
