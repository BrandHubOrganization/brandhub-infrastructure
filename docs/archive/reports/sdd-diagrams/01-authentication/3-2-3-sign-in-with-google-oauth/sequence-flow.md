# Sequence Flow — Sign In with Google OAuth

> Supplements `spec.md` (FR 3.2.3). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **User** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `LoginPage (UI)`.
- **System** — `AuthController` / `AuthService`.

---

## Flow A — Luồng thực thi chính: Sign In with Google OAuth

1. user -> loginpageui: `clicks "Sign In with Google"`
2. loginpageui -> authcontroller: `GET /api/v1/auth/oauth2/google`
3. authcontroller --> loginpageui: `redirect to Google OAuth consent URL`
4. loginpageui --> user: `Google login screen`
5. user -> googleoauthservice: `grants permission`
6. googleoauthservice --> loginpageui: `callback with authCode`
7. loginpageui -> authcontroller: `GET /api/v1/auth/oauth2/callback?code=authCode`
8. authcontroller -> authservice: `loginWithGoogle(authCode)`
9. authservice -> googleoauthservice: `exchangeCode(authCode)`
10. googleoauthservice --> authservice: `GoogleUserInfo(email, name, googleId)`
11. authservice -> userrepository: `findByEmail(email)`
12. userrepository --> authservice: `Optional.empty()`
13. authservice -> userrepository: `save(newUserFromGoogle)`
14. userrepository --> authservice: `savedUser`
15. userrepository --> authservice: `Optional<User>`
16. authservice --> authcontroller: `LoginResponse(accessToken, refreshToken)`
17. authcontroller --> loginpageui: `200 OK (LoginResponse)`
18. loginpageui --> user: `redirect to Dashboard`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
