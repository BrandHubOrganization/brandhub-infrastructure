# 3.7.11 Generate Livestream Script

| | |
|---|---|
| FR Code | 3.7.11 |
| Feature | Generate Livestream Script |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR |
| Version | 2.0 — 2026-09-27 — aligned with PO decisions: single LLM model, timeline segments structure (Intro -> Deal -> Minigame -> Closing), structured input form, preview & apply to FR 3.6.23 Write Livestream Script |
| Document status | Target Spec |
| Implementation status | Research-pending |

## Function Trigger

Begins when a Creator opens a Livestream Task in Task Management (`/workspaces/:workspaceId/tasks/:taskId?type=LIVESTREAM`), switches to the Script tab, and clicks the "AI Generate Script" button, or navigates directly to the Livestream Script Studio (`/workspaces/:workspaceId/ai/livestream-studio`).

## Function Description

- **Actors / Roles:** CREATOR (Workspace member assigned to content creation or livestream hosting).
- **Purpose:** Automatically generate a structured, broadcast-ready livestream script organized into sequential timeline segments (Intro/Hook → Product Showcase & Deal Pitch → Interactive Minigame/Q&A → Closing/Final Call) using a single fine-tuned/prompt-engineered LLM model. Provides spoken dialogue, visual/camera directions, host physical cues, and audience engagement triggers based on verified product data and promotional offers.
- **Interface:**
  - Structured Livestream Input Form (aligned with Section 2.8 of Alignment Plan):
    - `topic` / `idea` (prefilled from Task Livestream Idea FR 3.6.22 if available).
    - `goal` (Sales, Product Launch, Brand Awareness, Q&A, Tutorial).
    - `targetAudience` (Target demographic, pain points, buyer persona).
    - `durationMinutes` (Target total broadcast length: 15, 30, 45, or 60 minutes, default: 30).
    - `platform` (TikTok Live, Shopee Live, Facebook Live, YouTube Live).
    - `products` (Dynamic list: Product Name, Key Selling Points, Regular Price, Flash Sale Price).
    - `offers` (Vouchers, discount codes, gift rules, free shipping terms).
    - `hostStyle` / `tone` (Energetic/Hype, Professional/Consultative, Warm/Friendly, Comedic).
    - `language` (Default: `vi`).
  - Interactive Timeline Segment Inspector:
    - Structured timeline view dividing broadcast into 4 functional phases:
      1. Intro & Hook (00:00 – 03:00 / 05:00)
      2. Product Showcase & Deal (05:00 – 18:00)
      3. Minigame & Audience Engagement (18:00 – 24:00)
      4. Closing, Recap & Countdown (24:00 – 30:00)
    - Each segment card displays: Time bracket badge (`MM:SS – MM:SS`), Segment Title, Host Spoken Script, Visual/Camera Cues (pin product, change angle), and Interaction Cues (call to comment, share stream).
    - Segment inline editing tools (edit text, reorder, adjust time marks).
  - Action Bar: "Regenerate with Feedback", "Export Script (.PDF / .TXT)", "Apply to Task Script (FR 3.6.23)" button with version conflict check.
- **Data Processing:**
  - Gateway routes request to Business Service → checks workspace membership and reserves AI credits on the ledger.
  - Business Service invokes AI Service Prompt Builder: synthesizes brand context and verified product facts into a strict JSON-schema prompt for a single LLM model (e.g., Llama-3.3-70b / Claude 3.5 Sonnet / Gemini 1.5 Pro).
  - Post-processor validates timeline mathematics: confirms segment start/end times start at 0, are strictly contiguous without overlap, and sum exactly to the requested duration.
  - Result returned to Creator for review; clicking "Apply to Task" commits a new `ContentVersion` record under the target Task (FR 3.6.23), ensuring no unconfirmed overwriting of existing work.

## Routes and DTOs

### Public Client Endpoints (API Gateway → Business Service)

- `POST /api/v1/workspaces/{workspaceId}/ai/livestream-scripts/generate`
  - Body: `GenerateLivestreamScriptRequest`
  - Response `200 OK`: `ApiResponse<LivestreamScriptResponseDto>`
