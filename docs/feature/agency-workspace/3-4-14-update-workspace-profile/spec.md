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
- **Interface:** Workspace settings screen at `/workspaces/:id/settings` (`WorkspaceSettingsPage`) — the same page that displays the profile (FR 3.4.13); the edit form and logo control appear on it directly, there is no separate `/profile/edit` route.
- **Data Processing:** The system loads the Workspace, merges the supplied fields into the record and settings, and returns the updated Workspace profile.

## Screen Layout

Figure — Workspace Settings Screen, edit section (`WorkspaceSettingsPage`, `useWorkspaceSettings`):
- Logo block (`LogoUploader`), shown only when `canManage` is true — client-side accepts image/jpeg, image/png, image/webp and rejects files over 5 MB before calling the upload endpoint.
- Form pre-filled with the current name, timezone (`TimezoneSelect`), default platforms (`PlatformToggle`), report frequency (`FrequencyToggle`), industry, company size, website, phone, and location.
- A "Save" action; on success a confirmation toast is shown (`workspace.settings.saveSuccess`) and the form keeps the newly entered values.
- Out of scope for this FR but on the same screen: a "Save as Template" dialog (FR 3.4.17) and a Danger Zone delete-Workspace block (FR 3.4.15).

## Function Details

### Data Specifications

- **Input required:** The Workspace identifier; the caller's authenticated identity.
- **Input optional:** name, timezone, defaultPlatforms (list), reportFrequency (WEEKLY / MONTHLY), industry (WorkspaceIndustry enum), companySize (CompanySize enum), website, phone, location. For the logo control: the uploaded image file (validated client-side as image/jpeg, image/png, or image/webp, max 5 MB).
- **System data:** The existing Workspace record and its stored settings; the caller's role in that Workspace; the stored URL of the uploaded logo.
- **Output:** The updated Workspace profile — id, name, agencyId, slug, ownerId, settings (timezone, defaultPlatforms, reportFrequency), industry, companySize, website, phone, location, description, brandColor, logoIcon, logoUrl, tagline, foundedYear, social links, isActive, createdAt.

### Business Rules

- **BR-25:** Workspace settings and logo can only be updated by OWNER or MANAGER (enforced here as MANAGER, the only role granted on this Workspace's controller endpoint); all settings fields are optional (partial update).
- **BR-35:** `@RequireRoleAspect` re-reads the caller's role from the database at request time — it never trusts the JWT claim — and runs on the controller before the service method, so the role check on `updateSettings` / `uploadLogo` precedes even the not-found lookup. SystemRole.ADMIN bypasses the check.
- The Workspace must exist → otherwise 404 `WORKSPACE_NOT_FOUND`.
- Fields not supplied in the request keep their current values; the stored settings are merged rather than replaced (BR-25).
- A failure while reading the uploaded logo file → 400 `FILE_READ_ERROR`.
- The logo is uploaded through its own dedicated action, not through the profile settings update.

### Validation

- The caller must hold the MANAGER role in that Workspace (BR-25, BR-35); otherwise 403 `FORBIDDEN`.
- The Workspace must exist; otherwise 404 `WORKSPACE_NOT_FOUND`.
- `industry` must be a valid WorkspaceIndustry value; `companySize` must be a valid CompanySize value. Empty required field → Display: MSG02. Exceeding max length → Display: MSG03.
- An unreadable logo file → 400 `FILE_READ_ERROR`. The backend `updateLogo` itself has no explicit file-type/size check on this path; the frontend (`useWorkspaceSettings.handleLogoChange`) rejects non-image/jpeg, image/png, image/webp files and files over 5 MB before the request is sent, so the backend gap is currently masked by client-side validation, not fixed server-side.

## Functionalities

### Normal Flow

1. MANAGER opens `/workspaces/:id/settings` and edits the name, timezone, default platforms, report frequency, industry, company size, website, phone, or location.
2. System confirms the caller holds the MANAGER role in that Workspace (BR-25, BR-35), checked by `@RequireRoleAspect` before the service runs; otherwise the request fails with 403 `FORBIDDEN`.
3. System loads the Workspace; if it does not exist the request fails with 404 `WORKSPACE_NOT_FOUND`.
4. System applies the supplied fields and merges the new timezone / default platforms into the stored settings, keeping the previous values for fields left out (BR-25).
5. System returns the updated Workspace profile; the screen shows a success confirmation, toast MSG32. (The separate logo upload action, on success, shows toast MSG94.)

### Abnormal Cases

- 2.a1: Caller is not the MANAGER of that Workspace (BR-25, BR-35) → 403 `FORBIDDEN`, toast MSG39. 2.a2: The caller stays on the same `/workspaces/:id/settings` screen with the edit controls hidden (see FR 3.4.13's `canManage` gate).
- 3.a1: The Workspace does not exist → 404 `WORKSPACE_NOT_FOUND`, toast MSG38. 3.a2: The MANAGER returns to the Workspace list.
- 3.b1: Logo upload file cannot be read → 400 `FILE_READ_ERROR`. 3.b2: The user retries with another file.
- The timezone is changed while Tasks or Livestreams are already scheduled for the old timezone → the screen warns about the impact before saving; existing schedules are not moved automatically.

## Post-Conditions

- The Workspace record and its settings carry the new values; fields not supplied are unchanged.
- When a logo was uploaded, the Workspace holds the new logo location.

## Out of Scope

- Automatically rescheduling existing Tasks when the timezone changes.

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
