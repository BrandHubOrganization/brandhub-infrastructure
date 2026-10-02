# FR 3.5.9 - Update Content Request

| Field | Value |
|---|---|
| Status | Depends on FR 3.5.7 |
| Roles | Requesting Client |
| Delivery task | DA-E50-10 |

## Outcome

The requesting Client may update title or description only while the request is `PENDING`.

## Acceptance criteria

- `PATCH /api/v1/workspaces/{workspaceId}/content-requests/{requestId}` accepts title and/or description.
- Non-owner clients receive `403`.
- A request outside `PENDING` receives `409 REQUEST_NOT_EDITABLE`.
- Concurrent manager status change is handled by rechecking status atomically at write time.
