# Test - FR 3.5.9

| Case | Expected result |
|---|---|
| Creator edits pending request | Requested fields update. |
| Other Client edits | `403`. |
| In-progress/terminal request | `409 REQUEST_NOT_EDITABLE`. |
| Race with Manager transition | Conditional write prevents stale edit. |
| Edit title/description/type/dueDate separately and together | All four editable PENDING; validate resulting values, increment version. |
| Empty/unknown fields/invalid type/date/stale version | Reject without partial mutation or silent overwrite. |
| Existing PENDING request after Campaign complete | Still editable by creator. |
| UI vi/en/light/dark/mobile | Shared fields accessible; input preserved on conflict. |
