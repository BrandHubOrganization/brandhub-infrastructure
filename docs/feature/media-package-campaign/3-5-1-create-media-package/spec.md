# FR 3.5.1 - Create Media Package

| Field | Value |
|---|---|
| Status | Ready for technical review |
| Roles | Admin; Owner/Manager; Client |
| Delivery task | DA-E50-01 |

## Outcome

Admin templates and Agency-custom packages use the same `media_packages` record. Templates have `is_template=true` and no agency; custom packages have `is_template=false` and belong to one agency.

## Acceptance criteria

- List template packages with `GET /api/v1/media-package-templates`.
- All Agencies can view Admin templates (`is_template=true`, `agencyId=null`).
- A Client selects a template after the Workspace has been created with the Client already added.
- After discussion with the Client, Owner/Manager creates a custom package with `POST /api/v1/agencies/{agencyId}/media-package-custom`.
- A package provides `id`, `name`, `type`, `durationWeeks`, `budgetAmount`, `scopeDescription`, `isTemplate`, and `agencyId` where applicable.
- Workspace selection is delivered by DA-E50-02 and uses one `package_id` reference.

## Constraints

- Only Admin owns global templates; authoring UI is out of scope.
- Global templates are initially supplied by seed data while the Admin stream implements authoring.
- A custom package cannot be exposed as a global template.
- Do not use the obsolete polymorphic `packageRefType` database model.

## Open decision

The reminder delay/cadence after workspace creation is unspecified. The reminder should target the Client responsible for selection; whether the Manager is copied is still to be confirmed.
