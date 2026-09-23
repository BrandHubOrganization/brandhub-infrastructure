# Sequence Flow — Change Password

> Bổ sung cho `spec.md` (FR 3.2.5). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`AuthController.changePassword`, `AuthServiceImpl.changePassword`).

## Actors

- **User** — đã đăng nhập.
- **FE** — brandhub-web-dashboard (`/settings/change-password`).
- **BE** — brandhub-business-service.
- **DB** — PostgreSQL (`users`, `audit_logs`).

---

## Flow A — Đổi mật khẩu thành công

1. User → FE: mở `/settings/change-password`, nhập `currentPassword`, `newPassword`, `confirmNewPassword` — FE validate confirm khớp trước khi cho submit, có bước confirm lại (modal/step riêng theo spec mục 3).
2. FE → BE: `POST /api/v1/auth/change-password` (Header `Authorization: Bearer {accessToken}`) `{currentPassword, newPassword}`.
3. BE (`AuthController.changePassword`): check `authHeader` có `Bearer ` prefix — thiếu/sai → `401 INVALID_CREDENTIALS` ngay tại controller (không vào service).
4. BE (`AuthServiceImpl.changePassword`):
   a. Parse `userId` từ JWT access token.
   b. Tìm `User` — không có (token hợp lệ nhưng user đã bị xóa/data lỗi) → `404 USER_NOT_FOUND`.
   c. So khớp `currentPassword` với `passwordHash` hiện tại (bcrypt) — sai → `400 WRONG_CURRENT_PASSWORD`.
   d. So khớp `newPassword` với `passwordHash` hiện tại (bcrypt matches) — trùng → `400 SAME_AS_CURRENT_PASSWORD`. Check này chạy **sau** bước (c), chỉ tới đây khi `currentPassword` đã đúng.
   e. `UPDATE users SET passwordHash=bcrypt(newPassword), lastPasswordChange=now`.
   f. `INSERT audit_logs (PASSWORD_RESET)` — dùng chung action `PASSWORD_RESET` với Reset Password (FR 3.2.4), không có action riêng `PASSWORD_CHANGE`.
5. BE → FE: `200 { success: true, data: null }`.
6. FE: toast xác nhận thành công. **Không tự động logout** session hiện tại — access token còn hạn tiếp tục dùng bình thường, khác Reset Password. Lưu ý: `lastPasswordChange` vừa cập nhật làm mọi **refresh token cũ** (issued trước thời điểm đổi) bị coi là invalid ở lần refresh tiếp theo (so `claims.issuedAt < user.lastPasswordChange` → `401 REFRESH_TOKEN_INVALID`).

---

## Error paths tổng hợp (dùng cho sequence "alt"/"opt" fragments)

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Change password | Thiếu/sai header `Authorization` | 401 | `INVALID_CREDENTIALS` |
| Change password | User không tồn tại (token hợp lệ, data lỗi) | 404 | `USER_NOT_FOUND` |
| Change password | `currentPassword` sai | 400 | `WRONG_CURRENT_PASSWORD` |
| Change password | `newPassword` == `currentPassword` (chỉ check khi currentPassword đã đúng) | 400 | `SAME_AS_CURRENT_PASSWORD` |
| Change password | `newPassword` không đủ mạnh | 400 | `VALIDATION_ERROR` |
