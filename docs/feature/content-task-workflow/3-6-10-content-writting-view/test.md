# Test Specification — FR 3.6.10: Content Writing View

> Note: This specification maps to official **FR 3.6.10 — Content Writing View** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-6-10-content-writing-view/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.10` |
| **Function Name** | Content Writing View |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `TaskContentServiceImpl.restoreVersion()` (48 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/TaskContentServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Save rich social post drafts with Unicode font styling, track version history, and restore previous content versions |
| **Preconditions** | Can connect with server; Caller is Creator or Manager in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 6, `Boundary (B)`: 3, `Abnormal (A)`: 8 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is CREATOR of workspace; Task type is POST; Snapshot exists for task, 5 operations logged | `workspaceId` = `valid`, `taskId` = `valid`, `snapshotId` = `valid snapshot` | 200 OK - TaskContentResponse(snapshot=old state, ops=[], sequenceNumber=6) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is CREATOR of workspace; Task type is POST; Snapshot exists for task, 120 operations logged | `snapshotId` = `valid snapshot` | 200 OK - new snapshot sequenceNumber=121 | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Task type is POST; Snapshot exists for task, 5 operations logged; User is MANAGER of workspace | `snapshotId` = `valid snapshot` | 200 OK - restored state returned | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is CREATOR of workspace; Task type is POST; Task has 2 snapshots | `snapshotId` = `oldest snapshot` | 200 OK - old yjsState restored, new snapshot appended | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is CREATOR of workspace; Task type is POST; Task has 2 snapshots | `snapshotId` = `latest snapshot` | 200 OK - same state re-appended as new snapshot | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is CREATOR of workspace; Task type is POST; Snapshot exists for task, 5 operations logged | `snapshotId` = `valid snapshot`, `note` = `restore twice` | 200 OK - two new snapshots, history preserved | — | **Passed** |
| `UTCID07` | `B` | Can connect with server; User is CREATOR of workspace; Task type is POST; Snapshot exists for task, no operations logged | `snapshotId` = `valid snapshot` | 200 OK - sequenceNumber=1 | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; User is CREATOR of workspace; Task type is POST; Snapshot exists for task, 1 operation logged | `snapshotId` = `valid snapshot` | 200 OK - sequenceNumber=2 | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is CREATOR of workspace; Task type is POST; Snapshot at sequenceNumber 1 | `snapshotId` = `first snapshot` | 200 OK - restored | — | **Passed** |
| `UTCID10` | `A` | Can connect with server; User is CREATOR of workspace; Task type is POST | `snapshotId` = `non-existing id` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; User is CREATOR of workspace; Task type is POST; Snapshot belongs to another task | `snapshotId` = `foreign snapshot` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is CREATOR of workspace; Task type is POST | `snapshotId` = `null` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is CREATOR of workspace; Task does not exist | `taskId` = `non-existing task`, `snapshotId` = `valid snapshot` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is CREATOR of workspace; Task belongs to another workspace | `workspaceId` = `other workspace`, `snapshotId` = `valid snapshot` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is CREATOR of workspace; Task type is SURVEY | `snapshotId` = `valid snapshot` | 400 INVALID_TASK_TYPE_FOR_CONTENT_WRITING - Content writing only applies to Post tasks | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is CREATOR of workspace; Task type is SURVEY | `snapshotId` = `valid snapshot` | 400 INVALID_TASK_TYPE_FOR_CONTENT_WRITING - Content writing only applies to Post tasks | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is CREATOR of workspace; Task type is POST; Task has no snapshots | `snapshotId` = `any id` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.10`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — Content Writing View (FR 3.6.10)

