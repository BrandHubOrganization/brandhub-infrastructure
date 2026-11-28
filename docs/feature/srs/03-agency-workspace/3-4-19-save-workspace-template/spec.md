> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.4.19 — Save Workspace Template

| | |
|---|---|
| FR Code | 3.4.19 |
| Feature | Save Workspace Template |
| Domain | Agency & Workspace (FR 3.4) |
| Role | Owner |
| Version | 2.5 — 2026-09-25 — `WorkspaceTemplateServiceImpl` implemented (agency-scoped save/list/get/delete); stub warning resolved; `getTemplate` read-scope gap patched |
| Document status | Implemented |

## Function Trigger

Begins when a signed-in Agency member saves the configuration of an existing Workspace as a template.

## Function Description

- **Actors / Roles:** `Owner`.
- **Purpose:** Lets a member store a Workspace configuration as a reusable template so similar Workspaces can be created faster later.
- **Interface:** A "Save as Template" modal opened from Workspace settings (`detail.tsx`), plus a "View all templates" link to a separate templates list page (`templates.tsx`, routed at `/workspaces/templates`). ⚠ There is **no separate detail route/page** — the templates list page implements detail as an inline expand row (click the template name to toggle showing its `configSnapshot` inline); there is no dedicated URL for a single template's detail view.
- **Data Processing:** The system stores the template with the configuration snapshot captured from the Workspace, scoped automatically to the caller's Agency (resolved via the Agency the caller owns — same lookup as `WorkspaceServiceImpl.listMyWorkspaces`) and creator identity taken from the authenticated session.

## Screen Layout

Figure — Save Workspace Template Screen:
- A "Save as Template" button plus a "View all templates" link, both inside Workspace settings, shown only when `canManage` is true.
- The "Save as Template" action opens a modal with a template name input; the configSnapshot is built automatically from the current Workspace's `timezone`, `defaultPlatforms`, and `reportFrequency` (JSON-stringified) — there is no free-form configSnapshot input and no `sourceWorkspaceId` picker in the UI (it is set silently to the current workspace's id).
- The templates list page (`/workspaces/templates`) shows each template's name and creation date; clicking the name toggles an inline expand showing the raw `configSnapshot` text; a delete (trash) button removes it. There is no separate detail screen/route.

## Function Details

### Data Specifications

- **Input required:** name; configSnapshot (a JSON snapshot of the Workspace configuration).
- **Input optional:** sourceWorkspaceId (the Workspace the template was captured from).
- **System data:** The caller's authenticated identity; the Agency the caller belongs to; the creation timestamp.
- **Output:** The stored template — id, agencyId, name, sourceWorkspaceId, configSnapshot, createdBy, createdAt. The template list returns the same shape per entry, and the detail view returns one entry.

### Business Rules

- **BR-29:** Multi-tenancy — the Agency and the creator of the template are taken automatically from the caller's session and never from the request payload; a template is scoped to the caller's Agency (`saveTemplate`/`listTemplates`/`deleteTemplate` all resolve `agencyId` via the Agency the caller owns).
- **BR-02:** Templates are a standalone resource, not nested inside an Agency or a Workspace; the available actions are create, list, delete, and inline-expand-to-view within the list (no separate detail route — see Screen Layout).
- **BR-03:** `name` or `configSnapshot` empty → 400 `VALIDATION_ERROR`.
- **BR-04:** Requesting or deleting a template that does not exist → 404 `NOT_FOUND`.
- **BR-05:** No specific role restriction is currently applied to these actions; whether access should be limited by Agency or role is still to be confirmed. ⚠ BA conflict (needs team decision): no dedicated BR-xx code in `Section5_Requirement_Appendix.md` covers this; needs a code assigned if a role restriction is intended.
- **BR-06:** A template is independent of its source Workspace — it remains available even after that Workspace is deleted.
- **Implementation note:** `getTemplate` and `deleteTemplate` both enforce the caller owns the template's Agency (403 `FORBIDDEN` otherwise) — `getTemplate` takes `currentUser` for this check as of this pass.

### Validation

