# Sequence Flow — View Posted Detail

> Supplements `spec.md` (FR 3.8.4). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Member / Manager** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `PostDetailPage (UI)`.
- **System** — `PostController` / `PostServiceImpl`.

---

## Flow A — Luồng thực thi chính: View Posted Detail

1. membermanager -> postdetailpageui: `Click on published post in list / calendar`
2. postdetailpageui -> postcontroller: `GET /api/v1/workspaces/{workspaceId}/posts/{postId}`
3. postcontroller -> postserviceimpl: `getPostTrackDetail(workspaceId, postId)`
4. postserviceimpl -> postmongorepository: `findByIdAndWorkspaceId(postId, workspaceId)`
5. postmongorepository --> postserviceimpl: `return PostDocument (platform, platformPostId, platformPostUrl)`
6. postserviceimpl -> redismetricscache: `get("post:metrics:" + postId)`
7. redismetricscache --> postserviceimpl: `return cachedMetricsJson`
8. redismetricscache --> postserviceimpl: `return null`
9. socialmetricscontrol -> socialmetricsservice: `fetchPostMetrics(platform, platformPostId)`
10. postserviceimpl -> socialmetricscontrol: `GET /api/v1/social/metrics?platform={p}&platformPostId={extId}`
11. socialmetricsservice -> socialplatformgrapha: `GET /{platformPostId}?fields=reactions.summary(true),shares,comments.summary(true)`
12. socialplatformgrapha --> socialmetricsservice: `return rawMetricsResponse (reactionCount, shareCount, commentCount)`
13. socialmetricsservice --> socialmetricscontrol: `return metricsPayload`
14. socialmetricscontrol --> postserviceimpl: `return 200 OK (metricsPayload)`
15. postserviceimpl -> redismetricscache: `set("post:metrics:" + postId, metricsPayload, ttl=15m)`
16. redismetricscache --> postserviceimpl: `return OK`
17. postserviceimpl -> posttrackdetailrespo: `new PostTrackDetailResponse(postDoc, metrics, platformPostUrl)`
18. postserviceimpl --> postcontroller: `return trackDetailResponse`
19. posttrackdetailrespo --> postserviceimpl: `return trackDetailResponse`
20. postcontroller --> postdetailpageui: `return 200 OK (ApiResponse { data: trackDetailResponse })`
21. postdetailpageui --> membermanager: `Render post preview, engagement counts & original platform link`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
