# Sequence Flow — Change Password

> Supplements `spec.md` (FR 3.2.5). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Guest** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `SecuritySettingsPage (UI)`.
- **System** — `AuthController` / `AuthService`.

---

## Flow A — Luồng thực thi chính: Change Password

1. authservice -> authservice: `parseToken(accessToken) -> userId`
2. authservice -> authservice: `verifyPassword(request.currentPassword(), user.getPasswordHash())`
3. authservice -> authservice: `checkSamePassword(request.newPassword(), user.getPasswordHash())`
4. authservice -> authservice: `encodePassword(request.newPassword())`
5. authservice -> authservice: `updatePassword(user, newPasswordHash)`
6. authservice -> authservice: `recordAuditLog(userId, PASSWORD_RESET)`
7. guest -> securitysettingspage: `enters current password, new password & clicks "Update password"`
8. securitysettingspage -> authcontroller: `POST /api/v1/auth/change-password (ChangePasswordRequest, headers: Bearer accessToken)`
9. authcontroller --> securitysettingspage: `401 Unauthorized (INVALID_CREDENTIALS)`
10. securitysettingspage --> guest: `show error toast ('Authentication session invalid, please sign in again')`
11. authcontroller ->> authservice: `changePassword(accessToken, request)`
12. authservice ->> userrepository: `findById(userId)`
13. userrepository --> authservice: `Optional.empty()`
14. authservice --> authcontroller: `throw BusinessException(USER_NOT_FOUND)`
15. authcontroller --> securitysettingspage: `404 Not Found (USER_NOT_FOUND)`
16. securitysettingspage --> guest: `show error toast ('User account not found')`
17. userrepository --> authservice: `user`
18. authservice --> authcontroller: `throw BusinessException(WRONG_CURRENT_PASSWORD)`
19. authcontroller --> securitysettingspage: `400 Bad Request (WRONG_CURRENT_PASSWORD)`
20. securitysettingspage --> guest: `show error inline MSG19 ('Current password is incorrect.')`
21. authservice --> authcontroller: `throw BusinessException(SAME_AS_CURRENT_PASSWORD)`
22. authcontroller --> securitysettingspage: `400 Bad Request (SAME_AS_CURRENT_PASSWORD)`
23. securitysettingspage --> guest: `show error inline MSG90 ('New password cannot be the same as your current password.')`
24. authservice ->> userrepository: `save(user)`
25. userrepository --> authservice: `savedUser`
26. authservice --> authcontroller: `void`
27. authcontroller --> securitysettingspage: `200 OK (ApiResponse)`
28. securitysettingspage --> guest: `show success toast MSG18 ('Password updated successfully.') & clear form fields`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
