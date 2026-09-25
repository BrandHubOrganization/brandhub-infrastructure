# Sequence Flow — Save Workspace Template

> Companion to `spec.md` (FR 3.4.17). `WorkspaceTemplateServiceImpl` is
> **implemented** — all four methods (`saveTemplate`, `listTemplates`,
> `getTemplate`, `deleteTemplate`) run real logic; none throws
> `UnsupportedOperationException` anymore.
>
> Updated: 2026-09-25.

## Actors / Lifelines

- **Member** — a signed-in Agency member, acting from Workspace settings (`detail.tsx`) or the templates list page (`templates.tsx`, `/workspaces/templates`).
- **WorkspaceTemplateController** — `saveTemplate` / `listTemplates` / `getTemplate` / `deleteTemplate` endpoints.
- **WorkspaceTemplateServiceImpl** — real business logic; resolves the caller's owned Agency via `resolveOwnedAgencyId` (same pattern as `WorkspaceServiceImpl.listMyWorkspaces`).
- **WorkspaceTemplateRepository** — persistence for `WorkspaceTemplate`.
- **AgencyRepository** — resolves the caller's owned Agency (`findByOwnerIdAndStatusNot`).

---

## Flow A — Save a template

1. Member → WorkspaceTemplateController: in the "Save as Template" modal (`detail.tsx`), supplies a name; `configSnapshot` is auto-built from `timezone`/`defaultPlatforms`/`reportFrequency` and `sourceWorkspaceId` is set to the current workspace id. `POST /api/v1/workspace-templates`.
2. WorkspaceTemplateController: validates `name`/`configSnapshot` not empty via `@NotBlank` on `SaveWorkspaceTemplateRequest` → 400 `VALIDATION_ERROR` if either is empty.
3. WorkspaceTemplateController → WorkspaceTemplateServiceImpl: `saveTemplate(currentUser, request)`.
4. WorkspaceTemplateServiceImpl → AgencyRepository: `resolveOwnedAgencyId(currentUser)` — `findByOwnerIdAndStatusNot(currentUser.getId(), SOFT_DELETED)`; no owned Agency → 404 `AGENCY_NOT_FOUND`.
5. WorkspaceTemplateServiceImpl: builds a `WorkspaceTemplate` with `agencyId`/`createdBy` set from the resolved Agency and `currentUser` — never from the request payload (BR-29).
6. WorkspaceTemplateServiceImpl → WorkspaceTemplateRepository: `save(template)`.
7. WorkspaceTemplateServiceImpl → WorkspaceTemplateController → Member: 200 with the stored `WorkspaceTemplateResponse`.
8. Member (FE, on success): success toast, modal closes.

## Flow B — List templates

1. Member → WorkspaceTemplateController: opens `/workspaces/templates`; `GET /api/v1/workspace-templates`.
2. WorkspaceTemplateController → WorkspaceTemplateServiceImpl: `listTemplates(currentUser)`.
3. WorkspaceTemplateServiceImpl → AgencyRepository: `resolveOwnedAgencyId(currentUser)` — no owned Agency → 404 `AGENCY_NOT_FOUND`.
4. WorkspaceTemplateServiceImpl → WorkspaceTemplateRepository: `findByAgencyId(agencyId)` → the caller's Agency-scoped templates.
5. WorkspaceTemplateServiceImpl → WorkspaceTemplateController → Member: the list of templates.

## Flow C — Inline expand to view a template (no separate detail route)

1. Member → FE only: clicks a template's name in the already-loaded list; FE toggles showing that template's `configSnapshot` inline. No network call — the detail data was already fetched by Flow B's list response. There is no dedicated detail URL in the UI.

## Flow C.1 — Get a single template (`GET /{templateId}`, API-level; not wired into the current UI flow)

1. Caller → WorkspaceTemplateController: `GET /api/v1/workspace-templates/{templateId}`.
2. WorkspaceTemplateController → WorkspaceTemplateServiceImpl: `getTemplate(templateId, currentUser)`.
3. WorkspaceTemplateServiceImpl → WorkspaceTemplateRepository: `findById(templateId)` → missing → 404 `NOT_FOUND`.
4. WorkspaceTemplateServiceImpl → AgencyRepository: `resolveOwnedAgencyId(currentUser)`; compares against `template.getAgencyId()` — mismatch → 403 `FORBIDDEN` (Agency-scope check, patched in this pass — previously missing).
5. WorkspaceTemplateServiceImpl → WorkspaceTemplateController → Caller: 200 with the `WorkspaceTemplateResponse`.

## Flow D — Delete a template

1. Member → WorkspaceTemplateController: clicks the delete (trash) icon on a template row; `DELETE /api/v1/workspace-templates/{templateId}`.
2. WorkspaceTemplateController → WorkspaceTemplateServiceImpl: `deleteTemplate(templateId, currentUser)`.
3. WorkspaceTemplateServiceImpl → WorkspaceTemplateRepository: `findById(templateId)` → missing → 404 `NOT_FOUND`.
4. WorkspaceTemplateServiceImpl → AgencyRepository: `resolveOwnedAgencyId(currentUser)`; compares against `template.getAgencyId()` — mismatch → 403 `FORBIDDEN`.
5. WorkspaceTemplateServiceImpl → WorkspaceTemplateRepository: `delete(template)`.
6. WorkspaceTemplateServiceImpl → WorkspaceTemplateController → Member: 200 confirmation; FE removes the row from the list and shows a success toast.

---

## Error paths

| Step | Failure condition | Status | Error code |
|---|---|---|---|
| Create | `name` empty | 400 | `VALIDATION_ERROR` |
| Create | `configSnapshot` empty | 400 | `VALIDATION_ERROR` |
| Create / List / Get / Delete | Caller has no owned Agency | 404 | `AGENCY_NOT_FOUND` |
| Get / Delete | Template does not exist | 404 | `NOT_FOUND` |
| Get / Delete | Template belongs to a different Agency | 403 | `FORBIDDEN` |

## Notes

- All four `WorkspaceTemplateServiceImpl` methods are implemented; the earlier stub (`UnsupportedOperationException`) is resolved.
- `getTemplate` now enforces the same Agency-scope check as `deleteTemplate` (patched in this pass — previously only `deleteTemplate` had it).
- Templates are a standalone resource, not nested inside an Agency or a Workspace.
- No specific role restriction is currently applied to these actions (BR-05) — still to be confirmed, independent of the (now-resolved) stub issue.
- The "detail" view surfaced in the UI is an inline expand within the templates list page (Flow C), not the `GET /{templateId}` endpoint (Flow C.1), which exists at the API level but is not called by the current FE.
