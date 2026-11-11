# Implementation plan

1. Add separate I2V URL/key/timeout/poll settings in AI Service config and placeholder variables to `.env.example`.
2. Add image-only worker selection and adapter in `app/services/veo_client.py`. Reuse image validation, Redis job status and S3 video upload. Use the current worker's `/api/v1/media` route for local outputs. Do not change Animate or Veo payloads.
3. Add an image-prompt mode to `brandhub-web/src/pages/editor/components/AIVideoAssistPanel.tsx`, using the existing `aiVideoService` call and async result UI. Keep reference mode intact. Add vi/en editor translations.
4. Configure only the new worker variables in ignored local AI Service `.env` from the URL and key explicitly provided in chat. Verify `/docs`, OpenAPI and authenticated `/health` without generating a job.
5. Run focused backend tests, frontend lint/type checking and build checks appropriate to this UI. No commits or pushes, preserve unrelated staged changes.

Verification prerequisite: remove one duplicate Network import, an incomplete duplicate PostDashboardPage export, and duplicate subset DTO declarations that cause compilation errors. Preserve the complete dashboard view and canonical DTOs. Add vendor/** to the root linter ignores because this is separately vendored source.

Risks: local service must reload config; worker tunnel expires when its process stops; full GPU inference and S3 upload remain unverified unless a real job is requested. Existing local AWS variables are reused without displaying or changing them.

Sync resolution: keep remote Navbar conflict block; merge editor locale objects recursively; in AIVideoAssistPanel derive the selected prompt from imagePrompt or videoBrief, keep image+prompt worker routing distinct from brief-only fallback, and preserve both input controls. Validate with TypeScript/lint/build and focused existing tests.
