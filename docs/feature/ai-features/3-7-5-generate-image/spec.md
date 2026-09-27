# 3.7.5 Generate Image

| | |
|---|---|
| FR Code | 3.7.5 |
| Feature | Generate Commercial & Social Image (FLUX.2 Async Pipeline) |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR (thuộc Workspace / Agency) |
| Routes | `POST /api/v1/workspaces/{workspaceId}/ai/images/generate`<br>`GET /api/v1/workspaces/{workspaceId}/ai/images/jobs/{jobId}`<br>`GET /api/v1/workspaces/{workspaceId}/ai/images/jobs/{jobId}/events` (SSE)<br>`POST /api/v1/workspaces/{workspaceId}/ai/images/jobs/{jobId}/cancel`<br>`POST /api/v1/workspaces/{workspaceId}/ai/images/apply`<br>`POST /internal/ai/image/generate-async` (ai-service)<br>`GET /internal/ai/image/jobs/{jobId}` (ai-service) |
| Related FRs | 3.7.3 Generate Ambassador, 3.7.4 View Image Style Template, 3.6.1 Create Content Task, 3.6.35 View Content History, 3.7.8 Export File, 3.9.5 View AI Credit Tracking |
| Document status | Target Spec |
| Implementation status | In Progress (FLUX.2 Async Queue & Credit Lifecycle Migration) |

## Function Trigger
Begins when a Creator inside a Content Task (type Post) or the Image Studio (`/workspaces/:workspaceId/ai/generate-image`) configures prompt, aspect ratio, variants (1–4), optional Ambassador, optional Style Template, and optional Brand Materials, then clicks "Generate Image".

## Function Description
- **Actors / Roles:** CREATOR (holding active Workspace membership, assigned to the Content Task or operating in the Studio, with sufficient AI credits).
- **Purpose:** Provide high-fidelity, commercially viable image generation powered exclusively by the FLUX.2 foundation pipeline. The system synthesizes four distinct input sources (User Creative Prompt + Ambassador Canonical Reference + Style Template Modifiers + Brand Material Assets) into an asynchronous multi-conditioning generation queue, delivering production-ready visual assets without connection timeouts or browser blocking.
- **Interface:** Studio Screen & Task Sidebar Drawer (`GenerateImageStudio.tsx` and `TaskImageDrawer.tsx`):
  - Left Control Panel: Creative prompt textarea, Negative prompt accordion, Aspect ratio radio cards (`1:1`, `16:9`, `9:16`, `4:5`), Variants slider (1–4 images), Ambassador selector drawer, Style Template picker button, Brand Material picker (S3 asset selector from Material Repository), and Credit Cost breakdown badge.
  - Right Results Board: Real-time progress bar with SSE/polling status (`QUEUED` -> `PREPARING_REFERENCES` -> `SYNTHESIZING_FLUX2` -> `QUALITY_ASSURANCE` -> `READY`), batch variant cards (zoom lightbox, face similarity QA badge, download action), "Apply to Task Content Version", and "Save to Material Repository" actions.
- **Data Processing:**
  1. The Business Service validates tenant permissions, checks Creator quotas, and atomically reserves AI credits (`variantsCount * unitCredit`) on the Agency ledger (`ai_credit_ledgers`).
  2. Dispatches an async generation task to the AI Service queue (`POST /internal/ai/image/generate-async`), returning HTTP 202 Accepted with a `jobId`.
  3. The AI Service constructs the conditioning pipeline: parses user prompt, prepends/appends Style Template tokens, resolves the Ambassador's Canonical Reference portrait from S3 (if specified), injects brand product reference embeddings, and schedules parallel FLUX.2 inference runs on GPU workers.
  4. Upon worker completion, generated images are uploaded to durable S3 storage, face consistency scores are calculated against the Canonical Reference, and job status is updated to `COMPLETED`, `PARTIAL_SUCCESS`, or `FAILED`.
  5. The Business Service settles credits (`SETTLE`) strictly for the number of successful variants, and immediately releases (`RELEASE`) credits for failed variants or cancelled jobs.
  6. The Creator reviews variants, selecting one or more images to apply to the Content Task or save to the Material Repository.

