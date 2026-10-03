# FR 3.5.2 - View Media Package

| Field | Value |
|---|---|
| Status | Ready for technical review |
| Roles | Owner/Manager; Client (already added at workspace creation) |
| Delivery task | DA-E50-03 |

## Outcome

An authorised workspace member can read the package selected for that workspace, including negotiation state and effective terms.

## Acceptance criteria

- `GET /api/v1/workspaces/{workspaceId}/media-package` returns selected package, package type, scope description, current terms, and negotiation status.
- `GET /api/v1/workspaces/{workspaceId}/media-packages` returns only available non-template packages
  whose `agencyId` matches the Workspace, so Client selection cannot use global templates or cross Agency boundaries.
- Support duration, budget, and full-delegation package types.
- A non-member receives `403`; no selection returns a documented no-selection response.
- The workspace page renders a selected-package summary with source, type-specific value, effective
  terms, terms version, negotiation status, and approval state.
- A missing selection is an informative empty state rather than a destructive error toast.
- The same missing-selection state appears prominently on the Workspace dashboard, with a selection action for Client.
- UI copy uses key-parallel Vietnamese/English `mediaPackage` translations and semantic light/dark
  theme tokens.

## Constraints

- Read through `workspace_media_packages` and its one `package_id`.
- Full-delegation KPI commitments need explicit data fields before presentation as structured values; until then they remain in approved terms.
