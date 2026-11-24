> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Multi-Scene Product Video Production Pipeline (LTX Director, Wan 2.2 VACE / I2V Workers & CapCut Export)

| Field | Value |
| :--- | :--- |
| **Module Slug** | `wan-vace-product-video-pipeline` |
| **Category** | `06-ai-media-and-video-studio` — AI Commercial Image, Product Video & Conversational Video Studio |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Consolidated Feature Scopes** | `product-video-pipeline`, `ltx-director-worker`, `i2v-worker-integration` |
| **Aligned SRS Domains** | [FR 3.7.10 — View Video Style Template](../../../srs/06-ai-features/3-7-10-view-video-style-template/spec.md) · [FR 3.7.11 — Generate Video](../../../srs/06-ai-features/3-7-11-generate-video/spec.md) · [FR 3.7.12 — Export File](../../../srs/06-ai-features/3-7-12-export-file/spec.md) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Orchestrate multi-scene commercial **Product Video Production** (`ProductVideoController` + `product_video.py`): AI Director storyboard planning (`POST /plan` / `ltx-director-worker`), quote & credit reservation (`product_video_quotes` + `ai_credit_reservations`), asynchronous **Image-to-Video (I2V / Wan 2.2 VACE / LTX / Veo)** per-scene generation (`i2v-worker-integration`), granular scene retry (`POST /scenes/{sceneId}/retry`), master MP4 stitching (`POST /render-retry`), and editable **CapCut Desktop multi-track bundle export** (`GET /{id}/editing-bundle`).

## 2. User Stories

- As an `Owner`, `Manager`, or `Creator`, I want to turn product images and a campaign brief into a multi-scene storyboard, generate smooth I2V commercial shots, retry any individual scene without regenerating the whole video, and download either the final MP4 or an editable CapCut project bundle.

## 3. Consolidated Acceptance Criteria

1. **Two-Stage Storyboard Plan -> Scene Generation (`product-video-pipeline`, `2026-10-30-product-video-pipeline.sql`):** `POST /api/v1/workspaces/{workspaceId}/ai/video-productions/plan` synthesizes a scene-by-scene camera/motion script (`product_video_plans`) and exact credit quote (`product_video_quotes`) before any GPU generation runs.
2. **LTX Director & I2V GPU Worker Integration (`ltx-director-worker`, `i2v-worker-integration`):** `POST /video-productions/{id}/generate` reserves `VIDEO_GENERATE` credits (`DA-974` `reservation_id`), dispatches reference-conditioned I2V scene jobs (`Wan 2.2 VACE` / `LTX-Video` / `Veo`), tracks `product_video_attempts`, and reconciles completion asynchronously even if the user closes the browser.
3. **Granular Scene Retry & Render Retry:** `POST /{id}/scenes/{sceneId}/retry` regenerates a single failed/unsatisfactory scene; `POST /{id}/render-retry` re-runs final FFmpeg concat/audio muxing without re-running GPU inference.
4. **Final MP4 & CapCut Bundle Export:** `GET /{id}/content` and `GET /{id}/scenes/{sceneId}/content` stream rendered MP4s; `GET /{id}/editing-bundle` (`tools/video-edit/package_capcut.py`) packages raw scene clips, beat markers (`beats.py`), and `draft_content.json` into a portable `.zip` for CapCut Desktop.
5. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`aiStudio.productVideo.{plan,scenes,generate,retryScene,capcutBundle}.*` in `src/i18n/locales/{vi,en}/aiStudio.json`) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** `pages/ai-studio/video.tsx`, `GenerateVideoDialog.tsx`, `pages/editor/components/AIVideoAssistPanel.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/{AiVideoScreen,AiVideoHistoryScreen,QuickReelStudioScreen}.tsx`, `src/utils/aiWorkerHelpers.ts`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `POST /api/v1/workspaces/{workspaceId}/ai/video-productions/plan` | Bearer (`Owner, Manager, Creator`) | `ProductVideoController.plan()` -> `product_video.py` `POST /ai/product-video/plan` |
| `POST /api/v1/workspaces/{workspaceId}/ai/video-productions/{id}/generate` | Bearer (`Owner, Manager, Creator`) + `Idempotency-Key` | `ProductVideoController.generate()` -> reserves credits & dispatches I2V scene workers |
| `POST /api/v1/workspaces/{workspaceId}/ai/video-productions/{id}/scenes/{sceneId}/retry & /render-retry` | Bearer (`Owner, Manager, Creator`) | `ProductVideoController` -> granular scene or stitch recovery |
| `GET /api/v1/workspaces/{workspaceId}/ai/video-productions/{id}[/content|/editing-bundle]` | Bearer (`Owner, Manager, Creator`) | `ProductVideoController` -> status polling, MP4 stream & CapCut `.zip` bundle |

## 6. Error Handling, Security & Edge Cases

- **User Closes Browser During Long GPU Render:** Background reconciliation worker in `business-service` polls `GET /ai/product-video/render/{render_id}`, persists S3 output, and settles/releases `ai_credit_reservations` deterministically.
- **Cross-User Job Isolation:** Video job polling enforces Workspace/originator authorization checks.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [FR 3.7.10 — View Video Style Template](../../../srs/06-ai-features/3-7-10-view-video-style-template/spec.md) · [FR 3.7.11 — Generate Video](../../../srs/06-ai-features/3-7-11-generate-video/spec.md) · [FR 3.7.12 — Export File](../../../srs/06-ai-features/3-7-12-export-file/spec.md)
- **BA & Architecture References:** [BA 06 AI Features](../../../../ba/06-ai-features.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).