## Screen Layout
Figure — Generate Image Studio (`GenerateImageStudio.tsx`, route `/workspaces/:workspaceId/ai/generate-image` or embedded in Task Detail):
- **Header:** Navigation breadcrumb `Workspace / AI Studio / Generate Image`, Context badge (e.g., `Task: Post #T-204 - Ra mắt Serum`), and Credit quota widget showing available balance and unit cost.
- **Left Panel (Generation Control Panel):**
  - Prompt Editor (`PromptInputBox`, textarea, placeholder `Mô tả bối cảnh, sản phẩm, ánh sáng, góc chụp...`, max 2000 chars, character counter, AI prompt enhancement toggle).
  - Negative Prompt Accordion (Expandable, placeholder `Các chi tiết không mong muốn: text, watermark, blurry, deformed limbs...`, max 500 chars).
  - Ambassador Selector (`AmbassadorPickerComponent`):
    - Shows selected Ambassador avatar thumbnail and name (e.g., `Maya Linh`) or a "+ Chọn Virtual Ambassador" button opening a quick-select drawer.
    - "Bỏ chọn" link to remove Ambassador conditioning.
  - Style Template Selector (`StylePickerButton`):
    - Displays active style badge (e.g., `Commercial Clean Studio`) with thumbnail, or "Chọn phong cách (Tùy chọn)" opening FR 3.7.4 catalog drawer.
  - Brand Reference Materials (`MaterialAttachmentBox`):
    - Mini asset tray showing up to 3 attached product/brand images loaded from the Workspace Material Repository.
  - Aspect Ratio Selector (`AspectRatioRadioGroup`):
    - 4 visual ratio cards with proportional icon outlines:
      - `1:1` (Square - 1024x1024 px, Instagram / Facebook Feed)
      - `4:5` (Vertical Feed - 896x1120 px, Instagram Portrait)
      - `9:16` (Story & Reels - 768x1344 px, TikTok / IG Stories)
      - `16:9` (Landscape - 1344x768 px, YouTube / Website Banner)
  - Variants Count Selector (`VariantSlider`):
    - Segmented selector: `1`, `2`, `3`, `4` variants (Default: `3`).
  - Credit Estimate Banner:
    - Summary text: `Chi phí: N credits (1 credit/ảnh). Chỉ trừ khi ảnh sinh thành công.`
  - Action Footer:
    - Primary CTA: "Tạo ảnh với AI" (`GenerateButton`, shows loading state when in flight, disabled when prompt is empty or credit is insufficient).
- **Right Panel (Output Board):**
  - Initial State: Visual empty state illustration with sample gallery prompts.
  - Queued / Generating State: Progress banner displaying step description, elapsed seconds, estimated remaining time, and an active "Hủy tác vụ" (Cancel Job) button (available only in `PENDING` state).
  - Results Grid:
    - 2x2 responsive card grid displaying generated variant images.
    - Card Overlay: Zoom icon (opens full-resolution lightbox), aspect ratio tag, download button, and Face QA status badge (`PASS: 0.88`, `WARNING: 0.78`, or hidden if no Ambassador used).
  - Primary Action Drawer / Bar (Enabled when at least 1 variant is selected):
    - "Áp dụng vào Task" (`ApplyToTaskButton`): Embeds selected image into the current Task Content Version.
    - "Lưu vào Material Repository" (`SaveToMaterialButton`): Saves image permanently to selected Workspace folder.
    - "Tạo lại (Regenerate)" button: Clones parameters into form and prompts for a new generation run.

## Function Details
### Data Specifications
- **Input required:**
  - `workspaceId` (UUID, path parameter).
  - `prompt` (string, 10–2000 chars, user descriptive prompt).
  - `aspectRatio` (enum: `RATIO_1_1`, `RATIO_16_9`, `RATIO_9_16`, `RATIO_4_5`).
  - `variants` (integer, range: 1–4, default: 3).
- **Input optional:**
  - `taskId` (UUID, associated Content Task).
  - `negativePrompt` (string, max 500 chars).
  - `ambassadorId` (UUID, references virtual ambassador created in FR 3.7.3).
  - `styleTemplateId` (UUID, references style template from FR 3.7.4).
  - `referenceMaterialIds` (array of UUIDs, max 3 items, representing product photos or brand assets in Material Repository).
  - `seed` (integer, optional explicit reproduction seed).
- **System data:**
  - `jobId` (UUID, generated at submission, Redis TTL 24h).
  - `userId`, `agencyId`, `workspaceId` (resolved from authenticated JWT session).
  - `reservedCredits` (integer, `variants * 1`).
  - `settledCredits` (integer, count of successful variants).
  - `releasedCredits` (integer, `reservedCredits - settledCredits`).
  - `queueStatus` (enum: `PENDING`, `PROCESSING`, `COMPLETED`, `PARTIAL_SUCCESS`, `FAILED`, `CANCELLED`).
