# Sequence Flow — View Workspace Profile

> Companion to `spec.md` (FR 3.4.13). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly. It does not restate business rules — see `spec.md` for those.
>
> Updated: 2026-09-23.

## Actors

- **Client** — a Workspace member (MANAGER, CREATOR, CLIENT).
- **System** — the application service handling the request.
- **Database** — the persistent store holding Workspace and membership records.

---

## Flow A — View Workspace details

1. Client → System: open `/workspaces/:id/profile`.
2. System → Database: look up the Workspace by its identifier; a missing Workspace is rejected with 404 `WORKSPACE_NOT_FOUND`.
3. System → Database: read the caller's active membership row for that same Workspace; a missing row is rejected with 403 `WORKSPACE_ACCESS_DENIED`.
4. System: map the Workspace to its profile, parsing the stored settings into timezone and default platforms.
5. System: when the stored settings cannot be parsed, fall back to empty settings without raising an error.
6. System → Client: the full Workspace profile — id, name, agencyId, settings, industry, companySize, website, phone, location, description, brandColor, logoIcon, logoUrl, tagline, foundedYear, social links, createdAt.
7. Client: render the Workspace profile, including the Workspace timezone.

---

## Error paths

| Step | Failure condition | Status | Error code |
|---|---|---|---|
| View | Workspace does not exist | 404 | `WORKSPACE_NOT_FOUND` |
| View | Caller is not an active member of that Workspace | 403 | `WORKSPACE_ACCESS_DENIED` |

## Notes

- The membership check is performed explicitly for the Workspace named in the request, rather than through a generic role check.
- A malformed settings payload degrades to empty settings instead of failing the request.
- The flow is read-only.
