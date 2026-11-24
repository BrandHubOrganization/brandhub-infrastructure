> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Commercial Advertising Image Presets & Qwen Image 2.1 ComfyUI Virtual Ambassador Pipeline

| Field | Value |
| :--- | :--- |
| **Module Slug** | `commercial-image-and-qwen-ambassador` |
| **Category** | `06-ai-media-and-video-studio` — AI Commercial Image, Product Video & Conversational Video Studio |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Consolidated Feature Scopes** | `commercial-image-presets`, `ambassador-portrait-ui`, `qwen-ambassador-docker` |
| **Aligned SRS Domains** | [FR 3.7.7 — Generate Ambassador](../../../srs/06-ai-features/3-7-7-generate-ambassador/spec.md) · [FR 3.7.8 — View Image Style Template](../../../srs/06-ai-features/3-7-8-view-image-style-template/spec.md) · [FR 3.7.9 — Generate Image](../../../srs/06-ai-features/3-7-9-generate-image/spec.md) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Deliver BrandHub's self-hosted / GPU-worker **Virtual Brand Ambassador & Commercial Product Advertising Image Pipeline**: containerized **Qwen Image 2.1 ComfyUI Worker** (`qwen-ambassador-docker`), **Ambassador Portrait & Multi-Angle Character Sheet UI** (`ambassador-portrait-ui`), and **3-Image Commercial Advertising Composition Presets** (`commercial-image-presets` via `/api/v2/commercial/generate` combining Ambassador identity + Product photo + Pose/Style preset across `4:5`, `9:16`, `16:9`, and `auto` aspect buckets).

## 2. User Stories

- As an `Owner`, `Manager`, or `Creator`, I want to generate consistent Virtual Brand Ambassadors (`POST /api/v1/ai/ambassadors/generate` & `/character-sheet`) and composite them holding or showcasing real client products (`POST /api/v1/ai/image/commercial/generate`) using curated commercial studio lighting presets without prompt-engineering complexity.

## 3. Consolidated Acceptance Criteria

1. **Containerized Qwen Image 2.1 ComfyUI Runtime (`qwen-ambassador-docker`):** `QwenAmbassadorClient` (`app/services/qwen_ambassador_client.py`) dispatches deterministic ComfyUI workflow graphs to the Dockerized GPU worker with health checks, bounded concurrency, and automatic PNG normalization (`<= 20 MB` input guard, RGB lossless conversion in `commercial_image.py`).
2. **Ambassador Portrait & Character Sheet UI (`ambassador-portrait-ui`):** `pages/ai-studio/ambassadors.tsx` (`CreateAmbassadorDialog.tsx`, `AmbassadorGrid.tsx`, `AmbassadorCard.tsx`, `AmbassadorGeneratorModal.tsx`) supports demographic/wardrobe/brand-persona controls, 1:1 / 3:4 portrait framing, and multi-angle character sheets (`FREE_V1` / configured credit rules).
3. **Commercial Advertising Style Presets (`commercial-image-presets`):** `app/services/image/model_presets.py` and `app/api/v2/endpoints/commercial_image.py` (`POST /api/v2/commercial/generate`) fuse Ambassador reference (`PRESET` or custom Workspace ambassador) + Product image + Scene/Pose preset across aspect buckets `4:5` (`896x1120`), `9:16` (`576x1024`), `16:9` (`1024x576`), `1:1` (`1024x1024`), or `auto`, enforced by `safety_guardrails.py` (`validate_prompt_safety`) and `DA-974` `AMBASSADOR_GENERATE` / `COMMERCIAL_IMAGE` credit settlement.
4. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`aiStudio.ambassador.*`, `aiStudio.commercialImage.*`, `aiStudio.imageStyles.*` in `src/i18n/locales/{vi,en}/aiStudio.json`) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
5. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** `pages/ai-studio/ambassadors.tsx`, `CreateAmbassadorDialog.tsx`, `AmbassadorGeneratorModal.tsx`, `pages/editor/components/{AIImageStudioPanel,AIImageToolsPanel,ImageLightboxModal}.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/{AiModelGeneratorScreen,AiAdImageScreen}.tsx`, `src/utils/saveToLibrary.ts`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `GET /api/v1/ai/ambassadors/presets` | Bearer (`Owner, Manager, Creator`) | `AiGenerationController` -> `ambassador.py` & `model_presets.py` (0-credit catalog) |
| `POST /api/v1/ai/ambassadors/generate & /character-sheet` | Bearer (`Owner, Manager, Creator`) + `Idempotency-Key` | `AiGenerationController` -> `ambassador.py` -> `QwenAmbassadorClient` |
| `POST /api/v1/ai/image/commercial/generate` | Bearer (`Owner, Manager, Creator`) + `Idempotency-Key` | `AiGenerationController` -> `app/api/v2/endpoints/commercial_image.py` (`POST /commercial/generate`) |

## 6. Error Handling, Security & Edge Cases

- **Corrupt / `> 20 MB` Base64 Product Image:** Rejected `413` or `422` in `_normalize_image_bytes()` before reserving GPU worker time, releasing held AI credits immediately.
- **NSFW / Unsafe Prompt Guardrail:** `validate_prompt_safety()` blocks prohibited prompts (`422`) prior to ComfyUI execution.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [FR 3.7.7 — Generate Ambassador](../../../srs/06-ai-features/3-7-7-generate-ambassador/spec.md) · [FR 3.7.8 — View Image Style Template](../../../srs/06-ai-features/3-7-8-view-image-style-template/spec.md) · [FR 3.7.9 — Generate Image](../../../srs/06-ai-features/3-7-9-generate-image/spec.md)
- **BA & Architecture References:** [BA 06 AI Features](../../../../ba/06-ai-features.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).