- **Output:**
  - Submission Response: HTTP 202 Accepted with `jobId`, `status`, `reservedCredits`, `pollingUrl`, `sseUrl`, `estimatedSeconds`.
  - Polling / SSE Result: `jobId`, `status`, `progressPercent`, `completedVariants`, `totalVariants`, `variants: [{ variantIndex, imageUrl, s3Key, resolution: { width, height }, aspectRatio, seed, qaMetrics: { faceSimilarityScore, status } }]`, `credits: { reserved, settled, released }`.

### Business Rules
- **BR-AI-21: 100% Asynchronous Execution Pattern:** All image generation requests MUST be processed asynchronously. The Business Service validates the request, enqueues the job, and immediately returns HTTP 202 Accepted with a `jobId`. Synchronous blocking connections exceeding 5 seconds are strictly prohibited. The frontend monitors progress via SSE stream (`GET .../jobs/{jobId}/events`) or HTTP polling (`GET .../jobs/{jobId}`) at 2-second intervals.
- **BR-AI-22: Atomic Credit Reservation, Partial Settlement, and Auto-Release:**
  - Upon job submission, the system atomically reserves `N` credits (`variants * 1 credit`) from the Agency balance.
  - When the job concludes:
    - If all `N` variants succeed: status is `COMPLETED`, all `N` credits transition to `SETTLE`.
    - If `M` variants succeed and `N - M` fail: status is `PARTIAL_SUCCESS`, `M` credits transition to `SETTLE`, and `N - M` credits are immediately `RELEASE`d to the Agency balance.
    - If all variants fail or the job times out (>180s): status is `FAILED`, 100% of reserved credits are `RELEASE`d.
- **BR-AI-23: Technical Retries vs. User Regenerate:**
  - If a worker encounters an internal transient GPU error, the AI Service executes an automatic internal retry (max 1 retry, backoff 2s) within the same job context at ZERO additional credit cost.
  - If the user explicitly clicks "Tạo lại" (Regenerate) from the UI, this constitutes a distinct new request requiring a separate credit reservation.
- **BR-AI-24: 4-Source Conditioning Pipeline for FLUX.2:**
  - The generation prompt is orchestrated server-side by concatenating: `[Style Template Prefix] + [User Creative Prompt] + [Ambassador Identity Framing] + [Style Template Suffix]`.
  - When `ambassadorId` is present, the AI Service automatically loads the Ambassador's Canonical Reference portrait from S3 and injects it into FLUX.2 multi-reference attention. SDXL IP-Adapter and LoRA swapping are obsolete.
  - When `referenceMaterialIds` are provided, the AI Service loads up to 3 product/brand images to condition product shape and texture.
- **BR-AI-25: Supported Aspect Ratios & Exact Dimension Mapping:**
  - `RATIO_1_1`: 1024 × 1024 px.
  - `RATIO_16_9`: 1344 × 768 px.
  - `RATIO_9_16`: 768 × 1344 px.
  - `RATIO_4_5`: 896 × 1120 px.
  All outputs are rendered at native resolution matching these exact pixel dimensions.
- **BR-AI-26: QA Consistency & Face Similarity Scoring:**
  - When generating with an `ambassadorId`, the system runs an automated facial similarity verification against the Ambassador's Canonical Reference:
    - `PASS`: Face similarity score ≥ 0.85 (High identity confidence).
    - `WARNING`: Face similarity score 0.75 – 0.84 (Visual discrepancy warning flag displayed in UI, image is still delivered and settled).
    - `FAIL`: Face similarity score < 0.75 or no face detected (Variant is marked failed, credit released, and not delivered).
  - When generating without an Ambassador, face similarity scoring is bypassed.
- **BR-AI-27: Asset Reuse Immutability:** Once generated and settled, applying the image to a Content Task (`POST .../apply`), downloading it via Export (FR 3.7.8), or viewing it in Content History (FR 3.6.35) NEVER consumes additional credits.
- **BR-AI-28: Queue TTL & Cancellation Policy:**
  - Unclaimed jobs in `PENDING` state can be cancelled by the Creator via `POST .../jobs/{jobId}/cancel`, releasing 100% of reserved credits.
  - Once a job transitions to `PROCESSING`, cancellation is disabled.
  - Completed and failed job results are retained in Redis for 24 hours. Permanent asset references reside in S3 and database tables.

