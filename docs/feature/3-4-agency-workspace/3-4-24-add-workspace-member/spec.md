# 3.4.19 Add Workspace Member

| | |
|---|---|
| FR Code | 3.4.19 |
| Feature | Add Workspace Member |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER (of the Workspace) |
| Version | 2.3 — 2026-09-23 — rewritten to the standard FR format |
| Document status | Implemented |

## Function Trigger

Begins when the MANAGER of a Workspace adds a member, either by inviting an email address or by assigning a user who already belongs to the Agency.

## Function Description

- **Actors / Roles:** The MANAGER of the Workspace, and only that role.
- **Purpose:** Brings people into the Workspace with the right role, either by inviting them by email or by directly assigning people who are already in the Agency.
- **Interface:** "Add Member" action on the members screen, offering two distinct paths — "Invite by email" and "Assign from Agency", the latter selecting from existing Agency members.
- **Data Processing:** For an invitation the system records a pending invitation and sends an email; for an assignment the system creates active memberships immediately and reports which users were added and which were skipped because they were already active members.

## Screen Layout

Figure — Add Workspace Member Screen:
- An "Add Member" action on `/workspaces/:id/members`.
- An "Invite by email" tab with email, role, and an optional note.
- An "Assign from Agency" tab listing existing Agency members with a role choice per person.
- After an assignment, the result shows the members added and a notice for the users skipped because they were already members.

## Function Details

### Data Specifications

- **Input required:** The Workspace identifier; the caller's authenticated identity. For an invitation: email and role. For an assignment: at least one entry of `{userId, role}`.
- **Input optional:** note (invitation only).
- **System data:** The caller's role in the Workspace; the count of active MANAGERs in the Workspace; whether the email already has an active membership or a pending invitation; the Agency membership of each assigned user.
- **Output:** For an invitation, an acknowledgement with no content returned. For an assignment, the members added — id, workspaceId, userId, fullName, email, clientProfileId, role, joinedAt, isActive — together with `skippedUserIds`, the identifiers skipped because those users were already active members. `role` is one of MANAGER, CREATOR, CLIENT.

### Business Rules

- **BR-27:** Invite path — only OWNER/MANAGER may invite; an already-active member cannot be re-invited (→ 409 `ALREADY_IN_WORKSPACE`, guard checked first); a second invite is blocked while a pending unexpired invitation exists for the same email (→ 409 `INVITATION_ALREADY_PENDING`, guard checked second); the invitation token is a random UUID with an expiry window.
- **BR-35:** `@RequireRoleAspect` re-reads the caller's role from the DB at request time; `SystemRole.ADMIN` bypasses the check. The role check (MANAGER required) runs before any service-level guard.
- **BR-02:** The invitation path does not create a membership immediately — it records a pending invitation that the invitee must accept before becoming a member.
- **BR-05 (duplicate-MANAGER guard, checked third):** Requesting the MANAGER role while the Workspace already has an active MANAGER → 409 `MANAGER_ALREADY_ASSIGNED`, on both the invitation and the assignment path; a Workspace has exactly one active MANAGER at any time.
- **BR-06:** The assignment path creates active memberships immediately and needs no acceptance step.
- **BR-07:** An assignment entry whose user already has an active membership in the Workspace is skipped without error and its identifier is reported in `skippedUserIds`; the remaining entries in the batch are still processed.
- **BR-08:** An assignment entry whose user is not a member of the Agency → 403 `NOT_AGENCY_MEMBER`.
- **BR-09:** An assignment entry whose user record does not exist → `USER_NOT_FOUND`.
- **BR-31:** Code `MemberRole` enum has three workspace roles — MANAGER, CREATOR, CLIENT; there is no Workspace-level OWNER (OWNER exists only at Agency level, `AgencyMemberRole`). ⚠ BA conflict (needs team decision): `Section5_Requirement_Appendix.md` BR-31 still lists "OWNER, MANAGER, CREATOR, CLIENT" as the four workspace roles — that wording is stale against the current code, which moved OWNER to the Agency level and left `MemberRole` with only MANAGER/CREATOR/CLIENT (see `MemberRole.java` comment: "OWNER đã chuyển lên cấp Agency"). Invited or assigned roles must be one of MANAGER, CREATOR, CLIENT.
- **BR-32:** Role assignment happens at invite time; the role is stored on the invitation and carried to the member row on acceptance.
- **BR-11:** Roles are independent per Workspace — the same user may hold a different role in another Workspace of the same Agency.

