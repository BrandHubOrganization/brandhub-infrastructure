# Sequence Flow — List Workspace

> Companion to `spec.md` (FR 3.4.10). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly. It does not restate business rules — see `spec.md` for those.
>
> Updated: 2026-09-25.

## Actors

- **Client** — the signed-in user, a Workspace member of any role (MANAGER, CREATOR, CLIENT).
- **System** — the application service handling the request.
- **Database** — the persistent store holding Workspace and membership records.

---

## Flow A — Workspaces the user belongs to

1. Client → System: open the Workspace list screen (`WorkspacePage`).
2. System → Database: find every Agency the caller owns (`agencyRepository.findByOwnerIdAndStatusNot(..., SOFT_DELETED)`).
3. System → Database: for each owned Agency, load its Workspaces (`workspaceRepository.findByAgencyId`) and collect their ids.
4. System → Database: read the current user's active membership rows (filtered by user and active flag) and collect their Workspace ids too, merged into the same id set (`LinkedHashSet`, de-duplicated).
5. System → Database: `findAllById(workspaceIds)` — **no status filter is applied here** (known gap, see spec.md).
6. Database → System: the matching Workspace records, including any that are SOFT_DELETED.
7. System: map each Workspace to a Workspace summary.
8. System → Client: the list of Workspace summaries.
9. Client: render the Workspace list — an empty state when the user belongs to none.

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

- Flow A merges two sources: Workspaces of any Agency the caller owns, and Workspaces the caller has an active membership in — an Agency Owner sees every Workspace of their Agency even without a membership row.
- **Known gap:** `findAllById(workspaceIds)` in Flow A step 5 has no SOFT_DELETED filter — a soft-deleted Workspace (FR 3.4.15) can still appear in this list. Not fixed here (docs-only).
- The Database access pattern is read-only; neither flow writes anything.
