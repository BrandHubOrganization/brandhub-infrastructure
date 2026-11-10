# Plan - FR 3.5.8

## Scope

Implement Manager status transitions, request tracking, and one-task creation on acceptance.

## Plan

1. Add explicit Manager receipt PENDING → IN_PROGRESS; only then accept/deny. Record actor/time; effective MANAGER membership includes Owner acting as Workspace Manager.
2. Use a verified Mongo transaction for acceptance, Task insertion and Request/audit update; do not report ACCEPTED before the Task exists. Retry returns the same stable Task ID without overwriting execution state.
3. Add a NEW migration for missing source uniqueness/indexes (never edit a merged generic-task migration). Verify sourceType/sourceRefId and schema guard for CONTENT_REQUEST.
4. Create generic task with `campaignId: null`, copied type/due date, `status: backlog`, and content-request source reference.
5. Add list/detail queries and test terminal-state and idempotency cases.

## Dependencies

Requires content-request persistence and E51-01 generic task collection.

See [shared plan](../remaining-work/plan.md) for atomicity/rollout. Existing requests remain processable after Campaign completion. Add vi/en `requests.json` receive/review/status/task-link keys and test light/dark/mobile, without mixing E51 assignment into Request statuses.
