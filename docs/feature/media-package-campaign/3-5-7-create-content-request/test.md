# Test - FR 3.5.7

| Case | Expected result |
|---|---|
| Workspace Client creates | `PENDING` request is returned. |
| Manager/Owner creates | `403`. |
| External Client creates | `403`; no persisted request. |
| Create request | No task is generated yet. |
| Invalid/missing type or due date | Validation error; no request is persisted. |
