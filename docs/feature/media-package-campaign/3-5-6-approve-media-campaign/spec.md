# FR 3.5.6 - Approve and Deploy Media Campaign

| Field | Value |
|---|---|
| Status | Depends on FR 3.5.5, Task storage/editor alignment and pending BA decisions |
| Roles | Client; Owner/Manager |
| Delivery task | DA-E50-07 / DA-948 |

## Outcome

Both parties approve a campaign, then deployment creates one generic Mongo task per planned campaign work item in `backlog` and sets the campaign to `IN_PROGRESS`.

## Acceptance criteria

- Approval needs Agency and Client timestamps for the same campaign content version; any edit invalidates both prior approvals.
- Deploy rejects a campaign that is not fully approved.
- Generated tasks contain `workspaceId`, `campaignId`, type, name, due date, and `status=backlog`; they initially have no assignee.
- Retrying/deploying twice cannot duplicate a task for one campaign work item.

## Constraint

PostgreSQL and MongoDB have no shared transaction. Deploy needs stable work-item ID plus Mongo unique/upsert key on `{campaignId, campaignWorkItemId}`, not only a `deployed_at` timestamp.

## Delivery gate (2026-10-08)

The V2 Mongo target above conflicts with the current PostgreSQL Task entity and
Content Writing foreign keys. Resolve the shared Task contract before coding
deployment; do not create unrelated Task copies in both stores. Next-round
negotiation is permitted while the current Campaign runs, but concurrent Campaign
deployment is not yet confirmed. See [delivery plan](../campaign-delivery-plan.md).
