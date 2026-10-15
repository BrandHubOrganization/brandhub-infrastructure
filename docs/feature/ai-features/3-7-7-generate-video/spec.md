# 3.7.7 Generate Video

| | |
|---|---|
| FR Code | 3.7.7 |
| Feature | Generate Video |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR |
| Version | 2.0 — 2026-09-27 — aligned with PO decisions: Google Veo 3.1, Text-to-Video & Reference-to-Video, Async Job Queue HTTP 202, Timeout 5m auto-refund, native MP4, Zero Thumbnail rule |
| Document status | Target Spec |
| Implementation status | In Progress |

## Function Trigger

Begins when a Creator in a Workspace opens the Video Generation Studio (`/workspaces/:workspaceId/ai/video-studio`) or the Video creation panel inside a Task (`/workspaces/:workspaceId/tasks/:taskId`), configures generation parameters (prompt, reference image/Ambassador, style template, aspect ratio, duration), and clicks the "Generate Video" button.

## Function Description

- **Actors / Roles:** CREATOR (Workspace member with generation rights, subject to Agency credit quota and Creator limit).
- **Purpose:** Provide asynchronous generation of high-quality short video clips (5s or 10s) using the Google Veo 3.1 foundation model. Supports both Text-to-Video (pure narrative/cinematic prompt) and Reference-to-Video (guided by brand product asset or Ambassador identity canonical image). Operates via an asynchronous job queue with HTTP 202, two-tier polling, native MP4 delivery, zero-thumbnail client rendering, and a strict 5-minute timeout with automatic credit refund.
- **Interface:**
  - Video Generation Studio Form: Mode selector (Text-to-Video / Reference-to-Video), Prompt editor (with brand context and template chips), Reference Asset Picker (select from Brand Assets, Ambassador Gallery FR 3.7.3, or upload JPG/PNG), Style Template Picker (FR 3.7.6), Aspect Ratio Switcher (`16:9` landscape, `9:16` vertical), Duration Selector (5s, 10s), Credit Cost estimate badge, "Generate Video" submit button.
  - Async Processing View: Progress bar card, live state indicator (`QUEUED`, `PROCESSING`), elapsed timer, estimated time remaining, and "Cancel Generation" button.
  - Video Result Inspector: Native HTML5 video player with zero-thumbnail poster frame, duration indicator, prompt metadata, "Download / Export" button (FR 3.7.8), "Save to Material Assets" button, "Apply to Task" button, and "Regenerate" button.
- **Data Processing:**
  - Client submits payload to Gateway → Business Service validates workspace membership, checks asset access, reserves AI credits atomically on the ledger, creates `VideoJob` row (`status = PENDING`), and dispatches to AI Service.
  - Gateway responds immediately with `HTTP 202 Accepted` returning `{ jobId, status: "PENDING", estimatedWaitSeconds: 120 }`.
  - AI Service worker accepts job, converts reference assets into resolved pre-authenticated signed URLs, formats payload for Google Veo 3.1 API, and submits inference request (`status = PROCESSING`).
  - Worker polls Veo provider API every 10s until completion. Upon provider completion, worker streams native `video/mp4` directly into tenant-isolated S3 storage (`/workspaces/{workspaceId}/ai-videos/{year}/{month}/{jobId}.mp4`).
  - On S3 upload success: Job status marked `COMPLETED`; Business Service settles reserved credits permanently.
  - On timeout (> 300 seconds) or unrecoverable provider error: Job marked `FAILED`; Business Service automatically releases (refunds) reserved credits.

## Routes and DTOs

### Public Client Endpoints (API Gateway → Business Service)

- `POST /api/v1/workspaces/{workspaceId}/ai/videos/generate`
  - Headers: `Authorization: Bearer <token>`, `Content-Type: application/json`
  - Response `202 Accepted`: `ApiResponse<VideoJobInitDto>`
- `GET /api/v1/workspaces/{workspaceId}/ai/videos/{jobId}/status`
  - Response `200 OK`: `ApiResponse<VideoJobStatusDto>`
