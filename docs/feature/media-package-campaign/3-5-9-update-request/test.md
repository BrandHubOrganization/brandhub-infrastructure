# Test - FR 3.5.9

| Case | Expected result |
|---|---|
| Creator edits pending request | Requested fields update. |
| Other Client edits | `403`. |
| In-progress/terminal request | `409 REQUEST_NOT_EDITABLE`. |
| Race with Manager transition | Conditional write prevents stale edit. |
