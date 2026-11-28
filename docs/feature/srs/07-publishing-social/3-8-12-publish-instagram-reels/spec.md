> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.8.12 — Publish Instagram Reels

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.8.12` |
| **Use Case ID** | `UC-118` |
| **Feature** | Publish Instagram Reels |
| **Domain** | Publishing & Social (`3.8`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Business Rules** | `BR-20, BR-57, BR-60` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07, MSG46` |
| **Status** | Implemented — Production Verified |

## 1. Objective & Business Value

Publish vertical (`9:16`) **Instagram Reels** (`media_type=REELS`) with caption, optional custom cover frame (`cover_url`), and `share_to_feed` toggle to a connected Instagram Business / Creator account via `InstagramPublishServiceImpl`.

## 2. User Story

As an authorized member holding `Owner, Manager, Creator` in a Workspace, I want to execute **Publish Instagram Reels** reliably across BrandHub's supported social publishing pipeline (**Facebook, Instagram, TikTok, Threads**) so that approved brand content is delivered, previewed, scheduled, and audited safely with full tenant isolation (`BR-20, BR-57, BR-60`).

## 3. Acceptance Criteria

1. **Canonical Role & Workspace Scope (`BR-20`):** Only authenticated Workspace members with role in `Owner, Manager, Creator` may invoke the public REST endpoints for `Publish Instagram Reels`; unauthorized roles or cross-workspace requests fail deterministically with `403 FORBIDDEN` (`MSG07`).
2. **Four-Platform Scope Discipline:** Strictly supports **Facebook**, **Instagram**, **TikTok**, and **Threads** — legacy/de-scoped platforms (such as Zalo OA or LinkedIn) are rejected at validation boundaries (`MSG02`).
3. **Production Pipeline & Idempotency:**
- **1. Reels Container Creation:** Submits `media_type=REELS`, `video_url` (S3 presigned HTTPS URL), `caption` (`<= 2,200` chars, `<= 30` hashtags), and `share_to_feed=true|false`.
- **2. Bounded Transcode Polling:** Polls container `status_code` with backoff up to bounded timeout; if `status_code=ERROR`, extracts Meta error subcode (e.g. unsupported audio/video codec) and marks permanent failure; once `FINISHED`, calls `/media_publish`.
4. **Token & Credential Security:** Raw OAuth access/refresh tokens are encrypted at rest via AES-256-GCM (`CryptoUtils`) and never returned in client-facing `ApiResponse<T>` DTOs or written to application logs.
5. **Internationalization (`vi.json` + `en.json`):** All buttons, platform badges, status pills, validation alerts, and modal copy use synchronized key-parallel entries (`editor.publish.instagramReels.*`, `editor.publish.shareToFeed` in `vi.json` & `en.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces (`pages/editor/index.tsx` (Placement = `Reels`), `InstagramMockup.tsx`, `PhoneFrame.tsx` on Web and `src/screens/more/QuickReelStudioScreen.tsx`, `src/screens/content/PostDetailScreen.tsx` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/editor/index.tsx` (Placement = `Reels`), `InstagramMockup.tsx`, `PhoneFrame.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/QuickReelStudioScreen.tsx`, `src/screens/content/PostDetailScreen.tsx`
- **UI States:**
  - **Loading / In-Flight:** Skeleton placeholders on read views; spinner + disabled action button on mutations to prevent duplicate submissions.
  - **Empty:** Contextual guidance card (e.g., prompt to connect social account via FR 3.8.1 or create/schedule a post via FR 3.8.6) with localized CTA.
  - **Success:** Immediate `TanStack Query` cache invalidation, live status badge update, and localized toast notification.
  - **Error / Retryable Failure:** Structured inline banner displaying localized error reason mapped from `MSG01, MSG02, MSG03, MSG07, MSG46` without losing draft edits.

## 5. API & Messaging Contract

| Endpoint / Upstream Route | Auth / Security | Controller / Service Handler |
| :--- | :--- | :--- |
| `POST /api/v1/workspaces/{workspaceId}/posts/{postId}/publish` | Bearer (`Owner, Manager, Creator`) | `PostController.publish()` -> validates MP4/MOV video & enqueues `PublishJobMessage` (`platform=INSTAGRAM`, `placement=REELS`) |
| `POST https://graph.facebook.com/v19.0/{igUserId}/media (`media_type=REELS`) -> /media_publish` | Decrypted Meta Access Token | `InstagramPublishServiceImpl` -> creates Reels container, polls `IN_PROGRESS -> FINISHED`, publishes & resolves `/reel/{shortcode}/` permalink |

## 6. Error Handling & Edge Cases

- `IG_REELS_CONTAINER_ERROR` (`422`, `MSG46`): Container status returned `ERROR` or `EXPIRED` during Meta video transcoding.
- **Duplicate Delivery / Network Retry:** `PublishJobConsumer` enforces Redis lock `processingPostIds:{postId}:{platform}` (`30m` TTL) and `DefaultClassMapper` cross-service `PublishJobMessage` compatibility so broker redeliveries never double-post to a Client's live social feed.

## 7. Related Specifications & References

- **Domain Index & Sibling FRs:** [3.8 Publishing & Social Index](../README.md) · [FR 3.8.1 — Connect Social Account](../3-8-1-connect-social-account/spec.md) · [FR 3.8.7 — Track Post Status](../3-8-7-track-post-status/spec.md)
- **Consolidated Extension Module:** [`social-publisher-resilience`](../../../modules/07-billing-publisher-and-observability/social-publisher-resilience/spec.md)
- **BA Domain Baseline:** [BA 3.8 Publishing & Social](../../../../ba/07-publishing-social.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified across `brandhub-business-service` and `brandhub-publisher-service` JUnit suites, RabbitMQ + Redis lock integration checks, Web & Mobile UI integration, `vi.json`/`en.json` parity, and Light/Dark mode verification ([test.md](./test.md)).
- **Out of Scope:** De-scoped platforms (Zalo OA), livestream broadcasting, or automated paid ad-spend boosting.
