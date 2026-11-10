# FR 3.5.8 - Track Content Request Status

| Field | Value |
|---|---|
| Status | Depends on FR 3.5.7 V2 migration and E51-01 |
| Roles | Manager; Client read-only |
| Delivery task | DA-E50-10 |

## Outcome

Manager moves a content request through `PENDING`, `IN_PROGRESS`, `ACCEPTED`, or `DENIED`. On first acceptance, the system creates exactly one backlog task.

## Acceptance criteria

- Only an authorised Manager changes status; Client can read it only.
- Confirmed 2026-10-13: `PENDING -> IN_PROGRESS` is triggered only when Manager explicitly clicks **Tiếp nhận yêu cầu**. Opening a list/detail page never changes state.
- `IN_PROGRESS` displays as **Đang xem xét**; it is request review, not Task execution. Record the reviewing actor and time. The Client loses edit/cancel permission immediately upon successful receipt.
- Only `PENDING -> IN_PROGRESS`, `IN_PROGRESS -> ACCEPTED`, `IN_PROGRESS -> DENIED`, and creator cancellation `PENDING -> CANCELLED` are supported; no direct accept/deny from `PENDING`. Terminal states never reopen.
- Acceptance is idempotent and creates a generic task with `campaignId: null`, copied type/due date, and `sourceType=CONTENT_REQUEST` plus `sourceRefId`.
- A list/detail read model lets both permitted parties track the result.
- Do not report successful acceptance unless the generated Task is durably present and linked. Retried acceptance returns the same Task, without overwriting its subsequent execution state.

## UI contract

Use parallel vi/en `requests.v2.status.*`, `requests.v2.review.*`, `requests.v2.generatedTask`
and `requests.v2.taskStatus.*` keys. Show actions by server capabilities derived from
effective Workspace role. Confirm irreversible accept/deny, disable writes while loading,
retain denial note on conflict, and use semantic light/dark tokens with keyboard-accessible controls.
`GET /{id}/task` gives Request readers a read-only Task summary; only a Workspace Manager
with POST sees an editor link. Client does not gain editor or assignment permissions.
Assignment and Task approval belong to E51, not to Request statuses.

Confirmed during phase 3: a new Task keeps existing defaults — BACKLOG, no Creator/QC,
`requiresClientApproval=false`, empty typeMetadata and approvalRound 1. Manager configures
Task details later. Optional denial note is plain text <=2000 and visible to the Client.
