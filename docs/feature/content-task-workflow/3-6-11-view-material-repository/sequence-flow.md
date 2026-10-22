# Sequence Flow — View Material Repository

> Supplements `spec.md` (FR 3.6.11). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **CREATOR / CLIENT / MANAGER** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Workspace Dashboard`.
- **System** — `MaterialController` / `MaterialService`.

---

## Flow A — Luồng thực thi chính: View Material Repository

1. creatorclientmanager -> workspacedashboard: `Browse materials or details`
2. materialservice -> materialservice: `Validate session and query`
3. agencyrepository -> agencyrepository: `Check active workspace and view access`
4. materialservice -> materialservice: `Map metadata, badges and preview`
5. workspacedashboard -> materialcontroller: `GET workspace materials/brand-collection/`
6. materialcontroller -> materialservice: `listMaterials()`
7. materialservice --> materialcontroller: `Validation error`
8. materialcontroller --> workspacedashboard: `Show error`
9. materialservice ->> workspacerepository: `Load workspace`
10. workspacerepository -> workspace: `Read workspace`
11. workspace --> workspacerepository: `Workspace`
12. workspacerepository --> materialservice: `Workspace`
13. materialservice -> agencyrepository: `Load membership`
14. agencyrepository ->> workspacemember: `Read membership`
15. workspacemember --> agencyrepository: `WorkspaceMember`
16. agencyrepository --> materialservice: `WorkspaceMember`
17. materialservice ->> agencyrepository: `Load agency`
18. agencyrepository -> agency: `Read agency`
19. agency --> agencyrepository: `Agency`
20. agencyrepository --> materialservice: `Agency`
21. materialservice --> materialcontroller: `Access error`
22. materialcontroller --> workspacedashboard: `Show error`
23. materialservice ->> materialrepository: `Load scoped page / detail`
24. materialrepository ->> material: `Read READY, non-deleted materials`
25. material --> materialrepository: `Materials / detail`
26. materialrepository --> materialservice: `Materials / detail`
27. materialservice --> materialcontroller: `Unavailable`
28. materialcontroller --> workspacedashboard: `Notify and refresh list`
29. materialservice --> materialcontroller: `Load error`
30. materialcontroller --> workspacedashboard: `Show error and Retry`
31. materialservice --> materialcontroller: `Page / detail / empty result`
32. materialcontroller --> workspacedashboard: `Show results`
33. workspacedashboard --> creatorclientmanager: `Display Material Resource`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
