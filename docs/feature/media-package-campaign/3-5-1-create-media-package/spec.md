# FR 3.5.1 - Create Media Package

| Field | Value |
|---|---|
| Status | Ready for technical review |
| Roles | Admin; Agency Owner; Client |
| Delivery task | DA-E50-01 |

## Outcome

Admin templates and Agency packages use the same `media_packages` record. Templates have `is_template=true` and no agency; selectable packages have `is_template=false`, belong to one Agency, and may retain their source template ID.

## Acceptance criteria

- List template packages with `GET /api/v1/media-package-templates`.
- All Agencies can view Admin templates (`is_template=true`, `agencyId=null`).
- An Agency Owner creates an Agency package with `POST /api/v1/agencies/{agencyId}/media-package-custom`, either independently or from an optional `sourceTemplateId`.
- A package provides `id`, `name`, `type`, `durationWeeks`, `budgetAmount`, `scopeDescription`, `isTemplate`, `agencyId`, `sourceTemplateId`, and `availableToWorkspaces` where applicable.
- Workspace selection is delivered by DA-E50-02 and uses one `package_id` reference.
- The Agency Media Package screen at `/agency/{agencyId}/media-packages` is the Owner's management
  surface. It lists global templates and persisted Agency packages, supports cloning a template, and lets the Owner hide/show Agency packages.
- Creating an Agency package does not require a Workspace; the resulting package belongs to the Agency catalogue.
- The Workspace Media Package screen lists only packages belonging to that Workspace's Agency with `availableToWorkspaces=true`, and exposes selection only to the Client role.
- `GET /api/v1/agencies/{agencyId}/media-package-custom` reloads persisted custom packages for management.
- `GET /api/v1/workspaces/{workspaceId}/media-packages` returns packages available for Client selection.
- `PATCH /api/v1/agencies/{agencyId}/media-packages/{packageId}/availability` changes Agency-wide Workspace visibility.
- The Workspace dashboard prompts the Client to select a package when none has been selected.
- UI copy uses the `mediaPackage` namespace with key-parallel Vietnamese and English locale files.
- Loading, empty, error, selected, and submitting states work in both light and dark themes using
  semantic theme tokens.

## Constraints

- Only Admin owns global templates; authoring UI is out of scope.
- Global templates are initially supplied by seed data while the Admin stream implements authoring.
- A custom package cannot be exposed as a global template.
- Only the Agency Owner may create packages or change their Workspace visibility.
- Global templates cannot be selected directly by a Workspace.
- Hiding an Agency package affects new selections only; an existing Workspace selection remains readable and negotiable.
- Do not use the obsolete polymorphic `packageRefType` database model.

## Open decision

The reminder delay/cadence after workspace creation is unspecified. The reminder should target the Client responsible for selection; whether the Manager is copied is still to be confirmed.
