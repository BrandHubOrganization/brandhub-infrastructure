# Sequence Flow — Remove Hastag Collection

> Supplements `spec.md` (FR 3.6.21). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **CREATOR / CLIENT / MANAGER** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Remove Hastag Collection Page`.
- **System** — `HashtagController` / `HashtagService`.

---

## Flow A — Luồng thực thi chính: Remove Hastag Collection

1. hashtagservice -> hashtagservice: `Check removal rights, version and required-tag policy`
2. creatorclientmanager -> webdashboard: `Select Remove hashtag`
3. webdashboard --> creatorclientmanager: `Display warning and current scope`
4. creatorclientmanager -> webdashboard: `Confirm removal`
5. webdashboard -> hashtagcontroller: `DELETE /api/v1/workspaces/{workspaceId}/hashtags/{hashtagId}`
6. hashtagcontroller -> hashtagservice: `removeHashtag(user, command)`
7. hashtagservice -> workspacerepository: `Load workspace access`
8. workspacerepository --> hashtagservice: `Workspace`
9. hashtagservice -> hashtagrepository: `Load hashtag and required scope`
10. hashtagrepository --> hashtagservice: `Hashtag`
11. hashtagservice --> hashtagcontroller: `403 Forbidden / 404 Not Found / 409 Conflict`
12. hashtagcontroller --> webdashboard: `403 Forbidden / 404 Not Found / 409 Conflict`
13. webdashboard --> creatorclientmanager: `Display access or conflict error`
14. hashtagservice -> hashtagrepository: `Soft-remove hashtag entry`
15. hashtagrepository --> hashtagservice: `writeOutcome`
16. hashtagservice --> hashtagcontroller: `204 No Content`
17. hashtagcontroller --> webdashboard: `204 No Content`
18. webdashboard --> creatorclientmanager: `Display entry removed from collection`
19. hashtagservice --> hashtagcontroller: `409 Conflict / 500 Internal Server Error`
20. hashtagcontroller --> webdashboard: `409 Conflict / 500 Internal Server Error`
21. webdashboard --> creatorclientmanager: `Display save error; retain previous values`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
