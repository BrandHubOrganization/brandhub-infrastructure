> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.8.10 — Publish Facebook Reels

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.8.10` |
| **Use Case ID** | `UC-116` |
| **Feature** | Publish Facebook Reels |
| **Domain** | Publishing & Social (`3.8`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Business Rules** | `BR-20, BR-57, BR-59` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07, MSG45` |
| **Status** | Implemented — Production Verified |

## 1. Objective & Business Value

Publish short-form vertical (`9:16`, `3s–90s`) **Facebook Reels** videos with caption and hashtags to a connected Facebook Page via `FacebookPublishServiceImpl` using the Meta Graph API `v19.0` 3-step `/{pageId}/video_reels` pipeline.

## 2. User Story

As an authorized member holding `Owner, Manager, Creator` in a Workspace, I want to execute **Publish Facebook Reels** reliably across BrandHub's supported social publishing pipeline (**Facebook, Instagram, TikTok, Threads**) so that approved brand content is delivered, previewed, scheduled, and audited safely with full tenant isolation (`BR-20, BR-57, BR-59`).

## 3. Acceptance Criteria

1. **Canonical Role & Workspace Scope (`BR-20`):** Only authenticated Workspace members with role in `Owner, Manager, Creator` may invoke the public REST endpoints for `Publish Facebook Reels`; unauthorized roles or cross-workspace requests fail deterministically with `403 FORBIDDEN` (`MSG07`).
2. **Four-Platform Scope Discipline:** Strictly supports **Facebook**, **Instagram**, **TikTok**, and **Threads** — legacy/de-scoped platforms (such as Zalo OA or LinkedIn) are rejected at validation boundaries (`MSG02`).
3. **Production Pipeline & Idempotency:**
- **1. Reels Format Validation:** Requires single MP4/MOV video (`9:16` aspect ratio, `540x960` min, `1080x1920` recommended, `3s–90s` duration).
- **2. Three-Step Reels Session:** Starts upload session (`upload_phase=start`), posts `file_url` header (S3 presigned URL) to `https://rupload.facebook.com/video-upload/v19.0/{video_id}`, polls video encoding status, and invokes `upload_phase=finish` with `video_state=PUBLISHED` and `description`.
4. **Token & Credential Security:** Raw OAuth access/refresh tokens are encrypted at rest via AES-256-GCM (`CryptoUtils`) and never returned in client-facing `ApiResponse<T>` DTOs or written to application logs.
5. **Internationalization (`vi.json` + `en.json`):** All buttons, platform badges, status pills, validation alerts, and modal copy use synchronized key-parallel entries (`editor.publish.facebookReels.*`, `editor.placement.reels` in `vi.json` & `en.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces (`pages/editor/index.tsx` (Placement = `Reels`), `FacebookMockup.tsx`, `PhoneFrame.tsx` on Web and `src/screens/more/QuickReelStudioScreen.tsx`, `src/screens/content/PostDetailScreen.tsx` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/editor/index.tsx` (Placement = `Reels`), `FacebookMockup.tsx`, `PhoneFrame.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/QuickReelStudioScreen.tsx`, `src/screens/content/PostDetailScreen.tsx`
- **UI States:**
  - **Loading / In-Flight:** Skeleton placeholders on read views; spinner + disabled action button on mutations to prevent duplicate submissions.
  - **Empty:** Contextual guidance card (e.g., prompt to connect social account via FR 3.8.1 or create/schedule a post via FR 3.8.6) with localized CTA.
  - **Success:** Immediate `TanStack Query` cache invalidation, live status badge update, and localized toast notification.
  - **Error / Retryable Failure:** Structured inline banner displaying localized error reason mapped from `MSG01, MSG02, MSG03, MSG07, MSG45` without losing draft edits.

## 5. API & Messaging Contract

| Endpoint / Upstream Route | Auth / Security | Controller / Service Handler |
| :--- | :--- | :--- |
| `POST /api/v1/workspaces/{workspaceId}/posts/{postId}/publish` | Bearer (`Owner, Manager, Creator`) | `PostController.publish()` -> validates MP4 Reels constraints & enqueues `PublishJobMessage` (`platform=FACEBOOK`, `placement=REELS`) |
| `POST https://graph.facebook.com/v19.0/{pageId}/video_reels` | Decrypted Page Access Token | `FacebookPublishServiceImpl` -> `upload_phase=start` -> `rupload.facebook.com` `file_url` transfer -> `upload_phase=finish` (`video_state=PUBLISHED`) |

## 6. Error Handling & Edge Cases

- `INVALID_REELS_VIDEO` (`400`, `MSG02`): Non-video attachment or duration outside `3s–90s`.
- `FB_REELS_TRANSCODE_ERROR` (`MSG45`): Meta encoder rejected codec/frame rate -> surfaces exact Graph error message on Post Detail.
- **Duplicate Delivery / Network Retry:** `PublishJobConsumer` enforces Redis lock `processingPostIds:{postId}:{platform}` (`30m` TTL) and `DefaultClassMapper` cross-service `PublishJobMessage` compatibility so broker redeliveries never double-post to a Client's live social feed.

## 7. Related Specifications & References

- **Domain Index & Sibling FRs:** [3.8 Publishing & Social Index](../README.md) · [FR 3.8.1 — Connect Social Account](../3-8-1-connect-social-account/spec.md) · [FR 3.8.7 — Track Post Status](../3-8-7-track-post-status/spec.md)
- **Consolidated Extension Module:** [`social-publisher-resilience`](../../../modules/07-billing-publisher-and-observability/social-publisher-resilience/spec.md)
- **BA Domain Baseline:** [BA 3.8 Publishing & Social](../../../../ba/07-publishing-social.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified across `brandhub-business-service` and `brandhub-publisher-service` JUnit suites, RabbitMQ + Redis lock integration checks, Web & Mobile UI integration, `vi.json`/`en.json` parity, and Light/Dark mode verification ([test.md](./test.md)).
- **Out of Scope:** De-scoped platforms (Zalo OA), livestream broadcasting, or automated paid ad-spend boosting.
