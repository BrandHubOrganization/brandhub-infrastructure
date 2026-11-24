> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.7.14 — Suggest Hashtag Trend

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.7.14` |
| **Use Case ID** | `UC-101` |
| **Feature** | Suggest Hashtag Trend (Contextual, Workspace-Aware & Trend-Grounded) |
| **Domain** | AI Features (`3.7`) |
| **Canonical Actors / Roles** | `Owner`, `Manager`, `Creator` |
| **Business Rules** | `BR-20`, `BR-45`, `BR-50` |
| **Message Codes** | `MSG01`, `MSG02`, `MSG03`, `MSG07` |
| **Status** | Implemented — Production Verified (Consolidates `api-hashtag-suggestions`, `contextual-hashtag-suggestions`, `workspace-context-hashtag-suggestions`, `workspace-hashtag-demo-seed`) |

## 1. Objective & Business Value

Provide ranked, contextually accurate, platform-clamped hashtag suggestions inside the Post/Task Content Editor (`AiHashtagSuggestions.tsx`, `HashtagInputWithSuggestions.tsx`) and Hashtag Collection workflow for `Owner`, `Manager`, and `Creator`. The pipeline combines:
1. **Caption Semantic Meaning First:** Gemini (`GEMINI_MODEL`) interprets caption intent, target audience, topic, and tone, treating caption text strictly as untrusted data (prompt-injection safe).
2. **Authorized Workspace Candidate Enrichment:** `HashtagSuggestionContext` in `brandhub-business-service` loads up to `500` active optional hashtags (`BRAND`, `CAMPAIGN`, `TRENDING`) from `workspace_hashtags` for the caller's authorized Workspace (preferring `BRAND` then recent entries, excluding soft-deleted and `EVENT_SPECIFIC`/required campaign tags, and overwriting any caller-spoofed `workspace_hashtags`).
3. **Evidence-Based Trend Grounding:** Optional cached Redis trend evidence (`trends:vn:live:{category}`) enriches suggestions without ever fabricating trend badges or padding results with unrelated viral topics (e.g., excluding `#WorldCup` on a student laptop post).

## 2. User Story

As an `Owner`, `Manager`, or `Creator` drafting social content for Facebook, Instagram, TikTok, or Threads, I want to generate ranked hashtag suggestions with transparent provenance (`WORKSPACE`, `TREND_CONTEXT`, `AI_GENERATED`) and click to insert selected tags into my post without mutating the Workspace Hashtag Collection unless I explicitly save them.

## 3. Acceptance Criteria

1. **Role, Tenant & Spoofing Protection (`BR-20`):** Authenticated `Owner`, `Manager`, and `Creator` invoke `POST /api/v1/ai/content/hashtags` via `AiGenerationController`. `HashtagSuggestionContext` queries `workspace_hashtags` exclusively for the server-verified `workspaceId` after `HASHTAG_GENERATE` credit reservation claim, ignoring any client-supplied `client_id` or `workspace_hashtags` array.
2. **Relevance Ranking & Provenance Badges (`BR-50`):** Suggestions return in descending relevance order with deterministic `source` derived from Unicode NFC + accent-insensitive membership verification:
   - `WORKSPACE` — matched an active tag in the authorized Workspace's `workspace_hashtags` collection.
   - `TREND_CONTEXT` — matched verified Redis trend cache evidence (`trends:vn:*`) relevant to the caption.
   - `AI_GENERATED` — contextually synthesized niche/topical hashtag when neither workspace nor trend cache covers the concept.
3. **Platform Clamping & Sanitization:** Supported platforms are strictly `facebook` (recommended 3–5), `instagram` (up to 30), `tiktok` (recommended 5–8), and `threads` (1–3). Output tags enforce single leading `#`, Unicode NFC letters/marks/digits/underscores (`<= 100` chars), case/accent-insensitive deduplication, and community-safety blacklist filtering.
4. **Explicit User Selection (No Silent Mutation):** Empty captions disable the Generate button. Clicking a suggested chip appends it once to the active post draft (preventing duplicates) and never auto-inserts into `workspace_hashtags` unless the user explicitly invokes `HashtagController` (`POST /api/v1/workspaces/{workspaceId}/hashtags`).
5. **Credit Accounting & Failure Safety:** Managed through `AiCreditGenerationService` (`HASHTAG_GENERATE`). Explicit `HASHTAG_GENERATION_FAILED` / `HASHTAG_GENERATION_UNAVAILABLE` or pre-dispatch context load failure finalizes `0` billable units (releases reservation); transient upstream `503` triggers fallback model retry with trace-correlated, caption/secret-redacted structured logs.
6. **Internationalization (`vi.json` + `en.json`):** Key-parallel `editor.hashtagInput.aiGenerate`, `aiLoading`, `aiResults`, `aiRankHint`, `aiEmpty`, `sourceWorkspace`, `sourceTrend`, and `sourceGenerated` in `src/i18n/locales/{vi,en}/editor.json` (plus `hashtagService.ts` + `tr()` on Mobile).
7. **Light & Dark Mode Compliance:** Numbered suggestion list, provenance badges, keyboard focus rings, and responsive chip wrapping use semantic theme tokens across `375px`, `768px`, and `1440px` viewports in both Light and Dark modes.

