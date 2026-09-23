# Sequence Flow — List Workspace

> Companion to `spec.md` (FR 3.4.10). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly. It does not restate business rules — see `spec.md` for those.
>
> Updated: 2026-09-23.

## Actors

- **Client** — the signed-in user, a Workspace member of any role (MANAGER, CREATOR, CLIENT).
- **System** — the application service handling the request.
- **Database** — the persistent store holding Workspace and membership records.

---

## Flow A — Workspaces the user belongs to

1. Client → System: open the Workspace list screen.
2. System: read the current user's active membership rows (filtered by user and active flag).
3. System: collect the Workspace identifiers from those memberships.
4. System → Database: load the Workspace records for those identifiers.
5. Database → System: the matching Workspace records.
6. System: map each Workspace to a Workspace summary.
7. System → Client: the list of Workspace summaries.
8. Client: render the Workspace list — an empty state when the user belongs to none.

## Flow B — Workspaces the user manages

1. Client → System: open the "Workspaces I manage" screen.
2. System: read the current user's active memberships and keep only those with the MANAGER role.
3. System → Database: load the Workspace records for the remaining identifiers.
4. System: count the active members for each of those Workspaces.
5. System: map each Workspace to a managed-Workspace summary carrying id, name, role, and member count.
6. System → Client: the list of managed Workspace summaries.

---

## Error paths

| Step | Failure condition | Status | Error code |
|---|---|---|---|
| List (A / B) | Caller is not signed in | 401 | Shared authentication mechanism — no Workspace-specific error code |

No other business error codes apply: both flows only read data scoped to the current user and contain no 4xx/409 branch.

## Notes

- The listing is scoped to the current user rather than to an Agency, so an Agency owner does not automatically see every Workspace.
- The Database access pattern is read-only; neither flow writes anything.
