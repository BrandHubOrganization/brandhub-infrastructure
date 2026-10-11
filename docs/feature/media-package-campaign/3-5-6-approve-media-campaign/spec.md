# FR 3.5.6 - Approve and Deploy Media Campaign

| Field | Value |
|---|---|
| Status | Implemented in code; Atlas migration verification and live flow testing pending (2026-10-10) |
| Roles | Client; Owner/Manager |
| Delivery task | DA-E50-07 / DA-948 |

## Outcome

Both parties approve a campaign, then deployment creates one generic Mongo task per planned campaign work item in `backlog` and sets the campaign to `IN_PROGRESS`.

## Acceptance criteria

- Approval needs Agency and Client timestamps for the same campaign content version; any edit invalidates both prior approvals.
- Deploy rejects a campaign that is not fully approved.
- Generated tasks contain `workspaceId`, `campaignId`, type, name, due date, and `status=backlog`; they initially have no assignee.
- Retrying/deploying twice cannot duplicate a task for one campaign work item.
- Client gives feedback; Manager edits, and both parties approve the revised version.
- Manager explicitly marks an IN_PROGRESS Campaign completed. Unfinished tasks require
  a reason; preserve child Task states and their workflow. Record actor/time/reason/summary.

## Constraint

PostgreSQL and MongoDB have no shared transaction. Deploy needs stable work-item ID plus Mongo unique/upsert key on `{campaignId, campaignWorkItemId}`, not only a `deployed_at` timestamp.

## Delivery gate (2026-10-08)

Mongo V2 is confirmed as the Task source of truth. Current PostgreSQL Task and
Content Writing foreign keys still require integration work before deployment;
do not create unrelated Task copies in both stores. One Workspace has one Campaign;
new campaigns use new Workspaces, with an Owner duplication feature planned.
See [delivery plan](../campaign-delivery-plan.md) for the remaining decisions.

## Stage 3 review and approval contract (2026-10-09)

- Client submits feedback for the Campaign version currently displayed. Feedback is
  append-only and does not change the plan or its content version.
- Manager edits a draft plan; a material edit increments `contentVersion`, records a
  full immutable snapshot, and invalidates both previous approvals. No-op saves do not.
- Each side approves the exact version it viewed. The same actor cannot supply both
  approvals. One-sided approval leaves status `DRAFT`; both sides approving the same
  version moves it to `APPROVED`. Approved content is immutable.
- Approval requires a strategy, both timeline dates, and at least one work item.
  Feedback, edits, and approvals notify the opposite side through the existing inbox.
- Campaign version snapshots and review events are retained for comparison/audit.
  The Workspace-scoped API enforces current Workspace membership and role.
- Deploy and completion belong to Stage 4 and are not enabled by this stage.

## Stage 4 deployment and completion contract

- Manager explicitly deploys a fully approved Campaign. Every planned work item
  becomes one generic Mongo `tasks` document in `BACKLOG`, retaining its stable
  `campaignWorkItemId`, Workspace, Campaign, type, name and due date. The new Task
  has no assignee or QC assignee. Retry must not alter an existing Task.
- Deployment progress is durable in PostgreSQL. The Campaign becomes `IN_PROGRESS`
  only after Mongo confirms every work item. A failed or interrupted deployment
  can be retried using the same Task identities.
- PostgreSQL editor content remains stored in its Yjs tables, referenced by Task
  UUID. Mongo is the Task source of truth; no second PostgreSQL Task is created.
- Manager explicitly marks an `IN_PROGRESS` Campaign complete. When any linked
  Task is unfinished, a nonblank reason is required. Completion records actor,
  time, reason and Task summary, without changing any child Task state.
- Existing Task IDs and editor content must be preserved during cutover. Local
  preflight on 2026-10-09 found zero PostgreSQL tasks/operations/snapshots; other
  environments must pass an independent preflight/backfill before switching.
