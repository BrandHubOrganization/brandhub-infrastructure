# Test — Đăng nhập đa phương thức

| # | Test case | Input | Mong đợi | Pass |
|---|---|---|---|---|
| 1 | Login email + password | email + pass | 200 JWT | ☐ |
| 2 | Login SĐT + password | phone + pass (cùng user) | 200 JWT, cùng account | ☐ |
| 3 | Login identifier sai password | email/phone + sai pass | 401 | ☐ |
| 4 | Login SĐT không tồn tại | phone lạ | 401 | ☐ |
| 5 | Link phone mới | phone mới | OTP gửi → verify → users.phone ghi, login SĐT được | ☐ |
| 6 | Link phone trùng | phone của user khác | 409 PHONE_ALREADY_IN_USE | ☐ |
| 7 | Set-password | OAuth-only user | set → login email+pass được | ☐ |
| 8 | Set-password đã có | user có password | 400 PASSWORD_ALREADY_SET | ☐ |
| 9 | Unlink phone/oauth | gỡ 1 phương thức | vẫn login bằng phương thức còn lại | ☐ |
| 10 | Hết phương thức | cố gỡ hết | bị chặn LAST_LOGIN_METHOD | ☐ |
| 11 | /auth/me | sau link | phone + linkedProviders đúng | ☐ |
