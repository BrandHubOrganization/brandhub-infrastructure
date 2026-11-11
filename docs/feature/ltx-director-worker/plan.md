# LTX director worker implementation plan

Use Ponytail and writing-plans; execute inline with the executing-plans workflow. Reuse the current image worker's authenticated transport and media/S3 handling rather than adding another persistence system.

1. Refactor `ltx-video/build_flow.py` into importable `build_canvas`; preserve its CLI. Package the Qwen subgraph data so the deployed builder does not depend on `ovi-video-api` on the Windows machine.
2. Add GUI-to-API conversion with actual `/object_info` schemas, promoted subgraph widgets, namespaced IDs, optional input omission and final-output reachability pruning. Test linkage and literal lists separately.
3. Add the LTX worker using the existing image worker API pattern. Validate script/mode and image sizes before uploading; validate executable graph before `/prompt`. Keep status and media authentication.
4. Add backend LTX settings/director resources and reuse existing Claude vision call. Extend the existing image worker polling/download helper. Route only configured 20-second image jobs to LTX.
5. Add optional character image to Business request and web service/editor. Preserve old Java request constructors and old modes; update `vi/editor.json` and `en/editor.json` together.
6. Package worker, builder, director, templates and install/start instructions into `ltx_video_bundle.zip`. Run focused Python/Java checks, frontend CI and a mocked submit/poll/media integration.

No database migration, scheduler changes, remote render, deployment, commits or unrelated source cleanup are part of this change.
