# Sequence Flow — Deactivate Account

> Bổ sung cho `spec.md` (FR 3.2.9). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật — thêm route `POST /deactivate/send-otp` và nhánh OTP trong `AuthServiceImpl.deactivate`.

## Actors

- **User** — muốn tự vô hiệu hóa tài khoản.
- **FE** — brandhub-web-dashboard (`pages/profile/index.tsx`, Danger Zone section).
- **BE** — brandhub-business-service (`AuthController`, `AuthServiceImpl`).
- **Redis** — lưu OTP tạm thời (Flow B).
- **DB** — PostgreSQL (`users`, `agencies`).
- **MailService** — gửi email OTP (Flow B).

---

## Flow A — User có password (`passwordHash != null`)

1. User → FE: `/profile`, cuộn tới Danger Zone, bấm "Deactivate", nhập lại `password` trong dialog confirm.
2. FE → BE: `POST /api/v1/auth/deactivate {password}` (Bearer token).
3. BE (`AuthController.deactivate` → `AuthServiceImpl.deactivate`):
   a. Parse `userId` từ token qua `requireUserId(authHeader)` — thiếu/sai token → `401 INVALID_CREDENTIALS`.
   b. Tìm `User` theo `userId` — không có → `404 USER_NOT_FOUND`.
   c. `user.getPasswordHash() != null` → nhánh Flow A: so khớp `password` với `passwordHash` (bcrypt) — sai → `400 WRONG_CURRENT_PASSWORD`.
   d. Đúng → `agencyRepository.findByOwnerId(userId)` → lọc `status=ACTIVE` → **không có** Agency active nào do user sở hữu.
   e. BE → DB: `UPDATE users SET status=DEACTIVATED` — soft delete, không xóa record.
4. BE → FE: `200 { success: true, data: null }`.
5. FE (`handleDeactivate`): thành công → `useAuthStore.getState().logout()` (clear local auth state) → `navigate("/login")`.
6. User cố login lại → `AuthServiceImpl.login` → `checkStatus`: `status=DEACTIVATED` → `403 ACCOUNT_DEACTIVATED` (xem FR 3.2.2).

### Flow A' — Bị chặn vì sở hữu Agency active

Giống bước 1–3c, khác từ 3d:

3d'. `agencyRepository.findByOwnerId(userId)` → có **ít nhất 1** Agency `status=ACTIVE` do user sở hữu → `409 AGENCY_OWNERSHIP_ACTIVE`, **không** update `User.status`.
4'. BE → FE: `409 { success: false, error: {code: "AGENCY_OWNERSHIP_ACTIVE", ...} }`.
5'. FE: hiện lỗi, hướng dẫn user transfer ownership Agency trước khi deactivate được.

---

## Flow B — User OAuth-only (`passwordHash == null`) — MỚI

### B.1 — Gửi OTP

1. User → FE: `/profile`, Danger Zone, bấm "Deactivate" → FE phát hiện tài khoản không có password → hiện bước "Gửi mã xác nhận".
2. User → FE: bấm "Gửi mã OTP".
3. FE → BE: `POST /api/v1/auth/deactivate/send-otp` (Bearer token, không body).
4. BE (`AuthController.sendDeactivateOtp` → `AuthServiceImpl.sendDeactivateOtp`):
   a. Parse `userId` từ token — thiếu/sai token → `401 INVALID_CREDENTIALS`.
   b. Tìm `User` theo `userId` — không có → `404 USER_NOT_FOUND`.
   c. Sinh `otp` ngẫu nhiên 6 số (100000–999999).
   d. BE → Redis: `SET otp:deactivate:{userId} = otp, TTL=10 phút`.
   e. BE → MailService: `sendOtpEmail(user.email, otp)`.
5. BE → FE: `200 { success: true, data: null }`.
6. FE: hiện thông báo "Đã gửi mã xác nhận tới email", chuyển sang ô nhập OTP.
7. User → nhận email từ MailService, đọc OTP.

