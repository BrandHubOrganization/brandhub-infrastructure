# Realtime In-App Notifications — spec

## Objective
New in-app notifications appear on the web within a second or two, with no page refresh,
pushed over the existing STOMP WebSocket. Important actions that were silent before
now create a notification for the people they affect.

## User Story
As an Owner / Manager / Creator / Client, when something that needs my attention happens
(my post fails to publish, my task is approved, a Client sends a request, my payment lands),
I see a toast and the bell count update straight away, and a click takes me to the item.

## Acceptance Criteria
1. Every row inserted into `user_notifications` pushes a signal to the recipient's open
   web sessions (`/user/queue/notifications`) after the transaction commits. Rolled-back
   writes push nothing.
2. The signal carries no content. The web refetches `GET /api/v1/notifications/me`
   (the recipient's own inbox only), then shows a toast for each new unread item (at most 3)
   with a "View" action that opens `actionUrl`.
3. Items already unread when the page opens do not toast.
4. If the socket is down, the bell still refreshes on focus and every 120 s (was 30 s).
5. Admin web sessions are unchanged (the Admin bell has no user inbox).
6. New notification events (recipient → trigger):

| Event | Recipient | Link |
|---|---|---|
| Post published (first time) | Post author | `/workspaces/{ws}/posts/{post}` |
| Post failed (overall status FAILED) — `publishFailed` existed but was never called | Post author | same |
| Task approved at the last review step | Task assignee (not when they approved it themselves) | `/workspaces/{ws}/tasks?task={id}` |
| Admin moderation approve / block | Post author (in-app, next to the existing email) | post |
| SePay payment fulfilled (upgrade, renewal, credit top-up) | Agency Owner | `/subscription` |
| Invited to a Workspace (account already exists) | Invitee | `/invitations/accept?token=…` |
| Invitation accepted | Inviter | `/workspaces/{ws}/members` |
| Removed from a Workspace | Removed member | `/workspaces` |
| Workspace role changed | That member | `/workspaces/{ws}` |
| Client creates a Content Request | Workspace Managers | `/workspaces/{ws}/requests` |
| Content Request received / denied / accepted | Requesting Client | same |

Existing events (task assigned, comment/mention, review requested/rejected, section events,
chat, package proposal, campaign review, mail batch finished, plan expired, Admin broadcast)
now also arrive in realtime, with no change in their writers.

## i18n
- New key `notifications.open` ("Xem" / "View") in `vi/notifications.json` and
  `en/notifications.json`.
- Notification title/content are written in Vietnamese by the server, like every existing
  inbox row (unchanged convention).

## Light/Dark mode
Toasts use the existing `sonner` theme; no new colours.

## Error Handling
- A failed inbox write never fails the business action it reports on: billing and moderation
  write inside the action's own transaction; publish callback and content requests catch and log.
- Listener connection loss: logs a warning, reconnects every 5 s. Polling covers the gap.

## Edge Cases
- Duplicate publish callbacks / retried webhooks: deterministic ids (`on conflict do nothing`).
- Admin broadcast to thousands of users: Postgres folds identical NOTIFY payloads per
  transaction, so one signal per recipient.
- Several business-service instances: each LISTENs and reaches only its own sessions.

## Definition of Done
Migration applied, backend tests green, web `tsc` + eslint clean, live STOMP probe receives
the signal for an inserted row.

## Out of Scope
Mobile push (FCM), per-category notification preferences, cross-tab read sync.
