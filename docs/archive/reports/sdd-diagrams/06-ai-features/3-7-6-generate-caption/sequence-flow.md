# Sequence Flow — Generate Caption

> Supplements `spec.md` (FR 3.7.2). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **User** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `ContentEditorPage (UI)`.
- **System** — `AiFeatureController` / `AiCaptionService`.

---

## Flow A — Luồng thực thi chính: Generate Caption

1. user -> contenteditorpageui: `selects post, clicks "Generate Caption with AI"`
2. contenteditorpageui -> aifeaturecontroller: `POST /api/v1/ai/captions/generate (GenerateCaptionRequest)`
3. aifeaturecontroller -> aicaptionservice: `generateCaption(userId, request)`
4. aicaptionservice -> postrepository: `findById(postId)`
5. postrepository --> aicaptionservice: `Optional.empty()`
6. aicaptionservice --> aifeaturecontroller: `404 Not Found (POST_NOT_FOUND)`
7. aifeaturecontroller --> contenteditorpageui: `404 Not Found`
8. contenteditorpageui --> user: `Show error "Post not found"`
9. postrepository --> aicaptionservice: `Optional<Post>`
10. aicaptionservice -> aiserviceclient: `POST /ai/generate-caption (topic, tone, platform)`
11. aiserviceclient --> aicaptionservice: `GeneratedCaption(text, hashtags)`
12. aicaptionservice --> aifeaturecontroller: `AiCaptionResponse(caption, hashtags)`
13. aifeaturecontroller --> contenteditorpageui: `200 OK (AiCaptionResponse)`
14. contenteditorpageui --> user: `Display AI-generated caption with hashtags`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