### Validation & Error Messages
- `workspaceId` unauthorized or user role not CREATOR/ADMIN → HTTP 403, Display: **MSG-AI-21** ("Bạn không có quyền tạo ảnh trong Workspace này.")
- Insufficient AI credit balance to reserve `N` variants → HTTP 402, Display: **MSG-AI-22** ("Số dư AI Credit không đủ để tạo {N} ảnh. Vui lòng nạp thêm credit hoặc giảm số biến thể.")
- `prompt` is empty or less than 10 characters → HTTP 400, Display: **MSG-AI-23** ("Vui lòng nhập mô tả ảnh có ít nhất 10 ký tự.")
- `prompt` exceeds 2000 characters → HTTP 400, Display: **MSG-AI-24** ("Mô tả ảnh không được vượt quá 2000 ký tự.")
- `prompt` rejected by content moderation safety filter → HTTP 400, Display: **MSG-AI-25** ("Nội dung mô tả vi phạm chính sách an toàn nội dung. Vui lòng chỉnh sửa lại.")
- `aspectRatio` value not supported → HTTP 400, Display: **MSG-AI-26** ("Tỉ lệ khung hình không hợp lệ. Hỗ trợ: 1:1, 16:9, 9:16, 4:5.")
- `variants` count not in range [1, 4] → HTTP 400, Display: **MSG-AI-27** ("Số lượng ảnh biến thể phải từ 1 đến 4.")
- `ambassadorId` does not exist or has been deleted (BR-AI-08) → HTTP 404, Display: **MSG-AI-28** ("Ambassador đã chọn không tồn tại hoặc đã bị xóa.")
- `styleTemplateId` is inactive or not found → HTTP 404, Display: **MSG-AI-29** ("Phong cách mẫu đã chọn không còn khả dụng.")
- `referenceMaterialIds` contains an asset not belonging to the Workspace → HTTP 403, Display: **MSG-AI-30** ("Tài liệu tham khảo không thuộc quyền quản lý của Workspace.")
- Job cancellation rejected because job is already `PROCESSING` or terminal → HTTP 409, Display: **MSG-AI-31** ("Không thể hủy tác vụ do hệ thống đang tiến hành sinh ảnh.")
- GPU cluster timeout (>180s) or unrecoverable inference error → HTTP 504, Display: **MSG-AI-32** ("Quá trình sinh ảnh thất bại do sự cố kỹ thuật. Toàn bộ credit đã được hoàn trả.")

## API Contracts & DTOs
### 1. Submit Image Generation Job
`POST /api/v1/workspaces/{workspaceId}/ai/images/generate`
```json
// Request Body
{
  "taskId": "7a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d", // Optional Content Task UUID
  "prompt": "Commercial studio shot of a luxury vitamin C facial serum bottle on a wet marble pedestal, delicate water ripples, tropical palm leaf shadows, morning sunlight, ultra realistic, 8k",
  "negativePrompt": "watermark, label distortion, blurry, cheap plastic, grain",
  "aspectRatio": "RATIO_1_1", // "RATIO_1_1" | "RATIO_16_9" | "RATIO_9_16" | "RATIO_4_5"
  "variants": 3, // 1 to 4
  "ambassadorId": "amb_8871234a-9901-4bcd-8ef0-123456789abc", // Optional
  "styleTemplateId": "7f8b3c10-1a2b-4c3d-8e4f-5a6b7c8d9e0f", // Optional
  "referenceMaterialIds": [
    "mat_product_bottle_front_01",
    "mat_brand_logo_stamp_02"
  ],
  "seed": null
}

// Response: 202 Accepted
{
  "success": true,
  "data": {
    "jobId": "img_job_99887766-5544-3322-1100-aabbccddeeff",
    "status": "PENDING",
    "variantsCount": 3,
    "reservedCredits": 3,
    "pollingUrl": "/api/v1/workspaces/w-101/ai/images/jobs/img_job_99887766-5544-3322-1100-aabbccddeeff",
    "sseUrl": "/api/v1/workspaces/w-101/ai/images/jobs/img_job_99887766-5544-3322-1100-aabbccddeeff/events",
    "estimatedSeconds": 20
  }
}
```

