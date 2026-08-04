# Test — Đổi mật khẩu

| # | Test case | Input | Mong đợi | Pass |
|---|---|---|---|---|
| 1 | Đúng current | current + new hợp lệ | 200, login bằng password mới | ☐ |
| 2 | Sai current | current sai | 400 INVALID_CURRENT_PASSWORD | ☐ |
| 3 | Thiếu token | không có JWT | 401 | ☐ |
| 4 | Password mới yếu | < 8 ký tự | 400 VALIDATION_ERROR | ☐ |
| 5 | lastPasswordChange | đổi thành công | cập nhật thời gian | ☐ |
