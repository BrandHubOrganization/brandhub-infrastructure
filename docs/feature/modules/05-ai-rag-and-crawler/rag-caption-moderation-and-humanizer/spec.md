> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Brand-Grounded RAG Captions, Editor AI Popover, Content Humanizer & Text Safety Moderation

| Field | Value |
| :--- | :--- |
| **Module Slug** | `rag-caption-moderation-and-humanizer` |
| **Category** | `05-ai-rag-and-crawler` — AI Trend Crawler, Neo4j Knowledge Graph & Brand RAG |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Admin` |
| **Consolidated Feature Scopes** | `brand-trend-caption-quality`, `caption-credit-request`, `caption-neo4j-context`, `caption-text-moderation`, `caption-trend-retrieval`, `content-humanizer`, `editor-ai-content-popover` |
| **Aligned SRS Domains** | [FR 3.7.6 — Generate Caption](../../../srs/06-ai-features/3-7-6-generate-caption/spec.md) · [FR 3.10.4 — Content Moderation Queue](../../../srs/09-admin-functions/3-10-4-content-moderation-queue/spec.md) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Unify the complete AI text authoring and safety pipeline inside the Task & Post Editor: **ChromaDB Brand RAG + Neo4j Trend Retrieval** (`caption-trend-retrieval`, `caption-neo4j-context`, `brand-trend-caption-quality`), **Anti-AI-Slop Content Humanizer** (`content-humanizer`), **Inline Editor AI Content Popover** (`editor-ai-content-popover`), **Idempotent Credit Accounting** (`caption-credit-request`), and **Automated Text Compliance Moderation** (`caption-text-moderation` -> `InternalModerationController`).

## 2. User Stories

- As a `Creator`, `Manager`, or `Owner`, I want AI captions generated or refined inside the Editor popover to sound natural and human (`humanizer.py`), stay strictly faithful to uploaded Brand Guidelines and Neo4j trend context, and pass automated community-safety moderation before submission or publishing.

## 3. Consolidated Acceptance Criteria

1. **Dual ChromaDB + Neo4j Grounding (`caption-trend-retrieval`, `caption-neo4j-context`, `brand-trend-caption-quality`):** `llm_service.py` + `prompt_builder.py` inject top-scoring `brand_docs_{workspace_id}` chunks (strictly forbidding invented prices, phone numbers, or warranties) alongside Neo4j trend neighborhood entities/angles so captions connect the trend naturally to the brand.
2. **Content Humanizer (`content-humanizer`):** `app/utils/humanizer.py` strips robotic LLM clichés, forced triads, repetitive dash patterns, and artificial sales hype across both Vietnamese and English outputs during generate, `/captions/refine`, and `/captions/adapt`.
3. **Editor AI Content Popover & Choice Tracking (`editor-ai-content-popover`, `caption-credit-request`):** Inline Editor AI popover (`ContentCreatorAiPanel.tsx`, `AIGeneratePanel.tsx`, `AiCaptionDialog.tsx`) attaches `Idempotency-Key` + `X-AI-Workspace-Id`, records selected variant via `POST /captions/{generationId}/choice`, and persists accepted copy into Task Content Versions (`task_content_snapshots`).
4. **Automated Text Moderation (`caption-text-moderation`):** `POST /api/v1/workspaces/{workspaceId}/ai/captions/moderate` (`text_moderation_service.py`) evaluates drafts against profanity, violence, hate speech, and platform safety rules, displaying `CaptionModeration.tsx` / `EditorModerationStatus.tsx` badges and forwarding severe flags to `InternalModerationController` (`/api/v1/internal/moderation/flags`) for FR 3.10.4 review.
5. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`editor.aiPopover.*`, `editor.aiCaption.*`, `editor.humanizer.*`, `editor.moderation.*` in `src/i18n/locales/{vi,en}/editor.json`) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** `components/ai/AiCaptionDialog.tsx`, `pages/editor/components/{AIGeneratePanel,ContentCreatorAiPanel,CaptionModeration,EditorModerationStatus}.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/{AiCaptionScreen,AiPostStudioScreen}.tsx`, `src/utils/editorModeration.ts` (`editorModeration.test.ts`)
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `POST /api/v1/workspaces/{workspaceId}/ai/captions[/refine|/adapt]` | Bearer (`Owner, Manager, Creator`) + `Idempotency-Key` | `AiCaptionController` -> `content.py` RAG + Neo4j + Humanizer pipeline |
| `POST /api/v1/workspaces/{workspaceId}/ai/captions/{generationId}/choice` | Bearer (`Owner, Manager, Creator`) | `AiCaptionController` -> records chosen variant without credit charge |
| `POST /api/v1/workspaces/{workspaceId}/ai/captions/moderate` | Bearer (`Owner, Manager, Creator`) | `AiCaptionController` -> `text_moderation_service.py` compliance check |
| `POST /api/v1/internal/moderation/flags` | `X-Internal-Service-Key` | `InternalModerationController` -> enqueues flagged items into `content_moderation_reviews` |

## 6. Error Handling, Security & Edge Cases

- **Prompt Injection in User Topic or Trend Post:** Untrusted trend snippets and user notes are delimited inside data blocks and stripped of system-override directives before LLM invocation.
- **Retry with Identical `Idempotency-Key`:** Replays stored `ai_caption_generations` output without re-invoking Groq/Gemini.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [FR 3.7.6 — Generate Caption](../../../srs/06-ai-features/3-7-6-generate-caption/spec.md) · [FR 3.10.4 — Content Moderation Queue](../../../srs/09-admin-functions/3-10-4-content-moderation-queue/spec.md)
- **BA & Architecture References:** [BA 06 AI Features](../../../../ba/06-ai-features.md) · [BA 09 Admin Functions](../../../../ba/09-admin-functions.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).
