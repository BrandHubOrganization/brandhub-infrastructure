# Test - FR 3.5.8

| Case | Expected result |
|---|---|
| Valid Manager transition | State changes as specified. |
| Client transition | `403`. |
| First acceptance | Exactly one backlog task is created with `campaignId=null`. |
| Repeat acceptance | No second task is created. |
| Terminal state reopen | Rejected. |
| Open/read request | No implicit state change. |
| Manager receive / Owner acting as Workspace Manager | PENDING → IN_PROGRESS; reviewer/time saved, Client locked. |
| Direct accept/deny PENDING | Rejected; no generated Task. |
| Accept transaction fails / response lost after commit | No ACCEPTED without Task; retry returns same Task, preserves execution state. |
| Existing request after Campaign complete | Continue legal receive/accept/deny; no automatic cancellation. |
| UI vi/en/light/dark/mobile | “Đang xem xét” distinct from Task execution; actions/task link accessible. |

Concurrency/failure matrix and evidence: [remaining-work/test.md](../remaining-work/test.md),
R07/R11–R19 and phase-3 checkpoint. Unit/MockMvc, real isolated Mongo transaction/race/
rollback tests and browser fixtures executed 2026-10-13; shared Atlas apply/Gateway smoke pending.
