# Sequence Flow — Two-Factor Authentication (2FA, TOTP)

> Supplements `spec.md` (FR 3.2.7). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **User** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `SecuritySettingsPage (UI)`.
- **System** — `AuthController` / `AuthService`.

---

## Flow A — Luồng thực thi chính: Two-Factor Authentication (2FA, TOTP)

1. user -> securitysettingspage: `clicks "Enable 2FA"`
2. securitysettingspage -> authcontroller: `POST /api/v1/auth/2fa/setup (headers: Bearer accessToken)`
3. authcontroller -> authservice: `setup2FA(userId)`
4. authservice -> authenticatorapp: `generateSecret() -> otpAuthUrl`
5. authenticatorapp --> authservice: `otpAuthUrl (QR code URL)`
6. authservice -> rediscache: `set("2fa:pending:" + userId, secret, 10 min)`
7. rediscache --> authservice: `ok`
8. authservice --> authcontroller: `200 OK (otpAuthUrl)`
9. authcontroller --> securitysettingspage: `200 OK (otpAuthUrl)`
10. securitysettingspage --> user: `Display QR code to scan in Authenticator App`
11. user -> securitysettingspage: `scans QR, enters TOTP code, clicks "Confirm"`
12. securitysettingspage -> authcontroller: `POST /api/v1/auth/2fa/confirm (code, headers: Bearer accessToken)`
13. authcontroller -> authservice: `confirm2FA(userId, code)`
14. authservice -> rediscache: `get("2fa:pending:" + userId)`
15. rediscache --> authservice: `pendingSecret`
16. authservice --> authcontroller: `400 Bad Request (TWO_FA_CODE_INVALID)`
17. authcontroller --> securitysettingspage: `400 Bad Request`
18. securitysettingspage --> user: `Show error "Invalid TOTP code"`
19. authservice -> userrepository: `save(user with twoFaEnabled=true, twoFaSecret)`
20. userrepository --> authservice: `ok`
21. authservice -> rediscache: `delete("2fa:pending:" + userId)`
22. rediscache --> authservice: `ok`
23. authservice --> authcontroller: `200 OK`
24. authcontroller --> securitysettingspage: `200 OK`
25. securitysettingspage --> user: `"Two-factor authentication enabled"`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
