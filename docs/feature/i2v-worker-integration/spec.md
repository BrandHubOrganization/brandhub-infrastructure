# Image + prompt video worker

Objective: connect BrandHub's existing AI video web request to the user's Qwen-edit + Wan-I2V worker. Uploading an image and a prompt must work without a motion-reference video.

User story: the creator chooses image + prompt, supplies an image and request, selects 5/10/15/20 seconds, and receives a playable stored video through the current async job UI.

Acceptance criteria:
- Keep the worker key in AI Service `.env`, never in frontend assets or checked-in files.
- Use separate `I2V_WORKER_URL` and `I2V_WORKER_API_KEY`; preserve existing Qwen image and Tuấn Animate worker settings.
- For requests with an image, no pose video and I2V configured, submit multipart `reference_image`, `image_prompt`, `motion_prompt`, `duration_seconds`, width and height to `/api/v1/generate_video` with `X-API-Key`.
- Poll `/api/v1/jobs/{prompt_id}`. If the worker has no S3 URL, fetch authenticated `/api/v1/media` and store the MP4 using the backend's existing S3 uploader.
- Preserve pose-reference Animate requests and text-only Veo requests.
- Invalid duration, missing image/key and upstream errors must fail clearly; do not silently round duration or fall back to a paid provider after worker rejection.
- i18n: add matching `editor.studio.video.generationMode`, `imagePromptMode`, `referenceMode`, `promptHint`, `promptTooShort`, `aspectRatioLabel`, `portrait`, `landscape` keys in vi/en editor locales. Reuse existing brief/duration keys.
- Light/dark: reuse existing theme tokens for select, textarea and labels; no new palette, layout or modal.

API contract: the public web/business video contract remains unchanged; an image-only request already supports prompt, referenceImageBase64, durationSeconds and aspectRatio. The AI Service adapts those fields to the new worker.

UI states: image-prompt mode defaults to 5 seconds and portrait; reference mode retains its measured-duration UI. Existing pending, processing, complete and failed states continue to work.

Edge cases: worker restart/unknown job, key 401, unsupported 8-second requests, completed job without MP4, local-only worker output, empty prompt. Out of scope: product-video storyboard pipeline, worker model changes, AWS credential changes, deployment, GPU renders and credit-policy changes.

Definition of done: focused adapter/config tests pass, frontend lint/type checks pass, URL/key verified by authenticated read-only health; report restart requirement and no real render test.

Build prerequisite discovered during verification: remove duplicated import/component/interface declarations already present in the web working tree, preserving the complete PostDashboardView implementation and richer DTO declarations. Exclude separately vendored third-party source from the application's lint pass; do not change publishing behavior or third-party source.

Local sync 2026-11-09: retain remote text-brief generation and local image+prompt/reference generation when resolving stash conflicts. Never silently route image+prompt through text-only generation. Retain remote admin navbar access behavior and all locale keys. No new provider request, commit or push.
