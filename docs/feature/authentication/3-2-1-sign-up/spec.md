# UC — Sign Up

| | |
|---|---|
| FR Code | 3.2.1 |
| Feature | Sign Up |
| Domain | Authentication (FR 3.2) |
| Role | GUEST |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Confirmed — đã code |

## 1. Objective

Cho phép người dùng mới đăng ký tài khoản bằng email, có xác thực OTP để đảm bảo email là thật và thuộc quyền sở hữu của họ.

## 2. User Story

Là một Guest (khách chưa có tài khoản),
tôi muốn đăng ký bằng email và xác thực OTP,
để có tài khoản BrandHub và bắt đầu sử dụng hệ thống.

## 3. Acceptance Criteria

- Form nhập `email`, `password`, `confirmPassword`, `fullName`. BE nhận `email`, `password`, `fullName` (`confirmPassword` chỉ FE check, không gửi lên BE).
- Submit → hệ thống tạo `User`, gửi OTP về email, chuyển sang màn OTP Verification (FR 3.2.6).
- **Chuẩn hóa email trước khi lưu/so sánh**: `User@gmail.com` và `user@gmail.com` phải được coi là CÙNG 1 tài khoản — chuẩn hóa email về lowercase + trim trước khi lưu/check tồn tại (tránh tạo 2 account trùng chỉ khác hoa/thường).
- User được tạo ngay tại bước `register` (chưa verify — `emailVerifiedAt=null`). Xác thực OTP đúng (FR 3.2.6 `verify-otp`) → set `emailVerifiedAt=now`. **Không tự động đăng nhập** — user phải tự `POST /login` sau khi verify.
- Mật khẩu hash bằng bcrypt (`PasswordEncoder` chuẩn hệ thống).

## 4. UI / UX

- Trang `/register`. Input password có toggle show/hide. Validate real-time độ mạnh mật khẩu.
- Sau submit, chuyển màn OTP Verification (dùng chung component FR 3.2.6), đếm ngược resend OTP.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/auth/register
{ "email": "string", "password": "string", "fullName": "string" }
→ 201 { "success": true, "data": { "userId": "string" } }
```

Không có `otpSessionId`. Bước verify OTP tiếp theo (FR 3.2.6) dùng lại `email` để gọi `POST /verify-otp { "email", "otpCode" }`, không phải `otpSessionId`.

## 6. Error Handling

- Email đã tồn tại (case-insensitive) → 409 `EMAIL_ALREADY_EXISTS`.
- Password không đủ mạnh (<8 ký tự hoặc thiếu số) → 400 `VALIDATION_ERROR` (đã code: dùng chung code này, không có `WEAK_PASSWORD` riêng).
- Email sai format → 400 `VALIDATION_ERROR`.

## 7. Edge Cases

- User đăng ký lại bằng email viết hoa khác (`USER@gmail.com`) trong khi `user@gmail.com` đã tồn tại (kể cả chưa verify OTP) → chuẩn hóa lowercase trùng row cũ → vi phạm unique constraint → 409 `EMAIL_ALREADY_EXISTS` ngay, KHÔNG có logic tự resend OTP cho account cũ. Muốn nhận lại OTP, user phải tự gọi `POST /resend-otp`.
- OTP hết hạn trước khi user nhập → cho phép resend qua `POST /resend-otp` (rate-limit 60s), giữ nguyên account đã tạo.

## 8. Definition of Done

- Chuẩn hóa email hoạt động đúng (test case: đăng ký 2 lần với case khác nhau → lần 2 trả 409 `EMAIL_ALREADY_EXISTS`, không tạo thêm account).
- OTP gửi và verify thành công end-to-end (verify xong không tự login, cần gọi `/login` riêng).

## Out of Scope

- Đăng ký qua số điện thoại (chỉ email ở phạm vi này).

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)
