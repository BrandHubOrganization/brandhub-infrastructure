> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.8.3 — View Dashboard Post

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.8.3` |
| **Use Case ID** | `UC-109` |
| **Feature** | View Dashboard Post |
| **Domain** | Publishing & Social (`3.8`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Business Rules** | `BR-20, BR-55` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07` |
| **Status** | Implemented — Production Verified |

## 1. Objective & Business Value

Provide a unified, timezone-accurate Workspace Social Publishing Dashboard & Calendar (`GET /api/v1/workspaces/{workspaceId}/posts/dashboard`, `/posts`, `/schedule`) aggregating post KPIs, status breakdowns (`DRAFT`, `SCHEDULED`, `PUBLISHING`, `PUBLISHED`, `PARTIAL_FAILURE`, `FAILED`), and platform distribution across Facebook, Instagram, TikTok, and Threads.

## 2. User Story

As an authorized member holding `Owner, Manager, Creator, Client` in a Workspace, I want to execute **View Dashboard Post** reliably across BrandHub's supported social publishing pipeline (**Facebook, Instagram, TikTok, Threads**) so that approved brand content is delivered, previewed, scheduled, and audited safely with full tenant isolation (`BR-20, BR-55`).

## 3. Acceptance Criteria

1. **Canonical Role & Workspace Scope (`BR-20`):** Only authenticated Workspace members with role in `Owner, Manager, Creator, Client` may invoke the public REST endpoints for `View Dashboard Post`; unauthorized roles or cross-workspace requests fail deterministically with `403 FORBIDDEN` (`MSG07`).
2. **Four-Platform Scope Discipline:** Strictly supports **Facebook**, **Instagram**, **TikTok**, and **Threads** — legacy/de-scoped platforms (such as Zalo OA or LinkedIn) are rejected at validation boundaries (`MSG02`).
3. **Production Pipeline & Idempotency:**
- **1. Multi-Dimensional MongoDB Aggregation:** `PostService.getDashboard()` queries `posts` (`PostDocument`) scoped to `workspaceId` with compound index `{workspaceId, status, scheduledAt}`, computing total published, upcoming scheduled, failed/attention items, and per-platform counts (`FACEBOOK`, `INSTAGRAM`, `TIKTOK`, `THREADS`).
- **2. Workspace Timezone Alignment:** Date boundaries and monthly calendar buckets (`getSchedule`) evaluate in the Workspace's configured IANA timezone (default `Asia/Ho_Chi_Minh`), preventing midnight off-by-one shifts between Web and Mobile.
- **3. Bounded Batch Lookup:** `taskIds` filter enforces `ids.size() <= 200` (`ErrorCode.INVALID_REQUEST` on overflow) so large Campaign views query efficiently.
4. **Token & Credential Security:** Raw OAuth access/refresh tokens are encrypted at rest via AES-256-GCM (`CryptoUtils`) and never returned in client-facing `ApiResponse<T>` DTOs or written to application logs.
5. **Internationalization (`vi.json` + `en.json`):** All buttons, platform badges, status pills, validation alerts, and modal copy use synchronized key-parallel entries (`calendar.dashboard.*`, `calendar.filters.*`, `posts.status.*` in `src/i18n/locales/{vi,en}/calendar.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces (`pages/calendar/index.tsx` (`ContentCalendar.tsx`, `CalendarFilterBar.tsx`, `PlatformFilter.tsx`, `StatusFilter.tsx`), `pages/workspace/components/SocialQuickSnapshot.tsx` on Web and `src/screens/more/PostDashboardScreen.tsx`, `src/screens/calendar/CalendarScreen.tsx`, `src/services/postDashboardService.ts` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/calendar/index.tsx` (`ContentCalendar.tsx`, `CalendarFilterBar.tsx`, `PlatformFilter.tsx`, `StatusFilter.tsx`), `pages/workspace/components/SocialQuickSnapshot.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/more/PostDashboardScreen.tsx`, `src/screens/calendar/CalendarScreen.tsx`, `src/services/postDashboardService.ts`
- **UI States:**
  - **Loading / In-Flight:** Skeleton placeholders on read views; spinner + disabled action button on mutations to prevent duplicate submissions.
  - **Empty:** Contextual guidance card (e.g., prompt to connect social account via FR 3.8.1 or create/schedule a post via FR 3.8.6) with localized CTA.
  - **Success:** Immediate `TanStack Query` cache invalidation, live status badge update, and localized toast notification.
  - **Error / Retryable Failure:** Structured inline banner displaying localized error reason mapped from `MSG01, MSG02, MSG03, MSG07` without losing draft edits.

## 5. API & Messaging Contract

| Endpoint / Upstream Route | Auth / Security | Controller / Service Handler |
| :--- | :--- | :--- |
| `GET /api/v1/workspaces/{workspaceId}/posts/dashboard?dateRange={r}&platform={p}&status={s}&timezone={tz}` | Bearer (`Owner, Manager, Creator, Client`) | `PostController.getDashboard()` -> aggregates KPIs & recent activity in Workspace timezone (`Asia/Ho_Chi_Minh` default) |
| `GET /api/v1/workspaces/{workspaceId}/posts?status={s}&taskIds={ids}` | Bearer (`Owner, Manager, Creator, Client`) | `PostController.list()` -> filtered post list (`MAX_TASK_IDS = 200` guard) |
| `GET /api/v1/workspaces/{workspaceId}/posts/schedule?month={YYYY-MM}` | Bearer (`Owner, Manager, Creator, Client`) | `PostController.getSchedule()` -> monthly calendar slot grid |

## 6. Error Handling & Edge Cases

- `INVALID_REQUEST` (`400`, `MSG02`): `taskIds` exceeds `200`, invalid `YYYY-MM` month format, or unrecognized IANA timezone.
- `FORBIDDEN` (`403`, `MSG07`): Caller is not a member of `{workspaceId}`.
- **Duplicate Delivery / Network Retry:** `PublishJobConsumer` enforces Redis lock `processingPostIds:{postId}:{platform}` (`30m` TTL) and `DefaultClassMapper` cross-service `PublishJobMessage` compatibility so broker redeliveries never double-post to a Client's live social feed.

## 7. Related Specifications & References

- **Domain Index & Sibling FRs:** [3.8 Publishing & Social Index](../README.md) · [FR 3.8.1 — Connect Social Account](../3-8-1-connect-social-account/spec.md) · [FR 3.8.7 — Track Post Status](../3-8-7-track-post-status/spec.md)
- **Consolidated Extension Module:** [`social-publisher-resilience`](../../../modules/07-billing-publisher-and-observability/social-publisher-resilience/spec.md)
- **BA Domain Baseline:** [BA 3.8 Publishing & Social](../../../../ba/07-publishing-social.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified across `brandhub-business-service` and `brandhub-publisher-service` JUnit suites, RabbitMQ + Redis lock integration checks, Web & Mobile UI integration, `vi.json`/`en.json` parity, and Light/Dark mode verification ([test.md](./test.md)).
- **Out of Scope:** De-scoped platforms (Zalo OA), livestream broadcasting, or automated paid ad-spend boosting.
