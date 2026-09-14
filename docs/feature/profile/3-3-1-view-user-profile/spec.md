# UC — View User Profile

| | |
|---|---|
| FR Code | 3.3.1 |
| Feature | View User Profile |
| Domain | Profile (FR 3.3) |
| Role | USER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Hiển thị thông tin cá nhân của User đang đăng nhập.

## 2. User Story

Là một User,
tôi muốn xem thông tin profile của mình,
để kiểm tra thông tin cá nhân đã lưu trên hệ thống.

## 3. Acceptance Criteria

- Hiển thị các field cơ bản: `fullName`, `email`, `avatarUrl`, `phone` (nếu có), `createdAt` (ngày tham gia).
- **[CÂU HỎI MỞ — CSV chưa chốt]** danh sách field đầy đủ của User Profile chưa được xác định trong CSV gốc (nguyên văn: "sẽ cần những field nào?"). Cần Trung xác nhận thêm field nào khác (ví dụ: bio, timezone cá nhân, ngôn ngữ ưu tiên...) trước khi thiết kế DB chính thức.

## 4. UI / UX

- Trang `/settings/profile`, phần view (không cho sửa trực tiếp — chuyển sang FR 3.3.2 Update Profile khi bấm Edit).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/users/me
→ 200 { "success": true, "data": { "id", "fullName", "email", "avatarUrl", "phone", "createdAt" } }
```

## 6. Error Handling

- Token hết hạn/không hợp lệ → 401 `UNAUTHORIZED`.

## 7. Edge Cases

- User chưa từng cập nhật avatar → trả `avatarUrl=null`, FE hiển thị avatar mặc định (initials).

## 8. Definition of Done

- Hiển thị đúng toàn bộ field đã chốt (tạm thời theo danh sách cơ bản trên, mở rộng sau khi có câu trả lời CSV).

## Out of Scope

- Field mở rộng chưa chốt (xem câu hỏi mở AC).

## Tham chiếu BA

[02_Authentication_Profile.md](../../../BA/02_Authentication_Profile.md)
