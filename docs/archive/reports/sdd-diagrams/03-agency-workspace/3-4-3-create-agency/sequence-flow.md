# Sequence Flow — Create Agency

> Companion to `spec.md` (FR 3.4.3). This file lists each actor → action → system step in enough detail to draw the sequence diagram directly. Business explanation lives in `spec.md`.
>
> Updated 2026-09-23, matching the system as built today.

## Actors

- **User** — signed in; owns no Agency yet, or wants another one.
- **Client** — the BrandHub web application.
- **System** — the BrandHub service.
- **Database** — PostgreSQL (`agencies`, `agency_members`).

---

## Flow A — Create an Agency (without a logo)

1. User → Client: opens the Create Agency form and fills in the name, plus any optional branding values (description, category, company size, website, phone, location, brand colour, logo icon, tagline, founded year, Facebook, LinkedIn and Instagram links).
2. Client → System: submits the form (`POST /api/v1/agencies`).
3. System — create the Agency:
   a. Validates the name as mandatory — empty → `400 VALIDATION_ERROR`.
   b. Validates the brand colour at 9 characters and the tagline at 140 characters — over the limit → `400 VALIDATION_ERROR`.
   c. Stores a new Agency with the current user as its Owner and the status ACTIVE.
   d. Stores a member record for the Agency with the current user at the OWNER role.
4. System → Client: the profile of the new Agency, including its identifier.
5. Client: moves the user into the Agency just created. The Agency Dashboard (3.4.2) has no screen of its own yet, so the Agency Profile (3.4.4) is shown in the meantime.

## Flow B — Upload a logo once the Agency exists

1. Continuation of Flow A step 5, or the edit screen later on.
2. User → Client: picks the logo image file.
3. Client → System: submits the file for the Agency (`POST /api/v1/agencies/{agencyId}/logo`, sent as multipart form data).
4. System: stores the file and fills in the logo of the Agency.
5. System → Client: the Agency profile carrying the new logo location.
6. Client: refreshes the logo preview.

---

## Error paths

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| Create | Name empty | 400 | `VALIDATION_ERROR` |
| Create | Value over its limit (brand colour over 9 characters, tagline over 140 characters) | 400 | `VALIDATION_ERROR` |
| Logo upload | The file cannot be read | 400 | `FILE_READ_ERROR` |

## Notes

- No divergence from `spec.md`. The logo is uploaded separately from the main form, matching the built behaviour where the logo upload is a step of its own rather than part of the Agency creation.
