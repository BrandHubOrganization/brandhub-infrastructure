# Plan - FR 3.5.6

## Scope

Implement E50-07 campaign approval and idempotent task deployment.

## Plan

1. Reuse the confirmed two-party campaign approval rule.
2. Increment campaign content version/reset both approvals on a pre-final-approval edit.
3. Create Mongo task upserts keyed by campaign ID and stable work-item ID.
4. Record deployment progress/retry state in PostgreSQL.
5. Mark campaign `IN_PROGRESS` only after all work-item tasks are durable.
6. Test double deploy and mid-deployment retry without duplicates.

## Dependencies

Requires E50-06 work items and E51-01 generic tasks.
