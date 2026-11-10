# Verification cases

| Case | Expected |
| --- | --- |
| Mail preflight | All five tables absent; parent tables present; backup succeeds before apply |
| Migration apply and rerun | Five tables, five explicit indexes, constraints match migration; no destructive DDL; second run succeeds |
| Worker claim query with empty outbox | Zero rows, no missing relation; no email sent |
| Fresh PostgreSQL init | Succeeds in isolated empty DB; Mail definitions match migrated schema |
| Gateway Task WebSocket | Successful mock handshake and echo forwarded; upstream auth rejection not converted to success; chat still works |
| Concurrent expired HTTP requests | One refresh, each retries once with new token; second 401 rejects, no refresh loop |
| Refresh failure/malformed success | Reject, clear session; no undefined token/data installed |
| Editor reconnect after token rotation | Latest token used; missing/invalid session does not connect; queued edits retained |
| Request service envelope | Valid list/detail accepted, empty list accepted; missing data, success=false, wrong content type/body rejected |
| Deployment status | Only CAMPAIGN_DEPLOYMENT_NOT_FOUND is expected absence; other 404 and 401 remain failures |
| Emoji | All nine groups, search and insertion; no emoji.family request; HTTP failure -> visible error -> retry succeeds |
| UI states | vi/en labels, light/dark tokens, narrow viewport and keyboard controls work |

## Results — 2026-10-14

- PostgreSQL local preflight confirmed all five Mail tables absent. Full custom-format backup saved outside Git at `D:/FPT/FA26/SEP490/.local-backups/mail-schema-20261014/brandhub-before-mail.dump` (433028 bytes).
- Applied the existing Mail migration with `psql -X -v ON_ERROR_STOP=1`; reran successfully. All five tables and five explicit indexes present. Empty outbox worker selection (including locking, in a rolled-back transaction) returned zero rows; zero batches/deliveries, no email sent.
- Fresh init executed successfully in isolated `runtime_mail_init_check_20261014`. Normalised Mail schema dumps from fresh init and migrated local DB matched exactly (8550 characters each, excluding random pg_dump restrict markers).
- Gateway: 18 tests passed, zero failures/errors/skips: TaskWebSocketRouteTest (3), MonitoringRouteTest (4), CorsProxyTest (3), JwtAuthFilterGatewayFilterFactoryTest (8). Actual upstream WebSocket echo works for editor and chat; upstream auth refusal closes the channel without delivering frames. Gateway may upgrade its client socket before the upstream rejects; this test does not claim that the browser sees upstream HTTP 401 verbatim.
- Web: `npm test` passed 97 tests across 9 files. The existing 9 Node deadline tests also passed. Type-check and production build (`npm run build -- --configLoader runner`) passed. Scoped ESLint: zero errors, one pre-existing intentional `useMemo([taskId])` dependency warning in the Y.Doc lifecycle. Production build retains an unrelated pre-existing mixed static/dynamic import warning in mockContentLibraryService.
- Playwright CLI, isolated browser/mock APIs: actual EmojiPicker component passed injected HTTP 503 -> retry -> success, all 9 groups (1914 base sequences), search/insertion/empty results, keyboard category selection, vi/en, 375px no horizontal overflow, light/dark screenshots inspected. Fixed category row shrinking found during visual inspection.
- Playwright CLI, actual useTaskContentSync hook with mocked REST/STOMP: initial content 503 -> retry succeeds; identity 401 triggers exactly one refresh; handshake receives refreshed token; disconnect + token rotation reconnects with the new token; one offline Yjs edit is flushed exactly once.
- Current Campaign `d712722f-eace-46d4-a9a3-d74379496bdd` deployment remained SUCCEEDED; no Campaign data changed. UI now distinguishes explicit missing deployment from route/auth failures and offers retry instead of silently swallowing arbitrary 404.

## Runtime handoff and limits

Pre-push recheck on 2026-10-14: Web 97 Vitest + 9 Node deadline tests passed again; Business timezone/deadline selection 71 tests passed again. Gateway rerun: 18 tests, 16 passed, 2 MonitoringRouteTest failures because local Redis connection was refused at localhost:6379; Docker Desktop's Linux daemon was stopped, confirmed by read-only `docker ps`. The three TaskWebSocketRouteTest cases passed. No Monitoring code or container state was changed. This environment-dependent recheck does not replace the earlier successful 18-test run above.

Restart Gateway for the new `/ws/tasks` route, restart Business to load the separate Workspace timezone fix already in the worktree, restart/reload Web. Log in again if the refresh cookie is no longer valid. Do not rerun init on the existing application DB; Mail migration is already applied locally. Other developers apply `2026-10-12-create-mail-sending-tables.sql` to their existing PostgreSQL DB.

These are unit/integration and browser-mocked checks, not authenticated end-to-end verification against Mongo Atlas or the user's live cookie. The original arbitrary deployment 404 and malformed Request response cannot be conclusively attributed without their original response bodies. Invalid/revoked credentials must still fail. React DevTools suggestions are informational, not an application fault.

No shared Mongo migration/init, seed data, real mail, stash restoration, commit or push performed. Existing timezone edits and other local documentation changes preserved. Browser logs/screenshots/harness files from this run were moved outside Git to `D:/FPT/FA26/SEP490/.local-backups/runtime-recovery-browser-20261014`; older local logs were left untouched. The isolated init test database was verified empty of users/workspaces/mail and removed after comparison. Backup remains available. The test Vite server and isolated browser were stopped.
