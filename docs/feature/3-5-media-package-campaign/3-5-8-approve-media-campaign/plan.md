# Plan - FR 3.5.6

## Scope

Implement E50-07 campaign approval and idempotent task deployment.

2026-10-08: M2 approval can be delivered before M3 deployment. See
[delivery plan](../campaign-delivery-plan.md). Mongo V2 is confirmed; deployment
still requires editor integration and explicit launch conditions.

Stage 3 adds `campaign_versions` and append-only `campaign_review_events`, plus
actor/version columns on `media_campaigns`. The Workspace API exposes feedback,
versions and approval. Agreement row locking serializes concurrent edits and
approvals; a stale version returns 409. Inbox notifications use the existing
`user_notifications` table and the Campaign Workspace URL.

Stage 4 uses deterministic UUIDs derived from Campaign ID and work item ID,
Mongo insert-only upserts, a partial unique index on `(campaignId,
campaignWorkItemId)`, and PostgreSQL deployment state. A retry reads the same
approved snapshot and inserts only missing Tasks. No Mongo database init or
account seed is part of the change. Editor REST and WebSocket access validate
the Mongo Task and current Workspace membership; PostgreSQL Yjs foreign keys
become soft references while the old Task table remains for read-only audit.

Before the PostgreSQL FK migration, preflight must show no unmigrated Task IDs.
The local preflight is 0 Task, 0 operation, 0 snapshot. Other environments need
their own backfill and reconciliation before application rollout. Mongo validator
and index migration is applied separately on the existing Atlas database.

## Plan

1. Reuse the confirmed two-party campaign approval rule.
2. Increment campaign content version/reset both approvals on a pre-final-approval edit.
3. Implement the Mongo backlog adapter and integrate the existing editor. Use
   task insert-only upserts keyed by campaign ID and
   stable work-item ID, with a partial unique index for campaign-generated tasks.
4. Record deployment progress/retry state durably in PostgreSQL; resume after failure
   or restart, and ensure retries never overwrite a Task already being worked on.
5. Mark campaign `IN_PROGRESS` only after all work-item tasks are durable.
6. Test double deploy and mid-deployment retry without duplicates.
7. Add approval/launch UI with version indicators, opposite-side inbox notifications,
   paired vi/en text, light/dark states and recoverable failure feedback.
8. Implement Client feedback and Manager edits; add explicit Manager completion from
   IN_PROGRESS, requiring a reason if Tasks are unfinished. Preserve Task states/workflow;
   see [phase-1 contract](../phase-1-design/plan.md) for retries, metadata and Mongo failure handling.

## Dependencies

Requires E50-06 work items and E51-01 generic tasks.
