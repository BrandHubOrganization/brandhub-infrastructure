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
- `PENDING -> IN_PROGRESS`, `PENDING/IN_PROGRESS -> ACCEPTED`, and `PENDING/IN_PROGRESS -> DENIED` are supported; terminal states do not reopen.
- Acceptance is idempotent and creates a generic task with `campaignId: null`, copied type/due date, and `sourceType=CONTENT_REQUEST` plus `sourceRefId`.
- A list/detail read model lets both permitted parties track the result.