> Status: **Implemented & executed (2026-10-12; redesign + presence + mobile port added 2026-10-26).** All passing: 47+32 frontend unit + 22 backend service unit + 22 browser E2E + 31 live-backend integration (re-run 31/31 on the merged develop code) + 22 mobile unit. The live run (before merging the team's develop) found three defects the mocked tests could not see (§7 #4–#6); #4/#5 were meanwhile fixed upstream in `ChatInboundChannelInterceptor` and #6 was re-applied on top of develop. Items that could **not** be executed or are out of scope are listed explicitly in §6. See [spec.md](spec.md), [task.md](task.md).
>
> **2026-10-26 addition**: web UI redesigned to a Docs/Word hybrid chrome (page-card canvas + toolbar, Docs/Ribbon toggle — purely visual, zero logic changes, all pre-existing tests kept passing unmodified except the broker-mock fix noted below); presence/multi-cursor awareness added (`y-protocols/awareness` over a new unpersisted `/app+/topic/tasks/{taskId}/awareness` STOMP channel); 32 new Vitest unit tests for previously-untested pure-logic files (`richText.ts`, `listUtils.ts`, `contentUtils.ts`); 2 new E2E tests for presence (E2E-21, E2E-22); and a parallel **mobile port** (React Native, `brandhub-mobile-app/src/screens/content-writing/`) covering the same feature set via a TextInput-based editor instead of canvas — see §5 below.

## 1. Summary

| Layer | Tool | Location | Cases | Result |
|---|---|---|---|---|
| FE pure logic (list, diff, publish text, restore, CRDT) | Vitest | `brandhub-web/src/pages/content-writing/**/*.test.ts` | 47 + 32 new (2026-10-26) | ✅ 79 / 79 |
| BE service logic (load, op log, snapshot, versions, restore) | JUnit 5 + Mockito | `brandhub-business-service/src/test/java/.../service/impl/TaskContentServiceImplTest.java` | 22 | ✅ 22 / 22 |
| Browser E2E (real canvas editor, mocked REST + in-test STOMP broker) | Playwright | `brandhub-web/tests/e2e/editor/content-writing.spec.ts` | 20 + 2 new presence (E2E-21/22) | ✅ 22 / 22 |
| **Live backend integration** (real Spring Boot + Postgres + JWT + STOMP; two WS clients with real Yjs) | Node script | [integration-test.cjs](integration-test.cjs) | 31 | ✅ 31 / 31 |
| **Mobile unit (new, 2026-10-26)** | Jest (jest-expo) | `brandhub-mobile-app/src/screens/content-writing/__tests__/*.test.ts` | 22 | ✅ 22 / 22 |
| **Mobile component (new, 2026-10-26)** | Jest + `@testing-library/react-native` | `brandhub-mobile-app/src/screens/content-writing/__tests__/*.test.tsx` | 24 | ✅ 24 / 24 |
| **Mobile device flows (new, 2026-10-26)** | Maestro (YAML) | `brandhub-mobile-app/.maestro/content-writing/*.yaml` | 7 flows | ⚠️ written, not executed — see §9 |

> E2E note: running the full suite with Playwright's default `fullyParallel` workers against one shared `npm run dev` dev server causes spurious failures (page stuck on the app's lazy-load Suspense fallback) unrelated to this feature — confirmed by re-running with `--workers=1`, where all 22 pass, and by running each failing test in isolation. Always use `--workers=1` for this spec, or point `BASE_URL` at a dedicated dev server per worker.

## 2. How to run

```bash
# Frontend unit tests
cd brandhub-web-dashboard && npm test                 # vitest run (src/**/*.test.ts only)

# Backend unit tests
cd brandhub-business-service && mvn test -Dtest=TaskContentServiceImplTest

# Browser E2E (starts `npm run dev` itself)
cd brandhub-web-dashboard && npx playwright test tests/e2e/editor/content-writing.spec.ts
```

```bash
# Live backend integration (needs Postgres + Redis up; see "Live integration setup")
WS_ID=<workspace uuid> node integration-test.cjs
```

