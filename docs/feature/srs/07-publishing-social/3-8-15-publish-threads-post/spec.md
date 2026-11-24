> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.8.15 — Publish Threads Post

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.8.15` |
| **Use Case ID** | `UC-121` |
| **Feature** | Publish Threads Post |
| **Domain** | Publishing & Social (`3.8`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Business Rules** | `BR-20, BR-57, BR-62` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07, MSG48` |
| **Status** | Implemented — Production Verified |

## 1. Objective & Business Value

Publish `TEXT` (`<= 500` characters), `IMAGE`, `VIDEO`, or multi-item `CAROUSEL` (`2–20` attachments) posts to a connected **Threads** profile via `ThreadsPublishServiceImpl` using the official Threads Graph API `v1.0` (`https://graph.threads.net/v1.0/{threadsUserId}/threads` -> `/{threadsUserId}/threads_publish`).

## 2. User Story

As an authorized member holding `Owner, Manager, Creator` in a Workspace, I want to execute **Publish Threads Post** reliably across BrandHub's supported social publishing pipeline (**Facebook, Instagram, TikTok, Threads**) so that approved brand content is delivered, previewed, scheduled, and audited safely with full tenant isolation (`BR-20, BR-57, BR-62`).

## 3. Acceptance Criteria

1. **Canonical Role & Workspace Scope (`BR-20`):** Only authenticated Workspace members with role in `Owner, Manager, Creator` may invoke the public REST endpoints for `Publish Threads Post`; unauthorized roles or cross-workspace requests fail deterministically with `403 FORBIDDEN` (`MSG07`).
2. **Four-Platform Scope Discipline:** Strictly supports **Facebook**, **Instagram**, **TikTok**, and **Threads** — legacy/de-scoped platforms (such as Zalo OA or LinkedIn) are rejected at validation boundaries (`MSG02`).
3. **Production Pipeline & Idempotency:**
- **1. Four-Mode Threads Container Builder (`ThreadsPublishServiceImpl`):** Supports `media_type=TEXT` (`text` required, `1–500` UTF-8 chars), `IMAGE` (`image_url` + optional `text`), `VIDEO` (`video_url` + optional `text`), and `CAROUSEL` (`2–20` `is_carousel_item=true` child containers joined via `children=...`).
- **2. Readiness Poll & Permalink Fetch:** Polls `GET /{creationId}?fields=status,error_message` (crucial for video/carousel containers), invokes `POST /{threadsUserId}/threads_publish`, and queries `GET /{threadsMediaId}?fields=permalink` to persist `https://www.threads.net/@{username}/post/{code}`.
4. **Token & Credential Security:** Raw OAuth access/refresh tokens are encrypted at rest via AES-256-GCM (`CryptoUtils`) and never returned in client-facing `ApiResponse<T>` DTOs or written to application logs.
5. **Internationalization (`vi.json` + `en.json`):** All buttons, platform badges, status pills, validation alerts, and modal copy use synchronized key-parallel entries (`editor.publish.threads.*`, `editor.threads.charLimitWarning` in `vi.json` & `en.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces (`pages/editor/index.tsx` (`500`-char counter), `ThreadsMockup.tsx`, `PlatformPreviewModal.tsx` on Web and `src/screens/content-writing/SocialPreview.tsx`, `src/screens/content/PostDetailScreen.tsx` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/editor/index.tsx` (`500`-char counter), `ThreadsMockup.tsx`, `PlatformPreviewModal.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/content-writing/SocialPreview.tsx`, `src/screens/content/PostDetailScreen.tsx`
- **UI States:**
  - **Loading / In-Flight:** Skeleton placeholders on read views; spinner + disabled action button on mutations to prevent duplicate submissions.
  - **Empty:** Contextual guidance card (e.g., prompt to connect social account via FR 3.8.1 or create/schedule a post via FR 3.8.6) with localized CTA.
  - **Success:** Immediate `TanStack Query` cache invalidation, live status badge update, and localized toast notification.
  - **Error / Retryable Failure:** Structured inline banner displaying localized error reason mapped from `MSG01, MSG02, MSG03, MSG07, MSG48` without losing draft edits.

## 5. API & Messaging Contract

| Endpoint / Upstream Route | Auth / Security | Controller / Service Handler |
| :--- | :--- | :--- |
| `POST /api/v1/workspaces/{workspaceId}/posts/{postId}/publish` | Bearer (`Owner, Manager, Creator`) | `PostController.publish()` -> validates `<= 500` char text limit & enqueues `PublishJobMessage` (`platform=THREADS`, `placement=FEED`) |
| `POST https://graph.threads.net/v1.0/{threadsUserId}/threads & /threads_publish` | Decrypted Threads Long-Lived Token | `ThreadsPublishServiceImpl` (`brandhub-publisher-service`) -> container creation, status check, publish, and permalink lookup |

## 6. Error Handling & Edge Cases

- `THREADS_TEXT_TOO_LONG` (`400`, `MSG02`): Caption exceeds `500` characters for a Threads target.
- `THREADS_TOKEN_EXPIRED` (`190`, `MSG48`): Long-lived Threads token expired and refresh (`https://graph.threads.net/refresh_access_token`) failed.
- **Duplicate Delivery / Network Retry:** `PublishJobConsumer` enforces Redis lock `processingPostIds:{postId}:{platform}` (`30m` TTL) and `DefaultClassMapper` cross-service `PublishJobMessage` compatibility so broker redeliveries never double-post to a Client's live social feed.

## 7. Related Specifications & References

- **Domain Index & Sibling FRs:** [3.8 Publishing & Social Index](../README.md) · [FR 3.8.1 — Connect Social Account](../3-8-1-connect-social-account/spec.md) · [FR 3.8.7 — Track Post Status](../3-8-7-track-post-status/spec.md)
- **Consolidated Extension Module:** [`social-publisher-resilience`](../../../modules/07-billing-publisher-and-observability/social-publisher-resilience/spec.md)
- **BA Domain Baseline:** [BA 3.8 Publishing & Social](../../../../ba/07-publishing-social.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified across `brandhub-business-service` and `brandhub-publisher-service` JUnit suites, RabbitMQ + Redis lock integration checks, Web & Mobile UI integration, `vi.json`/`en.json` parity, and Light/Dark mode verification ([test.md](./test.md)).
- **Out of Scope:** De-scoped platforms (Zalo OA), livestream broadcasting, or automated paid ad-spend boosting.
