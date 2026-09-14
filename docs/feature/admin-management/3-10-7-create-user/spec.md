# UC — Create User

| | |
|---|---|
| FR Code | 3.10.7 |
| Feature | Create User |
| Domain | Admin Management (FR 3.10) |
| Role | ADMIN |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Tạo User mới vào hệ thống (thao tác thủ công bởi Admin, khác Sign Up tự đăng ký).

## 2. User Story

Là một Admin,
tôi muốn tạo User mới trực tiếp,
ví dụ để hỗ trợ khách hàng hoặc tạo account demo.

## 3. Acceptance Criteria

- Form nhập `email`, `fullName`, `initialPlan`.
- Tạo User với password tạm/random, gửi email cho user để họ tự set password lần đầu.

## 4. UI / UX

- Nút 'Tạo User' trong `/admin/users`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/admin/users
{ "email", "fullName", "initialPlan"? }
→ 201 { "success": true, "data": { "id", "email" } }
```

## 6. Error Handling

- Email đã tồn tại → 409 `EMAIL_ALREADY_EXISTS`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Tạo User thành công, gửi email set password.

## Out of Scope

- Không có.

## Tham chiếu BA

[09_Admin_Management.md](../../../BA/09_Admin_Management.md)
