# 3.4.13 View Workspace Profile

| | |
|---|---|
| FR Code | 3.4.13 |
| Feature | View Workspace Profile |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER / CREATOR / CLIENT |
| Version | 2.3 — 2026-09-23 — rewritten to the standard FR format |
| Document status | Implemented |

## Function Trigger

Begins when a Workspace member opens the profile of a Workspace.

## Function Description

- **Actors / Roles:** Workspace members with role MANAGER, CREATOR, or CLIENT.
- **Purpose:** Shows the Workspace's details — timezone configuration and branding/company information — so members understand which timezone the Workspace runs on and how its branding is configured.
- **Interface:** Workspace profile screen at `/workspaces/:id/profile`, showing the Workspace details and branding.
- **Data Processing:** The system loads the Workspace, confirms the caller is an active member of that same Workspace, and maps the record to a Workspace profile, parsing the stored settings into timezone and default platforms.

## Screen Layout

Figure — Workspace Profile Screen:
- Header with the Workspace name, logo, and brand colour.
- Details block: industry, company size, website, phone, location, description, tagline, founded year.
- Social links block: Facebook, LinkedIn, Instagram.
- Settings block showing the Workspace timezone and default platforms.

## Function Details

### Data Specifications

- **Input required:** The Workspace identifier; the caller's authenticated identity.
- **Input optional:** None.
- **System data:** The Workspace record; the caller's active membership row; the stored settings payload (timezone, default platforms).
- **Output:** The Workspace profile — id, name, agencyId, settings (holding timezoneConfig and defaultPlatforms), industry, companySize, website, phone, location, description, brandColor, logoIcon, logoUrl, tagline, foundedYear, facebookUrl, linkedinUrl, instagramUrl, createdAt.

### Business Rules

- **BR-29:** Multi-tenancy — every workspace-scoped resource carries workspaceId; a caller with no active membership in the Workspace cannot read it regardless of system role (except ADMIN, cross-workspace). The caller's active membership in the very Workspace being viewed is verified explicitly, not through a generic role check.
- Workspace that does not exist → 404 `WORKSPACE_NOT_FOUND`.
- Caller not an active member of that Workspace → 403 `WORKSPACE_ACCESS_DENIED`.
- Failure to parse the stored settings falls back to empty settings (no timezone, no default platforms) without raising an error.
- There is a single Workspace-level timezone configuration — not one per Client or per Task.

### Validation

- The Workspace must exist; otherwise 404 `WORKSPACE_NOT_FOUND`.
- The caller must hold an active membership in that Workspace (BR-29); otherwise 403 `WORKSPACE_ACCESS_DENIED`.
- A malformed settings payload must degrade to empty settings rather than fail the request.

## Functionalities

### Normal Flow

1. Member opens `/workspaces/:id/profile`.
2. System loads the Workspace; if it does not exist, the request fails with 404 `WORKSPACE_NOT_FOUND`.
3. System confirms the caller has an active membership in that Workspace (BR-29); otherwise the request fails with 403 `WORKSPACE_ACCESS_DENIED`.
4. System maps the Workspace to its profile, parsing the stored settings into timezone and default platforms.
5. Screen displays the Workspace profile, including the Workspace timezone.

### Abnormal Cases

- 2.a1: The Workspace does not exist → 404 `WORKSPACE_NOT_FOUND`, toast MSG38. 2.a2: The member returns to the Workspace list and picks a valid Workspace.
- 3.a1: The caller has no active membership in that Workspace (BR-29) → 403 `WORKSPACE_ACCESS_DENIED`, toast MSG40. 3.a2: The member returns to the Workspace list; only Workspaces they belong to are shown.
- 4.a1: Stored settings are malformed → the screen shows empty settings instead of failing. 4.a2: No further action is needed; the member may ask a MANAGER to re-save the settings.
- Workspace serves Clients across several locations → still a single Workspace-level timezone; per-Campaign timezones are outside the current scope.

## Post-Conditions

- No data is changed; the Workspace profile is displayed.

## Out of Scope

- Timezone per Task or per Campaign (only one Workspace-level timezone is in scope).
- A media package template or an active-Client list on the profile — neither exists in the current data returned, and their inclusion is not yet decided.

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
