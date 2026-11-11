# Video Space verification

Status: feature source, focused tests, production builds and five browser workflows verified. No paid AI generation or live database migrations. Live cloud setup is separate from the fixture-backed verification below.

| ID | Input / action | Expected |
|---|---|---|
| VS01 | Anonymous, CLIENT, inactive/nonmember workspace | Protected host/API access denied using existing account/workspace policy |
| VS02 | Same workspace, another project owner/admin-support | Private snapshot and media cannot be read or overwritten |
| VS03 | Completed owned AI job -> Open in Video Space | Only persisted original is downloaded; native File import opens timeline; no credit/generation/refresh call |
| VS04 | Missing/failed/pending/foreign AI job, arbitrary URL | Error and safe return; no URL proxy or data leak |
| VS05 | Open editor manually, import MP4 | Original dimensions/timing retained; timeline editable |
| VS06 | Media before first snapshot; competing creator same project ID | Draft owner claimed atomically; second owner rejected |
| VS07 | New snapshot revision 0 then expected revision 1 | Revisions advance and response describes its own CAS result |
| VS08 | Stale save with newly staged media | 409; accepted snapshot/manifest unchanged; staged media absent from GET |
| VS09 | Same asset ID + same hash/different hash | Idempotent original metadata preserved / 409 content conflict |
| VS10 | Invalid ID/name/finite JSON/size/media references | Validation errors; no accepted state or quota drift |
| VS11 | Provider upload reserve/PUT/confirm/retry/abort/recovery | Correct provider, content head/signature checks, immutable publication and consistent quota; no MaterialDocument leak |
| VS12 | Existing logo/avatar/material uploads | Existing 5MB/6MB multipart behavior unchanged |
| VS13 | Parent foreign origin/source/session or other workspace/path | Bridge ignores/rejects; no authenticated arbitrary API request |
| VS14 | Logout or switch workspace/user during upload/load | Old pending work cancelled; iframe reloads; another user's IndexedDB/OPFS data not listed/deleted |
| VS15 | Click clip -> Ctrl+B, Undo/Redo, mask None/preset, filter, speed, font | Same reviewed editor behavior; real timeline changes and reversible commands |
| VS16 | All 24 local fonts, SFX/sticker/template catalog | 85 valid items and licenses; no Google Fonts dependency for local families |
| VS17 | Save and restore in a fresh browser | Original bytes/hashes/IDs and editable layers restored; stale drafts not silently replaced |
| VS18 | Export MP4 after mask/text/filter | Playable file; decoded pixels reflect rendering, not only preview CSS |
| VS19 | Host vi/en, light/dark, keyboard navigation, 375/768/1440 widths | Parallel new translations, readable themed controls, working return/retry and desktop notice |
| VS20 | Clean install/build/container source | Static /video-space bundle and workers/fonts/WASM resolve without Next/FastAPI/lab/env/data copies |

## Evidence

- Host: `npm run type-check` passed; `vitest run tests/unit/videoSpaceProtocol.test.ts tests/unit/videoSpaceService.test.ts` passed 9 tests; focused ESLint passed. Guards cover foreign workspace/job/path/session, method/body shape and upload/flush boundaries. Transfer tests cover JSON sessions, credential-free provider PUT, idempotent upload, abort, ambiguous confirmation and safe localized errors.
- Editor: `npm run type-check:video-space` passed; `npm run verify --workspace @brandhub/video-space-editor` passed 3 bridge/storage tests and verified 598 source files, 85 licensed resources, 24 fonts and actual WASM initialization.
- `npm run build` passed for both static editor and host. Existing host bundles still produce Vite's large-chunk advisory. Build log: `.tmp/video-space-integration-20261028/web-build.log` in workspace root.
- Independent bridge review found and fixed two issues: sandbox blocked the reviewed restore-confirm dialog; nested API errors were not read by the child. The iframe now permits its confirm dialog, and sanitized localized errors include the top-level message expected by the native editor.
- Final backend suite: 1,283 tests, zero failures/errors, 82 environment-gated skips. Thirty feature tests across 13 new suites passed; the earlier focused feature/storage/access run passed 64 tests. Evidence and exact offline Maven command: [backend-api.md](backend-api.md), Business `target/video-space-full-suite.log` and `target/surefire-reports`.
- Production browser happy path passed on `http://127.0.0.1:3215/` with the real static editor/WASM and intercepted authenticated API/provider data. Completed history -> editor import -> Ctrl+B/Undo/Redo -> ellipse/None mask -> Mono -> editable Product Launch text/Lora font -> save -> fresh-browser restore -> MP4 export -> return with draft flush. The provider PUT had no bearer; original SHA was retained and no video-generation request occurred.
- Export was decoded in Chromium: 640x360, center pixel `[65,65,65,255]`, corner `[0,0,0,255]`, proving Mono and ellipse mask reach the rendered file. Evidence lives outside repos at workspace `.tmp/video-space-e2e`: `first-source-open.png`, `editor-edited.png`, `fresh-restored.png`, `accepted-snapshot.json`, `restored-export.mp4`, `export-pixels.json`.
- Visual review found an unlayered bootstrap body color overriding light-theme text. Bootstrap now uses theme variables. Independent review also found renderer-startup failure could trap the return action before a flush handler existed; a RED/GREEN bridge test now proves safe return before any editable draft exists. Final build exited 0 (`.tmp/video-space-integration-20261028/web-build-final.log`).
- Final Playwright run: 5/5 passed in 40.3 seconds on the final production bundle. Includes completed-history edit/save/restore/export, denied source with useful error and return, same-browser user/workspace isolation, light EN/dark VI with 375/768/1440 widths, and WASM startup failure with a working return action. Editor body contrast measured 14.91:1 in light mode and 17.16:1 in dark mode; root visually inspected both screenshots. Focused E2E ESLint passed. The 22,311-byte synthetic red MP4 is included under `tests/e2e/video-space/fixtures`; test execution does not depend on the lab.
- Browser command from web root: `node node_modules/@playwright/test/cli.js test -c tests/e2e/video-space/playwright.config.ts`. Production preview must already serve the web build on port 3215 (or supply `BASE_URL`). Artifacts are outside repos in workspace `.tmp/video-space-e2e`.
- Git: 11 accessible repositories updated. `brandhub-mvp` origin returns Repository not found; it remains unchanged. Four web conflicts are resolved, with no unresolved Git entries. Web/infra merge results remain uncommitted as authorized; no push. Original tracked patches and audit logs are preserved outside repositories in `.tmp/video-space-integration-20261028`.

