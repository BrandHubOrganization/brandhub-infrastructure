> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.8.11 — Publish Instagram Post

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.8.11` |
| **Use Case ID** | `UC-117` |
| **Feature** | Publish Instagram Post |
| **Domain** | Publishing & Social (`3.8`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Business Rules** | `BR-20, BR-57, BR-60` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07, MSG46` |
| **Status** | Implemented — Production Verified |

## 1. Objective & Business Value

Publish single-image or multi-asset `CAROUSEL` (`2–10` images/videos) Feed posts with captions and up to `30` hashtags to a connected **Instagram Business / Creator** account via `InstagramPublishServiceImpl` (`https://graph.facebook.com/v19.0/{igUserId}/media` -> `/{igUserId}/media_publish`).

## 2. User Story

As an authorized member holding `Owner, Manager, Creator` in a Workspace, I want to execute **Publish Instagram Post** reliably across BrandHub's supported social publishing pipeline (**Facebook, Instagram, TikTok, Threads**) so that approved brand content is delivered, previewed, scheduled, and audited safely with full tenant isolation (`BR-20, BR-57, BR-60`).

## 3. Acceptance Criteria

1. **Canonical Role & Workspace Scope (`BR-20`):** Only authenticated Workspace members with role in `Owner, Manager, Creator` may invoke the public REST endpoints for `Publish Instagram Post`; unauthorized roles or cross-workspace requests fail deterministically with `403 FORBIDDEN` (`MSG07`).
2. **Four-Platform Scope Discipline:** Strictly supports **Facebook**, **Instagram**, **TikTok**, and **Threads** — legacy/de-scoped platforms (such as Zalo OA or LinkedIn) are rejected at validation boundaries (`MSG02`).
3. **Production Pipeline & Idempotency:**
- **1. Single vs Carousel Container Workflow:** For 1 image, creates `POST /{igUserId}/media` (`image_url`, `caption`); for `2–10` items, creates child containers with `is_carousel_item=true`, then creates parent container (`media_type=CAROUSEL`, `children=...`, `caption`).
- **2. Container Readiness Polling & Permalink Fetch:** Polls `GET /{creationId}?fields=status_code,status` until `FINISHED`, calls `POST /{igUserId}/media_publish`, and fetches `GET /{igMediaId}?fields=permalink,shortcode` to store the live `https://www.instagram.com/p/{shortcode}/` URL.
4. **Token & Credential Security:** Raw OAuth access/refresh tokens are encrypted at rest via AES-256-GCM (`CryptoUtils`) and never returned in client-facing `ApiResponse<T>` DTOs or written to application logs.
5. **Internationalization (`vi.json` + `en.json`):** All buttons, platform badges, status pills, validation alerts, and modal copy use synchronized key-parallel entries (`editor.publish.instagramFeed.*`, `posts.platform.instagram` in `vi.json` & `en.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces (`pages/editor/index.tsx`, `InstagramMockup.tsx`, `PlatformPreviewModal.tsx` on Web and `src/screens/more/PostDashboardScreen.tsx`, `src/screens/content/PostDetailScreen.tsx` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/editor/index.tsx`, `InstagramMockup.tsx`, `PlatformPreviewModal.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/PostDashboardScreen.tsx`, `src/screens/content/PostDetailScreen.tsx`
- **UI States:**
  - **Loading / In-Flight:** Skeleton placeholders on read views; spinner + disabled action button on mutations to prevent duplicate submissions.
  - **Empty:** Contextual guidance card (e.g., prompt to connect social account via FR 3.8.1 or create/schedule a post via FR 3.8.6) with localized CTA.
  - **Success:** Immediate `TanStack Query` cache invalidation, live status badge update, and localized toast notification.
  - **Error / Retryable Failure:** Structured inline banner displaying localized error reason mapped from `MSG01, MSG02, MSG03, MSG07, MSG46` without losing draft edits.

## 5. API & Messaging Contract

| Endpoint / Upstream Route | Auth / Security | Controller / Service Handler |
| :--- | :--- | :--- |
| `POST /api/v1/workspaces/{workspaceId}/posts/{postId}/publish` | Bearer (`Owner, Manager, Creator`) | `PostController.publish()` -> validates IG Feed media (`1..10` items, caption `<= 2200` chars) & enqueues `PublishJobMessage` (`platform=INSTAGRAM`, `placement=FEED`) |
| `POST https://graph.facebook.com/v19.0/{igUserId}/media & /media_publish` | Decrypted Meta Access Token | `InstagramPublishServiceImpl` -> creates single or `CAROUSEL` child/parent containers, polls `status_code=FINISHED`, and calls `/media_publish` |

## 6. Error Handling & Edge Cases

- `IG_TEXT_ONLY_UNSUPPORTED` (`400`, `MSG02`): Instagram Feed requires at least 1 image/video (`<= 10` carousel items).
- `IG_PUBLISHING_LIMIT_EXCEEDED` (`429` / Graph `9`, `MSG46`): Account hit Meta's rolling 24h `content_publishing_limit`.
- **Duplicate Delivery / Network Retry:** `PublishJobConsumer` enforces Redis lock `processingPostIds:{postId}:{platform}` (`30m` TTL) and `DefaultClassMapper` cross-service `PublishJobMessage` compatibility so broker redeliveries never double-post to a Client's live social feed.

## 7. Related Specifications & References

- **Domain Index & Sibling FRs:** [3.8 Publishing & Social Index](../README.md) · [FR 3.8.1 — Connect Social Account](../3-8-1-connect-social-account/spec.md) · [FR 3.8.7 — Track Post Status](../3-8-7-track-post-status/spec.md)
- **Consolidated Extension Module:** [`social-publisher-resilience`](../../../modules/07-billing-publisher-and-observability/social-publisher-resilience/spec.md)
- **BA Domain Baseline:** [BA 3.8 Publishing & Social](../../../../ba/07-publishing-social.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified across `brandhub-business-service` and `brandhub-publisher-service` JUnit suites, RabbitMQ + Redis lock integration checks, Web & Mobile UI integration, `vi.json`/`en.json` parity, and Light/Dark mode verification ([test.md](./test.md)).
- **Out of Scope:** De-scoped platforms (Zalo OA), livestream broadcasting, or automated paid ad-spend boosting.
