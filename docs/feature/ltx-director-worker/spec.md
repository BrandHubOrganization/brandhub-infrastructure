# LTX director worker

Continue the approved Claude design: a 20-second product film, with `review` when a character image is supplied and `cinematic` otherwise. Claude on the application backend writes a validated director script. Qwen builds K0–K3; LTX renders two connected parts; VieNeu mixes optional narration and music.

## Acceptance
- Preserve Tuấn's architecture: backend-only `X-API-Key`, multipart submit, `prompt_id`, job polling, S3 output or authenticated media download.
- Keep existing motion-reference and 5/10/15-second image video routes intact. Select LTX for 20-second image jobs only when LTX is configured.
- Optional character image travels through the existing web and Business request into AI; no raw workflow or secret is accepted from the browser.
- Validate the director schema and selected mode before ComfyUI submission. Override upload filenames and output prefixes server-side.
- Convert generated GUI subgraphs into executable API nodes using the running server's node schema; reject unsupported serialization rather than submitting a guessed graph.
- Deployment ZIP includes everything required to build the graph; installation preserves model files and running ComfyUI.
- UI: optional character upload uses parallel Vietnamese/English keys and existing light/dark theme components. Character image means review; otherwise cinematic.
- Invalid key, missing character, malformed script and unavailable ComfyUI return bounded actionable errors; failed generation retains existing credit handling.

## Verification boundary
Use mocked Claude/ComfyUI and real generated graphs locally. A live GPU render and listening to a selected voice remain hardware acceptance checks; do not claim them from mocked tests.

## Revision 2026-11-18: Wan VACE worker replaces LTX

The VM now runs Wan 2.2 Fun VACE (`wan_vace_bundle`) instead of LTX. Same transport (`LTX_WORKER_URL`/`LTX_WORKER_API_KEY`, `X-API-Key`, `script_json` + `reference_image`, `prompt_id`, job polling, `/api/v1/media`). Only the director script changes.

- Claude writes a VACE script, the same format as the 13 hand-made flows in `ltx-video/flows/<genre>/`: `genre`, `name`, `product_name`, `story`, `views` (4-side turnaround), one 2x2 `storyboard_prompt` (or two `storyboard_prompts` for cut films) and 3-7 `segments` (`prompt`, `start`, `end_panel`, `frames`).
- Genre follows the brief: unbox, hero, tvc, lifestyle, asmr, before_after, food, tech, compare, fashion, home. Prompts follow `PROMPT_RULES_WAN.md` (anti-plastic checklist, ABCD for TVC).
- Video is silent (VACE has no audio): no voice-over or music fields. Sound is added at editing.
- An optional character image is sent as `extra_images` (storyboard image 3, after the product photo and the turnaround). No mode switch.
- Size comes from the request aspect ratio (9:16 = 576x1024, 16:9 = 1024x576), never from Claude. Upload names and output prefixes stay server-side.
- Validation before submission: schema, segment 1 not `prev`, panel numbers within the grids, `frames` 4n+1 in 17..85, total 15-21 s at 16 fps. Failure: no GPU job, no credit change beyond existing handling.

Out of scope: S2V UGC talking flow through the API, web/Business changes, voice/music.

## Revision 2026-11-18 (b): Product Video page uses VACE instead of Veo

User decision (option A): `/workspaces/:id/product-video` becomes the VACE 20 s flow. The scene-by-scene Veo pipeline
(plan, storyboard review, per-scene quotes and retries, ffmpeg render) is no longer shown on this page; its code stays in
the repo for rollback.

- Form: product photo (required, JPEG/PNG/WebP, max 10 MB), optional person photo (same limits), brief (required, max
  1000 characters, the AI service legacy prompt limit), aspect ratio 9:16 (default) or 16:9.
- Submit: existing `aiVideoService.generate` → Business `POST /workspaces/{id}/ai/videos` with `durationSeconds: 20`,
  `referenceImageBase64`, optional `characterImageBase64`. Credits: the existing `VIDEO_GENERATE` operation (refund on
  failure as today). No Business change.
- Progress: existing background task dock (poll every 5 s); the page shows rendering state, then the MP4 player and a
  download link. A failed job shows the credit-aware error message.
- UI states: idle, submitting, rendering (10-20 min note), completed, failed. i18n keys under `productVideo.vace.*` in
  both `vi/productVideo.json` and `en/productVideo.json`; theme tokens only (`bg-card`, `border-border`, `text-muted-foreground`,
  `text-brand-orange`), so light and dark both work.
- Out of scope: storyboard preview before rendering, per-scene retry, recent-jobs list on this page.

## Revision 2026-11-18 (c): photo + brief only
User decision: the page asks only for the product photo and the brief. Claude decides genre, story, people and
`aspect_ratio` (new required script field; the worker size follows it, the request aspect is ignored on this route).
The person-photo and aspect inputs are removed from the page; the backend still accepts `character_image_base64`.

## Revision 2026-11-18 (d): background music
The director picks one of the 5 bundled CC0 tracks (`resources/product-video/music`) in the required `music` field. After
the worker MP4 is downloaded, the AI service loops/trims it to the video length with a 0.5 s fade in and 1.5 s fade out
(ffmpeg, video stream copied, about 1 s). A mixing failure logs and delivers the silent video. No extra Claude call.

## Revision 2026-11-19 (e): Veo form removed
User decision: the product-video page shows only the VACE form. The Veo scene components, hook, service, types and their
unit/e2e tests are deleted from `brandhub-web` (git history keeps them); `?productionId=` links now open the VACE form.
Work restored from stash `wip-ltx-product-video-before-develop-20261118` onto new branch `feature/vace-product-video`
in `brandhub-ai-service` and `brandhub-web`.