Live integration setup (used for the 2026-10-12 run): start `brandhub-postgres` + `brandhub-redis`; create a scratch DB cloned with `pg_dump -s brandhub | psql brandhub_e2e`; run business-service with `POSTGRES_URL=jdbc:postgresql://localhost:5432/brandhub_e2e`, `SPRING_JPA_HIBERNATE_DDL_AUTO=update`, `MONGODB_URI=mongodb://localhost:27017` and the JWT/Redis vars from `docker/.env`; register `e2e_a/b/c@test.local` (password `Passw0rdx1`) via `/api/v1/auth/register`, activate them in SQL (`status='ACTIVE', email_verified_at=now()`), and seed one agency + workspace with `e2e_a` as MANAGER, `e2e_b` as CREATOR and `e2e_c` as non-member. Since Tasks moved to MongoDB (develop, 2026-10): create the `uq_tasks_campaign_work_item` index on the scratch Mongo `tasks` collection (as in `2026-10-09-campaign-task-deployment.js`, otherwise `TASK_SCHEMA_NOT_READY`) and apply the FK drops from `2026-10-09-campaign-deployment.sql` to `task_content_*` (otherwise inserts fail on the old FK to Postgres `tasks`). Re-run on the merged develop code: 31/31. The script covers: REST load/RBAC (IT-01..06), WS handshake (IT-07..08), two live clients and 120-update concurrent burst (IT-09..16), snapshots/versions/who (IT-17..24), read-only restore + live propagation (IT-25..28), non-member over WS (IT-29..30), payload validation (IT-31).

Notes:
- First E2E run on a machine needs `npx playwright install chromium` (the installed `@playwright/test` pins a specific Chromium build).
- If Maven reports `Unresolved compilation problems ... source level 25`, `target/` holds classes compiled by the IDE (ECJ); run `mvn clean test`.
- E2E does **not** need the backend: REST is mocked with `page.route`, and the STOMP socket is a small in-test broker (`page.routeWebSocket`) that echoes each `SEND` as a `MESSAGE` with an increasing `sequenceNumber`, mirroring `TaskContentWebSocketController`.

## 3. Frontend unit tests (Vitest)

### 3.1 Lists — `listUtils.test.ts`

| ID | Scenario | Expected |
|---|---|---|
| TC-LIST-01 | Bullet on the paragraph under the caret | `alpha` → `• alpha` |
| TC-LIST-02 | Ordered list over 3 selected paragraphs | numbered `1.` `2.` `3.` |
| TC-LIST-03 | Selection spans only middle paragraphs | only those paragraphs get the marker |
| TC-LIST-04 | Toggle the same kind when all paragraphs already have it | markers removed |
| TC-LIST-05 | Mixed (some already bullets) | all become bullets, no double prefix |
| TC-LIST-06 | Bullet ⇄ ordered | marker replaced, never stacked |
| TC-LIST-07 | Empty document | creates an empty first item (`• ` / `1. `) |
| TC-LIST-08 | Empty paragraph between two others | empty paragraph also gets a marker |
| TC-LIST-09 | Text like `10.5 km` / `2024` | not mistaken for an existing marker |
| TC-LIST-10 | Caret after toggle | end of last affected paragraph |
| TC-LIST-11 | Reversed selection (focus before anchor) | same result as forward selection |
| TC-LIST-12 | Enter at end of a bullet item | continues with `• ` |
| TC-LIST-13 | Enter in ordered item | increments (`2.`→`3.`, `9.`→`10.`) |
| TC-LIST-14 | Enter on an empty item | exits the list (marker removed, no newline) |
| TC-LIST-15 | Enter outside any list / empty doc | plain `\n` |
| TC-LIST-16 | Enter with caret inside the marker | plain `\n` |
| TC-LIST-17 | Enter in the middle of an item | marker carried to the new line |

### 3.2 Utilities — `contentUtils.test.ts`

