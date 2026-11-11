# Acceptance tests (write before code)

| Case | Expected proof |
|---|---|
| Unauthorized internal key, workspace/project/owner mismatch | Denied before model/storage reads |
| Canonical saved source assets only, stale revision | No client snapshot/URL override; stale409 on first admission; later revisions preserve the admitted immutable output branch |
| Missing/foreign/not READY asset, size/SHA mismatch, URL/path/NaN/oversize | Safe explicit error, no render command/model execution |
| Same scoped idempotency key and request | One paid plan, one durable job; retry recovers lost acknowledgment; changed input409 |
| Worker restart, queue full, concurrent submit | Fenced durable receipts, bounded running jobs, queued state visible; no second plan/provider spend |
| Crash after provider_started / lost plan POST acknowledgment | Receipt polling recovers known result with same reservation/job; ambiguous outcome remains RECONCILIATION_REQUIRED, never repeated paid Claude call |
| Public admission while probe/ASR/Claude slow | Durable202 returned before heavy work, browser can close without stopping workflow |
| No ASR model/TTS provider/reference media | Capability/preflight error or explicit unmet-input result; no fake speech/captions/sample video |
| Typed editorial render plan | IDs/timing/geometry/transitions bounded; unknown code/command/filter fields rejected |
| Real synthetic video/still/voice/alpha portrait input | Finished MP4 has freeze/callout, composited title/portrait, captions, transition and audible mix; inspect selected decoded pixels and audio |
| QC frame count/duration/dimensions/full decode/loudness | Correct final timing and no empty/truncated output; failure never COMPLETED |
| Canonical output persistence | Private server-derived key, SHA/size receipt; another user/workspace cannot get output |
| Encrypted media transport | Worker reads Business-verified/decrypted stream only; does not receive AES/storage keys. Output uses normal private quota/capability/confirm flow; interruption replays identical artifact/session without quota leak |
| Browser closes/reopens | Saved job resumes in UI; server continues; original editable project unchanged |
| UI VI/EN and light/dark/keyboard | Parallel labels, visible stage/failure/download, no theme/focus regression |
| VM package | No F:/ or C:/ dependencies; ffmpeg/font/SFX/license present; env capabilities expose missing model/provider; no embedded secrets |
| Regression | Existing8-action assistant, manual edits/Undo/export and image+prompt video generation remain working |

Record commands, actual fixture render paths and model/provider calls separately. Synthetic/fixture proof is not an actual cloud deployment or paid footage-generation proof.

Review regression cases: dropped output-session reply recovers cached artifact; long caption/long token at bottom edge fits or fails explicitly; untouched native text defaults pass; audio-labelled container cannot bypass embedded video decoder limits.

2026-11-10 controller evidence: reviewed Task1135files hash-integrated into root with0conflicts. Live worker8094 health200, authenticatedcapabilities200/withoutkey401; ffmpeg/ffprobe/planner/Mongojournal/mountedASR readiness alltrue, optionalTTSfalse. Final reviewed Linux image rebuilt successfully; networkdisabled/read-only/4CPU/4GiB/128PID container smoke health200, real30frame160x160H264 encode verified byffprobe,72SFX present. Build log: .tmp/server-video-editor-20261110/runtime/docker-final-build.log. No footage generation or VM deployment.

Integrated root worker verification: python -m pytest tests/server_video_edit -q --noconftest,25passed in10.36s (no provider/cloud). AI API reloaded andproxycapabilities200 withplanner+ASR ready, evidence runtime/proxy-smoke.json. Realnativevoiceupload found existing encrypted-capability MIME allowlist mismatch (WAV permittedbyVideoMediaPolicy butdeniedbycontroller); Task2includesparityregression. Failedownedtestsession abortedthroughpublicAPI200; no directDBwrites.

Final evidence and limits: see RESULT_2026-11-10.md. Actual API completed68.062s/private SHA verified; final read-only replay passed with zero new provider calls. Business57 tests, Web15 unit tests/root CI/laptop2 E2E passed. Worker final recovery/runtime20 tests passed; final Docker offline encode30 frames exit0. No VM deployment. Publication expiry residual was corrected by controller after scoped review; no subsequent independent review of the last narrow line.

## 2026-11-11 — Editable layer cases
- A valid sidecar preserves two cuts, editable text and independently timed/gained audio; editable=true survives JSON transport.
- Foreign asset, unknown SFX, invalid timing or mismatched MP4 geometry fails explicitly. A legacy completed output stays editable=false.
- Import original video audio as audio elements (not unmuting every matching video), respecting trim, speed, gain and silence. Music/SFX become separate library tracks with valid bundled URLs.
- Applying creates a new scene; Undo restores original scene. Unsupported effects are disclosed, not silently omitted. Save failure retains the local scene and displays retry guidance.
- VI/EN feedback keys match; existing semantic theme classes and keyboard buttons remain. Run native typecheck/build and worker tests offline; identify any browser/live-job checks not performed.

2026-11-11 evidence: worker pytest tests/server_video_edit --noconftest: 78 passed (45.02s), no provider calls; native importer Vitest: 4 passed including independent video-source audio, trim/gain/retime, missing media rejection and repeated long library music. Native typecheck passed. Root npm run ci passed (0 lint errors, 110 existing warnings); native bundle rebuilt after music-loop correction. Edge fixture tests chat-layers.spec.ts VI/light + EN/dark passed (2 cases): two cuts, editable text, three audio layers, saved new scene and Undo. Screenshots in .tmp/video-space-e2e/chat-layers-{vi-light,en-dark}.png. Worker restarted only after read-only journal count unfinished=0; live health200, new editable schema present, planner_ready=true. No real Claude editing turn was submitted, so actual model compliance with TIMELINE.json is not yet demonstrated; missing sidecar is clearly marked flattened, invalid sidecar fails explicitly. New generated media and fully faithful custom effects remain unsupported by this source/library-only export. No commit/push.


## 2026-11-11 — Missing editor resources
Audio uploaded in either Media or Audio is visible under Uploaded, playable, searchable, added as upload sourceType with same mediaId and persisted after save/reload. Filters have nonblank differing thumbnails, replace old filter without removing other effects, clear and Undo work. Effects catalog has actual shader-backed entries and adding changes saved clip params/render. Verify VI/light and EN/dark with no missing asset requests or shader errors. Existing editable-chat tests continue passing.

2026-11-11 editor-resource evidence: reproduced Uploaded missing in Edge before fix; native data tests reproduced 2-only effects and missing preview asset path. Final native Vitest 7 passed (includes prior layer importer regressions, finite positive blur sigma and VI/EN catalog parity). Native typecheck passed. Root npm run ci exit0, lint0 errors/110 existing warnings, production/native builds passed. Final Edge fixtures 4 passed/0 flaky (44.0s): prior Claude-layer import+Undo in VI/light and EN/dark; WAV upload through Media and Audio, real preview playback, add/save/reopen retains 2 uploaded files; all effect previews have nonblank pixels, warm/cool previews differ, replacing/clearing filter and adding high-contrast effect persist. Screenshots .tmp/video-space-e2e/{editor-resources,uploaded-audio}-{vi-light,en-dark}.png. No worker/backend change or paid call. A transient test-server watcher EBUSY during rebuild was resolved by restarting the test server; final tests passed. No commit/push.
