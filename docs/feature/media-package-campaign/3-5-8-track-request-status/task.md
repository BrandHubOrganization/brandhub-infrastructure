# Tasks - FR 3.5.8

- [x] Implement Manager-only transition validator and version guard.
- [x] Add transactional acceptance claim/idempotency control.
- [x] Add task source reference/idempotency migration (Atlas apply pending).
- [x] Generate one generic BACKLOG task with `campaignId=null`, selected type/date/brief and confirmed defaults.
- [x] Request list/detail read paths and scoped generated Task summary.
- [x] Test states, roles and repeated acceptance with unit/MockMvc and isolated Mongo integration.
- [x] Explicit receive and reviewer/time; no implicit view transition or direct accept/deny from PENDING.
- [x] Read-only Atlas topology verification + real local transaction rollback/concurrency tests.
- [x] Task source unique index via NEW migration + init; old merged scripts retained.
- [x] Existing requests do not consult Campaign status on review; effective MANAGER supported.
- [x] Update vi/en receive/status/task-link keys; UI fixture validation, mobile and semantic theme.
- [ ] Apply reviewed migrations on Atlas and smoke through Gateway with existing test accounts; no shared writes yet.
