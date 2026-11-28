# Sequence Flow — List Agency

> Companion to `spec.md` (FR 3.4.1). This file lists each actor → action → system step in enough detail to draw the sequence diagram directly. Business explanation lives in `spec.md`.
>
> Updated 2026-09-23, matching the system as built today.

## Actors

- **User** — signed in; may own several Agencies and may belong to other Agencies as a Member.
- **Client** — the BrandHub web application.
- **System** — the BrandHub service.
- **Database** — PostgreSQL (`agencies`, `agency_members`).

---

## Flow A — View the Agency list

1. User → Client: signs in and opens the Agencies page, which is the default landing page when the user owns or belongs to at least one Agency.
2. Client → System: requests the Agency list of the signed-in user (`GET /api/v1/agencies`).
3. System — build the list:
   a. Collects the Agencies the user owns, excluding those that are soft-deleted.
   b. Collects the Agencies where the user holds a member record and merges them into the same set of identifiers, removing duplicates.
   c. Loads the merged set by identifier, filters out any Agency that is soft-deleted once more, and maps each remaining Agency to its full profile.
4. System → Client: the list of Agency profiles, empty when the user owns or belongs to none.
5. Client: renders one card per Agency. When the list is empty, it shows the empty state with the "Create new Agency" call to action (3.4.3).
6. User selects a card → the Client moves into that Agency, using the Agency profile of 3.4.4 because the Agency Dashboard of 3.4.2 has no screen of its own yet.

---

## Error paths

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| List | None — the list is always returned, including when it is empty | — | — |

The feature has no business failure path. Only the shared session failure applies: a request without a valid session is rejected with `401 UNAUTHORIZED` before it reaches the Agency logic.

## Notes

- No divergence from `spec.md`: the result merges the Agencies the user owns with the Agencies the user belongs to, even though the feature is named from the Owner's point of view. `spec.md` states this in its business rules.
