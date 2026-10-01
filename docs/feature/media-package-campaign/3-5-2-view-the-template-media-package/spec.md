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
- Support duration, budget, and full-delegation package types.
- A non-member receives `403`; no selection returns a documented no-selection response.

## Constraints

- Read through `workspace_media_packages` and its one `package_id`.
- Full-delegation KPI commitments need explicit data fields before presentation as structured values; until then they remain in approved terms.
