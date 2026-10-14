# Test - FR 3.5.10

| Case | Expected result |
|---|---|
| Creator cancels pending request | Status becomes terminal `CANCELLED` and is retained for audit. |
| Other Client cancels | `403`. |
| Non-pending request | `409 REQUEST_NOT_CANCELLABLE`. |
| Cancellation | No task is created or changed. |
| Cancel races with Manager receive | One conditional write succeeds; no invalid transition. |
| Existing PENDING after Campaign complete | Creator still may cancel. |
| Cancelled history read | Retained terminal record with actor/time; no reopen action. |
| UI vi/en/light/dark/mobile/keyboard | Clear soft-cancel confirmation and focus/pending/error states. |
