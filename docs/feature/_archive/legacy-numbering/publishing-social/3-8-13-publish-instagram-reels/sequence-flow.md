# Sequence Flow — Publish Instagram Story

> Supplements `spec.md` (FR 3.8.13). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Scheduler (Job)** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Publish Instagram Story Page`.
- **System** — `PublishInstagramStoryController` / `SchedulerService`.

---

## Flow A — Luồng thực thi chính: Publish Instagram Story

1. schedulerjob -> schedulerservice: `trigger scheduled publish job`
2. schedulerservice -> postrepository: `findScheduledPosts(scheduledAt <= NOW(), platform=INSTAGRAM, type=STORY)`
3. postrepository --> schedulerservice: `List<Post>`
4. schedulerservice -> rabbitmq: `publish("publisher.job.queue", PublishJobMessage{platform=INSTAGRAM, type=STORY, ...})`
5. rabbitmq --> publishjobconsumer: `consume(PublishJobMessage)`
6. publishjobconsumer -> instagramstorypublis: `publishPost(jobMessage)`
7. instagramstorypublis -> metagraphapi: `POST /{igUserId}/media (media_type="STORIES", image_url)`
8. instagramstorypublis -> metagraphapi: `POST /{igUserId}/media (media_type="STORIES", video_url)`
9. metagraphapi --> instagramstorypublis: `{id: containerId}`
10. instagramstorypublis -> metagraphapi: `POST /{igUserId}/media_publish (creation_id=containerId)`
11. metagraphapi --> instagramstorypublis: `{id: platformPostId}`
12. instagramstorypublis --> publishjobconsumer: `SUCCESS (platformPostId)`
13. publishjobconsumer -> postrepository: `update(post, status=PUBLISHED, platformPostId)`
14. postrepository --> publishjobconsumer: `ok`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
