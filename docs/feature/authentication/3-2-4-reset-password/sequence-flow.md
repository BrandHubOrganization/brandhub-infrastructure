# Sequence Flow — Reset Password

> Supplements `spec.md` (FR 3.2.4). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **User** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `ForgotPasswordPage (UI)`.
- **System** — `AuthController` / `AuthService`.

---

## Flow A — Luồng thực thi chính: Reset Password

1. user -> forgotpasswordpageui: `enters email, clicks "Send Reset Link"`
2. forgotpasswordpageui -> authcontroller: `POST /api/v1/auth/forgot-password (email)`
3. authcontroller -> authservice: `forgotPassword(email)`
4. authservice -> userrepository: `findByEmail(email)`
5. userrepository --> authservice: `Optional.empty()`
6. authservice --> authcontroller: `200 OK (generic — no email leak)`
7. authcontroller --> forgotpasswordpageui: `200 OK`
8. forgotpasswordpageui --> user: `"If this email exists, a reset link was sent"`
9. userrepository --> authservice: `Optional<User>`
10. authservice -> rediscache: `set("pwd:reset:" + token, userId, 15 min)`
11. rediscache --> authservice: `ok`
12. authservice -> mailservice: `sendResetPasswordEmail(email, resetLink)`
13. mailservice --> authservice: `ok`
14. authservice --> authcontroller: `200 OK`
15. authcontroller --> forgotpasswordpageui: `200 OK`
16. forgotpasswordpageui --> user: `"Check your email for the reset link"`
17. user -> forgotpasswordpageui: `opens reset link, enters new password, clicks "Reset Password"`
18. forgotpasswordpageui -> authcontroller: `POST /api/v1/auth/reset-password (ResetPasswordRequest)`
19. authcontroller -> authservice: `resetPassword(token, newPassword)`
20. authservice -> rediscache: `get("pwd:reset:" + token)`
21. rediscache --> authservice: `null`
22. authservice --> authcontroller: `400 Bad Request (RESET_TOKEN_INVALID)`
23. authcontroller --> forgotpasswordpageui: `400 Bad Request`
24. forgotpasswordpageui --> user: `Show error "Reset link is invalid or expired"`
25. rediscache --> authservice: `userId`
26. authservice -> userrepository: `save(user with encodedNewPassword)`
27. userrepository --> authservice: `ok`
28. authservice -> rediscache: `delete("pwd:reset:" + token)`
29. rediscache --> authservice: `ok`
30. authservice --> authcontroller: `200 OK`
31. authcontroller --> forgotpasswordpageui: `200 OK`
32. forgotpasswordpageui --> user: `"Password reset successfully — please sign in"`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
