# UC — View User Profile

| | |
|---|---|
| FR Code | 3.3.1 |
| Feature | View User Profile |
| Domain | Profile (FR 3.3) |
| Role | USER |
| Version | 2.1 (sync với code thật, 2026-09-23) |
| Trạng thái tài liệu | Đã code — spec khớp `UserController`/`UserServiceImpl` |

## 1. Objective

Hiển thị thông tin cá nhân của User đang đăng nhập.

## 2. User Story

Là một User,
tôi muốn xem thông tin profile của mình,
để kiểm tra thông tin cá nhân đã lưu trên hệ thống.

## 3. Acceptance Criteria

- Hiển thị đầy đủ field: `userId`, `email`, `fullName`, `avatarUrl`, `phone` (nếu có), `role`, `workspaceId`, `timezone`, `notificationPreferences`, `createdAt` (ngày tham gia).
- `role` lấy từ `user_system_roles` (mặc định `USER` nếu chưa có bản ghi); `workspaceId` lấy từ token, fallback sang 1 workspace đang active của user nếu token không có sẵn.
- `timezone` và `notificationPreferences` được parse từ field JSON `preferences` lưu trên `users`.

## 4. UI / UX

- Trang `/settings/profile`, phần view (không cho sửa trực tiếp — chuyển sang FR 3.3.2 Update Profile khi bấm Edit).

## 5. API Contract

```
GET /api/v1/users/me
Authorization: Bearer <access-token>
→ 200 { "success": true, "data": {
    "userId", "email", "fullName", "avatarUrl", "phone",
    "role", "workspaceId", "timezone", "notificationPreferences", "createdAt"
  } }
```

## 6. Error Handling

- Token hết hạn/không hợp lệ → 401 `UNAUTHORIZED`.
- User không tồn tại trong DB (lý thuyết, token hợp lệ nhưng bị xoá) → 404 `USER_NOT_FOUND`.

## 7. Edge Cases

- User chưa từng cập nhật avatar → trả `avatarUrl=null`, FE hiển thị avatar mặc định (initials).

## 8. Definition of Done

- Hiển thị đúng toàn bộ field ở mục 3, khớp response thật của `GET /api/v1/users/me`.

## Out of Scope

- Không có (field đã chốt đầy đủ theo code hiện tại).

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)