### 2. Poll Image Job Status
`GET /api/v1/workspaces/{workspaceId}/ai/images/jobs/{jobId}`
```json
// Response: 200 OK (Completed State with Partial/Full Success)
{
  "success": true,
  "data": {
    "jobId": "img_job_99887766-5544-3322-1100-aabbccddeeff",
    "status": "COMPLETED", // "PENDING" | "PROCESSING" | "COMPLETED" | "PARTIAL_SUCCESS" | "FAILED" | "CANCELLED"
    "progressPercent": 100,
    "completedVariants": 3,
    "totalVariants": 3,
    "results": [
      {
        "variantIndex": 0,
        "imageUrl": "https://s3.brandhub.io/workspaces/w-101/generated-images/img_job_998/var_0.png",
        "s3Key": "workspaces/w-101/generated-images/img_job_998/var_0.png",
        "resolution": {
          "width": 1024,
          "height": 1024
        },
        "aspectRatio": "RATIO_1_1",
        "seed": 45192038,
        "qaMetrics": {
          "faceSimilarityScore": 0.89,
          "status": "PASS"
        }
      },
      {
        "variantIndex": 1,
        "imageUrl": "https://s3.brandhub.io/workspaces/w-101/generated-images/img_job_998/var_1.png",
        "s3Key": "workspaces/w-101/generated-images/img_job_998/var_1.png",
        "resolution": {
          "width": 1024,
          "height": 1024
        },
        "aspectRatio": "RATIO_1_1",
        "seed": 45192039,
        "qaMetrics": {
          "faceSimilarityScore": 0.87,
          "status": "PASS"
        }
      },
      {
        "variantIndex": 2,
        "imageUrl": "https://s3.brandhub.io/workspaces/w-101/generated-images/img_job_998/var_2.png",
        "s3Key": "workspaces/w-101/generated-images/img_job_998/var_2.png",
        "resolution": {
          "width": 1024,
          "height": 1024
        },
        "aspectRatio": "RATIO_1_1",
        "seed": 45192040,
        "qaMetrics": {
          "faceSimilarityScore": 0.81,
          "status": "WARNING"
        }
      }
    ],
    "credits": {
      "reserved": 3,
      "settled": 3,
      "released": 0
    },
    "createdAt": "2026-09-27T09:20:00Z",
    "completedAt": "2026-09-27T09:20:18Z"
  }
}
```

### 3. Cancel Queued Job
`POST /api/v1/workspaces/{workspaceId}/ai/images/jobs/{jobId}/cancel`
```json
// Response: 200 OK
{
  "success": true,
  "data": {
    "jobId": "img_job_99887766-5544-3322-1100-aabbccddeeff",
    "status": "CANCELLED",
    "releasedCredits": 3,
    "message": "Tác vụ đã được hủy thành công. Toàn bộ credit đã được hoàn trả."
  }
}
```

### 4. Apply Generated Image to Task or Material Repository
`POST /api/v1/workspaces/{workspaceId}/ai/images/apply`
```json
// Request Body
{
  "taskId": "7a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d",
  "imageS3Key": "workspaces/w-101/generated-images/img_job_998/var_0.png",
  "target": "TASK_CONTENT_VERSION", // "TASK_CONTENT_VERSION" | "MATERIAL_REPOSITORY"
  "targetFolderId": "fld_skincare_campaign_2026" // Required if target == MATERIAL_REPOSITORY
}

// Response: 200 OK
{
  "success": true,
  "data": {
    "applied": true,
    "taskVersionId": "ver_0987-6543-2109",
    "materialAssetId": "mat_asset_5566-7788",
    "assetUrl": "https://s3.brandhub.io/workspaces/w-101/generated-images/img_job_998/var_0.png",
    "appliedAt": "2026-09-27T09:21:00Z"
  }
}
```

