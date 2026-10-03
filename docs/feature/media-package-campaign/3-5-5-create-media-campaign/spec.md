# FR 3.5.5 - Create Media Campaign

| Field | Value |
|---|---|
| Status | Ready for technical review |
| Roles | Owner/Manager |
| Delivery task | DA-E50-06 |

## Outcome

Owner/Manager creates a `DRAFT` campaign from an approved workspace package. The campaign is an execution plan, not a contract.

## Acceptance criteria

- `POST /api/v1/workspaces/{workspaceId}/campaigns` rejects an unapproved package with `PACKAGE_NOT_APPROVED`.
- A campaign stores name, strategy detail, brand guideline, timeline, status, `contentVersion`, approvals, and JSONB `workItems`.
- Each work item has stable `id`, `name`, `type` (`POST|LIVESTREAM|SURVEY`), and `dueDate`, so deployment creates one task exactly once.
- A workspace may have multiple campaigns over time.

## Constraint

Task IDs are not a substitute for planned work items: tasks exist only after deployment. `workItems` is stored in PostgreSQL JSONB and is the deployment source of truth.

## Approval-version rule

The campaign starts at content version 1. Editing campaign content or work items before final approval increments the version and invalidates both prior approvals; a deployed campaign is immutable.
