# Sequence Flow — Save Workspace Template

> Companion to `spec.md` (FR 3.4.17). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly. It does not restate business rules — see `spec.md` for those.
>
> Updated: 2026-09-23.

## Actors

- **Client** — a signed-in Agency member.
- **System** — the application service handling the request.
- **Database** — the persistent store holding template records.

---

## Flow A — Save a template from an existing Workspace

1. Client → System: in Workspace settings, choose "Save as Template" and supply the name, the configuration snapshot built from the Workspace currently being viewed, and optionally the source Workspace.
2. System: validate that the name and the configuration snapshot are not empty; an empty value is rejected with 400 `VALIDATION_ERROR`.
3. System: attach the caller's Agency and creator identity automatically, without taking them from the request.
4. System → Database: insert the template row.
5. System → Client: the stored template — id, agencyId, name, sourceWorkspaceId, configSnapshot, createdBy, createdAt.
6. Client: show a success confirmation and add the template to the template list.

## Flow B — List templates

1. Client → System: open the template list screen.
2. System → Database: read the templates in the caller's Agency scope.
3. System → Client: the list of template summaries.

## Flow C — View a template's detail

1. Client → System: open one template.
2. System → Database: look up the template by its identifier; a missing template is rejected with 404 `NOT_FOUND`.
3. System → Client: the template detail.

## Flow D — Delete a template

1. Client → System: choose Delete on a template.
2. System → Database: look up the template by its identifier; a missing template is rejected with 404 `NOT_FOUND`.
3. System → Database: remove the template row.
4. System → Client: confirmation that the template has been deleted.

---

## Error paths

| Step | Failure condition | Status | Error code |
|---|---|---|---|
| Create | `name` empty | 400 | `VALIDATION_ERROR` |
| Create | Configuration snapshot empty | 400 | `VALIDATION_ERROR` |
| Detail / Delete | Template does not exist | 404 | `NOT_FOUND` |

## Notes

- Templates are a standalone resource and are not nested inside an Agency or a Workspace.
- No specific role restriction is currently applied to these actions; whether access should be limited by Agency or role is still to be confirmed.
- A template stays available even after its source Workspace is deleted, because the stored snapshot does not depend on the source Workspace.
