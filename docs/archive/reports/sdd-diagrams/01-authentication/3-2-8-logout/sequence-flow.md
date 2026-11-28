# Sequence Flow — Sign Out

> Supplements `spec.md` (FR 3.2.8). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Guest** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `AppHeader (UI)`.
- **System** — `AuthController` / `Auth Service`.

---

## Flow A — Luồng thực thi chính: Sign Out

1. guest -> appheaderui: `clicks "Sign Out"`
2. authservice -> authservice: `parseToken(accessToken)`
3. authservice -> authservice: `extract userId and jti`
4. authservice -> authservice: `blacklistToken(accessToken)`
5. authservice -> authservice: `blacklistToken(refreshToken)`
6. authcontroller -> authcontroller: `clearCookie("refreshToken", path="/api/v1/auth")`
7. appheaderui -> appheaderui: `clearClientSession()`
8. authcontroller -> authcontroller: `extract accessToken = authHeader.replace("Bearer ", "")`
9. appheaderui -> authcontroller: `POST /api/v1/auth/logout (headers: Authorization: Bearer <accessToken>, X-Forwarded-For, User-Agent; Cookie: refreshToken)`
10. authcontroller -> appheaderui: `401 Unauthorized (INVALID_CREDENTIALS)`
11. appheaderui -> guest: `redirect to /login ('Invalid session credentials')`
12. authcontroller -> authservice: `logout(accessToken, refreshToken, ipAddress, userAgent)`
13. authservice -> rediscache: `set("jwt:blacklist:" + jti, "true", ttl)`
14. rediscache -> authservice: `ok`
15. authservice -> rediscache: `set("jwt:blacklist:" + refreshJti, "true", ttl)`
16. rediscache -> authservice: `ok`
17. authservice --> authcontroller: `void`
18. authcontroller --> appheaderui: `200 OK (Sign out successful)`
19. appheaderui --> guest: `redirectToLoginPage("Signed out successfully")`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
