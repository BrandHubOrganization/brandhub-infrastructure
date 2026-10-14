# FR 3.5.9 - Update Content Request

| Field | Value |
|---|---|
| Status | Depends on FR 3.5.7 |
| Roles | Requesting Client |
| Delivery task | DA-E50-10 |

## Outcome

Confirmed 2026-10-13: the requesting Client may update title, description, type and dueDate only while the request is `PENDING`. Manager receipt immediately locks all four fields.

## Acceptance criteria

- `PATCH /api/v1/workspaces/{workspaceId}/content-requests/{requestId}` accepts one or more of `title`, `description`, `type`, `dueDate`; validate the resulting request using the same rules as creation. Reject an empty patch and unsupported fields.
- Non-owner clients receive `403`.
- A request outside `PENDING` receives `409 REQUEST_NOT_EDITABLE`.
- Concurrent manager status change is handled by rechecking status atomically at write time.
- Check supplied version and status; concurrent Client edits must not overwrite each other. Confirmed 2026-10-14: Manager completion automatically cancels PENDING; no Client edits after completion. See ../request-completion-validation/spec.md for deadline rules and concurrency.

## UI contract

Reuse the creation fields and parallel vi/en `requests.revise.*`, `requests.fields.*`, `requests.errors.conflict` keys. After receipt, show read-only values and the reason editing is locked. Preserve unsaved input on conflicts; light/dark themes and mobile forms use existing components/tokens.
