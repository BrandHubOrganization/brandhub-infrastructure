# Sequence Flow — Update Profile

> Bổ sung cho `spec.md` (FR 3.3.2). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`UserController`, `UserServiceImpl`, `FileStorageService`).

## Actors

- **User** — người dùng đang đăng nhập.
- **FE** — brandhub-web-dashboard (React), trang `/settings/profile`.
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (bảng `users`).
- **S3** — file storage cho avatar (`FileStorageService`).

---

## Flow A — Cập nhật thông tin text (fullName, phone, timezone, notificationPreferences)

1. User → FE: sửa form trên `/settings/profile` (`fullName`, `phone`, tuỳ chọn `timezone`, `notificationPreferences`), bấm Save.
2. FE → BE: `PUT /api/v1/users/me` `{fullName, phone?, timezone?, notificationPreferences?}`.
   - Request DTO (`UpdateProfileRequest`) **không có field `email` hay `avatarUrl`** — về mặt cấu trúc không thể gửi 2 field này qua endpoint này (không phải BE âm thầm ignore, mà form/DTO không có chỗ để chứa).
   - `fullName` trống/blank → validation `@NotBlank` chặn ngay ở tầng controller → `400 VALIDATION_ERROR`.
3. BE (`UserController.updateProfile` → `UserServiceImpl.updateUserProfile`):
   a. BE → DB: `findById(userId)` — không có → `404 USER_NOT_FOUND` (lý thuyết).
   b. Set `user.fullName = fullName.trim()`.
   c. Nếu `phone != null` → set `user.phone = phone.trim()`.
   d. Parse `user.preferences` (JSON hiện tại) → merge thêm `timezone` (nếu gửi) và `notificationPreferences` (nếu gửi) → serialize lại JSON, lưu vào `user.preferences`.
      - Lỗi serialize JSON (hiếm) → `400 INVALID_REQUEST`.
4. BE → DB: `save(user)`.
5. BE → FE: `200 { id, email, fullName, avatarUrl, phone, role, workspaceId, timezone, notificationPreferences, createdAt }` (cùng shape với GET /me).
6. FE: toast thành công, cập nhật UI ngay từ response, không reload.

## Flow B — Upload avatar

Endpoint riêng, độc lập với Flow A (không nằm chung `PUT /me`).

1. User → FE: mở `AvatarUploadModal`, chọn file ảnh.
2. FE → BE: `POST /api/v1/users/me/avatar` multipart `file`.
3. BE (`UserController.uploadAvatar` → `UserServiceImpl.updateAvatar`):
   a. `file` null/rỗng → `400 NO_FILE_PROVIDED`.
   b. `contentType` không bắt đầu bằng `image/` → `400 INVALID_FILE_TYPE`.
   c. `file.size > 5MB` → `400 FILE_TOO_LARGE`.
   d. BE → DB: `findById(userId)` — không có → `404 USER_NOT_FOUND` (lý thuyết).
   e. Đọc bytes file — lỗi IO → `400 UPLOAD_FAILED`.
   f. BE → S3: `uploadAvatar(userId, bytes, contentType)` → nhận `newAvatarUrl`.
   g. Nếu user đã có `avatarUrl` cũ → BE → S3: `deleteFile(oldAvatarUrl)` (dọn file cũ).
   h. Set `user.avatarUrl = newAvatarUrl` → BE → DB: `save(user)`.
4. BE → FE: `200 { avatarUrl: newAvatarUrl }`.
5. FE: gắn `avatarUrl` mới vào state/preview, không còn dùng local preview URL tạm.

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Update (Flow A) | `fullName` trống | 400 | `VALIDATION_ERROR` |
| Update (Flow A) | Lỗi serialize preferences JSON (hiếm) | 400 | `INVALID_REQUEST` |
| Update (Flow A/B) | User không tồn tại (lý thuyết) | 404 | `USER_NOT_FOUND` |
| Upload avatar (Flow B) | Không có file | 400 | `NO_FILE_PROVIDED` |
| Upload avatar (Flow B) | File không phải ảnh | 400 | `INVALID_FILE_TYPE` |
| Upload avatar (Flow B) | File > 5MB | 400 | `FILE_TOO_LARGE` |
| Upload avatar (Flow B) | Lỗi đọc file (IO) | 400 | `UPLOAD_FAILED` |
