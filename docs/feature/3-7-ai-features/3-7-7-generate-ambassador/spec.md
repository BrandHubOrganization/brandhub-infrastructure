# 3.7.3 Generate Ambassador

| | |
|---|---|
| FR Code | 3.7.3 |
| Feature | Generate Virtual Brand Ambassador (Self-Service Identity Creation) |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR (thuộc Workspace / Agency) |
| Routes | `POST /api/v1/workspaces/{workspaceId}/ai/ambassadors/generate`<br>`GET /api/v1/workspaces/{workspaceId}/ai/ambassadors/jobs/{jobId}`<br>`POST /api/v1/workspaces/{workspaceId}/ai/ambassadors/confirm`<br>`GET /api/v1/workspaces/{workspaceId}/ai/ambassadors`<br>`GET /api/v1/workspaces/{workspaceId}/ai/ambassadors/{ambassadorId}`<br>`DELETE /api/v1/workspaces/{workspaceId}/ai/ambassadors/{ambassadorId}`<br>`POST /internal/ai/ambassador/generate` (ai-service) |
| Related FRs | 3.7.4 View Image Style Template, 3.7.5 Generate Image, 3.7.7 Generate Video, 3.5.1 Create Media Package (Material Repository), 3.9.5 View AI Credit Tracking |
| Document status | Target Spec |
| Implementation status | In Progress (FLUX.2 Self-Service identity pipeline & Canonical Reference storage) |

## Function Trigger
Begins when a Creator inside a Workspace opens the Ambassador Studio (`/workspaces/:workspaceId/ai/ambassador`), configures appearance prompts or uploads a reference portrait, and clicks "Generate Candidates" to create a new virtual brand ambassador.

## Function Description
- **Actors / Roles:** CREATOR (holding active Workspace membership with allocated AI credit quota).
- **Purpose:** Self-service creation of a persistent virtual brand ambassador without requiring prior LoRA fine-tuning. The user generates 1–4 facial candidate variants using FLUX.2, selects the preferred face, and the system persists it as the "Canonical Reference" portrait in the Workspace Material Repository (type `AMBASSADOR`). This Canonical Reference serves as the single source of truth for facial identity consistency across subsequent image generation (FR 3.7.5) and video generation (FR 3.7.7) workflows.
- **Interface:** Ambassador Studio screen (`AmbassadorStudioPage.tsx`, route `/workspaces/:workspaceId/ai/ambassador`): split view with Creation Parameters on the left (Mode switcher, Prompt editor, Demographics selectors, Reference portrait uploader, Style template picker, Variants slider) and Candidate Inspection Board on the right (Job progress indicator, 1–4 candidate cards with zoom/lightbox, Face validation badge, "Confirm & Save Ambassador" modal).
- **Data Processing:**
  1. The Business Service validates tenant context, Creator limits, and content guardrails; executes an atomic reservation of AI credits (`variantsCount × unitCredit`) against the Agency ledger.
  2. Dispatches an async generation job to the AI Service FLUX.2 pipeline (`POST /internal/ai/ambassador/generate`) and returns HTTP 202 Accepted with a `jobId`.
  3. The AI Service runs FLUX.2 conditioned on prompt text and optional reference image embeddings, returning generated candidate portraits.
  4. The Creator selects a candidate; the Business Service settles credits for the generated variants, saves the chosen portrait to S3 (`workspaces/{workspaceId}/materials/ambassadors/{ambassadorId}/canonical.png`), registers the asset in the Material Repository, creates the `Ambassador` record, and marks it active for zero-credit-cost reuse.

