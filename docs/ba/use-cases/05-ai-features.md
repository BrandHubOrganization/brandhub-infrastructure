# UC 05 — AI Features (UC-74 → UC-82)

> [<< Về Overview](../00-overview.md) · Nguồn FR: [06-ai-features.md](../06-ai-features.md)
> Nguồn UC gốc: `Các FR của hệ thống - Use Case.csv`

## Bảng tổng hợp

| UC ID | Use Case | Actor(s) | Related FR |
|---|---|---|---|
| UC-74 | View Trending Topics & Hashtag Suggestions | CREATOR | 3.7.1, 3.7.10 |
| UC-75 | Generate Caption with AI | CREATOR | 3.7.2 |
| UC-76 | Generate AI Brand Ambassador | CREATOR | 3.7.3 |
| UC-77 | Generate Image with AI | CREATOR | 3.7.4, 3.7.5 |
| UC-78 | Generate Video with AI | CREATOR | 3.7.6, 3.7.7 |
| UC-79 | Export AI-Generated File | CREATOR | 3.7.8 |
| UC-80 | Configure Trend Crawl Schedule | ADMIN | 3.7.9 |
| UC-81 | Generate Livestream Script with AI | CREATOR | 3.7.11 |
| UC-82 | Recommend Media Collaborator | CREATOR | 3.7.12 |

---

## UC-74 — View Trending Topics & Hashtag Suggestions

- **Actor(s):** CREATOR
- **Description:** View a dashboard of current trending keywords and suggested trending hashtags.
- **Precondition:** Trend crawl data available (see UC-80).
- **Main Flow:**
  1. CREATOR opens Trending Topics dashboard.
  2. System displays current trend keywords + AI-suggested trending hashtags.

## UC-75 — Generate Caption with AI

- **Actor(s):** CREATOR
- **Description:** Use an LLM and prompt to generate a caption for a post.
- **Precondition:** CREATOR has an active AI credit balance.
- **Main Flow:**
  1. CREATOR enters a prompt/context for the post.
  2. System sends the request to the LLM, returns a generated caption.
  3. AI credit deducted for the generation.

## UC-76 — Generate AI Brand Ambassador

- **Actor(s):** CREATOR
- **Description:** Use an LLM to generate a virtual model/ambassador when the brand has none, used for Image/Video generation.
- **Precondition:** Brand has no real ambassador/model on file.
- **Main Flow:**
  1. CREATOR requests ambassador generation (style/appearance input).
  2. System generates a virtual "actor" via LLM.
- **Postcondition:** Ambassador saved and reusable as an input source for UC-77 (Generate Image) and UC-78 (Generate Video) — not a standalone one-off feature.

## UC-77 — Generate Image with AI

- **Actor(s):** CREATOR
- **Description:** Select an image style template and generate an image via LLM based on form input, model, and other materials.
- **Precondition:** CREATOR has an active AI credit balance.
- **Main Flow:**
  1. CREATOR selects an image style template (anime, spring, nostalgic, etc.).
  2. CREATOR fills a form; system combines form + Ambassador model (if any) + Material Repository/Brand Collection assets into a single prompt.
  3. System calls the image-gen LLM (LoRA fine-tuned for brand style where applicable), returns generated image(s).
  4. AI credit deducted.

## UC-78 — Generate Video with AI

- **Actor(s):** CREATOR
- **Description:** Select a video style template and generate a video via LLM/third-party APIs.
- **Precondition:** CREATOR has an active AI credit balance.
- **Main Flow:**
  1. CREATOR selects a video style template.
  2. System builds prompt/input, calls third-party video-gen API.
  3. AI credit deducted, generated video returned.

## UC-79 — Export AI-Generated File

- **Actor(s):** CREATOR
- **Description:** Export generated files (images/videos) from the system to the user's device.
- **Precondition:** A generated file exists (UC-77/UC-78).
- **Main Flow:**
  1. CREATOR selects Export on a generated file.
  2. System exports in the appropriate format (mainly MP4/WebM for social upload).
- **Note:** Reusing a previously generated asset does not deduct AI credit again (see FR 3.6.35).

## UC-80 — Configure Trend Crawl Schedule

- **Actor(s):** ADMIN
- **Description:** Configure timing, source pages, and volume per run for the crawler that collects trending keyword data.
- **Precondition:** User is ADMIN.
- **Main Flow:**
  1. ADMIN sets crawl schedule (frequency, source pages, posts-per-run volume).
  2. System applies the config to the trend-crawling job.
- **Note:** This is the only AI-group FR owned by ADMIN (not CREATOR) — crawler config affects system-wide resources, not a per-Workspace action.

## UC-81 — Generate Livestream Script with AI

- **Actor(s):** CREATOR
- **Description:** Use AI to generate a sample script for a livestream session.
- **Precondition:** Livestream idea exists (see [04-content-task-workflow.md](04-content-task-workflow.md) UC-61).
- **Main Flow:**
  1. CREATOR requests an AI-generated draft script.
  2. System returns a sample script, which the Creator then edits/finalizes (UC-62, Write Livestream Script).

## UC-82 — Recommend Media Collaborator

- **Actor(s):** CREATOR
- **Description:** AI recommends third parties (online newspapers, banner ad channels, TV channels) as media partners for the campaign.
- **Precondition:** Active Media Campaign context.
- **Main Flow:**
  1. CREATOR/Manager requests collaborator suggestions.
  2. System returns a ranked list of potential Third-party Collaborators.
- **Business Rule:** AI only suggests — final selection/contact decision remains with Client/Manager, no auto-contact or auto-signing. See [07-publishing-social-collaborator.md](../07-publishing-social-collaborator.md) §2.
