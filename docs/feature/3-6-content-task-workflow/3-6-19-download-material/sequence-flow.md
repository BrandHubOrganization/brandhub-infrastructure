# Sequence Flow — Download Material

> Supplements `spec.md` (FR 3.6.16). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **CREATOR / CLIENT / MANAGER** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Download Material Page`.
- **System** — `MaterialController` / `MaterialService`.

---

## Flow A — Luồng thực thi chính: Download Material

1. materialservice -> materialservice: `Check session, scope and workspace download permission`
2. creatorclientmanager -> webdashboard: `Download selected material`
3. webdashboard -> materialcontroller: `GET /api/v1/workspaces/{workspaceId}/materials/{materialId}/download`
4. materialcontroller -> materialservice: `downloadMaterial(user, command)`
5. materialservice -> workspacerepository: `Load workspace`
6. workspacerepository --> materialservice: `Workspace`
7. materialservice -> workspacememberrepos: `Load membership`
8. workspacememberrepos --> materialservice: `WorkspaceMember`
9. materialservice -> agencyrepository: `Load agency`
10. agencyrepository --> materialservice: `Agency`
11. materialservice -> materialrepository: `Load READY, non-deleted material`
12. materialrepository --> materialservice: `Material`
13. materialservice --> materialcontroller: `401 Unauthorized / 403 Forbidden / 404 Not Found`
14. materialcontroller --> webdashboard: `401 Unauthorized / 403 Forbidden / 404 Not Found`
15. webdashboard --> creatorclientmanager: `Display access or resource error`
16. materialservice -> s3storage: `Read exact selected object from S3`
17. s3storage --> materialservice: `file stream / storage error`
18. materialservice --> materialcontroller: `503 Service Unavailable`
19. materialcontroller --> webdashboard: `503 Service Unavailable`
20. webdashboard --> creatorclientmanager: `Display download error; retry`
21. materialservice --> materialcontroller: `200 OK`
22. materialcontroller --> webdashboard: `200 OK`
23. webdashboard --> creatorclientmanager: `Display download started; browser receives selected file`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
