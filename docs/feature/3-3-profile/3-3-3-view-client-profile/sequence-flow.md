# Sequence Flow — View Client Profile

> Supplements `spec.md` (FR 3.3.3). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).
>
> Updated: 2026-10-02. ClientProfile reworked — owned by the User, independent of any Agency.

## Actors

- **User** — any signed-in user, owner of zero or more Client Profiles.
- **Agency member** — an Owner or Manager viewing a workspace's Client list.
- **Client** — the "My Brand Profiles" screen (`/client-profiles`) and the Workspace Client list (`/workspaces/:id/clients`).
- **System** — the application services.
- **Database** — PostgreSQL (`client_profiles`, `workspace_members`).

---

## Key point — a Client Profile is owned by the User, never scoped to an Agency

- A user may own any number of independent Client Profiles — one per brand/customer they represent (e.g. separate "Nike" and "Adidas" profiles), unrelated to how many Agencies they work with.
- The same profile can be linked (`workspace_members.client_profile_id`) to any number of workspaces across any number of Agencies simultaneously. There is no "per-Agency copy" — one record, many links.

## Flow A — View "My Brand Profiles"

1. User → Client: opens `/client-profiles`.
2. Client → System: requests the signed-in user's Client Profiles.
3. System:
   a. Resolves the caller's identity from the access token.
   b. System → Database: `findByUserId(userId)` — returns every matching row (possibly empty).
4. System → Client: returns the list — `id`, `userId`, `displayName`, `company`, `phone`, `note`, `logoUrl`, `website`, `industry`, `location`, `description`, `socialLinks`, plus brand fields, `createdAt`, `updatedAt`.
5. Client: renders one card per profile.

## Flow B — Agency member views a workspace's Client list

1. Agency member → Client: opens `/workspaces/:id/clients`.
2. Client → System: requests `GET /api/v1/workspaces/{id}/members`.
3. System:
   a. Confirms the Workspace exists and the caller is an active member.
   b. System → Database: reads every active `workspace_members` row for that workspace; for role CLIENT rows, resolves the linked Client Profile's `displayName`.
4. System → Client: returns the member list.
5. Client: filters to `role === "CLIENT"` and displays them, with an "Add client" action for Owner/Manager.

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| View My Brand Profiles (Flow A) | Missing, expired, or invalid token | 401 | `UNAUTHORIZED` |
| View Workspace Client list (Flow B) | Workspace does not exist | 404 | `WORKSPACE_NOT_FOUND` |
| View Workspace Client list (Flow B) | Caller not an active member of that workspace | 403 | `WORKSPACE_ACCESS_DENIED` |

## Notes

- Creating a Client Profile happens explicitly on `/client-profiles` (FR 3.3.4) or inline during a CLIENT invitation accept flow (see `agency-workspace/3-4-7-invite-agency-member/sequence-flow.md`) — never implicitly, and never keyed by an Agency.
- The old "(user, agency) pair" model (2026-09-21, reverted 2026-10-02) is documented in `plan.md` §6 for historical context only — do not reintroduce it.
