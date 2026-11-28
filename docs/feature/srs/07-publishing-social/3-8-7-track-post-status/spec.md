> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.8.7 — Track Post Status

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.8.7` |
| **Use Case ID** | `UC-113` |
| **Feature** | Track Post Status |
| **Domain** | Publishing & Social (`3.8`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Business Rules** | `BR-20, BR-57, BR-58` |
| **Message Codes** | `MSG01, MSG03, MSG07` |
| **Status** | Implemented — Production Verified |

## 1. Objective & Business Value

Track real-time and asynchronous per-platform delivery status (`DRAFT -> SCHEDULED -> PUBLISHING -> PUBLISHED | PARTIAL_FAILURE | FAILED`) of Workspace posts (`GET /api/v1/workspaces/{workspaceId}/posts/{postId}/status`), backed by `PublishJobConsumer` Redis idempotency locks (`processingPostIds:{postId}:{platform}`), tiered RabbitMQ retry queues (`1m / 5m / 15m`), DLQ routing, and realtime `user_notifications` alerts.

## 2. User Story

As an authorized member holding `Owner, Manager, Creator, Client` in a Workspace, I want to execute **Track Post Status** reliably across BrandHub's supported social publishing pipeline (**Facebook, Instagram, TikTok, Threads**) so that approved brand content is delivered, previewed, scheduled, and audited safely with full tenant isolation (`BR-20, BR-57, BR-58`).

## 3. Acceptance Criteria

1. **Canonical Role & Workspace Scope (`BR-20`):** Only authenticated Workspace members with role in `Owner, Manager, Creator, Client` may invoke the public REST endpoints for `Track Post Status`; unauthorized roles or cross-workspace requests fail deterministically with `403 FORBIDDEN` (`MSG07`).
2. **Four-Platform Scope Discipline:** Strictly supports **Facebook**, **Instagram**, **TikTok**, and **Threads** — legacy/de-scoped platforms (such as Zalo OA or LinkedIn) are rejected at validation boundaries (`MSG02`).
3. **Production Pipeline & Idempotency:**
- **1. Per-(Post, Platform) Redis Lock:** `PublishJobConsumer` acquires `SETNX processingPostIds:{postId}:{platform}` (`TTL = 30 minutes`) so multi-platform sibling jobs run concurrently while duplicate RabbitMQ redeliveries for the same platform are suppressed.
- **2. Error Classification & Tiered Backoff (`ErrorClassifier`):** Transient network/rate-limit (`429`, `5xx`) failures route to `publisher.retry.exchange` with header `x-retry-count` across `publish.jobs.retry.1m` (`60s`), `publish.jobs.retry.5m` (`300s`), and `publish.jobs.retry.15m` (`900s`). Permanent OAuth/policy errors (`400`, `401`, `403`) or exhausted retries route to `publisher.job.dlx` (`publisher.job.dlq`) and callback `FAILED` immediately.
- **3. Aggregate Rollup & Realtime Notification:** `PostPublishService` computes `PUBLISHED` (all targets succeeded), `PARTIAL_FAILURE` (at least one succeeded and one failed), or `FAILED` (all failed), and emits PostgreSQL `LISTEN/NOTIFY` `user_notifications` to the post author and `Manager`.
4. **Token & Credential Security:** Raw OAuth access/refresh tokens are encrypted at rest via AES-256-GCM (`CryptoUtils`) and never returned in client-facing `ApiResponse<T>` DTOs or written to application logs.
5. **Internationalization (`vi.json` + `en.json`):** All buttons, platform badges, status pills, validation alerts, and modal copy use synchronized key-parallel entries (`posts.status.{draft,scheduled,publishing,published,partialFailure,failed}`, `posts.tracking.retryAttempt` in `vi.json` & `en.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces (`pages/calendar/index.tsx` status pills, `pages/editor/components/EditorHeaderActions.tsx` live publish tracker on Web and `src/screens/more/PostDashboardScreen.tsx`, `src/screens/content/PostDetailScreen.tsx` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/calendar/index.tsx` status pills, `pages/editor/components/EditorHeaderActions.tsx` live publish tracker
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/PostDashboardScreen.tsx`, `src/screens/content/PostDetailScreen.tsx`
- **UI States:**
  - **Loading / In-Flight:** Skeleton placeholders on read views; spinner + disabled action button on mutations to prevent duplicate submissions.
  - **Empty:** Contextual guidance card (e.g., prompt to connect social account via FR 3.8.1 or create/schedule a post via FR 3.8.6) with localized CTA.
  - **Success:** Immediate `TanStack Query` cache invalidation, live status badge update, and localized toast notification.
  - **Error / Retryable Failure:** Structured inline banner displaying localized error reason mapped from `MSG01, MSG03, MSG07` without losing draft edits.

## 5. API & Messaging Contract

| Endpoint / Upstream Route | Auth / Security | Controller / Service Handler |
| :--- | :--- | :--- |
| `GET /api/v1/workspaces/{workspaceId}/posts/{postId}/status` | Bearer (`Owner, Manager, Creator, Client`) | `PostController.getStatus()` -> returns aggregate status + per-platform attempt count, external ID/URL, and classified error reason |
| `POST /api/v1/internal/posts/{postId}/publish-result` | `X-Internal-Service-Key` | `InternalPostController` (`business-service`) <- receives callback from `PublishJobConsumer` (`publisher-service`) |

## 6. Error Handling & Edge Cases

- `POST_NOT_FOUND` (`404`, `MSG01`): Unknown `postId` or cross-workspace query.
- `UNAUTHORIZED_INTERNAL_KEY` (`403`): Missing/invalid `X-Internal-Service-Key` on internal callback.
- **Duplicate Delivery / Network Retry:** `PublishJobConsumer` enforces Redis lock `processingPostIds:{postId}:{platform}` (`30m` TTL) and `DefaultClassMapper` cross-service `PublishJobMessage` compatibility so broker redeliveries never double-post to a Client's live social feed.

## 7. Related Specifications & References

- **Domain Index & Sibling FRs:** [3.8 Publishing & Social Index](../README.md) · [FR 3.8.1 — Connect Social Account](../3-8-1-connect-social-account/spec.md) · [FR 3.8.7 — Track Post Status](../3-8-7-track-post-status/spec.md)
- **Consolidated Extension Module:** [`social-publisher-resilience`](../../../modules/07-billing-publisher-and-observability/social-publisher-resilience/spec.md)
- **BA Domain Baseline:** [BA 3.8 Publishing & Social](../../../../ba/07-publishing-social.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified across `brandhub-business-service` and `brandhub-publisher-service` JUnit suites, RabbitMQ + Redis lock integration checks, Web & Mobile UI integration, `vi.json`/`en.json` parity, and Light/Dark mode verification ([test.md](./test.md)).
- **Out of Scope:** De-scoped platforms (Zalo OA), livestream broadcasting, or automated paid ad-spend boosting.