- `POST /api/v1/workspaces/{workspaceId}/ai/livestream-scripts/regenerate`
  - Body: `RegenerateLivestreamScriptRequest`
  - Response `200 OK`: `ApiResponse<LivestreamScriptResponseDto>`
- `POST /api/v1/workspaces/{workspaceId}/ai/livestream-scripts/{scriptId}/apply-to-task`
  - Body: `ApplyScriptToTaskRequest`
  - Response `200 OK`: `ApiResponse<ApplyScriptResponseDto>`

### DTO Schemas

```json
// GenerateLivestreamScriptRequest
{
  "taskId": "7c9e6679-7425-40de-944b-e07fc1f90ae7", // optional context
  "topic": "Super Brand Day Flash Sale - Summer Glow Skin Routine",
  "goal": "SALES", // enum: SALES, BRAND_AWARENESS, PRODUCT_LAUNCH, TUTORIAL, QA
  "targetAudience": "Gen Z and young office workers seeking affordable acne-safe hydration",
  "durationMinutes": 30, // integer: 15, 30, 45, 60
  "platform": "TIKTOK_LIVE", // enum: TIKTOK_LIVE, SHOPEE_LIVE, FACEBOOK_LIVE, YOUTUBE_LIVE
  "language": "vi",
  "tone": "ENERGETIC", // enum: ENERGETIC, PROFESSIONAL, WARM_FRIENDLY, COMEDIC
  "products": [
    {
      "productId": "prod-101",
      "productName": "BrandHub Hydra-Gel Cream 50ml",
      "keyBenefits": ["72h hydration", "Non-greasy", "Calms redness"],
      "regularPrice": 350000,
      "dealPrice": 249000
    }
  ],
  "offers": "Buy 1 cream get 1 travel serum free for orders placed in the first 15 mins. Voucher BHUB50K for bills > 400K.",
  "keyMessages": "Verified dermatologist approved, 100% genuine warranty",
  "hostStyleNotes": "High energy, frequent call-outs of buyer usernames, countdown urgency"
}

// LivestreamScriptResponseDto
{
  "scriptId": "ls-scr-9a8b7c6d-1234-5678-abcd-ef0123456789",
  "title": "Super Brand Day Flash Sale - Summer Glow Skin Routine",
  "summary": "30-minute high-conversion livestream structured into 4 key phases with flash deal spotlights and engaging minigames.",
  "totalDurationMinutes": 30,
  "segments": [
    {
      "segmentId": "seg-01",
      "phase": "INTRO", // enum: INTRO, DEAL, MINIGAME, CLOSING
      "sectionTitle": "Hook & Welcome: Announce Exclusive Flash Deals",
      "startSecond": 0,
      "endSecond": 180,
      "timeDisplay": "00:00 - 03:00",
      "hostScript": "Hello cả nhà yêu ơi! Chào mừng mọi người đã đến với phiên livestream độc quyền Super Brand Day hôm nay...",
      "visualCues": "Host waves warmly; camera locked on medium close-up; banner 'FLASH DEAL 249K' overlays top corner.",
      "interactionCue": "Kêu gọi mọi người thả tim lên mốc 10K để mở khóa voucher 50K đầu tiên!",
      "productRefs": []
    },
    {
      "segmentId": "seg-02",
      "phase": "DEAL",
      "sectionTitle": "Product Showcase & Live Demo: Hydra-Gel Cream",
      "startSecond": 180,
      "endSecond": 1080,
      "timeDisplay": "03:00 - 18:00",
      "hostScript": "Và sản phẩm tâm điểm của chúng ta hôm nay: Hydra-Gel Cream 50ml! Giá gốc 350K nhưng ngay lúc này chỉ còn 249K...",
      "visualCues": "Host apply chất kem lên mu bàn tay; camera macro zoom cận cảnh độ thẩm thấu; ghim giỏ hàng sản phẩm số 1.",
      "interactionCue": "Comment 'DA ĐẸP' để được ghim voucher độc quyền!",
      "productRefs": ["prod-101"]
    },
    {
      "segmentId": "seg-03",
      "phase": "MINIGAME",
      "sectionTitle": "Lucky Wheel & Mini Giveaway: Đố vui nhận quà",
      "startSecond": 1080,
      "endSecond": 1440,
      "timeDisplay": "18:00 - 24:00",
      "hostScript": "Bây giờ chúng ta sẽ cùng chơi một minigame cực kỳ nhanh: Ai là người comment đúng thành phần chính của kem dưỡng...",
      "visualCues": "Host giơ bảng câu hỏi mini; trợ lý đếm ngược 60 giây trên màn hình.",
      "interactionCue": "Nhắc khán giả comment đáp án kèm 2 số may mắn.",
      "productRefs": []
    },
    {
      "segmentId": "seg-04",
      "phase": "CLOSING",
      "sectionTitle": "Final Call: Countdown Deal & Wrap-up",
      "startSecond": 1440,
      "endSecond": 1800,
      "timeDisplay": "24:00 - 30:00",
      "hostScript": "Chỉ còn đúng 5 phút cuối cùng trước khi deal 249K đóng lại! Ai chưa bấm thanh toán thì nhanh tay nhé...",
      "visualCues": "Đồng hồ đếm ngược 5 phút cuối xuất hiện; host cầm bộ sản phẩm tổng thể chào tạm biệt.",
      "interactionCue": "Nhắc nhở bấm 'Theo dõi shop' để nhận thông báo ca live ngày mai.",
      "productRefs": ["prod-101"]
    }
  ],
  "creditSettled": 10,
  "createdAt": "2026-09-27T09:40:00Z"
}

// ApplyScriptToTaskRequest
{
  "taskId": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "overwriteStrategy": "NEW_VERSION" // enum: "NEW_VERSION", "OVERWRITE_CURRENT"
}

// ApplyScriptResponseDto
{
  "taskId": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "contentVersionId": "cv-7788-9900",
  "versionNumber": 2,
  "status": "APPLIED",
  "message": "Livestream script applied as new Content Version 2."
}
```

