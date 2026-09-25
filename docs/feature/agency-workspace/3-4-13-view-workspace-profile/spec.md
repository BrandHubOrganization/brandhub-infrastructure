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
- **Interface:** Workspace settings screen at `/workspaces/:id/settings` (`WorkspaceSettingsPage`) — a single combined page that also hosts the update form (FR 3.4.14); there is no separate read-only `/profile` route in the current frontend.
- **Data Processing:** The system loads the Workspace via `WorkspaceController.getWorkspace` (`@RequireRole({MANAGER, CREATOR, CLIENT})` on the controller), and maps the record to a Workspace profile, parsing the stored settings into timezone, default platforms, and report frequency.

## Screen Layout

Figure — Workspace Settings Screen (`WorkspaceSettingsPage`):
- Logo block (`LogoUploader`) shown only when `canManage` is true — see BA conflict note below.
- Form pre-filled from `GET /api/v1/workspaces/:id`: name, timezone (`TimezoneSelect`), default platforms (`PlatformToggle`), report frequency (`FrequencyToggle`), industry, company size, website, phone, location.
- ⚠ BA conflict (needs team decision): the frontend computes `canManage` by calling `listMembers` and checking the caller's role for `OWNER` or `MANAGER`. The backend's workspace-level `MemberRole` enum only has MANAGER / CREATOR / CLIENT (no workspace OWNER — OWNER exists only at Agency level per FR 3.4.12). The FE check for a workspace-level "OWNER" role can never be true against the current backend data, so in practice only MANAGER unlocks editing/logo/danger-zone controls; the OWNER branch looks like dead/stale FE code, not a real access path. Flagging rather than assuming intent.

## Function Details

### Data Specifications

- **Input required:** The Workspace identifier; the caller's authenticated identity.
- **Input optional:** None.
- **System data:** The Workspace record; the caller's active membership row; the stored settings payload (timezone, default platforms).
- **Output:** The Workspace profile — id, name, agencyId, slug, ownerId, settings (timezone, defaultPlatforms, reportFrequency), industry, companySize, website, phone, location, description, brandColor, logoIcon, logoUrl, tagline, foundedYear, facebookUrl, linkedinUrl, instagramUrl, isActive, createdAt.

### Business Rules

- **BR-29:** Multi-tenancy — every workspace-scoped resource carries workspaceId; a caller with no active membership in the Workspace cannot read it regardless of system role (except ADMIN, cross-workspace). Enforced in two layers: (1) `@RequireRole({MANAGER, CREATOR, CLIENT})` on `WorkspaceController.getWorkspace`, checked by `RequireRoleAspect` against a fresh DB read of the caller's *global* role set before the service method runs — a caller who holds none of those workspace roles anywhere is rejected here with 403 `FORBIDDEN`; (2) inside `WorkspaceServiceImpl.getWorkspace`, an explicit `assertMember(workspaceId, currentUser.getId())` call that re-checks membership in *this specific* Workspace and throws 403 `WORKSPACE_ACCESS_DENIED` if the caller is not an active member of it. The service-level check is what actually scopes the check to the requested Workspace.
- Workspace that does not exist → 404 `WORKSPACE_NOT_FOUND`.
- Caller not an active member of that specific Workspace → 403 `WORKSPACE_ACCESS_DENIED` (service-level check).
- Failure to parse the stored settings falls back to empty settings (no timezone, no default platforms) without raising an error.
- There is a single Workspace-level timezone configuration — not one per Client or per Task.

### Validation

- The Workspace must exist; otherwise 404 `WORKSPACE_NOT_FOUND`.
- The caller must hold an active membership in that Workspace (BR-29); otherwise 403 `WORKSPACE_ACCESS_DENIED`.
- A malformed settings payload must degrade to empty settings rather than fail the request.

## Functionalities

### Normal Flow

1. Member opens `/workspaces/:id/settings`.
2. System loads the Workspace; if it does not exist, the request fails with 404 `WORKSPACE_NOT_FOUND`.
3. System confirms the caller has an active membership in that Workspace (BR-29); otherwise the request fails with 403 `WORKSPACE_ACCESS_DENIED`.
4. System maps the Workspace to its profile, parsing the stored settings into timezone, default platforms, and report frequency.
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
- A dedicated read-only profile view — the current frontend renders view and edit (FR 3.4.14) on the same `/workspaces/:id/settings` screen; splitting them is a future UX decision, not part of this FR.

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
