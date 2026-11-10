# Sequence Flow — Update Agency Profile

> Companion to `spec.md` (FR 3.4.5). This file lists each actor → action → system step in enough detail to draw the sequence diagram directly. Business explanation lives in `spec.md`.
>
> Updated 2026-09-23, matching the system as built today.

## Actors

- **Owner**
- **Client** — the BrandHub web application.
- **System** — the BrandHub service.
- **Database** — PostgreSQL (`agencies`).

---

## Flow A — Update the Agency profile (full replace)

1. Owner → Client: opens the Agency Profile in edit mode; the form loads with every current value (3.4.4).
2. Owner: changes the fields that need updating and leaves the rest as they are — every value has to come back in the form, because the save replaces the whole profile instead of patching single fields.
3. Client → System: submits the full profile (`PUT /api/v1/agencies/{agencyId}`).
4. System — update:
   a. Loads the Agency by its identifier — not found → `404 AGENCY_NOT_FOUND`.
   b. Confirms the caller is the Owner of the Agency — otherwise `403 NOT_AGENCY_OWNER`.
   c. Validates the name as mandatory — empty → `400 VALIDATION_ERROR`.
   d. Replaces every field of the profile with the submitted values; a value that was not sent is cleared.
   e. Stores the updated profile.
5. System → Client: the updated profile of the Agency.
6. Client: shows a confirmation and refreshes the form and the logo preview.

## Flow B — Change the logo (uploaded separately)

1. Owner → Client: picks a new logo file on the edit screen.
2. Client → System: submits the file for the Agency (`POST /api/v1/agencies/{agencyId}/logo`, sent as multipart form data).
3. System — change the logo:
   a. Loads the Agency by its identifier — not found → `404 AGENCY_NOT_FOUND`.
   b. Confirms the caller is the Owner of the Agency — otherwise `403 NOT_AGENCY_OWNER`.
   c. Stores the file. When the file cannot be read → `400 FILE_READ_ERROR`, rather than an internal failure.
   d. Fills in the logo of the Agency with the stored location and refreshes the update timestamp.
4. System → Client: the Agency profile carrying the new logo location.
5. Client: refreshes the logo preview.

---

## Error paths

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| Update | Agency does not exist | 404 | `AGENCY_NOT_FOUND` |
| Update | Caller is not the Owner | 403 | `NOT_AGENCY_OWNER` |
| Update | Name empty | 400 | `VALIDATION_ERROR` |
| Logo upload | Agency does not exist | 404 | `AGENCY_NOT_FOUND` |
| Logo upload | Caller is not the Owner | 403 | `NOT_AGENCY_OWNER` |
| Logo upload | The file cannot be read | 400 | `FILE_READ_ERROR` |

## Notes

- No divergence from `spec.md`. The file-read failure on a logo upload returns `400 FILE_READ_ERROR` rather than a generic internal error and leaves the stored profile untouched.