## Screen Layout
Figure — Ambassador Studio Screen (`AmbassadorStudioPage.tsx`, route `/workspaces/:workspaceId/ai/ambassador`):
- **Header:** Breadcrumb `Workspace / AI Studio / Virtual Ambassador`, Credit balance widget displaying available credits, and a "Saved Ambassadors" tab button navigating to `/workspaces/:workspaceId/ai/ambassadors/gallery`.
- **Left Panel (Configuration Form):**
  - Mode Selection Tabs: `Text-to-Ambassador` (Default) vs. `Portrait Reference-to-Ambassador`.
  - Ambassador Basic Info: Name input (`AmbassadorNameInput`, placeholder `e.g. Maya - Tech Brand Voice`, max 100 chars).
  - Trait & Demographic Selectors (Accordion or Dropdown grid):
    - Gender (`FEMALE`, `MALE`, `NON_BINARY`).
    - Age Range (`18-24`, `25-34`, `35-44`, `45+`).
    - Ethnicity / Regional Tone (Text input with suggested chips: `East Asian`, `Southeast Asian`, `Caucasian`, `Latino`, `African`, etc.).
  - Prompt Editor (`PromptTextArea`, placeholder `Mô tả chi tiết ngoại hình, kiểu tóc, biểu cảm, trang phục, phong cách ánh sáng...`, max 1000 chars, character counter).
  - Reference Portrait Upload Box (Visible only in `Portrait Reference-to-Ambassador` mode): Drag & drop area accepting PNG/JPEG/WEBP (max 10MB), automated client-side aspect ratio check, and thumbnail preview with remove button.
  - Style Template Selector (Optional): Dropdown linking to FR 3.7.4 Style Templates with quick thumbnail preview.
  - Variant Count Selector: Radio pill group (`1`, `2`, `3`, `4` variants, default: `4`).
  - Cost Breakdown Box: Displays `Reserved Credits: N credits` and a policy reminder `Credit được trừ theo số ảnh sinh thành công; tái sử dụng Ambassador đã lưu là 0 credit`.
  - Primary Action Button: "Generate Candidates" (Triggers HTTP 202; disabled when form is invalid or credit is insufficient).
- **Right Panel (Candidate Inspection Board):**
  - Empty State: Illustrated placeholder explaining the self-service canonical reference workflow.
  - In-Progress State: Animated radial progress spinner with step status (`Queueing` -> `Synthesizing Face with FLUX.2` -> `Evaluating Quality`), cancel button (active only while job status is `PENDING`), and elapsed time counter.
  - Results State: Responsive 2x2 grid displaying generated candidate portraits:
    - Candidate Card: High-resolution image preview, zoom button (opens lightbox), face quality status badge (`PASS`), and "Select as Canonical Face" radio selector.
    - Footer Actions: "Regenerate" button (triggers a new job with new credit charge) and "Confirm & Save Ambassador" button (enabled when exactly 1 candidate is selected).
- **Save Confirmation Modal (`SaveAmbassadorModal.tsx`):**
  - Displays selected portrait, confirmed Ambassador name, auto-generated unique ID, Material Repository target folder (`Root / Virtual Ambassadors`), and "Confirm Save" button. Shows toast MSG-AI-06 on success and redirects to Ambassador details or Image Generation Studio.

## Function Details
### Data Specifications
- **Input required:**
  - `workspaceId` (UUID in URL path, resolved from user context).
  - `name` (string, 1–100 chars, unique within Workspace).
  - `mode` (enum: `TEXT_PROMPT` | `REFERENCE_PORTRAIT`).
  - `prompt` (string, 10–1000 chars).
  - `variants` (integer, range: 1–4, default: 4).
  - `referenceAssetId` or multipart file `referenceImage` (required only when `mode == REFERENCE_PORTRAIT`).
- **Input optional:**
  - `gender` (enum: `FEMALE`, `MALE`, `NON_BINARY`).
  - `ageRange` (enum: `AGE_18_24`, `AGE_25_34`, `AGE_35_44`, `AGE_45_PLUS`).
  - `ethnicity` (string, max 50 chars).
  - `styleTemplateId` (UUID, referencing FR 3.7.4).
  - `negativePrompt` (string, max 500 chars).
- **System data:**
  - `jobId` (UUID, tracked in Redis and database, TTL 24h).
  - `userId`, `agencyId`, `workspaceId` (extracted from authenticated JWT session).
  - `creditCostPerVariant` (system config: 1 credit per image variant).
  - `reservedCredits` (integer, `variants * creditCostPerVariant`).
  - `canonicalS3Key` (string, e.g., `workspaces/{workspaceId}/ambassadors/{ambassadorId}/canonical.png`).
