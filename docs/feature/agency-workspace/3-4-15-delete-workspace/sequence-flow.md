# Sequence Flow — Delete Workspace

> FR 3.4.15 — **proposed, not yet implemented: there is no real sequence to describe.**
>
> Updated: 2026-09-23.

## Implementation status

- No delete or restore action exists for a Workspace.
- The Workspace record already carries a status field and a deletion timestamp, but no handling currently writes to them for soft deletion.
- There is therefore no implemented sequence to document. Every step below is an anticipated flow taken from `spec.md`, not yet confirmed technically and not yet built.

## Actors (anticipated)

- **Client** — the Agency owner performing the deletion.
- **System** — the application service; no delete handling exists yet.
- **Database** — the persistent store; the Workspace status and deletion timestamp fields exist but are unused.

---

## Anticipated flow (PROPOSED — not yet implemented)

1. Client → System: open Workspace settings and choose Delete, then type the Workspace name in the confirmation dialog.
2. System (anticipated): confirm the caller is the Agency owner — any other caller, including the Workspace MANAGER, is rejected with 403 `FORBIDDEN`.
3. System (anticipated): mark the Workspace as soft-deleted and record the deletion timestamp.
4. System (anticipated): every member and Client loses access immediately, and all data inside the Workspace (Task, Campaign, Material and similar) becomes inactive.
5. System → Client (anticipated): confirmation that the Workspace has been soft-deleted.

### Sub-flow — Restore (anticipated, not yet implemented)

1. Client → System: choose Restore for a deleted Workspace within the 30-day window.
2. System (anticipated): check that the 30-day window has not elapsed; otherwise reject with 410 `RESTORE_WINDOW_EXPIRED`.
3. System (anticipated): clear the deletion state and bring back the previous statuses of the Tasks and Campaigns rather than resetting them to backlog.
4. System → Client (anticipated): the restored Workspace profile.

---

## Error paths (anticipated — not yet implemented)

| Step | Failure condition | Status | Error code |
|---|---|---|---|
| Delete | Caller is not the Agency owner | 403 | `FORBIDDEN` (proposed) |
| Restore | The 30-day window has elapsed | 410 | `RESTORE_WINDOW_EXPIRED` (proposed) |

## Notes

- `spec.md` already marks this FR as proposed and not yet implemented; this file confirms that the Workspace record carries the status and deletion-timestamp fields as groundwork, but no handling writes to them, so there is no implemented sequence beyond the anticipated flow above.
- The role allowed to delete is still unconfirmed — the Agency owner is proposed only.
