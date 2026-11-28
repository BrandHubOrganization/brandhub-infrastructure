# Sequence Flow — Create User

> Supplements `spec.md` (FR 3.10.7). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Admin** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `AdminUserManagementPage (UI)`.
- **System** — `AdminUserController` / `AdminUserService`.

---

## Flow A — Luồng thực thi chính: Create User

1. admin -> adminusermanagementp: `fills user details (name, email, role), clicks "Provision User"`
2. adminusermanagementp -> adminusercontroller: `POST /api/v1/admin/users/provision (ProvisionUserRequest)`
3. adminusercontroller -> adminuserservice: `provisionUser(adminId, request)`
4. adminuserservice -> userrepository: `existsByEmail(email)`
5. userrepository --> adminuserservice: `true`
6. adminuserservice --> adminusercontroller: `409 Conflict (EMAIL_ALREADY_IN_USE)`
7. adminusercontroller --> adminusermanagementp: `409 Conflict`
8. adminusermanagementp --> admin: `Show error "Email already in use"`
9. userrepository --> adminuserservice: `false`
10. adminuserservice -> userrepository: `save(newUser with status=PENDING_ACTIVATION)`
11. userrepository --> adminuserservice: `savedUser`
12. adminuserservice -> mailservice: `sendActivationEmail(email, activationToken)`
13. mailservice --> adminuserservice: `ok`
14. adminuserservice --> adminusercontroller: `201 Created (UserProvisionResponse)`
15. adminusercontroller --> adminusermanagementp: `201 Created`
16. adminusermanagementp --> admin: `"User provisioned — activation email sent"`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