## Screen Layout

Figure — Livestream Script Generator & Timeline Editor (`brandhub-web/src/pages/ai/livestream/LivestreamScriptPage.tsx`):
- Top Context Header: Task title, Client/Brand name badge, Associated Campaign tag, Credit balance indicator.
- Left Panel: Form Input (Collapsible)
  - Topic / Idea Input: Text field with pre-fill button "Load from Task Idea".
  - Goal selector chips: `Sales (Default)`, `Product Launch`, `Brand Awareness`, `Tutorial`, `Q&A`.
  - Duration picker: Radio buttons `15 min`, `30 min (Default)`, `45 min`, `60 min`.
  - Platform selector: Dropdown with platform icons (`TikTok Live`, `Shopee Live`, `Facebook Live`, `YouTube Live`).
  - Tone & Style: Selector (`Energetic / Hype`, `Professional`, `Friendly`, `Comedic`).
  - Products & Offers Table:
    - Repeater rows: Product Name, Key Benefits, Normal Price, Flash Price. Button "+ Add Product".
    - Offers Textarea: Free-text promotion details.
  - Submit Button: "Generate Livestream Script (10 Credits)".
- Right Panel: Timeline Segment View (Live Canvas)
  - Summary Bar: Total duration badge (`30:00`), 4 phase chips (`Intro 3m`, `Deal 15m`, `Minigame 6m`, `Closing 6m`).
  - Segment Cards Column:
    - Card 1 (Intro): Purple header, Time badge `00:00 - 03:00`, Host dialogue in prominent font, Visual direction pill `Camera: Medium close-up`, Interaction note `Comment 'START'`.
    - Card 2 (Deal): Green header, Time badge `03:00 - 18:00`, Highlighted product box, Spoken pitch, Call-to-action cue.
    - Card 3 (Minigame): Orange header, Time badge `18:00 - 24:00`, Minigame rules and engagement triggers.
    - Card 4 (Closing): Blue header, Time badge `24:00 - 30:00`, Urgency countdown cues, goodbye remarks.
  - Action Bar (sticky bottom):
    - Button "Regenerate with Feedback" (opens feedback drawer).
    - Button "Download Script (.TXT / .DOCX)".
    - Button "Apply to Task Script (FR 3.6.23)" (primary orange button).

## Function Details

### Data Specifications

