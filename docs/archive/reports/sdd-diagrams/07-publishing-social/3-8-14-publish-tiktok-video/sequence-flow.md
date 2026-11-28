# Sequence Flow — Publish TikTok Video

> Supplements `spec.md` (FR 3.8.14). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Scheduler (Job)** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Publish TikTok Video Page`.
- **System** — `PublishTikTokVideoController` / `PublishJobConsumer (Publisher Service)`.

---

## Flow A — Luồng thực thi chính: Publish TikTok Video

1. schedulerjob -> schedulerserviceimpl: `triggerEveryMinute()`
2. schedulerserviceimpl -> postmongorepositoryb: `findScheduledPosts(scheduledAt <= NOW(), status='SCHEDULED', platform='TIKTOK')`
3. postmongorepositoryb --> schedulerserviceimpl: `return List<PostDocument>`
4. schedulerserviceimpl -> postmongorepositoryb: `updateStatus(postId, 'IN_PROGRESS')`
5. postmongorepositoryb --> schedulerserviceimpl: `return 200 OK`
6. schedulerserviceimpl -> rabbitmqbrandhubpubl: `publish("brandhub.publishing", "publish.job", PublishJobMessage {platform='TIKTOK', ...})`
7. rabbitmqbrandhubpubl --> schedulerserviceimpl: `return Acknowledgement`
8. rabbitmqbrandhubpubl -> publishjobconsumerpu: `consume("publisher.job.queue", message)`
9. publishjobconsumerpu -> publishjobconsumerpu: `checkRedisLockSETNX("processingPostIds:" + postId, ttl=30m)`
10. publishjobconsumerpu -> tiktokpublishadapter: `publish(jobMessage)`
11. tiktokpublishadapter -> tiktokreelspublishse: `publish(jobMessage)`
12. tiktokreelspublishse -> tiktokreelspublishse: `rateLimiter.acquire() & decryptToken(encryptedToken)`
13. tiktokreelspublishse -> s3mediastorage: `GET videoUrl (download video bytes)`
14. s3mediastorage --> tiktokreelspublishse: `return videoBytes (byte[])`
15. tiktokreelspublishse -> tiktokapi: `POST https://open.tiktokapis.com/v2/post/publish/video/init/ (post_info: caption, source_info: FILE_UPLOAD)`
16. tiktokapi --> tiktokreelspublishse: `return { publish_id: "tiktok_pub_888", upload_url: "https://..." }`
17. tiktokreelspublishse -> tiktokapi: `PUT upload_url (videoBytes, Content-Type: video/mp4)`
18. tiktokapi --> tiktokreelspublishse: `return 200 OK (Uploaded)`
19. tiktokreelspublishse --> tiktokpublishadapter: `return PublishResult (status='SUCCESS', platformPostId='tiktok_pub_888')`
20. tiktokpublishadapter --> publishjobconsumerpu: `return PublishResult`
21. publishjobconsumerpu -> rabbitmqbrandhubpubl: `channel.basicAck(deliveryTag)`
22. publishjobconsumerpu -> rabbitmqbrandhubpubl: `publish("brandhub.publishing", "publish.callback", CallbackMessage {status='SUCCESS', platformPostId='tiktok_pub_888'})`
23. rabbitmqbrandhubpubl --> publishjobconsumerpu: `return ack`
24. tiktokapi --> tiktokreelspublishse: `return Error Response (Invalid token / Video spec error)`
25. tiktokreelspublishse --> tiktokpublishadapter: `return PublishResult (status='FAILED', errorCode, errorMessage)`
26. tiktokpublishadapter --> publishjobconsumerpu: `return throw Exception`
27. publishjobconsumerpu -> rabbitmqbrandhubpubl: `basicNack -> Route to Dead Letter Queue ("publisher.job.dlq")`
28. rabbitmqbrandhubpubl --> publishjobconsumerpu: `return ack`
29. publishjobconsumerpu -> rabbitmqbrandhubpubl: `publish("brandhub.publishing", "publish.callback", CallbackMessage {status='FAILED', error})`
30. rabbitmqbrandhubpubl --> publishjobconsumerpu: `return ack`
31. rabbitmqbrandhubpubl -> publishcallbackconsu: `consume("business.publish_callback.queue", callbackMessage)`
32. publishcallbackconsu -> postmongorepositoryb: `updateStatus(postId, 'PUBLISHED', platformPostId)`
33. postmongorepositoryb --> publishcallbackconsu: `return 200 OK`
34. publishcallbackconsu -> postmongorepositoryb: `updateStatus(postId, 'FAILED', errorMessage)`
35. postmongorepositoryb --> publishcallbackconsu: `return 200 OK`
36. publishcallbackconsu -> rabbitmqbrandhubpubl: `channel.basicAck(deliveryTag)`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