- **Output:**
  - Async Job: `jobId`, `status`, `reservedCredits`, `pollingUrl`, `estimatedTimeSeconds`.
  - Job Result: array of candidate objects `[{ candidateIndex, imageUrl, s3Key, seed, faceQualityScore }]`.
  - Confirmed Ambassador: `ambassadorId`, `name`, `canonicalReferenceUrl`, `materialAssetId`, `mode`, `status`, `createdAt`.

### Business Rules
- **BR-AI-01: Workspace & Agency Multi-Tenant Isolation:** Ambassador identities, candidate jobs, and canonical reference assets belong strictly to the active `workspaceId`. A Creator cannot view, use, or select Ambassadors from another Workspace or Agency.
- **BR-AI-02: Self-Service Identity Creation (Zero Prior LoRA Training):** Creation of virtual brand ambassadors is on-demand and self-service. The system utilizes FLUX.2 zero-shot / reference-conditioned generation. Creators are NOT required to train a dedicated LoRA model or wait for offline model training before using the ambassador.
- **BR-AI-03: Dual Creation Modes:**
  - `TEXT_PROMPT`: Generates faces purely from descriptive text prompts and demographic parameters. The generated candidates have no prior face similarity baseline; quality inspection evaluates single-face clarity and absence of artifacts.
  - `REFERENCE_PORTRAIT`: Uses a creator-uploaded portrait as structural reference for FLUX.2. Input image must pass facial detection validation (exactly one clear frontal/three-quarter face).
- **BR-AI-04: Canonical Reference Persistence in Material Repository:** The single candidate selected by the Creator becomes the permanent "Canonical Reference" for this Ambassador. The image is saved to durable S3 storage and registered into the Workspace Material Repository with type `AMBASSADOR`. All subsequent downstream image (FR 3.7.5) and video (FR 3.7.7) generation tasks must load this exact canonical asset to maintain facial consistency.
- **BR-AI-05: Credit Lifecycle (Reserve -> Settle -> Release):**
  - When the generation job is initiated, Business Service checks the Creator's quota and places a hold (`RESERVE`) of `N` credits (`variants * 1`).
  - When candidates are generated successfully, the system transitions reserved credits to `SETTLE` for each successful image.
  - If any variant fails during inference, or if the entire job times out / crashes, the unproduced credits are immediately `RELEASE`d back to the ledger.
  - Confirming and saving the chosen candidate does NOT consume additional credits.
- **BR-AI-06: Zero-Cost Identity Reuse Policy:** Once an Ambassador is created and saved, querying, browsing, inspecting, or attaching `ambassadorId` to downstream image/video generation requests consumes 0 credits for the Ambassador itself. Credits in downstream features are charged only for the new image/video generation output.
- **BR-AI-07: Face Quality & Single-Face Constraint:**
  - For `REFERENCE_PORTRAIT` mode, the uploaded image must contain exactly one detectable human face. Images with no face or multiple faces are rejected immediately with HTTP 400.
  - FLUX.2 generated candidates are passed through automated QA verification: candidate images containing distorted anatomy, zero detectable faces, or multiple faces are flagged as `QUALITY_WARNING`.
- **BR-AI-08: Soft Deletion & Task Dependency Integrity:** Deleting an Ambassador sets its status to `DEPRECATED` / `DELETED`. Existing Content Tasks and published posts that previously utilized the Ambassador retain historical asset links and canonical snapshots, but new generation tasks cannot select a deleted Ambassador.

