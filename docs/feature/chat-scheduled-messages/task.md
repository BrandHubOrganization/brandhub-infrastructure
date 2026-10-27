# Tasks

- [x] Add additive Mongo schema/migration/init and cancelled-only optional seeder.
- [x] Implement scheduling validation, own-user APIs, paging and revision CAS.
- [x] Implement leased transactional delivery, retry/recovery and commit-only events.
- [x] Revalidate suspended/deactivated/deleted accounts in background delivery.
- [x] Recover pending realtime broadcasts after unknown commit/broker failure.
- [x] Integrate split Send in channel/DM/thread rich composers with draft protection.
- [x] Keep drafts when an idempotent retry returns a failed/cancelled intent.
- [x] Add private schedule queue, reschedule/cancel and errors in Workspace panels.
- [x] Update vi/chat.json + en/chat.json with matching keys.
- [x] Verify keyboard, responsive layouts and light/dark mode.
- [x] Verify schema parity/idempotency and worker races on disposable Mongo.
- [x] Run Business compile/chat regressions and Web build/targeted lint.
- [x] Document verification results and exact shared-DB rollout steps.
- [x] Add channel-scoped upcoming projection with ownership/access enforcement.
- [x] Show compact notice above composer and open the existing private queue.
- [x] Update vi/en notice keys and verify light/dark, mobile and keyboard behavior.
- [x] Verify notice refresh, filtering, empty/error state and pagination independence.

Implementation and isolated verification complete on 27 October 2026. Shared
Atlas deployment and production smoke testing remain operator rollout steps;
neither migration nor seed was run against shared data during development.
