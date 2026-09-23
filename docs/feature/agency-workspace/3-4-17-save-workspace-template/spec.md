# 3.4.17 Save Workspace Template

| | |
|---|---|
| FR Code | 3.4.17 |
| Feature | Save Workspace Template |
| Domain | Agency & Workspace (FR 3.4) |
| Role | Signed-in Agency member (no specific role restriction is applied) |
| Version | 2.2 — 2026-09-23 — rewritten to the standard FR format |
| Document status | Implemented |

## Function Trigger

Begins when a signed-in Agency member saves the configuration of an existing Workspace as a template.

## Function Description

- **Actors / Roles:** Any signed-in member of the Agency; no specific role restriction is applied.
- **Purpose:** Lets a member store a Workspace configuration as a reusable template so similar Workspaces can be created faster later.
- **Interface:** "Save as Template" action inside Workspace settings, plus a separate template list screen with a detail view and a delete action.
- **Data Processing:** The system stores the template with the configuration snapshot captured from the Workspace, scoped automatically to the caller's Agency and creator identity.

## Screen Layout

Figure — Save Workspace Template Screen:
- A "Save as Template" action in Workspace settings.
- A form with the template name, an optional source Workspace, and the configuration snapshot.
- A separate template list screen with a detail view and a delete action per template.

## Function Details

### Data Specifications

- **Input required:** name; configSnapshot (a JSON snapshot of the Workspace configuration).
- **Input optional:** sourceWorkspaceId (the Workspace the template was captured from).
- **System data:** The caller's authenticated identity; the Agency the caller belongs to; the creation timestamp.
- **Output:** The stored template — id, agencyId, name, sourceWorkspaceId, configSnapshot, createdBy, createdAt. The template list returns the same shape per entry, and the detail view returns one entry.

### Business Rules

- **BR-01:** The Agency and the creator of the template are taken automatically from the caller and never from the request payload.
- **BR-02:** Templates are a standalone resource, not nested inside an Agency or a Workspace; the available actions are create, list, view detail, and delete.
- **BR-03:** `name` or `configSnapshot` empty → 400 `VALIDATION_ERROR`.
- **BR-04:** Requesting or deleting a template that does not exist → 404 `NOT_FOUND`.
- **BR-05:** No specific role restriction is currently applied to these actions; whether access should be limited by Agency or role is still to be confirmed.
- **BR-06:** A template is independent of its source Workspace — it remains available even after that Workspace is deleted.

### Validation

- `name` must not be empty; otherwise 400 `VALIDATION_ERROR`.
- `configSnapshot` must not be empty; otherwise 400 `VALIDATION_ERROR`.
- The template must exist for detail and delete actions; otherwise 404 `NOT_FOUND`.

## Functionalities

### Normal Flow

1. Member opens Workspace settings and chooses "Save as Template".
2. Member fills in the template name, an optional source Workspace, and the configuration snapshot.
3. System validates that the name and snapshot are not empty.
4. System attaches the caller's Agency and identity automatically.
5. System stores the template and confirms it, adding it to the template list.
6. Member can later list templates, open one in detail, or delete it.

### Abnormal Cases

- `name` empty → 400 `VALIDATION_ERROR`; the user supplies a name and resubmits.
- `configSnapshot` empty → 400 `VALIDATION_ERROR`; the user captures the configuration and resubmits.
- Detail or delete requested for a template that does not exist → 404 `NOT_FOUND`.
- The source Workspace is deleted after the template was saved → the template still exists, because the stored snapshot does not depend on the source Workspace.

## Post-Conditions

- A template exists within the caller's Agency with the captured configuration snapshot.
- The template remains available independently of the source Workspace.

## Out of Scope

- Sharing templates across different Agencies (templates stay within one Agency).

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
