# Sequence Flow — Publish Facebook Story

> Supplements `spec.md` (FR 3.8.9). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Scheduler (Job)** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Publish Facebook Story Page`.
- **System** — `PublishFacebookStoryController` / `PublishCallbackConsumer (Business Service)`.

---

## Flow A — Luồng thực thi chính: Publish Facebook Story

1. schedulerjob -> schedulerserviceimpl: `triggerEveryMinute()`
2. schedulerserviceimpl -> postmongorepositoryb: `findScheduledPosts(scheduledAt <= NOW(), status='SCHEDULED')`
3. postmongorepositoryb --> schedulerserviceimpl: `return List<PostDocument>`
4. schedulerserviceimpl -> postmongorepositoryb: `updateStatus(postId, 'IN_PROGRESS')`
5. postmongorepositoryb --> schedulerserviceimpl: `return 200 OK`
6. schedulerserviceimpl -> rabbitmqbrandhubpubl: `publish("brandhub.publishing", "publish.job", PublishJobMessage {platform='FACEBOOK', postType='STORY', ...})`
7. rabbitmqbrandhubpubl --> schedulerserviceimpl: `return Acknowledgement`
8. rabbitmqbrandhubpubl -> publishjobconsumerpu: `consume("publisher.job.queue", message)`
9. publishjobconsumerpu -> publishjobconsumerpu: `checkRedisLockSETNX("processingPostIds:" + postId, ttl=30m)`
10. publishjobconsumerpu -> facebookpublishadapt: `publish(jobMessage)`
11. facebookpublishadapt -> facebookpublishservi: `publish(jobMessage)`
12. facebookpublishservi -> facebookpublishservi: `rateLimiter.acquire() & decryptToken(encryptedToken)`
13. facebookpublishservi -> metagraphapifacebook: `POST https://graph.facebook.com/v26.0/{pageId}/video_stories (video_url)`
14. facebookpublishservi -> metagraphapifacebook: `POST https://graph.facebook.com/v26.0/{pageId}/photo_stories (photo_url)`
15. metagraphapifacebook --> facebookpublishservi: `return FacebookResponse { id: "story_98765" }`
16. facebookpublishservi --> facebookpublishadapt: `return PublishResult (status='SUCCESS', platformPostId='story_98765')`
17. facebookpublishadapt --> publishjobconsumerpu: `return PublishResult`
18. publishjobconsumerpu -> rabbitmqbrandhubpubl: `channel.basicAck(deliveryTag)`
19. publishjobconsumerpu -> rabbitmqbrandhubpubl: `publish("brandhub.publishing", "publish.callback", CallbackMessage {status='SUCCESS', platformPostId='story_98765'})`
20. rabbitmqbrandhubpubl --> publishjobconsumerpu: `return ack`
21. metagraphapifacebook --> facebookpublishservi: `return Error Response (HTTP 400/401/429)`
22. facebookpublishservi --> facebookpublishadapt: `return PublishResult (status='FAILED', errorCode, errorMessage)`
23. facebookpublishadapt --> publishjobconsumerpu: `return throw Exception`
24. publishjobconsumerpu -> rabbitmqbrandhubpubl: `basicNack -> Route to Dead Letter Queue ("publisher.job.dlq")`
25. rabbitmqbrandhubpubl --> publishjobconsumerpu: `return ack`
26. publishjobconsumerpu -> rabbitmqbrandhubpubl: `publish("brandhub.publishing", "publish.callback", CallbackMessage {status='FAILED', error})`
27. rabbitmqbrandhubpubl --> publishjobconsumerpu: `return ack`
28. rabbitmqbrandhubpubl -> publishcallbackconsu: `consume("business.publish_callback.queue", callbackMessage)`
29. publishcallbackconsu -> postmongorepositoryb: `updateStatus(postId, 'PUBLISHED', platformPostId)`
30. postmongorepositoryb --> publishcallbackconsu: `return 200 OK`
31. publishcallbackconsu -> postmongorepositoryb: `updateStatus(postId, 'FAILED', errorMessage)`
32. postmongorepositoryb --> publishcallbackconsu: `return 200 OK`
33. publishcallbackconsu -> rabbitmqbrandhubpubl: `channel.basicAck(deliveryTag)`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
