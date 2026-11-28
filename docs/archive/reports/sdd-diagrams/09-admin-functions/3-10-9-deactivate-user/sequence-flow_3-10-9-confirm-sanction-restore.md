# Sequence Flow — Deactive User

> Supplements `spec.md` (FR 3.10.9). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Admin** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `AdminUserManagementPage (UI)`.
- **System** — `AdminUserController` / `AdminUserService`.

---

## Flow A — Luồng thực thi chính: Deactive User

1. admin -> adminusermanagementp: `selects user, chooses action (SUSPEND / RESTORE), confirms`
2. adminusermanagementp -> adminusercontroller: `PATCH /api/v1/admin/users/{userId}/status (UpdateUserStatusRequest)`
3. adminusercontroller -> adminuserservice: `updateUserStatus(adminId, userId, action)`
4. adminuserservice -> userrepository: `findById(userId)`
5. userrepository --> adminuserservice: `Optional.empty()`
6. adminuserservice --> adminusercontroller: `404 Not Found (USER_NOT_FOUND)`
7. adminusercontroller --> adminusermanagementp: `404 Not Found`
8. adminusermanagementp --> admin: `Show error "User not found"`
9. userrepository --> adminuserservice: `Optional<User>`
10. adminuserservice -> userrepository: `update(user, status=SUSPENDED)`
11. userrepository --> adminuserservice: `ok`
12. adminuserservice -> notificationservice: `notifyUser(userId, ACCOUNT_SUSPENDED)`
13. notificationservice --> adminuserservice: `ok`
14. adminuserservice --> adminusercontroller: `200 OK`
15. adminusercontroller --> adminusermanagementp: `200 OK`
16. adminusermanagementp --> admin: `"User account suspended"`
17. userrepository --> adminuserservice: `Optional<User>`
18. adminuserservice -> userrepository: `update(user, status=ACTIVE)`
19. userrepository --> adminuserservice: `ok`
20. adminuserservice -> notificationservice: `notifyUser(userId, ACCOUNT_RESTORED)`
21. notificationservice --> adminuserservice: `ok`
22. adminuserservice --> adminusercontroller: `200 OK`
23. adminusercontroller --> adminusermanagementp: `200 OK`
24. adminusermanagementp --> admin: `"User account restored"`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
