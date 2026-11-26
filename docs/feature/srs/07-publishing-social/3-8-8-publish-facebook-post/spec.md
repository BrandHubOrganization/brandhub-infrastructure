> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.8.8 — Publish Facebook Post

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.8.8` |
| **Use Case ID** | `UC-114` |
| **Feature** | Publish Facebook Post |
| **Domain** | Publishing & Social (`3.8`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Business Rules** | `BR-20, BR-57, BR-59` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07, MSG45` |
| **Status** | Implemented — Production Verified |

## 1. Objective & Business Value

Publish approved text, single-photo, multi-photo album (`2–10` images), or standard video Feed posts to a connected **Facebook Page** via `POST /api/v1/workspaces/{workspaceId}/posts/{postId}/publish` -> RabbitMQ -> `FacebookPublishServiceImpl` (`https://graph.facebook.com/v19.0`).

## 2. User Story

As an authorized member holding `Owner, Manager, Creator` in a Workspace, I want to execute **Publish Facebook Post** reliably across BrandHub's supported social publishing pipeline (**Facebook, Instagram, TikTok, Threads**) so that approved brand content is delivered, previewed, scheduled, and audited safely with full tenant isolation (`BR-20, BR-57, BR-59`).

## 3. Acceptance Criteria

1. **Canonical Role & Workspace Scope (`BR-20`):** Only authenticated Workspace members with role in `Owner, Manager, Creator` may invoke the public REST endpoints for `Publish Facebook Post`; unauthorized roles or cross-workspace requests fail deterministically with `403 FORBIDDEN` (`MSG07`).
2. **Four-Platform Scope Discipline:** Strictly supports **Facebook**, **Instagram**, **TikTok**, and **Threads** — legacy/de-scoped platforms (such as Zalo OA or LinkedIn) are rejected at validation boundaries (`MSG02`).
3. **Production Pipeline & Idempotency:**
- **1. Multi-Modal Graph API Dispatch (`FacebookPublishServiceImpl`):** Text/link posts call `POST /{pageId}/feed`; single-photo posts call `POST /{pageId}/photos` (`published=true`); multi-photo posts upload each image with `published=false` to collect `media_fbid`s and publish atomically via `POST /{pageId}/feed` with `attached_media[i]`; standard feed videos call `POST /{pageId}/videos`.
- **2. Token Decryption & Permalink Resolution:** Decrypts Page token in memory via `CryptoUtils`, executes publish under `processingPostIds:{postId}:FACEBOOK`, resolves canonical `https://www.facebook.com/{post_id}` permalink, and reports `PublishResult` to `business-service`.
4. **Token & Credential Security:** Raw OAuth access/refresh tokens are encrypted at rest via AES-256-GCM (`CryptoUtils`) and never returned in client-facing `ApiResponse<T>` DTOs or written to application logs.
5. **Internationalization (`vi.json` + `en.json`):** All buttons, platform badges, status pills, validation alerts, and modal copy use synchronized key-parallel entries (`editor.publish.facebookFeed.*`, `posts.platform.facebook` in `vi.json` & `en.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces (`pages/editor/index.tsx`, `FacebookMockup.tsx`, `EditorHeaderActions.tsx` on Web and `src/screens/more/PostDashboardScreen.tsx`, `src/screens/content/PostDetailScreen.tsx` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/editor/index.tsx`, `FacebookMockup.tsx`, `EditorHeaderActions.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/PostDashboardScreen.tsx`, `src/screens/content/PostDetailScreen.tsx`
- **UI States:**
  - **Loading / In-Flight:** Skeleton placeholders on read views; spinner + disabled action button on mutations to prevent duplicate submissions.
  - **Empty:** Contextual guidance card (e.g., prompt to connect social account via FR 3.8.1 or create/schedule a post via FR 3.8.6) with localized CTA.
  - **Success:** Immediate `TanStack Query` cache invalidation, live status badge update, and localized toast notification.
  - **Error / Retryable Failure:** Structured inline banner displaying localized error reason mapped from `MSG01, MSG02, MSG03, MSG07, MSG45` without losing draft edits.

## 5. API & Messaging Contract

| Endpoint / Upstream Route | Auth / Security | Controller / Service Handler |
| :--- | :--- | :--- |
| `POST /api/v1/workspaces/{workspaceId}/posts/{postId}/publish` | Bearer (`Owner, Manager, Creator`) | `PostController.publish()` -> validates Facebook Page target & enqueues `PublishJobMessage` (`platform=FACEBOOK`, `placement=FEED`) |
| `POST https://graph.facebook.com/v19.0/{pageId}/feed | /photos | /videos` | Decrypted Page Access Token | `FacebookPublishServiceImpl` (`brandhub-publisher-service`) -> executes Graph API Feed/Photo/Video publish |

## 6. Error Handling & Edge Cases

- `FB_OAUTH_PERMISSION_MISSING` (`190` / `200` Graph code, `MSG45`): Page token expired or lacks `pages_manage_posts` -> marks account `TOKEN_EXPIRED` without futile retries.
- `FB_RATE_LIMIT` (`4` / `32` / `613` Graph code): Classified transient -> scheduled onto `publish.jobs.retry.1m/5m/15m`.
- **Duplicate Delivery / Network Retry:** `PublishJobConsumer` enforces Redis lock `processingPostIds:{postId}:{platform}` (`30m` TTL) and `DefaultClassMapper` cross-service `PublishJobMessage` compatibility so broker redeliveries never double-post to a Client's live social feed.

## 7. Related Specifications & References

- **Domain Index & Sibling FRs:** [3.8 Publishing & Social Index](../README.md) · [FR 3.8.1 — Connect Social Account](../3-8-1-connect-social-account/spec.md) · [FR 3.8.7 — Track Post Status](../3-8-7-track-post-status/spec.md)
- **Consolidated Extension Module:** [`social-publisher-resilience`](../../../modules/07-billing-publisher-and-observability/social-publisher-resilience/spec.md)
- **BA Domain Baseline:** [BA 3.8 Publishing & Social](../../../../ba/07-publishing-social.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified across `brandhub-business-service` and `brandhub-publisher-service` JUnit suites, RabbitMQ + Redis lock integration checks, Web & Mobile UI integration, `vi.json`/`en.json` parity, and Light/Dark mode verification ([test.md](./test.md)).
- **Out of Scope:** De-scoped platforms (Zalo OA), livestream broadcasting, or automated paid ad-spend boosting.
