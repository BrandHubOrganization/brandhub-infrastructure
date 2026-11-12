# Tests — video auto-edit agent

## Unit (ai-service, fake Anthropic client, no network)
- Loop calls tools in order the fake model asks, returns all tool_results in one user message, ends on accepted `submit_plan` + `end_turn`.
- Invalid plan → `is_error` tool_result with the validation message; corrected second submit accepted.
- Unknown asset ID, >6 frames per call, frame budget exceeded → tool error, no ffmpeg call outside envelope assets.
- Turn limit, `max_tokens`, `refusal`, cancel/lease loss → job fails with specific codes; `provider_started` fence prevents re-run.
- Request shape: model `claude-sonnet-5-5`, adaptive thinking, effort, no forced tool_choice, system prompt byte-stable across turns (cache), no source URLs/keys in any message.
- `view_frames` / `detect_scenes` against a generated ffmpeg test clip (real ffmpeg).

## Business-service
- `render_mp4=false` → job COMPLETED after plan, no render job, no output asset; default true keeps current flow.
- Receipt exposes summary/plan/agent/render_mp4 only to the owner; validator rejects unbounded agent fields.

## Web e2e (mocked receipts)
- Checkbox sends `render_mp4`; progress shows turn n/max; completed plan → "Mở trên timeline" adds a new scene with clips/text/transitions, original scene unchanged, one Undo removes it; MP4-only features listed.

## Live
- Matcha fixture: plan accepted within limits; record turns, frames, tokens, cost; timeline opens; MP4 renders and passes QC when ticked. Visual review by user.
