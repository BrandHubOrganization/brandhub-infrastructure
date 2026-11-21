# Realtime In-App Notifications — test

## Automated
| ID | Test | Where |
|---|---|---|
| A1 | FAILED callback notifies the author with readable copy | `InternalPostControllerNotificationTest` |
| A2 | Two PUBLISHED callbacks notify once | same |
| A3 | Existing inbox / task / content request / billing / workspace / moderation suites still pass | `mvn test` |

## Live probe (done 2026-11-21, local Postgres + business-service on :18081)
1. Apply the migration. `LISTEN user_notification` + insert a row → psql prints
   `Asynchronous notification "user_notification" with payload "<user id>"`.
2. Node STOMP client: login → CONNECT on `/ws/chat` → SUBSCRIBE `/user/queue/notifications`,
   then insert a row for that user → client receives `{"type":"NOTIFICATION"}`. Probe row deleted.

## Manual (browser)
| ID | Steps | Expected |
|---|---|---|
| M1 | Two browsers: Manager and Creator in one Workspace. Manager assigns a task to Creator | Creator sees a toast + bell count within ~2 s, no reload |
| M2 | Creator submits; Manager approves the last step | Creator gets "Công việc đã được duyệt" |
| M3 | Client creates a Content Request | Manager gets "Yêu cầu nội dung mới" |
| M4 | Manager receives / denies the request | Client gets the matching toast |
| M5 | Owner changes a member's role, then removes them | Member gets both notifications |
| M6 | Publisher reports FAILED for a post | Author gets "Đăng bài thất bại" with a readable reason |
| M7 | Reload the page with unread items | No toast for items that were already there |
| M8 | Stop business-service, insert a row, restart | Bell catches up on reconnect |
| M9 | Toast in light and in dark theme | Readable in both |
| M10 | Admin account | No socket subscription, Admin pages unchanged |
