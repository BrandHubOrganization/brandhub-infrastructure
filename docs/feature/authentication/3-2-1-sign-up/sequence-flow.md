# Sequence Flow — Sign Up

> Bổ sung cho `spec.md` (FR 3.2.1). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`AuthController`, `AuthServiceImpl`).

## Actors

- **User** — Guest đăng ký tài khoản mới.
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`users`, `user_system_roles`).
- **Mail** — SMTP, gửi OTP (đồng bộ trong `register`, không `@Async`).

---

## Flow A — Đăng ký thành công

1. User → FE: mở `/register`, điền `email`, `password`, `confirmPassword`, `fullName`.
2. FE → BE: `POST /api/v1/auth/register` `{email, password, fullName}`.
3. BE (`AuthServiceImpl.register`):
   a. Chuẩn hóa `email` → `toLowerCase().trim()`.
   b. Sinh OTP 6 số (`generateOtp`), hạn 10 phút.
   c. `INSERT users` (passwordHash bcrypt, otpCode, otpExpiry) — nếu email đã tồn tại, DB constraint unique ném `DataIntegrityViolationException` → BE bắt và convert thành `409 EMAIL_ALREADY_EXISTS`.
   d. `INSERT user_system_roles` (role=USER).
4. BE → Mail (đồng bộ, trong transaction): `sendOtpEmail(email, otp)`.
5. BE → FE: `201 { userId }`.
6. FE: chuyển màn OTP Verification (FR 3.2.6), truyền `email` để gọi verify.
7. Tiếp tục **FR 3.2.6 Flow verify-otp** — verify đúng → `emailVerifiedAt` được set. **KHÔNG tự động đăng nhập** (không cấp token ở bước verify-otp — user tự `POST /login` sau).

## Flow B — Đăng ký lại bằng email khác hoa/thường trong khi email cũ (chưa verify) đã tồn tại

1–2. Giống Flow A.
3. BE: `email.toLowerCase().trim()` → trùng row cũ → `INSERT` vi phạm unique constraint → `DataIntegrityViolationException` → `409 EMAIL_ALREADY_EXISTS`.
   - Không có nhánh "gửi lại OTP cho account cũ" — chỉ trả lỗi trùng email. Muốn resend, gọi riêng `POST /resend-otp`.

---

## Error paths tổng hợp (dùng cho sequence "alt"/"opt" fragments)

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Register | Email đã tồn tại (kể cả case-insensitive) | 409 | `EMAIL_ALREADY_EXISTS` |
| Register | Password/email validate fail (Bean Validation) | 400 | `VALIDATION_ERROR` |
| Verify OTP (FR 3.2.6) | OTP sai/hết hạn | 400 | `OTP_INVALID` |
| Verify OTP | Sai 5 lần liên tiếp | 400 | `OTP_TOO_MANY_ATTEMPTS` |

## Ghi chú

- Mail gửi OTP là **đồng bộ**, nằm trong transaction `@Transactional` của `register` — không phải `@Async` như một số flow khác (agency invitation email là async, sign-up OTP thì không).
