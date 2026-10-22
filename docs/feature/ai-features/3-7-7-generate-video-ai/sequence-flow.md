# Sequence Flow — Generate Video

> Supplements `spec.md` (FR 3.7.7). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **User** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `ContentEditorPage (UI)`.
- **System** — `AiFeatureController` / `AiVideoService`.

---

## Flow A — Luồng thực thi chính: Generate Video

1. user -> contenteditorpageui: `configures video prompt & settings, clicks "Generate Video"`
2. contenteditorpageui -> aifeaturecontroller: `POST /api/v1/ai/videos/generate (GenerateVideoRequest)`
3. aifeaturecontroller -> aivideoservice: `generateVideo(userId, request)`
4. aivideoservice -> postrepository: `findById(postId)`
5. postrepository --> aivideoservice: `Optional.empty()`
6. aivideoservice --> aifeaturecontroller: `404 Not Found (POST_NOT_FOUND)`
7. aifeaturecontroller --> contenteditorpageui: `404 Not Found`
8. contenteditorpageui --> user: `Show error "Post not found"`
9. postrepository --> aivideoservice: `Optional<Post>`
10. aivideoservice -> aiserviceclient: `POST /ai/generate-video (prompt, duration, style)`
11. aiserviceclient --> aivideoservice: `GeneratedVideoResult(videoUrl, durationSecs)`
12. aivideoservice -> mediastorageservice: `storeGeneratedAsset(videoUrl, userId)`
13. mediastorageservice --> aivideoservice: `assetId`
14. aivideoservice --> aifeaturecontroller: `AiVideoResponse(assetId, previewUrl)`
15. aifeaturecontroller --> contenteditorpageui: `200 OK (AiVideoResponse)`
16. contenteditorpageui --> user: `Display video preview, option to attach to post`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
