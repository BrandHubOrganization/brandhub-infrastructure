# FR 3.5.10 - Cancel Content Request

| Field | Value |
|---|---|
| Status | Ready for technical review |
| Roles | Requesting Client |
| Delivery task | DA-E50-10 |

## Outcome

The requesting Client can cancel a request only while it remains `PENDING`.

## Acceptance criteria

- `DELETE /api/v1/workspaces/{workspaceId}/content-requests/{requestId}` is permitted only to creator and only from `PENDING`.
- A non-pending request returns `409 REQUEST_NOT_CANCELLABLE`.
- Cancellation never creates a task or alters an existing generated task.
- Confirmed 2026-10-14: Manager marking Campaign COMPLETED automatically cancels PENDING Requests with history; IN_PROGRESS is not cancelled. This is a system consequence of completion, not a general Manager cancel endpoint. See ../request-completion-validation/spec.md.
- Manager receipt and Client cancellation compete through an atomic status/version predicate; only one succeeds. Owner/Manager cannot cancel on behalf of the requester in this scope.

## UI contract

Use existing confirmation UI with parallel vi/en `requests.cancelDialog.*` and `requests.status.cancelled` keys. Retain cancelled requests in list/detail history, with no edit/reopen action. Support keyboard focus, pending/error states and semantic light/dark tokens.

## Retention rule

Cancellation is a terminal `CANCELLED` status, not a hard delete. It remains visible in appropriate history/audit views and can never generate a task.
