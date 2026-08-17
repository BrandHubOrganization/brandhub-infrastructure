# Test — Quên / đặt lại mật khẩu

| # | Test case | Input | Mong đợi | Pass |
|---|---|---|---|---|
| 1 | forgot email tồn tại | email thật | 200, email chứa link token | ☐ |
| 2 | forgot email không tồn tại | email lạ | 200 (không lộ email) | ☐ |
| 3 | reset token hợp lệ | token + password mới | 200, login bằng password mới | ☐ |
| 4 | reset token hết hạn | token sau TTL | 400 INVALID_OR_EXPIRED_TOKEN | ☐ |
| 5 | reset token đã dùng | dùng lại token | 400 | ☐ |
| 6 | lastPasswordChange | reset thành công | cập nhật thời gian | ☐ |
| 7 | Password mới yếu | < 8 ký tự | 400 VALIDATION_ERROR | ☐ |