- `POST /api/v1/workspaces/{workspaceId}/ai/videos/{jobId}/cancel`
  - Response `200 OK`: `ApiResponse<Void>`
- `POST /api/v1/workspaces/{workspaceId}/ai/videos/{jobId}/apply-to-task`
  - Body: `{ "taskId": "UUID" }`
  - Response `200 OK`: `ApiResponse<{ "materialId": "UUID", "taskId": "UUID" }>`

### Internal Service Endpoints (Business Service ↔ AI Service)

- `POST /internal/v1/ai/video-jobs`
  - Headers: `X-Internal-Service-Key: <secret>`, `X-Workspace-Id: <id>`, `X-User-Id: <id>`
  - Body: `InternalVideoJobRequest`
  - Response `202 Accepted`: `{ "jobId": "UUID", "status": "QUEUED" }`
- `POST /internal/v1/billing/jobs/{jobId}/settlement`
  - Headers: `X-Internal-Service-Key: <secret>`
  - Body: `{ "jobId": "UUID", "status": "SETTLED" | "RELEASED", "reason": "string" }`

### DTO Schemas

```json
// GenerateVideoRequest
{
  "mode": "TEXT_TO_VIDEO", // enum: TEXT_TO_VIDEO, REFERENCE_TO_VIDEO
  "prompt": "A luxury perfume bottle spinning slowly in mid-air with water droplets splashing in super slow motion, golden sunlight reflections",
  "templateId": "tpl-vid-cinematic-orbit-01", // optional
  "referenceAssetId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890", // optional, required if mode == REFERENCE_TO_VIDEO
  "ambassadorId": null, // optional, resolved to ambassador's canonical reference asset
  "aspectRatio": "16:9", // enum: "16:9", "9:16"
  "durationSeconds": 5, // enum: 5, 10
  "taskId": "7c9e6679-7425-40de-944b-e07fc1f90ae7" // optional context
}

// VideoJobInitDto (HTTP 202)
{
  "jobId": "vid-job-89f4b1c2-3e4a-4d91-88f5-123456789abc",
  "status": "PENDING",
  "mode": "TEXT_TO_VIDEO",
  "estimatedWaitSeconds": 120,
  "creditReserved": 50,
  "createdAt": "2026-09-27T09:30:00Z"
}

// VideoJobStatusDto (HTTP 200)
{
  "jobId": "vid-job-89f4b1c2-3e4a-4d91-88f5-123456789abc",
  "status": "COMPLETED", // enum: PENDING, PROCESSING, COMPLETED, FAILED, CANCELLED
  "progressPercentage": 100,
  "videoUrl": "https://s3.ap-southeast-1.amazonaws.com/brandhub-assets/workspaces/ws-01/ai-videos/2026/09/vid-job-89f4b1c2.mp4?X-Amz-Expires=604800&...",
  "durationSeconds": 5,
  "aspectRatio": "16:9",
  "mimeType": "video/mp4",
  "fps": 24,
  "fileSizeBytes": 15728640,
  "creditSettled": 50,
  "errorMessage": null,
  "errorCode": null,
  "createdAt": "2026-09-27T09:30:00Z",
  "completedAt": "2026-09-27T09:32:15Z"
}
```

## Screen Layout

Figure — Video Studio & Generation Queue (`brandhub-web/src/pages/ai/video/VideoStudioPage.tsx`):
- Left Panel: Configuration Form
  - Mode Tabs: `Text-to-Video` | `Reference Image-to-Video`.
  - Reference Media Dropzone (active when Reference mode chosen): Displays selected product thumbnail or Ambassador badge, with "Change" and "Remove" buttons.
  - Prompt Textarea: Auto-expanding text input (10–1000 characters) with syntax highlight for brand keywords; "Enhance Prompt with AI" helper icon.
  - Style Preset Widget: Shows active template (e.g., "Cinematic Orbit") with thumbnail pill and "Change" link opening FR 3.7.6 modal.
  - Aspect Ratio Selector: Radio cards `16:9 Landscape` (1920×1080) and `9:16 Vertical Reel` (1080×1920).
  - Duration Selector: Buttons `5s (Standard)` and `10s (Extended)`.
  - Credit Estimator: "Estimated Cost: 50 Credits | Available: 420 Credits".
  - Action Button: Large orange button "Generate Video (50 Credits)" — disabled if credit insufficient or prompt invalid.