### Validation & Error Messages
- `workspaceId` invalid or unauthorized → HTTP 403, Display: **MSG-AI-01** ("Bạn không có quyền truy cập Workspace này.")
- Insufficient AI credit balance to reserve `N` variants → HTTP 402, Display: **MSG-AI-02** ("Số dư AI Credit không đủ để tạo {N} ảnh mẫu Ambassador. Vui lòng nạp thêm credit.")
- `name` empty or exceeds 100 characters → HTTP 400, Display: **MSG-AI-03** ("Tên Ambassador là bắt buộc và không quá 100 ký tự.")
- `name` already exists within the same Workspace → HTTP 409, Display: **MSG-AI-04** ("Tên Ambassador đã tồn tại trong Workspace. Vui lòng chọn tên khác.")
- `prompt` empty or less than 10 characters → HTTP 400, Display: **MSG-AI-05** ("Mô tả Ambassador phải có ít nhất 10 ký tự.")
- `prompt` violates content safety / NSFW / impersonation guardrails → HTTP 400, Display: **MSG-AI-06** ("Mô tả chứa từ khóa vi phạm chính sách an toàn nội dung.")
- `REFERENCE_PORTRAIT` mode uploaded file is missing or not a valid image (PNG/JPEG/WEBP) → HTTP 400, Display: **MSG-AI-07** ("Tệp ảnh chân dung tham chiếu không hợp lệ hoặc vượt quá 10MB.")
- `REFERENCE_PORTRAIT` image has no detectable face or multiple faces detected → HTTP 422, Display: **MSG-AI-08** ("Ảnh chân dung phải chứa duy nhất 1 khuôn mặt rõ nét.")
- Selected candidate index invalid or candidate expired → HTTP 400, Display: **MSG-AI-09** ("Mẫu ứng viên được chọn không hợp lệ hoặc phiên làm việc đã hết hạn.")
- Upstream FLUX.2 worker failure or queue timeout (>180s) → HTTP 504, Display: **MSG-AI-10** ("Hệ thống AI xử lý quá thời gian quy định. Credit đã được hoàn trả tự động.")

## API Contracts & DTOs
### 1. Generate Ambassador Candidates
`POST /api/v1/workspaces/{workspaceId}/ai/ambassadors/generate`
```json
// Request Body
{
  "name": "Maya Linh",
  "mode": "TEXT_PROMPT", // "TEXT_PROMPT" | "REFERENCE_PORTRAIT"
  "prompt": "Portrait of a 24-year-old Vietnamese female brand ambassador, modern professional look, confident smile, clean studio lighting, 8k resolution, elegant beige blazer",
  "gender": "FEMALE",
  "ageRange": "AGE_18_24",
  "ethnicity": "Southeast Asian",
  "styleTemplateId": "7f8b3c10-1a2b-4c3d-8e4f-5a6b7c8d9e0f", // Optional
  "referenceAssetId": null, // Required if mode == REFERENCE_PORTRAIT
  "variants": 4, // 1 to 4
  "negativePrompt": "blurry, distorted face, extra limbs, bad eyes, cartoon, low quality"
}

// Response: 202 Accepted
{
  "success": true,
  "data": {
    "jobId": "c4b12345-6789-4def-0123-456789abcdef",
    "status": "PENDING",
    "variantsCount": 4,
    "reservedCredits": 4,
    "pollingUrl": "/api/v1/workspaces/w-101/ai/ambassadors/jobs/c4b12345-6789-4def-0123-456789abcdef",
    "estimatedTimeSeconds": 25
  }
}
```

### 2. Poll Candidate Job Status
`GET /api/v1/workspaces/{workspaceId}/ai/ambassadors/jobs/{jobId}`
```json
// Response: 200 OK (Completed State)
{
  "success": true,
  "data": {
    "jobId": "c4b12345-6789-4def-0123-456789abcdef",
    "status": "COMPLETED", // "PENDING" | "PROCESSING" | "COMPLETED" | "FAILED"
    "progressPercent": 100,
    "candidates": [
      {
        "candidateIndex": 0,
        "imageUrl": "https://s3.brandhub.io/workspaces/w-101/ambassador-jobs/c4b/var_0.png",
        "s3Key": "workspaces/w-101/ambassador-jobs/c4b/var_0.png",
        "seed": 9871234,
        "qualityStatus": "PASS"
      },
      {
        "candidateIndex": 1,
        "imageUrl": "https://s3.brandhub.io/workspaces/w-101/ambassador-jobs/c4b/var_1.png",
        "s3Key": "workspaces/w-101/ambassador-jobs/c4b/var_1.png",
        "seed": 9871235,
        "qualityStatus": "PASS"
      },
      {
        "candidateIndex": 2,
        "imageUrl": "https://s3.brandhub.io/workspaces/w-101/ambassador-jobs/c4b/var_2.png",
        "s3Key": "workspaces/w-101/ambassador-jobs/c4b/var_2.png",
        "seed": 9871236,
        "qualityStatus": "PASS"
      },
      {
        "candidateIndex": 3,
        "imageUrl": "https://s3.brandhub.io/workspaces/w-101/ambassador-jobs/c4b/var_3.png",
        "s3Key": "workspaces/w-101/ambassador-jobs/c4b/var_3.png",
        "seed": 9871237,
        "qualityStatus": "PASS"
      }
    ],
    "credits": {
      "reserved": 4,
      "settled": 4,
      "released": 0
    },
    "createdAt": "2026-09-27T09:15:00Z",
    "completedAt": "2026-09-27T09:15:22Z"
  }
}
```

