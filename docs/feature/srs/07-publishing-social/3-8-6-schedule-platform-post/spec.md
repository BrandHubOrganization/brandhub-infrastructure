> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.8.6 — Schedule Platform Post

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.8.6` |
| **Use Case ID** | `UC-112` |
| **Feature** | Schedule Platform Post |
| **Domain** | Publishing & Social (`3.8`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Business Rules** | `BR-20, BR-56, BR-57` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07, MSG44` |
| **Status** | Implemented — Production Verified |

## 1. Objective & Business Value

Schedule an approved post across one or more connected Facebook, Instagram, TikTok, or Threads accounts for automated future execution (`scheduledAt` in Workspace timezone), supported by AI/analytics recommended optimal posting slots (`GET /recommended-times`) and drag-and-drop rescheduling (`PATCH /{postId}/reschedule`).

## 2. User Story

As an authorized member holding `Owner, Manager, Creator` in a Workspace, I want to execute **Schedule Platform Post** reliably across BrandHub's supported social publishing pipeline (**Facebook, Instagram, TikTok, Threads**) so that approved brand content is delivered, previewed, scheduled, and audited safely with full tenant isolation (`BR-20, BR-56, BR-57`).

## 3. Acceptance Criteria

1. **Canonical Role & Workspace Scope (`BR-20`):** Only authenticated Workspace members with role in `Owner, Manager, Creator` may invoke the public REST endpoints for `Schedule Platform Post`; unauthorized roles or cross-workspace requests fail deterministically with `403 FORBIDDEN` (`MSG07`).
2. **Four-Platform Scope Discipline:** Strictly supports **Facebook**, **Instagram**, **TikTok**, and **Threads** — legacy/de-scoped platforms (such as Zalo OA or LinkedIn) are rejected at validation boundaries (`MSG02`).
3. **Production Pipeline & Idempotency:**
- **1. Approval & Account Readiness Gate (`BR-57`):** Verifies the source Task has completed required approval (`APPROVED`, unless solo/self-approved per Workspace mode), every selected `socialAccountId` is `CONNECTED` in `{workspaceId}`, and `scheduledAt` is at least `5 minutes` in the future.
- **2. Due-Post Scheduler & Per-Platform Fan-Out:** Scheduled dispatcher polls MongoDB `posts` (`status = SCHEDULED AND scheduledAt <= now()`), atomically transitions status to `PUBLISHING`, and publishes one `PublishJobMessage` per target `(postId, platform, socialAccountId)` to RabbitMQ `publisher.job.exchange` (`routing-key: publisher.job.routing-key`).
- **3. Reschedule Lock Protection:** `PATCH /{postId}/reschedule` rejects changes (`409 CONFLICT`) once a post has entered `PUBLISHING` or `PUBLISHED`.
4. **Token & Credential Security:** Raw OAuth access/refresh tokens are encrypted at rest via AES-256-GCM (`CryptoUtils`) and never returned in client-facing `ApiResponse<T>` DTOs or written to application logs.
5. **Internationalization (`vi.json` + `en.json`):** All buttons, platform badges, status pills, validation alerts, and modal copy use synchronized key-parallel entries (`editor.schedule.title`, `editor.schedule.recommendedSlots`, `editor.schedule.timezoneHint`, `editor.schedule.errors.pastTime` in `vi.json` & `en.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces (`pages/editor/components/ScheduleModal.tsx`, `pages/calendar/components/SchedulePostModal.tsx`, `ContentCalendar.tsx` on Web and `src/screens/calendar/CalendarScreen.tsx`, `src/components/calendar/CalendarModals.tsx` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/editor/components/ScheduleModal.tsx`, `pages/calendar/components/SchedulePostModal.tsx`, `ContentCalendar.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/calendar/CalendarScreen.tsx`, `src/components/calendar/CalendarModals.tsx`
- **UI States:**
  - **Loading / In-Flight:** Skeleton placeholders on read views; spinner + disabled action button on mutations to prevent duplicate submissions.
  - **Empty:** Contextual guidance card (e.g., prompt to connect social account via FR 3.8.1 or create/schedule a post via FR 3.8.6) with localized CTA.
  - **Success:** Immediate `TanStack Query` cache invalidation, live status badge update, and localized toast notification.
  - **Error / Retryable Failure:** Structured inline banner displaying localized error reason mapped from `MSG01, MSG02, MSG03, MSG07, MSG44` without losing draft edits.

## 5. API & Messaging Contract

| Endpoint / Upstream Route | Auth / Security | Controller / Service Handler |
| :--- | :--- | :--- |
| `POST /api/v1/workspaces/{workspaceId}/posts` | Bearer (`Owner, Manager, Creator`) | `PostController.save()` -> creates/updates scheduled `PostDocument` after verifying Task approval & connected `socialAccountIds` |
| `PATCH /api/v1/workspaces/{workspaceId}/posts/{postId}/reschedule` | Bearer (`Owner, Manager, Creator`) | `PostController.reschedule()` -> updates `scheduledAt` if post is still in `SCHEDULED` / `FAILED` state |
| `GET /api/v1/workspaces/{workspaceId}/posts/recommended-times` | Bearer (`Owner, Manager, Creator`) | `PostController.getRecommendedTimes()` -> returns optimal engagement time slots per platform/placement/timezone |

## 6. Error Handling & Edge Cases

- `SCHEDULE_TIME_IN_PAST` (`400`, `MSG44`): `scheduledAt` is in the past or `< 5 minutes` from server clock.
- `TASK_NOT_APPROVED` (`409`, `MSG03`): Linked Task has not passed `Creator -> Manager -> Client` approval.
- `ACCOUNT_DISCONNECTED` (`409`, `MSG43`): Target social account is disconnected or token expired.
- **Duplicate Delivery / Network Retry:** `PublishJobConsumer` enforces Redis lock `processingPostIds:{postId}:{platform}` (`30m` TTL) and `DefaultClassMapper` cross-service `PublishJobMessage` compatibility so broker redeliveries never double-post to a Client's live social feed.

## 7. Related Specifications & References

- **Domain Index & Sibling FRs:** [3.8 Publishing & Social Index](../README.md) · [FR 3.8.1 — Connect Social Account](../3-8-1-connect-social-account/spec.md) · [FR 3.8.7 — Track Post Status](../3-8-7-track-post-status/spec.md)
- **Consolidated Extension Module:** [`social-publisher-resilience`](../../../modules/07-billing-publisher-and-observability/social-publisher-resilience/spec.md)
- **BA Domain Baseline:** [BA 3.8 Publishing & Social](../../../../ba/07-publishing-social.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified across `brandhub-business-service` and `brandhub-publisher-service` JUnit suites, RabbitMQ + Redis lock integration checks, Web & Mobile UI integration, `vi.json`/`en.json` parity, and Light/Dark mode verification ([test.md](./test.md)).
- **Out of Scope:** De-scoped platforms (Zalo OA), livestream broadcasting, or automated paid ad-spend boosting.
