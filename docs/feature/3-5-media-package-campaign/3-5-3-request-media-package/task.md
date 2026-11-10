# Tasks - FR 3.5.3

- [x] Add `terms_version` and append-only negotiation-event migration plus V2 init schema update.
- [x] Implement existing negotiate path for request-change/counter-offer and scoped history read path.
- [x] Enforce current selection, membership, and non-approved state.
- [x] Test immutable history, concurrent proposals and replacement blocking.

## Phase 5

- [x] Add immutable history migration/init with honest legacy baseline.
- [x] Atomic event writer + scoped paginated history API.
- [x] Required version for propose/approve; stale requests leave all state unchanged.
- [x] UI history/read-only diff + captured edit version/note.
- [x] Parallel vi/en keys and light/dark/mobile/form focus/error states; not a full accessibility audit.
- [x] Unit/HTTP/PostgreSQL migration/transaction/race regression, browser fixture.
- [x] Setup guide: ordered PostgreSQL/Mongo migrations, readiness checks, restart and test flows.
- [ ] Live Gateway/account acceptance after operator setup (not inferred from mocks).
