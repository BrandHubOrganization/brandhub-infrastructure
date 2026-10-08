# Plan - FR 3.5.5

## Scope

Implement E50-06 creation of a draft campaign from an approved workspace package.

Updated 2026-10-08: this is a staged proposal, not approval to implement undecided
behavior. Follow M1/M2 and Q3/Q5/Q6 in [delivery plan](../campaign-delivery-plan.md).

## Plan

1. Audit duplicate campaigns per agreement and current Workspace agreement uniqueness.
   Deliver the new cooperation-round prerequisite under a Jira follow-up before
   changing single-agreement queries. Then add a unique campaign agreement FK,
   `work_items JSONB NOT NULL DEFAULT '[]'` and `content_version INT NOT NULL DEFAULT 1`
   migration plus equivalent V2 init schema update. Do not delete duplicate history.
2. Validate each item has stable ID, task type, name, and due date.
3. Validate approved package, workspace access, and campaign payload.
4. Create/read/update `DRAFT` plans with a version guard; enforce one Campaign per
   agreement, including concurrent requests. Multiple Campaigns in one Workspace
   require different agreements. Keep compatibility with the existing draft API.
5. Replace cross-Campaign allocations with periods/phases inside the single Campaign
   after period and service mapping decisions are confirmed.
6. Add Campaign list/detail/editor in Web, paired vi/en keys and light/dark/responsive
   states; retain access to earlier rounds while negotiating the next.

