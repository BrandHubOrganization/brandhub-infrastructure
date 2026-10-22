# Sequence Flow — Sign In With Email

> Supplements `spec.md` (FR 3.2.2). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **User** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `LoginPage (UI)`.
- **System** — `AuthController` / `AuthService`.

---

## Flow A — Luồng thực thi chính: Sign In With Email

1. user -> loginpageui: `enters email & password, clicks "Sign In"`
2. loginpageui -> authcontroller: `POST /api/v1/auth/login (LoginRequest)`
3. authcontroller -> authservice: `login(request)`
4. authservice -> userrepository: `findByEmail(email)`
5. userrepository --> authservice: `Optional.empty() / password mismatch`
6. authservice --> authcontroller: `401 Unauthorized (INVALID_CREDENTIALS)`
7. authcontroller --> loginpageui: `401 Unauthorized`
8. loginpageui --> user: `Show error "Invalid email or password"`
9. userrepository --> authservice: `Optional<User>`
10. authservice -> rediscache: `set("refresh:" + userId, refreshToken, TTL)`
11. rediscache --> authservice: `ok`
12. authservice --> authcontroller: `LoginResponse(accessToken, refreshToken)`
13. authcontroller --> loginpageui: `200 OK (LoginResponse)`
14. loginpageui --> user: `redirect to Dashboard`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
