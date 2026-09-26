# Sequence Flow — View Workspace Profile

> Companion to `spec.md` (FR 3.4.13). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly. It does not restate business rules — see `spec.md` for those.
>
> Updated: 2026-09-25.

## Actors

- **Client** — a Workspace member (MANAGER, CREATOR, CLIENT).
- **System** — the application service handling the request.
- **Database** — the persistent store holding Workspace and membership records.

---

## Flow A — View Workspace details

1. Client → System: open `/workspaces/:id/settings` (`WorkspaceSettingsPage`); the page calls `GET /api/v1/workspaces/:id`.
2. System: `@RequireRole({MANAGER, CREATOR, CLIENT})` on the controller — the caller must hold at least one of those roles somewhere, checked by `RequireRoleAspect` against a fresh DB read; otherwise rejected with 403 `FORBIDDEN`.
3. System → Database: look up the Workspace by its identifier; a missing Workspace is rejected with 404 `WORKSPACE_NOT_FOUND`.
4. System → Database: read the caller's active membership row for that same Workspace (`assertMember`, service-level check); a missing row is rejected with 403 `WORKSPACE_ACCESS_DENIED`.
5. System: map the Workspace to its profile, parsing the stored settings into timezone, default platforms, and report frequency.
6. System: when the stored settings cannot be parsed, fall back to empty settings without raising an error.
7. System → Client: the full Workspace profile — id, name, agencyId, slug, ownerId, settings, industry, companySize, website, phone, location, description, brandColor, logoIcon, logoUrl, tagline, foundedYear, social links, isActive, createdAt.
8. Client: render the Workspace profile, including the Workspace timezone.

---

## Error paths

| Step | Failure condition | Status | Error code |
|---|---|---|---|
| View | Caller holds none of MANAGER/CREATOR/CLIENT anywhere | 403 | `FORBIDDEN` |
| View | Workspace does not exist | 404 | `WORKSPACE_NOT_FOUND` |
| View | Caller is not an active member of that specific Workspace | 403 | `WORKSPACE_ACCESS_DENIED` |

## Notes

- Two access checks run in sequence: a coarse controller-level `@RequireRole` gate, then an explicit service-level membership check scoped to the exact Workspace in the request.
- A malformed settings payload degrades to empty settings instead of failing the request.
- The flow is read-only.
