# Test — Update Profile (FR 3.3.2)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | Gửi `fullName` + `phone` mới | AC | 200; fullName/phone cập nhật, timezone/notificationPreferences giữ nguyên | Happy path | Pass |
| TC-02 | Gửi `fullName` + `timezone`, không gửi notificationPreferences | AC | 200; timezone đổi, notificationPreferences không bị ghi đè | Happy path | Pass |
| TC-03 | `phone` null (không gửi) | Edge | 200; phone cũ giữ nguyên | Edge case | Pass |
| TC-04 | `fullName` rỗng | Error | 400 `@NotBlank` violation | Error case | Pass |
| TC-05 | User không tồn tại | Error | 404 `USER_NOT_FOUND` | Error case | Pass |

## Ghi chú

- AC = "Cập nhật fullName, phone, timezone, notificationPreferences; không đổi email".
- Unit test: `UserServiceImplTest.updateUserProfile_persistsFullNameAndPhonePreservingTimezoneAndNotificationPreferences`, `updateUserProfile_mergesTimezoneWithoutOverwritingNotificationPreferences`.
