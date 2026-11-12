# Product Video Pipeline verification

Status: local implementation verification completed30October2026 using deterministic API/provider fixtures and real synthetic media, FFmpeg and native editor. No paid Google generation, live database migration or Cloud deployment was performed.

## Planner and consent

| ID | Input/action | Expected |
|---|---|---|
| PV01 | Review, unboxing, showcase briefs; auto matching | One of the three allowed recipes with reason and 2/3 distinct scene roles; no unverified product claims |
| PV02 | Unboxing without box image or generic-box consent | Missing-input response, no actionable quote, reservation or generation |
| PV03 | Owned product/box/logo image refs vs foreign/aborted/wrong-type/oversize refs | Only validated immutable owner/workspace READY refs accepted |
| PV04 | Plan 15/20 seconds | 360/480 total frames at24fps including12-frame transitions and CTA; 2/3 eight-second source requests, sampleCount1 |
| PV05 | User edits prompt or replaces asset/model configuration | New immutable plan/quote; old consent cannot start changed content/configuration |
| PV06 | Plan shown, then explicit Generate | No paid job/hold before click; public costs contain BrandHub credits only, no USD/project credential fields |

## Financial state and durability

| ID | Input/action | Expected |
|---|---|---|
| PV07 | Approved2/3-scene generate with enough credits | All one-unit reservations join one PostgreSQL transaction; dispatch starts only after commit |
| PV08 | Insufficient wallet/cap or price change during batch | Complete rollback; zero dispatch; replan/credit error; no partial holds |
| PV09 | Repeat matching generate key after expiry/current price change | Return same existing production/holds; do not create paid attempts |
| PV10 | Same key with changed revision/quote/workspace/hash | Conflict; no new charge or dispatch |
| PV11 | One successful source and one authoritative failure | Success retained/charged once; failed hold finalized under existing allocation rules; parent needs explicit retry |
| PV12 | Retry quote only, then approve once with new key | Quote has no hold; approval creates one new attempt/hold; other successful scenes unchanged |
| PV13 | AI POST acknowledgment lost but receipt exists | Lookup stable attempt ID; accept known existing operation/job, no second paid submit |
| PV14 | Crash after Google submit with no saved operation | SUBMISSION_UNKNOWN/RECONCILIATION_REQUIRED; hold retained, no automatic retry/refund |
| PV15 | Restart with saved operation name/output checkpoint | Resume polling/download/upload, not provider submission; one authoritative settlement |
| PV15b | Restart before scene submit or during logo render; lost admission returns404 | Restore journaled private reference bytes; replay same stable attempt/reservation only when unadmitted; known UNKNOWN never resubmits |
| PV16 | Render fails then render-retry | Same successful source attempts, zero Veo submits and zero generation-credit reservations |
| PV17 | Missing schema/provider/ADC/config/hash mismatch | Fail readiness before reserving or calling provider; useful error, input retained |

## Render, security and editable project

| ID | Input/action | Expected |
|---|---|---|
| PV18 | Typed two/three-source render with text/logo | Full MP4 decode, exact360/480 frames, requested720canvas ratio, audio duration withinoneframe, correct overlay/join pixels |
| PV19 | Short/malformed source, unsafe key/path/filter/code, invalid frame/overlay bounds | Reject before subprocess; retain original media, no arbitrary command/network execution |
| PV20 | Same render ID+same/different plan hash | Replay same job/output or409; no duplicate incompatible publication |
| PV21 | No music/voice requested | No auto TTS, brown noise, library fetch, hidden loop or extra outro |
| PV22 | Selected licensed bundled music/source-audio behavior | Apply only declared layers; preserve mapping and notices; no unapproved paid source |
| PV23 | Owned completed production editing bundle | Native importer retains asset IDs/fullsource192frames, correct360/480frame scene, editable text/logo/music |
| PV24 | Native first open, repeat, reload, second tab and existing manual local/remote revision | Import once or reopen existing work; no empty partial project, overwrites or blind409 rebase |
| PV25 | Foreign production/scene/workspace, stale iframe session, wrong origin/source/path | Deny or ignore; no authenticated arbitrary request or source leak |
| PV26 | Media fetch/upload/quota/CAS fails | Preserve complete local draft and source data; no false cloud-save/completion success |
| PV27 | Both languages/themes and375/768/1440 widths | Parallel new keys, readable controls, keyboard/return actions and desktop notice |
| PV28 | Existing one-clip Video AI, Video Space jobId import, bridgeflush/storage isolation | Relevant regressions continue to pass |

