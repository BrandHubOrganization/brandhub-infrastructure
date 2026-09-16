# UC — Sign In with Google OAuth

| | |
|---|---|
| FR Code | 3.2.3 |
| Feature | Sign In with Google OAuth |
| Domain | Authentication (FR 3.2) |
| Role | GUEST |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép user đăng nhập nhanh qua Google OAuth. **Ghi chú hiện trạng: flow này đang KHÔNG chạy được — đây vừa là bug-fix vừa là rebuild theo model V2.**

## 2. User Story

Là một Guest,
tôi muốn đăng nhập bằng tài khoản Google,
để không cần nhớ thêm password riêng cho BrandHub.

## 3. Acceptance Criteria

- Nút "Đăng nhập với Google" → redirect Google OAuth consent screen.
- Callback thành công → nếu email đã có `User` (kể cả tạo qua Sign Up thường) → login vào account đó; nếu chưa có → tạo `User` mới với `emailVerified=true` (Google đã verify email).
- **Phải fix được lỗi hiện tại khiến flow không hoạt động** trước khi coi FR này hoàn thành — cần điều tra nguyên nhân cụ thể (callback URL sai, thiếu client secret, CORS...) khi bắt tay code.

## 4. UI / UX

- Nút Google OAuth đặt cùng trang `/login` và `/register`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/auth/oauth/google → redirect Google consent
GET /api/v1/auth/oauth/google/callback?code=...
→ 200 { "success": true, "data": { "accessToken", "refreshToken", "isNewUser": boolean } }
```

## 6. Error Handling

- Google trả lỗi/user cancel consent → redirect về `/login` kèm thông báo lỗi.
- Email Google đã được dùng bởi account khác qua Sign Up thường → merge vào account đó (không tạo account trùng), theo logic chuẩn hóa email chung.

## 7. Edge Cases

- User bấm Google OAuth nhưng đã có account email/password cùng email → login thẳng vào account cũ, không tạo account riêng cho "Google user".

## 8. Definition of Done

- Flow chạy được thực tế (bug hiện tại đã fix, verify bằng test đăng nhập thật).

## Out of Scope

- OAuth provider khác ngoài Google (Facebook, GitHub... không thuộc CSV V2 hiện tại).

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)