| ID | Scenario | Expected |
|---|---|---|
| TC-UTIL-01..03 | `yjsStateToText`: null, plain text, formatted text | `""`, text, text (attributes ignored) |
| TC-DIFF-01 | identical text | single `same` part |
| TC-DIFF-02 | first version (empty before) | all `add` |
| TC-DIFF-03 | everything removed | all `del` |
| TC-DIFF-04 | replaced words | `del` + `add` around unchanged context |
| TC-DIFF-05 | rebuild old/new from parts | lossless (old = same+del, new = same+add) |
| TC-DIFF-06 | both empty | no parts |
| TC-DIFF-07 | input above the size cap | whole `del` + whole `add` (no freeze) |
| TC-FONT-01 | plain text | unchanged |
| TC-FONT-02 | decomposed Vietnamese (`e`+`◌̣`+`◌̂`) | NFC-normalized (`ệ`) |
| TC-FONT-03 | bold `Az09` | Mathematical Sans-Serif Bold letters/digits |
| TC-FONT-04 | italic `Az1` | Sans-Serif Italic letters; digits stay plain |
| TC-FONT-05 | bold + italic | Bold-Italic set |
| TC-FONT-06 | bold `ệ` | styled base `e` + combining marks kept |
| TC-FONT-07 | bold `đ! 😀` | `đ`, punctuation, emoji unchanged |
| TC-FONT-08 | mixed runs | concatenated in order, plain runs untouched |
| TC-FONT-09 | underline/color-only run, non-text embed | plain / skipped |
| TC-FONT-10 | list prefixes | pass through as literal text |
| TC-FONT-11 | empty delta | `""` |
| TC-RESTORE-01 | restore replaces current text | old text |
| TC-RESTORE-02 | restored formatting | attributes preserved |
| TC-RESTORE-03 | null snapshot | no-op |
| TC-RESTORE-04 | empty snapshot | document cleared |
| TC-RESTORE-05 | restore on client A | client B converges to restored text (restore is a normal update) |
| TC-RESTORE-06 | edit by B right after restore | kept, both converge |
| TC-SYNC-01 | two clients insert at the same index | identical text on both, both edits present |
| TC-SYNC-02 | replay snapshot + operation tail | same delta (incl. formatting) |
| TC-SYNC-03 | same update applied twice (echoed broadcast) | idempotent |

## 4. Backend unit tests (JUnit 5 + Mockito) — `TaskContentServiceImplTest`

| Test | Verifies |
|---|---|
| `getContent_withoutSnapshot_returnsAllOperationsFromZero` | no snapshot → all ops, `sequenceNumber` = last op |
| `getContent_withSnapshot_returnsOnlyTailAfterSnapshot` | tail starts after snapshot sequence |
| `getContent_snapshotWithEmptyTail_reportsSnapshotSequence` | sequence = snapshot's |
| `getContent_taskInOtherWorkspace_isNotFound` | cross-workspace access → `TASK_NOT_FOUND` |
| `getContent_nonPostTask_isRejected` | non-POST → `INVALID_TASK_TYPE_FOR_CONTENT_WRITING` |
| `appendOperation_assignsNextSequenceAndRecordsEditor` | `count+1`, stores update + `editedBy` + `taskId` |
| `appendOperation_concurrentWritersNeverGetTheSameSequence` | 8 threads × 25 appends against a log that throws on duplicate sequence → 200 unique sequences, no error (guards the per-task lock) |
| `reportSnapshot_savesWhenNoneExists` | first snapshot persisted |
| `reportSnapshot_skipsWhenLatestIsAtOrBeyondReportedSequence` | equal/behind → ignored (first reporter wins) |
| `reportSnapshot_savesWhenReportedSequenceIsNewer` | newer → saved |
| `reportSnapshot_wrongWorkspace_isNotFoundAndNothingSaved` | no write on foreign workspace |
| `listVersions_includesLastEditorUpToSnapshotSequence` | `editedBy` / `editedByName` resolved |
| `listVersions_noOperationFound_leavesEditorNull` | both null |
| `listVersions_editorUserDeleted_keepsIdButNoName` | id kept, name null |
| `listVersions_operationWithoutEditor_doesNotQueryUsers` | no needless user lookup |
| `listVersions_noSnapshots_returnsEmptyList` | `[]` |
| `getVersion_returnsStoredStateWithItsSequence` | state + sequence, empty tail |
| `getVersion_snapshotBelongsToAnotherTask_isNotFound` | cross-task snapshot → `TASK_NOT_FOUND` |
| `getVersion_unknownSnapshot_isNotFound` | unknown id → `TASK_NOT_FOUND` |
| `restoreVersion_isReadOnly_returnsOldStateAndWritesNothing` | returns old state; no snapshot/op saved |
| `restoreVersion_doesNotShiftNextOperationSequence` | regression: next op still `count+1`, no colliding snapshot |
| `restoreVersion_snapshotOfAnotherTask_isNotFound` | cross-task protection |

## 5. Browser E2E (Playwright) — `content-writing.spec.ts`

