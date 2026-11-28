> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Mobile AI Hub: Grounded Captions, Hashtag Suggestions, Ambassadors, Ad Images, Video & Quick Reel Studio

| Field | Value |
| :--- | :--- |
| **Module Slug** | `mobile-ai-features` |
| **Category** | `08-mobile-application` — BrandHub Mobile Application (Expo SDK 58 / React Native 0.88) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Consolidated Feature Scopes** | `mobile-ai-features`, `mobile-nav-role-parity (AI Studio, Trends & Quick Reel Studio)` |
| **Aligned SRS Domains** | [3.7 AI Features](../../../srs/06-ai-features/README.md) (`3.7.1–3.7.19`) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Bring BrandHub's full creative AI suite to `brandhub-mobile-app` (`AiHubScreen.tsx`): **AI Caption & Post Studio** (`AiCaptionScreen.tsx`, `AiPostStudioScreen.tsx` with Brand RAG + Neo4j Trend grounding + Contextual Hashtags), **Social Trends Explorer** (`SocialTrendsScreen.tsx`), **Virtual Ambassador & Commercial Ad Image Generators** (`AiModelGeneratorScreen.tsx`, `AiAdImageScreen.tsx`), **AI Product/Style Video & History** (`AiVideoScreen.tsx`, `AiVideoHistoryScreen.tsx`), and **Quick Reel Auto-Edit Studio** (`QuickReelStudioScreen.tsx`).

## 2. User Stories

- As an `Owner`, `Manager`, or `Creator` working on mobile, I want to browse live Brand-Fit trends, generate RAG-grounded captions and ranked hashtags, synthesize Virtual Ambassadors, commercial product images, and AI videos/Quick Reels, and save generated assets straight to the Workspace Library or device gallery.

## 3. Consolidated Acceptance Criteria

1. **Unified `X-AI-Workspace-Id` + `Idempotency-Key` Mobile Contract:** `src/services/aiService.ts` and `hashtagService.ts` attach explicit `X-AI-Workspace-Id` and per-action `Idempotency-Key` headers matching `DA-974` / Workspace Credit Unification, invalidating credit balance queries after billable generations.
2. **AI Caption, Post Studio & Hashtag Suggestions (`AiCaptionScreen.tsx`, `AiPostStudioScreen.tsx`):** Generates 3-variant RAG/Trend captions, supports refine/adapt/choice, runs `editorModeration.ts` compliance checks, displays ranked hashtag provenance (`WORKSPACE`, `TREND_CONTEXT`, `AI_GENERATED`), and applies output directly to Tasks.
3. **Visual & Video AI Studios (`AiModelGeneratorScreen.tsx`, `AiAdImageScreen.tsx`, `AiVideoScreen.tsx`, `AiVideoHistoryScreen.tsx`, `QuickReelStudioScreen.tsx`):** Supports preset selection, gallery/camera product reference upload (`<= 20 MB` normalized), resilient async job polling (`aiWorkerHelpers.ts`), native `expo-video` playback, and 1-tap save to Workspace Material Repository (`saveToLibrary.ts`) or device photo library (`expo-media-library`).
4. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`aiHub.*`, `aiCaption.*`, `aiImage.*`, `aiVideo.*`, `quickReel.*`, `trends.*` in `src/i18n/locales/en.json` & `src/i18n/locales/vi/common.json` (`tr()`)) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
5. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** Parity with `pages/ai-studio/*` and `pages/editor/components/AI*Panel.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/{AiHubScreen,AiCaptionScreen,AiPostStudioScreen,AiModelGeneratorScreen,AiAdImageScreen,AiVideoScreen,AiVideoHistoryScreen,QuickReelStudioScreen,SocialTrendsScreen}.tsx`, `src/services/{aiService,hashtagService,trendService,matchingService}.ts`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `POST /api/v1/workspaces/{workspaceId}/ai/captions/** & GET /trend-fit & /credits` | Bearer (`Owner, Manager, Creator`) + `Idempotency-Key` | `AiCaptionController` <- `aiService.ts` |
| `POST /api/v1/ai/content/hashtags & /ambassadors/** & /image/commercial/generate` | Bearer (`Owner, Manager, Creator`) + `X-AI-Workspace-Id` | `AiGenerationController` <- `aiService.ts` & `hashtagService.ts` |
| `GET/POST /api/v1/workspaces/{workspaceId}/ai/video-styles & /videos/** & /video-productions/**` | Bearer (`Owner, Manager, Creator`) | `AiVideoController` & `ProductVideoController` <- `aiService.ts` |
| `POST /api/v1/workspaces/{workspaceId}/materials/reel-studio/auto-edit` | Bearer (`Owner, Manager, Creator`) | `MaterialController` <- `QuickReelStudioScreen.tsx` |

## 6. Error Handling, Security & Edge Cases

- **`Client` Role Exclusion:** `Client` accounts cannot access AI generation screens (`navAccess.ts` + `withAccess.tsx` + backend `403`).
- **App Backgrounded During AI Video Poll:** `AiVideoHistoryScreen.tsx` resumes polling persisted `jobId` on foreground return without losing reserved credit state.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [3.7 AI Features](../../../srs/06-ai-features/README.md) (`3.7.1–3.7.19`)
- **BA & Architecture References:** [BA 06 AI Features](../../../../ba/06-ai-features.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).
