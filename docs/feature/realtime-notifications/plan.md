# Realtime In-App Notifications — plan

## Approach
Database-driven push. A Postgres trigger runs `pg_notify('user_notification', user_id)`
on every insert into `user_notifications`. NOTIFY is delivered only on commit. One listener
per business-service instance pushes `{"type":"NOTIFICATION"}` to that user over STOMP.

Why not wrap each writer: there are about ten writers (raw SQL in chat, task outbox,
billing, Admin broadcast, subscription lifecycle, …). The trigger covers all of them, and
any future writer, with no code in the writer.

## Database (brandhub-infrastructure)
- `docs/database/migrations/2026-11-21-user-notification-realtime.sql` — function + trigger
  (idempotent: `CREATE OR REPLACE`). Also appended to `init-postgres-v2.sql`.

## business-service
- `service/NotificationRealtimeListener.java` — virtual thread, own JDBC connection
  (`DataSourceProperties`), `LISTEN`, `PGConnection.getNotifications(10s)`,
  `convertAndSendToUser(userId, "/queue/notifications")`, reconnects every 5 s.
  Off switch: `app.notifications.realtime.enabled` (off in `application-test.yml`).
- `pom.xml` — postgresql driver scope `runtime` → compile (needed for `PGConnection`).
- `security/ChatInboundChannelInterceptor.java` — allow SUBSCRIBE `/user/queue/notifications`.
- `service/UserNotificationService.java` — single `notify(Notice)` write path; existing
  helpers delegate to it; new `publishSucceeded`.
- Event writers:
  - `controller/InternalPostController.java` — notify author on status change to PUBLISHED / FAILED.
  - `service/impl/TaskApprovalOutbox.java` + `TaskNotificationWorker.java` — `TASK_REVIEW_APPROVED`.
  - `service/admin/ContentModerationService.java` — in-app decision.
  - `service/AgencyBillingService.java` — Owner after fulfilment.
  - `service/impl/WorkspaceServiceImpl.java` — invite / accept / remove / role change.
  - `service/ContentRequestService.java`, `service/ContentRequestReviewService.java`.

## web
- `src/hooks/useNotificationSocket.ts` — STOMP on `/ws/chat` (same endpoint and JWT check
  as chat), subscribe `/user/queue/notifications`, catch-up refetch on (re)connect.
- `src/components/layout/Navbar.tsx` — refetch on signal, toast new unread items, polling
  30 s → 120 s fallback.
- `src/i18n/locales/vi/notifications.json`, `src/i18n/locales/en/notifications.json` — `open`.

## Gateway
No change: `/ws/chat` is already routed.

## Deploy order
1. Run the migration on Postgres (without it nothing breaks; only realtime stays off).
2. Deploy business-service, then web.