### Validation

- Caller must be the MANAGER of that Workspace; otherwise 403 `FORBIDDEN` (BR-35). Display: MSG39.
- email empty → Display: MSG02.
- role empty → Display: MSG02.
- Invitation: `email` must be a well-formed email address; otherwise Display: MSG04.
- Invitation: `role` must be one of MANAGER, CREATOR, CLIENT (BR-31, BR-82); otherwise Display: MSG95.
- Assignment: the member list must contain at least one entry; otherwise 400 `VALIDATION_ERROR`.
- Assignment: every `userId` must belong to an Agency member; otherwise 403 `NOT_AGENCY_MEMBER`.

## Functionalities

### Normal Flow

1. MANAGER opens the members screen and chooses "Add Member".
2. On the invite path, the MANAGER enters an email, a role, and an optional note; on the assign path, the MANAGER picks one or more existing Agency members and a role for each.
3. System confirms the caller holds the MANAGER role in the Workspace (BR-35); otherwise the request fails with 403 `FORBIDDEN`.
4. Invite path: system normalises the email, checks for an existing active membership and for a pending invitation, and applies the single-MANAGER rule when the role is MANAGER (BR-27, BR-05).
5. Invite path: system records a pending invitation with an expiry and sends the invitation email (BR-27, BR-02); toast MSG33.
6. Assign path: system validates each entry against Agency membership, skips users who are already active members, applies the single-MANAGER rule, and creates active memberships immediately.
7. Assign path: system returns the members added together with the identifiers of the users skipped.
8. Screen refreshes the member list with the members added and can show a notice for the skipped users.

### Abnormal Cases

- 3.a1: Caller is not the MANAGER of the Workspace (BR-35) → 403 `FORBIDDEN`, toast MSG39. 3.a2: The screen blocks the action; the caller cannot add members without the MANAGER role.
- 4.a1: Invitation for an email that already has an active membership (BR-27) → 409 `ALREADY_IN_WORKSPACE`, toast MSG34. 4.a2: The MANAGER checks the existing member list instead of re-inviting.
- 4.b1: Invitation for an email that already has a pending, unexpired invitation (BR-27) → 409 `INVITATION_ALREADY_PENDING`, toast MSG35. 4.b2: The MANAGER waits for the pending invitation to be accepted or to expire before retrying.
- 4.c1: MANAGER role requested while the Workspace already has an active MANAGER (BR-05) → 409 `MANAGER_ALREADY_ASSIGNED`, Display: MSG95 (generic role-rejection message; no dedicated MSG code exists for this conflict — see report). 4.c2: The MANAGER picks CREATOR or CLIENT instead, or hands over the MANAGER role first.
- Assignment entry whose user is outside the Agency → 403 `NOT_AGENCY_MEMBER`.
- Assignment entry whose user does not exist → `USER_NOT_FOUND`.
- Assignment where some users are already active members → those identifiers appear in `skippedUserIds`, no entry for them appears in the added list, no error is raised, and the rest of the batch is processed.
- Invitation, email missing → Display: MSG02. Role missing → Display: MSG02. Email malformed → Display: MSG04.
- Assignment with an empty member list → 400 `VALIDATION_ERROR`.
- Invitation of a person who has an account in the system but has never joined this Agency → the invitation is still sent, because the invite path does not require Agency membership.
- Assignment of a user who holds a different role in another Workspace of the same Agency → valid, since roles are independent per Workspace.

## Post-Conditions

- Invite path: a pending invitation exists for the email with an expiry date, and the invitation email has been dispatched.
- Assign path: active membership rows exist for every valid entry, and the identifiers of the skipped users have been reported.
- The Workspace still has exactly one active MANAGER.

## Out of Scope

- None.

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
