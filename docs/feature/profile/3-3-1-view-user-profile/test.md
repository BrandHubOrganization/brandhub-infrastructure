# Test — View User Profile (FR 3.3.1)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | `GET /users/me` trả `fullName`, `email`, `avatarUrl`, `phone`, `createdAt` | AC | 200; đủ field cơ bản | Happy path | Pass |
| TC-02 | `preferences` jsonb chứa timezone/notificationPreferences → trả về | AC | 200; `timezone`/`notificationPreferences` đúng | Happy path | Pass |
| TC-03 | `avatarUrl` null | Edge | 200; `avatarUrl=null`, FE hiển thị initials | Edge case | Pass |
| TC-04 | User không tồn tại | Error | 404 `USER_NOT_FOUND` | Error case | Pass |

## Ghi chú

- AC = "Hiển thị các field cơ bản: fullName, email, avatarUrl, phone, createdAt".
- Unit test: `UserServiceImplTest.getUserProfile_returnsPhoneTimezoneAndNotificationPreferences`.