## Operational boundary

Browser API/provider responses are fixtures; backend tests use mocked dependencies. They do not establish live cloud readiness. Existing repository writes are disabled by default and require verified provider/CORS, quota/inventory readiness and the documented Mongo indexes. A read-only-by-default index migration is prepared at `docs/database/migration-mongo/2026-10-29-video-projects-indexes.js`; no database/cloud settings or data were changed. Source AI downloads retain the existing buffered S3 reader. Docker source configuration is updated; no Docker image build or deployment is claimed.

## Reconnection acceptance 2026-11-09
GET project list returns200 instead404; private project PUT/GET preserves snapshot/media and revision; foreign owner/workspace denied; stale revision409. Saved source bytes stay immutable and checksummed. Claude planner accepts only bounded canonical snapshot; validates allowed actions, existing active-scene IDs/type and numeric bounds; handles unavailable provider/invalid output without mutating project. Business preserves idempotency/accounting, never exposes key and does not hold/truncate DB transaction during provider network call. Host permits only exact selected project's edit-plan POST and ignores forged frame/session; plan invalidated after local/server revision changes. All actions validated before one BatchCommand; Undo restores original. Trim/speed/transition supported only using actual native APIs; unsupported action fails visibly. Run feature regressions, full relevant type/build checks and real synthetic render with no API cost. Actual paid Claude/Veo and cloud deployment require separately observed proof, not claimed from mocks.

Runtime migration check: disposable restored DB has required private media quota/production/sharing columns; BASIC/PERSONAL and entire billing_plan_versions checksum unchanged; immutable trigger remains enabled; legacy tables/data retained. No paid-order/wallet/price insert. New Mongo video indexes use exact named definitions, reject existing conflicts, don't modify current task/post/mail collections. S3 readiness result403/InvalidAccessKeyId retained; no cloud upload claimed.

Observed RED: old Video AI sidebar selector missing after pull; global /ai-studio/video redirects without workspace and mock dashboard fails. Gate must navigate actual workspace Video AI menu, import owned completed fixture, edit/save/fresh restore/export/Back into same workspace.

Final evidence2026-11-09: see RECONNECT_RESULT_2026-11-09.md. Authenticated actual Claude plan200 in2.7s/replay200; API save/read200, stale409, workspace404, missing key400. Native14+host14 unit green, planner51 green, FFmpeg7 green. Browser assistant11s green; source/edit/fresh-restore/export17.7s green, decoded640x360 pixels checked. Root build and native typecheck green; changed files final lint0errors. AWS upload remains unverified/InvalidAccessKeyId; user storage choice pending; no paid Veo/VM/commit/push.

## Visual integration checks — 2026-11-11
Palette test: apply host HSL tokens, white primary foreground and font to child; repeat for changed dark tokens without altering media styles. Navigation test: video items retain workspace scoping and existing CLIENT denial. Check library dictionary key parity and reactive locale selection. Run native type-check, relevant unit tests, existing host bridge regression and npm run ci. Browser acceptance: one BrandHub sidebar, all video destinations visible to Creator/Manager, no test-workspace wording, no nested horizontal viewport overflow, readable light/dark cards/buttons and usable mobile recovery. Do not generate paid video or overwrite user projects for this check.

Observed 2026-11-11: focused appearance/navigation/bridge-service tests 19 passed; native host-bridge Node test 1 passed; native TypeScript exit0; full npm run ci exit0 (existing110 lint warnings, no errors, bundle-size warnings). Rebuilt editor served at localhost:3000/video-space/index.html with HTTP200. Browser access host unavailable: actual light/dark, mobile layout and user-project playback were not visually verified. No paid API/render job or data mutation was used.
