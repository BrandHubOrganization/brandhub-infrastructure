# Sequence Flow — Remove Material Repository

> Supplements `spec.md` (FR 3.6.14). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **CREATOR / CLIENT / MANAGER** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Remove Material Repository Page`.
- **System** — `MaterialController` / `MaterialService`.

---

## Flow A — Luồng thực thi chính: Remove Material Repository

1. materialservice -> materialservice: `Check session, scope and removal rights`
2. materialservice -> materialservice: `Block new material links`
3. materialservice -> materialservice: `Commit / rollback`
4. creatorclientmanager -> webdashboard: `Confirm removal (Cancel sends no request)`
5. webdashboard -> materialcontroller: `DELETE /api/v1/workspaces/{workspaceId}/materials/{materialId}`
6. materialcontroller -> materialservice: `removeMaterial(user, command)`
7. materialservice -> workspacerepository: `Load workspace`
8. workspacerepository --> materialservice: `Workspace`
9. materialservice -> workspacememberrepos: `Load membership`
10. workspacememberrepos --> materialservice: `WorkspaceMember`
11. materialservice -> agencyrepository: `Load agency`
12. agencyrepository --> materialservice: `Agency`
13. materialservice -> materialrepository: `Load material and deletion state`
14. materialrepository --> materialservice: `Material`
15. materialservice --> materialcontroller: `401 Unauthorized / 403 Forbidden / 404 Not Found`
16. materialcontroller --> webdashboard: `401 Unauthorized / 403 Forbidden / 404 Not Found`
17. webdashboard --> creatorclientmanager: `Display access or resource error`
18. materialservice --> materialcontroller: `409 Conflict`
19. materialcontroller --> webdashboard: `409 Conflict`
20. webdashboard --> creatorclientmanager: `Display already removed`
21. materialservice -> materialrepository: `Soft-delete with user/time`
22. materialrepository --> materialservice: `writeOutcome`
23. materialservice --> materialcontroller: `204 No Content`
24. materialcontroller --> webdashboard: `204 No Content`
25. webdashboard --> creatorclientmanager: `Display material removed from repository`
26. materialservice --> materialcontroller: `409 Conflict / 500 Internal Server Error`
27. materialcontroller --> webdashboard: `409 Conflict / 500 Internal Server Error`
28. webdashboard --> creatorclientmanager: `Display save error; retain previous values`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
