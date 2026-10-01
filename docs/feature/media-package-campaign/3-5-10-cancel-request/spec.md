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

## Retention rule

Cancellation is a terminal `CANCELLED` status, not a hard delete. It remains visible in appropriate history/audit views and can never generate a task.
