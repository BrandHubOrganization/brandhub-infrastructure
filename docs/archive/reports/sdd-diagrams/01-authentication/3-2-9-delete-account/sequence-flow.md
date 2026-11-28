# Sequence Flow — Delete Account

> Supplements `spec.md` (FR 3.2.9). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Guest** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `DangerZoneModal (UI)`.
- **System** — `AuthController` / `AuthService`.

---

## Flow A — Luồng thực thi chính: Delete Account

1. guest -> dangerzonemodalui: `enters password/OTP & clicks "Confirm Deactivation"`
2. authcontroller -> authcontroller: `clearCookie("refreshToken", path="/api/v1/auth")`
3. dangerzonemodalui -> dangerzonemodalui: `clearClientSession()`
4. dangerzonemodalui -> authcontroller: `POST /api/v1/auth/deactivate (DeactivateRequest(password, otpCode), headers: Bearer token, Cookie: refreshToken)`
5. authcontroller -> authservice: `deactivate(password, otpCode, accessToken, refreshToken)`
6. authservice -> userrepository: `findById(userId)`
7. userrepository --> authservice: `user`
8. authservice --> authcontroller: `throw BusinessException (400 Bad Request)`
9. authcontroller --> dangerzonemodalui: `400 Bad Request (WRONG_CURRENT_PASSWORD / OTP_INVALID)`
10. dangerzonemodalui --> guest: `show error toast ('Verification failed: invalid credentials or OTP')`
11. authservice ->> agencyrepository: `findByOwnerId(userId)`
12. agencyrepository --> authservice: `agencies`
13. authservice --> authcontroller: `throw AGENCY_OWNERSHIP_ACTIVE (409)`
14. authcontroller --> dangerzonemodalui: `409 Conflict (AGENCY_OWNERSHIP_ACTIVE)`
15. dangerzonemodalui --> guest: `show error modal ('Cannot deactivate: transfer active agency ownership first')`
16. authservice ->> userrepository: `updateStatus(userId, DEACTIVATED)`
17. userrepository --> authservice: `updatedUser`
18. authservice ->> rediscache: `blacklistTokens(accessToken, refreshToken)`
19. rediscache --> authservice: `ok`
20. authservice --> authcontroller: `void`
21. authcontroller --> dangerzonemodalui: `200 OK`
22. dangerzonemodalui --> guest: `redirectToLoginPage ('Account deactivated successfully')`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
