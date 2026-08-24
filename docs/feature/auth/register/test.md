# Test — Đăng ký

| # | Test case | Input | Mong đợi | Pass |
|---|---|---|---|---|
| 1 | Email mới | email + password + fullName | 200, có userId, user trong DB | ☐ |
| 2 | Email trùng | email đã có | 409 EMAIL_ALREADY_EXISTS | ☐ |
| 3 | Thiếu fullName | bỏ fullName | 400 VALIDATION_ERROR | ☐ |
| 4 | Password ngắn | password < 8 ký tự | 400 | ☐ |
| 5 | Email hoa/trắng | "  X@Y.com " | tạo user, email lowercase | ☐ |
| 6 | Role mặc định | đăng ký mới | user có SystemRole.USER | ☐ |
| 7 | Hash password | kiểm tra DB | password là BCrypt, không plaintext | ☐ |
