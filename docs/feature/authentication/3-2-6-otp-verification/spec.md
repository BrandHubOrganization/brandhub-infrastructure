# UC — OTP Verification

| | |
|---|---|
| FR Code | 3.2.6 |
| Feature | OTP Verification |
| Domain | Authentication (FR 3.2) |
| Role | USER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Confirmed — đã code (email-based verify-otp/resend-otp) |

## 1. Objective

Màn hình dùng chung để user điền mã OTP — tái sử dụng cho Sign Up, Reset Password, và 2FA.

## 2. User Story

Là một User đang ở giữa 1 luồng cần xác thực OTP,
tôi muốn nhập mã OTP nhận được,
để hoàn tất bước xác thực.

## 3. Acceptance Criteria

- Input 6 số (hoặc theo chuẩn OTP hệ thống), auto-focus từng ô.
- Nút Resend OTP có đếm ngược (ví dụ 60s) trước khi bấm lại được.
- Component dùng chung — nhận `context` (register | reset-password | 2fa) qua prop/query để biết gọi API verify nào.
- Verify đúng → tiếp tục luồng tương ứng (tạo account / cho đổi password / cấp token đầy đủ).

## 4. UI / UX

- Component tái sử dụng, không tạo 3 màn OTP riêng cho 3 luồng khác nhau.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/auth/otp/verify
{ "otpSessionId": "string", "code": "string", "context": "register|reset-password|2fa" }
→ 200 { "success": true, "data": { ...tùy context... } }

POST /api/v1/auth/otp/resend
{ "otpSessionId": "string" }
→ 200 { "success": true, "data": { "nextResendAt": "ISO datetime" } }
```

## 6. Error Handling

- OTP sai → 400 `OTP_INVALID` (đã code, thay cho `INVALID_OTP`).
- OTP hết hạn → 400 `OTP_INVALID` (dùng chung code, không tách `OTP_EXPIRED`).
- Sai 5 lần liên tiếp → 400 `OTP_TOO_MANY_ATTEMPTS` (đã code: đếm attempt qua Redis, hủy OTP hiện tại khi chạm ngưỡng).

## 7. Edge Cases

- User đóng tab giữa lúc chờ OTP rồi mở lại → `otpSessionId` vẫn còn hiệu lực nếu chưa hết hạn.

## 8. Definition of Done

- Component dùng chung hoạt động đúng cho cả 3 context.

## Out of Scope

- OTP qua SMS (chỉ email trong phạm vi hiện tại).

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)
