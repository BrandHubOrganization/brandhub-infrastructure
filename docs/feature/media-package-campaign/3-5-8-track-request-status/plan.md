# Plan - FR 3.5.8

## Scope

Implement Manager status transitions, request tracking, and one-task creation on acceptance.

## Plan

1. Enforce the documented state transitions and Manager-only mutation.
2. Atomically claim acceptance so repeated requests cannot create two tasks.
3. Add `sourceType`/`sourceRefId` to the generic-task migration and unique idempotency protection for a content request.
4. Create generic task with `campaignId: null`, copied type/due date, `status: backlog`, and content-request source reference.
5. Add list/detail queries and test terminal-state and idempotency cases.

## Dependencies

Requires content-request persistence and E51-01 generic task collection.