### B.2 — Xác nhận deactivate bằng OTP

8. User → FE: nhập `otpCode` vừa nhận, bấm confirm.
9. FE → BE: `POST /api/v1/auth/deactivate {otpCode}` (Bearer token).
10. BE (`AuthServiceImpl.deactivate`):
    a. Parse `userId` từ token — thiếu/sai → `401 INVALID_CREDENTIALS`.
    b. Tìm `User` — không có → `404 USER_NOT_FOUND`.
    c. `user.getPasswordHash() == null` → nhánh Flow B: BE → Redis: `GET otp:deactivate:{userId}`.
    d. Key không tồn tại, hoặc `otpCode` null, hoặc không khớp → `400 OTP_INVALID`.
    e. Khớp → BE → Redis: `DEL otp:deactivate:{userId}` (dùng 1 lần).
    f. BE → DB: `agencyRepository.findByOwnerId(userId)` → lọc `status=ACTIVE` → **không có** Agency active nào do user sở hữu.
    g. BE → DB: `UPDATE users SET status=DEACTIVATED`.
11. BE → FE: `200 { success: true, data: null }`.
12. FE: `useAuthStore.getState().logout()` → `navigate("/login")`.
13. User cố login lại → `checkStatus`: `status=DEACTIVATED` → `403 ACCOUNT_DEACTIVATED`.

### Flow B' — Bị chặn vì sở hữu Agency active (sau khi OTP đã khớp)

Giống bước 8–10e, khác từ 10f:

10f'. `agencyRepository.findByOwnerId(userId)` → có **ít nhất 1** Agency `status=ACTIVE` → `409 AGENCY_OWNERSHIP_ACTIVE`, **không** update `User.status`. Lưu ý: OTP đã bị xóa ở bước 10e trước khi check này — user cần gọi lại `send-otp` nếu muốn thử lại sau khi transfer ownership.
11'. BE → FE: `409 { success: false, error: {code: "AGENCY_OWNERSHIP_ACTIVE", ...} }`.

### Flow B'' — OTP sai / thiếu / hết hạn / chưa gọi send-otp

10d'. Redis không có key (chưa gọi `send-otp`, hoặc TTL 10 phút đã qua), hoặc `otpCode` gửi lên không khớp, hoặc `otpCode` null → `400 OTP_INVALID`.
11''. BE → FE: `400 { success: false, error: {code: "OTP_INVALID", ...} }`.

---

## Error paths tổng hợp (dùng cho sequence "alt"/"opt" fragments)

| Route | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| `/deactivate`, `/deactivate/send-otp` | Thiếu/sai Bearer token | 401 | `INVALID_CREDENTIALS` |
| `/deactivate`, `/deactivate/send-otp` | User không tồn tại (token hợp lệ, data lỗi) | 404 | `USER_NOT_FOUND` |
| `/deactivate` (Flow A, `passwordHash != null`) | Password sai | 400 | `WRONG_CURRENT_PASSWORD` |
| `/deactivate` (Flow B, `passwordHash == null`) | OTP sai / thiếu / hết hạn / chưa gọi send-otp | 400 | `OTP_INVALID` |
| `/deactivate` | Sở hữu ≥1 Agency đang `ACTIVE` (cả 2 flow) | 409 | `AGENCY_OWNERSHIP_ACTIVE` |

## Ghi chú khác biệt so với spec.md gốc

- **Đã bổ sung toàn bộ Flow B (OTP-based) — trước đây spec.md/sequence-flow.md chỉ có Flow A (password bắt buộc), route `/deactivate/send-otp` chưa tồn tại.**
- Route `/deactivate` giờ phân nhánh theo `user.passwordHash` thay vì luôn yêu cầu `password`.
- **Xóa ghi chú gap cũ**: bản trước ghi "user OAuth-only hiện tại không có cách nào tự deactivate qua flow này trừ khi trước đó đã set password" — điều này **không còn đúng**: user OAuth-only giờ dùng Flow B (OTP qua email) để deactivate, không cần set password trước.
