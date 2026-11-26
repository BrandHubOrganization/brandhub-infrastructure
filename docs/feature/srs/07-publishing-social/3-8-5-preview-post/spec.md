> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.8.5 — Preview Post

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.8.5` |
| **Use Case ID** | `UC-111` |
| **Feature** | Preview Post |
| **Domain** | Publishing & Social (`3.8`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Business Rules** | `BR-20, BR-56` |
| **Message Codes** | `MSG01, MSG02, MSG07` |
| **Status** | Implemented — Production Verified |

## 1. Objective & Business Value

Render interactive, pixel-accurate native UI mockups of a draft or scheduled post across **Facebook** (Feed/Story/Reels), **Instagram** (Feed/Carousel/Reels/Story), **TikTok** (9:16 vertical player with right-rail icons & bottom caption safe-zone), and **Threads** (500-char conversational card) prior to approval, scheduling, or immediate publication.

## 2. User Story

As an authorized member holding `Owner, Manager, Creator, Client` in a Workspace, I want to execute **Preview Post** reliably across BrandHub's supported social publishing pipeline (**Facebook, Instagram, TikTok, Threads**) so that approved brand content is delivered, previewed, scheduled, and audited safely with full tenant isolation (`BR-20, BR-56`).

## 3. Acceptance Criteria

1. **Canonical Role & Workspace Scope (`BR-20`):** Only authenticated Workspace members with role in `Owner, Manager, Creator, Client` may invoke the public REST endpoints for `Preview Post`; unauthorized roles or cross-workspace requests fail deterministically with `403 FORBIDDEN` (`MSG07`).
2. **Four-Platform Scope Discipline:** Strictly supports **Facebook**, **Instagram**, **TikTok**, and **Threads** — legacy/de-scoped platforms (such as Zalo OA or LinkedIn) are rejected at validation boundaries (`MSG02`).
3. **Production Pipeline & Idempotency:**
- **1. Platform-Specific Format & Safe-Zone Validation (`BR-56`):** Validates caption character thresholds (`Threads <= 500`, `Instagram <= 2,200`, `TikTok <= 2,200`, `Facebook <= 63,206`), hashtag count warnings (`TikTok <= 8`, `Instagram <= 30`, `Facebook <= 5`, `Threads <= 3`), and media aspect ratio compatibility (`9:16` required for Reels/Stories/TikTok; `1:1` / `4:5` / `1.91:1` for IG Feed).
- **2. Interactive Truncation & Media Simulation:** `ExpandableCaption.tsx` simulates native `...Xem thêm / ...more` fold lines; `PhoneFrame.tsx` renders safe-zone overlays so `Creator` and `Client` spot text occluded by TikTok/Reels UI chrome before publishing.
4. **Token & Credential Security:** Raw OAuth access/refresh tokens are encrypted at rest via AES-256-GCM (`CryptoUtils`) and never returned in client-facing `ApiResponse<T>` DTOs or written to application logs.
5. **Internationalization (`vi.json` + `en.json`):** All buttons, platform badges, status pills, validation alerts, and modal copy use synchronized key-parallel entries (`editor.preview.platforms.*`, `editor.preview.safeZoneWarning`, `editor.preview.seeMore` in `src/i18n/locales/{vi,en}/editor.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces (`pages/editor/components/PlatformMockups.tsx`, `PlatformPreviewModal.tsx`, `StudioPreviewPanel.tsx`, `mockups/{FacebookMockup,InstagramMockup,TikTokMockup,ThreadsMockup,PhoneFrame,ExpandableCaption}.tsx`, `pages/content-writing/components/SocialPreview.tsx` on Web and `src/screens/content-writing/SocialPreview.tsx` (`SocialPreview.test.tsx` verified) on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/editor/components/PlatformMockups.tsx`, `PlatformPreviewModal.tsx`, `StudioPreviewPanel.tsx`, `mockups/{FacebookMockup,InstagramMockup,TikTokMockup,ThreadsMockup,PhoneFrame,ExpandableCaption}.tsx`, `pages/content-writing/components/SocialPreview.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/content-writing/SocialPreview.tsx` (`SocialPreview.test.tsx` verified)
- **UI States:**
  - **Loading / In-Flight:** Skeleton placeholders on read views; spinner + disabled action button on mutations to prevent duplicate submissions.
  - **Empty:** Contextual guidance card (e.g., prompt to connect social account via FR 3.8.1 or create/schedule a post via FR 3.8.6) with localized CTA.
  - **Success:** Immediate `TanStack Query` cache invalidation, live status badge update, and localized toast notification.
  - **Error / Retryable Failure:** Structured inline banner displaying localized error reason mapped from `MSG01, MSG02, MSG07` without losing draft edits.

## 5. API & Messaging Contract

| Endpoint / Upstream Route | Auth / Security | Controller / Service Handler |
| :--- | :--- | :--- |
| `GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}/post` | Bearer (`Owner, Manager, Creator, Client`) | `TaskPostController` -> loads draft post payload, media aspect ratios, and connected account branding for live preview |
| `GET /api/v1/workspaces/{workspaceId}/posts/{postId}` | Bearer (`Owner, Manager, Creator, Client`) | `PostController` -> loads saved post configuration for `PlatformPreviewModal` |

## 6. Error Handling & Edge Cases

- `MEDIA_ASPECT_RATIO_WARNING` (Inline UI validation, `MSG02`): Flags incompatible media dimensions (e.g., `16:9` landscape image selected for Instagram Story) before publish submission.
- **Duplicate Delivery / Network Retry:** `PublishJobConsumer` enforces Redis lock `processingPostIds:{postId}:{platform}` (`30m` TTL) and `DefaultClassMapper` cross-service `PublishJobMessage` compatibility so broker redeliveries never double-post to a Client's live social feed.

## 7. Related Specifications & References

- **Domain Index & Sibling FRs:** [3.8 Publishing & Social Index](../README.md) · [FR 3.8.1 — Connect Social Account](../3-8-1-connect-social-account/spec.md) · [FR 3.8.7 — Track Post Status](../3-8-7-track-post-status/spec.md)
- **Consolidated Extension Module:** [`social-publisher-resilience`](../../../modules/07-billing-publisher-and-observability/social-publisher-resilience/spec.md)
- **BA Domain Baseline:** [BA 3.8 Publishing & Social](../../../../ba/07-publishing-social.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified across `brandhub-business-service` and `brandhub-publisher-service` JUnit suites, RabbitMQ + Redis lock integration checks, Web & Mobile UI integration, `vi.json`/`en.json` parity, and Light/Dark mode verification ([test.md](./test.md)).
- **Out of Scope:** De-scoped platforms (Zalo OA), livestream broadcasting, or automated paid ad-spend boosting.
