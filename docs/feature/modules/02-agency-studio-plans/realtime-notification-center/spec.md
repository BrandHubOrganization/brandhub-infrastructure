> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Realtime In-App Notification Center (PostgreSQL LISTEN/NOTIFY + WebSocket/SSE)

| Field | Value |
| :--- | :--- |
| **Module Slug** | `realtime-notification-center` |
| **Category** | `02-agency-studio-plans` — Agency, Personal Studio, Dashboards & Realtime Notifications |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client, Admin` |
| **Consolidated Feature Scopes** | `realtime-notifications` |
| **Aligned SRS Domains** | [FR 3.10.1 — Push Notification](../../../srs/09-admin-functions/3-10-1-push-notification/spec.md) · [3.6 Content & Workflow](../../../srs/05-content-task-workflow/README.md) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Deliver low-latency, persistent in-app notifications (`user_notifications`) across Web and Mobile for Task assignments, 3-tier approval transitions, `@mention` comments/chat, Content Request submissions, Social Post publish completions/failures, and Admin system broadcasts, powered by PostgreSQL `LISTEN/NOTIFY` (`2026-11-21-user-notification-realtime.sql`) and WebSocket/STOMP push.

## 2. User Stories

- As an `Owner`, `Manager`, `Creator`, `Client`, or `Admin`, I want an instant unread badge and notification inbox that updates in real time without polling storms and deep-links me directly to the target Task, Campaign, Chat thread, or Post.

## 3. Consolidated Acceptance Criteria

1. **Durable Persistence + `pg_notify` Trigger (`2026-11-21-user-notification-realtime.sql`):** Every domain event inserts a row into `user_notifications` (`recipient_user_id`, `type`, `title`, `body`, `action_url`, `metadata` JSONB, `read_at`) and fires PostgreSQL `NOTIFY user_notifications_channel` after transaction commit.
2. **Realtime Fan-Out & Reconnect Catch-Up:** Dedicated listener connection in `brandhub-business-service` pushes new notifications over authenticated STOMP/WebSocket user queues (`/user/queue/notifications`); on reconnect or tab focus, `GET /api/v1/notifications/me` reconciles any missed items.
3. **Read / Read-All State & Deep-Link Validation:** `POST /api/v1/notifications/me/{id}/read` and `POST /api/v1/notifications/me/read-all` update `read_at` idempotently; `notificationLink.ts` validates deep-link routes and switches active Workspace/Agency safely before navigating.
4. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`notifications.{title,markAllRead,empty,types.*,timeAgo}` in `src/i18n/locales/{vi,en}/notifications.json`) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
5. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** Header Notification Bell popover + Notification Inbox drawer (`brandhub-web`)
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/notifications/NotificationsScreen.tsx`, `NotificationPreferencesScreen.tsx`, `src/services/notificationService.ts`, `src/utils/notificationLink.ts`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `GET /api/v1/notifications/me?page={1}&size={20}&unreadOnly={bool}` | Bearer (`Owner, Manager, Creator, Client, Admin`) | `UserNotificationController` -> paginated inbox + unread count |
| `POST /api/v1/notifications/me/{id}/read` | Bearer (`Owner, Manager, Creator, Client, Admin`) | `UserNotificationController` -> marks single notification read (`recipient_user_id` checked) |
| `POST /api/v1/notifications/me/read-all` | Bearer (`Owner, Manager, Creator, Client, Admin`) | `UserNotificationController` -> marks all unread notifications read for caller |
| `WS /ws -> /user/queue/notifications` | Authenticated STOMP JWT | `WebSocketConfig` + `PgNotificationListener` -> pushes live `UserNotificationResponse` |

## 6. Error Handling, Security & Edge Cases

- **Revoked Workspace rostership Before Click:** Clicking an older notification for a Workspace the user was removed from displays a safe localized access notice instead of crashing.
- **PostgreSQL Listener Connection Drop:** Automatic exponential-backoff reconnect re-issues `LISTEN` without impacting primary HikariCP transactional pool.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [FR 3.10.1 — Push Notification](../../../srs/09-admin-functions/3-10-1-push-notification/spec.md) · [3.6 Content & Workflow](../../../srs/05-content-task-workflow/README.md)
- **BA & Architecture References:** [BA 03 Agency & Workspace](../../../../ba/03-agency-workspace.md) · [BA 09 Admin Functions](../../../../ba/09-admin-functions.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).
