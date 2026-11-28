# Sequence Flow — Update Hastag Collection

> Supplements `spec.md` (FR 3.6.20). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **CREATOR / CLIENT / MANAGER** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Update Hastag Collection Page`.
- **System** — `HashtagController` / `HashtagService`.

---

## Flow A — Luồng thực thi chính: Update Hastag Collection

1. hashtagservice -> hashtagservice: `Validate rights, scope, uniqueness and expectedVersion`
2. creatorclientmanager -> webdashboard: `Save hashtag changes`
3. webdashboard -> hashtagcontroller: `PATCH /api/v1/workspaces/{workspaceId}/hashtags/{hashtagId}`
4. hashtagcontroller -> hashtagservice: `updateHashtag(user, command)`
5. hashtagservice -> workspacerepository: `Load workspace access`
6. workspacerepository --> hashtagservice: `Workspace`
7. hashtagservice -> hashtagrepository: `Load hashtag and version`
8. hashtagrepository --> hashtagservice: `Hashtag`
9. hashtagservice --> hashtagcontroller: `400 Bad Request / 403 Forbidden / 409 Conflict`
10. hashtagcontroller --> webdashboard: `400 Bad Request / 403 Forbidden / 409 Conflict`
11. webdashboard --> creatorclientmanager: `Display validation or reload conflict`
12. hashtagservice -> hashtagrepository: `Save hashtag changes with version check`
13. hashtagrepository --> hashtagservice: `writeOutcome`
14. hashtagservice --> hashtagcontroller: `200 OK`
15. hashtagcontroller --> webdashboard: `200 OK`
16. webdashboard --> creatorclientmanager: `Display updated collection entry`
17. hashtagservice --> hashtagcontroller: `409 Conflict / 500 Internal Server Error`
18. hashtagcontroller --> webdashboard: `409 Conflict / 500 Internal Server Error`
19. webdashboard --> creatorclientmanager: `Display save error; retain previous values`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
