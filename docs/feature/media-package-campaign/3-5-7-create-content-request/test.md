# Test - FR 3.5.7

| Case | Expected result |
|---|---|
| Workspace Client creates | `PENDING` request is returned. |
| Manager/Owner creates | `403`. |
| External Client creates | `403`; no persisted request. |
| Create request | No task is generated yet. |
| Invalid/missing type or due date | Validation error; no request is persisted. |
| Campaign not deployed/partial/failed or only APPROVED | Reject create, no request/task. |
| Campaign COMPLETED | Reject new request; pre-existing requests keep their lifecycle. |
| Create vs Campaign complete | Server-side locking/version consistently enforces creation gate. |
| Workspace UI vi/en/light/dark/mobile | Real API, parallel keys, accessible states, unrelated pages unchanged. |

Full matrix/migration gates: [remaining-work/test.md](../remaining-work/test.md), R01–R06/R20–R26. Planned cases, not evidence of execution.
