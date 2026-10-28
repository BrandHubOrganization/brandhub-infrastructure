# Tasks

- [x] Localize self-sender as Bạn/You; wire thread read acknowledgements.
- [ ] Verify unread badge with real incoming root/reply and two browser accounts.

- [x] Preserve drafts and suspend writes for transient errors.
- [x] Account-scoped Chat cooldown and bounded read retry.
- [x] Browser regression: 429, 403, retry and draft identity.
- [x] Add linked-message preview, bounded read acknowledgement retries and Dashboard role guard.
- [x] Expose Gateway rate-limit headers; prevent seed image scheme requests in hover preview.

- [x] Verify quick-login overrides against PostgreSQL and real auth flow (Manager/Creator).

- [x] Add mention identity and sender/recipient validation.
- [x] Persist notification intents atomically with new messages.
- [x] Add lease worker and idempotent SQL inbox delivery.
- [x] Add actor-scoped DND/mute API and preferences storage.
- [x] Match migration and fresh init; syntax and isolated smoke checks.
- [x] Run regressions, report live integration limitations.

- [x] Connect composer mentions and retry identities.
- [x] Connect DND/mute controls, loading/error/retry states.
- [x] Update vi/en locales and verify TypeScript/lint.
- [ ] Verify keyboard, light/dark and responsive UI in browser.

No real-user inbox delivery or end-to-end Mongo/PostgreSQL worker test was run.

- [x] Add ChatSampleSeeder and wire fresh Mongo seed.
- [x] Guard chat metadata before seeding and preserve existing samples.
- [x] Compile and verify fixtures without shared DB writes.
