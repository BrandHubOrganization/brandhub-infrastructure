# Plan - FR 3.5.6

## Scope

Implement E50-07 campaign approval and idempotent task deployment.

2026-10-08: M3 approval can be delivered before M4 deployment. See
[delivery plan](../campaign-delivery-plan.md). M4 requires the Task/editor storage
decision and the concurrent-Campaign launch rule; do not silently select either.

## Plan

1. Reuse the confirmed two-party campaign approval rule.
2. Increment campaign content version/reset both approvals on a pre-final-approval edit.
3. After the Task storage decision, implement the agreed backlog adapter. If Mongo
   remains authoritative, use task insert-only upserts keyed by campaign ID and
   stable work-item ID, with a partial unique index for campaign-generated tasks.
4. Record deployment progress/retry state durably in PostgreSQL; resume after failure
   or restart, and ensure retries never overwrite a Task already being worked on.
5. Mark campaign `IN_PROGRESS` only after all work-item tasks are durable.
6. Test double deploy and mid-deployment retry without duplicates.
7. Add approval/launch UI with version indicators, opposite-side inbox notifications,
   paired vi/en text, light/dark states and recoverable failure feedback.

## Dependencies

Requires E50-06 work items and E51-01 generic tasks.
