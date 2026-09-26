# 3.4.12 Create Workspace

| | |
|---|---|
| FR Code | 3.4.12 |
| Feature | Create Workspace |
| Domain | Agency & Workspace (FR 3.4) |
| Role | Agency Owner only — creates a Workspace inside their own Agency |
| Version | 2.3 — 2026-09-24 — fixed BA conflict: only the Agency Owner may create a Workspace |
| Document status | Implemented |

## Function Trigger

Begins when the Agency Owner submits the Create Workspace form with a Workspace name and the target Agency.

**Fixed 2026-09-24:** an earlier version of this spec/code allowed any active Agency member to create a Workspace (the `NOT_AGENCY_OWNER` guard only checked membership, not role — a real gap against BA, which restricts this to the Agency Owner). Now corrected in `WorkspaceServiceImpl.createWorkspace` to require `AgencyMemberRole.OWNER`.

## Function Description

- **Actors / Roles:** Any member of the Agency in which the Workspace is created.
- **Purpose:** Creates a Workspace inside an Agency; the creator becomes its MANAGER by default, and members may optionally be assigned — including transferring the MANAGER role — at creation time.
- **Interface:** Create Workspace form — name input, Agency field, the extended Workspace profile fields (industry, company size, website, phone, location, description, brand colour, logo icon, tagline, founded year, Facebook/LinkedIn/Instagram links), and an optional member-assignment block.
- **Data Processing:** The system validates the request, creates the Workspace row, inserts the creator's membership in the same transaction, then applies any assignment entries — demoting the creator to CREATOR when the MANAGER role was transferred.

## Screen Layout

Figure — Create Workspace Screen:
- A single form screen scoped to one Agency.
- Name input (required) and the target Agency (required).
- Optional extended fields: industry, company size, website, phone, location, description, brand colour, logo icon, tagline, founded year, and social links.
- Optional member-assignment block letting the user pick Agency members and a role each (MANAGER / CREATOR / CLIENT).
- A "Create" action; on success the user is taken into the new Workspace.

## Function Details

### Data Specifications

- **Input required:** name; agencyId (carried in the request payload, not in the path).
- **Input optional:** industry (WorkspaceIndustry enum), companySize (CompanySize enum), website, phone, location, description, brandColor, logoIcon, tagline, foundedYear, facebookUrl, linkedinUrl, instagramUrl, assignMembers (list of `{userId, role}` with role in MANAGER / CREATOR / CLIENT).
- **System data:** The caller's authenticated identity; the Agency membership of the caller; default Workspace settings; the created Workspace identifier.
- **Output:** The created Workspace — id, name, agencyId, settings, industry, companySize, website, phone, location, description, brandColor, logoIcon, logoUrl, tagline, foundedYear, facebookUrl, linkedinUrl, instagramUrl, createdAt.

### Business Rules

- **BR-24:** Creating a workspace inserts the creator as a workspace_members row with role MANAGER (or CREATOR when the MANAGER role is transferred via `assignMembers`), isActive=true. (Note: the code builds the Workspace row directly and does not show an explicit slug-generation step; any slug behavior described elsewhere is design intent, not confirmed against this method — see report.)
- If `assignMembers` names exactly one other user as MANAGER, the creator is automatically demoted to CREATOR and the chosen user holds MANAGER — a Workspace has exactly one active MANAGER at any time.
- The Workspace row and the creator's membership row are created in a single transaction; the `assignMembers` entries are applied immediately afterwards.
- `name` empty or `agencyId` missing → 400 `VALIDATION_ERROR`.
- More than one MANAGER entry in `assignMembers` besides the creator → 409 `MANAGER_ALREADY_ASSIGNED`.
- **BR-29:** Multi-tenancy — the caller must be an active member of the target Agency (its parent scope). On top of that, the caller must specifically hold the OWNER role in that Agency — otherwise 403 `NOT_AGENCY_OWNER`. Both checks are the first guard clause in `createWorkspace`, checked before the Workspace row is built.
- An `assignMembers` entry whose user is not a member of that Agency → 403 `NOT_AGENCY_MEMBER`.
- An `assignMembers` entry whose user record does not exist → `USER_NOT_FOUND`.
- An `assignMembers` entry whose user already has an active membership in the new Workspace is skipped without error (idempotent).

### Validation

- `name` empty → Display: MSG02.
- `agencyId` missing → 400 `VALIDATION_ERROR`.
- `industry` must be a valid WorkspaceIndustry value; `companySize` must be a valid CompanySize value.
- `foundedYear`, when supplied, must be a numeric year.
- Every `assignMembers` role must be one of MANAGER / CREATOR / CLIENT (BR-31 — workspace roles in code are the MemberRole enum: MANAGER, CREATOR, CLIENT; there is no workspace-level OWNER, OWNER exists only at Agency level).

## Functionalities

### Normal Flow

1. User opens the Create Workspace form inside an Agency and fills in the name, the Agency, and any optional fields.
2. System verifies the caller is an active member of that Agency (BR-29).
3. System creates the Workspace row with default settings and records the caller as its creator.
4. System inserts the creator's membership with role MANAGER — or with role CREATOR when the MANAGER role is being transferred (BR-24).
5. System applies the `assignMembers` entries, inserting a membership row for each valid entry.
6. System returns the created Workspace and the user is taken into it; the MANAGER is either the creator or the user designated in `assignMembers`. Toast MSG31.

### Abnormal Cases

- 1.a1: `name` empty → Display: MSG02. 1.a2: The user corrects the field and resubmits.
- 1.b1: `agencyId` missing → 400 `VALIDATION_ERROR`. 1.b2: The user selects an Agency and resubmits.
- 2.a1: Caller is not an active member of the target Agency, or is a member but not its OWNER (BR-29) → 403 `NOT_AGENCY_OWNER`, toast MSG39. 2.a2: The user is returned to the Agency list; the Workspace is not created.
- 5.a1: An `assignMembers` entry references a user outside the Agency → 403 `NOT_AGENCY_MEMBER`, toast MSG39. 5.a2: The user removes or corrects that entry and resubmits.
- 5.b1: An `assignMembers` entry references a user that does not exist → `USER_NOT_FOUND`, toast MSG38. 5.b2: The user removes or corrects that entry and resubmits.
- 5.c1: Two entries request MANAGER besides the creator (BR-05) → 409 `MANAGER_ALREADY_ASSIGNED`, toast MSG39. 5.c2: The user reduces the assignment to a single MANAGER and resubmits.
- No `assignMembers` supplied → the creator is the only MANAGER.
- The creator lists themselves in `assignMembers` as MANAGER → not treated as "another user"; the creator keeps MANAGER.

## Post-Conditions

- A Workspace row exists inside the Agency.
- A membership row exists for the creator (MANAGER by default, CREATOR when the role was transferred) and for every valid `assignMembers` entry.
- The new Workspace has exactly one active MANAGER.

## Out of Scope

- Creating a Workspace from a saved Template (see FR 3.4.17 Save Workspace Template — the reverse direction; creating from a template is a UX extension and not required).

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