## Functionalities
### Normal Flow
1. The Creator opens the Image Generation Studio in a Workspace or clicks "Tạo ảnh AI" inside an active Content Task.
2. The Creator enters the descriptive prompt and optional negative prompt.
3. (Optional) The Creator selects an Ambassador from FR 3.7.3 to maintain brand face consistency.
4. (Optional) The Creator selects a Style Template from FR 3.7.4 to apply artistic parameters.
5. (Optional) The Creator selects up to 3 brand assets from the Material Repository.
6. The Creator selects the desired Aspect Ratio (`1:1`, `16:9`, `9:16`, `4:5`) and number of variants (1 to 4).
7. The Creator clicks "Tạo ảnh với AI".
8. The Business Service validates inputs, checks user quotas, and places an atomic hold (`RESERVE`) of `N` credits on the Agency ledger.
9. The Business Service posts the job payload to the AI Service queue (`POST /internal/ai/image/generate-async`) and immediately returns HTTP 202 Accepted with a `jobId`.
10. The UI displays the generation progress screen, establishing an SSE connection (`/jobs/{jobId}/events`) with polling fallback (`GET /jobs/{jobId}`).
11. The AI Service worker executes multi-reference FLUX.2 inference, uploads results to S3, and verifies face similarity.
12. The worker marks the job as `COMPLETED`. The Business Service transitions the reserved credits to `SETTLE`.
13. The frontend renders the generated variants in the Results Grid.
14. The Creator selects the best image variant and clicks "Áp dụng vào Task" or "Lưu vào Material Repository".
15. The system links the asset without further credit deduction, displaying toast MSG-AI-20 ("Áp dụng ảnh vào Task thành công").

### Abnormal Cases
- **8.a1:** Insufficient AI credits available on the Agency ledger or Creator limit reached (BR-AI-22) → HTTP 402 INSUFFICIENT_AI_CREDIT, toast MSG-AI-22. **8.a2:** The Creator reduces the variant count or requests a quota increase from the Agency Manager (FR 3.9.7).
- **8.b1:** Prompt violates content moderation policies (BR-AI-25) → HTTP 400 PROMPT_REJECTED, toast MSG-AI-25. **8.b2:** The Creator removes sensitive words and re-submits.
- **10.a1:** Creator changes their mind while the job is still queued (`status == PENDING`) and clicks "Hủy tác vụ" (BR-AI-28) → `POST .../jobs/{jobId}/cancel` returns 200 OK. **10.a2:** The job status updates to `CANCELLED`, 100% of reserved credits are immediately released, and the UI returns to the editing state.
- **11.a1:** Partial worker failure (e.g., 2 of 3 variants finish successfully, but 1 variant fails due to a transient worker GPU out-of-memory error) (BR-AI-22) → Job transitions to `PARTIAL_SUCCESS`. **11.a2:** The Business Service settles 2 credits, automatically releases 1 credit back to the ledger, and renders the 2 successful variants on screen with a partial completion notice.
- **11.b1:** Complete worker crash or queue timeout (>180s) (BR-AI-22) → Job transitions to `FAILED`, toast MSG-AI-32. **11.b2:** 100% of reserved credits are released; the UI presents a "Thử lại kỹ thuật" button (re-running the technical task without double-charging).
- **11.c1:** Ambassador face consistency test yields `WARNING` (0.75 – 0.84) (BR-AI-26) → The image is delivered with a yellow warning indicator advising the Creator that the face may have slight discrepancies. **11.c2:** The Creator can choose to accept the image or regenerate.
- **14.a1:** Browser tab is closed or internet connection drops during generation → The job continues processing in the background on the server. **14.a2:** Upon reopening the Task or Studio, the system detects the active `jobId` from local storage/backend task status, restores the completed images, and ensures credits were accurately settled without duplicate runs.

## Post-Conditions
- Generated images are securely stored in S3 under `workspaces/{workspaceId}/generated-images/{jobId}/`.
- Exact credits for successful variants are deducted (`SETTLE`) in `ai_credit_ledgers`.
- Unsuccessful variant credits are returned (`RELEASE`).
- When applied to a Content Task, a new draft Content Version is recorded with provenance metadata (seed, prompt, model: `FLUX.2`, parameters).
- When saved to the Material Repository, a permanent `MaterialAsset` record is created.

## Out of Scope
- Direct automatic publishing to Facebook/TikTok/Instagram (Publishing is governed by FR 3.8.x and requires explicit task approval in FR 3.6.9).
- Canvas inpainting, localized object replacement, or lasso-based retouching.
- Video generation from static images (Governed by FR 3.7.7 Generate Video).

## References
- Architecture & Alignment: [docs/plan/ai-features-spec-alignment-plan.md](../../plan/ai-features-spec-alignment-plan.md) (PO decisions D01, D06, D12).
- BA Specification: [docs/ba/06-ai-features.md](../../ba/06-ai-features.md) (UC-77 Generate Image).
- Service Contracts: [docs/architecture/business-ai-rest-contract.md](../../architecture/business-ai-rest-contract.md).
- Related Features: FR 3.7.3 Generate Ambassador, FR 3.7.4 View Image Style Template, FR 3.6.1 Create Content Task, FR 3.7.8 Export File.
