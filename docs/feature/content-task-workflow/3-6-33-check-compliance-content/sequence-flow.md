# Sequence Flow — Check Compliance Content

> Supplements `spec.md` (FR 3.6.33). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **CREATOR / CLIENT / MANAGER** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Check Compliance Content Page`.
- **System** — `ContentCheckController` / `ContentCheckService`.

---

## Flow A — Luồng thực thi chính: Check Compliance Content

1. contentcheckservice -> contentcheckservice: `Check content / conditional AI access`
2. contentcheckservice -> contentcheckservice: `Check input and provider coverage`
3. creatorclientmanager -> webdashboard: `Check Compliance for selected content version`
4. webdashboard -> contentcheckcontroll: `POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/compliance-check`
5. contentcheckcontroll -> contentcheckservice: `checkCompliance(user, command)`
6. contentcheckservice -> workspacerepository: `Load workspace`
7. workspacerepository --> contentcheckservice: `Workspace`
8. contentcheckservice -> workspacememberrepos: `Load membership`
9. workspacememberrepos --> contentcheckservice: `WorkspaceMember`
10. contentcheckservice -> agencyrepository: `Load agency`
11. agencyrepository --> contentcheckservice: `Agency`
12. contentcheckservice --> contentcheckcontroll: `401 Unauthorized / 403 Forbidden / 404 Not Found`
13. contentcheckcontroll --> webdashboard: `401 Unauthorized / 403 Forbidden / 404 Not Found`
14. webdashboard --> creatorclientmanager: `Display access or resource error`
15. contentcheckservice --> contentcheckcontroll: `400 Bad Request / 503 Service Unavailable`
16. contentcheckcontroll --> webdashboard: `400 Bad Request / 503 Service Unavailable`
17. webdashboard --> creatorclientmanager: `Display unavailable or unsupported check`
18. contentcheckservice -> hiveapi: `Check supported text/images [provider proposed]`
19. hiveapi --> contentcheckservice: `per-part issues, coverage or errors`
20. contentcheckservice -> contentcheckresultre: `Save versioned check evidence`
21. contentcheckresultre --> contentcheckservice: `checkTrace`
22. contentcheckservice --> contentcheckcontroll: `503 Service Unavailable`
23. contentcheckcontroll --> webdashboard: `503 Service Unavailable`
24. webdashboard --> creatorclientmanager: `Display partial / unavailable report; Retry`
25. contentcheckservice --> contentcheckcontroll: `200 OK`
26. contentcheckcontroll --> webdashboard: `200 OK`
27. webdashboard --> creatorclientmanager: `Display versioned compliance report`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
