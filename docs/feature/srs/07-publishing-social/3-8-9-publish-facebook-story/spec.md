> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.8.9 — Publish Facebook Story

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.8.9` |
| **Use Case ID** | `UC-115` |
| **Feature** | Publish Facebook Story |
| **Domain** | Publishing & Social (`3.8`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Business Rules** | `BR-20, BR-57, BR-59` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07, MSG45` |
| **Status** | Implemented — Production Verified |

## 1. Objective & Business Value

Publish vertical (`9:16`) ephemeral 24-hour Photo Stories or Video Stories (`<= 60s`) to a connected **Facebook Page** via `FacebookPublishServiceImpl` using Meta Graph API `v19.0` Page Stories endpoints (`/{pageId}/photo_stories` and `/{pageId}/video_stories`).

## 2. User Story

As an authorized member holding `Owner, Manager, Creator` in a Workspace, I want to execute **Publish Facebook Story** reliably across BrandHub's supported social publishing pipeline (**Facebook, Instagram, TikTok, Threads**) so that approved brand content is delivered, previewed, scheduled, and audited safely with full tenant isolation (`BR-20, BR-57, BR-59`).

## 3. Acceptance Criteria

1. **Canonical Role & Workspace Scope (`BR-20`):** Only authenticated Workspace members with role in `Owner, Manager, Creator` may invoke the public REST endpoints for `Publish Facebook Story`; unauthorized roles or cross-workspace requests fail deterministically with `403 FORBIDDEN` (`MSG07`).
2. **Four-Platform Scope Discipline:** Strictly supports **Facebook**, **Instagram**, **TikTok**, and **Threads** — legacy/de-scoped platforms (such as Zalo OA or LinkedIn) are rejected at validation boundaries (`MSG02`).
3. **Production Pipeline & Idempotency:**
- **1. Story Media Pre-Validation:** Enforces exactly `1` media item per Story job: JPEG/PNG (`<= 10 MB`) for Photo Story, or H.264/AAC MP4 (`9:16`, `3s–60s`) for Video Story.
- **2. Two-Phase Video Story Upload:** For video stories, `FacebookPublishServiceImpl` initializes `POST /{pageId}/video_stories` (`upload_phase=start`) to obtain `video_id` and `upload_url`, streams/transfers the S3 presigned media, polls processing readiness, and finalizes with `upload_phase=finish`.
4. **Token & Credential Security:** Raw OAuth access/refresh tokens are encrypted at rest via AES-256-GCM (`CryptoUtils`) and never returned in client-facing `ApiResponse<T>` DTOs or written to application logs.
5. **Internationalization (`vi.json` + `en.json`):** All buttons, platform badges, status pills, validation alerts, and modal copy use synchronized key-parallel entries (`editor.publish.facebookStory.*`, `editor.placement.story` in `vi.json` & `en.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces (`pages/editor/index.tsx` (Placement = `Story`), `PhoneFrame.tsx`, `FacebookMockup.tsx` on Web and `src/screens/content/PostDetailScreen.tsx`, `src/screens/content-writing/SocialPreview.tsx` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/editor/index.tsx` (Placement = `Story`), `PhoneFrame.tsx`, `FacebookMockup.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/content/PostDetailScreen.tsx`, `src/screens/content-writing/SocialPreview.tsx`
- **UI States:**
  - **Loading / In-Flight:** Skeleton placeholders on read views; spinner + disabled action button on mutations to prevent duplicate submissions.
  - **Empty:** Contextual guidance card (e.g., prompt to connect social account via FR 3.8.1 or create/schedule a post via FR 3.8.6) with localized CTA.
  - **Success:** Immediate `TanStack Query` cache invalidation, live status badge update, and localized toast notification.
  - **Error / Retryable Failure:** Structured inline banner displaying localized error reason mapped from `MSG01, MSG02, MSG03, MSG07, MSG45` without losing draft edits.

## 5. API & Messaging Contract

| Endpoint / Upstream Route | Auth / Security | Controller / Service Handler |
| :--- | :--- | :--- |
| `POST /api/v1/workspaces/{workspaceId}/posts/{postId}/publish` | Bearer (`Owner, Manager, Creator`) | `PostController.publish()` -> validates single vertical image/video & dispatches `PublishJobMessage` (`platform=FACEBOOK`, `placement=STORY`) |
| `POST https://graph.facebook.com/v19.0/{pageId}/photo_stories | /video_stories` | Decrypted Page Access Token | `FacebookPublishServiceImpl` -> 2-phase photo/video story session (`upload_phase=start` -> upload -> `upload_phase=finish`) |

## 6. Error Handling & Edge Cases

- `INVALID_STORY_MEDIA` (`400`, `MSG02`): Missing media (text-only Story unsupported via Graph API), multiple attachments, or duration `> 60s`.
- `FB_STORY_UPLOAD_FAILED` (`502/503`, `MSG45`): Upload session interrupted -> retried safely via `publisher.retry.exchange`.
- **Duplicate Delivery / Network Retry:** `PublishJobConsumer` enforces Redis lock `processingPostIds:{postId}:{platform}` (`30m` TTL) and `DefaultClassMapper` cross-service `PublishJobMessage` compatibility so broker redeliveries never double-post to a Client's live social feed.

## 7. Related Specifications & References

- **Domain Index & Sibling FRs:** [3.8 Publishing & Social Index](../README.md) · [FR 3.8.1 — Connect Social Account](../3-8-1-connect-social-account/spec.md) · [FR 3.8.7 — Track Post Status](../3-8-7-track-post-status/spec.md)
- **Consolidated Extension Module:** [`social-publisher-resilience`](../../../modules/07-billing-publisher-and-observability/social-publisher-resilience/spec.md)
- **BA Domain Baseline:** [BA 3.8 Publishing & Social](../../../../ba/07-publishing-social.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified across `brandhub-business-service` and `brandhub-publisher-service` JUnit suites, RabbitMQ + Redis lock integration checks, Web & Mobile UI integration, `vi.json`/`en.json` parity, and Light/Dark mode verification ([test.md](./test.md)).
- **Out of Scope:** De-scoped platforms (Zalo OA), livestream broadcasting, or automated paid ad-spend boosting.
