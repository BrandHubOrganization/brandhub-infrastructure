# Sequence Flow — Publish Facebook Reels

> Supplements `spec.md` (FR 3.8.10). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Scheduler (Job)** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Publish Facebook Reels Page`.
- **System** — `PublishFacebookReelsController` / `SchedulerService`.

---

## Flow A — Luồng thực thi chính: Publish Facebook Reels

1. schedulerjob -> schedulerservice: `trigger scheduled publish job`
2. schedulerservice -> postrepository: `findScheduledPosts(scheduledAt <= NOW(), platform=FACEBOOK, type=REELS)`
3. postrepository --> schedulerservice: `List<Post>`
4. schedulerservice -> rabbitmq: `publish("publisher.job.queue", PublishJobMessage{platform=FACEBOOK, type=REELS, ...})`
5. rabbitmq --> publishjobconsumer: `consume(PublishJobMessage)`
6. publishjobconsumer -> facebookpublishservi: `publishPost(jobMessage)`
7. facebookpublishservi -> metagraphapi: `POST /{pageId}/videos (video_url, title, published=true)`
8. metagraphapi --> facebookpublishservi: `{id: videoId, status: PROCESSING}`
9. facebookpublishservi --> publishjobconsumer: `FAILED (error)`
10. publishjobconsumer -> rabbitmq: `basicNack -> Route to DLQ`
11. publishjobconsumer -> postrepository: `update(post, status=FAILED)`
12. postrepository --> publishjobconsumer: `ok`
13. facebookpublishservi --> publishjobconsumer: `SUCCESS (platformPostId)`
14. publishjobconsumer -> postrepository: `update(post, status=PUBLISHED, platformPostId)`
15. postrepository --> publishjobconsumer: `ok`
16. publishjobconsumer -> rabbitmq: `publish("business.publish_callback.queue", CallbackMessage{status=SUCCESS})`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
