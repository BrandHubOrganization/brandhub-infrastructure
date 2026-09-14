# UC — Sign Up

| | |
|---|---|
| FR Code | 3.2.1 |
| Feature | Sign Up |
| Domain | Authentication (FR 3.2) |
| Role | GUEST |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép người dùng mới đăng ký tài khoản bằng email, có xác thực OTP để đảm bảo email là thật và thuộc quyền sở hữu của họ.

## 2. User Story

Là một Guest (khách chưa có tài khoản),
tôi muốn đăng ký bằng email và xác thực OTP,
để có tài khoản BrandHub và bắt đầu sử dụng hệ thống.

## 3. Acceptance Criteria

- Form nhập `email`, `password`, `confirmPassword`.
- Submit → hệ thống gửi OTP về email, chuyển sang màn OTP Verification (FR 3.2.6).
- **Chuẩn hóa email trước khi lưu/so sánh**: `User@gmail.com` và `user@gmail.com` phải được coi là CÙNG 1 tài khoản — chuẩn hóa local-part về lowercase trước khi check tồn tại/tạo mới (tránh tạo 2 account trùng chỉ khác hoa/thường).
- Xác thực OTP đúng → tạo `User` mới, set `emailVerified=true`, tự động đăng nhập.
- Mật khẩu hash bằng bcrypt (cost factor theo chuẩn hệ thống hiện tại).

## 4. UI / UX

- Trang `/register`. Input password có toggle show/hide. Validate real-time độ mạnh mật khẩu.
- Sau submit, chuyển màn OTP Verification (dùng chung component FR 3.2.6), đếm ngược resend OTP.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/auth/register
{ "email": "string", "password": "string" }
→ 201 { "success": true, "data": { "otpSessionId": "string", "email": "string" } }
```

## 6. Error Handling

- Email đã tồn tại (case-insensitive) → 409 `EMAIL_ALREADY_EXISTS`.
- Password không đủ mạnh → 400 `WEAK_PASSWORD`.
- Email sai format → 400 `VALIDATION_ERROR`.

## 7. Edge Cases

- User đăng ký lại bằng email viết hoa khác (`USER@gmail.com`) trong khi `user@gmail.com` đã tồn tại nhưng chưa verify OTP → coi là cùng tài khoản, gửi lại OTP cho account cũ, không tạo account mới.
- OTP hết hạn trước khi user nhập → cho phép resend, giữ nguyên session đăng ký.

## 8. Definition of Done

- Chuẩn hóa email hoạt động đúng (test case: đăng ký 2 lần với case khác nhau chỉ tạo 1 account).
- OTP gửi và verify thành công end-to-end.

## Out of Scope

- Đăng ký qua số điện thoại (chỉ email ở phạm vi này).

## Tham chiếu BA

[02_Authentication_Profile.md](../../../BA/02_Authentication_Profile.md)
