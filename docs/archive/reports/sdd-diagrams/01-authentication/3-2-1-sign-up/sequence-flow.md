# Sequence Flow — Sign Up

> Supplements `spec.md` (FR 3.2.1). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **User** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `RegisterPage (UI)`.
- **System** — `AuthController` / `AuthService`.

---

## Flow A — Luồng thực thi chính: Sign Up

1. user -> registerpageui: `fills in full name, email & password, clicks "Create Account"`
2. registerpageui -> authcontroller: `POST /api/v1/auth/register (RegisterRequest)`
3. authcontroller -> authservice: `register(request)`
4. authservice -> userrepository: `existsByEmail(email)`
5. userrepository --> authservice: `true`
6. authservice --> authcontroller: `409 Conflict (EMAIL_ALREADY_IN_USE)`
7. authcontroller --> registerpageui: `409 Conflict (EMAIL_ALREADY_IN_USE)`
8. registerpageui --> user: `Show error "Email already in use"`
9. userrepository --> authservice: `false`
10. authservice -> userrepository: `save(newUser)`
11. userrepository --> authservice: `savedUser`
12. authservice -> mailservice: `sendVerificationEmail(email, verifyToken)`
13. mailservice --> authservice: `ok`
14. authservice --> authcontroller: `RegisterResponse(userId, email)`
15. authcontroller --> registerpageui: `201 Created (RegisterResponse)`
16. registerpageui --> user: `"Account created — check your email to verify"`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
