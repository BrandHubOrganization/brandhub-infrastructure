# Technical plan

1. Review/preflight existing `2026-10-12-create-mail-sending-tables.sql`; copy its definitions into PostgreSQL init. Back up local PostgreSQL before applying the exact additive migration, with ON_ERROR_STOP. Validate table/index presence and the worker claim query without sending mail. Verify fresh init separately.
2. Add `/ws/tasks` Gateway route to the configured WebSocket Business upstream; use isolated route/proxy tests, retaining REST JWT and downstream handshake rejection.
3. Retain Axios refresh protocol, repair queued retry marking and validate refresh token envelopes. Editor checks the existing protected identity endpoint before each connection, sharing HTTP refresh handling, then reads the latest access token. Do not change Yjs format or discard pending updates.
4. Add strict envelope extraction to the Content Request service and regression tests; retain existing error UI. Inspect Campaign deployment handling and restrict expected absence to its business code.
5. Bundle Unicode's version-pinned emoji test dataset and licence; parse qualified base sequences, retaining all nine categories. Serve from the web app and wire retry state correctly. Update `src/i18n/locales/vi/editor.json` and `src/i18n/locales/en/editor.json`; preserve theme/layout.
6. Run focused Vitest/Node tests, Gateway JUnit tests, type-check and scoped lint; use an isolated Playwright CLI browser with mocked APIs for UI checks. Do not start Business seeders/workers against shared state.

Risks: cached running binaries need restart; expired/missing refresh cookies still require login; old HTTP 404 cannot be attributed without its original response code. Never log token-bearing WebSocket URLs.
