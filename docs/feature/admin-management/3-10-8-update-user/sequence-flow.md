# Sequence Flow — Update User

> Supplements `spec.md` (FR 3.10.8). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Admin** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `EditUserDialog (UI)`.
- **System** — `AdminUserController` / `AdminUserProvisioningService`.

---

## Flow A — Luồng thực thi chính: Update User

1. admin -> edituserdialogui: `Submit profile / plan update request`
2. edituserdialogui -> adminusercontroller: `PATCH /api/v1/admin/users/{id}(request)`
3. adminusercontroller -> adminaccountservice: `requireAdmin(actorId)`
4. adminaccountservice --> adminusercontroller: `200 OK (ADMIN verified)`
5. adminusercontroller -> adminuserprovisionin: `updateUserProfileAndPlan(userId, request)`
6. adminuserprovisionin -> userrepository: `findById(userId)`
7. userrepository --> adminuserprovisionin: `return Optional<UserEntity>`
8. adminuserprovisionin -> userrepository: `save(updatedUser)`
9. userrepository --> adminuserprovisionin: `return savedUser`
10. adminuserprovisionin --> adminusercontroller: `return UserUpdateResponse`
11. adminusercontroller --> edituserdialogui: `200 OK (UserUpdateResponse)`
12. edituserdialogui --> admin: `Display success notification`
13. adminuserprovisionin --> adminusercontroller: `404 Not Found (UserNotFoundException)`
14. adminusercontroller --> edituserdialogui: `404 Not Found (ErrorResponse)`
15. edituserdialogui --> admin: `Show error notification`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
