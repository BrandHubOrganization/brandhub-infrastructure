# Sequence Flow — Preview Post

> Supplements `spec.md` (FR 3.8.5). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Creator / Manager** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `PostEditorPage (Preview Panel)`.
- **System** — `PostController` / `PostServiceImpl`.

---

## Flow A — Luồng thực thi chính: Preview Post

1. creatormanager -> posteditorpageprevie: `Select platform tab (e.g., THREADS / INSTAGRAM / TIKTOK / FB)`
2. posteditorpageprevie -> postcontroller: `GET /api/v1/workspaces/{workspaceId}/posts/{postId}/preview?platform=?`
3. postcontroller -> postserviceimpl: `generatePlatformPreview(workspaceId, postId, platform)`
4. postserviceimpl -> postmongorepository: `findByIdAndWorkspaceId(postId, workspaceId)`
5. postmongorepository --> postserviceimpl: `return PostDocument (contentText, media, hashtags)`
6. postserviceimpl -> postserviceimpl: `validateAndTransformLayout(postDoc, platform)`
7. postserviceimpl -> postpreviewresponse: `new PostPreviewResponse(formattedText, mediaUrls, platformLayoutRules, warnings)`
8. postpreviewresponse --> postserviceimpl: `return previewResponse`
9. postserviceimpl --> postcontroller: `return previewResponse`
10. postcontroller --> posteditorpageprevie: `return 200 OK (ApiResponse { data: previewResponse })`
11. posteditorpageprevie --> creatormanager: `Render mockup layout`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
