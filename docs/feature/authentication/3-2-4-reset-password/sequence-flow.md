# Sequence Flow — Reset Password

> Bổ sung cho `spec.md` (FR 3.2.4). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`AuthController`, `AuthServiceImpl.forgotPassword/resetPassword`), bao gồm cơ chế reverse-index mới để tự động invalidate token reset cũ.

## Actors

- **User** — quên mật khẩu.
- **FE** — brandhub-web-dashboard.
- **BE** — brandhub-business-service.
- **DB** — Redis (`pwd:reset:{token}` → userId; `pwd:reset:user:{userId}` → token hiện hành, TTL = `appProperties.passwordResetTtlSeconds`), PostgreSQL (`users`).
- **Mail** — SMTP, gửi link reset.

---

## Flow A — Quên mật khẩu → nhận link → đặt lại thành công

1. User → FE: mở `/forgot-password`, nhập `email`.
2. FE → BE: `POST /api/v1/auth/forgot-password {email}`.
3. BE (`forgotPassword`):
   a. Tìm `User` theo email chuẩn hóa (lowercase+trim) — **không tìm thấy → return ngay, vẫn coi như thành công** (không tiết lộ email tồn tại hay không).
   b. Có user → `GET pwd:reset:user:{userId}` từ Redis lấy `oldToken` (nếu có).
   c. Nếu có `oldToken` → `DELETE pwd:reset:{oldToken}` (vô hiệu hoá token reset cũ ngay lập tức).
   d. Sinh `token` mới random 32 byte hex (64 ký tự hex, `SecureRandom`).
   e. `SET pwd:reset:{token} = userId` vào Redis, TTL = `passwordResetTtlSeconds`.
   f. `SET pwd:reset:user:{userId} = token` vào Redis, cùng TTL (reverse-index, ghi đè giá trị cũ).
   g. Gửi mail chứa link reset kèm token.
4. BE → FE: `200 { success: true, data: null }` — **luôn 200 dù email có tồn tại hay không**.
5. FE: hiện thông báo "nếu email tồn tại, bạn sẽ nhận được link" (generic message, không xác nhận email có hay không).
6. User → click link email → FE mở `/reset-password?token=X`.
7. User: nhập `newPassword`, `confirmPassword` (validate confirm khớp ở FE).
8. FE → BE: `POST /api/v1/auth/reset-password {token, newPassword}`.
9. BE (`resetPassword`):
   a. `GET pwd:reset:{token}` từ Redis — không có → `400 RESET_TOKEN_INVALID`.
   b. `DELETE pwd:reset:{token}` (atomic, tránh dùng lại) — nếu `delete` trả về false (race condition, token vừa bị xóa bởi request khác) → `400 RESET_TOKEN_USED`.
   c. Tìm `User` theo userId lấy từ token — không có (data lỗi) → `400 RESET_TOKEN_INVALID`.
   d. `DELETE pwd:reset:user:{userId}` (dọn dẹp reverse-index — token đã dùng xong).
   e. `UPDATE users SET passwordHash=bcrypt(newPassword), lastPasswordChange=now`.
   f. `INSERT audit_logs (PASSWORD_RESET)`.
10. BE → FE: `200 { success: true, data: null }`.
11. FE: toast thành công, điều hướng `/login`.
    - **Hệ quả ngầm định**: mọi `refreshToken` cũ phát hành trước `lastPasswordChange` bị vô hiệu — không phải do revoke thủ công từng token, mà vì `AuthServiceImpl.refresh` so sánh `claims.getIssuedAt()` với `user.getLastPasswordChange()`, token cũ hơn → `401 REFRESH_TOKEN_INVALID` khi user cố dùng lại.

## Flow B — Request forgot-password nhiều lần liên tiếp (token cũ tự invalidate)

1. User → FE → BE: `POST /forgot-password {email}` (lần 1) → BE sinh `token1`, lưu `pwd:reset:token1=userId` + `pwd:reset:user:{userId}=token1` (TTL). → `200`.
2. User → FE → BE: `POST /forgot-password {email}` (lần 2, cùng email, trước khi dùng `token1`):
   a. BE đọc `pwd:reset:user:{userId}` → thấy `token1` → `DELETE pwd:reset:token1` ngay.
   b. Sinh `token2`, lưu `pwd:reset:token2=userId` + `pwd:reset:user:{userId}=token2` (ghi đè). → `200`.
3. User dùng `token1` (từ email đầu, đã bị vô hiệu) để reset → `GET pwd:reset:token1` → không có (đã bị xoá ở bước 2a) → `400 RESET_TOKEN_INVALID` (ngay cả khi TTL gốc của `token1` chưa hết).
4. User dùng `token2` (mới nhất) để reset → hợp lệ → theo Flow A bước 9 → `200`, reset thành công.

---

## Error paths tổng hợp (dùng cho sequence "alt"/"opt" fragments)

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Forgot password | Email không tồn tại | 200 | — (im lặng, không lỗi) |
| Reset password | Token không tồn tại/hết hạn/đã bị invalidate bởi request forgot-password mới hơn | 400 | `RESET_TOKEN_INVALID` |
| Reset password | Token vừa bị dùng/xóa (race condition, 2 request reset cùng lúc) | 400 | `RESET_TOKEN_USED` |
| Reset password | userId lấy từ token không map ra User (data lỗi) | 400 | `RESET_TOKEN_INVALID` |
| Reset password | `newPassword` không đủ mạnh | 400 | `VALIDATION_ERROR` |
