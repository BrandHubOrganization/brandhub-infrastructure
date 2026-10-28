# Tests

Self-label/read follow-up: own rows show Bạn/You and others keep stored display
names. Opening thread and reading bottom sends channel read acknowledgement; failed
read must not clear badge. Successful response refreshes channel list and selected
channel. Verify root+reply unread case, StrictMode effect cleanup and two real users.
No database schema changes or manual unread-count data edits.

## Reliability fixes verification — 2026-10-23

Isolated browser, Vite 3107 (normal app port 3000 was stopped): simulated channel
429 suspends composer but recovery returns exact original draft. Mention keyboard
selection does not POST. Linked-message preview loads target by scoped API; 403
revocation hides composer. 375/768/1440 document widths do not overflow; no page JS
exceptions. Expected HTTP 429/403 console entries are injected fixtures, not live
Backend failures. Test output's old `lostDraft` boolean measures temporary textbox
visibility, NOT lost state; `recoveredValue` proves retention.

In-memory transport checks pass: no network request during same-actor cooldown,
writes not replayed, different actor not blocked, cooldown expiry, bounded GET
retry. TypeScript and Chat/sidebar touched-file ESLint passed; Dashboard has two
set-state-in-effect warnings, no lint errors. Gateway CORS config exposes rate
headers and requires restart to take effect. Dashboard role guard and seed-image
fallback source/compile checked; no live Backend test of those changes this turn.
No DB modifications, no new source test files, no commit/push. Missing Dashboard
Analytics/Activity APIs remain unimplemented; this does not certify whole-system
stability or complete load/reconnect/security acceptance testing.

Production Vite build passed outside sandbox (sandbox attempt hit native dependency
spawn EPERM, no dependency reinstall needed). Existing ineffective dynamic-import
warning in Content Library remains. No generated dist files are committed.

Reliability regressions: draft and mention IDs survive 429/retry; send disabled
during failure; 403 hides cached content. Retry-After seconds/date honored for same
actor, not inherited by another account. Writes never auto-replayed. GET retry is
bounded and cancellable. Test with API fixtures; no real spam/load testing.

Live audit 2026-10-23: Manager/Creator quick-login passed after local email overrides
for legacy dataset; shared defaults unchanged. Real QA root mention + thread reply
persisted, one matching SQL inbox notification confirmed. DND/mute persisted then
restored. 19 API responses/27s successful; idle 22s had two polling GETs. 45 Business
and 11 Gateway tests passed, TypeScript and touched-file ESLint passed. Six viewport/
theme combinations: composer visible and no document horizontal overflow.

BLOCKER discovered in browser fixture: selected-channel detail 429 unmounts the
conversation and Retry loses unsent draft. Chat does not honor Retry-After. No
infinite idle request loop was demonstrated. Creator Dashboard campaign GET 403
also reproduced. These are findings, NOT fixes. Whole-system stability not signed
off. Local evidence and exact QA record IDs remain ignored in keep-local-only.

Dev-login: new seed defaults unchanged; old dataset uses local email overrides,
normal password authentication and actual Workspace roles. Never relabel tokens.

Seeder: missing chat metadata fails before any fixture write; members come from
active PostgreSQL rows, two distinct internal users required. Repeat invocation
must not overwrite messages/preferences or duplicate records. Check root ObjectId,
reply/channel/mention references, no pending notification intents or SQL writes.
Completed full-seed marker still skips; do not delete marker to seed existing DB.

Frontend: select mention, edit before/inside/after it, remove mention, retry failed
message with same IDs. Typed names alone must not notify. Navigate suggestions by
keyboard; Escape closes without sending. Preferences load/save errors remain
visible and retryable; switching users/workspaces must not reuse another scope.
Check vi/en, light/dark and 375/768/1440 widths without clipped menu controls.

- Legacy five-argument DTO and omitted mentions stay compatible.
- Valid mentions persist; self mention produces no notification, duplicate IDs
  deduplicate, recipient lacking channel access is rejected before insert.
- Client-ID replay with changed mentions conflicts; replay with same set reuses
  existing message without appending duplicate intents.
- DM notification recipient plus mention produces one recipient; no message text
  in SQL notification content. Ordinary channel message has no recipients.
- Mongo persistence failure emits no event or SQL notification.
- Delivery failure retries with same deterministic inbox UUID; lease updates are
  fenced; revoked recipient suppressed, DB outage is not suppressed as denial.
- DND/mute APIs check active Workspace/channel membership and update only caller;
  mute/unmute doesn't reset DND. Muting doesn't discard inbox.
- Migration never backfills messages. No live publish/push/call/Atlas writes.

## Results — 2026-10-23

Targeted suite: 37 tests, zero failures/errors/skips, including 14 in
ChatChannelMessagesTest (7 new checks). Unit tests cover mention access, DM/mention
deduplication, replay conflict, stable inbox identity, SQL-failure acknowledgement
ordering, revoked recipient versus outage, and mute/DND read semantics.

Mongo 7 isolated container: DRY_RUN nonmutation, repeated APPLY, init/migration
validator parity for all three collaboration/preferences collections, invalid
preference rejection, legacy-message preservation, no backfill and existing
collection-validator repair all passed. Repeated APPLY with index preflight passed.
Scripts are syntax checked. Harness is ignored under keep-local-only.

Initial full test compilation hit disappearing target/classes artifacts; rerun
completed successfully without unrelated source changes. No shared DB, real inbox
or live push/call operation was executed. This does not establish multi-worker
SQL/Mongo crash recovery or frontend integration; those remain acceptance gates.

## Frontend continuation — 2026-10-23

Connected optional mentionUserIds to optimistic messages and retry, added typed-@
suggestions with arrow/Enter/Escape handling and removable recipient chips.
Identity ranges are removed when edited across, and adjusted for preceding edits;
typing a display name alone does not create a recipient. No HTML injection.
Added actor/workspace/channel-scoped DND/mute menu using persisted API values;
disabled loading controls, visible errors, retry and cache invalidation.

TypeScript build check and ESLint for touched chat files passed. Local in-memory
checks passed for range edits before/inside/after a mention, @ trigger versus
email text, and complete vi/en locale key parity. No test files were added.
Port 3000 was not listening: browser keyboard/theme/responsive checks and live
API/notification integration remain unverified. No shared database APPLY.

## Seeder verification — 2026-10-23

MongoDataSeederTest: 8 tests passed with Maven offline, including fixtures with two
real-member identities, 9 insert-only documents (3 channels + 6 messages), repeated
call without extra writes, reply root/channel references, no delivery intent fields,
insufficient-member skip and integration with the existing complete-seed marker.
Compilation passed. Used only mocks: no actual Mongo/PostgreSQL seed or migration
was run. Existing tracked test file was extended; no new test file added.

ChatSampleSeeder runs through the existing seed/seed-mongo fresh-DB workflow, not
normal Business startup. Existing databases with completed seed_runs are not
backfilled; running migrations alone does not insert sample data. Do not clear
seed_runs or existing collections to force seeding. DND/mute/read states are not
seeded or overwritten. The bounded lookup examines at most 100 active Workspace
members and selects two distinct Manager/Creator users; Clients are not auto-invited.
