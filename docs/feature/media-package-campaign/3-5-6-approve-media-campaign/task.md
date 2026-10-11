# Tasks - FR 3.5.6

- [x] Integrate Task lookup/create and editor REST/WebSocket with Mongo Task identity in code.
- [ ] Verify Content Writing against Atlas after Task schema migration; preflight/backfill required in nonlocal environments.
- [x] Phase 1: expanded Task types and complete-with-reason conditions confirmed.
- [ ] Coordinate specialist schema/ownership and verify existing launch conditions before implementation.
- [x] Implement Client feedback and Manager editing with version snapshots.
- [x] Implement explicit Manager complete action (Stage 4).

- [x] Implement two-party campaign approval with version guard.
- [x] Add deterministic Task identity and partial unique index migration for Campaign work items.
- [x] Implement durable retry-safe deploy workflow and campaign status update.
- [x] Unit-test existing Task preservation, storage failure and idempotent identity.
- [ ] Confirm Atlas migration results and smoke-test deploy/retry; migration/check instructions supplied to the user.
- [ ] Test actual partial Mongo failure/restart with Task already edited by Creator.
- [x] Add versioned approval UI and notifications to the opposite side.
- [x] Add matching vi/en locale keys; build verified. Visual light/dark/mobile review remains.
- [ ] Regression-test existing Media Package and Content Writing flows.

2026-10-10: full Business Service suite passed (416 passed/31 skipped, 0 failure/error).
Web lint/type-check/build passed. Mocked Package/Campaign browser tests were run;
the utility `/media-package` redirect still fails and Content Writing/Atlas live
integration remains unverified. See [roadmap](../implementation-roadmap.md).
