# Test - FR 3.5.10

| Case | Expected result |
|---|---|
| Creator cancels pending request | Status becomes terminal `CANCELLED` and is retained for audit. |
| Other Client cancels | `403`. |
| Non-pending request | `409 REQUEST_NOT_CANCELLABLE`. |
| Cancellation | No task is created or changed. |
