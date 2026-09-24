# 3.4.10 List Workspace

| | |
|---|---|
| FR Code | 3.4.10 |
| Feature | List Workspace |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER / CREATOR / CLIENT |
| Version | 2.2 — 2026-09-23 — rewritten to the standard FR format |
| Document status | Implemented |

## Function Trigger

Begins when a signed-in user opens the Workspace list screen.

## Function Description

- **Actors / Roles:** Any Workspace member (MANAGER, CREATOR, or CLIENT).
- **Purpose:** Shows every Workspace the current user belongs to, so the user can pick one to work in.
- **Interface:** Workspace list screen of the current user — a list of Workspace entries, not scoped under an Agency route.
- **Data Processing:** The system reads the current user's active Workspace memberships, loads the Workspace records those memberships point to, and maps each one to a Workspace summary.

## Screen Layout

Figure — Workspace List Screen:
- A single list screen titled with the user's Workspaces.
- Each row/card shows the Workspace name and branding (logo, brand colour, tagline).
- An empty state is shown when the user belongs to no Workspace.
- A separate "Workspaces I manage" view lists the Workspaces where the user is MANAGER, each with the member count.

## Function Details

### Data Specifications

- **Input required:** The caller's authenticated identity (taken from the session principal).
- **Input optional:** None.
- **System data:** Active Workspace membership rows of the current user; the Workspace records those memberships reference.
- **Output:** The Workspaces the user belongs to — id, name, agencyId, settings, industry, companySize, website, phone, location, description, brandColor, logoIcon, logoUrl, tagline, foundedYear, facebookUrl, linkedinUrl, instagramUrl, createdAt. The "managed" listing additionally returns id, name, role, and memberCount per Workspace.

### Business Rules

- **BR-01:** Only Workspaces where the current user has an active membership row are returned, regardless of role (MANAGER, CREATOR, CLIENT).
- **BR-02:** The listing is scoped to the current user, not to an Agency — an Agency owner does not automatically see every Workspace.
- **BR-03:** The listing is read-only; there is no business error code for it. The only failure is a missing session, rejected with 401 through the shared authentication mechanism.

### Validation

- The caller must be signed in; otherwise the request is rejected with 401.
- A user with no Workspace membership must receive an empty list, not an error.

## Functionalities

### Normal Flow

1. User opens the Workspace list screen.
2. System reads the current user's active Workspace memberships.
3. System loads the Workspace records referenced by those memberships.
4. System maps each Workspace to a Workspace summary.
5. Screen shows the Workspaces the user belongs to; an empty list is shown when the user belongs to none.

### Abnormal Cases

- User belongs to no Workspace → an empty list is returned and an empty state is displayed.
- User is not signed in → 401 through the shared authentication mechanism.

## Post-Conditions

- No data is changed; the Workspaces the user belongs to are displayed.

## Out of Scope

- None.

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
