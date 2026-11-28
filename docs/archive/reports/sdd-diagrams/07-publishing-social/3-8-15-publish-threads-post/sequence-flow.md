# Sequence Flow — Publish Threads Post

> Supplements `spec.md` (FR 3.8.15). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Scheduler (Job)** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Publish Threads Post Page`.
- **System** — `PublishThreadsPostController` / `SchedulerService`.

---

## Flow A — Luồng thực thi chính: Publish Threads Post

1. schedulerjob -> schedulerservice: `trigger scheduled publish job`
2. schedulerservice -> postrepository: `findScheduledPosts(scheduledAt <= NOW(), platform=THREADS)`
3. postrepository --> schedulerservice: `List<Post>`
4. schedulerservice -> rabbitmq: `publish("publisher.job.queue", PublishJobMessage{platform=THREADS, ...})`
5. rabbitmq --> publishjobconsumer: `consume(PublishJobMessage)`
6. publishjobconsumer -> threadspublishservic: `publishPost(jobMessage)`
7. threadspublishservic -> threadsapi: `POST /{targetId}/threads (media_type, text/image_url/video_url)`
8. threadsapi --> threadspublishservic: `{id: containerId}`
9. threadspublishservic -> threadsapi: `POST /{targetId}/threads_publish (creation_id=containerId)`
10. threadsapi --> threadspublishservic: `{id: platformPostId}`
11. threadspublishservic --> publishjobconsumer: `FAILED (error)`
12. publishjobconsumer -> rabbitmq: `basicNack -> Route to DLQ`
13. publishjobconsumer -> postrepository: `update(post, status=FAILED)`
14. postrepository --> publishjobconsumer: `ok`
15. threadspublishservic --> publishjobconsumer: `SUCCESS (platformPostId)`
16. publishjobconsumer -> postrepository: `update(post, status=PUBLISHED, platformPostId)`
17. postrepository --> publishjobconsumer: `ok`
18. publishjobconsumer -> rabbitmq: `publish("business.publish_callback.queue", CallbackMessage{status=SUCCESS})`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
