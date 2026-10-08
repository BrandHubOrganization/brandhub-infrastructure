# FR 3.5.5 - Create Media Campaign

| Field | Value |
|---|---|
| Status | One-agreement/one-Campaign BA confirmed; dependent lifecycle/service decisions pending |
| Roles | Owner/Manager |
| Delivery task | DA-E50-06 / DA-947 |

## Outcome

> Current implementation slice: [offering models](../offering-models/spec.md).
> Draft creation uses the existing `/api/v1/media-campaigns` controller, with
> workspaceMediaPackageId in the body and server-side workspace authorization.
> This slice records frozen package terms and deliverable allocations. The workItems,
> contentVersion and approval/deployment criteria below remain the subsequent E50-06/07 scope;
> this change does not claim full FR 3.5.5/3.5.6 completion.

Owner/Manager creates a `DRAFT` campaign from an approved workspace package. The campaign is an execution plan, not a contract.

## Acceptance criteria

- `POST /api/v1/workspaces/{workspaceId}/campaigns` rejects an unapproved package with `PACKAGE_NOT_APPROVED`.
- A campaign stores name, strategy detail, brand guideline, timeline, status, `contentVersion`, approvals, and JSONB `workItems`.
- Each work item has stable `id`, `name`, `type` (`POST|LIVESTREAM|SURVEY`), and `dueDate`, so deployment creates one task exactly once.
- A workspace may have multiple campaigns over time, each for a different approved
  WorkspaceMediaPackage (cooperation round). A specific agreement has at most one
  Campaign, even while it is DRAFT. The catalogue MediaPackage can be reused in a new round.
- The next round can be negotiated while the current Campaign runs; permission to
  deploy both Campaigns concurrently has not been decided.
- RETAINER months and bundle phases belong inside one Campaign rather than creating
  several Campaigns from one agreement. Period boundaries and non-Task services are
  open decisions in [the delivery plan](../campaign-delivery-plan.md).

## Constraint

Task IDs are not a substitute for planned work items: tasks exist only after deployment. `workItems` is stored in PostgreSQL JSONB and is the deployment source of truth.

## Approval-version rule

The campaign starts at content version 1. Editing campaign content or work items before final approval increments the version and invalidates both prior approvals; content is immutable once both parties approve.
