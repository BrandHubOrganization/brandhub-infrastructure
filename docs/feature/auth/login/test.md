# Test — Đăng nhập

| # | Test case | Input | Mong đợi | Pass |
|---|---|---|---|---|
| 1 | Login đúng email | email + password hợp lệ | 200, có accessToken + Set-Cookie refreshToken | ☐ |
| 2 | Login đúng SĐT | SĐT E.164 + password (cùng user) | 200, cùng account với email | ☐ |
| 3 | Sai password | đúng identifier, sai password | 401 INVALID_CREDENTIALS | ☐ |
| 4 | Identifier không tồn tại | email/SĐT lạ | 401 (cùng message như #3) | ☐ |
| 5 | Trim identifier | identifier có khoảng trắng | login thành công | ☐ |
| 6 | Inactive/suspended | tài khoản bị khóa | 403 ACCOUNT_SUSPENDED | ☐ |
| 7 | OAuth-only | user không có passwordHash | 401 INVALID_CREDENTIALS | ☐ |
| 8 | lastLoginAt | login thành công | cập nhật thời gian | ☐ |
| 9 | Audit LOGIN | login thành công | auditLog ghi action=LOGIN | ☐ |
| 10 | Thiếu field | bỏ password | 400 VALIDATION_ERROR | ☐ |
| 11 | Refresh | access hết hạn | refresh token từ cookie cấp access mới | ☐ |
