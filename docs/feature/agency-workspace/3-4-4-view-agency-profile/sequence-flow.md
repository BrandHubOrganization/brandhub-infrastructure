# Sequence Flow — View Agency Profile

> Companion to `spec.md` (FR 3.4.4). This file lists each actor → action → system step in enough detail to draw the sequence diagram directly. Business explanation lives in `spec.md`.
>
> Updated 2026-09-23, matching the system as built today.

## Actors

- **Viewer** — Owner or Member of the Agency; must be signed in, because the profile carries an access check.
- **Client** — the BrandHub web application.
- **System** — the BrandHub service.
- **Database** — PostgreSQL (`agencies`, `agency_members`).

---

## Flow A — View the Agency profile

1. Viewer → Client: opens the profile of the Agency.
2. Client → System: requests the Agency profile with the signed-in session (`GET /api/v1/agencies/{agencyId}`). This is the same request the Agency list uses when opening an Agency, as there is no separate profile request.
3. System — session check: a missing or invalid session → `401 UNAUTHORIZED`, refused before the Agency logic runs.
4. System — load and authorise:
   a. Loads the Agency by its identifier — not found → `404 AGENCY_NOT_FOUND`.
   b. Confirms whether the caller is the Owner of the Agency.
   c. Confirms whether the caller holds a member record in the Agency.
   d. Caller is neither the Owner nor a Member → `400 NOT_AGENCY_MEMBER`.
   e. Maps the Agency to its profile.
5. System → Client: the profile of the Agency.
6. Client: renders the profile — name, logo, description, category, company size, website, phone, location, brand colour, logo icon, tagline, founded year (shown as years in business, counted from the current year), and the Facebook, LinkedIn and Instagram links.

---

## Error paths

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| Session | Session missing, invalid or expired | 401 | `UNAUTHORIZED` |
| Load | Agency does not exist | 404 | `AGENCY_NOT_FOUND` |
| Authorise | Caller is neither the Owner nor a Member | 400 | `NOT_AGENCY_MEMBER` |

## Notes

- **Correction applied:** an earlier revision described the profile as public, with no sign-in and no access check. That is wrong for the system as built. The request now requires a signed-in session, and the system confirms the caller is the Owner of the Agency or holds a member record in it, refusing anyone else with `NOT_AGENCY_MEMBER`. The profile is no longer public.
