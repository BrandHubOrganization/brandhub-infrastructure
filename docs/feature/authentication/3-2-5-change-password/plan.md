# Plan — Change Password

> [spec.md](./spec.md) — Đổi mật khẩu khi đã đăng nhập, xác nhận currentPassword.

## Kỹ thuật

- `POST /api/v1/auth/change-password` (Bearer token) `{ currentPassword, newPassword }`.
- `AuthServiceImpl.changePassword()`: resolve userId từ access token → verify `currentPassword` (bcrypt) → sai → 400 `INVALID_CURRENT_PASSWORD` → hash `newPassword` → lưu.
- **Không** tự logout (khác Reset Password — user đã chứng minh danh tính).
- Spec đề xuất `PATCH`; code dùng `POST` (đồng bộ pattern controller hiện tại).

## Luồng

1. Auth (Bearer) → userId.
2. Verify currentPassword → sai → 400.
3. Set newPassword → 200.

## Data Model

- `users.passwordHash`.

## Rủi ro

- `newPassword == currentPassword` → spec nêu `SAME_AS_CURRENT_PASSWORD`; verify khi implement (nếu chưa có, thêm guard).
