# Sequence Flow — View Hastag Collection

> Supplements `spec.md` (FR 3.6.18). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **CREATOR / CLIENT / MANAGER** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `View Hastag Collection Page`.
- **System** — `HashtagController` / `HashtagService`.

---

## Flow A — Luồng thực thi chính: View Hastag Collection

1. hashtagservice -> hashtagservice: `Check session, scope and collection view permission`
2. creatorclientmanager -> webdashboard: `Open Hashtag Collection / change filters`
3. webdashboard -> hashtagcontroller: `GET /api/v1/workspaces/{workspaceId}/hashtags`
4. hashtagcontroller -> hashtagservice: `listHashtags(user, query)`
5. hashtagservice -> workspacerepository: `Load workspace`
6. workspacerepository --> hashtagservice: `Workspace`
7. hashtagservice -> workspacememberrepos: `Load membership`
8. workspacememberrepos --> hashtagservice: `WorkspaceMember`
9. hashtagservice -> agencyrepository: `Load agency`
10. agencyrepository --> hashtagservice: `Agency`
11. hashtagservice --> hashtagcontroller: `401 Unauthorized / 403 Forbidden / 404 Not Found`
12. hashtagcontroller --> webdashboard: `401 Unauthorized / 403 Forbidden / 404 Not Found`
13. webdashboard --> creatorclientmanager: `Display access or resource error`
14. hashtagservice -> hashtagrepository: `Query active tags with paging/search`
15. hashtagrepository --> hashtagservice: `entries`
16. hashtagservice --> hashtagcontroller: `500 Internal Server Error`
17. hashtagcontroller --> webdashboard: `500 Internal Server Error`
18. webdashboard --> creatorclientmanager: `Display load error with Retry`
19. hashtagservice --> hashtagcontroller: `200 OK`
20. hashtagcontroller --> webdashboard: `200 OK`
21. webdashboard --> creatorclientmanager: `Display tag details / empty list`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
