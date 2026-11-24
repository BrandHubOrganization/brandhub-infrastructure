# Sequence Flow — View Content History

> Supplements `spec.md` (FR 3.6.35). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **CREATOR / CLIENT / MANAGER** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `View Content History Page`.
- **System** — `ContentHistoryController` / `ContentHistoryService`.

---

## Flow A — Luồng thực thi chính: View Content History

1. contenthistoryservic -> contenthistoryservic: `Check session, scope and history view permission`
2. creatorclientmanager -> webdashboard: `Open content history and filters`
3. webdashboard -> contenthistorycontro: `GET /api/v1/workspaces/{workspaceId}/content-history`
4. contenthistorycontro -> contenthistoryservic: `listContentHistory(user, query)`
5. contenthistoryservic -> workspacerepository: `Load workspace access`
6. workspacerepository --> contenthistoryservic: `Workspace`
7. contenthistoryservic --> contenthistorycontro: `401 Unauthorized / 403 Forbidden / 404 Not Found`
8. contenthistorycontro --> webdashboard: `401 Unauthorized / 403 Forbidden / 404 Not Found`
9. webdashboard --> creatorclientmanager: `Display access or resource error`
10. contenthistoryservic -> contenthistoryreposi: `Query scoped history with paging`
11. contenthistoryreposi --> contenthistoryservic: `history`
12. contenthistoryservic --> contenthistorycontro: `500 Internal Server Error`
13. contenthistorycontro --> webdashboard: `500 Internal Server Error`
14. webdashboard --> creatorclientmanager: `Display load error with Retry`
15. contenthistoryservic --> contenthistorycontro: `200 OK`
16. contenthistorycontro --> webdashboard: `200 OK`
17. webdashboard --> creatorclientmanager: `Display history / empty list`
18. creatorclientmanager -> webdashboard: `Reuse selected version in destination Task`
19. webdashboard -> contenthistorycontro: `POST /api/v1/workspaces/{workspaceId}/content-reuse`
20. contenthistorycontro -> contenthistoryservic: `reuseContent(user, command)`
21. contenthistoryservic -> contenthistoryreposi: `Load content history entry`
22. contenthistoryreposi --> contenthistoryservic: `ContentHistoryEntry`
23. contenthistoryservic -> contentreusereposito: `Save unique reuse trace`
24. contentreusereposito --> contenthistoryservic: `reuseOutcome`
25. contenthistoryservic --> contenthistorycontro: `200 OK`
26. contenthistorycontro --> webdashboard: `200 OK`
27. webdashboard --> creatorclientmanager: `Display reused content`
28. contenthistoryservic --> contenthistorycontro: `500 Internal Server Error`
29. contenthistorycontro --> webdashboard: `500 Internal Server Error`
30. webdashboard --> creatorclientmanager: `Display reuse failure`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