### 3. Confirm & Save Selected Candidate
`POST /api/v1/workspaces/{workspaceId}/ai/ambassadors/confirm`
```json
// Request Body
{
  "jobId": "c4b12345-6789-4def-0123-456789abcdef",
  "selectedCandidateIndex": 1,
  "name": "Maya Linh",
  "description": "Virtual Ambassador chính thức cho chiến dịch Ra mắt dòng sản phẩm Skincare 2026",
  "tags": ["skincare", "modern", "female", "youth"]
}

// Response: 201 Created
{
  "success": true,
  "data": {
    "ambassadorId": "amb_8871234a-9901-4bcd-8ef0-123456789abc",
    "name": "Maya Linh",
    "canonicalReferenceUrl": "https://s3.brandhub.io/workspaces/w-101/materials/ambassadors/amb_8871234a/canonical.png",
    "materialAssetId": "mat_44123-5566-7788",
    "status": "ACTIVE",
    "reusable": true,
    "createdAt": "2026-09-27T09:16:05Z"
  }
}
```

### 4. Internal AI Service Contract
`POST /internal/ai/ambassador/generate` (Header: `X-Internal-Api-Key`)
```json
// Internal Request Payload
{
  "jobId": "c4b12345-6789-4def-0123-456789abcdef",
  "workspaceId": "w-101",
  "model": "flux.2",
  "prompt": "Portrait of a 24-year-old Vietnamese female brand ambassador...",
  "negativePrompt": "blurry, distorted...",
  "variants": 4,
  "mode": "TEXT_PROMPT",
  "referenceImageUrl": null,
  "callbackUrl": "http://business-service:8081/internal/ai/ambassador/callback"
}
```

## Functionalities
### Normal Flow
1. The Creator opens `/workspaces/:workspaceId/ai/ambassador` and chooses the creation mode (`TEXT_PROMPT` or `REFERENCE_PORTRAIT`).
2. The Creator enters the Ambassador's name, demographic parameters, visual prompt, and selects the number of candidate variants (1 to 4).
3. The Creator clicks "Generate Candidates".
4. The Business Service validates inputs, checks tenant permissions, and atomically reserves `variantsCount` credits from the Agency ledger.
5. The Business Service dispatches the inference task to the AI Service FLUX.2 pipeline and returns HTTP 202 Accepted with a `jobId` and estimated duration.
6. The frontend begins polling `GET .../ai/ambassadors/jobs/{jobId}` every 2 seconds, displaying progress state to the user.
7. Upon job completion, the frontend renders the 1–4 generated candidate portraits on the Candidate Inspection Board.
8. The Creator examines the candidates, clicks on the preferred portrait, and clicks "Confirm & Save Ambassador".
9. The Business Service copies the chosen candidate image to the permanent Canonical Reference location in S3, registers it as an asset in the Material Repository, creates the `Ambassador` record, settles the reserved credits, and returns HTTP 201 Created.
10. The UI shows toast notification MSG-AI-06 ("Lưu Ambassador thành công"), and redirects to the Ambassador details page where the ambassador is immediately ready for use in FR 3.7.5 and FR 3.7.7.

