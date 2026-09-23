# Sequence Flow — View User Profile

> Bổ sung cho `spec.md` (FR 3.3.1). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`UserController`, `UserServiceImpl`).

## Actors

- **User** — người dùng đang đăng nhập.
- **FE** — brandhub-web-dashboard (React), trang `/settings/profile`.
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`users`, `user_system_roles`, `workspace_members`).

---

## Flow A — Xem User Profile

1. User → FE: mở trang `/settings/profile`.
2. FE → BE: `GET /api/v1/users/me` (kèm access token trong header).
3. BE (`UserController.getProfile` → `UserServiceImpl.getUserProfile`):
   a. Lấy `currentUser.getId()` từ token đã xác thực (`@AuthenticationPrincipal`).
   b. BE → DB: `findById(userId)` trong bảng `users` — không có → `404 USER_NOT_FOUND` (trường hợp lý thuyết, token hợp lệ thì user luôn tồn tại).
4. BE → DB: `userSystemRoleRepository.findByUserId(userId)` lấy `role` hệ thống (mặc định `USER` nếu chưa có bản ghi).
5. BE → DB: nếu token không có sẵn `workspaceId`, fallback `workspaceMemberRepository.findFirstByUserIdAndIsActiveTrue(userId)` lấy 1 workspace đang active.
6. BE: parse `user.preferences` (JSON) lấy `timezone` + `notificationPreferences`.
7. BE → FE: `200 { id, email, fullName, avatarUrl, phone, role, workspaceId, timezone, notificationPreferences, createdAt }`.
8. FE: render các field lên trang view (không cho sửa trực tiếp — nút Edit chuyển sang FR 3.3.2).
   - `avatarUrl=null` → FE hiển thị avatar mặc định (initials).

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Xem profile | Token hết hạn/không hợp lệ (chặn ở filter, trước khi vào controller) | 401 | `UNAUTHORIZED` |
| Xem profile | User không tồn tại trong DB (lý thuyết, token hợp lệ nhưng bị xoá) | 404 | `USER_NOT_FOUND` |
