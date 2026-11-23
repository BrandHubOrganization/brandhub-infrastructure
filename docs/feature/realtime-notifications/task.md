# Realtime In-App Notifications — tasks

- [x] T1 Migration: NOTIFY trigger on `user_notifications` (+ append to init SQL)
- [x] T2 `NotificationRealtimeListener` (LISTEN → STOMP user queue), test profile off
- [x] T3 Allow SUBSCRIBE `/user/queue/notifications` in the inbound interceptor
- [x] T4 `UserNotificationService.notify(Notice)` single write path
- [x] T5 Publish result → author (wires the unused `publishFailed`, adds `publishSucceeded`)
- [x] T6 Final task approval → assignee (`TASK_REVIEW_APPROVED` outbox event + eligibility)
- [x] T7 Admin moderation decision → author in-app
- [x] T8 SePay fulfilment → Agency Owner
- [x] T9 Workspace invite / accept / remove / role change
- [x] T10 Content Request create → Managers; receive / deny / accept → Client
- [x] T11 Web `useNotificationSocket` + Navbar toast + polling fallback 120 s
- [x] T12 Update `vi/notifications.json` + `en/notifications.json` (`open`)
- [ ] T13 Check toast in light and dark mode in the browser (skipped 2026-11-21 by decision)
- [x] T14 Backend tests + web `tsc`/eslint + live STOMP probe
- [ ] T15 Run the migration on production Postgres before deploying business-service
