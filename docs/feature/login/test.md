# Test — Đăng nhập

| # | Test case | Input | Mong đợi | Pass |
|---|---|---|---|---|
| 1 | Login đúng | email + password hợp lệ | 200, có accessToken | ☐ |
| 2 | Sai password | đúng email, sai password | 401 INVALID_CREDENTIALS | ☐ |
| 3 | Email không tồn tại | email lạ | 401 (cùng message như #2) | ☐ |
| 4 | Trim email | email có khoảng trắng | login thành công | ☐ |
| 5 | Inactive | tài khoản bị khóa | 403 ACCOUNT_DISABLED | ☐ |
| 6 | lastLoginAt | login thành công | cập nhật thời gian | ☐ |
| 7 | Thiếu field | bỏ password | 400 VALIDATION_ERROR | ☐ |
| 8 | Refresh | access hết hạn | refresh token cấp access mới | ☐ |