- **Input required:**
  - `workspaceId` (path, UUID): Active workspace ID.
  - `topic` (body, string, 5–200 characters).
  - `goal` (body, enum): `SALES`, `BRAND_AWARENESS`, `PRODUCT_LAUNCH`, `TUTORIAL`, `QA`.
  - `targetAudience` (body, string, 5–500 characters).
  - `durationMinutes` (body, integer): `15`, `30`, `45`, `60`.
  - `platform` (body, enum): Target broadcast platform.
- **Input optional:**
  - `taskId` (body, UUID): Target livestream task.
  - `products` (body, array of product objects, required if `goal == SALES`).
  - `offers` (body, string): Promotions, discounts, vouchers.
  - `tone` (body, enum, default `ENERGETIC`).
  - `language` (body, string, default `vi`).
- **System data:**
  - Database table `ai_livestream_scripts`: `id`, `workspace_id`, `creator_id`, `task_id`, `form_payload_json`, `result_json`, `credit_cost`, `applied_at`, `created_at`.
  - Task Content Versions table: `content_versions` linked to FR 3.6.23.
- **Output:**
  - `LivestreamScriptResponseDto` containing structured segments array and timeline metadata.

### Business Rules

- **BR-AI-1101 (Single LLM Architecture):**
  - Script generation uses a single LLM model call (primary: Groq / Llama-3.3-70b or configured secondary fallback).
  - The model prompt enforces strict JSON schema output with strongly typed timeline segments.
- **BR-AI-1102 (Timeline Integrity & Mathematical Contiguity):**
  - The generated timeline segments MUST satisfy:
    1. First segment `startSecond == 0`.
    2. Segment `i.endSecond == segment[i+1].startSecond` (strictly contiguous, zero time gap, zero overlap).
    3. Final segment `endSecond == durationMinutes * 60`.
  - If the LLM generates inconsistent time increments, backend post-processor normalizes segment lengths proportionately to guarantee exact duration match.
- **BR-AI-1103 (Factual Grounding & Anti-Hallucination):**
  - The LLM is strictly prohibited from inventing product prices, fake percentage discounts, or fabricated product ingredients.
  - If `goal == SALES` or product references are discussed, the script MUST rely solely on the user-provided `products` array and `offers` text. If no offer is provided, the script must not promise discounts.
- **BR-AI-1104 (Non-Destructive Task Application & Versioning):**
  - Clicking "Apply to Task" MUST NOT silently overwrite existing scripts in FR 3.6.23.
  - The system checks if the Task currently contains a script. If a script exists, the system creates a new `ContentVersion` record (e.g. Version 2) and records provenance that it was generated by AI, allowing Creators to revert to previous versions at any time.
- **BR-AI-1105 (Credit Reservation & Settlement):**
  - Generates script for 10 credits (configurable).
  - Business Service reserves 10 credits prior to LLM invocation. Upon valid JSON output generation and parsing, the 10 credits are settled. If the LLM call fails or times out, the 10 credits are released immediately.
- **BR-AI-1106 (Regenerate with Feedback):**
  - Creator can provide textual refinement feedback (e.g., "Make the minigame shorter and focus more on the moisturizer texture").
  - The system feeds the previous script summary + user feedback into the LLM context.
  - Regeneration is treated as a new generation request and consumes a new credit fee.

### Validation

- Missing `topic`, `targetAudience`, or invalid `durationMinutes` → 400 `VALIDATION_ERROR`, Display: MSG-AI-1101 ("Please fill in topic, target audience, and choose a valid duration.").
- Goal is `SALES` but `products` list is empty → 400 `PRODUCTS_REQUIRED_FOR_SALES`, Display: MSG-AI-1102 ("At least one product with price is required for Sales livestream scripts.").
- Creator has insufficient AI credits → 402 `INSUFFICIENT_AI_CREDIT`, Display: MSG-AI-701.
- Applying script to a Task that does not belong to the workspace → 403 `FORBIDDEN`, Display: MSG-AI-01.
- Applying script to a Task that already has approved/published content → 409 `TASK_LOCKED_CANNOT_OVERWRITE`, Display: MSG-AI-1103 ("This task is locked for editing; please duplicate the task to apply new scripts.").

