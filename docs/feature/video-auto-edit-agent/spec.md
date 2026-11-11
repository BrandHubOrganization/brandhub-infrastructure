# Video auto-edit agent

## Objective
Replace the server auto-edit's single Claude call with a Claude tool-use agent loop, so a user's instruction plus uploaded clips produce an edit closer to the DemoVideo agent workflow: look at footage, find clean shots and beats, build a plan, fix its own validation errors, and return both an **editable Video Space timeline** and, when asked, an **MP4**.

Decisions (user, 2026-11-10): model **Claude Sonnet 5.5** (`claude-sonnet-5-5`); output **timeline and optional MP4** (user chooses per run).

## Scope
In: the existing `plan` job of `server_video_edit` (ai-service), the auto-edit admission/receipt in business-service, and the Video Space server-edit panel.
Out (later phases): reference-video style analysis, durable per-user correction memory, EditAtlas inside the agent (the in-editor planner already uses it), new paid footage generation.

## Observable acceptance
1. User imports clips (+ optional music/voice), writes an instruction, ticks or unticks "Xuất MP4", and starts an auto edit. Browser may close; the job continues on the server.
2. The agent inspects footage through tools (frames, scene cuts, beats, transcript) before submitting a plan. The plan is validated by the existing `validate_plan`; validation errors go back to the agent as a tool error so it can correct them, up to the turn limit.
3. When the plan is accepted, the panel offers **"Mở trên timeline"**: it adds the plan as a **new scene** in the current project (never overwrites the user's scene), in one undo step. Clips, trims, speed, text (with font/colour/position), transitions, music/voice layers map to native layers. Plan features with no native equivalent (blur fit, circle/arrow callouts, portrait glow, freeze) are listed in the summary as "MP4 only".
4. If "Xuất MP4" was ticked, the existing render job runs from the same accepted plan and the MP4 downloads as today. Unticked, the job ends after the plan with no render cost.
5. The panel shows stages: analyzing, agent working (turn n / max), rendering, QC, uploading, completed, failed. Failures show a short reason; originals are untouched.
6. The existing 8-action chat assistant and its behaviour stay unchanged.

## Agent contract
- Surface: Claude API Messages with user-defined tools, **manual loop** in ai-service using the official `anthropic` SDK (already pinned 2.3.0). Manual loop because each turn must pass the worker's cancel/lease check and update the durable job stage.
- Model `claude-sonnet-5-5`, adaptive thinking, `output_config.effort` `medium` (configurable), `fallbacks: "default"` with beta `server-side-fallback-2026-07-01`. Handle `stop_reason` `refusal` / `max_tokens` explicitly. No forced `tool_choice` (400 on this model): `auto` + prompt instruction.
- Tools (all read-only except `submit_plan`; none run model-supplied commands, filters, paths or URLs):
  - `list_sources()` → verified probes (kind, role, duration, size, has_audio), transcripts, beat estimates, SFX names.
  - `view_frames(asset_id, seconds[])` → one contact-sheet JPEG (≤6 frames, ≤1024 px wide) with timestamps burned in. Budget ≤60 frames per job.
  - `detect_scenes(asset_id)` → scene-cut times from ffmpeg scene detection, cached per asset.
  - `submit_plan(summary, plan)` → runs `RenderPlan` parse + `validate_plan`; returns accepted, or `is_error` with the validation message.
- Loop ends when `submit_plan` is accepted and the model ends its turn. Limits: ≤16 model turns, ≤600 s wall clock (shared job deadline), ≤60 frames, ≤64k output tokens per job; exceeding one fails the job with a specific code.
- Prompt caching: frozen system prompt (runtime guide + genre text + schema) and tool list first, `cache_control` on the last system block; history append-only.
- Durable fence unchanged: `provider_started` is saved before the first model call; a crash or unknown outcome after that becomes `RECONCILIATION_REQUIRED`, never an automatic re-run. Usage (input/output/cache tokens, turns, frames) is recorded on the job receipt for credit review.

## API changes
- `POST /api/v1/workspaces/{ws}/video-projects/{project}/auto-edits` body gains optional `render_mp4` (boolean, default `true` to keep current behaviour).
- `GET .../auto-edits/{job}` adds `summary`, `plan` (accepted RenderPlan), `agent` `{turns, frames}` and `render_mp4`. No storage keys, prompts or provider payloads.
- Internal plan receipt gains `agent` usage; `kind=plan` envelope gains nothing else.

## Security and cost
Instruction, captions and transcripts are untrusted data. Source bytes, keys and URLs never enter the prompt; only sampled frames, probes and transcripts. Credits: the plan step is charged once per job as now; the price must be reviewed after measuring real usage (estimate, unmeasured: 100–200k input + ~10k output tokens per job on Sonnet 5.5).
