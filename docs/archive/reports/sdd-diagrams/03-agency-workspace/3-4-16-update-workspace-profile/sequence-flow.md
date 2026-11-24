# Sequence Flow — Update Workspace Profile

> Companion to `spec.md` (FR 3.4.14). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly. It does not restate business rules — see `spec.md` for those.
>
> Updated: 2026-09-25.

## Actors

- **Client** — the MANAGER of the Workspace.
- **System** — the application service handling the request.
- **Database** — the persistent store holding Workspace records.
- **File storage** — the external store holding the uploaded Workspace logo.

---

## Flow A — Update settings and Workspace details

1. Client → System: on `/workspaces/:id/settings`, edit the name, timezone, default platforms, report frequency, industry, company size, website, phone, or location and submit.
2. System: check the caller's role in the Workspace before handling the request — a caller who is not the Workspace MANAGER is rejected with 403 `FORBIDDEN`.
3. System → Database: look up the Workspace by its identifier; a missing Workspace is rejected with 404 `WORKSPACE_NOT_FOUND`.
4. System: apply the supplied name when it is not blank.
5. System: parse the stored settings and merge in the new timezone and default platforms, keeping the previous values for fields left out of the request.
6. System: store the merged settings and apply the supplied industry, company size, website, phone, and location.
7. System: record the update timestamp.
8. System → Database: write the updated Workspace.
9. System → Client: the updated Workspace profile.
10. Client: show a success confirmation and refresh the profile.

## Flow B — Update the Workspace logo

1. Client → System: choose a logo image file; the client rejects it up front if it is not image/jpeg, image/png, or image/webp, or if it exceeds 5 MB, before any request is sent.
2. System: check the caller's role — a caller who is not the Workspace MANAGER is rejected with 403 `FORBIDDEN`.
3. System → Database: look up the Workspace by its identifier; a missing Workspace is rejected with 404 `WORKSPACE_NOT_FOUND`.
4. System: read the uploaded file's bytes; a read failure is rejected with 400 `FILE_READ_ERROR`.
5. System → File storage: upload the logo and receive its location.
6. System: set the Workspace logo location and record the update timestamp.
7. System → Database: write the updated Workspace.
8. System → Client: the updated Workspace profile carrying the new logo location.
9. Client: display the new logo.

---

## Error paths

| Step | Failure condition | Status | Error code |
|---|---|---|---|
| Update settings / Upload logo | Caller is not the MANAGER of that Workspace | 403 | `FORBIDDEN` |
| Update settings / Upload logo | Workspace does not exist | 404 | `WORKSPACE_NOT_FOUND` |
| Upload logo | The uploaded file cannot be read | 400 | `FILE_READ_ERROR` |

## Notes

- The role check is applied before the request reaches the update handling, so a non-MANAGER never triggers a Workspace lookup.
- Fields omitted from the request keep their current values; the settings payload is merged rather than replaced.
- The logo has its own dedicated action, separate from the settings update.
