> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.8.4 — View Posted Detail

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.8.4` |
| **Use Case ID** | `UC-110` |
| **Feature** | View Posted Detail |
| **Domain** | Publishing & Social (`3.8`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Business Rules** | `BR-20, BR-55` |
| **Message Codes** | `MSG01, MSG03, MSG07` |
| **Status** | Implemented — Production Verified |

## 1. Objective & Business Value

Display complete post-publication details for a Workspace Post (`GET /api/v1/workspaces/{workspaceId}/posts/{postId}/detail` and `/{postId}/comments`), including per-platform external post IDs, live external permalinks, published timestamps, rendered media assets, caption/hashtag snapshot, engagement summary, and per-platform error diagnostics.

## 2. User Story

As an authorized member holding `Owner, Manager, Creator, Client` in a Workspace, I want to execute **View Posted Detail** reliably across BrandHub's supported social publishing pipeline (**Facebook, Instagram, TikTok, Threads**) so that approved brand content is delivered, previewed, scheduled, and audited safely with full tenant isolation (`BR-20, BR-55`).

## 3. Acceptance Criteria

1. **Canonical Role & Workspace Scope (`BR-20`):** Only authenticated Workspace members with role in `Owner, Manager, Creator, Client` may invoke the public REST endpoints for `View Posted Detail`; unauthorized roles or cross-workspace requests fail deterministically with `403 FORBIDDEN` (`MSG07`).
2. **Four-Platform Scope Discipline:** Strictly supports **Facebook**, **Instagram**, **TikTok**, and **Threads** — legacy/de-scoped platforms (such as Zalo OA or LinkedIn) are rejected at validation boundaries (`MSG02`).
3. **Production Pipeline & Idempotency:**
- **1. Tenant-Scoped Lookup:** Fetches `PostDocument` `{postId}` verifying `post.workspaceId == workspaceId` (`404 NOT_FOUND` on mismatch).
- **2. Per-Platform Delivery Receipt Enrichment:** Maps each target entry (`platform`, `placement`: `FEED`/`STORY`/`REELS`/`VIDEO`, `externalPostId`, `permalinkUrl`, `publishedAt`, `failureCode`, `failureMessage`) alongside resolved media URLs (handling graceful client stream disconnects if video playback is aborted mid-stream).
- **3. Historical Account Resilience:** Even if the underlying `SocialAccountDocument` was later disconnected (FR 3.8.2), the stored account display snapshot (`accountName`, `avatarUrl`, `platform`) renders intact.
4. **Token & Credential Security:** Raw OAuth access/refresh tokens are encrypted at rest via AES-256-GCM (`CryptoUtils`) and never returned in client-facing `ApiResponse<T>` DTOs or written to application logs.
5. **Internationalization (`vi.json` + `en.json`):** All buttons, platform badges, status pills, validation alerts, and modal copy use synchronized key-parallel entries (`posts.detail.*`, `posts.permalink.openExternal`, `posts.metrics.*`, `posts.comments.*` in `vi.json` & `en.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces (`pages/calendar/index.tsx` post detail drawer, `pages/tasks/detail.tsx` linked post card on Web and `src/screens/content/PostDetailScreen.tsx`, `src/components/content/postDetailStyles.ts` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/calendar/index.tsx` post detail drawer, `pages/tasks/detail.tsx` linked post card
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/content/PostDetailScreen.tsx`, `src/components/content/postDetailStyles.ts`
- **UI States:**
  - **Loading / In-Flight:** Skeleton placeholders on read views; spinner + disabled action button on mutations to prevent duplicate submissions.
  - **Empty:** Contextual guidance card (e.g., prompt to connect social account via FR 3.8.1 or create/schedule a post via FR 3.8.6) with localized CTA.
  - **Success:** Immediate `TanStack Query` cache invalidation, live status badge update, and localized toast notification.
  - **Error / Retryable Failure:** Structured inline banner displaying localized error reason mapped from `MSG01, MSG03, MSG07` without losing draft edits.

## 5. API & Messaging Contract

| Endpoint / Upstream Route | Auth / Security | Controller / Service Handler |
| :--- | :--- | :--- |
| `GET /api/v1/workspaces/{workspaceId}/posts/{postId}/detail` | Bearer (`Owner, Manager, Creator, Client`) | `PostController` -> returns `PostResponse` + platform delivery receipts, external URLs, media presigned/streaming URLs, linked `taskId` |
| `GET /api/v1/workspaces/{workspaceId}/posts/{postId}/comments` | Bearer (`Owner, Manager, Creator, Client`) | `PostController` -> returns `List<PostCommentResponse>` synced/associated with the published post |

## 6. Error Handling & Edge Cases

- `POST_NOT_FOUND` (`404`, `MSG01`): `postId` does not exist in `{workspaceId}`.
- `FORBIDDEN` (`403`, `MSG07`): Non-member of `{workspaceId}` attempts access.
- **Duplicate Delivery / Network Retry:** `PublishJobConsumer` enforces Redis lock `processingPostIds:{postId}:{platform}` (`30m` TTL) and `DefaultClassMapper` cross-service `PublishJobMessage` compatibility so broker redeliveries never double-post to a Client's live social feed.

## 7. Related Specifications & References

- **Domain Index & Sibling FRs:** [3.8 Publishing & Social Index](../README.md) · [FR 3.8.1 — Connect Social Account](../3-8-1-connect-social-account/spec.md) · [FR 3.8.7 — Track Post Status](../3-8-7-track-post-status/spec.md)
- **Consolidated Extension Module:** [`social-publisher-resilience`](../../../modules/07-billing-publisher-and-observability/social-publisher-resilience/spec.md)
- **BA Domain Baseline:** [BA 3.8 Publishing & Social](../../../../ba/07-publishing-social.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified across `brandhub-business-service` and `brandhub-publisher-service` JUnit suites, RabbitMQ + Redis lock integration checks, Web & Mobile UI integration, `vi.json`/`en.json` parity, and Light/Dark mode verification ([test.md](./test.md)).
- **Out of Scope:** De-scoped platforms (Zalo OA), livestream broadcasting, or automated paid ad-spend boosting.
