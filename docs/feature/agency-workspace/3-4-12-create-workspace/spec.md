# 3.4.12 Create Workspace

| | |
|---|---|
| FR Code | 3.4.12 |
| Feature | Create Workspace |
| Domain | Agency & Workspace (FR 3.4) |
| Role | Agency member (any) — creates a Workspace inside their own Agency |
| Version | 2.2 — 2026-09-23 — rewritten to the standard FR format |
| Document status | Implemented |

## Function Trigger

Begins when an Agency member submits the Create Workspace form with a Workspace name and the target Agency.

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

- **BR-01:** The caller is inserted as a MANAGER of the new Workspace by default.
- **BR-02:** If `assignMembers` names exactly one other user as MANAGER, the creator is automatically demoted to CREATOR and the chosen user holds MANAGER — a Workspace has exactly one active MANAGER at any time.
- **BR-03:** The Workspace row and the creator's membership row are created in a single transaction; the `assignMembers` entries are applied immediately afterwards.
- **BR-04:** `name` empty or `agencyId` missing → 400 `VALIDATION_ERROR`.
- **BR-05:** More than one MANAGER entry in `assignMembers` besides the creator → 409 `MANAGER_ALREADY_ASSIGNED`.
- **BR-06:** The caller must be a member of the target Agency — otherwise 403 `NOT_AGENCY_OWNER`.
- **BR-07:** An `assignMembers` entry whose user is not a member of that Agency → 403 `NOT_AGENCY_MEMBER`.
- **BR-08:** An `assignMembers` entry whose user record does not exist → `USER_NOT_FOUND`.
- **BR-09:** An `assignMembers` entry whose user already has an active membership in the new Workspace is skipped without error (idempotent).

### Validation

- `name` empty → 400 `VALIDATION_ERROR`.
- `agencyId` missing → 400 `VALIDATION_ERROR`.
- `industry` must be a valid WorkspaceIndustry value; `companySize` must be a valid CompanySize value.
- `foundedYear`, when supplied, must be a numeric year.
- Every `assignMembers` role must be one of MANAGER / CREATOR / CLIENT.

## Functionalities

### Normal Flow

1. User opens the Create Workspace form inside an Agency and fills in the name, the Agency, and any optional fields.
2. System verifies the caller is a member of that Agency.
3. System creates the Workspace row with default settings and records the caller as its creator.
4. System inserts the creator's membership with role MANAGER — or with role CREATOR when the MANAGER role is being transferred.
5. System applies the `assignMembers` entries, inserting a membership row for each valid entry.
6. System returns the created Workspace and the user is taken into it; the MANAGER is either the creator or the user designated in `assignMembers`.

### Abnormal Cases

- `name` empty → 400 `VALIDATION_ERROR`; the user corrects the field and resubmits.
- `agencyId` missing → 400 `VALIDATION_ERROR`; the user selects an Agency and resubmits.
- Caller is not a member of the target Agency → 403 `NOT_AGENCY_OWNER`.
- An `assignMembers` entry references a user outside the Agency → 403 `NOT_AGENCY_MEMBER`.
- An `assignMembers` entry references a user that does not exist → `USER_NOT_FOUND`.
- Two entries request MANAGER (besides the creator) → 409 `MANAGER_ALREADY_ASSIGNED`.
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
