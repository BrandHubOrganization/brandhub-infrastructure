# UC — Sign Out

| | |
|---|---|
| FR Code | 3.2.8 |
| Feature | Sign Out |
| Domain | Authentication (FR 3.2) |
| Role | USER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Đăng xuất user, đồng thời lưu lại nền tảng đăng nhập lần cuối để lần sau đăng nhập tiện hơn.

## 2. User Story

Là một User đã đăng nhập,
tôi muốn đăng xuất khỏi hệ thống,
nhưng vẫn được gợi ý nhanh phương thức đăng nhập tôi hay dùng lần sau.

## 3. Acceptance Criteria

- Bấm Sign Out → revoke refresh token hiện tại, xóa token khỏi client storage.
- **Lưu lại `lastUsedLoginMethod`** (ví dụ: `email` hoặc `google_oauth`) vào local storage/cookie (không cần gửi server, hoặc gửi kèm 1 field nhẹ trên User nếu cần đồng bộ đa thiết bị — quyết định khi thiết kế kỹ thuật).
- Lần sau vào `/login`, nút tương ứng `lastUsedLoginMethod` được hiển thị nổi bật hơn (ví dụ badge "Đã dùng lần trước").

## 4. UI / UX

- Redirect về `/login` sau khi sign out, hiển thị gợi ý phương thức đăng nhập lần trước.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/auth/logout
→ 200 { "success": true, "data": null }
```

## 6. Error Handling

- Token đã hết hạn/không hợp lệ lúc logout → vẫn coi là thành công (idempotent), không báo lỗi.

## 7. Edge Cases

- User logout trên nhiều thiết bị — mỗi thiết bị chỉ revoke refresh token của chính nó, không ảnh hưởng thiết bị khác (khác với đổi mật khẩu — revoke toàn bộ).

## 8. Definition of Done

- Logout hoạt động, gợi ý last-used-method hiển thị đúng ở lần đăng nhập kế tiếp.

## Out of Scope

- Đăng xuất từ xa (remote logout tất cả thiết bị) không thuộc FR này — đó là hệ quả của Change/Reset Password.

## Tham chiếu BA

[02_Authentication_Profile.md](../../../BA/02_Authentication_Profile.md)