- Right Panel: Stage / Preview / Progress
  - When idle: Empty state placeholder graphic with tips on creating video prompts.
  - When job in flight (`PENDING` / `PROCESSING`):
    - Glowing animated progress card: "Generating with Google Veo 3.1...".
    - Elapsed time counter: `01:24 / ~02:00`.
    - Polling status text: "Rendering motion keyframes (45%)...".
    - Button "Cancel Job" (subtle outlined button).
  - When job completed (`COMPLETED`):
    - Video Player Container: Native `<video controls playsinline preload="metadata">`. No external thumbnail image is loaded; the browser decodes and displays frame 0 natively.
    - Floating action overlay: "Export / Download" (opens FR 3.7.8), "Attach to Task", "Save as Asset Material", "Regenerate with Variations".
    - Metadata badge bar: `Google Veo 3.1`, `MP4 Native`, `24 FPS`, `16:9`, `15.0 MB`.

## Function Details

### Data Specifications

- **Input required:**
  - `workspaceId` (path, UUID): Target workspace ID.
  - `prompt` (body, string): Text description (10 to 1000 characters).
  - `aspectRatio` (body, enum): Strictly `"16:9"` or `"9:16"`.
  - `durationSeconds` (body, integer): `5` or `10`.
  - `referenceAssetId` (body, UUID, required if `mode == REFERENCE_TO_VIDEO`).
- **Input optional:**
  - `templateId` (body, string): Style preset from FR 3.7.6.
  - `ambassadorId` (body, UUID): Ambassador ID from FR 3.7.3.
  - `taskId` (body, UUID): Associated task for automatic asset linking.
- **System data:**
  - PostgreSQL `video_jobs` table: `id`, `workspace_id`, `creator_id`, `task_id`, `prompt`, `mode`, `status`, `s3_key`, `duration_seconds`, `aspect_ratio`, `credit_reserved`, `credit_settled`, `provider_job_id`, `created_at`, `updated_at`, `completed_at`.
  - Redis key `video:job:{jobId}` (hash containing status, progress, s3_key, TTL = 24h).
  - Redis atomic lock `credit:reserve:{workspaceId}:{creatorId}`.
- **Output:**
  - `VideoJobInitDto` on `202 Accepted`.
  - `VideoJobStatusDto` on status polling `200 OK`.

### Business Rules

- **BR-AI-701 (Dual Generation Modes):**
  - `TEXT_TO_VIDEO`: Generates video purely from text prompt + style template modifier.
  - `REFERENCE_TO_VIDEO`: Requires a verified `referenceAssetId` or `ambassadorId`. The Business Service MUST verify that the asset belongs to the same Workspace/Agency tenant. Backend resolves the asset to a temporary pre-signed URL before submitting to the Veo 3.1 provider pipeline. The ID is never blindly appended to the prompt string.
- **BR-AI-702 (Atomic Credit Reserve & Settlement):**
  - Upon receiving the generation request, Business Service atomically reserves the required credit (e.g., 50 credits for 5s, 90 credits for 10s) on the Agency/Creator ledger (`credit:reserve`).
  - If the job completes successfully (`COMPLETED`), credits are formally settled (deducted).
  - If the job fails (`FAILED`), times out, or is cancelled by the user, the reserved credits are immediately and automatically released (refunded) back to available balance.