| ID | Scenario | Expected |
|---|---|---|
| E2E-01 | open page | editor + canvas visible, status "Live" (STOMP connected) |
| E2E-02 | type `Hello BrandHub` | text in editor & preview; Yjs updates sent over STOMP; replaying them rebuilds the text |
| E2E-03 | load with existing snapshot | content restored |
| E2E-04 | Vietnamese IME via CDP (`imeSetComposition` → `insertText`) | preview shown mid-composition but document/publish text empty until commit; **no "Maximum update depth" render loop** |
| E2E-05 | `Ctrl+A`, `Ctrl+B` | mirror stays plain; preview shows Unicode bold |
| E2E-06 | `Ctrl+A`, Backspace | document cleared |
| E2E-07 | undo / redo | text removed then restored |
| E2E-08 | bullet button twice | `• buy milk` then back to `buy milk` |
| E2E-09 | select all + numbered button | `1. one / 2. two / 3. three` |
| E2E-10 | bullet, Enter, type, Enter, Enter | list continues, then exits on empty item; focus stays in editor |
| E2E-11 | versions with/without editor name | name shown / "Unknown" |
| E2E-12 | "Changes" | struck words red, new words green; "Hide" collapses |
| E2E-13 | first version "Changes" | all additions |
| E2E-14 | "Restore" | live content replaced; restore sent as a Yjs update; replaying it on the old state gives restored text |
| E2E-15 | no versions | placeholder |
| E2E-16 | type, wait 21 s (fake clock) | exactly one `POST .../content/snapshot` with the typed text |
| E2E-17 | bold text → "Sao chép bản đăng" | clipboard holds converted text |
| E2E-18 | empty document | copy button disabled |
| E2E-19 | socket dropped, edit typed offline, then reconnect | edit queued + persisted in localStorage, sent after reconnect, queue cleared; update missed while offline is pulled from REST and merged |
| E2E-20 | accessibility attributes | hidden input has `role=textbox` + `aria-multiline`; canvas is `aria-hidden` |
| E2E-21 *(new, 2026-10-26)* | fake peer's awareness update arrives | their cursor flag renders with their name and color, `getByTitle(name)` visible |
| E2E-22 *(new, 2026-10-26)* | this Creator types (publishes their own awareness state) | their own avatar never renders as a "peer of itself" — even though the mock broker echoes every SEND back to the sender, matching a real multi-subscriber topic |

> Not covered by E2E-21: the 30s auto-expiry of a silent peer's cursor (y-protocols' own `outdatedTimeout`). `lib0`'s `getUnixTime` captures a direct `Date.now` reference at module load, which Playwright's `page.clock` fake-timer patch (applied after that module already loaded) cannot retroactively intercept — a library/clock-mocking limitation, not an app-code gap. The removal behavior itself is a well-established y-protocols guarantee, not something this feature's code implements.

## 6. Not executed / known gaps

