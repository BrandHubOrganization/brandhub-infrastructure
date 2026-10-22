# Sequence Flow — Update Material Repository

> Supplements `spec.md` (FR 3.6.13). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **CREATOR / CLIENT / MANAGER** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Update Material Repository Page`.
- **System** — `MaterialController` / `MaterialService`.

---

## Flow A — Luồng thực thi chính: Update Material Repository

1. materialservice -> materialservice: `Validate session, rights, allowed fields and expectedVersion`
2. creatorclientmanager -> webdashboard: `Save edited type/note`
3. webdashboard -> materialcontroller: `PATCH /api/v1/workspaces/{workspaceId}/materials/{materialId}`
4. materialcontroller -> materialservice: `updateMaterial(user, command)`
5. materialservice -> workspacerepository: `Load workspace access`
6. workspacerepository --> materialservice: `Workspace`
7. materialservice -> materialrepository: `Load material and version`
8. materialrepository --> materialservice: `Material`
9. materialservice --> materialcontroller: `400 Bad Request / 403 Forbidden / 409 Conflict`
10. materialcontroller --> webdashboard: `400 Bad Request / 403 Forbidden / 409 Conflict`
11. webdashboard --> creatorclientmanager: `Display save error; retain previous values`
12. materialservice -> materialrepository: `Save edited metadata with version check`
13. materialrepository --> materialservice: `writeOutcome`
14. materialservice --> materialcontroller: `200 OK`
15. materialcontroller --> webdashboard: `200 OK`
16. webdashboard --> creatorclientmanager: `Display updated material`
17. materialservice --> materialcontroller: `409 Conflict / 500 Internal Server Error`
18. materialcontroller --> webdashboard: `409 Conflict / 500 Internal Server Error`
19. webdashboard --> creatorclientmanager: `Display validation or conflict error`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