### Abnormal Cases
- **1.a1:** Creator has insufficient AI credits on the Agency ledger or exceeds their monthly creator limit (BR-AI-05) → HTTP 402 INSUFFICIENT_AI_CREDIT, toast MSG-AI-02. **1.a2:** The Creator requests the Agency Owner/Manager to purchase more credits or allocate a higher quota (FR 3.9.6 / 3.9.7).
- **2.a1:** Ambassador name already exists in the current Workspace (BR-AI-01) → HTTP 409 CONFLICT, field validation error MSG-AI-04. **2.a2:** Creator updates the name and re-submits.
- **2.b1:** Visual prompt contains prohibited keywords (NSFW, hate speech, political defamation) → HTTP 400 PROMPT_REJECTED, toast MSG-AI-06. **2.b2:** Creator edits the prompt to comply with content policies.
- **3.a1:** Creator selects `REFERENCE_PORTRAIT` mode but uploads a file with no human face detected (e.g., landscape, product photo) (BR-AI-07) → HTTP 422 UNPROCESSABLE_ENTITY, alert MSG-AI-08. **3.a2:** Creator replaces the image with a valid portrait containing a clear single face.
- **3.b1:** Creator uploads a photo containing multiple people (e.g., group photo) (BR-AI-07) → HTTP 422 UNPROCESSABLE_ENTITY, alert MSG-AI-08. **3.b2:** Creator crops or uploads an individual portrait.
- **5.a1:** Upstream AI Service FLUX.2 worker crashes or GPU queue exceeds timeout (>180s) (BR-AI-05) → Job status transitions to `FAILED`, HTTP 504 GATEWAY_TIMEOUT, toast MSG-AI-10. **5.a2:** Business Service automatically releases 100% of reserved credits back to the ledger; UI displays retry button without incurring duplicate charges.
- **5.b1:** Partial variant failure (e.g., 3 candidates generated successfully, 1 failed due to transient memory limits) → Job status transitions to `PARTIAL_SUCCESS`. **5.b2:** Business Service settles 3 credits, releases 1 credit back to the ledger; UI displays the 3 successful candidates for creator selection.
- **8.a1:** Creator is dissatisfied with all generated candidates and clicks "Regenerate" (BR-AI-05) → **8.a2:** The system initiates a brand-new generation request with a new credit reservation; previous candidates remain available for review until discarded or the session is refreshed.

## Post-Conditions
- A new `Ambassador` record is created in the database with status `ACTIVE`.
- The chosen portrait is durably saved in S3 under `workspaces/{workspaceId}/materials/ambassadors/{ambassadorId}/canonical.png`.
- The portrait is cataloged in the Material Repository (`materials` table, type `AMBASSADOR`) with full provenance metadata (seed, prompt, FLUX.2 parameters).
- The exact number of successfully generated candidates is deducted (`SETTLE`) from the AI credit ledger.
- The `ambassadorId` is immediately selectable in Generate Image (FR 3.7.5) and Generate Video (FR 3.7.7) without incurring identity training or lookup fees.

## Out of Scope
- Training custom LoRA weights or fine-tuning model checkpoints for individual ambassadors (FLUX.2 reference conditioning is used instead).
- Voice synthesis, speech generation, or lip-sync audio capabilities (Handled in Video / TTS pipelines).
- 3D avatar rigging or live motion capture streaming.
- Public marketplace publishing or sharing of ambassadors across unrelated Agencies.

## References
- Architecture & Alignment: [docs/plan/ai-features-spec-alignment-plan.md](../../plan/ai-features-spec-alignment-plan.md) (PO decisions D01, D04, D06).
- BA Specification: [docs/ba/06-ai-features.md](../../ba/06-ai-features.md) (UC-76 Virtual Ambassador).
- Service Contracts: [docs/architecture/business-ai-rest-contract.md](../../architecture/business-ai-rest-contract.md).
- Related Features: FR 3.7.4 View Image Style Template, FR 3.7.5 Generate Image, FR 3.7.7 Generate Video, FR 3.9.5 View AI Credit Tracking.
