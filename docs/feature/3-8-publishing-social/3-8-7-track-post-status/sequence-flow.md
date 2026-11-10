# Sequence Flow — Publish Facebook Post

> Supplements `spec.md` (FR 3.8.8). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Scheduler (Job)** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Publish Facebook Post Page`.
- **System** — `PublishFacebookPostController` / `FacebookPublishAdapter (Publisher Service)`.

---

## Flow A — Luồng thực thi chính: Publish Facebook Post

1. schedulerjob -> schedulerserviceimpl: `triggerEveryMinute()`
2. schedulerserviceimpl -> postmongorepositoryb: `findScheduledPosts(scheduledAt <= NOW(), status='SCHEDULED')`
3. postmongorepositoryb --> schedulerserviceimpl: `return List<PostDocument>`
4. schedulerserviceimpl -> postmongorepositoryb: `updateStatus(postId, 'IN_PROGRESS')`
5. postmongorepositoryb --> schedulerserviceimpl: `return 200 OK`
6. schedulerserviceimpl -> rabbitmqbrandhubpubl: `publish("brandhub.publishing", "publish.job", PublishJobMessage)`
7. rabbitmqbrandhubpubl --> schedulerserviceimpl: `return Acknowledgement`
8. rabbitmqbrandhubpubl -> publishjobconsumerpu: `consume("publisher.job.queue", message)`
9. publishjobconsumerpu -> publishjobconsumerpu: `checkRedisLockSETNX("processingPostIds:" + postId, ttl=30m)`
10. publishjobconsumerpu -> facebookpublishadapt: `publish(jobMessage)`
11. facebookpublishadapt -> facebookpublishservi: `publish(jobMessage)`
12. facebookpublishservi -> facebookpublishservi: `rateLimiter.acquire() & decryptToken(encryptedToken)`
13. facebookpublishservi -> metagraphapifacebook: `POST https://graph-video.facebook.com/v26.0/{pageId}/videos (file_url, description)`
14. facebookpublishservi -> metagraphapifacebook: `POST https://graph.facebook.com/v26.0/{pageId}/photos (url, message, published=true)`
15. facebookpublishservi -> metagraphapifacebook: `POST https://graph.facebook.com/v26.0/{pageId}/feed (message)`
16. metagraphapifacebook --> facebookpublishservi: `return FacebookResponse { id: "fb_post_123" }`
17. facebookpublishservi --> facebookpublishadapt: `return PublishResult (status='SUCCESS', platformPostId='fb_post_123')`
18. facebookpublishadapt --> publishjobconsumerpu: `return PublishResult`
19. publishjobconsumerpu -> rabbitmqbrandhubpubl: `channel.basicAck(deliveryTag)`
20. publishjobconsumerpu -> rabbitmqbrandhubpubl: `publish("brandhub.publishing", "publish.callback", CallbackMessage {status='SUCCESS', platformPostId='fb_post_123'})`
21. rabbitmqbrandhubpubl --> publishjobconsumerpu: `return ack`
22. metagraphapifacebook --> facebookpublishservi: `return Error Response (HTTP 429/401/500)`
23. facebookpublishservi --> facebookpublishadapt: `return PublishResult (status='FAILED', errorCode, errorMessage)`
24. facebookpublishadapt --> publishjobconsumerpu: `return throw Exception`
25. publishjobconsumerpu -> rabbitmqbrandhubpubl: `basicNack -> Route to Dead Letter Queue ("publisher.job.dlq")`
26. rabbitmqbrandhubpubl --> publishjobconsumerpu: `return ack`
27. publishjobconsumerpu -> rabbitmqbrandhubpubl: `publish("brandhub.publishing", "publish.callback", CallbackMessage {status='FAILED', error})`
28. rabbitmqbrandhubpubl --> publishjobconsumerpu: `return ack`
29. rabbitmqbrandhubpubl -> publishcallbackconsu: `consume("business.publish_callback.queue", callbackMessage)`
30. publishcallbackconsu -> postmongorepositoryb: `updateStatus(postId, 'PUBLISHED', platformPostId)`
31. postmongorepositoryb --> publishcallbackconsu: `return 200 OK`
32. publishcallbackconsu -> postmongorepositoryb: `updateStatus(postId, 'FAILED', errorMessage)`
33. postmongorepositoryb --> publishcallbackconsu: `return 200 OK`
34. publishcallbackconsu -> rabbitmqbrandhubpubl: `channel.basicAck(deliveryTag)`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
