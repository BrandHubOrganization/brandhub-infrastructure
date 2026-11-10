# Sequence Flow — Add Material Repository

> Supplements `spec.md` (FR 3.6.12). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **CREATOR / CLIENT / MANAGER** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Add Material Repository Page`.
- **System** — `MaterialController` / `MaterialService`.

---

## Flow A — Luồng thực thi chính: Add Material Repository

1. materialservice -> materialservice: `Check session, scope and add permission`
2. materialservice -> materialservice: `Validate file format, size and metadata`
3. creatorclientmanager -> webdashboard: `Confirm file upload (repeat per file)`
4. webdashboard -> materialcontroller: `POST /api/v1/workspaces/{workspaceId}/materials`
5. materialcontroller -> materialservice: `uploadMaterial(user, command)`
6. materialservice -> workspacerepository: `Load workspace access`
7. workspacerepository --> materialservice: `Workspace`
8. materialservice --> materialcontroller: `401 Unauthorized / 403 Forbidden / 404 Not Found`
9. materialcontroller --> webdashboard: `401 Unauthorized / 403 Forbidden / 404 Not Found`
10. webdashboard --> creatorclientmanager: `Display access or resource error`
11. materialservice --> materialcontroller: `400 Bad Request`
12. materialcontroller --> webdashboard: `400 Bad Request`
13. webdashboard --> creatorclientmanager: `Display validation error`
14. materialservice -> materialrepository: `Save PENDING metadata and object key`
15. materialrepository --> materialservice: `pendingOutcome`
16. materialservice -> s3storage: `Upload file to S3`
17. s3storage --> materialservice: `storageOutcome`
18. materialservice -> materialrepository: `Save unavailable state`
19. materialrepository --> materialservice: `recoveryState`
20. materialservice --> materialcontroller: `503 Service Unavailable`
21. materialcontroller --> webdashboard: `503 Service Unavailable`
22. webdashboard --> creatorclientmanager: `Display upload failure or retry status`
23. materialservice -> materialrepository: `Save READY metadata`
24. materialrepository --> materialservice: `writeOutcome`
25. materialservice --> materialcontroller: `201 Created`
26. materialcontroller --> webdashboard: `201 Created`
27. webdashboard --> creatorclientmanager: `Display ready material in repository`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
