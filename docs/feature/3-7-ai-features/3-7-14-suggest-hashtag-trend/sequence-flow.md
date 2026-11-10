# Sequence Flow — Suggest hashtag trend

> Supplements `spec.md` (FR 3.7.10). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **OWNER / MANAGER / CREATOR** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Suggest hashtag trend Page`.
- **System** — `AiHashtagController` / `AiHashtagService`.

---

## Flow A — Luồng thực thi chính: Suggest hashtag trend

1. aihashtagservice -> aihashtagservice: `Validate topic, AI access and quota`
2. ownermanagercreator -> webdashboard: `Request suggestions for content/topic`
3. webdashboard -> aihashtagcontroller: `POST /api/v1/ai/suggest-hashtags`
4. aihashtagcontroller -> aihashtagservice: `suggestHashtags(user, command)`
5. aihashtagservice -> workspacerepository: `Load workspace access`
6. workspacerepository --> aihashtagservice: `Workspace`
7. aihashtagservice --> aihashtagcontroller: `400 Bad Request / 401 Unauthorized / 403 Forbidden`
8. aihashtagcontroller --> webdashboard: `400 Bad Request / 401 Unauthorized / 403 Forbidden`
9. webdashboard --> ownermanagercreator: `Display access or validation error`
10. aihashtagservice -> aiserviceinternalapi: `Request hashtag suggestions`
11. aiserviceinternalapi --> aihashtagservice: `suggestionsOutcome`
12. aihashtagservice --> aihashtagcontroller: `503 Service Unavailable`
13. aihashtagcontroller --> webdashboard: `503 Service Unavailable`
14. webdashboard --> ownermanagercreator: `Display suggestion failure`
15. aihashtagservice --> aihashtagcontroller: `200 OK`
16. aihashtagcontroller --> webdashboard: `200 OK`
17. webdashboard --> ownermanagercreator: `Display suggestions with trend evidence`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
