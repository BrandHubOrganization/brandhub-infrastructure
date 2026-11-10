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
