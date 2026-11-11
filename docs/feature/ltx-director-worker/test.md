# Acceptance checks
- Importing builder performs no filesystem write or CLI action. Both example scripts build outside the source checkout.
- Review requires character; cinematic rejects an unexpected character. Keyframe IDs are unique K0–K3; exactly two parts; bounded voice timings.
- Expanded graph contains no UUID class types or editor-only nodes. Parent image links, promoted text/seed values, K1 end guide and Part-1-last-frame→Part-2 continuity are retained.
- Unsupported widget serialization, missing runtime nodes and unresolved required inputs fail before GPU submission.
- Missing/wrong API key is rejected before multipart parsing; oversize image/body is rejected.
- Mock ComfyUI receives uniquely named uploads and a valid API graph, returns job id; polling exposes only output media, failures and pending state correctly.
- Backend chooses LTX only for configured 20-second image jobs, with character→review and no character→cinematic. Existing Animate/I2V regressions pass.
- Business preserves legacy constructors and forwards the optional character image without changing credit/idempotency behavior.
- UI character upload accepts supported images, can remove them, and sends the selected image. Labels exist in vi/en and reuse theme tokens.
- ZIP contains a portable worker/builder/director and excludes all secrets. Do not count mock success as a GPU quality pass.

## Results — 2026-11-10

- Portable builder/converter/worker: `python -m unittest discover -s tests -v`: 8 passed. Covers both canvases, continuity, promoted values, seed UI controls, bypassed LoRA, unsupported node rejection, auth/mode validation and mocked submission.
- AI backend: `pytest tests/unit/services/test_ltx_worker.py tests/unit/services/test_i2v_worker.py -q`: 12 passed, with mocked Claude and worker HTTP; no paid call or render.
- Business: focused `AiVideoCharacterTest`: 2 passed, 0 failures/errors, preserving legacy constructors and forwarding optional character.
- Web: `npm run ci` passed (110 existing lint warnings, 0 errors); `npx tsc -b` passed after the final 20-second job polling timeout adjustment.
- ZIP: 32 explicitly allowed files, 4,498,884 bytes. CRC check passed; extracted into an isolated temporary directory and built review/cinematic canvases plus imported API/OpenAPI without the original checkout or sibling Ovi repo. No keys, `.env`, logs, model weights or caches included.
- Read-only final review found no concrete blocker; it explicitly did not certify actual installed ComfyUI schema compatibility.

Still pending: actual `/object_info` conversion for both full templates on the VM, GPU memory/quality and Vietnamese voice checks, live polling/media/S3 delivery, browser light/dark checks and public worker configuration. VM is off at the user's request. `start_api.py` performs schema compilation before exposing a new worker; failure requires diagnosis before claiming deployment success.

Deployment: upload the ZIP, extract under `/workspace`, run `bash /workspace/ltx_video_bundle/setup.sh`. Public API targets 10200, GUI targets 10101. Backend LTX URL/key settings remain opt-in; a built ZIP is not evidence that the web is connected to a live worker. Stable `API_KEY` in the VM `.env` can be reused across rentals; an automatically generated key changes on a fresh VM and must be updated privately in backend settings.
