# Sequence Flow — Check Copyright Infringement

> Supplements `spec.md` (FR 3.6.34). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **CREATOR / CLIENT / MANAGER** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Check Copyright Infringement Page`.
- **System** — `ContentCheckController` / `ContentCheckService`.

---

## Flow A — Luồng thực thi chính: Check Copyright Infringement

1. creatorclientmanager -> webdashboard: `Check Copyright on selected image/version`
2. contentcheckservice -> contentcheckservice: `Validate image and agreed provider/corpus/scope`
3. contentcheckservice -> contentcheckservice: `Check content / conditional AI access`
4. webdashboard -> contentcheckcontroll: `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/copyright-check`
5. contentcheckcontroll -> contentcheckservice: `checkCopyright(user, command)`
6. contentcheckservice -> workspacerepository: `Load workspace`
7. workspacerepository --> contentcheckservice: `Workspace`
8. contentcheckservice -> workspacememberrepos: `Load membership`
9. workspacememberrepos --> contentcheckservice: `WorkspaceMember`
10. contentcheckservice -> agencyrepository: `Load agency`
11. agencyrepository --> contentcheckservice: `Agency`
12. contentcheckcontroll --> webdashboard: `401 Unauthorized / 403 Forbidden / 404 Not Found`
13. contentcheckservice --> contentcheckcontroll: `401 Unauthorized / 403 Forbidden / 404 Not Found`
14. webdashboard --> creatorclientmanager: `Display access or resource error`
15. contentcheckcontroll --> webdashboard: `400 Bad Request / 503 Service Unavailable`
16. contentcheckservice --> contentcheckcontroll: `400 Bad Request / 503 Service Unavailable`
17. webdashboard --> creatorclientmanager: `Display check unavailable`
18. contentcheckservice -> googlevisionapi: `Compare selected image [Google Vision proposed]`
19. googlevisionapi --> contentcheckservice: `matching sources / no matches / error`
20. contentcheckcontroll --> webdashboard: `503 Service Unavailable`
21. contentcheckservice --> contentcheckcontroll: `503 Service Unavailable`
22. webdashboard --> creatorclientmanager: `Display COPYRIGHT_SERVICE_UNAVAILABLE; Retry`
23. contentcheckservice -> contentcheckresultre: `Save versioned check evidence`
24. contentcheckresultre --> contentcheckservice: `checkTrace`
25. contentcheckcontroll --> webdashboard: `200 OK`
26. contentcheckservice --> contentcheckcontroll: `200 OK`
27. webdashboard --> creatorclientmanager: `Display versioned matches / no matches`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
