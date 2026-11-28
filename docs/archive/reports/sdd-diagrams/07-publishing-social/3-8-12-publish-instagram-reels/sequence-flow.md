# Sequence Flow — Publish Instagram Reels

> Supplements `spec.md` (FR 3.8.12). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Scheduler (Job)** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Publish Instagram Reels Page`.
- **System** — `PublishInstagramReelsController` / `SchedulerService`.

---

## Flow A — Luồng thực thi chính: Publish Instagram Reels

1. schedulerjob -> schedulerservice: `trigger scheduled publish job`
2. schedulerservice -> postrepository: `findScheduledPosts(scheduledAt <= NOW(), platform=INSTAGRAM, type=REELS)`
3. postrepository --> schedulerservice: `List<Post>`
4. schedulerservice -> rabbitmq: `publish("publisher.job.queue", PublishJobMessage{platform=INSTAGRAM, type=REELS, ...})`
5. rabbitmq --> publishjobconsumer: `consume(PublishJobMessage)`
6. publishjobconsumer -> instagramreelspublis: `publishPost(jobMessage)`
7. instagramreelspublis -> metagraphapi: `POST /{igUserId}/media (media_type="REELS", video_url, caption, share_to_feed=true)`
8. metagraphapi --> instagramreelspublis: `{id: containerId}`
9. instagramreelspublis -> metagraphapi: `GET /{containerId}?fields=status_code (poll until FINISHED)`
10. metagraphapi --> instagramreelspublis: `{status_code: FINISHED}`
11. instagramreelspublis -> metagraphapi: `POST /{igUserId}/media_publish (creation_id=containerId)`
12. metagraphapi --> instagramreelspublis: `{id: platformPostId}`
13. instagramreelspublis --> publishjobconsumer: `FAILED (error)`
14. publishjobconsumer -> rabbitmq: `basicNack -> Route to DLQ`
15. publishjobconsumer -> postrepository: `update(post, status=FAILED)`
16. postrepository --> publishjobconsumer: `ok`
17. instagramreelspublis --> publishjobconsumer: `SUCCESS (platformPostId)`
18. publishjobconsumer -> postrepository: `update(post, status=PUBLISHED, platformPostId)`
19. postrepository --> publishjobconsumer: `ok`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
