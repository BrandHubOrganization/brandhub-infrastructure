> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.8.14 — Publish TikTok Video

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.8.14` |
| **Use Case ID** | `UC-120` |
| **Feature** | Publish TikTok Video |
| **Domain** | Publishing & Social (`3.8`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Business Rules** | `BR-20, BR-57, BR-61` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07, MSG47` |
| **Status** | Implemented — Production Verified |

## 1. Objective & Business Value

Publish vertical (`9:16`) MP4 videos to a connected **TikTok** account via `TikTokPublishServiceImpl` and `TikTokCreatorUploadService` using TikTok Content Posting API v2 (`creator_info/query` -> `video/init` Direct Post / Chunk Upload -> `status/fetch` polling) with TikTok UX compliance controls (`privacy_level`, comment/duet/stitch toggles, commercial content disclosure).

## 2. User Story

As an authorized member holding `Owner, Manager, Creator` in a Workspace, I want to execute **Publish TikTok Video** reliably across BrandHub's supported social publishing pipeline (**Facebook, Instagram, TikTok, Threads**) so that approved brand content is delivered, previewed, scheduled, and audited safely with full tenant isolation (`BR-20, BR-57, BR-61`).

## 3. Acceptance Criteria

1. **Canonical Role & Workspace Scope (`BR-20`):** Only authenticated Workspace members with role in `Owner, Manager, Creator` may invoke the public REST endpoints for `Publish TikTok Video`; unauthorized roles or cross-workspace requests fail deterministically with `403 FORBIDDEN` (`MSG07`).
2. **Four-Platform Scope Discipline:** Strictly supports **Facebook**, **Instagram**, **TikTok**, and **Threads** — legacy/de-scoped platforms (such as Zalo OA or LinkedIn) are rejected at validation boundaries (`MSG02`).
3. **Production Pipeline & Idempotency:**
- **1. Creator Capability Pre-Flight (`creator_info/query`):** Queries allowed `privacy_level_options` (`PUBLIC_TO_EVERYONE`, `MUTUAL_FOLLOW_FRIENDS`, `SELF_ONLY`), `max_video_post_duration_sec`, and duet/stitch/comment flags so compliance rules (`BR-61`) are respected.
- **2. Direct Post Init & Transfer:** Calls `POST https://open.tiktokapis.com/v2/post/publish/video/init/` with `post_info` (`title`/caption `<= 2,200` chars, `privacy_level`, `disable_duet`, `disable_stitch`, `disable_comment`, `video_cover_timestamp_ms`) and `source_info` (`PULL_FROM_URL` verified domain or chunked `FILE_UPLOAD` via `TikTokCreatorUploadService`).
- **3. Asynchronous Publish Status Polling:** Polls `POST /v2/post/publish/status/fetch/` with `publish_id` until `PUBLISH_COMPLETE` (recording `publicaly_available_post_id`) or `FAILED` (`fail_reason`).
4. **Token & Credential Security:** Raw OAuth access/refresh tokens are encrypted at rest via AES-256-GCM (`CryptoUtils`) and never returned in client-facing `ApiResponse<T>` DTOs or written to application logs.
5. **Internationalization (`vi.json` + `en.json`):** All buttons, platform badges, status pills, validation alerts, and modal copy use synchronized key-parallel entries (`editor.publish.tiktok.*`, `editor.tiktok.{privacyLevel,allowComments,allowDuet,allowStitch}` in `vi.json` & `en.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces (`pages/editor/index.tsx` (TikTok privacy/interaction settings), `TikTokMockup.tsx` on Web and `src/screens/more/QuickReelStudioScreen.tsx`, `src/screens/content/PostDetailScreen.tsx` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/editor/index.tsx` (TikTok privacy/interaction settings), `TikTokMockup.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/QuickReelStudioScreen.tsx`, `src/screens/content/PostDetailScreen.tsx`
- **UI States:**
  - **Loading / In-Flight:** Skeleton placeholders on read views; spinner + disabled action button on mutations to prevent duplicate submissions.
  - **Empty:** Contextual guidance card (e.g., prompt to connect social account via FR 3.8.1 or create/schedule a post via FR 3.8.6) with localized CTA.
  - **Success:** Immediate `TanStack Query` cache invalidation, live status badge update, and localized toast notification.
  - **Error / Retryable Failure:** Structured inline banner displaying localized error reason mapped from `MSG01, MSG02, MSG03, MSG07, MSG47` without losing draft edits.

## 5. API & Messaging Contract

| Endpoint / Upstream Route | Auth / Security | Controller / Service Handler |
| :--- | :--- | :--- |
| `POST /api/v1/workspaces/{workspaceId}/posts/{postId}/publish` | Bearer (`Owner, Manager, Creator`) | `PostController.publish()` -> validates `TikTokDirectPostRequest` metadata & enqueues `PublishJobMessage` (`platform=TIKTOK`, `placement=VIDEO`) |
| `POST https://open.tiktokapis.com/v2/post/publish/creator_info/query/ & /video/init/` | Decrypted TikTok OAuth2 Bearer Token | `TikTokPublishServiceImpl` & `TikTokCreatorUploadService` (`brandhub-publisher-service`) |

## 6. Error Handling & Edge Cases

- `TIKTOK_SPAM_RISK_TOO_MANY_POSTS` (`spam_risk_too_many_posts`, `MSG47`): Daily creator cap reached on TikTok.
- `TIKTOK_UNAUDITED_CLIENT_PRIVACY` (`unaudited_client_can_only_post_to_private_accounts`): Sandbox app mode gracefully informs user to select `SELF_ONLY` or audited app credentials.
- **Duplicate Delivery / Network Retry:** `PublishJobConsumer` enforces Redis lock `processingPostIds:{postId}:{platform}` (`30m` TTL) and `DefaultClassMapper` cross-service `PublishJobMessage` compatibility so broker redeliveries never double-post to a Client's live social feed.

## 7. Related Specifications & References

- **Domain Index & Sibling FRs:** [3.8 Publishing & Social Index](../README.md) · [FR 3.8.1 — Connect Social Account](../3-8-1-connect-social-account/spec.md) · [FR 3.8.7 — Track Post Status](../3-8-7-track-post-status/spec.md)
- **Consolidated Extension Module:** [`social-publisher-resilience`](../../../modules/07-billing-publisher-and-observability/social-publisher-resilience/spec.md)
- **BA Domain Baseline:** [BA 3.8 Publishing & Social](../../../../ba/07-publishing-social.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified across `brandhub-business-service` and `brandhub-publisher-service` JUnit suites, RabbitMQ + Redis lock integration checks, Web & Mobile UI integration, `vi.json`/`en.json` parity, and Light/Dark mode verification ([test.md](./test.md)).
- **Out of Scope:** De-scoped platforms (Zalo OA), livestream broadcasting, or automated paid ad-spend boosting.
