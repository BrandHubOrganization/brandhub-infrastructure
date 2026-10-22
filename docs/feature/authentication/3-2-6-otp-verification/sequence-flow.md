# Sequence Flow — OTP Verification

> Supplements `spec.md` (FR 3.2.6). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **User** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `ProfilePage (UI)`.
- **System** — `AuthController` / `AuthService`.

---

## Flow A — Luồng thực thi chính: OTP Verification

1. user -> profilepageui: `clicks "Verify Phone / Email via OTP"`
2. profilepageui -> authcontroller: `POST /api/v1/auth/otp/send (OtpRequest, headers: Bearer accessToken)`
3. authcontroller -> authservice: `sendOtp(userId, target)`
4. authservice -> userrepository: `findById(userId)`
5. userrepository --> authservice: `Optional<User>`
6. authservice -> rediscache: `set("otp:" + userId, otp, 5 min)`
7. rediscache --> authservice: `ok`
8. authservice -> mailservice: `sendOtpEmail(email, otp)`
9. mailservice --> authservice: `ok`
10. authservice --> authcontroller: `200 OK`
11. authcontroller --> profilepageui: `200 OK`
12. profilepageui --> user: `"OTP sent — enter it below"`
13. user -> profilepageui: `enters OTP, clicks "Verify"`
14. profilepageui -> authcontroller: `POST /api/v1/auth/otp/verify (OtpVerifyRequest, headers: Bearer accessToken)`
15. authcontroller -> authservice: `verifyOtp(userId, otp)`
16. authservice -> rediscache: `get("otp:" + userId)`
17. rediscache --> authservice: `null / mismatch`
18. authservice --> authcontroller: `400 Bad Request (OTP_INVALID)`
19. authcontroller --> profilepageui: `400 Bad Request`
20. profilepageui --> user: `Show error "Invalid or expired OTP"`
21. rediscache --> authservice: `storedOtp (match)`
22. authservice -> rediscache: `delete("otp:" + userId)`
23. rediscache --> authservice: `ok`
24. authservice -> userrepository: `save(user with verified flag)`
25. userrepository --> authservice: `ok`
26. authservice --> authcontroller: `200 OK`
27. authcontroller --> profilepageui: `200 OK`
28. profilepageui --> user: `"Verified successfully"`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
