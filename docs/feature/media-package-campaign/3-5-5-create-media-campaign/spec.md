# FR 3.5.5 - Create Media Campaign

| Field | Value |
|---|---|
| Status | Implemented in code; live API/concurrency verification pending (2026-10-10) |
| Roles | Owner/Manager |
| Delivery task | DA-E50-06 / DA-947 |

## Outcome

> Current implementation uses Workspace-scoped create/list/detail/PATCH endpoints.
> The earlier `/api/v1/media-campaigns` create route remains compatible and also
> enforces one Campaign per agreement and total quantities. Frozen terms, work items
> and content versions are persisted; live verification remains in the
> [roadmap](../implementation-roadmap.md).

Owner/Manager creates a `DRAFT` campaign from an approved workspace package. The campaign is an execution plan, not a contract.

## Acceptance criteria

- `POST /api/v1/workspaces/{workspaceId}/campaigns` rejects an unapproved package with `PACKAGE_NOT_APPROVED`.
- A campaign stores name, strategy detail, brand guideline, timeline, status, `contentVersion`, approvals, and JSONB `workItems`.
- Each work item has stable `id`, `deliverableId`, `name`, `type`
  (`POST|LIVESTREAM|SURVEY|EVENT_PLAN|PRESS_RECOMMENDATION`) and `dueDate`, so deployment creates one task exactly once.
- A Workspace has at most one Campaign, including DRAFT and COMPLETED. A new
  campaign uses a new Workspace; an Owner duplication feature is planned separately.
- Keep one selected WorkspaceMediaPackage per Workspace. Do not implement multiple
  cooperation rounds or allow agreement reassignment to bypass Campaign uniqueness.
- New packages use total quantities for the whole package, with no monthly allowance.
  Legacy monthly snapshots remain unchanged and require explicit handling, not automatic
  conversion. See [phase-1 contract](../phase-1-design/plan.md) for fields/API and migration gates.

## Constraint

Task IDs are not a substitute for planned work items: tasks exist only after deployment. `workItems` is stored in PostgreSQL JSONB and is the deployment source of truth.

## Approval-version rule

The campaign starts at content version 1. Editing campaign content or work items before final approval increments the version and invalidates both prior approvals; content is immutable once both parties approve.