## Evidence to record after implementation

- AI planner/provider/journal/render test commands and actual counts; explicit synthetic FFmpeg renders with ffprobe/full-decode evidence.
- Business accounting/controller/store/worker tests; distinguish unit mocks from actual disposable-DB runs. Never point gated DB tests at live user data.
- Host/native typechecks, lint, resource/license/bridge verification and production builds.
- Browser fixtures for all3 recipes, exact consent/cost behavior, failed-scene retry, render-only retry and editable reopening; screenshots/MP4/decoded pixels outside repos.
- Final branch/conflict/no-commit state, source/runtime/migration files and unapplied Cloud/storage/DB setup.

Operational prerequisite: Cloud Veo GA project/location/ADC/quota/billing, AI Mongo journal, existing storage/quota prerequisites and additive production SQL schema. Retired Gemini preview API key alone cannot satisfy this. No Docker deployment or live provider success may be inferred from fixture tests.

## Actual local results

Artifacts: `F:/LEARN/DA/.tmp/product-video-pipeline-20261030/`.

| Check | Observed result | Evidence |
|---|---|---|
| AI plan/provider/journal/auth/recovery |22passed |`ai-unit-green.log`|
| Real FFmpeg4canvas/duration variants +short source +legacy params/styles |10passed; exact360/480frames, decode, join/logo/text pixels and220→440Hz audio switch |`ai-render-final.log`, `ai-renders/*.mp4` and JSON|
| Business full clean suite |1300tests,0failures/0errors,82gated skips |`business-clean-tests.log`; count observed from fresh Surefire XML before subsequent focused clean|
| Business final focused feature suite |15passed,0skipped |`business-product-final-clean.log`, `business-product-totals.json`|
| Host approval/API/upload/bridge unit tests |15passed |`web-unit-green.log`|
| Native importer/bridge/storage/resources |13tests passed;600source files,85licensed resources,24fonts andWASM verified |`native-verify.log`|
| Native browser import→manual split/save→local reopen→fresh remote restore→export |Passed; final360frames24fps/15s; red→blend→blue decodedpixels |`native/results/.last-run.json`, `native/accepted-native-manual.json`, `native/native-export.mp4`, probe/pixel JSON|
| Feature browser flows |7passed; all3recipes, explicit credit consent, stale edits, missing-box recovery, one-scene quote/retry, render-only retry, reload, private staged project first import/return, responsive375/768/1440 |`web-browser-final.log`, `web/*.png`|
| Root/native typechecks, focused lint, production build |Passed |`web-typecheck.log`, `native-typecheck.log`, `web-lint.log`, `web-final-build.log`|
| vi/en keys |122parallel keys, no raw productVideo keys visible |Locale comparison and browser assertions|
| Conflicts |0unmerged paths in all4involved repos |`final-repos.json`|

The first broad backend run hit stale compiled test classes; a clean rebuild passed. No application source or test was disabled to obtain that result. The final small image-limit alignment was then checked by the15 focused tests after another clean build.

Financial tests use existing accounting services with unit transaction/store fixtures; actual new SQL concurrency/rollback on a disposable PostgreSQL instance was not run. Live Veo fidelity, Google quota/billing, Mongo/S3 permissions and deployed schema remain operational checks, rather than inferred success from these fixtures. Google operation/model/duration are retained privately for cost reconciliation; no USD cost or credentials are returned in the public quote.