| Item | Status | Why / next step |
|---|---|---|
| Real backend integration (Postgres unique constraint, handshake, `@RequireRole`, STOMP controller, new `GET .../versions/{id}`) | ✅ **Run 2026-10-12** | `integration-test.cjs`, 31/31, against a real business-service + Postgres scratch DB. Mongo was pointed at the local instance; api-gateway, ai/publisher services and RabbitMQ were not started. |
| Two live clients | ✅ **Run** (headless WS clients, real Yjs) | IT-09..16, 28. Two real *browser tabs* against the live backend were not run; the browser path is covered by the mock-broker E2E. |
| Full browser → gateway → backend run | **Not run** | Gateway not started; the frontend's real `useTaskContentSync` against the live backend was not exercised (the Node client mirrors it). |
| Pre-existing failures elsewhere in business-service | Out of scope | Startup logs show unrelated missing tables (`admin_notifications`, `admin_email_outbox`, `admin_report_exports`) in the cloned schema; `/actuator/health` reports DOWN. Not touched. |
| Screen reader | Partial | Only that the hidden `aria-live` mirror tracks the document (E2E-02..10); no real AT run. |
| Offline resilience | ✅ E2E-19 | In-memory + localStorage queue and REST resync on reconnect. Not covered: a real network outage against a live backend, token refresh during a long outage. |
| Virtualization | Out of scope | Not implemented (see [task.md](task.md) #8). |
| Mutation check of the per-task lock | ✅ Effectively done | The live burst (IT-13) failed with the old lock-inside-`@Transactional` code (228 duplicate-key errors) and passes after the fix. The Mockito concurrency test could **not** catch this because mocks have no transactions. |
| Rendering of styled Unicode on target platforms | Manual | Facebook/TikTok/Zalo rendering of Vietnamese styled letters varies by font; verify manually before relying on it. |
| Wrapped-line hanging indent / mid-list renumbering | Known limitation | Lists are literal text prefixes (see spec.md). |

## 7. Defects found and fixed while testing

| # | Defect | Found by | Fix |
|---|---|---|---|
| 1 | After clicking a toolbar button, focus left the hidden input so the next keystrokes were lost (list items couldn't be typed right after pressing the button) | E2E-10 | `toggleList` returns focus to the hidden input |
| 2 | During IME composition the editor re-rendered in a loop (`Maximum update depth exceeded`): `displayRuns` was a new array every render, so `render` changed identity and its effect called `setCaretPos({...})` each time | E2E-04 | `displayRuns` memoized; `setCaretPos` bails out when the position is unchanged |
| 3 | Restore: live document not updated, and snapshot sequence collided with the next operation (edit lost on reload) | review + TC-RESTORE-*, `restoreVersion_*` | restore is read-only on the server and applied client-side as a normal edit |
| 4 | **Task content WebSocket was completely unusable**: the chat feature's global `ChatInboundChannelInterceptor` demanded an `Authorization` STOMP header on CONNECT (the editor authenticates via `?token=`) and only allowed chat destinations, so every CONNECT got `ERROR: Authentication required` | live integration (IT-09) | fixed independently upstream in develop: `ChatInboundChannelInterceptor` accepts the handshake-authenticated session and `authorizeTask` handles `/app|/topic/tasks/{id}/content` (my duplicate `TaskContentChannelInterceptor` was dropped on merge) |
| 5 | **Authorization hole**: `appendOperation` and the topic subscription checked no membership, so any logged-in user could subscribe to / write into any task's content log (the code comment "validated by the handshake" was false: the handshake only checks the JWT) | review while fixing #4, IT-29/30 | upstream `authorizeTask` requires an existing POST task and an active OWNER/MANAGER/CREATOR member of its workspace for SEND and SUBSCRIBE; `appendOperation` also checks editor access |
| 6 | **Lost updates under concurrency** (the earlier "per-task lock" fix was incomplete): `synchronized` lived inside `@Transactional`, so the lock was released before commit; a burst of 120 updates persisted only ~63, 228 `duplicate key` errors | live integration (IT-13) | removed `@Transactional` from `appendOperation` so each statement commits inside the lock (re-applied on top of develop, which still had the bug). Single-JVM only, as before |

Test-authoring mistakes (wrong expected code points, an over-narrow glob for the restore route) were corrected in the tests themselves; they were not product defects.

## 8. Mobile unit tests (Jest, `jest-expo`) — new, 2026-10-26

Mirrors §3's web pure-logic tests exactly (same assertions, ported file-for-file) against the mobile port's own copies of the logic (`brandhub-mobile-app/src/screens/content-writing/{listUtils,base64,contentUtils}.ts`) — there is no shared package between the two apps, so these files are duplicated by design, same as the rest of the mobile codebase's relationship to web.

| File | Cases | Result |
|---|---|---|
| `listUtils.test.ts` | 8 | ✅ |
| `base64.test.ts` | 4 | ✅ |
| `contentUtils.test.ts` | 10 | ✅ |

```bash
cd brandhub-mobile-app && npm test -- src/screens/content-writing   # jest, all 3 files
cd brandhub-mobile-app && npm test                                   # full suite — confirms no regression: 11 suites / 53 tests, all passing
```

**Environment fix needed to get yjs running under Jest** (not a product bug, but required infrastructure — documented here since it will resurface for anyone adding more `yjs`-dependent tests to this app): `yjs`'s `lib0` dependency resolves to its React-Native-specific `webcrypto.react-native.cjs` entry under `jest-expo`'s RN-style module resolution. That file requires `isomorphic-webcrypto`, whose own "no native crypto found" fallback (`msrcrypto`) tries to gather entropy via `XMLHttpRequest` — undefined in Jest's plain Node test environment (a real device build never hits this path; Expo provides `global.crypto` there). Fixed with:
- `react-native-get-random-values` imported in `jest.setup.ts` (also the correct real-device polyfill, not test-only).
- A `moduleNameMapper` entry in `package.json`'s `jest` config routing `isomorphic-webcrypto` to a 10-line local shim (`jest.webcrypto-shim.js`) that hands `lib0` Node's native `crypto.webcrypto` instead, with a no-op `ensureSecure()` (the one method Node's implementation lacks that `lib0` calls).

Verification for the mobile port as of the §15/16 closeout: TypeScript compiles clean project-wide, the 22 unit tests above pass, and the full existing 53-test mobile suite had zero regressions. Component tests and device flows were added in a follow-up pass — see §9.

## 9. Mobile component tests + Maestro device flows (new, 2026-10-26)

24 `@testing-library/react-native` component tests across 4 files:

| File | Cases | What it covers |
|---|---|---|
| `FormattingToolbar.test.tsx` | 9 | Every toolbar callback fires with the right argument (bold/italic/underline/strikethrough toggle, align, list kind, undo/redo, clear formatting), the color/link modals open and apply, Docs/Ribbon mode switch doesn't crash |
| `SocialPreview.test.tsx` | 6 | Placeholder vs. typed text, author name default, X/Twitter tab + character counter + over-limit flag, attached image renders |
| `VersionHistory.test.tsx` | 3 | Empty state, editor name / "Unknown" fallback, restore calls `onRestored` with the server's returned snapshot (REST mocked via `jest.mock("../../../services/api")`) |
| `RichTextEditor.test.tsx` | 6 | Typing inserts into a **real** `Y.Doc` (not mocked — exercises the actual CRDT wiring), toolbar bold formats the next typed char, bullet list prefixes the paragraph, undo reverts, `onTextChange` fires, peer avatar renders |

**Defect found and fixed while writing these (test infrastructure, not app code)**: `fireEvent.press` in this project's RTL version (14.1.0) combined with React 19 must be wrapped in `await act(async () => ...)`. Without it, the state update from a `press()` in one test leaks past that test's boundary — the *next* `render()` call in the same file silently fails to mount (`toJSON()` returns `null`), which then surfaced as a confusing "Unable to find an element with accessibility label: X" on a completely unrelated query two tests later, with nothing in the error pointing at the real cause. Diagnosed by: (1) confirming each failing test passed when run alone (`-t "name"`), ruling out the test logic itself; (2) a binary-search probe — rendering `Modal` alone four times in a row (fine), then `Select` alone three times (fine), ruling those components out; (3) reproducing the exact 3-test failing sequence from the real file in an isolated throwaway test, which revealed `toJSON()` returning `null` on the broken render; (4) wrapping the presses in `act()` in that isolated repro fixed it, then applied the same fix to the real suite. All four test files above use this pattern (`async function press(el) { await act(async () => { fireEvent.press(el); }); }`), and `VersionHistory.test.tsx`'s async `api.post` flow additionally needed `waitFor`.

**Maestro device flows** (`.maestro/content-writing/*.yaml`, 7 flows) and a setup README (`.maestro/README.md`) were written to cover what unit/component tests structurally cannot: the real app launching, real OS keyboard, real photo picker, real navigation. **Not executed** — this session had no Maestro CLI installed and no running simulator/emulator (headless environment). See `.maestro/README.md` §1-§4 for install/build/run steps.

Flows 06 (version history: autosave → diff → restore) and 07 (offline/reconnect: airplane-mode edit → queue → flush, **Android-only**, no iOS equivalent for `setAirplaneMode`) were added after the initial 5, closing the two single-device gaps originally listed as not covered. Still not attempted — needs two simultaneous device sessions, not a single-device Maestro flow: two-device real-time sync, presence/multi-cursor (see §6 of the README).
