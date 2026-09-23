# Plan — Change Password

> [spec.md](./spec.md) — Đổi mật khẩu khi đã đăng nhập, xác nhận currentPassword.

## Kỹ thuật

- `POST /api/v1/auth/change-password` (Bearer token) `{ currentPassword, newPassword }`.
- `AuthServiceImpl.changePassword()`: resolve userId từ access token → verify `currentPassword` (bcrypt) → sai → 400 `WRONG_CURRENT_PASSWORD` → nếu `newPassword` trùng `currentPassword` (bcrypt matches) → 400 `SAME_AS_CURRENT_PASSWORD` → hash `newPassword` → lưu + set `lastPasswordChange=now` + audit log `PASSWORD_RESET`.
- **Không** tự logout session hiện tại (access token vẫn dùng được) — khác Reset Password. Nhưng `lastPasswordChange` cập nhật làm refresh token cũ (issued trước đó) bị invalid ở lần refresh tiếp theo.
- Spec đề xuất `PATCH`; code dùng `POST` (đồng bộ pattern controller hiện tại).

## Luồng

1. Auth (Bearer) → userId. Thiếu/sai header → 401.
2. Verify currentPassword → sai → 400 `WRONG_CURRENT_PASSWORD`.
3. So newPassword với currentPassword → trùng → 400 `SAME_AS_CURRENT_PASSWORD`.
4. Set newPassword, lastPasswordChange=now, audit log → 200.

## Data Model

- `users.passwordHash`, `users.lastPasswordChange`.

## Rủi ro

- Đã fix: `newPassword == currentPassword` → `SAME_AS_CURRENT_PASSWORD` (400), check sau khi verify currentPassword đúng. Không còn là gap.