## Revision verification: unboxing/review quality

Live sample follow-up: real FFmpeg190-frame regression first failed on the20s cut and passed on the15s rejection. After validating render inputs against each required interval, both pass:20s/168-frame segments accept without padding; the15s second segment still rejects a190-frame input before rendering. All45 focused AI/real-render tests pass (`flow-review/render-190-{red,green}.log`).

Actual manual Flow sample:3Veo3.1Fast clips downloaded, generated once each for20credits; approved cap60 and observed balance250→190. Final `flow-review/AMBER_DEMO_UNBOXING_20S_REAL.mp4` is720x1280,H264/AAC,24fps,480frames,20.000s audio/video and passes full decode. `AMBER_REAL_QC.json`, per-scene contact sheets and `final-contact.png` record the actual media checks. Local Whisper outputs `scene-{1,2,3}-speech.json` retain approximate recognition and word times; spoken content finishes before the6.5s/6.5s/7s cuts. ASR is not a guarantee of exact pronunciation or identical voices.

| ID | Input/action | Expected |
|---|---|---|
| PV29 |20s unboxing of fictional perfume with packaging consent and3approved review lines | Open/lift action, experiential scent-review scene, closing placement; separate camera/audio instructions; every exact approved line in its own prompt/metadata |
| PV30 |15s unboxing/review | Two clips retain the experience/review beat; no first+last-only hero sequence |
| PV31 |Missing/null reviewScript vs wrong line count/over18words/source audio muted | Backward compatible no-speech plan, or explicit missing inputs and no actionable quote; no silently truncated narration |
| PV32 |Custom source prompt overrides narration/action | Prompt kept as supplied; old derived action/narration is not falsely displayed as enforced |
| PV33 |Form/review script update | vi/en field and readable action/voice card; new plan/quote required; no generation before approval; old briefs without the field restore |
| PV34 |Pending AMBER Demo artifact and real Flow run | Clearly labelled fictional notes and pending generation. No image-pan fixture is proof of unboxing. Actual Flow credit approval,3real clips, decoded/audio review and final assembly are required before marking live sample complete |

Revision artifacts: `F:/LEARN/DA/.tmp/product-video-pipeline-20261030/unboxing-revision/`.

| Check | Observed result | Evidence |
|---|---|---|
| Action/speech planner and existing AI contracts |38passed; initial RED failed before the correction |`ai-narrative-red.log`, `ai-narrative-green.log`|
| Local FFmpeg and legacy regression |10passed; synthetic sources, not generated unboxing footage |`ai-render-regression.log`, `renders/`|
| Business brief compatibility and feature tests |17tests,0failures/0errors/0skips, including2 narration-contract tests |`business-narration-red.log`, `business-narration-green.log`; fresh ProductVideo Surefire XML|
| Host unit contracts |15passed |`web-unit.log`|
| Form/storyboard and responsive browser fixtures |7passed, including exact approved narration presentation |`web-narration-red.log`, `web-narration-green.log`|
| Focused web lint and production build |Passed |`web-lint.log`, `web-build.log`|
| vi/en keys |130parallel keys |Locale comparison after the revision|
| Pending example |3 scenes,480frames/20s; fictional facts and approved narration; no generated footage |`../flow-review/AMBER_UNBOXING_PENDING.json`, `../flow-review/AMBER_UNBOXING_STORYBOARD.md`, `../flow-review/CANH_1_PROMPT.txt` through `CANH_3_PROMPT.txt`|

Revision status: the real manual Flow unboxing/scent sample is rendered and visually inspected; no image-pan fixture was substituted. Scene1 opens/lifts/places the bottle, scene2 smells a paper sample while describing the fictional scent, and scene3 closes on the product. Keep the fictional-product disclosure and mandatory Flow watermark. Wardrobe differs between independent scenes and the synthesized voices were not locked to a single reference. The separate BrandHub Cloud API deployment, credentials/quota/schema and financial concurrency gates remain unverified as stated above.