## 4. UI / UX & Screen States

- **Web Components:** `pages/editor/components/AiHashtagSuggestions.tsx`, `HashtagInputWithSuggestions.tsx`, `HashtagCollectionPicker.tsx`, and `pages/hashtag-groups/index.tsx`.
- **Mobile Components:** `src/services/hashtagService.ts`, `src/screens/more/AiPostStudioScreen.tsx`.
- **UI States:**
  - **Disabled:** Empty/whitespace-only caption disables `aiGenerate` trigger with tooltip guidance.
  - **Loading:** Inline skeleton/spinner (`editor.hashtagInput.aiLoading`) with query cancellation if caption/platform changes.
  - **Ranked Results:** Numbered vertical list (`#1..#N`) showing `#TagName` + provenance pill (`sourceWorkspace` / `sourceTrend` / `sourceGenerated`); already-selected tags show check state and prevent duplicate insertion.
  - **Empty / Error:** Explicit retryable banner (`aiEmpty` / localized error) with zero mock/unrelated fallback tags.

## 5. API Contract

| Method & Endpoint | Auth | Handler | Request / Response |
| :--- | :--- | :--- | :--- |
| `POST /api/v1/ai/content/hashtags` | Bearer (`Owner, Manager, Creator`) | `AiGenerationController` -> `AiCreditGenerationService` | Req: `{ workspaceId, caption, platform, count }` -> `200 ApiResponse<HashtagGenerateResponse>` (`hashtags[]` + `suggestions[{ tag, source, score }]`) |
| `POST /api/v1/ai/content/hashtags` (Internal) | `X-Internal-Api-Key` | `brandhub-ai-service` `app/api/v1/endpoints/content.py` | Receives caption + validated `workspace_hashtags` (`<= 500`) + platform/count; queries Gemini + `trend_cache_service.py` |
| `POST /api/v1/workspaces/{workspaceId}/hashtags` | Bearer (`Owner, Manager, Creator`) | `HashtagController` | Optional explicit save into `workspace_hashtags` (`BRAND`, `CAMPAIGN`, `TRENDING`, `EVENT_SPECIFIC`) |

## 6. Error Handling, Seed Integrity & Edge Cases

- **Empty Workspace Collection:** Works seamlessly (`workspace_hashtags = []`), returning `TREND_CONTEXT` and `AI_GENERATED` tags without error.
- **Required / `EVENT_SPECIFIC` Campaign Tags:** Excluded from optional AI candidate pool so mandatory campaign hashtag compliance rules remain enforced independently.
- **Idempotent Demo Seed Compatibility:** Transactional `workspace_hashtags` demo/trend-import migrations use NFC normalization, lowercase uniqueness conflict guards (`ON CONFLICT DO NOTHING`), and preserve soft-deleted rows across reruns.
- **Log Redaction:** Lifecycle logs record trace ID, provider branch, latency, and result count while redacting raw caption bodies and `GEMINI_API_KEY`.

## 7. Related Specifications & References

- **Sibling SRS FRs:** [FR 3.7.1 — View Trending Topics Suggestions](../3-7-1-view-trending-topics-suggestions/spec.md) · [FR 3.7.6 — Generate Caption](../3-7-6-generate-caption/spec.md)
- **Consolidated Extension Module:** [`rag-caption-moderation-and-humanizer`](../../../modules/05-ai-rag-and-crawler/rag-caption-moderation-and-humanizer/spec.md)
- **BA Domain Baseline:** [BA 3.7 AI Features](../../../../ba/06-ai-features.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified in `AiGenerationControllerTest`, `AiHashtagFailureTest`, `26` AI hashtag unit tests, and Playwright `vi`/`en` Light/Dark studio tests ([test.md](./test.md)).
- **Out of Scope:** Post-publish hashtag impression analytics (covered in FR 3.8.4) and unsupported platforms outside Facebook, Instagram, TikTok, and Threads.
