# Tasks

- [ ] Schema migration, init parity, Java model, isolated validation checks.
- [ ] Lifecycle API, busy handling, CAS, lease expiry and inbox.
- [ ] Authorized STOMP signaling and integration regressions.
- [ ] Accessible Agora audio UI, vi/en, light/dark, cleanup.
- [ ] Agora token configuration and real two-network tests.
- [ ] Server-issued token bound to call/participant, only after acceptance.
- [ ] Security and concurrency acceptance gates before release.

Implementation progress (2026-10-23): lifecycle REST, generic authenticated user-
queue invalidations, per-participant leases, Agora media UI and lazy SDK are added.
Token and lifecycle security tests plus isolated Mongo schema tests are run; see
test.md. Checkboxes remain open where end-to-end/provider or inbox gates remain.
- [x] Add parallel vi/en chat.calls.* strings.
- [x] Verify incoming UI at 375/768/1440 in light and dark (mocked API).
- [ ] Durable missed-call inbox and alerts respecting DND/mute.
- [ ] Invitations when outside Chat and real two-device media acceptance.
