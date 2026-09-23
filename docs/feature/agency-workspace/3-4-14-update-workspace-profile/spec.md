# 3.4.14 Update Workspace Profile

| | |
|---|---|
| FR Code | 3.4.14 |
| Feature | Update Workspace Profile |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER (only) |
| Version | 2.3 — 2026-09-23 — rewritten to the standard FR format |
| Document status | Implemented |

## Function Trigger

Begins when the MANAGER of a Workspace submits changes to the Workspace profile or settings.

## Function Description

- **Actors / Roles:** The MANAGER of the Workspace, and only that role.
- **Purpose:** Lets the Workspace MANAGER keep the Workspace's details and settings accurate with day-to-day operations.
- **Interface:** Edit Workspace profile screen at `/workspaces/:id/profile/edit`, plus a separate logo upload control.
- **Data Processing:** The system loads the Workspace, merges the supplied fields into the record and settings, and returns the updated Workspace profile.

## Screen Layout

Figure — Update Workspace Profile Screen:
- Edit form pre-filled with the current name, timezone, default platforms, industry, company size, website, phone, and location.
- A separate logo upload control beside the Workspace branding block.
- A "Save" action; on success a confirmation toast is shown and the profile is refreshed.

## Function Details

### Data Specifications

- **Input required:** The Workspace identifier; the caller's authenticated identity.
- **Input optional:** name, timezone, defaultPlatforms (list), industry (WorkspaceIndustry enum), companySize (CompanySize enum), website, phone, location. For the logo control: the uploaded image file.
- **System data:** The existing Workspace record and its stored settings; the caller's role in that Workspace; the stored URL of the uploaded logo.
- **Output:** The updated Workspace profile — id, name, agencyId, settings (timezoneConfig, defaultPlatforms), industry, companySize, website, phone, location, description, brandColor, logoIcon, logoUrl, tagline, foundedYear, social links, createdAt.

### Business Rules

- **BR-01:** Only the MANAGER of that Workspace may update it; there is no OWNER role at Workspace level — OWNER exists only at Agency level.
- **BR-02:** A caller who is not the Workspace MANAGER → 403 `FORBIDDEN`.
- **BR-03:** The Workspace must exist → otherwise 404 `WORKSPACE_NOT_FOUND`.
- **BR-04:** Fields not supplied in the request keep their current values; the stored settings are merged rather than replaced.
- **BR-05:** A failure while reading the uploaded logo file → 400 `FILE_READ_ERROR`.
- **BR-06:** The logo is uploaded through its own dedicated action, not through the profile settings update.

### Validation

- The caller must hold the MANAGER role in that Workspace; otherwise 403 `FORBIDDEN`.
- The Workspace must exist; otherwise 404 `WORKSPACE_NOT_FOUND`.
- `industry` must be a valid WorkspaceIndustry value; `companySize` must be a valid CompanySize value.
- An unreadable logo file → 400 `FILE_READ_ERROR`.

## Functionalities

### Normal Flow

1. MANAGER opens `/workspaces/:id/profile/edit` and edits the name, timezone, default platforms, industry, company size, website, phone, or location.
2. System confirms the caller holds the MANAGER role in that Workspace; otherwise the request fails with 403 `FORBIDDEN`.
3. System loads the Workspace; if it does not exist the request fails with 404 `WORKSPACE_NOT_FOUND`.
4. System applies the supplied fields and merges the new timezone / default platforms into the stored settings, keeping the previous values for fields left out.
5. System returns the updated Workspace profile; the screen shows a success confirmation.

### Abnormal Cases

- Caller is not the MANAGER of that Workspace → 403 `FORBIDDEN`.
- Workspace does not exist → 404 `WORKSPACE_NOT_FOUND`.
- Logo upload file cannot be read → 400 `FILE_READ_ERROR`; the user retries with another file.
- The timezone is changed while Tasks or Livestreams are already scheduled for the old timezone → the screen warns about the impact before saving; existing schedules are not moved automatically.

## Post-Conditions

- The Workspace record and its settings carry the new values; fields not supplied are unchanged.
- When a logo was uploaded, the Workspace holds the new logo location.

## Out of Scope

- Automatically rescheduling existing Tasks when the timezone changes.

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