- **BR-AI-703 (Two-Tier Polling & Provider Isolation):**
  - **Tier 1 (Internal Worker Polling):** Background worker polls the Google Veo 3.1 API every 10 seconds.
  - **Tier 2 (Client UI Polling):** Frontend client polls `GET /api/v1/workspaces/{workspaceId}/ai/videos/{jobId}/status` every 3–5 seconds. UI polling strictly reads cached state from Redis/PostgreSQL and NEVER initiates calls to external AI providers.
- **BR-AI-704 (Zero Thumbnail Rule for Generated Videos):**
  - The video pipeline delivers native MP4 files directly.
  - To minimize GPU compute and latency, the system DOES NOT generate, resize, or store separate thumbnail/poster images for newly generated videos.
  - Frontend video components are instructed to configure native HTML5 video attributes: `<video preload="metadata">`. The browser renders the initial video keyframe (frame 0) as the poster preview natively.
- **BR-AI-705 (5-Minute Timeout & Auto-Refund):**
  - Video inference maximum SLA is 300 seconds (5 minutes) from dispatch.
  - If the provider does not deliver output within 300 seconds, the monitoring worker marks the job as `FAILED` with error code `VIDEO_GENERATION_TIMEOUT` and triggers auto-refund of reserved credits.
- **BR-AI-706 (Native MP4 Delivery):**
  - Output is strictly delivered in native Google Veo format: MIME `video/mp4`, 24 FPS, AAC audio (if ambient audio is supported), stored in private S3 and served via Presigned URL with 7-day TTL (`X-Amz-Expires=604800`).
- **BR-AI-707 (Regenerate vs. Technical Retry):**
  - When a Creator clicks "Regenerate", it is treated as an explicit new user action creating a distinct `VideoJob` and consuming a new credit allocation.
  - Internal network drop or transient 503 retries by the worker within the same job lifecycle do NOT charge additional credits.

### Validation

- Credit balance lower than required amount → 402 `INSUFFICIENT_AI_CREDIT`, Display: MSG-AI-701 ("Insufficient AI credits to generate video. Required: {required}, Available: {available}.").
- Prompt length < 10 or > 1000 characters → 400 `VALIDATION_ERROR`, Display: MSG-AI-702 ("Prompt must be between 10 and 1000 characters.").
- Reference mode selected but `referenceAssetId` missing or asset does not belong to workspace → 400 `INVALID_REFERENCE_ASSET`, Display: MSG-AI-703 ("Reference image asset not found or access denied.").
- Unsupported aspect ratio (not `16:9` or `9:16`) → 400 `VALIDATION_ERROR`, Display: MSG-AI-704 ("Google Veo 3.1 supports only 16:9 and 9:16 aspect ratios.").
- Job timeout exceeded 300s → Job status updated to `FAILED`, Display: MSG-AI-705 ("Video generation timed out after 5 minutes. Reserved credits have been refunded.").

## Functionalities

### Normal Flow

1. Creator configures generation parameters on Video Studio (Prompt: "Product rotation...", Mode: `REFERENCE_TO_VIDEO`, Reference Image: `perfume.png`, Template: `PRODUCT_SHOWCASE`, Aspect Ratio: `16:9`, Duration: 5s).
2. Creator clicks "Generate Video".
3. Client validates inputs locally and sends `POST /api/v1/workspaces/{workspaceId}/ai/videos/generate` to Gateway.
4. Gateway authenticates Creator and routes request to Business Service.
5. Business Service checks Creator quota and reserves 50 credits in Redis ledger atomically.
6. Business Service resolves reference image URL from S3, generates new `jobId`, creates `video_jobs` record (`status = PENDING`), and pushes job to RabbitMQ queue `ai.video.tasks`.
7. Gateway responds immediately to client with `202 Accepted` (`{ "jobId": "...", "status": "PENDING", "estimatedWaitSeconds": 120 }`).
8. Client switches UI to async progress view and initiates Tier 2 polling every 4 seconds.
9. AI Service worker dequeues task, updates status to `PROCESSING` in Redis, and dispatches generation payload to Google Veo 3.1 API.
10. AI Service worker polls Veo API (Tier 1) every 10 seconds.
11. Veo completes generation in 115 seconds, returning streaming MP4 bytes.
12. Worker streams MP4 directly to S3 (`/workspaces/{workspaceId}/ai-videos/2026/09/{jobId}.mp4`) and extracts video metadata (duration 5s, 24 FPS, size 15.2 MB).
13. Worker updates Redis and DB `video_jobs` to `status = COMPLETED` with S3 key.
14. Business Service receives completion event, settles 50 credits permanently, and releases reservation.
15. Client's next poll returns `status: "COMPLETED"` and presigned S3 `videoUrl`.
16. Client mounts `<video preload="metadata">`, browser displays frame 0 instantly, and plays video when Creator clicks Play.

