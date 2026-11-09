# Test Specification — FR 3.6.10: Content Writing View

> Note: This specification maps to official **FR 3.6.10 — Content Writing View** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-6-10-content-writing-view/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.10` |
| **Function Name** | Content Writing View |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `TaskContentServiceImpl.restoreVersion()` (48 LOC) + `contentUtils.ts` / `CanvasTextEditor.tsx` / `RichTextEditor.tsx` |
| **Unit Test Files** | `brandhub-business-service/src/test/java/com/brandhub/business/service/TaskContentServiceImplTest.java`, `brandhub-web/src/pages/content-writing/*.test.ts` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Save rich social post drafts with Unicode font styling (YayText/Zantext), support both Direct API Auto-Publish and Manual 1-Click Copy/Paste to Facebook/Instagram/TikTok/Threads, import/export Google Docs & Word documents, track version history, and restore previous content versions |
| **Preconditions** | Can connect with server (or automatic local offline fallback when server is unreachable); Caller is Owner, Manager, or Creator in workspace |
| **Overall Status** | **Passed (100%) — 52/52 Vitest + 22/22 JUnit + 67/67 Playwright E2E + 31/31 Live Integration** |
| **Test Case Breakdown** | **Backend UTC Matrix: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 6, `Boundary (B)`: 3, `Abnormal (A)`: 8 |

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

## 4. Feature Acceptance & Automated Verification Summary

| Layer | Tool | Location | Cases | Result |
|---|---|---|---|---|
| FE pure logic (lists, diff, Unicode font conversion, CRDT, richText) | Vitest | `brandhub-web/src/pages/content-writing/**/*.test.ts` | 52 | ✅ 52 / 52 |
| BE service logic (load, op log, snapshot, versions, restore) | JUnit 5 + Mockito | `brandhub-business-service/src/test/java/.../service/impl/TaskContentServiceImplTest.java` | 22 | ✅ 22 / 22 |
| Browser E2E — Content Writing View (`CanvasTextEditor`) | Playwright | `brandhub-web/tests/e2e/editor/content-writing.spec.ts` | 32 (`E2E-01`..`E2E-32`) | ✅ 32 / 32 |
| Browser E2E — Content Creator Studio (`RichTextEditor`) | Playwright | `brandhub-web/tests/e2e/editor/content-creator-studio.spec.ts` | 35 (`Studio-01`..`Studio-35`) | ✅ 35 / 35 |
| Live backend integration (real Spring Boot + Postgres + JWT + STOMP) | Node script | [integration-test.cjs](integration-test.cjs) | 31 | ✅ 31 / 31 |
| Mobile unit & component (`jest-expo` + RTL) | Jest | `brandhub-mobile-app/src/screens/content-writing/__tests__/` | 46 | ✅ 46 / 46 |

---

## 5. Browser E2E Matrix (Playwright) — `content-writing.spec.ts` (`E2E-01`–`E2E-32`)

| ID | Scenario | Expected | Status |
|---|---|---|---|
| `E2E-01` | Open page | Editor + canvas visible, status "Live" (STOMP connected) | ✅ Passed |
| `E2E-02` | Type `Hello BrandHub` | Text in editor & preview; Yjs updates sent over STOMP; replaying them rebuilds the text | ✅ Passed |
| `E2E-03` | Load with existing snapshot | Content restored accurately | ✅ Passed |
| `E2E-04` | Vietnamese IME via CDP (`imeSetComposition` → `insertText`) | Preview shown mid-composition; commits on `compositionend` without render loop | ✅ Passed |
| `E2E-05` | `Ctrl+A`, `Ctrl+B` | Mirror stays plain; preview shows Unicode bold | ✅ Passed |
| `E2E-06` | `Ctrl+A`, Backspace | Document cleared | ✅ Passed |
| `E2E-07` | Undo / Redo (`Ctrl+Z` / `Ctrl+Y`) | Text removed then restored | ✅ Passed |
| `E2E-08` | Bullet button twice | `• buy milk` then back to `buy milk` | ✅ Passed |
| `E2E-09` | Select all + numbered button | `1. one / 2. two / 3. three` | ✅ Passed |
| `E2E-10` | Bullet, Enter, type, Enter, Enter | List continues, then exits on empty item; focus stays in editor | ✅ Passed |
| `E2E-11` | Versions with/without editor name | Name shown / "Unknown" | ✅ Passed |
| `E2E-12` | "Changes" word diff | Struck words red, new words green; "Hide" collapses | ✅ Passed |
| `E2E-13` | First version "Changes" | All additions | ✅ Passed |
| `E2E-14` | "Restore" version | Live content replaced; restore sent as a Yjs update | ✅ Passed |
| `E2E-15` | Empty history | Placeholder displayed | ✅ Passed |
| `E2E-16` | Idle editor (21 s) | Reports `POST .../content/snapshot` | ✅ Passed |
| `E2E-17` | Bold text → "Sao chép bản đăng" | Clipboard holds converted Unicode text | ✅ Passed |
| `E2E-18` | Empty document | Copy button disabled | ✅ Passed |
| `E2E-19` | Offline edits + reconnect | Edits queued in `localStorage`, sent on reconnect, missed remote updates merged | ✅ Passed |
| `E2E-20` | Accessibility attributes | Hidden input has `role=textbox` + `aria-multiline`; canvas is `aria-hidden` | ✅ Passed |
| `E2E-21` | Peer awareness update arrives | Colored cursor flag + name label rendered at peer's caret | ✅ Passed |
| `E2E-22` | Own awareness broadcast | Never renders as a peer of itself | ✅ Passed |
| `E2E-23` | Cursor pixel accuracy across fonts, sizes (`12pt`–`28pt`), and alignments (`left`, `center`, `right`) | Caret sits at exact glyph pixel boundary on every word click and arrow press | ✅ Passed |
| `E2E-24` | Selecting different fonts (`Georgia`, `Courier New`, `Brush Script`, `Double Struck`, `Fraktur Gothic`, `Small Caps`, `Circled`, `Squared`, `Fullwidth`) | Social preview and published post payload (`POST /posts`) convert to the exact Unicode font | ✅ Passed |
| `E2E-25` | Wrapped multiline text, Word Ribbon mode, double-click word select, and `ArrowUp`/`ArrowDown` | Caret stays 100% aligned across wrapped visual lines | ✅ Passed |
| `E2E-26` | Google Docs UI/UX chrome, creative copywriting tools, and `.docx` import | Menu bar, ruler, creative tools, and `.docx` import populate canvas and preview | ✅ Passed |
| `E2E-27` | Document Import all cases | Live Google Docs URL, error handling, `.docx`, `.md`, `.txt`, `.html`, Replace vs. Append modes | ✅ Passed |
| `E2E-28` | Backend (`Có BK`) vs. No Backend (`Không BK` / Offline Fallback) | Editor works seamlessly even when backend returns 500/offline | ✅ Passed |
| `E2E-29` | AI Caption in Content Writing View: With Brand Knowledge (`Có BK`) vs. Without Brand Knowledge (`Không BK`) | Badge reflects BK status; generated caption inserts and converts to Unicode | ✅ Passed |
| `E2E-30` | Brand Knowledge Documents (`Phần tài liệu BK`) | View, Upload (`.pdf`, `.docx`, `.txt`), Reject invalid file, Semantic Search, and Delete to `Không BK` | ✅ Passed |
| `E2E-31` | Full Google Docs/Word cursor suite (`Ctrl+Arrow`, `Ctrl+Shift+Arrow`, `Ctrl+Home/End`, `Ctrl+Backspace/Delete`, Double/Triple-click), Rich HTML Paste, `.docx`/`.md`/`.txt` Export, and Facebook publish | All cursor shortcuts, rich paste, export round-trip, and Facebook publish pass | ✅ Passed |
| `E2E-32` | Both Social Publishing Cases: (1) Direct API Publish to `Facebook`, `Instagram`, `TikTok`, `Threads` & (2) Zantext / 1-Click Copy & Paste (`Ctrl+C`, toolbar copy, Zantext popover) into Plain-Text Facebook Composer Sandbox (`Thử dán FB`) | 100% of mixed fonts, bold, italic, underline, strikethrough, and bullet lists are preserved in both API payload and pasted plain-text composer | ✅ Passed |

---

## 6. Planned V6 Test Cases (YayText 36-Style Expansion — To Execute After User Approval)

| ID | Layer | Scenario | Expected |
|---|---|---|---|
| `TC-YAY-01` | Vitest | `Black Bubble` (`🅑🅤🅑🅑🅛🅔`) & `Black Square` (`🅱🅻🅰🅲🅺`) with English & digits | Maps `Sale 50` → `🅢🅐🅛🅔 ➎⓿` / `🆂🅰🅻🅴 ➎⓿` |
| `TC-YAY-02` | Vitest | Smart Vietnamese Diacritic Auto-Strip on Enclosed shapes (`"Khuyến mãi Đặc Biệt"`) | Automatically strips Vietnamese diacritics before enclosed mapping → `"🅚🅗🅤🅨🅔🅝 🅜🅐🅘 🅓🅐🅒 🅑🅘🅔🅣"` (zero broken combining marks) |
| `TC-YAY-03` | Vitest | `Parenthesized` (`⒫⒜⒭⒠⒩`) & `Regional Indicator` (`🇧 🇷 🇦 🇳 🇩`) | Maps letters & digits accurately without merging into unintended country flags |
| `TC-YAY-04` | Vitest | `Superscript` (`ˢᵘᵖᵉʳ ⁰¹²`) & `Subscript` (`ₛᵤ₆ ₀₁₂`) | Maps footnotes (`"incl. VAT 10%"` → `"ᶦⁿᶜˡ. ⱽᴬᵀ ¹⁰%"`) |
| `TC-YAY-05` | Vitest | Combining Line Overlays: `slashthrough` (`9̸9̸0̸k̸`), `double-underline` (`A̳B̳C̳`), `tilde-strike` (`A̴B̴C̴`), `overline` (`A̅B̅C̅`), `under-asterisks` (`A͙B͙C͙`), `lightning-above` (`A͛B͛C͛`) | Applies exact combining mark after each base glyph (excluding `\n`) |
| `TC-YAY-06` | Vitest | `upside-down` (`qnpuɐɹB`) | Rotates characters 180° and reverses character order per line while preserving line order |
| `TC-YAY-07` | Vitest | Character & Line Decorators (`air-quotes` `『B』『r』`, `lenticular-brackets` `【B】【r】`, `sparkles-decorator`, `stars-wave-decorator`, `arrow-pointer-decorator`) | Wraps characters/lines cleanly |
| `TC-YAY-08` | Vitest | `stripUnicodeStyling` across all 36 YayText styles | Restores clean plain text when switching between any two of the 36 styles |
| `E2E-33` | Playwright | YayText 36-Style Popover in both `ContentWritingPage` and `ContentCreatorStudio`: Category filter tabs (`Sale & Gạch giá`, `Khung Nổi bật`), Favorite pinning (`⭐`), Vietnamese Diacritic toggle, and 1-Click Copy of `Black Bubble` + `Slash Price` into Facebook Sandbox | Filtered styles render, Favorites persist in `localStorage`, and copied `🅢🅐🅛🅔 9̸9̸0̸k̸` pastes identically into Facebook Sandbox |