- `name` must not be empty; otherwise 400 `VALIDATION_ERROR`, MSG02 (enforced via `@NotBlank` on `SaveWorkspaceTemplateRequest.name`).
- `configSnapshot` must not be empty; otherwise 400 `VALIDATION_ERROR`, MSG02 (enforced via `@NotBlank` on `SaveWorkspaceTemplateRequest.configSnapshot`).
- The template must exist for delete/get; otherwise 404 `NOT_FOUND`, toast MSG38.
- Getting or deleting a template belonging to a different Agency → 403 `FORBIDDEN`.

## Functionalities

### Normal Flow

1. Member opens Workspace settings and clicks "Save as Template", opening a modal.
2. Member fills in the template name; the configSnapshot is built automatically from the current Workspace's `timezone`/`defaultPlatforms`/`reportFrequency`, and `sourceWorkspaceId` is set to the current workspace's id — neither is a free-form input.
3. FE calls `POST /api/v1/workspace-templates`; System validates that the name and snapshot are not empty.
4. System resolves the caller's owned Agency and attaches `agencyId`/`createdBy` automatically (never from the request body).
5. System stores the template and returns it; FE shows a success toast and closes the modal. ⚠ Toast message key used is `workspace.settings.template.saveSuccess` (an i18n key), not literally MSG32 — MSG32 in the Section5 appendix is "Updating workspace settings successfully" / "Settings saved.", a different, unrelated message; do not reuse MSG32 for template-save success without confirming a dedicated MSG code with BA.
6. Member can later open `/workspaces/templates` to list templates, expand one inline to view its configSnapshot, or delete it.

### Abnormal Cases

- 3.a1: `name` empty → 400 `VALIDATION_ERROR`, Display: MSG02. 3.a2: The user supplies a name and resubmits.
- 3.b1: `configSnapshot` empty → 400 `VALIDATION_ERROR`, Display: MSG02. 3.b2: The user captures the configuration and resubmits. (In the current UI this cannot happen — configSnapshot is always auto-built and non-empty.)
- 6.a1: Delete/get requested for a template that does not exist (BR-04) → 404 `NOT_FOUND`, toast MSG38. 6.a2: The user returns to the template list, which no longer shows that entry.
- 6.b1: The source Workspace is deleted after the template was saved (BR-06) → no error is raised. 6.b2: The template still exists and remains listable, because the stored snapshot does not depend on the source Workspace.
- 6.c1: Delete requested for a template belonging to another Agency → 403 `FORBIDDEN`. 6.c2: The user has no access; the template is unaffected.

## Post-Conditions

- A template exists within the caller's Agency with the captured configuration snapshot.
- The template remains available independently of the source Workspace.

## Out of Scope

- Sharing templates across different Agencies (templates stay within one Agency).

## References

[01-organization-structure.md](../../../../ba/01-organization-structure.md), [03-agency-workspace-management.md](../../../../ba/03-agency-workspace.md)

## Cross-Platform UI, i18n & Theme Acceptance Criteria

- **Endpoints & Implementation:** `POST /api/v1/workspace-templates · POST /api/v1/workspace-templates/global` (`WorkspaceTemplateController.saveTemplate() / saveGlobalTemplate()` -> `WorkspaceTemplateServiceImpl.saveTemplate() / saveGlobalTemplate()`). Snapshots sanitized Workspace configuration (`timezone_config`, industry, posting frequency, default platforms, workflow settings) into `workspace_templates` (`BR-24`), stripping all Client identities, social OAuth tokens, tasks, and materials.
- **Internationalization (`vi` / `en`):** All labels, buttons, empty states, and error/confirmation toasts use key-parallel locale entries (`workspace.templates.save.*`) in both `vi` and `en` bundles — zero hardcoded UI text.
- **Semantic Light/Dark Theme:** Web (`src/pages/workspace/detail.tsx`, `src/pages/workspace/components/settings/SaveTemplateModal.tsx`, `src/pages/admin/WorkspaceTemplateLibrary.tsx`, `src/services/workspaceTemplateService.ts`) and Mobile (`src/services/workspaceService.ts`) surfaces use semantic theme tokens with WCAG-compliant contrast in both Light and Dark modes.
- **Related Documentation:** [BA Agency & Workspace Spec](../../../../ba/03-agency-workspace.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).