## Functionalities

### Normal Flow — Generate Script

1. Creator opens Task Detail (`/workspaces/:workspaceId/tasks/:taskId`), clicks "Write Livestream Script" tab (FR 3.6.23), and clicks "AI Generate Script".
2. System opens the Livestream Script Studio with prefilled topic from Task Livestream Idea (FR 3.6.22).
3. Creator fills in duration (30 min), goal (`SALES`), target audience, selects platform (`TIKTOK_LIVE`), adds 1 product (`Hydra-Gel Cream`, regular: 350K, deal: 249K), and inputs discount voucher.
4. Creator clicks "Generate Livestream Script".
5. Client submits request to `POST /api/v1/workspaces/{workspaceId}/ai/livestream-scripts/generate`.
6. Business Service verifies workspace tenancy, verifies quota, and reserves 10 credits.
7. AI Service Prompt Builder formats payload, sends prompt to LLM, receives raw JSON response, and validates schema and timeline contiguity.
8. System records `ai_livestream_scripts` entry, settles 10 credits, and returns `200 OK` with `LivestreamScriptResponseDto`.
9. Client renders the 4 timeline segment cards (`Intro`, `Deal`, `Minigame`, `Closing`).

### Normal Flow — Apply Script to Task (FR 3.6.23)

1. Creator reviews generated segments, clicks into Segment 2 to tweak one spoken sentence, and clicks "Apply to Task Script".
2. System checks if target Task already contains existing script content.
   - If Task is empty: system writes content as `ContentVersion` v1.
   - If Task has existing script: dialog prompts: "Task already has a draft script. Create new Version 2 or overwrite?" Creator selects "Create new Version 2 (Recommended)".
3. Client submits `POST .../apply-to-task` with `{ "overwriteStrategy": "NEW_VERSION" }`.
4. Business Service inserts new `ContentVersion` row linked to Task and links `scriptId`.
5. System returns `200 OK`. Toast MSG-AI-1104 ("Livestream script saved as Version 2.").
6. Creator is navigated back to Task Script editor (FR 3.6.23) with the new script preloaded.

### Abnormal Cases

- 6.a1: Credit balance is insufficient (< 10 credits) → 402 `INSUFFICIENT_AI_CREDIT`, toast MSG-AI-701. Generation aborted.
- 7.a1: LLM returns malformed JSON or times out (> 45s) → AI Service retries once with fallback model. If second attempt fails → returns 502 `AI_GATEWAY_TIMEOUT`, reserved credits refunded, toast MSG-AI-1105 ("AI generation failed to produce valid timeline; credits refunded.").
- 7.b1: LLM outputs segments whose total duration does not match `durationMinutes` → Post-processor auto-scales the endSeconds proportionally to fit the exact duration before returning to user.
- 9.a1: Creator is dissatisfied with the output and enters feedback: "Make minigame simpler" → Creator clicks "Regenerate". System submits `POST .../regenerate`, reserves 10 credits, feeds previous script as reference context, and outputs refreshed segments.

## Post-Conditions

- Generated script is persisted in `ai_livestream_scripts`.
- On "Apply to Task": A new `ContentVersion` record is saved in Task workflow, available in FR 3.6.23 for manual editing, teleprompter view, or approval handover.
- AI credit deduction settled on the ledger.

## Out of Scope

- Auto-broadcasting or triggering live video streams on TikTok/Shopee via API (handled manually or via social publishing connectors).
- Real-time AI teleprompter voice tracking during the live stream.
- Video generation from livestream script (video generation is handled in FR 3.7.7).

## References

- [06-ai-features.md](../../../ba/06-ai-features.md)
- [08-subscription-billing.md](../../../ba/08-subscription-billing.md)
- [ai-features-spec-alignment-plan.md](../../../plan/ai-features-spec-alignment-plan.md) (PO Decision D05, Section 2.7, Section 2.8: Temporary Livestream Form & Output)
- [3-6-22-write-livestream-idea/spec.md](../../content-task-workflow/3-6-22-write-livestream-idea/spec.md)
- [3-6-23-write-livestream-script/spec.md](../../content-task-workflow/3-6-23-write-livestream-script/spec.md)
