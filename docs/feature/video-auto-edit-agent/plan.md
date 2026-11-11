# Plan — video auto-edit agent

## ai-service (`app/services/server_video_edit/`)
- `agent.py` (new): manual tool-use loop with `anthropic.Anthropic`, replacing `planner.plan_edit` as the worker's `planner` callable with the same signature `(envelope, analysis, config, sfx_names) -> PlanResult`. Reuses `genre_context`, runtime guide, `RenderPlan` schema and `validate_plan`. Per turn: `runner.check()`, stage callback `planning` with turn counter, budget checks.
- `tools.py` (new): `list_sources`, `view_frames` (ffmpeg seek + `tile` into one JPEG via the existing `ProcessRunner`, timestamps drawn with drawtext), `detect_scenes` (ffmpeg `select='gt(scene,0.3)'` + `showinfo`, parsed pts_time), `submit_plan`. Tool inputs validated with pydantic before use; asset IDs must be in the envelope.
- `config.py`: `anthropic_model` default `claude-sonnet-5-5`, add `agent_effort`, `agent_max_turns`, `agent_max_frames`.
- `planner.py`: keep for prompt pieces (`genre_context`); drop the raw httpx call once the agent replaces it.
- `service.py`: pass a stage/turn callback to the planner; store `agent` usage with the plan receipt; skip nothing else.

## business-service
- `VideoAutoEditService`/`Contract`: accept `render_mp4` (default true), persist it; `VideoAutoEditWorker` stops after the accepted plan when false and marks COMPLETED without output.
- Receipt JSON: expose `summary`, `plan`, `agent`, `render_mp4`; validator accepts the new `agent` object (bounded integers).

## web (`vendor/video-space/src/brandhub/`)
- `server-render-controls.tsx`: "Xuất MP4" checkbox (default on), turn progress, "Mở trên timeline" button when a plan exists.
- `import-render-plan.ts` (new): RenderPlan → new scene with native elements in one `BatchCommand` (reuse `buildTextElement`, transition params, `entranceAnimation`, style mapping from `apply-plan.ts`). Returns the list of MP4-only features for the summary.
- `studio-messages.ts`: vi/en keys.

## Order
1. ai-service agent + tools + unit tests (fake Anthropic client).
2. Live smoke on the matcha fixture with Sonnet 5.5 (paid: one run, needs user OK), record usage.
3. BE `render_mp4` + receipt fields + tests.
4. Web import + panel + e2e with mocked receipts.
5. End-to-end on localhost with the matcha clips.