### Abnormal Cases

- 5.a1: Credit balance is below required amount → Business Service rejects request with 402 `INSUFFICIENT_AI_CREDIT`. Client displays MSG-AI-701 with direct link to buy credits (FR 3.9.6).
- 5.b1: Creator credit limit reached (Agency admin cap) → 403 `CREATOR_QUOTA_EXCEEDED`, Display: MSG-AI-706 ("Your monthly AI credit limit has been reached.").
- 6.a1: `referenceAssetId` does not belong to current workspace or has been deleted → 400 `INVALID_REFERENCE_ASSET`, Display: MSG-AI-703. Submit aborted.
- 9.a1: AI Service worker queue overloaded → Job remains `PENDING` longer than 60s; frontend displays "High queue traffic, your job is queued in position #2".
- 10.a1: Google Veo 3.1 provider returns HTTP 500 or rate limit 429 during worker polling → Worker executes exponential backoff retry (up to 3 times within 60s). If failures persist → Worker marks job `FAILED`, reason `PROVIDER_UNAVAILABLE`, publishes rollback event. Reserved credits refunded automatically. Client poll receives `FAILED` and displays toast MSG-AI-707.
- 10.b1: Job execution time exceeds 300 seconds (5-minute timeout, BR-AI-705) → Worker aborts monitoring, writes `status = FAILED`, error code `VIDEO_GENERATION_TIMEOUT`. Business Service rolls back credit reservation. Client displays MSG-AI-705 with "Retry" button.
- 12.a1: Network disconnect while streaming output to S3 → Worker retries S3 multipart upload once. If failed, job fails with `STORAGE_UPLOAD_ERROR`, credits refunded.
- 15.a1: Creator closes browser or reloads page during generation → Job continues processing in background on server. When Creator returns to Task / Video Studio, UI queries active jobs for workspace and restores progress or completed video player.
- 15.b1: Creator clicks "Cancel Generation" while job is `PENDING` or `PROCESSING` → Client sends `POST .../cancel`. System sends cancellation signal, terminates worker, sets `status = CANCELLED`, and immediately refunds reserved credits.

## Post-Conditions

- On `COMPLETED`: A durable `video_jobs` row exists with `COMPLETED` status; MP4 file is securely saved in workspace S3 bucket; credit deduction is settled in ledger; asset is eligible for Material saving or Task attachment.
- On `FAILED` / `CANCELLED`: `video_jobs` record status is `FAILED` or `CANCELLED` with detailed error message; zero credits are permanently deducted (all reserved credits released); no orphan video artifacts left in S3.

## Out of Scope

- Video timeline multi-track editing, trimming, and audio dubbing inside the browser.
- Transcoding video into WebM or animated GIF (Veo 3.1 native output is strictly MP4; transcoding is handled separately if enabled).
- Generating custom thumbnails via GPU/FFmpeg (strictly prohibited by Zero Thumbnail Rule).

## References

- [06-ai-features.md](../../../ba/06-ai-features.md)
- [08-subscription-billing.md](../../../ba/08-subscription-billing.md)
- [ai-features-spec-alignment-plan.md](../../../plan/ai-features-spec-alignment-plan.md) (PO Decision D08, Section 2.6: Video & Export, Section 7.1)
- [Google Veo 3.1 API Technical Reference](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/veo/3-1-generate)
