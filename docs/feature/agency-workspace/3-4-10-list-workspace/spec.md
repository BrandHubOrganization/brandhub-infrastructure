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

Figure — Workspace List Screen (`WorkspacePage`, `WorkspaceCardGrid`):
- A single grid screen titled with the user's Workspaces (`workspace.list.title`).
- Each card shows an initials badge, the Workspace name, and its slug; clicking a card navigates to `/workspaces/:id/settings`.
- An empty state message is shown when the user belongs to no Workspace.
- A "Create Workspace" button navigates to the create form (FR 3.4.12).
- ⚠ BA conflict (needs team decision): `workspaceService.listManagedWorkspaces()` (`GET /api/v1/workspaces/my-managed`, returning id/name/slug/logoUrl/role/memberCount) exists in the frontend service layer, but the current `WorkspacePage` (`index.tsx`) does not call it or render a "Workspaces I manage" view anywhere. Either that view was removed/not yet wired up, or it lives on a screen not reviewed here — needs confirmation before documenting it as shipped UI.

## Function Details

### Data Specifications

- **Input required:** The caller's authenticated identity (taken from the session principal).
- **Input optional:** None.
- **System data:** Active Workspace membership rows of the current user; the Workspace records those memberships reference.
- **Output:** The Workspaces the user belongs to — id, name, agencyId, slug, ownerId, settings (including reportFrequency), industry, companySize, website, phone, location, description, brandColor, logoIcon, logoUrl, tagline, foundedYear, facebookUrl, linkedinUrl, instagramUrl, isActive, createdAt. The frontend list card only renders the name and slug. A separate "managed" endpoint (`GET /api/v1/workspaces/my-managed`) returns id, name, slug, logoUrl, role, and memberCount per Workspace, but see the BA conflict note in Screen Layout on whether it is currently surfaced in the UI.

### Business Rules

- **BR-29:** Multi-tenancy — every workspace-scoped resource carries workspaceId; a user with no active membership cannot read/write the workspace regardless of system role (except ADMIN). Applied here as: a Workspace is returned when either (a) the current user has an active membership row in it (MemberRole MANAGER, CREATOR, or CLIENT), or (b) the current user is the Owner of the Agency that Workspace belongs to — per `docs/ba/10-roles-permissions-matrix.md` Tầng 1, an Agency Owner sees every Workspace of their Agency, not only ones they are a member of.
  - **Fixed 2026-09-24:** an earlier version of this spec/code scoped the listing to membership only, so an Agency Owner did not automatically see every Workspace of their own Agency — this was a real gap against BA, now corrected in `WorkspaceServiceImpl.listMyWorkspaces`.
- **BR-03:** The listing is read-only; there is no business error code for it. The only failure is a missing session, rejected with 401 through the shared authentication mechanism.
- **Known gap:** `listMyWorkspaces` does not currently exclude SOFT_DELETED workspaces from the list — the merge of owned-Agency workspace IDs and membership workspace IDs is passed straight into `workspaceRepository.findAllById(workspaceIds)` with no status filter in the repository query or the stream. A soft-deleted Workspace (see FR 3.4.15 Delete Workspace) may still appear in this list until this is fixed. Docs-only note; not fixed here.

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

- 5.a1: User belongs to no Workspace (BR-29) → an empty list is returned, HTTP 200. 5.a2: The empty state is displayed on the screen.
- 5.b1: User is not signed in → 401 through the shared authentication mechanism. 5.b2: The user is redirected to sign in.
- 5.c1: A Workspace referenced by an owned Agency or an active membership has actually been soft-deleted (known gap above) → it is still returned and displayed as if active. 5.c2: No workaround on the client side; tracked as a backend fix.

## Post-Conditions

- No data is changed; the Workspaces the user belongs to are displayed.

## Out of Scope

- None.

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
