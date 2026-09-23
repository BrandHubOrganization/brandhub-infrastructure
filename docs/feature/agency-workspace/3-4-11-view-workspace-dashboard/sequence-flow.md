# Sequence Flow — View Workspace Dashboard

> FR 3.4.11 — **proposed, not yet implemented: there is no real sequence to describe.**
>
> Updated: 2026-09-23.

## Implementation status

- No dashboard route exists for a Workspace, and no aggregation of Task counts, active Clients, or active Campaigns has been built for a Workspace dashboard.
- There is therefore no implemented sequence to document. Every step below is an anticipated flow taken from `spec.md`, not yet confirmed technically and not yet built.

## Actors (anticipated)

- **Client** — a Workspace member (MANAGER, CREATOR, CLIENT).
- **System** — the application service; no dashboard handling exists yet.
- **Database** — the persistent store holding Task, Campaign, and membership records; the aggregation queries are not yet defined.

---

## Anticipated flow (PROPOSED — not yet implemented)

1. Client → System: open the dashboard of a Workspace.
2. System (anticipated): confirm the caller holds an active membership in that Workspace — otherwise reject with 403 `FORBIDDEN`.
3. System (anticipated) → Database: aggregate Task counts by status (backlog / in progress / completed), the number of active Clients, and the number of active Campaigns.
4. Database → System (anticipated): the aggregated counts.
5. System → Client (anticipated): the task counts by status, the active Client count, and the active Campaign count.
6. Client: render the dashboard; a newly created Workspace with no data shows all counters as 0.

---

## Error paths (anticipated — not yet implemented)

| Step | Failure condition | Status | Error code |
|---|---|---|---|
| Dashboard | Caller has no access to the Workspace | 403 | `FORBIDDEN` (proposed) |

## Notes

- `spec.md` already marks this FR as proposed and not yet implemented; this file confirms that no dashboard route or aggregation exists, so no new drift has been introduced.
- The response shape for the counters is proposed only — it has not been agreed technically.
